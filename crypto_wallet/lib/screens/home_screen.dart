import 'dart:async';

import 'package:flutter/material.dart';

import '../models/asset.dart';
import '../models/transaction.dart';
import '../services/notification_service.dart';
import '../services/transaction_service.dart';
import '../services/wallet_service.dart';
import '../widgets/action_card.dart';
import '../widgets/asset_card.dart';
import '../widgets/section_title.dart';
import '../widgets/wallet_balance_card.dart';

import 'asset_screen.dart';
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
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen>
    with WidgetsBindingObserver {
  List<Asset> assets = [];

  List<WalletTransaction> transactions = [];

  double totalBalance = 0.0;

  bool isLoading = true;

  bool hasUnreadNotifications = false;

  Timer? _notificationTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _loadWalletData();

    _startNotificationPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _notificationTimer?.cancel();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state,
      ) {
    if (state == AppLifecycleState.resumed) {
      _loadWalletData();
      _checkNotifications();
      _startNotificationPolling();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _notificationTimer?.cancel();
    }
  }

  // ============================================================
  // NOTIFICATION POLLING
  // ============================================================

  void _startNotificationPolling() {
    _notificationTimer?.cancel();

    _checkNotifications();

    _notificationTimer = Timer.periodic(
      const Duration(seconds: 5),
          (_) {
        if (mounted) {
          _checkNotifications();
        }
      },
    );
  }

  Future<void> _checkNotifications() async {
    try {
      await NotificationService.getNotifications();

      if (!mounted) {
        return;
      }

      final bool unread =
          NotificationService.unreadCount > 0;

      if (hasUnreadNotifications != unread) {
        setState(() {
          hasUnreadNotifications = unread;
        });
      }
    } catch (_) {
      // Do not disturb the wallet UI if notification
      // refreshing temporarily fails.
    }
  }

  // ============================================================
  // WALLET DATA
  // ============================================================

  Future<void> _loadWalletData() async {
    try {
      final List<Asset> walletAssets =
      await WalletService.getAssets();

      final double walletBalance =
      await WalletService.getTotalBalance();

      final List<WalletTransaction> walletTransactions =
      await TransactionService.getRecentTransactions(
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

  Future<void> _openAssets() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AssetsScreen(),
      ),
    );

    if (!mounted) {
      return;
    }

    await _loadWalletData();
  }

  Future<void> _openSend() async {
    final bool? result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const SendReceiveScreen(
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

  Future<void> _openReceive() async {
    final bool? result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const SendReceiveScreen(
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

  Future<void> _openSwap() async {
    final bool? result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const SwapScreen(),
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
        'Swap completed successfully.',
      );
    }
  }

  Future<void> _openSwapHistory() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SwapHistoryScreen(),
      ),
    );

    if (!mounted) {
      return;
    }

    await _loadWalletData();
  }

  Future<void> _openP2P() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const P2PScreen(),
      ),
    );

    if (!mounted) {
      return;
    }

    await _loadWalletData();
  }

  Future<void> _openProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );

    if (!mounted) {
      return;
    }

    await _loadWalletData();
  }

  // ============================================================
  // OPEN NOTIFICATIONS
  // ============================================================

  Future<void> _openNotifications() async {
    try {
      if (hasUnreadNotifications) {
        await NotificationService.markAllAsRead();
      }

      if (!mounted) {
        return;
      }

      setState(() {
        hasUnreadNotifications = false;
      });

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
          const NotificationsScreen(),
        ),
      );

      if (!mounted) {
        return;
      }

      await _checkNotifications();
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _cleanError(error),
        isError: true,
      );

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
          const NotificationsScreen(),
        ),
      );

      if (!mounted) {
        return;
      }

      await _checkNotifications();
    }
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor:
        isError ? Colors.red.shade700 : null,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('Bad state: ', '');
  }

  String _formatBalance(double balance) {
    return '\$${balance.toStringAsFixed(2)}';
  }

  String _formatTransactionTime(
      DateTime timestamp,
      ) {
    final DateTime now = DateTime.now();

    final Duration difference =
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

    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  String _formatTime(DateTime dateTime) {
    final int hour = dateTime.hour % 12 == 0
        ? 12
        : dateTime.hour % 12;

    final String minute = dateTime.minute
        .toString()
        .padLeft(2, '0');

    final String period =
    dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back 👋',
                style: TextStyle(
                  fontSize: 13,
                  color:
                  colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your Wallet',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.7,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),

        _notificationHeaderButton(context),

        const SizedBox(width: 9),

        _headerButton(
          context,
          icon: Icons.person_outline_rounded,
          onTap: _openProfile,
        ),
      ],
    );
  }

  Widget _notificationHeaderButton(
      BuildContext context,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Material(
      color:
      colorScheme.surfaceContainerHighest
          .withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: _openNotifications,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: 21,
                  color: colorScheme.onSurface,
                ),
              ),

              if (hasUnreadNotifications)
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                        colorScheme
                            .surfaceContainerHighest,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerButton(
      BuildContext context, {
        required IconData icon,
        required VoidCallback onTap,
      }) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Material(
      color:
      colorScheme.surfaceContainerHighest
          .withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            size: 21,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BALANCE
  // ============================================================

  Widget _buildBalanceSection(
      BuildContext context,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary
                .withValues(alpha: 0.84),
            colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary
                .withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          WalletBalanceCard(
            balance: _formatBalance(totalBalance),
            change: '+4.82% today',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _buildQuickActions(
      BuildContext context,
      ) {
    return Row(
      children: [
        Expanded(
          child: ActionCard(
            icon: Icons.arrow_upward_rounded,
            title: 'Send',
            onTap: _openSend,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ActionCard(
            icon: Icons.arrow_downward_rounded,
            title: 'Receive',
            onTap: _openReceive,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ActionCard(
            icon: Icons.swap_horiz_rounded,
            title: 'Swap',
            onTap: _openSwap,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ASSETS
  // ============================================================

  Widget _buildAssetsSection(
      BuildContext context,
      ) {
    return Column(
      children: [
        SectionTitle(
          title: 'Your Assets',
          actionText: 'View All',
          onAction: _openAssets,
        ),
        const SizedBox(height: 11),

        if (assets.isEmpty)
          _emptyCard(
            context,
            icon:
            Icons.account_balance_wallet_outlined,
            title: 'No assets yet',
            message:
            'Your wallet assets will appear here.',
          ),

        ...assets.take(4).map(
              (Asset asset) {
            return Padding(
              padding:
              const EdgeInsets.only(bottom: 10),
              child: AssetCard(
                asset: asset,
              ),
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // TRANSACTIONS
  // ============================================================

  Widget _buildTransactionsSection(
      BuildContext context,
      ) {
    return Column(
      children: [
        SectionTitle(
          title: 'Recent Transactions',
          actionText: 'View All',
          onAction: _openSwapHistory,
        ),
        const SizedBox(height: 11),

        if (transactions.isEmpty)
          _emptyCard(
            context,
            icon: Icons.receipt_long_outlined,
            title: 'No transactions yet',
            message:
            'Your latest wallet activity will appear here.',
          ),

        ...transactions.map(
              (WalletTransaction transaction) {
            return _transactionCard(transaction);
          },
        ),

        if (transactions.isNotEmpty)
          Padding(
            padding:
            const EdgeInsets.only(top: 3),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openSwapHistory,
                icon: const Icon(
                  Icons.history_rounded,
                  size: 19,
                ),
                label: const Text(
                  'View Transaction History',
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // EMPTY CARD
  // ============================================================

  Widget _emptyCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String message,
      }) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(
        vertical: 25,
        horizontal: 18,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant
              .withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 34,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 9),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
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

    final bool isDeposit =
        type == 'deposit';

    final bool isWithdrawal =
        type == 'withdrawal' ||
            type == 'withdraw';

    final bool isSwap =
        type == 'swap';

    final Color color;
    final IconData icon;

    if (isSwap) {
      color =
          Theme.of(context).colorScheme.primary;
      icon = Icons.swap_horiz_rounded;
    } else if (isReceive || isDeposit) {
      color = Colors.green;
      icon = isDeposit
          ? Icons.account_balance_wallet_outlined
          : Icons.arrow_downward_rounded;
    } else {
      color = Colors.red;
      icon = isWithdrawal
          ? Icons.account_balance_outlined
          : Icons.arrow_upward_rounded;
    }

    String amountText;

    if (isSwap) {
      amountText =
      '${transaction.amount.toStringAsFixed(2)} '
          '${transaction.asset}';
    } else if (isDeposit) {
      amountText =
      '+${transaction.amount.toStringAsFixed(2)} '
          '${transaction.asset}';
    } else if (isWithdrawal) {
      amountText =
      '-${transaction.amount.toStringAsFixed(2)} '
          '${transaction.asset}';
    } else {
      amountText =
      '${isReceive ? '+' : '-'}'
          '${transaction.amount.toStringAsFixed(2)} '
          '${transaction.asset}';
    }

    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: colorScheme.outlineVariant
              .withValues(alpha: 0.38),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.type,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.asset} • '
                      '${transaction.network}',
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color:
                    colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatTransactionTime(
                    transaction.timestamp,
                  ),
                  style: TextStyle(
                    fontSize: 10.5,
                    color:
                    colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Flexible(
            child: Text(
              amountText,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow:
              TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Scaffold(
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
        ),
      )
          : SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadWalletData,
          child: ListView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding:
            const EdgeInsets.fromLTRB(
              18,
              12,
              18,
              28,
            ),
            children: [
              _buildHeader(context),

              const SizedBox(height: 24),

              _buildBalanceSection(context),

              const SizedBox(height: 28),

              SectionTitle(
                title: 'Quick Actions',
              ),

              const SizedBox(height: 12),

              _buildQuickActions(context),

              const SizedBox(height: 30),

              _buildAssetsSection(context),

              const SizedBox(height: 28),

              _buildTransactionsSection(
                context,
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (
            int index,
            ) {
          switch (index) {
            case 0:
              break;

            case 1:
              _openAssets();
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
              Icons.home_rounded,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.account_balance_wallet_outlined,
            ),
            selectedIcon: Icon(
              Icons.account_balance_wallet_rounded,
            ),
            label: 'Assets',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.handshake_outlined,
            ),
            selectedIcon: Icon(
              Icons.handshake_rounded,
            ),
            label: 'P2P',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outline_rounded,
            ),
            selectedIcon: Icon(
              Icons.person_rounded,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}