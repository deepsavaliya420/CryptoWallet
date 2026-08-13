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
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: colorScheme.onPrimary,
                ),
                const SizedBox(width: 10),
                Text(
                  'Total Balance',
                  style: TextStyle(
                    color: colorScheme.onPrimary.withValues(alpha: 0.85),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              balance,
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 18,
                  color: colorScheme.onPrimary,
                ),
                const SizedBox(width: 5),
                Text(
                  change,
                  style: TextStyle(
                    color: colorScheme.onPrimary,
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