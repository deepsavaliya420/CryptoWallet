import '../models/receive_request.dart';
import 'api_service.dart';

class ReceiveRequestService {
  static final List<ReceiveRequest> _requests =
  <ReceiveRequest>[];

  static bool _initialized = false;

  // ============================================================
  // INITIALIZE
  // ============================================================

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    await _refreshFromBackend();

    _initialized = true;
  }

  // ============================================================
  // REFRESH
  // ============================================================

  static Future<void> refresh() async {
    _initialized = false;

    await initialize();
  }

  // ============================================================
  // CREATE REQUEST
  // ============================================================

  static Future<ReceiveRequest> createRequest({
    required String requestedFrom,
    required String requestedTo,
    required String asset,
    required String network,
    required double amount,
  }) async {
    if (requestedFrom.trim().isEmpty) {
      throw StateError(
        'Sender wallet address is required.',
      );
    }

    if (requestedTo.trim().isEmpty) {
      throw StateError(
        'Your wallet address is required.',
      );
    }

    if (amount <= 0) {
      throw StateError(
        'Requested amount must be greater than zero.',
      );
    }

    final response = await ApiService.post(
      '/receive-requests',
      {
        'asset': asset.trim().toUpperCase(),
        'amount': amount,
        'walletAddress': requestedTo.trim(),
        'network': network.trim(),
      },
    );

    if (response['success'] != true ||
        response['request'] == null) {
      throw StateError(
        response['message']?.toString() ??
            'Receive request could not be created.',
      );
    }

    final Map<String, dynamic> data =
    Map<String, dynamic>.from(
      response['request'],
    );

    final ReceiveRequest request =
    _fromBackendMap(
      data,
      requestedFrom: requestedFrom.trim(),
    );

    _requests.insert(
      0,
      request,
    );

    _sortRequests();

    _initialized = true;

    return request;
  }

  // ============================================================
  // LOAD ALL REQUESTS
  // ============================================================

  static Future<List<ReceiveRequest>>
  getRequests() async {
    await _refreshFromBackend();

    return List<ReceiveRequest>.unmodifiable(
      _requests,
    );
  }

  // ============================================================
  // LOAD PENDING REQUESTS
  // ============================================================

  static Future<List<ReceiveRequest>>
  getPendingRequests() async {
    await _refreshFromBackend();

    final List<ReceiveRequest> pending =
    _requests
        .where(
          (ReceiveRequest request) =>
      request.status.toLowerCase() ==
          'pending',
    )
        .toList();

    pending.sort(
          (ReceiveRequest a, ReceiveRequest b) =>
          b.createdAt.compareTo(
            a.createdAt,
          ),
    );

    return List<ReceiveRequest>.unmodifiable(
      pending,
    );
  }

  // ============================================================
  // GET ONE REQUEST
  // ============================================================

  static Future<ReceiveRequest?> getRequest(
      String requestId,
      ) async {
    await _refreshFromBackend();

    try {
      return _requests.firstWhere(
            (ReceiveRequest request) =>
        request.id == requestId,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // CANCEL REQUEST
  // ============================================================

  static Future<ReceiveRequest> cancelRequest(
      String requestId,
      ) async {
    final response = await ApiService.put(
      '/receive-requests/$requestId/cancel',
      {},
    );

    if (response['success'] != true ||
        response['request'] == null) {
      throw StateError(
        response['message']?.toString() ??
            'Receive request could not be cancelled.',
      );
    }

    final Map<String, dynamic> data =
    Map<String, dynamic>.from(
      response['request'],
    );

    final int index =
    _requests.indexWhere(
          (ReceiveRequest request) =>
      request.id == requestId,
    );

    final ReceiveRequest oldRequest =
    index == -1
        ? _fromBackendMap(data)
        : _requests[index];

    final ReceiveRequest cancelled =
    _fromBackendMap(
      data,
      requestedFrom:
      oldRequest.requestedFrom,
    );

    if (index == -1) {
      _requests.insert(
        0,
        cancelled,
      );
    } else {
      _requests[index] = cancelled;
    }

    _sortRequests();

    return cancelled;
  }

  // ============================================================
  // COMPLETE REQUEST
  // ============================================================
  //
  // Backend currently supports:
  // pending
  // completed
  // cancelled
  //
  // Completing a request only changes its status.
  // It does NOT automatically transfer wallet funds.
  // ============================================================

  static Future<ReceiveRequest> completeRequest(
      String requestId,
      ) async {
    final response = await ApiService.put(
      '/receive-requests/$requestId/complete',
      {},
    );

    if (response['success'] != true ||
        response['request'] == null) {
      throw StateError(
        response['message']?.toString() ??
            'Receive request could not be completed.',
      );
    }

    final Map<String, dynamic> data =
    Map<String, dynamic>.from(
      response['request'],
    );

    final int index =
    _requests.indexWhere(
          (ReceiveRequest request) =>
      request.id == requestId,
    );

    final ReceiveRequest oldRequest =
    index == -1
        ? _fromBackendMap(data)
        : _requests[index];

    final ReceiveRequest completed =
    _fromBackendMap(
      data,
      requestedFrom:
      oldRequest.requestedFrom,
    );

    if (index == -1) {
      _requests.insert(
        0,
        completed,
      );
    } else {
      _requests[index] = completed;
    }

    _sortRequests();

    return completed;
  }

  // ============================================================
  // DELETE REQUEST
  // ============================================================

  static Future<void> deleteRequest(
      String requestId,
      ) async {
    final response = await ApiService.delete(
      '/receive-requests/$requestId',
    );

    if (response['success'] != true) {
      throw StateError(
        response['message']?.toString() ??
            'Receive request could not be deleted.',
      );
    }

    _requests.removeWhere(
          (ReceiveRequest request) =>
      request.id == requestId,
    );
  }

  // ============================================================
  // CLEAR ALL REQUESTS
  // ============================================================

  static Future<void> clearRequests() async {
    final response = await ApiService.delete(
      '/receive-requests',
    );

    if (response['success'] != true) {
      throw StateError(
        response['message']?.toString() ??
            'Receive requests could not be cleared.',
      );
    }

    _requests.clear();
  }

  // ============================================================
  // REFRESH FROM BACKEND
  // ============================================================

  static Future<void> _refreshFromBackend() async {
    final response = await ApiService.get(
      '/receive-requests',
    );

    if (response['success'] != true) {
      throw StateError(
        response['message']?.toString() ??
            'Receive requests could not be loaded.',
      );
    }

    final List<dynamic> data =
        response['requests'] ?? [];

    _requests.clear();

    for (final dynamic item in data) {
      if (item is Map<String, dynamic>) {
        _requests.add(
          _fromBackendMap(item),
        );
      }
    }

    _sortRequests();
  }

  // ============================================================
  // BACKEND MAP → FLUTTER MODEL
  // ============================================================

  static ReceiveRequest _fromBackendMap(
      Map<String, dynamic> data, {
        String requestedFrom = '',
      }) {
    return ReceiveRequest(
      id:
      data['requestId']?.toString() ??
          data['_id']?.toString() ??
          'REQ-${DateTime.now().millisecondsSinceEpoch}',
      requestedFrom:
      requestedFrom,
      requestedTo:
      data['walletAddress']?.toString() ?? '',
      asset:
      data['asset']?.toString().toUpperCase() ?? '',
      network:
      data['network']?.toString() ?? '',
      amount:
      _toDouble(data['amount']),
      status:
      data['status']?.toString() ?? 'pending',
      createdAt:
      _parseDate(data['createdAt']),
      completedAt:
      _parseNullableDate(
        data['completedAt'],
      ),
    );
  }

  // ============================================================
  // NUMBER PARSER
  // ============================================================

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0.0;
  }

  // ============================================================
  // DATE PARSER
  // ============================================================

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    final DateTime? parsed =
    DateTime.tryParse(
      value?.toString() ?? '',
    );

    return parsed ?? DateTime.now();
  }

  static DateTime? _parseNullableDate(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  // ============================================================
  // SORT
  // ============================================================

  static void _sortRequests() {
    _requests.sort(
          (
          ReceiveRequest a,
          ReceiveRequest b,
          ) {
        return b.createdAt.compareTo(
          a.createdAt,
        );
      },
    );
  }
}