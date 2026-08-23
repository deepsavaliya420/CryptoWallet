import 'package:flutter/material.dart';

import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  List<AppNotification> notifications = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    final data =
    await NotificationService.getNotifications();

    if (!mounted) {
      return;
    }

    setState(() {
      notifications = data;
      isLoading = false;
    });
  }

  Future<void> markAllAsRead() async {
    await NotificationService.markAllAsRead();
    await loadNotifications();
  }

  Future<void> deleteNotification(
      String notificationId,
      ) async {
    await NotificationService.deleteNotification(
      notificationId,
    );

    await loadNotifications();
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
      return '${difference.inHours} hour ago';
    }

    if (difference.inDays == 1) {
      return 'Yesterday';
    }

    return '${difference.inDays} days ago';
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
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (notifications.isNotEmpty)
            IconButton(
              tooltip: 'Mark all as read',
              onPressed: markAllAsRead,
              icon: const Icon(
                Icons.done_all,
              ),
            ),
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
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          itemBuilder: (
              context,
              index,
              ) {
            final notification =
            notifications[index];

            return Dismissible(
              key: ValueKey(
                notification.id,
              ),
              direction:
              DismissDirection.endToStart,
              onDismissed: (_) {
                deleteNotification(
                  notification.id,
                );
              },
              background: Container(
                margin:
                const EdgeInsets.only(
                  bottom: 12,
                ),
                alignment:
                Alignment.centerRight,
                padding:
                const EdgeInsets.only(
                  right: 20,
                ),
                decoration: BoxDecoration(
                  color:
                  colorScheme.error,
                  borderRadius:
                  BorderRadius.circular(
                    16,
                  ),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: colorScheme
                      .onError,
                ),
              ),
              child: _NotificationCard(
                notification:
                notification,
                time: formatTime(
                  notification.createdAt,
                ),
                onTap: () async {
                  await NotificationService
                      .markAsRead(
                    notification.id,
                  );

                  await loadNotifications();

                  if (!context.mounted) {
                    return;
                  }

                  if (notification.type ==
                      'p2p_payment') {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Open your P2P order to complete payment.',
                        ),
                      ),
                    );
                  }
                },
              ),
            );
          },
        ),
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

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor:
                isP2P
                    ? colorScheme
                    .primaryContainer
                    : colorScheme
                    .secondaryContainer,
                child: Icon(
                  isP2P
                      ? Icons.payment
                      : Icons.notifications,
                  color: isP2P
                      ? colorScheme
                      .onPrimaryContainer
                      : colorScheme
                      .onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight:
                              notification
                                  .isRead
                                  ? FontWeight
                                  .w500
                                  : FontWeight
                                  .bold,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration:
                            BoxDecoration(
                              shape:
                              BoxShape.circle,
                              color: colorScheme
                                  .primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.message,
                      style: TextStyle(
                        color: colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
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
            CircleAvatar(
              radius: 42,
              backgroundColor:
              colorScheme.primaryContainer,
              child: Icon(
                Icons.notifications_none,
                size: 48,
                color:
                colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Notifications',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your P2P payment notifications will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
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