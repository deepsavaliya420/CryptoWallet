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
        'requestedFrom':
        requestedFrom.trim(),

        'requestedTo':
        requestedTo.trim(),

        'asset':
        asset.trim().toUpperCase(),

        'amount':
        amount,

        'walletAddress':
        requestedTo.trim(),

        'network':
        network.trim(),

        'status':
        'pending',
      },
    );

    if (response['success'] != true ||
        response['receiveRequest'] == null) {
      throw StateError(
        response['message']?.toString() ??
            'Receive request could not be created.',
      );
    }

    final Map<String, dynamic> data =
    Map<String, dynamic>.from(
      response['receiveRequest'],
    );

    final ReceiveRequest request =
    _fromBackendMap(data);

    _requests.removeWhere(
          (ReceiveRequest item) =>
      item.id == request.id,
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
  // GET REQUESTS
  // ============================================================

  static Future<List<ReceiveRequest>>
  getRequests() async {
    await _refreshFromBackend();

    return List<ReceiveRequest>.unmodifiable(
      _requests,
    );
  }

  // ============================================================
  // GET PENDING REQUESTS
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
          (
          ReceiveRequest a,
          ReceiveRequest b,
          ) =>
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

  static Future<ReceiveRequest?>
  getRequest(
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
  // APPROVE REQUEST
  // ============================================================

  static Future<ReceiveRequest>
  approveRequest(
      String requestId,
      ) async {
    final response = await ApiService.put(
      '/receive-requests/$requestId/approve',
      {},
    );

    if (response['success'] != true ||
        response['receiveRequest'] == null) {
      throw StateError(
        response['message']?.toString() ??
            'Receive request could not be approved.',
      );
    }

    final Map<String, dynamic> data =
    Map<String, dynamic>.from(
      response['receiveRequest'],
    );

    final ReceiveRequest updated =
    _fromBackendMap(data);

    _updateLocalRequest(updated);

    return updated;
  }

  // ============================================================
  // DENY REQUEST
  // ============================================================

  static Future<ReceiveRequest>
  denyRequest(
      String requestId,
      ) async {
    final response = await ApiService.put(
      '/receive-requests/$requestId/deny',
      {},
    );

    if (response['success'] != true ||
        response['receiveRequest'] == null) {
      throw StateError(
        response['message']?.toString() ??
            'Receive request could not be denied.',
      );
    }

    final Map<String, dynamic> data =
    Map<String, dynamic>.from(
      response['receiveRequest'],
    );

    final ReceiveRequest updated =
    _fromBackendMap(data);

    _updateLocalRequest(updated);

    return updated;
  }

  // ============================================================
  // CANCEL REQUEST
  // ============================================================

  static Future<ReceiveRequest>
  cancelRequest(
      String requestId,
      ) async {
    return _updateRequestStatus(
      requestId: requestId,
      status: 'cancelled',
    );
  }

  // ============================================================
  // COMPLETE REQUEST
  // ============================================================

  static Future<ReceiveRequest>
  completeRequest(
      String requestId,
      ) async {
    return _updateRequestStatus(
      requestId: requestId,
      status: 'completed',
    );
  }

  // ============================================================
  // UPDATE REQUEST STATUS
  // ============================================================

  static Future<ReceiveRequest>
  _updateRequestStatus({
    required String requestId,
    required String status,
  }) async {
    final response = await ApiService.put(
      '/receive-requests/$requestId',
      {
        'status': status,
      },
    );

    if (response['success'] != true ||
        response['receiveRequest'] == null) {
      throw StateError(
        response['message']?.toString() ??
            'Receive request could not be updated.',
      );
    }

    final Map<String, dynamic> data =
    Map<String, dynamic>.from(
      response['receiveRequest'],
    );

    final ReceiveRequest updated =
    _fromBackendMap(data);

    _updateLocalRequest(updated);

    return updated;
  }

  // ============================================================
  // DELETE REQUEST
  // ============================================================

  static Future<void> deleteRequest(
      String requestId,
      ) async {
    final response =
    await ApiService.delete(
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
  // CLEAR REQUESTS
  // ============================================================

  static Future<void> clearRequests() async {
    final response =
    await ApiService.delete(
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

  static Future<void>
  _refreshFromBackend() async {
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
        response['receiveRequests'] ?? [];

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
  // UPDATE LOCAL REQUEST
  // ============================================================

  static void _updateLocalRequest(
      ReceiveRequest updated,
      ) {
    final int index =
    _requests.indexWhere(
          (ReceiveRequest request) =>
      request.id == updated.id,
    );

    if (index == -1) {
      _requests.insert(
        0,
        updated,
      );
    } else {
      _requests[index] = updated;
    }

    _sortRequests();
  }

  // ============================================================
  // BACKEND MAP → MODEL
  // ============================================================

  static ReceiveRequest _fromBackendMap(
      Map<String, dynamic> data,
      ) {
    return ReceiveRequest(
      id:
      data['requestId']?.toString() ??
          data['_id']?.toString() ??
          'REQ-${DateTime.now().millisecondsSinceEpoch}',

      requestedFrom:
      data['requestedFrom']?.toString() ??
          '',

      requestedTo:
      data['requestedTo']?.toString() ??
          data['walletAddress']?.toString() ??
          '',

      asset:
      data['asset']
          ?.toString()
          .toUpperCase() ??
          '',

      network:
      data['network']?.toString() ??
          '',

      amount:
      _toDouble(data['amount']),

      status:
      data['status']?.toString() ??
          'pending',

      createdAt:
      _parseDate(data['createdAt']),

      completedAt:
      _parseNullableDate(
        data['completedAt'],
      ),
    );
  }

  // ============================================================
  // DOUBLE PARSER
  // ============================================================

  static double _toDouble(
      dynamic value,
      ) {
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

  static DateTime _parseDate(
      dynamic value,
      ) {
    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(
      value?.toString() ?? '',
    ) ??
        DateTime.now();
  }

  // ============================================================
  // NULLABLE DATE PARSER
  // ============================================================

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