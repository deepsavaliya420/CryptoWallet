import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/swap_transaction.dart';

class SwapService {
  static const String _storageKey =
      'swap_transactions';

  static const double _swapFeePercent = 0.0;

  static final List<SwapTransaction> _swaps = [];

  static bool _initialized = false;

  // ============================================================
  // SUPPORTED CURRENCIES
  // ============================================================

  static const List<String> currencies = [
    'USD',
    'INR',
    'EUR',
    'GBP',
    'AED',
    'JPY',
    'USDT',
    'USDC',
    'BTC',
    'ETH',
  ];

  // ============================================================
  // SUPPORTED NETWORKS
  // ============================================================

  static const List<String> networks = [
    'TRC-20',
    'ERC-20',
    'Solana',
    'BEP-20',
    'TRON',
    'Bitcoin',
  ];

  // ============================================================
  // INTERNAL USD RATES
  //
  // 1 USD = rate units of the currency.
  //
  // These are app/demo rates.
  // For production, replace them with a live
  // exchange-rate provider.
  // ============================================================

  static const Map<String, double>
  _usdRates = {
    'USD': 1.0,

    'INR': 83.50,
    'EUR': 0.92,
    'GBP': 0.79,
    'AED': 3.6725,
    'JPY': 157.0,

    'USDT': 1.0,
    'USDC': 1.0,

    'BTC': 0.0000105,
    'ETH': 0.00030,
  };

  // ============================================================
  // INITIALIZE
  // ============================================================

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    final prefs =
    await SharedPreferences.getInstance();

    final saved =
    prefs.getStringList(
      _storageKey,
    );

    if (saved != null) {
      _swaps.clear();

      for (final item in saved) {
        try {
          _swaps.add(
            SwapTransaction.fromMap(
              jsonDecode(item)
              as Map<String, dynamic>,
            ),
          );
        } catch (_) {
          // Ignore corrupted swap records.
        }
      }
    }

    _sortSwaps();

