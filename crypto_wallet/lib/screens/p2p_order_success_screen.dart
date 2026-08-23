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
      /*
       * STEP 1
       * Add purchased crypto to wallet.
       *
       * Example:
       * Existing USDT = 250
       * Purchased USDT = 500
       * New balance = 750 USDT
       */
      await WalletService.addP2PPurchasedCrypto(
        asset: widget.asset,
        amount: widget.amount,
      );

      /*
       * STEP 2
       * Create a RECEIVED transaction.
       *
       * This will appear in:
       * Home -> Recent Transactions
       */
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

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update wallet: $error',
          ),
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
        builder: (context) =>
        const HomeScreen(),
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
            'Payment Successful',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding:
            const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                CircleAvatar(
                  radius: 42,
                  backgroundColor:
                  Colors.green
                      .withValues(alpha: 0.15),
                  child: Icon(
                    Icons.check,
                    size: 48,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'P2P Payment Successful',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  isProcessing
                      ? 'Updating your wallet...'
                      : paymentCompleted
                      ? '${widget.amount.toStringAsFixed(2)} ${widget.asset} has been added to your wallet.'
                      : 'Wallet update failed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme
                        .onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 24),

                Expanded(
                  child: Card(
                    child: ListView(
                      padding:
                      const EdgeInsets.all(
                        20,
                      ),
                      children: [
                        _DetailRow(
                          title: 'Order ID',
                          value: orderId,
                        ),

                        _DetailRow(
                          title: 'Asset',
                          value:
                          widget.asset,
                        ),

                        _DetailRow(
                          title: 'Seller',
                          value: widget
                              .offer
                              .sellerName,
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
                          title:
                          'Payment Method',
                          value:
                          widget.paymentMethod,
                        ),

                        _DetailRow(
                          title:
                          'Total Payment',
                          value:
                          '₹${widget.totalPrice.toStringAsFixed(2)}',
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        if (paymentCompleted)
                          Container(
                            padding:
                            const EdgeInsets
                                .all(18),
                            decoration:
                            BoxDecoration(
                              color: Colors.green
                                  .withValues(
                                alpha: 0.12,
                              ),
                              borderRadius:
                              BorderRadius
                                  .circular(
                                14,
                              ),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons
                                      .account_balance_wallet,
                                  size: 40,
                                  color:
                                  Colors.green,
                                ),

                                const SizedBox(
                                  height: 10,
                                ),

                                const Text(
                                  'Crypto Added to Wallet',
                                  style:
                                  TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                  ),
                                ),

                                const SizedBox(
                                  height: 8,
                                ),

                                Text(
                                  '+${widget.amount.toStringAsFixed(2)} ${widget.asset}',
                                  style:
                                  const TextStyle(
                                    fontSize: 22,
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    color:
                                    Colors.green,
                                  ),
                                ),

                                const SizedBox(
                                  height: 8,
                                ),

                                const Text(
                                  'Transaction status: Completed',
                                ),

                                const SizedBox(
                                  height: 6,
                                ),

                                Text(
                                  '₹${widget.totalPrice.toStringAsFixed(2)} paid successfully',
                                ),
                              ],
                            ),
                          ),

                        if (isProcessing)
                          const Padding(
                            padding:
                            EdgeInsets.all(
                              20,
                            ),
                            child: Center(
                              child:
                              CircularProgressIndicator(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width:
                  double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed:
                    isProcessing
                        ? null
                        : goToHome,
                    icon: const Icon(
                      Icons.home,
                    ),
                    label: const Text(
                      'Back to Wallet',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String title;
  final String value;

  const _DetailRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Text(
              value,
              textAlign:
              TextAlign.end,
              style:
              const TextStyle(
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}