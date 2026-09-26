import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  final String type;
  final String asset;
  final String network;
  final String amount;
  final String time;
  final bool isReceived;

  const TransactionCard({
    super.key,
    required this.type,
    required this.asset,
    required this.network,
    required this.amount,
    required this.time,
    required this.isReceived,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final iconColor = isReceived
        ? Colors.green
        : colorScheme.error;

    final icon = isReceived
        ? Icons.south_west_rounded
        : Icons.north_east_rounded;

    return Card(
      margin:
      const EdgeInsets.only(bottom: 11),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        child: Row(
          children: [
            // ==================================================
            // TRANSACTION ICON
            // ==================================================

            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(
                  alpha: 0.10,
                ),
                borderRadius:
                BorderRadius.circular(15),
                border: Border.all(
                  color:
                  iconColor.withValues(
                    alpha: 0.10,
                  ),
                ),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),

            const SizedBox(width: 12),

            // ==================================================
            // TRANSACTION INFO
            // ==================================================

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          asset,
                          maxLines: 1,
                          overflow:
                          TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight:
                            FontWeight.w700,
                            color: colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ),

                      Padding(
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 5,
                        ),
                        child: Text(
                          '•',
                          style: TextStyle(
                            color: colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ),

                      Flexible(
                        child: Text(
                          network,
                          maxLines: 1,
                          overflow:
                          TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  Text(
                    time,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.5,
                      color: colorScheme
                          .onSurfaceVariant
                          .withValues(
                        alpha: 0.75,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // ==================================================
            // AMOUNT
            // ==================================================

            Column(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              children: [
                Text(
                  '${isReceived ? '+' : '-'}$amount',
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 13,
                    fontWeight:
                    FontWeight.w800,
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
                    color:
                    iconColor.withValues(
                      alpha: 0.09,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      7,
                    ),
                  ),
                  child: Text(
                    isReceived
                        ? 'Received'
                        : 'Sent',
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 8.5,
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
    );
  }
}