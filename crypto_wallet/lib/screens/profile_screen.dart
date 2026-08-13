import 'package:flutter/material.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

  void showMessage(
      BuildContext context,
      String message,
      ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout from ChainVault?',
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
                Navigator.pop(dialogContext);
                logout(context);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 10),

            CircleAvatar(
              radius: 48,
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                size: 52,
                color: colorScheme.onPrimaryContainer,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'ChainVault User',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'user@chainvault.com',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 30),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                      colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person_outline,
                        color:
                        colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: const Text('Personal Information'),
                    subtitle: const Text(
                      'Name, email and location',
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                    ),
                    onTap: () {
                      showMessage(
                        context,
                        'Personal information coming soon',
                      );
                    },
                  ),

                  const Divider(
                    height: 1,
                  ),

                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                      colorScheme.primaryContainer,
                      child: Icon(
                        Icons.security_outlined,
                        color:
                        colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: const Text('Security'),
                    subtitle: const Text(
                      'Password, biometrics and wallet security',
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                    ),
                    onTap: () {
                      showMessage(
                        context,
                        'Security settings coming soon',
                      );
                    },
                  ),

                  const Divider(
                    height: 1,
                  ),

                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                      colorScheme.primaryContainer,
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        color:
                        colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: const Text('Wallet Settings'),
                    subtitle: const Text(
                      'Manage your wallet and networks',
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                    ),
                    onTap: () {
                      showMessage(
                        context,
                        'Wallet settings coming soon',
                      );
                    },
                  ),

                  const Divider(
                    height: 1,
                  ),

                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                      colorScheme.primaryContainer,
                      child: Icon(
                        Icons.notifications_outlined,
                        color:
                        colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: const Text('Notifications'),
                    subtitle: const Text(
                      'Manage notification preferences',
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                    ),
                    onTap: () {
                      showMessage(
                        context,
                        'Notification settings coming soon',
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(
                    Icons.logout,
                  ),
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Sign out of your ChainVault account',
                ),
                onTap: () {
                  showLogoutDialog(context);
                },
              ),
            ),

            const SizedBox(height: 25),

            Center(
              child: Text(
                'ChainVault v1.0.0',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}