    _initialized = true;
  }

  // ============================================================
  // GET EXCHANGE RATE
  //
  // Example:
  //
  // USD -> INR
  // 1 USD = 83.50 INR
  // ============================================================

  static double getExchangeRate({
    required String fromCurrency,
    required String toCurrency,
  }) {
    final from =
    fromCurrency.toUpperCase();

    final to =
    toCurrency.toUpperCase();

    final fromRate =
    _usdRates[from];

    final toRate =
    _usdRates[to];

    if (fromRate == null) {
      throw StateError(
        'Unsupported source currency: $from',
      );
    }

    if (toRate == null) {
      throw StateError(
        'Unsupported destination currency: $to',
      );
    }

    /*
     * Convert:
     *
     * source -> USD -> destination
     *
     * Example:
     *
     * 1 USD = 83.50 INR
     */

    return toRate / fromRate;
  }

  // ============================================================
  // CALCULATE RECEIVED AMOUNT
  // ============================================================

  static double calculateReceivedAmount({
    required double fromAmount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    if (fromAmount <= 0) {
      return 0;
    }

    final rate =
    getExchangeRate(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
    );

    final fee =
    calculateFee(
      fromAmount,
    );

    final amountAfterFee =
        fromAmount - fee;

    return amountAfterFee * rate;
  }

  // ============================================================
  // CALCULATE FEE
  // ============================================================

  static double calculateFee(
      double amount,
      ) {
    if (amount <= 0) {
      return 0;
    }

    return amount *
        (_swapFeePercent / 100);
  }

  // ============================================================
  // GET USD VALUE
  //
  // Used to check the maximum swap against
  // the wallet's USD balance.
  // ============================================================

  static double getUsdValue({
    required double amount,
    required String currency,
  }) {
    final rate =
    _usdRates[
    currency.toUpperCase()
    ];

    if (rate == null) {
      throw StateError(
        'Unsupported currency: '
            '${currency.toUpperCase()}',
      );
    }

    /*
     * _usdRates means:
     *
     * 1 USD = X currency
     *
     * Therefore:
     *
     * currency amount / X = USD value
     */

    return amount / rate;
  }

  // ============================================================
  // GET MAX SWAPPABLE USD
  // ============================================================

  static double getMaxSwapAmountUsd({
    required double totalUsdBalance,
  }) {
    if (totalUsdBalance <= 0) {
      return 0;
    }

    return totalUsdBalance;
  }

  // ============================================================
  // CREATE / EXECUTE SWAP
  //
  // This service only creates and stores the swap.
  // Wallet balance movement is handled by the wallet
  // integration in the Swap screen.
  // ============================================================

  static Future<SwapTransaction>
  createSwap({
    required String fromCurrency,
    required String fromNetwork,
    required String toCurrency,
    required String toNetwork,
    required double fromAmount,
  }) async {
    await initialize();

    final from =
    fromCurrency.toUpperCase();

    final to =
    toCurrency.toUpperCase();

    if (!_usdRates.containsKey(from)) {
      throw StateError(
        'Unsupported source currency: $from',
      );
    }

    if (!_usdRates.containsKey(to)) {
      throw StateError(
        'Unsupported destination currency: $to',
      );
    }

    if (from == to &&
        fromNetwork == toNetwork) {
      throw StateError(
        'Source and destination cannot be the same.',
      );
    }

    if (!networks.contains(fromNetwork)) {
      throw StateError(
        'Unsupported source network: '
            '$fromNetwork',
      );
    }

    if (!networks.contains(toNetwork)) {
      throw StateError(
        'Unsupported destination network: '
            '$toNetwork',
      );
    }

    if (fromAmount <= 0) {
      throw StateError(
        'Swap amount must be greater than zero.',
      );
    }

    final rate =
    getExchangeRate(
      fromCurrency: from,
      toCurrency: to,
    );

    final fee =
    calculateFee(
      fromAmount,
    );

    final received =
    calculateReceivedAmount(
      fromAmount: fromAmount,
      fromCurrency: from,
      toCurrency: to,
    );

    final swap =
    SwapTransaction(
      id:
      'SWAP-${DateTime.now().millisecondsSinceEpoch}',
      fromCurrency:
      from,
      fromNetwork:
      fromNetwork,
      toCurrency:
      to,
      toNetwork:
      toNetwork,
      fromAmount:
      fromAmount,
      toAmount:
      received,
      exchangeRate:
      rate,
      fee:
      fee,
      status:
      'completed',
      timestamp:
      DateTime.now(),
    );

    _swaps.insert(
      0,
      swap,
    );

    await _saveSwaps();

    return swap;
  }

  // ============================================================
  // LOAD ALL SWAPS
  // ============================================================

  static Future<List<SwapTransaction>>
  getSwaps() async {
    await initialize();

    _sortSwaps();

    return List.unmodifiable(
      _swaps,
    );
  }

  // ============================================================
  // RECENT SWAPS
  // ============================================================

  static Future<List<SwapTransaction>>
  getRecentSwaps({
    int limit = 5,
  }) async {
    await initialize();

    _sortSwaps();

    final count =
    limit < _swaps.length
        ? limit
        : _swaps.length;

    return List.unmodifiable(
      _swaps.take(count).toList(),
    );
  }

  // ============================================================
  // FIND ONE SWAP
  // ============================================================

  static Future<SwapTransaction?>
  getSwap(
      String id,
      ) async {
    await initialize();

    try {
      return _swaps.firstWhere(
            (swap) =>
        swap.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // DELETE SWAP
  // ============================================================

  static Future<void> deleteSwap(
      String id,
      ) async {
    await initialize();

    _swaps.removeWhere(
          (swap) =>
      swap.id == id,
    );

    await _saveSwaps();
  }

  // ============================================================
  // CLEAR HISTORY
  // ============================================================

  static Future<void> clearHistory() async {
    await initialize();

    _swaps.clear();

    await _saveSwaps();
  }

  // ============================================================
  // SAVE
  // ============================================================

  static Future<void> _saveSwaps() async {
    final prefs =
    await SharedPreferences.getInstance();

    final encoded =
    _swaps.map(
          (swap) => jsonEncode(
        swap.toMap(),
      ),
    ).toList();

    await prefs.setStringList(
      _storageKey,
      encoded,
    );
  }

  // ============================================================
  // SORT
  // ============================================================

  static void _sortSwaps() {
    _swaps.sort(
          (a, b) =>
          b.timestamp.compareTo(
            a.timestamp,
          ),
    );
  }
}