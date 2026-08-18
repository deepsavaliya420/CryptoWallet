import 'package:flutter/material.dart';

import '../services/user_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = UserService.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Transaction Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Transaction Received',
                    ),
                    subtitle: const Text(
                      'Notify me when crypto is received',
                    ),
                    value: settings.transactionReceived,
                    onChanged: (value) {
                      setState(() {
                        settings.transactionReceived =
                            value;
                      });
                    },
                  ),

                  const Divider(height: 1),

                  SwitchListTile(
                    title: const Text(
                      'Transaction Sent',
                    ),
                    subtitle: const Text(
                      'Notify me when crypto is sent',
                    ),
                    value: settings.transactionSent,
                    onChanged: (value) {
                      setState(() {
                        settings.transactionSent =
                            value;
                      });
                    },
                  ),

                  const Divider(height: 1),

                  SwitchListTile(
                    title: const Text(
                      'Transaction Failed',
                    ),
                    subtitle: const Text(
                      'Notify me when a transaction fails',
                    ),
                    value: settings.transactionFailed,
                    onChanged: (value) {
                      setState(() {
                        settings.transactionFailed =
                            value;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Security',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Login Alerts'),
                    subtitle: const Text(
                      'Notify me about new logins',
                    ),
                    value: settings.loginAlerts,
                    onChanged: (value) {
                      setState(() {
                        settings.loginAlerts = value;
                      });
                    },
                  ),

                  const Divider(height: 1),

                  SwitchListTile(
                    title: const Text('Security Alerts'),
                    subtitle: const Text(
                      'Receive important security notifications',
                    ),
                    value: settings.securityAlerts,
                    onChanged: (value) {
                      setState(() {
                        settings.securityAlerts = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Market',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Price Alerts'),
                    subtitle: const Text(
                      'Receive cryptocurrency price alerts',
                    ),
                    value: settings.priceAlerts,
                    onChanged: (value) {
                      setState(() {
                        settings.priceAlerts = value;
                      });
                    },
                  ),

                  const Divider(height: 1),

                  SwitchListTile(
                    title: const Text('Market Updates'),
                    subtitle: const Text(
                      'Receive crypto market updates',
                    ),
                    value: settings.marketUpdates,
                    onChanged: (value) {
                      setState(() {
                        settings.marketUpdates = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Email',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: SwitchListTile(
                title: const Text('Email Notifications'),
                subtitle: const Text(
                  'Receive important notifications by email',
                ),
                value: settings.emailNotifications,
                onChanged: (value) {
                  setState(() {
                    settings.emailNotifications = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}