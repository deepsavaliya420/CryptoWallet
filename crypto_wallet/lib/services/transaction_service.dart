import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction.dart';

class TransactionService {
  static const String _storageKey =
      'wallet_transactions';

  static bool _initialized = false;

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

  // ============================================================
  // INITIALIZATION
  // ============================================================

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    final prefs =
    await SharedPreferences.getInstance();

    final savedTransactions =
    prefs.getStringList(_storageKey);

    if (savedTransactions != null &&
        savedTransactions.isNotEmpty) {
      _transactions.clear();

      for (final transactionJson
      in savedTransactions) {
        try {
          final decoded =
          jsonDecode(transactionJson);

          if (decoded is Map<String, dynamic>) {
            _transactions.add(
              _transactionFromJson(decoded),
            );
          }
        } catch (_) {
          // Ignore invalid saved transactions.
        }
      }
    }

    /*
     * Make sure newest transaction is always first.
     */
    _sortTransactions();

    _initialized = true;
  }

  // ============================================================
  // GET TRANSACTIONS
  // ============================================================

  /// Get all transactions.
  static Future<List<WalletTransaction>>
  getTransactions() async {
    await initialize();

    _sortTransactions();

    return List.unmodifiable(
      _transactions,
    );
  }

  /// Get recent transactions.
  static Future<List<WalletTransaction>>
  getRecentTransactions({
    int limit = 3,
  }) async {
    await initialize();

    _sortTransactions();

    return List.unmodifiable(
      _transactions.take(limit).toList(),
    );
  }

  /// Get transaction by ID.
  static Future<WalletTransaction?>
  getTransaction(
      String transactionId,
      ) async {
    await initialize();

    try {
      return _transactions.firstWhere(
            (transaction) =>
        transaction.id == transactionId,
      );
    } catch (_) {
      return null;
    }
  }

  /// Get transactions for a specific asset.
  static Future<List<WalletTransaction>>
  getTransactionsByAsset(
      String asset,
      ) async {
    await initialize();

    final result = _transactions
        .where(
          (transaction) =>
      transaction.asset.toUpperCase() ==
          asset.toUpperCase(),
    )
        .toList();

    result.sort(
          (a, b) =>
          b.timestamp.compareTo(a.timestamp),
    );

    return List.unmodifiable(result);
  }

  // ============================================================
  // ADD TRANSACTION
  // ============================================================

  /// Add an existing transaction.
  static Future<void> addTransaction(
      WalletTransaction transaction,
      ) async {
    await initialize();

    /*
     * Add newest transaction at the beginning.
     */
    _transactions.insert(
      0,
      transaction,
    );

    _sortTransactions();

    await _saveTransactions();
  }

  // ============================================================
  // CREATE NORMAL TRANSACTION
  // ============================================================

  /// Create a normal Send/Receive transaction.
  static Future<WalletTransaction>
  createTransaction({
    required String type,
    required String asset,
    required String network,
    required double amount,
    required double value,
    required String from,
    required String to,
  }) async {
    await initialize();

    final transaction =
    WalletTransaction(
      id:
      'TX-${DateTime.now().millisecondsSinceEpoch}',
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

    _transactions.insert(
      0,
      transaction,
    );

    _sortTransactions();

    await _saveTransactions();

    return transaction;
  }

  // ============================================================
  // CREATE P2P RECEIVED TRANSACTION
  // ============================================================

  /// Create a completed P2P received transaction.
  static Future<WalletTransaction>
  createP2PReceivedTransaction({
    required String asset,
    required String network,
    required double amount,
    required double value,
    required String seller,
    required String buyerWallet,
  }) async {
    await initialize();

    final transaction =
    WalletTransaction(
      id:
      'P2P-${DateTime.now().millisecondsSinceEpoch}',
      type: 'Received',
      asset: asset,
      network: network,
      amount: amount,
      value: value,
      from: seller,
      to: buyerWallet,
      status: 'Completed',
      timestamp: DateTime.now(),
    );

    _transactions.insert(
      0,
      transaction,
    );

    _sortTransactions();

    await _saveTransactions();

    return transaction;
  }

  // ============================================================
  // DELETE
  // ============================================================

  /// Delete transaction.
  static Future<void> deleteTransaction(
      String transactionId,
      ) async {
    await initialize();

    _transactions.removeWhere(
          (transaction) =>
      transaction.id == transactionId,
    );

    await _saveTransactions();
  }

  // ============================================================
  // CLEAR
  // ============================================================

  /// Clear all transactions.
  static Future<void> clearTransactions() async {
    await initialize();

    _transactions.clear();

    await _saveTransactions();
  }

  // ============================================================
  // STORAGE
  // ============================================================

  static Future<void> _saveTransactions() async {
    final prefs =
    await SharedPreferences.getInstance();

    final encodedTransactions =
    _transactions
        .map(
          (transaction) =>
          jsonEncode(
            _transactionToJson(
              transaction,
            ),
          ),
    )
        .toList();

    await prefs.setStringList(
      _storageKey,
      encodedTransactions,
    );
  }

  // ============================================================
  // JSON CONVERSION
  // ============================================================

  static Map<String, dynamic>
  _transactionToJson(
      WalletTransaction transaction,
      ) {
    return {
      'id': transaction.id,
      'type': transaction.type,
      'asset': transaction.asset,
      'network': transaction.network,
      'amount': transaction.amount,
      'value': transaction.value,
      'from': transaction.from,
      'to': transaction.to,
      'status': transaction.status,
      'timestamp':
      transaction.timestamp.toIso8601String(),
    };
  }

  static WalletTransaction
  _transactionFromJson(
      Map<String, dynamic> json,
      ) {
    return WalletTransaction(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      asset: json['asset']?.toString() ?? '',
      network:
      json['network']?.toString() ?? '',
      amount:
      (json['amount'] as num?)?.toDouble() ??
          0.0,
      value:
      (json['value'] as num?)?.toDouble() ??
          0.0,
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      status:
      json['status']?.toString() ??
          'Completed',
      timestamp:
      DateTime.tryParse(
        json['timestamp']
            ?.toString() ??
            '',
      ) ??
          DateTime.now(),
    );
  }

  // ============================================================
  // SORTING
  // ============================================================

  static void _sortTransactions() {
    _transactions.sort(
          (a, b) =>
          b.timestamp.compareTo(a.timestamp),
    );
  }
}