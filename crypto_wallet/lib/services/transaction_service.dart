import '../models/transaction.dart';
import 'api_service.dart';

class TransactionService {
  static final List<WalletTransaction> _transactions =
  <WalletTransaction>[];

  static bool _initialized = false;

  // ============================================================
  // INITIALIZE
  // ============================================================

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    try {
      final response = await ApiService.get(
        '/transactions',
      );

      if (response['success'] == true) {
        final List<dynamic> transactionsData =
            response['transactions'] ?? [];

        _transactions.clear();

        for (final dynamic item in transactionsData) {
          if (item is Map<String, dynamic>) {
            _transactions.add(
              _fromBackendMap(item),
            );
          }
        }

        _sortTransactions();
        _initialized = true;
      }
    } catch (e) {
      _transactions.clear();
      _initialized = false;
      rethrow;
    }
  }

  // ============================================================
  // CREATE TRANSACTION
  // ============================================================

  static Future<WalletTransaction> createTransaction({
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

    final String backendType =
    _convertTypeToBackend(type);

    final response = await ApiService.post(
      '/transactions',
      {
        'type': backendType,
        'asset': asset,
        'amount': amount,
        'from': from,
        'to': to,
        'status': 'completed',
        'network': network,
        'description': 'Wallet transaction',
      },
    );

    if (response['success'] != true ||
        response['transaction'] == null) {
      throw StateError(
        'Transaction could not be created.',
      );
    }

    final Map<String, dynamic> transactionData =
    Map<String, dynamic>.from(
      response['transaction'],
    );

    final WalletTransaction transaction =
    _fromBackendMap(
      transactionData,
      valueOverride: value,
      typeOverride: type,
    );

    _transactions.insert(
      0,
      transaction,
    );

    _sortTransactions();

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

    final response = await ApiService.post(
      '/swaps',
      {
        'fromAsset': fromCurrency,
        'toAsset': toCurrency,
        'fromAmount': fromAmount,
        'toAmount': toAmount,
        'rate': exchangeRate,
        'status': 'completed',
      },
    );

    if (response['success'] != true ||
        response['swap'] == null) {
      throw StateError(
        'Swap transaction could not be created.',
      );
    }

    final String swapId =
        response['swap']['swapId']?.toString() ??
            'SWAP-${DateTime.now().millisecondsSinceEpoch}';

    final WalletTransaction transaction =
    WalletTransaction(
      id: swapId,
      type: 'Swap',
      asset:
      '$fromCurrency → $toCurrency',
      network:
      '$fromNetwork → $toNetwork',
      amount: fromAmount,
      value: toAmount,
      from: fromCurrency,
      to: toCurrency,
      timestamp: _parseDate(
        response['swap']['createdAt'],
      ),
    );

    _transactions.insert(
      0,
      transaction,
    );

    _sortTransactions();

    return transaction;
  }

  // ============================================================
  // GET ALL
  // ============================================================

  static Future<List<WalletTransaction>>
  getTransactions() async {
    await _refreshFromBackend();

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
    await _refreshFromBackend();

    if (limit <= 0) {
      return <WalletTransaction>[];
    }

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
    await _refreshFromBackend();

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

  static Future<void> deleteTransaction(
      String id,
      ) async {
    // Backend currently does not expose
    // transaction delete endpoint.

    _transactions.removeWhere(
          (WalletTransaction transaction) =>
      transaction.id == id,
    );
  }

  // ============================================================
  // CLEAR
  // ============================================================

  static Future<void> clearTransactions() async {
    // Backend currently does not expose
    // clear-all transactions endpoint.

    _transactions.clear();
  }

  // ============================================================
  // REFRESH FROM BACKEND
  // ============================================================

  static Future<void> _refreshFromBackend() async {
    try {
      final response = await ApiService.get(
        '/transactions',
      );

      if (response['success'] != true) {
        return;
      }

      final List<dynamic> transactionsData =
          response['transactions'] ?? [];

      _transactions.clear();

      for (final dynamic item in transactionsData) {
        if (item is Map<String, dynamic>) {
          _transactions.add(
            _fromBackendMap(item),
          );
        }
      }

      _sortTransactions();

      _initialized = true;
    } catch (e) {
      if (!_initialized) {
        rethrow;
      }
    }
  }

  // ============================================================
  // BACKEND MAP → FLUTTER MODEL
  // ============================================================

  static WalletTransaction _fromBackendMap(
      Map<String, dynamic> data, {
        double? valueOverride,
        String? typeOverride,
      }) {
    final String type =
        typeOverride ??
            _convertTypeFromBackend(
              data['type']?.toString() ?? '',
            );

    final double amount =
    _toDouble(data['amount']);

    final double value =
        valueOverride ??
            amount;

    return WalletTransaction(
      id: data['transactionId']?.toString() ??
          data['_id']?.toString() ??
          'TX-${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      asset: data['asset']?.toString() ?? '',
      network: data['network']?.toString() ?? '',
      amount: amount,
      value: value,
      from: data['from']?.toString() ?? '',
      to: data['to']?.toString() ?? '',
      timestamp: _parseDate(
        data['createdAt'],
      ),
    );
  }

  // ============================================================
  // TYPE CONVERSION
  // ============================================================

  static String _convertTypeToBackend(
      String type,
      ) {
    switch (type.toLowerCase()) {
      case 'sent':
        return 'sent';

      case 'received':
        return 'received';

      case 'p2p_received':
        return 'p2p_received';

      case 'swap':
        return 'swap';

      case 'deposit':
        return 'received';

      case 'withdrawal':
        return 'sent';

      default:
        return 'received';
    }
  }

  static String _convertTypeFromBackend(
      String type,
      ) {
    switch (type.toLowerCase()) {
      case 'sent':
        return 'Sent';

      case 'received':
        return 'Received';

      case 'p2p_received':
        return 'Received';

      case 'swap':
        return 'Swap';

      default:
        return type;
    }
  }

  // ============================================================
  // DOUBLE PARSER
  // ============================================================

  static double _toDouble(
      dynamic value,
      ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0.0;
  }

  // ============================================================
  // DATE PARSER
  // ============================================================

  static DateTime _parseDate(
      dynamic value,
      ) {
    if (value is DateTime) {
      return value;
    }

    final DateTime? parsed =
    DateTime.tryParse(
      value?.toString() ?? '',
    );

    return parsed ?? DateTime.now();
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