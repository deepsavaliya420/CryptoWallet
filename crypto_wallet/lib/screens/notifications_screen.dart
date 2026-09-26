import 'package:flutter/material.dart';

import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
  });

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  List<AppNotification> notifications = [];

  bool isLoading = true;
  bool isMarkingAllRead = false;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      final data =
      await NotificationService.getNotifications();

      if (!mounted) {
        return;
      }

      setState(() {
        notifications = data;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      _showMessage(
        _cleanError(error),
        isError: true,
      );
    }
  }

  Future<void> markAllAsRead() async {
    if (isMarkingAllRead) {
      return;
    }

    setState(() {
      isMarkingAllRead = true;
    });

    try {
      await NotificationService.markAllAsRead();
      await loadNotifications();
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _cleanError(error),
        isError: true,
      );
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        isMarkingAllRead = false;
      });
    }
  }

  Future<void> deleteNotification(
      String notificationId,
      ) async {
    try {
      await NotificationService.deleteNotification(
        notificationId,
      );

      await loadNotifications();
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _cleanError(error),
        isError: true,
      );
    }
  }

  Future<void> _handleNotificationTap(
      AppNotification notification,
      ) async {
    try {
      await NotificationService.markAsRead(
        notification.id,
      );

      await loadNotifications();

      if (!mounted) {
        return;
      }

      if (notification.type == 'p2p_payment') {
        _showMessage(
          'Open your P2P order to complete payment.',
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _cleanError(error),
        isError: true,
      );
    }
  }

  void _showMessage(
      String message, {
        bool isError = false,
      }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor:
        isError ? Colors.red.shade700 : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('Bad state: ', '');
  }

  String formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }

    if (difference.inHours < 24) {
      return difference.inHours == 1
          ? '1 hour ago'
          : '${difference.inHours} hours ago';
    }

    if (difference.inDays == 1) {
      return 'Yesterday';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }

    return '${time.day}/${time.month}/${time.year}';
  }

  int get _unreadCount {
    return notifications
        .where((notification) => !notification.isRead)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              tooltip: 'Mark all as read',
              onPressed:
              isMarkingAllRead
                  ? null
                  : markAllAsRead,
              icon: isMarkingAllRead
                  ? const SizedBox(
                width: 20,
                height: 20,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Icon(
                Icons.done_all_rounded,
              ),
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : notifications.isEmpty
          ? _EmptyNotifications(
        colorScheme: colorScheme,
      )
          : RefreshIndicator(
        onRefresh: loadNotifications,
        child: ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding:
          const EdgeInsets.fromLTRB(
            18,
            8,
            18,
            30,
          ),
          children: [
            _buildHeader(context),

            const SizedBox(height: 20),

            if (_unreadCount > 0)
              Padding(
                padding:
                const EdgeInsets.only(
                  bottom: 12,
                ),
                child: Text(
                  '$_unreadCount unread notification${_unreadCount == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w700,
                    color: colorScheme
                        .onSurfaceVariant,
                  ),
                ),
              ),

            ...notifications.map(
                  (
                  AppNotification notification,
                  ) {
                return Dismissible(
                  key: ValueKey(
                    notification.id,
                  ),
                  direction:
                  DismissDirection
                      .endToStart,
                  onDismissed: (_) {
                    deleteNotification(
                      notification.id,
                    );
                  },
                  background:
                  _buildDeleteBackground(
                    context,
                  ),
                  child:
                  _NotificationCard(
                    notification:
                    notification,
                    time: formatTime(
                      notification
                          .createdAt,
                    ),
                    onTap: () {
                      _handleNotificationTap(
                        notification,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary
                .withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 51,
            height: 51,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.15,
              ),
              borderRadius:
              BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stay Updated',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _unreadCount == 0
                      ? 'You are all caught up.'
                      : 'You have $_unreadCount unread update${_unreadCount == 1 ? '' : 's'}.',
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: 0.78,
                    ),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteBackground(
      BuildContext context,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      padding: const EdgeInsets.only(
        right: 22,
      ),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: colorScheme.error,
        borderRadius:
        BorderRadius.circular(19),
      ),
      child: Icon(
        Icons.delete_outline_rounded,
        color: colorScheme.onError,
        size: 25,
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final String time;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final bool isP2P =
        notification.type == 'p2p_payment';

    final Color iconColor = isP2P
        ? colorScheme.primary
        : colorScheme.secondary;

    final Color iconBackground =
    isP2P
        ? colorScheme.primaryContainer
        : colorScheme.secondaryContainer;

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: notification.isRead
            ? colorScheme.surface
            : colorScheme.primaryContainer
            .withValues(alpha: 0.28),
        borderRadius:
        BorderRadius.circular(19),
        border: Border.all(
          color: notification.isRead
              ? colorScheme.outlineVariant
              .withValues(alpha: 0.35)
              : colorScheme.primary
              .withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow
                .withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius:
          BorderRadius.circular(19),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius:
                    BorderRadius.circular(15),
                  ),
                  child: Icon(
                    isP2P
                        ? Icons
                        .account_balance_wallet_outlined
                        : Icons
                        .notifications_outlined,
                    color: iconColor,
                    size: 23,
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                notification.isRead
                                    ? FontWeight.w600
                                    : FontWeight.w800,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 9,
                              height: 9,
                              margin:
                              const EdgeInsets.only(
                                top: 4,
                                left: 8,
                              ),
                              decoration:
                              BoxDecoration(
                                shape:
                                BoxShape.circle,
                                color:
                                colorScheme.primary,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: colorScheme
                              .onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 9),

                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: colorScheme
                                .onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight:
                              FontWeight.w600,
                              color: colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyNotifications
    extends StatelessWidget {
  final ColorScheme colorScheme;

  const _EmptyNotifications({
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme
                    .primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 50,
                color: colorScheme
                    .onPrimaryContainer,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'All Caught Up',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'You have no notifications right now.\nNew wallet and P2P updates will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.5,
                color:
                colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}