import 'package:flutter/material.dart';

import '../models/asset.dart';
import '../services/wallet_service.dart';

class AssetsScreen extends StatefulWidget {
  const AssetsScreen({
    super.key,
  });

  @override
  State<AssetsScreen> createState() =>
      _AssetsScreenState();
}

class _AssetsScreenState
    extends State<AssetsScreen> {
  List<Asset> _assets = [];

  double _totalBalance = 0.0;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadAssets();
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> _loadAssets() async {
    try {
      final List<Asset> assets =
      await WalletService.getAssets();

      final double total =
      await WalletService.getTotalBalance();

      if (!mounted) {
        return;
      }

      setState(() {
        _assets = assets;
        _totalBalance = total;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            _cleanError(error),
          ),
          backgroundColor:
          Colors.red,
        ),
      );
    }
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
      'Bad state: ',
      '',
    )
        .replaceFirst(
      'Exception: ',
      '',
    );
  }

  // ============================================================
  // ICON
  // ============================================================

  IconData _iconFor(
      String symbol,
      ) {
    switch (symbol.toUpperCase()) {
      case 'USD':
      case 'INR':
      case 'EUR':
      case 'GBP':
      case 'AED':
      case 'JPY':
        return Icons.payments_outlined;

      case 'BTC':
        return Icons.currency_bitcoin;

      case 'ETH':
        return Icons.diamond_outlined;

      case 'USDT':
      case 'USDC':
        return Icons.token_outlined;

      case 'SOL':
        return Icons.bolt_outlined;

      case 'TRX':
        return Icons.flash_on_outlined;

      default:
        return Icons
            .account_balance_wallet_outlined;
    }
  }

  // ============================================================
  // ICON COLOR
  // ============================================================

  Color _colorFor(
      String symbol,
      ) {
    switch (symbol.toUpperCase()) {
      case 'USD':
        return Colors.green;

      case 'INR':
        return Colors.orange;

      case 'EUR':
        return Colors.blue;

      case 'GBP':
        return Colors.indigo;

      case 'AED':
        return Colors.teal;

      case 'JPY':
        return Colors.red;

      case 'BTC':
        return Colors.orange;

      case 'ETH':
        return Colors.deepPurple;

      case 'USDT':
        return Colors.green;

      case 'USDC':
        return Colors.blue;

      case 'SOL':
        return Colors.purple;

      case 'TRX':
        return Colors.red;

      default:
        return Theme.of(context)
            .colorScheme
            .primary;
    }
  }

  // ============================================================
  // ASSET CARD
  // ============================================================

  Widget _assetCard(
      Asset asset,
      ) {
    final Color color =
    _colorFor(asset.symbol);

    return Card(
      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration:
              BoxDecoration(
                color:
                color.withValues(
                  alpha: 0.12,
                ),
                borderRadius:
                BorderRadius.circular(
                  16,
                ),
              ),
              child: Icon(
                _iconFor(
                  asset.symbol,
                ),
                color: color,
                size: 26,
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
                    asset.name,
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
                    asset.symbol,
                    style: TextStyle(
                      color:
                      Theme.of(
                        context,
                      )
                          .colorScheme
                          .onSurfaceVariant,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    asset.network,
                    style: TextStyle(
                      color:
                      Theme.of(
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
              width: 12,
            ),

            Column(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              children: [
                Text(
                  asset.amount,
                  textAlign:
                  TextAlign.end,
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  asset.value,
                  style: TextStyle(
                    color:
                    Theme.of(
                      context,
                    )
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  asset.change,
                  style: TextStyle(
                    color:
                    asset.isPositive
                        ? Colors.green
                        : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TOTAL CARD
  // ============================================================

  Widget _totalCard() {
    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              'Total Wallet Value',
              style: TextStyle(
                color:
                Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              '\$${_totalBalance.toStringAsFixed(2)}',
              style:
              const TextStyle(
                fontSize: 30,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            const Text(
              'USD-valued wallet balance',
              style: TextStyle(
                fontSize: 12,
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
      appBar: AppBar(
        title: const Text(
          'Assets',
          style: TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: _loadAssets,
        child: ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding:
          const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            30,
          ),
          children: [
            _totalCard(),

            const SizedBox(
              height: 24,
            ),

            const Text(
              'Your Assets',
              style:
              TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            if (_assets.isEmpty)
              const Padding(
                padding:
                EdgeInsets.all(
                  30,
                ),
                child: Center(
                  child: Text(
                    'No assets yet',
                  ),
                ),
              ),

            ..._assets.map(
              _assetCard,
            ),
          ],
        ),
      ),
    );
  }
}