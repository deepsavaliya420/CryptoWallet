import 'package:shared_preferences/shared_preferences.dart';

import '../models/receive_request.dart';

class ReceiveRequestService {
  static const String _storageKey =
      'receive_requests';

  static final List<ReceiveRequest> _requests = [];

  static bool _initialized = false;

  // ============================================================
  // INITIALIZE
  // ============================================================

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    final prefs =
    await SharedPreferences.getInstance();

    final savedRequests =
    prefs.getStringList(_storageKey);

    if (savedRequests != null) {
      _requests.clear();

      for (final requestJson in savedRequests) {
        try {
          _requests.add(
            ReceiveRequest.fromJson(
              requestJson,
            ),
          );
        } catch (_) {
          // Ignore corrupted request data.
        }
      }
    }

    _sortRequests();

    _initialized = true;
  }

  // ============================================================
  // CREATE REQUEST
  // ============================================================

  static Future<ReceiveRequest>
  createRequest({
    required String requestedFrom,
    required String requestedTo,
    required String asset,
    required String network,
    required double amount,
  }) async {
    await initialize();

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

    final request =
    ReceiveRequest(
      id:
      'REQ-${DateTime.now().millisecondsSinceEpoch}',
      requestedFrom:
      requestedFrom.trim(),
      requestedTo:
      requestedTo.trim(),
      asset:
      asset.toUpperCase(),
      network:
      network,
      amount:
      amount,
      status:
      'pending',
      createdAt:
      DateTime.now(),
    );

    _requests.insert(
      0,
      request,
    );

    await _saveRequests();

    return request;
  }

  // ============================================================
  // LOAD ALL REQUESTS
  // ============================================================

  static Future<List<ReceiveRequest>>
  getRequests() async {
    await initialize();

    _sortRequests();

    return List.unmodifiable(
      _requests,
    );
  }

  // ============================================================
  // LOAD PENDING REQUESTS
  // ============================================================

  static Future<List<ReceiveRequest>>
  getPendingRequests() async {
    await initialize();

    final pending =
    _requests.where(
          (request) =>
      request.status.toLowerCase() ==
          'pending',
    ).toList();

    pending.sort(
          (a, b) =>
          b.createdAt.compareTo(
            a.createdAt,
          ),
    );

    return List.unmodifiable(
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
    await initialize();

    try {
      return _requests.firstWhere(
            (request) =>
        request.id == requestId,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // CANCEL REQUEST
  // ============================================================

  static Future<ReceiveRequest>
  cancelRequest(
      String requestId,
      ) async {
    await initialize();

    final index =
    _requests.indexWhere(
          (request) =>
      request.id == requestId,
    );

    if (index == -1) {
      throw StateError(
        'Receive request not found.',
      );
    }

    final request =
    _requests[index];

    if (request.status.toLowerCase() !=
        'pending') {
      throw StateError(
        'Only pending requests can be cancelled.',
      );
    }

    final cancelled =
    request.copyWith(
      status: 'cancelled',
    );

    _requests[index] =
        cancelled;

    await _saveRequests();

    return cancelled;
  }

  // ============================================================
  // COMPLETE REQUEST
  // ============================================================

  static Future<ReceiveRequest>
  completeRequest(
      String requestId,
      ) async {
    await initialize();

    final index =
    _requests.indexWhere(
          (request) =>
      request.id == requestId,
    );

    if (index == -1) {
      throw StateError(
        'Receive request not found.',
      );
    }

    final request =
    _requests[index];

    if (request.status.toLowerCase() !=
        'pending') {
      throw StateError(
        'Only pending requests can be completed.',
      );
    }

    final completed =
    request.copyWith(
      status: 'completed',
      completedAt:
      DateTime.now(),
    );

    _requests[index] =
        completed;

    await _saveRequests();

    return completed;
  }

  // ============================================================
  // DELETE REQUEST
  // ============================================================

  static Future<void> deleteRequest(
      String requestId,
      ) async {
    await initialize();

    _requests.removeWhere(
          (request) =>
      request.id == requestId,
    );

    await _saveRequests();
  }

  // ============================================================
  // CLEAR ALL REQUESTS
  // ============================================================

  static Future<void> clearRequests() async {
    await initialize();

    _requests.clear();

    await _saveRequests();
  }

  // ============================================================
  // STORAGE
  // ============================================================

  static Future<void> _saveRequests() async {
    final prefs =
    await SharedPreferences.getInstance();

    final encoded =
    _requests
        .map(
          (request) =>
          request.toJson(),
    )
        .toList();

    await prefs.setStringList(
      _storageKey,
      encoded,
    );
  }

  // ============================================================
  // SORT
  // ============================================================

  static void _sortRequests() {
    _requests.sort(
          (a, b) =>
          b.createdAt.compareTo(
            a.createdAt,
          ),
    );
  }
}