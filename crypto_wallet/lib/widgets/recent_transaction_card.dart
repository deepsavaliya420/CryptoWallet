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
    final colorScheme = Theme.of(context).colorScheme;

    final iconColor = isReceived ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 5,
        ),
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.12),
          child: Icon(
            isReceived
                ? Icons.arrow_downward
                : Icons.arrow_upward,
            color: iconColor,
          ),
        ),
        title: Text(
          type,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '$asset • $network\n$time',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        isThreeLine: true,
        trailing: Text(
          '${isReceived ? '+' : '-'}$amount',
          style: TextStyle(
            color: iconColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}