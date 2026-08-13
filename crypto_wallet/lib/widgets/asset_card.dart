import 'package:flutter/material.dart';
import '../models/asset.dart';

class AssetCard extends StatelessWidget {
  final Asset asset;

  const AssetCard({
    super.key,
    required this.asset,
  });

  Color getAssetColor(String symbol) {
    switch (symbol) {
      case 'ETH':
        return Colors.deepPurple;
      case 'USDT':
        return Colors.green;
      case 'SOL':
        return Colors.blue;
      case 'TRX':
        return Colors.red;
      default:
        return Colors.indigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final assetColor = getAssetColor(asset.symbol);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: assetColor.withValues(alpha: 0.12),
              child: Text(
                asset.symbol[0],
                style: TextStyle(
                  color: assetColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.symbol,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${asset.name} • ${asset.network}',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  asset.amount,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  asset.value,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  asset.change,
                  style: TextStyle(
                    color: asset.isPositive
                        ? Colors.green
                        : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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