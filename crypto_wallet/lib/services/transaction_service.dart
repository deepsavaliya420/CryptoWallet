import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction.dart';

class TransactionService {
  static const String _storageKey =
      'wallet_transactions';

  static final List<WalletTransaction>
  _transactions = <WalletTransaction>[];

  static bool _initialized = false;

  // ============================================================
  // INITIALIZE
  // ============================================================

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    final List<String>? saved =
    prefs.getStringList(_storageKey);

    _transactions.clear();

    if (saved != null) {
      for (final String item in saved) {
        try {
          final dynamic decoded =
          jsonDecode(item);

          if (decoded is Map<String, dynamic>) {
            _transactions.add(
              WalletTransaction.fromMap(
                decoded,
              ),
            );
          }
        } catch (_) {
          // Ignore invalid saved transaction.
        }
      }
    }

    _sortTransactions();

    _initialized = true;
  }

  // ============================================================
  // CREATE TRANSACTION
  // ============================================================

  static Future<WalletTransaction>
  createTransaction({
    required String type,
    required String asset,
    required String network,
    required double amount,
    required double value,
    String from = '',
    String to = '',
  }) async {
    await initialize();

    if (amount <= 0) {
      throw StateError(
        'Transaction amount must be greater than zero.',
      );
    }

    final WalletTransaction transaction =
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
      timestamp: DateTime.now(),
    );

    _transactions.insert(
      0,
      transaction,
    );

    await _saveTransactions();

    return transaction;
  }

  // ============================================================
  // SENT TRANSACTION
  // ============================================================

  static Future<WalletTransaction>
  createSentTransaction({
    required String asset,
    required String network,
    required double amount,
    required double value,
    required String recipient,
  }) async {
    return createTransaction(
      type: 'Sent',
      asset: asset,
      network: network,
      amount: amount,
      value: value,
      from: 'My Wallet',
      to: recipient,
    );
  }

  // ============================================================
  // RECEIVED TRANSACTION
  // ============================================================

  static Future<WalletTransaction>
  createReceivedTransaction({
    required String asset,
    required String network,
    required double amount,
    required double value,
    required String sender,
  }) async {
    return createTransaction(
      type: 'Received',
      asset: asset,
      network: network,
      amount: amount,
      value: value,
      from: sender,
      to: 'My Wallet',
    );
  }

  // ============================================================
  // P2P RECEIVED TRANSACTION
  // ============================================================

  static Future<WalletTransaction>
  createP2PReceivedTransaction({
    required String asset,
    required String network,
    required double amount,
    required double value,
    required String seller,
    required String buyerWallet,
  }) async {
    return createTransaction(
      type: 'Received',
      asset: asset,
      network: network,
      amount: amount,
      value: value,
      from: seller,
      to: buyerWallet,
    );
  }

  // ============================================================
  // SWAP TRANSACTION
  // ============================================================

  static Future<WalletTransaction>
  createSwapTransaction({
    required String fromCurrency,
    required String fromNetwork,
    required double fromAmount,
    required String toCurrency,
    required String toNetwork,
    required double toAmount,
    required double exchangeRate,
  }) async {
    await initialize();

    if (fromAmount <= 0) {
      throw StateError(
        'Swap source amount must be greater than zero.',
      );
    }

    if (toAmount <= 0) {
      throw StateError(
        'Swap destination amount must be greater than zero.',
      );
    }

    final WalletTransaction transaction =
    WalletTransaction(
      id:
      'SWAP-${DateTime.now().millisecondsSinceEpoch}',
      type: 'Swap',
      asset:
      '$fromCurrency → $toCurrency',
      network:
      '$fromNetwork → $toNetwork',
      amount: fromAmount,
      value: toAmount,
      from: fromCurrency,
      to: toCurrency,
      timestamp: DateTime.now(),
    );

    _transactions.insert(
      0,
      transaction,
    );

    await _saveTransactions();

    return transaction;
  }

  // ============================================================
  // GET ALL
  // ============================================================

  static Future<List<WalletTransaction>>
  getTransactions() async {
    await initialize();

    _sortTransactions();

    return List<WalletTransaction>.unmodifiable(
      _transactions,
    );
  }

  // ============================================================
  // GET RECENT
  // ============================================================

  static Future<List<WalletTransaction>>
  getRecentTransactions({
    int limit = 5,
  }) async {
    await initialize();

    if (limit <= 0) {
      return <WalletTransaction>[];
    }

    _sortTransactions();

    final int count =
    limit < _transactions.length
        ? limit
        : _transactions.length;

    return List<WalletTransaction>.unmodifiable(
      _transactions
          .take(count)
          .toList(),
    );
  }

  // ============================================================
  // GET ONE
  // ============================================================

  static Future<WalletTransaction?>
  getTransaction(
      String id,
      ) async {
    await initialize();

    try {
      return _transactions.firstWhere(
            (WalletTransaction transaction) =>
        transaction.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  static Future<void>
  deleteTransaction(
      String id,
      ) async {
    await initialize();

    _transactions.removeWhere(
          (WalletTransaction transaction) =>
      transaction.id == id,
    );

    await _saveTransactions();
  }

  // ============================================================
  // CLEAR
  // ============================================================

  static Future<void>
  clearTransactions() async {
    await initialize();

    _transactions.clear();

    await _saveTransactions();
  }

  // ============================================================
  // SAVE
  // ============================================================

  static Future<void>
  _saveTransactions() async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    final List<String> encoded =
    _transactions.map(
          (WalletTransaction transaction) {
        return jsonEncode(
          transaction.toMap(),
        );
      },
    ).toList();

    await prefs.setStringList(
      _storageKey,
      encoded,
    );
  }

  // ============================================================
  // SORT
  // ============================================================

  static void _sortTransactions() {
    _transactions.sort(
          (
          WalletTransaction a,
          WalletTransaction b,
          ) {
        return b.timestamp.compareTo(
          a.timestamp,
        );
      },
    );
  }
}