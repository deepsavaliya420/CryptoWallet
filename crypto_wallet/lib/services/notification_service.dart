import 'api_service.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotificationService {
  static final List<AppNotification>
  _notifications = <AppNotification>[];

  static bool _initialized = false;

  // ============================================================
  // INITIALIZE
  // ============================================================

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    try {
      final response = await ApiService.get(
        '/notifications',
      );

      if (response['success'] != true) {
        throw StateError(
          response['message']?.toString() ??
              'Notifications could not be loaded.',
        );
      }

      _notifications.clear();

      final List<dynamic> data =
          response['notifications'] ?? [];

      for (final dynamic item in data) {
        if (item is Map<String, dynamic>) {
          _notifications.add(
            _fromBackendMap(item),
          );
        }
      }

      _sortNotifications();

      _initialized = true;
    } catch (e) {
      _initialized = false;
      rethrow;
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  static Future<void> refresh() async {
    _initialized = false;

    await initialize();
  }

  // ============================================================
  // GET ALL NOTIFICATIONS
  // ============================================================

  static Future<List<AppNotification>>
  getNotifications() async {
    await _refreshFromBackend();

    return List<AppNotification>.unmodifiable(
      _notifications,
    );
  }

  // ============================================================
  // UNREAD COUNT
  // ============================================================

  static int get unreadCount {
    return _notifications
        .where(
          (AppNotification notification) =>
      !notification.isRead,
    )
        .length;
  }

  // ============================================================
  // ADD NOTIFICATION
  // ============================================================

  static Future<void> addNotification({
    required String title,
    required String message,
    required String type,
  }) async {
    final String backendType =
    _convertTypeToBackend(type);

    final response = await ApiService.post(
      '/notifications',
      {
        'title': title,
        'message': message,
        'type': backendType,
      },
    );

    if (response['success'] != true ||
        response['notification'] == null) {
      throw StateError(
        response['message']?.toString() ??
            'Notification could not be created.',
      );
    }

    final Map<String, dynamic> data =
    Map<String, dynamic>.from(
      response['notification'],
    );

    final AppNotification notification =
    _fromBackendMap(data);

    _notifications.insert(
      0,
      notification,
    );

    _sortNotifications();

    _initialized = true;
  }

  // ============================================================
  // CREATE P2P PAYMENT NOTIFICATION
  // ============================================================

  static Future<void>
  createP2PPaymentNotification({
    required String sellerName,
    required String asset,
    required double amount,
    required double totalPrice,
    required String paymentMethod,
    required String orderId,
  }) async {
    await addNotification(
      title: 'P2P Payment Required',
      message:
      'Pay ₹${totalPrice.toStringAsFixed(2)} '
          'for ${amount.toStringAsFixed(2)} '
          '$asset to $sellerName '
          'using $paymentMethod.',
      type: 'p2p_payment',
    );
  }

  // ============================================================
  // MARK AS READ
  // ============================================================

  static Future<void> markAsRead(
      String notificationId,
      ) async {
    final response = await ApiService.put(
      '/notifications/$notificationId/read',
      {},
    );

    if (response['success'] != true) {
      throw StateError(
        response['message']?.toString() ??
            'Notification could not be marked as read.',
      );
    }

    final int index =
    _notifications.indexWhere(
          (AppNotification notification) =>
      notification.id ==
          notificationId,
    );

    if (index != -1) {
      _notifications[index] =
          _notifications[index].copyWith(
            isRead: true,
          );
    }
  }

  // ============================================================
  // MARK ALL AS READ
  // ============================================================

  static Future<void> markAllAsRead() async {
    final response = await ApiService.put(
      '/notifications/read-all',
      {},
    );

    if (response['success'] != true) {
      throw StateError(
        response['message']?.toString() ??
            'Notifications could not be marked as read.',
      );
    }

    for (int i = 0;
    i < _notifications.length;
    i++) {
      _notifications[i] =
          _notifications[i].copyWith(
            isRead: true,
          );
    }
  }

  // ============================================================
  // DELETE ONE NOTIFICATION
  // ============================================================

  static Future<void> deleteNotification(
      String notificationId,
      ) async {
    final response = await ApiService.delete(
      '/notifications/$notificationId',
    );

    if (response['success'] != true) {
      throw StateError(
        response['message']?.toString() ??
            'Notification could not be deleted.',
      );
    }

    _notifications.removeWhere(
          (AppNotification notification) =>
      notification.id ==
          notificationId,
    );
  }

  // ============================================================
  // CLEAR ALL NOTIFICATIONS
  // ============================================================

  static Future<void> clearNotifications() async {
    final response = await ApiService.delete(
      '/notifications',
    );

    if (response['success'] != true) {
      throw StateError(
        response['message']?.toString() ??
            'Notifications could not be cleared.',
      );
    }

    _notifications.clear();
  }

  // ============================================================
  // REFRESH FROM BACKEND
  // ============================================================

  static Future<void> _refreshFromBackend() async {
    try {
      final response = await ApiService.get(
        '/notifications',
      );

      if (response['success'] != true) {
        return;
      }

      final List<dynamic> data =
          response['notifications'] ?? [];

      _notifications.clear();

      for (final dynamic item in data) {
        if (item is Map<String, dynamic>) {
          _notifications.add(
            _fromBackendMap(item),
          );
        }
      }

      _sortNotifications();

      _initialized = true;
    } catch (e) {
      if (!_initialized) {
        rethrow;
      }
    }
  }

  // ============================================================
  // BACKEND MAP → FLUTTER MODEL
  // ============================================================

  static AppNotification _fromBackendMap(
      Map<String, dynamic> data,
      ) {
    return AppNotification(
      id:
      data['notificationId']?.toString() ??
          data['_id']?.toString() ??
          'NOT-${DateTime.now().millisecondsSinceEpoch}',
      title:
      data['title']?.toString() ?? '',
      message:
      data['message']?.toString() ?? '',
      type:
      _convertTypeFromBackend(
        data['type']?.toString() ?? '',
      ),
      createdAt:
      _parseDate(data['createdAt']),
      isRead:
      data['isRead'] == true,
    );
  }

  // ============================================================
  // TYPE CONVERSION
  // ============================================================

  static String _convertTypeToBackend(
      String type,
      ) {
    switch (type.toLowerCase()) {
      case 'transaction':
        return 'transaction';

      case 'swap':
        return 'swap';

      case 'p2p':
      case 'p2p_payment':
        return 'p2p';

      case 'security':
        return 'security';

      case 'system':
        return 'system';

      case 'general':
        return 'general';

      default:
        return 'general';
    }
  }

  static String _convertTypeFromBackend(
      String type,
      ) {
    switch (type.toLowerCase()) {
      case 'transaction':
        return 'transaction';

      case 'swap':
        return 'swap';

      case 'p2p':
        return 'p2p';

      case 'security':
        return 'security';

      case 'system':
        return 'system';

      case 'general':
        return 'general';

      default:
        return type;
    }
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

    final DateTime? parsed =
    DateTime.tryParse(
      value?.toString() ?? '',
    );

    return parsed ?? DateTime.now();
  }

  // ============================================================
  // SORT
  // ============================================================

  static void _sortNotifications() {
    _notifications.sort(
          (
          AppNotification a,
          AppNotification b,
          ) {
        return b.createdAt.compareTo(
          a.createdAt,
        );
      },
    );
  }
}