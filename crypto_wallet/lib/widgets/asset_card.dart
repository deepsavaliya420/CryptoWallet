import 'package:flutter/material.dart';

import '../models/asset.dart';

class AssetCard extends StatelessWidget {
  final Asset asset;

  const AssetCard({
    super.key,
    required this.asset,
  });

  Color getAssetColor(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'ETH':
        return Colors.deepPurple;
      case 'USDT':
        return Colors.green;
      case 'SOL':
        return Colors.blue;
      case 'TRX':
        return Colors.red;
      case 'BTC':
        return Colors.orange;
      case 'USDC':
        return Colors.blueAccent;
      case 'USD':
        return Colors.green;
      case 'INR':
        return Colors.deepOrange;
      case 'EUR':
        return Colors.indigo;
      case 'GBP':
        return Colors.purple;
      case 'AED':
        return Colors.teal;
      case 'JPY':
        return Colors.redAccent;
      default:
        return Colors.indigo;
    }
  }

  IconData getAssetIcon(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'ETH':
        return Icons.diamond_outlined;
      case 'USDT':
        return Icons.attach_money_rounded;
      case 'SOL':
        return Icons.bolt_rounded;
      case 'TRX':
        return Icons.flash_on_rounded;
      case 'BTC':
        return Icons.currency_bitcoin_rounded;
      case 'USDC':
        return Icons.monetization_on_outlined;
      case 'USD':
        return Icons.attach_money_rounded;
      case 'INR':
        return Icons.currency_rupee_rounded;
      case 'EUR':
        return Icons.euro_rounded;
      case 'GBP':
        return Icons.currency_pound_rounded;
      case 'AED':
        return Icons.payments_outlined;
      case 'JPY':
        return Icons.currency_yen_rounded;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final assetColor =
    getAssetColor(asset.symbol);

    final assetIcon =
    getAssetIcon(asset.symbol);

    final changeColor = asset.isPositive
        ? Colors.green
        : colorScheme.error;

    return Card(
      margin:
      const EdgeInsets.only(bottom: 11),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius:
        BorderRadius.circular(18),
        onTap: () {},
        child: Padding(
          padding:
          const EdgeInsets.all(15),
          child: Row(
            children: [
              // =================================================
              // ASSET ICON
              // =================================================

              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: assetColor.withValues(
                    alpha: 0.11,
                  ),
                  borderRadius:
                  BorderRadius.circular(16),
                  border: Border.all(
                    color:
                    assetColor.withValues(
                      alpha: 0.12,
                    ),
                  ),
                ),
                child: Icon(
                  assetIcon,
                  color: assetColor,
                  size: 25,
                ),
              ),

              const SizedBox(width: 13),

              // =================================================
              // ASSET INFORMATION
              // =================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            asset.symbol,
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight:
                              FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Container(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration:
                          BoxDecoration(
                            color: colorScheme
                                .surfaceContainerHighest,
                            borderRadius:
                            BorderRadius
                                .circular(
                              7,
                            ),
                          ),
                          child: Text(
                            asset.network,
                            maxLines: 1,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight:
                              FontWeight.w700,
                              color: colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      asset.name,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // =================================================
              // BALANCE
              // =================================================

              Column(
                crossAxisAlignment:
                CrossAxisAlignment.end,
                children: [
                  Text(
                    asset.amount,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    asset.value,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme
                          .onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Container(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration:
                    BoxDecoration(
                      color: changeColor
                          .withValues(
                        alpha: 0.10,
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        7,
                      ),
                    ),
                    child: Text(
                      asset.change,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: TextStyle(
                        color: changeColor,
                        fontSize: 10,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}