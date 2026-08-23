import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'login_screen.dart';
import 'personal_information_screen.dart';
import 'security_screen.dart';
import 'wallet_settings_screen.dart';
import 'notification_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  Future<void> logout() async {
    await AuthService.logout();

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

  void showLogoutDialog() {
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
              onPressed: () async {
                Navigator.pop(dialogContext);
                await logout();
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
    final colorScheme =
        Theme.of(context).colorScheme;

    final user = UserService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No user is currently logged in.',
          ),
        ),
      );
    }

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
              backgroundColor:
              colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                size: 52,
                color:
                colorScheme.onPrimaryContainer,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              user.fullName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              user.email,
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                  colorScheme.primaryContainer,
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                child: Text(
                  'ID: ${user.userId}',
                  style: TextStyle(
                    color: colorScheme
                        .onPrimaryContainer,
                    fontSize: 12,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Card(
              child: Column(
                children: [
                  _ProfileOption(
                    icon: Icons.person_outline,
                    title:
                    'Personal Information',
                    subtitle:
                    'Name, email, location and phone',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const PersonalInformationScreen(),
                        ),
                      );

                      if (mounted) {
                        setState(() {});
                      }
                    },
                  ),

                  const Divider(height: 1),

                  _ProfileOption(
                    icon:
                    Icons.security_outlined,
                    title: 'Security',
                    subtitle:
                    'Password, biometrics and protection',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const SecurityScreen(),
                        ),
                      );
                    },
                  ),

                  const Divider(height: 1),

                  _ProfileOption(
                    icon: Icons
                        .account_balance_wallet_outlined,
                    title: 'Wallet Settings',
                    subtitle:
                    'Wallet, networks and currency',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const WalletSettingsScreen(),
                        ),
                      );

                      if (mounted) {
                        setState(() {});
                      }
                    },
                  ),

                  const Divider(height: 1),

                  _ProfileOption(
                    icon: Icons
                        .notifications_outlined,
                    title: 'Notifications',
                    subtitle:
                    'Manage notification preferences',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const NotificationSettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                  colorScheme.errorContainer,
                  child: Icon(
                    Icons.logout,
                    color:
                    colorScheme.onErrorContainer,
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
                onTap: showLogoutDialog,
              ),
            ),

            const SizedBox(height: 25),

            Center(
              child: Text(
                'ChainVault v1.0.0',
                style: TextStyle(
                  color:
                  colorScheme.onSurfaceVariant,
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

class _ProfileOption
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return ListTile(
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 7,
      ),
      leading: CircleAvatar(
        backgroundColor:
        colorScheme.primaryContainer,
        child: Icon(
          icon,
          color:
          colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(subtitle),
      trailing:
      const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}