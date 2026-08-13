import 'package:flutter/material.dart';

import '../models/asset.dart';
import '../widgets/action_card.dart';
import '../widgets/asset_card.dart';
import '../widgets/section_title.dart';
import '../widgets/recent_transaction_card.dart';
import '../widgets/wallet_balance_card.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Asset> assets = const [
    Asset(
      symbol: 'ETH',
      name: 'Ethereum',
      network: 'ERC-20',
      amount: '0.82 ETH',
      value: '\$2,100.00',
      change: '+3.42%',
      isPositive: true,
    ),
    Asset(
      symbol: 'USDT',
      name: 'Tether',
      network: 'TRC-20',
      amount: '250 USDT',
      value: '\$250.00',
      change: '+0.02%',
      isPositive: true,
    ),
    Asset(
      symbol: 'SOL',
      name: 'Solana',
      network: 'Solana',
      amount: '1.50 SOL',
      value: '\$190.00',
      change: '+5.21%',
      isPositive: true,
    ),
    Asset(
      symbol: 'TRX',
      name: 'TRON',
      network: 'TRC-20',
      amount: '12 TRX',
      value: '\$1.20',
      change: '-1.10%',
      isPositive: false,
    ),
  ];

  void openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  }

  void showMessage(
      BuildContext context,
      String message,
      ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ChainVault',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              showMessage(
                context,
                'No new notifications',
              );
            },
            icon: const Icon(
              Icons.notifications_outlined,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Profile',
              onPressed: () {
                openProfile(context);
              },
              icon: const Icon(
                Icons.account_circle_outlined,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            16,
            10,
            16,
            24,
          ),
          children: [
            const Text(
              'Welcome back 👋',
              style: TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Your Wallet',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            const WalletBalanceCard(
              balance: '\$2,541.20',
              change: '+4.82% today',
            ),

            const SizedBox(height: 24),

            const SectionTitle(
              title: 'Quick Actions',
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: ActionCard(
                    icon: Icons.arrow_upward,
                    title: 'Send',
                    onTap: () {
                      showMessage(
                        context,
                        'Send feature coming soon',
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ActionCard(
                    icon: Icons.arrow_downward,
                    title: 'Receive',
                    onTap: () {
                      showMessage(
                        context,
                        'Receive feature coming soon',
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ActionCard(
                    icon: Icons.swap_horiz,
                    title: 'Swap',
                    onTap: () {
                      showMessage(
                        context,
                        'Swap feature coming soon',
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),

            SectionTitle(
              title: 'Your Assets',
              actionText: 'View All',
              onAction: () {
                showMessage(
                  context,
                  'Assets screen coming soon',
                );
              },
            ),

            const SizedBox(height: 10),

            ...assets.map(
                  (asset) => AssetCard(
                asset: asset,
              ),
            ),

            const SizedBox(height: 16),

            SectionTitle(
              title: 'Recent Transactions',
              actionText: 'View All',
              onAction: () {
                showMessage(
                  context,
                  'Transactions screen coming soon',
                );
              },
            ),

            const SizedBox(height: 10),

            const TransactionCard(
              type: 'Sent',
              asset: 'USDT',
              network: 'TRC-20',
              amount: '50 USDT',
              time: 'Today, 6:30 PM',
              isReceived: false,
            ),

            const TransactionCard(
              type: 'Received',
              asset: 'SOL',
              network: 'Solana',
              amount: '1.2 SOL',
              time: 'Today, 4:15 PM',
              isReceived: true,
            ),

            const TransactionCard(
              type: 'Sent',
              asset: 'ETH',
              network: 'ERC-20',
              amount: '0.15 ETH',
              time: 'Yesterday, 11:20 AM',
              isReceived: false,
            ),
          ],
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 3) {
            openProfile(context);
            return;
          }

          if (index == 1) {
            showMessage(
              context,
              'Assets screen coming soon',
            );
          }

          if (index == 2) {
            showMessage(
              context,
              'P2P marketplace coming soon',
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.account_balance_wallet_outlined,
            ),
            selectedIcon: Icon(
              Icons.account_balance_wallet,
            ),
            label: 'Assets',
          ),
          NavigationDestination(
            icon: Icon(Icons.handshake_outlined),
            selectedIcon: Icon(Icons.handshake),
            label: 'P2P',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}