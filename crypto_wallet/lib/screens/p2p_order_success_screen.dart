import 'package:flutter/material.dart';

import '../models/p2p_offer.dart';
import '../services/transaction_service.dart';
import '../services/wallet_service.dart';
import 'home_screen.dart';

class P2POrderSuccessScreen extends StatefulWidget {
  final P2POffer offer;
  final String asset;
  final String currency;
  final double amount;
  final double totalPrice;
  final String paymentMethod;

  const P2POrderSuccessScreen({
    required this.offer,
    required this.asset,
    required this.currency,
    required this.amount,
    required this.totalPrice,
    required this.paymentMethod,
    super.key,
  });

  @override
  State<P2POrderSuccessScreen> createState() =>
      _P2POrderSuccessScreenState();
}

class _P2POrderSuccessScreenState
    extends State<P2POrderSuccessScreen> {
  late final String orderId;

  bool isProcessing = true;
  bool paymentCompleted = false;

  @override
  void initState() {
    super.initState();

    orderId =
    'CV-P2P-${DateTime.now().millisecondsSinceEpoch}';

    _completeP2PPayment();
  }

  Future<void> _completeP2PPayment() async {
    try {
      await WalletService.addP2PPurchasedCrypto(
        asset: widget.asset,
        amount: widget.amount,
      );

      await TransactionService
          .createP2PReceivedTransaction(
        asset: widget.asset,
        network: _networkForAsset(
          widget.asset,
        ),
        amount: widget.amount,
        value: widget.totalPrice,
        seller: widget.offer.sellerName,
        buyerWallet: 'My Wallet',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        paymentCompleted = true;
        isProcessing = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isProcessing = false;
        paymentCompleted = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update wallet: $error',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _networkForAsset(String asset) {
    switch (asset.toUpperCase()) {
      case 'USDT':
        return 'TRC-20';
      case 'ETH':
        return 'ERC-20';
      case 'SOL':
        return 'Solana';
      case 'TRX':
        return 'TRC-20';
      default:
        return 'Unknown';
    }
  }

  void goToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Order Status',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              18,
              10,
              18,
              30,
            ),
            children: [
              _buildStatusHeader(context),

              const SizedBox(height: 22),

              _buildOrderCard(context),

              const SizedBox(height: 16),

              if (paymentCompleted)
                _buildWalletAddedCard(context),

              if (isProcessing)
                _buildProcessingCard(context),

              if (!paymentCompleted &&
                  !isProcessing)
                _buildFailureCard(context),

              const SizedBox(height: 20),

              _buildBackButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final bool success = paymentCompleted;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        25,
        20,
        23,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: success
              ? [
            Colors.green.shade700,
            Colors.green.shade500,
          ]
              : [
            colorScheme.primary,
            colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: (success
                ? Colors.green
                : colorScheme.primary)
                .withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.16,
              ),
              shape: BoxShape.circle,
            ),
            child: isProcessing
                ? const Padding(
              padding: EdgeInsets.all(21),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.white,
              ),
            )
                : Icon(
              success
                  ? Icons.check_rounded
                  : Icons.error_outline_rounded,
              color: Colors.white,
              size: 43,
            ),
          ),

          const SizedBox(height: 17),

          Text(
            isProcessing
                ? 'Processing Payment'
                : success
                ? 'P2P Payment Successful'
                : 'Payment Update Failed',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            isProcessing
                ? 'Please wait while your wallet is being updated.'
                : success
                ? '${widget.amount.toStringAsFixed(2)} ${widget.asset} has been added to your wallet.'
                : 'We could not complete the wallet update.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(
                alpha: 0.82,
              ),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.outlineVariant
              .withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow
                .withValues(alpha: 0.035),
            blurRadius: 17,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme
                      .primaryContainer,
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 21,
                  color: colorScheme
                      .onPrimaryContainer,
                ),
              ),

              const SizedBox(width: 11),

              const Expanded(
                child: Text(
                  'Order Details',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: paymentCompleted
                      ? Colors.green
                      .withValues(alpha: 0.10)
                      : colorScheme
                      .surfaceContainerHighest,
                  borderRadius:
                  BorderRadius.circular(9),
                ),
                child: Text(
                  isProcessing
                      ? 'PROCESSING'
                      : paymentCompleted
                      ? 'COMPLETED'
                      : 'FAILED',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: paymentCompleted
                        ? Colors.green.shade700
                        : colorScheme
                        .onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _DetailRow(
            title: 'Order ID',
            value: orderId,
            mono: true,
          ),

          _DetailRow(
            title: 'Asset',
            value: widget.asset,
          ),

          _DetailRow(
            title: 'Network',
            value: _networkForAsset(
              widget.asset,
            ),
          ),

          _DetailRow(
            title: 'Seller',
            value: widget.offer.sellerName,
          ),

          _DetailRow(
            title: 'Price',
            value:
            '₹${widget.offer.price.toStringAsFixed(2)} / ${widget.asset}',
          ),

          _DetailRow(
            title: 'Amount',
            value:
            '${widget.amount.toStringAsFixed(2)} ${widget.asset}',
          ),

          _DetailRow(
            title: 'Payment Method',
            value: widget.paymentMethod,
          ),

          const SizedBox(height: 9),

          Divider(
            color: colorScheme.outlineVariant
                .withValues(alpha: 0.5),
          ),

          const SizedBox(height: 9),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total Payment',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '₹${widget.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletAddedCard(
      BuildContext context,
      ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: Colors.green.withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.green.withValues(
                alpha: 0.13,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.green,
              size: 29,
            ),
          ),

          const SizedBox(height: 13),

          const Text(
            'Crypto Added to Wallet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            '+${widget.amount.toStringAsFixed(2)} ${widget.asset}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.green,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Transaction status: Completed',
            style: TextStyle(
              color: Colors.green.shade700,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            '₹${widget.totalPrice.toStringAsFixed(2)} paid successfully',
            style: TextStyle(
              color: Colors.green.shade700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingCard(
      BuildContext context,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme
            .surfaceContainerLow,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: colorScheme.primary,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Text(
              'Updating wallet and recording transaction...',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailureCard(
      BuildContext context,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer
            .withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              'The wallet could not be updated. Please check your wallet balance and transaction history.',
              style: TextStyle(
                color: colorScheme
                    .onErrorContainer,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed:
        isProcessing ? null : goToHome,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(17),
          ),
        ),
        icon: const Icon(
          Icons.home_rounded,
        ),
        label: Text(
          isProcessing
              ? 'Please Wait...'
              : 'Back to Wallet',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String title;
  final String value;
  final bool mono;

  const _DetailRow({
    required this.title,
    required this.value,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme
                    .onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(width: 14),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                fontFamily:
                mono ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}