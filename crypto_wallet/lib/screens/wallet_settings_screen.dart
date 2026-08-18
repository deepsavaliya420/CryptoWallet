import 'package:flutter/material.dart';

import '../services/user_service.dart';

class WalletSettingsScreen extends StatefulWidget {
  const WalletSettingsScreen({super.key});

  @override
  State<WalletSettingsScreen> createState() =>
      _WalletSettingsScreenState();
}

class _WalletSettingsScreenState
    extends State<WalletSettingsScreen> {
  late final TextEditingController walletNameController;

  @override
  void initState() {
    super.initState();

    walletNameController = TextEditingController(
      text: UserService.settings.walletName,
    );
  }

  @override
  void dispose() {
    walletNameController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void saveSettings() {
    UserService.updateWalletSettings(
      walletName: walletNameController.text.trim().isEmpty
          ? 'My Main Wallet'
          : walletNameController.text.trim(),
      defaultNetwork: UserService.settings.defaultNetwork,
      displayCurrency: UserService.settings.displayCurrency,
    );

    showMessage('Wallet settings updated.');
  }

  void copyAddress() {
    showMessage('Wallet address copied.');
  }

  @override
  Widget build(BuildContext context) {
    final user = UserService.currentUser;
    final settings = UserService.settings;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('No user is currently logged in.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wallet Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Wallet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: walletNameController,
              decoration: const InputDecoration(
                labelText: 'Wallet Name',
                prefixIcon:
                Icon(Icons.account_balance_wallet_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Wallet Address',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      user.walletAddress,
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: copyAddress,
                      icon: const Icon(Icons.copy_outlined),
                      label: const Text('Copy Address'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Networks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Ethereum'),
                    subtitle: const Text('ERC-20'),
                    value: 'Ethereum',
                    groupValue:
                    settings.defaultNetwork,
                    onChanged: (value) {
                      setState(() {
                        settings.defaultNetwork =
                        value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('BNB Chain'),
                    subtitle: const Text('BEP-20'),
                    value: 'BNB Chain',
                    groupValue:
                    settings.defaultNetwork,
                    onChanged: (value) {
                      setState(() {
                        settings.defaultNetwork =
                        value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Solana'),
                    value: 'Solana',
                    groupValue:
                    settings.defaultNetwork,
                    onChanged: (value) {
                      setState(() {
                        settings.defaultNetwork =
                        value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('TRON'),
                    subtitle: const Text('TRC-20'),
                    value: 'TRON',
                    groupValue:
                    settings.defaultNetwork,
                    onChanged: (value) {
                      setState(() {
                        settings.defaultNetwork =
                        value!;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Display Currency',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: settings.displayCurrency,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.currency_exchange,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'USD',
                  child: Text('USD - US Dollar'),
                ),
                DropdownMenuItem(
                  value: 'EUR',
                  child: Text('EUR - Euro'),
                ),
                DropdownMenuItem(
                  value: 'INR',
                  child: Text('INR - Indian Rupee'),
                ),
                DropdownMenuItem(
                  value: 'GBP',
                  child: Text('GBP - British Pound'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  settings.displayCurrency = value!;
                });
              },
            ),

            const SizedBox(height: 28),

            FilledButton.icon(
              onPressed: saveSettings,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Settings'),
            ),

            const SizedBox(height: 24),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.warning_amber_outlined,
                ),
                title: const Text('Export Wallet'),
                subtitle: const Text(
                  'Wallet export will be available after secure '
                      'key management is implemented.',
                ),
                onTap: () {
                  showMessage(
                    'Secure wallet export is not available yet.',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}