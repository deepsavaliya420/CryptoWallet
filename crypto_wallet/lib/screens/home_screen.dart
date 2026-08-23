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
import 'swap_history_screen.dart';
import 'swap_screen.dart';

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

  double totalBalance = 0.0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(
      this,
    );

    _loadWalletData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(
      this,
    );

    super.dispose();
  }

  // ============================================================
  // APP RESUMED
  // ============================================================

  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state,
      ) {
    if (state == AppLifecycleState.resumed) {
      _loadWalletData();
    }
  }

  // ============================================================
  // LOAD WALLET
  // ============================================================

  Future<void> _loadWalletData() async {
    try {
      final List<Asset> walletAssets =
      await WalletService.getAssets();

      final double walletBalance =
      await WalletService.getTotalBalance();

      final List<WalletTransaction>
      walletTransactions =
      await TransactionService
          .getRecentTransactions(
        limit: 5,
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
  // SEND
  // ============================================================

  Future<void> _openSend() async {
    final bool? result =
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const SendReceiveScreen(
          mode: TransferMode.send,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    await _loadWalletData();

    if (!mounted) {
      return;
    }

    if (result == true) {
      _showMessage(
        'Send completed successfully.',
      );
    }
  }

  // ============================================================
  // RECEIVE
  // ============================================================

  Future<void> _openReceive() async {
    final bool? result =
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const SendReceiveScreen(
          mode: TransferMode.receive,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    await _loadWalletData();

    if (!mounted) {
      return;
    }

    if (result == true) {
      _showMessage(
        'Receive completed successfully.',
      );
    }
  }

  // ============================================================
  // SWAP
  //
  // IMPORTANT:
  // THIS IS THE FIX.
  //
  // There is NO "Swap feature coming soon" here.
  // It directly opens SwapScreen.
  // ============================================================

  Future<void> _openSwap() async {
    final bool? result =
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const SwapScreen(),
      ),
    );

    if (!mounted) {
      return;
    }

    // Refresh balance and recent transactions
    // after returning from SwapScreen.
    await _loadWalletData();

    if (!mounted) {
      return;
    }

    if (result == true) {
      _showMessage(
        'Swap completed successfully.',
      );
    }
  }

  // ============================================================
  // SWAP HISTORY
  // ============================================================

  Future<void> _openSwapHistory() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const SwapHistoryScreen(),
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
  // NOTIFICATIONS
  // ============================================================

  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const NotificationsScreen(),
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
      String message, {
        bool isError = false,
      }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
        backgroundColor:
        isError ? Colors.red : null,
        behavior:
        SnackBarBehavior.floating,
        duration:
        const Duration(
          seconds: 2,
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  String _cleanError(
      Object error,
      ) {
    return error
        .toString()
        .replaceFirst(
      'Exception: ',
      '',
    )
        .replaceFirst(
      'Bad state: ',
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
    final DateTime now =
    DateTime.now();

    final Duration difference =
    now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }

    if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    }

    if (difference.inDays < 1) {
      return 'Today, '
          '${_formatTime(timestamp)}';
    }

    if (difference.inDays == 1) {
      return 'Yesterday, '
          '${_formatTime(timestamp)}';
    }

    return '${timestamp.day}/'
        '${timestamp.month}/'
        '${timestamp.year}';
  }

  String _formatTime(
      DateTime dateTime,
      ) {
    final int hour =
    dateTime.hour % 12 == 0
        ? 12
        : dateTime.hour % 12;

    final String minute =
    dateTime.minute
        .toString()
        .padLeft(
      2,
      '0',
    );

    final String period =
    dateTime.hour >= 12
        ? 'PM'
        : 'AM';

    return '$hour:$minute $period';
  }

  // ============================================================
  // TRANSACTION CARD
  // ============================================================

  Widget _transactionCard(
      WalletTransaction transaction,
      ) {
    final String type =
    transaction.type.toLowerCase();

    final bool isReceive =
        type == 'received' ||
            type == 'receive';

    final bool isSwap =
        type == 'swap';

    final Color color;

    final IconData icon;

    if (isSwap) {
      color = Theme.of(context)
          .colorScheme
          .primary;

      icon = Icons.swap_horiz;
    } else if (isReceive) {
      color = Colors.green;

      icon = Icons.arrow_downward;
    } else {
      color = Colors.red;

      icon = Icons.arrow_upward;
    }

    String amountText;

    if (isSwap) {
      amountText =
      '${transaction.amount.toStringAsFixed(2)} '
          '${transaction.asset}';
    } else {
      amountText =
      '${isReceive ? '+' : '-'}'
          '${transaction.amount.toStringAsFixed(2)} '
          '${transaction.asset}';
    }

    return Card(
      margin:
      const EdgeInsets.only(
        bottom: 10,
      ),
      child: Padding(
        padding:
        const EdgeInsets.all(
          16,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
              color.withValues(
                alpha: 0.14,
              ),
              child: Icon(
                icon,
                color: color,
              ),
            ),

            const SizedBox(
              width: 14,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.type,
                    style:
                    const TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    '${transaction.asset} • '
                        '${transaction.network}',
                    style:
                    TextStyle(
                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    _formatTransactionTime(
                      transaction.timestamp,
                    ),
                    style:
                    TextStyle(
                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            Flexible(
              child: Text(
                amountText,
                textAlign:
                TextAlign.end,
                style:
                TextStyle(
                  fontWeight:
                  FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      // ========================================================
      // APP BAR
      // ========================================================

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
            onPressed:
            _openNotifications,
            icon: const Icon(
              Icons.notifications_outlined,
            ),
          ),

          Padding(
            padding:
            const EdgeInsets.only(
              right: 8,
            ),
            child: IconButton(
              tooltip:
              'Profile',
              onPressed:
              _openProfile,
              icon: const Icon(
                Icons.account_circle_outlined,
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
        child:
        RefreshIndicator(
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
              // TOTAL BALANCE
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
                  // ----------------------------------------------
                  // SEND
                  // ----------------------------------------------

                  Expanded(
                    child:
                    ActionCard(
                      icon:
                      Icons.arrow_upward,
                      title:
                      'Send',
                      onTap:
                      _openSend,
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  // ----------------------------------------------
                  // RECEIVE
                  // ----------------------------------------------

                  Expanded(
                    child:
                    ActionCard(
                      icon:
                      Icons.arrow_downward,
                      title:
                      'Receive',
                      onTap:
                      _openReceive,
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  // ----------------------------------------------
                  // SWAP
                  //
                  // THIS IS THE IMPORTANT PART.
                  //
                  // It calls _openSwap().
                  // It does NOT call a "coming soon" message.
                  // ----------------------------------------------

                  Expanded(
                    child:
                    ActionCard(
                      icon:
                      Icons.swap_horiz,
                      title:
                      'Swap',
                      onTap:
                      _openSwap,
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

              if (assets.isEmpty)
                const Padding(
                  padding:
                  EdgeInsets.all(
                    20,
                  ),
                  child:
                  Center(
                    child: Text(
                      'No assets yet',
                    ),
                  ),
                ),

              ...assets.map(
                    (
                    Asset asset,
                    ) {
                  return AssetCard(
                    asset: asset,
                  );
                },
              ),

              const SizedBox(
                height: 24,
              ),

              // ==================================================
              // RECENT TRANSACTIONS
              // ==================================================

              SectionTitle(
                title:
                'Recent Transactions',
                actionText:
                'View All',
                onAction:
                _openSwapHistory,
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
                    (
                    WalletTransaction
                    transaction,
                    ) {
                  return _transactionCard(
                    transaction,
                  );
                },
              ),

              const SizedBox(
                height: 12,
              ),

              // ==================================================
              // SWAP HISTORY BUTTON
              // ==================================================

              OutlinedButton.icon(
                onPressed:
                _openSwapHistory,
                icon: const Icon(
                  Icons.swap_horiz,
                ),
                label:
                const Text(
                  'Swap History',
                ),
              ),
            ],
          ),
        ),
      ),

      // ==========================================================
      // BOTTOM NAVIGATION
      // ==========================================================

      bottomNavigationBar:
      NavigationBar(
        selectedIndex: 0,
        onDestinationSelected:
            (int index) {
          switch (index) {
            case 0:
              break;

            case 1:
              _showMessage(
                'Assets screen coming soon',
              );
              break;

            case 2:
              _openP2P();
              break;

            case 3:
              _openProfile();
              break;
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