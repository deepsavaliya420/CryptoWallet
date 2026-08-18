import '../models/transaction.dart';

class TransactionService {
  static final List<WalletTransaction> _transactions = [
    WalletTransaction(
      id: 'TX-10001',
      type: 'Received',
      asset: 'USDT',
      network: 'TRC-20',
      amount: 250.0,
      value: 250.0,
      from: 'TX9a...72Kp',
      to: 'TY8b...91Lm',
      status: 'Completed',
      timestamp: DateTime.now().subtract(
        const Duration(hours: 2),
      ),
    ),
    WalletTransaction(
      id: 'TX-10002',
      type: 'Sent',
      asset: 'SOL',
      network: 'Solana',
      amount: 0.50,
      value: 92.50,
      from: 'TY8b...91Lm',
      to: '7xK2...9PqL',
      status: 'Completed',
      timestamp: DateTime.now().subtract(
        const Duration(days: 1),
      ),
    ),
    WalletTransaction(
      id: 'TX-10003',
      type: 'Received',
      asset: 'ETH',
      network: 'Ethereum',
      amount: 0.20,
      value: 490.0,
      from: '0xA91...72BC',
      to: '0x71C...976F',
      status: 'Completed',
      timestamp: DateTime.now().subtract(
        const Duration(days: 2),
      ),
    ),
  ];

  /// Get all transactions.
  static Future<List<WalletTransaction>> getTransactions() async {
    return List.unmodifiable(_transactions);
  }

  /// Get a single transaction by ID.
  static Future<WalletTransaction?> getTransaction(
      String transactionId,
      ) async {
    try {
      return _transactions.firstWhere(
            (transaction) => transaction.id == transactionId,
      );
    } catch (_) {
      return null;
    }
  }

  /// Get transactions for a specific cryptocurrency.
  static Future<List<WalletTransaction>> getTransactionsByAsset(
      String asset,
      ) async {
    return _transactions
        .where(
          (transaction) =>
      transaction.asset.toUpperCase() ==
          asset.toUpperCase(),
    )
        .toList();
  }

  /// Add a new transaction.
  static Future<void> addTransaction(
      WalletTransaction transaction,
      ) async {
    _transactions.insert(0, transaction);
  }

  /// Create a demo transaction.
  static Future<WalletTransaction> createTransaction({
    required String type,
    required String asset,
    required String network,
    required double amount,
    required double value,
    required String from,
    required String to,
  }) async {
    final transaction = WalletTransaction(
      id: 'TX-${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      asset: asset,
      network: network,
      amount: amount,
      value: value,
      from: from,
      to: to,
      status: 'Completed',
      timestamp: DateTime.now(),
    );

    _transactions.insert(0, transaction);

    return transaction;
  }

  /// Remove a transaction.
  static Future<void> deleteTransaction(
      String transactionId,
      ) async {
    _transactions.removeWhere(
          (transaction) => transaction.id == transactionId,
    );
  }

  /// Clear all transactions.
  static Future<void> clearTransactions() async {
    _transactions.clear();
  }
}