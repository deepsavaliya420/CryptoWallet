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
  static final List<AppNotification> _notifications = [];

  /// Get all notifications.
  static Future<List<AppNotification>> getNotifications() async {
    return List.unmodifiable(_notifications);
  }

  /// Get unread notification count.
  static int get unreadCount {
    return _notifications
        .where((notification) => !notification.isRead)
        .length;
  }

  /// Add a new notification.
  static Future<void> addNotification({
    required String title,
    required String message,
    required String type,
  }) async {
    final notification = AppNotification(
      id: 'NOT-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      type: type,
      createdAt: DateTime.now(),
    );

    _notifications.insert(0, notification);
  }

  /// Create a P2P payment notification.
  static Future<void> createP2PPaymentNotification({
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
      'Pay ₹${totalPrice.toStringAsFixed(2)} for ${amount.toStringAsFixed(2)} $asset to $sellerName using $paymentMethod.',
      type: 'p2p_payment',
    );
  }

  /// Mark notification as read.
  static Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere(
          (notification) => notification.id == notificationId,
    );

    if (index == -1) {
      return;
    }

    _notifications[index] =
        _notifications[index].copyWith(
          isRead: true,
        );
  }

  /// Mark all notifications as read.
  static Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] =
          _notifications[i].copyWith(
            isRead: true,
          );
    }
  }

  /// Delete one notification.
  static Future<void> deleteNotification(
      String notificationId,
      ) async {
    _notifications.removeWhere(
          (notification) =>
      notification.id == notificationId,
    );
  }

  /// Clear all notifications.
  static Future<void> clearNotifications() async {
    _notifications.clear();
  }
}