import '../models/swap_transaction.dart';
import 'api_service.dart';

class SwapService {
  static const double _swapFeePercent = 0.0;

  static final List<SwapTransaction> _swaps =
  <SwapTransaction>[];

  static bool _initialized = false;

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
    'SOL',
    'TRX',
  ];

  static const List<String> networks = [
    'TRC-20',
    'ERC-20',
    'Solana',
    'BEP-20',
    'TRON',
    'Bitcoin',
  ];

  static const Map<String, double> _usdRates = {
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
    'SOL': 0.0060,
    'TRX': 4.0,
  };

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    try {
      final response =
      await ApiService.get(
        '/swaps',
      );

      if (response['success'] != true) {
        throw StateError(
          response['message']?.toString() ??
              'Swaps could not be loaded.',
        );
      }

      final List<dynamic> swapsData =
          response['swaps'] ?? [];

      _swaps.clear();

      for (final dynamic item in swapsData) {
        if (item is Map<String, dynamic>) {
          _swaps.add(
            _fromBackendMap(item),
          );
        }
      }

      _sortSwaps();

      _initialized = true;
    } catch (e) {
      _initialized = false;
      rethrow;
    }
  }

  static Future<void> refresh() async {
    _initialized = false;

    await initialize();
  }

  static double getExchangeRate({
    required String fromCurrency,
    required String toCurrency,
  }) {
    final String from =
    fromCurrency.toUpperCase();

    final String to =
    toCurrency.toUpperCase();

    final double? fromRate =
    _usdRates[from];

    final double? toRate =
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

    return toRate / fromRate;
  }

  static double calculateReceivedAmount({
    required double fromAmount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    if (fromAmount <= 0) {
      return 0;
    }

    final double rate =
    getExchangeRate(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
    );

    final double fee =
    calculateFee(fromAmount);

    final double amountAfterFee =
        fromAmount - fee;

    return amountAfterFee * rate;
  }

  static double calculateFee(
      double amount,
      ) {
    if (amount <= 0) {
      return 0;
    }

    return amount *
        (_swapFeePercent / 100);
  }

  static double getUsdValue({
    required double amount,
    required String currency,
  }) {
    final double? rate =
    _usdRates[
    currency.toUpperCase()];

    if (rate == null) {
      throw StateError(
        'Unsupported currency: '
            '${currency.toUpperCase()}',
      );
    }

    return amount / rate;
  }

  static double getMaxSwapAmountUsd({
    required double totalUsdBalance,
  }) {
    if (totalUsdBalance <= 0) {
      return 0;
    }

    return totalUsdBalance;
  }

  static Future<SwapTransaction>
  createSwap({
    required String fromCurrency,
    required String fromNetwork,
    required String toCurrency,
    required String toNetwork,
    required double fromAmount,
  }) async {
    await initialize();

    final String from =
    fromCurrency.toUpperCase();

    final String to =
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

    final double rate =
    getExchangeRate(
      fromCurrency: from,
      toCurrency: to,
    );

    final double fee =
    calculateFee(fromAmount);

    final double received =
    calculateReceivedAmount(
      fromAmount: fromAmount,
      fromCurrency: from,
      toCurrency: to,
    );

    final response =
    await ApiService.post(
      '/swaps',
      {
        'fromAsset': from,
        'toAsset': to,
        'fromAmount': fromAmount,
        'toAmount': received,
        'rate': rate,
        'status': 'completed',
      },
    );

    if (response['success'] != true ||
        response['swap'] == null) {
      throw StateError(
        response['message']?.toString() ??
            'Swap could not be created.',
      );
    }

    final Map<String, dynamic>
    swapData =
    Map<String, dynamic>.from(
      response['swap'],
    );

    final SwapTransaction swap =
    SwapTransaction(
      id:
      swapData['swapId']
          ?.toString() ??
          swapData['_id']
              ?.toString() ??
          'SWAP-${DateTime.now().millisecondsSinceEpoch}',

      fromCurrency: from,

      fromNetwork:
      fromNetwork,

      toCurrency: to,

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
      _convertStatus(
        swapData['status']
            ?.toString() ??
            'completed',
      ),

      timestamp:
      _parseDate(
        swapData['createdAt'],
      ),
    );

    _swaps.removeWhere(
          (SwapTransaction item) =>
      item.id == swap.id,
    );

    _swaps.insert(
      0,
      swap,
    );

    _sortSwaps();

    return swap;
  }

  static Future<List<SwapTransaction>>
  getSwaps() async {
    await _refreshFromBackend();

    return List<SwapTransaction>.unmodifiable(
      _swaps,
    );
  }

  static Future<List<SwapTransaction>>
  getRecentSwaps({
    int limit = 5,
  }) async {
    await _refreshFromBackend();

    if (limit <= 0) {
      return <SwapTransaction>[];
    }

    final int count =
    limit < _swaps.length
        ? limit
        : _swaps.length;

    return List<SwapTransaction>.unmodifiable(
      _swaps.take(count).toList(),
    );
  }

  static Future<SwapTransaction?>
  getSwap(
      String id,
      ) async {
    await _refreshFromBackend();

    try {
      return _swaps.firstWhere(
            (SwapTransaction swap) =>
        swap.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> deleteSwap(
      String id,
      ) async {
    _swaps.removeWhere(
          (SwapTransaction swap) =>
      swap.id == id,
    );
  }

  static Future<void> clearHistory() async {
    _swaps.clear();
  }

  static Future<void>
  _refreshFromBackend() async {
    try {
      final response =
      await ApiService.get(
        '/swaps',
      );

      if (response['success'] != true) {
        return;
      }

      final List<dynamic> swapsData =
          response['swaps'] ?? [];

      _swaps.clear();

      for (final dynamic item in swapsData) {
        if (item is Map<String, dynamic>) {
          _swaps.add(
            _fromBackendMap(item),
          );
        }
      }

      _sortSwaps();

      _initialized = true;
    } catch (e) {
      if (!_initialized) {
        rethrow;
      }
    }
  }

  static SwapTransaction
  _fromBackendMap(
      Map<String, dynamic> data,
      ) {
    final String fromCurrency =
        data['fromAsset']
            ?.toString() ??
            '';

    final String toCurrency =
        data['toAsset']
            ?.toString() ??
            '';

    final double fromAmount =
    _toDouble(
      data['fromAmount'],
    );

    final double toAmount =
    _toDouble(
      data['toAmount'],
    );

    final double rate =
    _toDouble(
      data['rate'],
    );

    final double fee =
    calculateFee(
      fromAmount,
    );

    return SwapTransaction(
      id:
      data['swapId']
          ?.toString() ??
          data['_id']
              ?.toString() ??
          'SWAP-${DateTime.now().millisecondsSinceEpoch}',

      fromCurrency:
      fromCurrency,

      fromNetwork:
      data['fromNetwork']
          ?.toString() ??
          '',

      toCurrency:
      toCurrency,

      toNetwork:
      data['toNetwork']
          ?.toString() ??
          '',

      fromAmount:
      fromAmount,

      toAmount:
      toAmount,

      exchangeRate:
      rate,

      fee:
      fee,

      status:
      _convertStatus(
        data['status']
            ?.toString() ??
            'completed',
      ),

      timestamp:
      _parseDate(
        data['createdAt'],
      ),
    );
  }

  static String _convertStatus(
      String status,
      ) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'completed';

      case 'pending':
        return 'pending';

      case 'failed':
        return 'failed';

      default:
        return status;
    }
  }

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

  static DateTime _parseDate(
      dynamic value,
      ) {
    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(
      value?.toString() ?? '',
    ) ??
        DateTime.now();
  }

  static void _sortSwaps() {
    _swaps.sort(
          (
          SwapTransaction a,
          SwapTransaction b,
          ) {
        return b.timestamp.compareTo(
          a.timestamp,
        );
      },
    );
  }
}