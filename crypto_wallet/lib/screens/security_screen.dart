import 'package:flutter/material.dart';

import '../services/user_service.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void showChangePasswordDialog() {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (passwordController.text.length < 8) {
                  showMessage(
                    'Password must contain at least 8 characters.',
                  );
                  return;
                }

                if (passwordController.text !=
                    confirmController.text) {
                  showMessage('Passwords do not match.');
                  return;
                }

                Navigator.pop(dialogContext);

                showMessage(
                  'Password change will be connected to authentication.',
                );
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = UserService.settings;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Security',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Account Security',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Manage how your ChainVault account is protected.',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('Change Password'),
                    subtitle: const Text(
                      'Update your account password',
                    ),
                    trailing:
                    const Icon(Icons.chevron_right),
                    onTap: showChangePasswordDialog,
                  ),

                  const Divider(height: 1),

                  SwitchListTile(
                    secondary: const Icon(
                      Icons.fingerprint,
                    ),
                    title: const Text('Biometric Login'),
                    subtitle: const Text(
                      'Use fingerprint or Face ID',
                    ),
                    value: settings.biometricLogin,
                    onChanged: (value) {
                      setState(() {
                        settings.biometricLogin = value;
                      });
                    },
                  ),

                  const Divider(height: 1),

                  SwitchListTile(
                    secondary: const Icon(
                      Icons.verified_user_outlined,
                    ),
                    title: const Text(
                      'Two-Factor Authentication',
                    ),
                    subtitle: const Text(
                      'Add an additional security layer',
                    ),
                    value:
                    settings.twoFactorAuthentication,
                    onChanged: (value) {
                      setState(() {
                        settings.twoFactorAuthentication =
                            value;
                      });

                      showMessage(
                        value
                            ? 'Two-factor authentication enabled.'
                            : 'Two-factor authentication disabled.',
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Card(
              color: colorScheme.errorContainer
                  .withValues(alpha: 0.35),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_outlined),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Never share your password, recovery phrase, '
                            'or private key with anyone. ChainVault will '
                            'never ask you to send these details.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}