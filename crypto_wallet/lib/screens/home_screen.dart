import 'package:flutter/material.dart';

import '../models/asset.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';
import '../services/wallet_service.dart';
import '../widgets/action_card.dart';
import '../widgets/asset_card.dart';
import '../widgets/section_title.dart';
import '../widgets/wallet_balance_card.dart';
import 'notifications_screen.dart';
import 'p2p_screen.dart';
import 'profile_screen.dart';
import 'send_receive_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen>
    with WidgetsBindingObserver {
  List<Asset> assets = [];

  List<WalletTransaction> transactions = [];

  double totalBalance = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _loadWalletData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state,
      ) {
    if (state == AppLifecycleState.resumed) {
      _loadWalletData();
    }
  }

  // ============================================================
  // LOAD HOME DATA
  // ============================================================

  Future<void> _loadWalletData() async {
    try {
      final walletAssets =
      await WalletService.getAssets();

      final walletBalance =
      await WalletService.getTotalBalance();

      final walletTransactions =
      await TransactionService.getRecentTransactions(
        limit: 3,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        assets = walletAssets;
        totalBalance = walletBalance;
        transactions = walletTransactions;
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

  // ============================================================
  // SEND / RECEIVE
  // ============================================================

  Future<void> _openSendReceive(
      TransferMode mode,
      ) async {
    final result =
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SendReceiveScreen(
              mode: mode,
            ),
      ),
    );

    if (!mounted) {
      return;
    }

    /*
     * Always refresh when returning from Send/Receive.
     *
     * This is important because:
     *
     * Send    -> balance decreases
     * Receive -> balance increases
     * Both    -> transaction list changes
     */

    await _loadWalletData();

    if (!mounted) {
      return;
    }

    if (result == true) {
      _showMessage(
        mode == TransferMode.send
            ? 'USDT sent successfully.'
            : 'USDT received successfully.',
      );
    }
  }

  // ============================================================
  // PROFILE
  // ============================================================

  Future<void> _openProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const ProfileScreen(),
      ),
    );

    if (!mounted) {
      return;
    }

    await _loadWalletData();
  }

  // ============================================================
  // P2P
  // ============================================================

  Future<void> _openP2P() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const P2PScreen(),
      ),
    );

    if (!mounted) {
      return;
    }

    await _loadWalletData();
  }

  // ============================================================
  // RECEIVE REQUESTS
  // ============================================================

  Future<void> _openReceiveRequests() async {
    /*
     * We import this screen dynamically through the local
     * navigation function below.
     */

    await Navigator.pushNamed(
      context,
      '/receive-requests',
    );

    if (!mounted) {
      return;
    }

    await _loadWalletData();
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
      String message, {
        bool isError = false,
      }) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
        isError ? Colors.red : null,
        behavior:
        SnackBarBehavior.floating,
        duration:
        const Duration(seconds: 2),
      ),
    );
  }

  String _cleanError(
      Object error,
      ) {
    return error
        .toString()
        .replaceFirst(
      'Bad state: ',
      '',
    )
        .replaceFirst(
      'Exception: ',
      '',
    );
  }

  // ============================================================
  // BALANCE
  // ============================================================

  String _formatBalance(
      double balance,
      ) {
    return '\$${balance.toStringAsFixed(2)}';
  }

  // ============================================================
  // TRANSACTION TIME
  // ============================================================

  String _formatTransactionTime(
      DateTime timestamp,
      ) {
    final now = DateTime.now();

    final difference =
    now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }

    if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    }

    if (difference.inDays < 1) {
      return 'Today, ${_formatTime(timestamp)}';
    }

    if (difference.inDays == 1) {
      return 'Yesterday, ${_formatTime(timestamp)}';
    }

    return '${timestamp.day}/'
        '${timestamp.month}/'
        '${timestamp.year}';
  }

  String _formatTime(
      DateTime dateTime,
      ) {
    final hour =
    dateTime.hour % 12 == 0
        ? 12
        : dateTime.hour % 12;

    final minute =
    dateTime.minute
        .toString()
        .padLeft(2, '0');

    final period =
    dateTime.hour >= 12
        ? 'PM'
        : 'AM';

    return '$hour:$minute $period';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ChainVault',
          style: TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip:
            'Notifications',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                  const NotificationsScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications_outlined,
            ),
          ),

          Padding(
            padding:
            const EdgeInsets.only(
              right: 12,
            ),
            child: IconButton(
              tooltip: 'Profile',
              onPressed:
              _openProfile,
              icon: const Icon(
                Icons
                    .account_circle_outlined,
              ),
            ),
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: isLoading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : SafeArea(
        child: RefreshIndicator(
          onRefresh:
          _loadWalletData,
          child: ListView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding:
            const EdgeInsets.fromLTRB(
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

              const SizedBox(
                height: 4,
              ),

              Text(
                'Your Wallet',
                style:
                Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              // ==================================================
              // BALANCE
              // ==================================================

              WalletBalanceCard(
                balance:
                _formatBalance(
                  totalBalance,
                ),
                change:
                '+4.82% today',
              ),

              const SizedBox(
                height: 24,
              ),

              // ==================================================
              // QUICK ACTIONS
              // ==================================================

              const SectionTitle(
                title:
                'Quick Actions',
              ),

              const SizedBox(
                height: 10,
              ),

              Row(
                children: [
                  // ==============================================
                  // SEND
                  // ==============================================

                  Expanded(
                    child:
                    ActionCard(
                      icon: Icons
                          .arrow_upward,
                      title: 'Send',
                      onTap: () {
                        _openSendReceive(
                          TransferMode
                              .send,
                        );
                      },
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  // ==============================================
                  // RECEIVE
                  // ==============================================

                  Expanded(
                    child:
                    ActionCard(
                      icon: Icons
                          .arrow_downward,
                      title:
                      'Receive',
                      onTap: () {
                        _openSendReceive(
                          TransferMode
                              .receive,
                        );
                      },
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  // ==============================================
                  // SWAP
                  // ==============================================

                  Expanded(
                    child:
                    ActionCard(
                      icon: Icons
                          .swap_horiz,
                      title: 'Swap',
                      onTap: () {
                        _showMessage(
                          'Swap feature coming soon',
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 26,
              ),

              // ==================================================
              // ASSETS
              // ==================================================

              SectionTitle(
                title:
                'Your Assets',
                actionText:
                'View All',
                onAction: () {
                  _showMessage(
                    'Assets screen coming soon',
                  );
                },
              ),

              const SizedBox(
                height: 10,
              ),

              ...assets.map(
                    (asset) =>
                    AssetCard(
                      asset: asset,
                    ),
              ),

              const SizedBox(
                height: 16,
              ),

              // ==================================================
              // RECENT TRANSACTIONS
              // ==================================================

              SectionTitle(
                title:
                'Recent Transactions',
                actionText:
                'View All',
                onAction: () {
                  _showMessage(
                    'Transactions screen coming soon',
                  );
                },
              ),

              const SizedBox(
                height: 10,
              ),

              if (transactions.isEmpty)
                const Padding(
                  padding:
                  EdgeInsets.all(
                    20,
                  ),
                  child:
                  Center(
                    child: Text(
                      'No transactions yet',
                    ),
                  ),
                ),

              ...transactions.map(
                    (transaction) =>
                    _TransactionCard(
                      transaction:
                      transaction,
                      time:
                      _formatTransactionTime(
                        transaction
                            .timestamp,
                      ),
                    ),
              ),

              const SizedBox(
                height: 12,
              ),

              // ==================================================
              // RECEIVE REQUESTS
              // ==================================================

              OutlinedButton.icon(
                onPressed:
                _openReceiveRequests,
                icon: const Icon(
                  Icons
                      .request_quote_outlined,
                ),
                label: const Text(
                  'Receive Requests',
                ),
              ),
            ],
          ),
        ),
      ),

      // ==========================================================
      // NAVIGATION
      // ==========================================================

      bottomNavigationBar:
      NavigationBar(
        selectedIndex: 0,
        onDestinationSelected:
            (index) {
          if (index == 1) {
            _showMessage(
              'Assets screen coming soon',
            );
          }

          if (index == 2) {
            _openP2P();
          }

          if (index == 3) {
            _openProfile();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons
                  .account_balance_wallet_outlined,
            ),
            selectedIcon: Icon(
              Icons
                  .account_balance_wallet,
            ),
            label: 'Assets',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.handshake_outlined,
            ),
            selectedIcon: Icon(
              Icons.handshake,
            ),
            label: 'P2P',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
            ),
            selectedIcon: Icon(
              Icons.person,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// TRANSACTION CARD
// ==================================================================

class _TransactionCard
    extends StatelessWidget {
  final WalletTransaction transaction;
  final String time;

  const _TransactionCard({
    required this.transaction,
    required this.time,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    final bool received =
        transaction.type
            .toLowerCase() ==
            'received';

    final colorScheme =
        Theme.of(context)
            .colorScheme;

    return Card(
      margin:
      const EdgeInsets.only(
        bottom: 10,
      ),
      child: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
              received
                  ? Colors.green
                  .withValues(
                alpha: 0.15,
              )
                  : Colors.red
                  .withValues(
                alpha: 0.15,
              ),
              child: Icon(
                received
                    ? Icons
                    .arrow_downward
                    : Icons
                    .arrow_upward,
                color: received
                    ? Colors.green
                    : Colors.red,
              ),
            ),

            const SizedBox(
              width: 14,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Text(
                    transaction.type,
                    style:
                    const TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    '${transaction.asset} • '
                        '${transaction.network}',
                    style: TextStyle(
                      color:
                      colorScheme
                          .onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    time,
                    style: TextStyle(
                      color:
                      colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Text(
              '${received ? '+' : '-'}'
                  '${transaction.amount.toStringAsFixed(2)} '
                  '${transaction.asset}',
              style: TextStyle(
                fontWeight:
                FontWeight.bold,
                color: received
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}