import 'package:flutter/material.dart';

class WalletBalanceCard extends StatelessWidget {
  final String balance;
  final String change;

  const WalletBalanceCard({
    super.key,
    required this.balance,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
          ],
        ),
        borderRadius:
        BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary
                .withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ====================================================
          // DECORATIVE CIRCLE
          // ====================================================

          Positioned(
            right: -35,
            top: -45,
            child: Container(
              width: 135,
              height: 135,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white
                    .withValues(alpha: 0.07),
              ),
            ),
          ),

          Positioned(
            right: 35,
            bottom: -65,
            child: Container(
              width: 105,
              height: 105,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white
                    .withValues(alpha: 0.05),
              ),
            ),
          ),

          // ====================================================
          // CONTENT
          // ====================================================

          Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              // -----------------------------------------------
              // HEADER
              // -----------------------------------------------

              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withValues(alpha: 0.13),
                      borderRadius:
                      BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white
                            .withValues(alpha: 0.10),
                      ),
                    ),
                    child: const Icon(
                      Icons
                          .account_balance_wallet_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Balance',
                          style: TextStyle(
                            color: Colors.white
                                .withValues(
                              alpha: 0.78,
                            ),
                            fontSize: 11,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Portfolio Value',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withValues(alpha: 0.11),
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        Icon(
                          Icons
                              .visibility_outlined,
                          size: 14,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Wallet',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 19),

              // -----------------------------------------------
              // BALANCE
              // -----------------------------------------------

              Text(
                balance,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 31,
                  fontWeight:
                  FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),

              const SizedBox(height: 11),

              // -----------------------------------------------
              // CHANGE
              // -----------------------------------------------

              Row(
                children: [
                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withValues(alpha: 0.12),
                      borderRadius:
                      BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.trending_up_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Flexible(
                    child: Text(
                      change,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // -----------------------------------------------
              // BOTTOM LABEL
              // -----------------------------------------------

              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration:
                    const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'Live portfolio value',
                    style: TextStyle(
                      color: Colors.white
                          .withValues(
                        alpha: 0.68,
                      ),
                      fontSize: 9.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}