import 'package:flutter/material.dart';

import '../services/user_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({
    super.key,
  });

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = UserService.settings;
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
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            18,
            8,
            18,
            30,
          ),
          children: [
            _buildHeader(context),

            const SizedBox(height: 26),

            _buildSection(
              context,
              title: 'Transactions',
              subtitle:
              'Choose which wallet activity you want to know about.',
              icon: Icons.receipt_long_outlined,
              children: [
                _buildNotificationTile(
                  context,
                  icon: Icons.arrow_downward_rounded,
                  iconColor: Colors.green,
                  title: 'Transaction Received',
                  subtitle:
                  'Notify me when crypto is received',
                  value:
                  settings.transactionReceived,
                  onChanged: (value) {
                    setState(() {
                      settings.transactionReceived =
                          value;
                    });
                  },
                ),
                _buildDivider(context),
                _buildNotificationTile(
                  context,
                  icon: Icons.arrow_upward_rounded,
                  iconColor: Colors.red,
                  title: 'Transaction Sent',
                  subtitle:
                  'Notify me when crypto is sent',
                  value:
                  settings.transactionSent,
                  onChanged: (value) {
                    setState(() {
                      settings.transactionSent =
                          value;
                    });
                  },
                ),
                _buildDivider(context),
                _buildNotificationTile(
                  context,
                  icon: Icons.error_outline_rounded,
                  iconColor: Colors.orange,
                  title: 'Transaction Failed',
                  subtitle:
                  'Notify me when a transaction fails',
                  value:
                  settings.transactionFailed,
                  onChanged: (value) {
                    setState(() {
                      settings.transactionFailed =
                          value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 22),

            _buildSection(
              context,
              title: 'Security',
              subtitle:
              'Stay informed about activity related to your account.',
              icon: Icons.shield_outlined,
              children: [
                _buildNotificationTile(
                  context,
                  icon: Icons.login_rounded,
                  iconColor: colorScheme.primary,
                  title: 'Login Alerts',
                  subtitle:
                  'Notify me about new logins',
                  value: settings.loginAlerts,
                  onChanged: (value) {
                    setState(() {
                      settings.loginAlerts = value;
                    });
                  },
                ),
                _buildDivider(context),
                _buildNotificationTile(
                  context,
                  icon: Icons.security_rounded,
                  iconColor: Colors.orange,
                  title: 'Security Alerts',
                  subtitle:
                  'Receive important security notifications',
                  value: settings.securityAlerts,
                  onChanged: (value) {
                    setState(() {
                      settings.securityAlerts =
                          value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 22),

            _buildSection(
              context,
              title: 'Market',
              subtitle:
              'Get updates about cryptocurrency prices and markets.',
              icon: Icons.show_chart_rounded,
              children: [
                _buildNotificationTile(
                  context,
                  icon: Icons.notifications_active_outlined,
                  iconColor: colorScheme.primary,
                  title: 'Price Alerts',
                  subtitle:
                  'Receive cryptocurrency price alerts',
                  value: settings.priceAlerts,
                  onChanged: (value) {
                    setState(() {
                      settings.priceAlerts = value;
                    });
                  },
                ),
                _buildDivider(context),
                _buildNotificationTile(
                  context,
                  icon: Icons.trending_up_rounded,
                  iconColor: Colors.green,
                  title: 'Market Updates',
                  subtitle:
                  'Receive crypto market updates',
                  value: settings.marketUpdates,
                  onChanged: (value) {
                    setState(() {
                      settings.marketUpdates =
                          value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 22),

            _buildSection(
              context,
              title: 'Email',
              subtitle:
              'Control which important updates are delivered to your email.',
              icon: Icons.email_outlined,
              children: [
                _buildNotificationTile(
                  context,
                  icon: Icons.mark_email_unread_outlined,
                  iconColor: colorScheme.primary,
                  title: 'Email Notifications',
                  subtitle:
                  'Receive important notifications by email',
                  value:
                  settings.emailNotifications,
                  onChanged: (value) {
                    setState(() {
                      settings.emailNotifications =
                          value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 22),

            _buildInfoCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
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
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
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
              size: 27,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notification Preferences',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Customize the alerts you receive from ChainVault.',
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: 0.78,
                    ),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required List<Widget> children,
      }) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer
                    .withValues(alpha: 0.65),
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: colorScheme
                    .onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      color: colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 11),

        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius:
            BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outlineVariant
                  .withValues(alpha: 0.38),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationTile(
      BuildContext context, {
        required IconData icon,
        required Color iconColor,
        required String title,
        required String subtitle,
        required bool value,
        required ValueChanged<bool> onChanged,
      }) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 7,
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: iconColor.withValues(
                alpha: 0.10,
              ),
              borderRadius:
              BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.3,
                    color:
                    colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Switch.adaptive(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Divider(
      height: 1,
      indent: 68,
      endIndent: 13,
      color: colorScheme.outlineVariant
          .withValues(alpha: 0.35),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer
            .withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: colorScheme
                .onPrimaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Notification preferences are applied to your ChainVault account. Critical security notifications may still be delivered when necessary.',
              style: TextStyle(
                fontSize: 11,
                height: 1.45,
                color: colorScheme
                    .onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}