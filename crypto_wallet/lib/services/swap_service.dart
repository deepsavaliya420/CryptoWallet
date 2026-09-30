import '../models/swap_transaction.dart';
import 'api_service.dart';
import 'market_data_service.dart';

class SwapService {
  static const double _swapFeePercent = 0.0;

  static final List<SwapTransaction> _swaps =
  <SwapTransaction>[];

  static bool _initialized = false;

  static bool _marketRatesLoaded = false;

  static Map<String, double> _usdRates =
  <String, double>{};

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

  // ==========================================================
  // INITIALIZE
  // ==========================================================

  static Future<void> initialize() async {
    if (_initialized &&
        _marketRatesLoaded) {
      return;
    }

    try {
      await _loadMarketRates();

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

      for (
      final dynamic item
      in swapsData
      ) {
        if (item
        is Map<String, dynamic>) {
          _swaps.add(
            _fromBackendMap(
              item,
            ),
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

  // ==========================================================
  // LOAD LIVE MARKET RATES
  // ==========================================================

  static Future<void>
  _loadMarketRates() async {
    final Map<String, double>
    rates =
    await MarketDataService
        .getUsdRates();

    if (rates.isEmpty) {
      throw StateError(
        'Market rates could not be loaded.',
      );
    }

    const List<String>
    requiredCurrencies = [
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

    for (
    final String currency
    in requiredCurrencies
    ) {
      final double? rate =
      rates[currency];

      if (
      rate == null ||
          rate <= 0) {
        throw StateError(
          'Market rate unavailable for $currency.',
        );
      }
    }

    _usdRates =
    Map<String, double>.from(
      rates,
    );

    _marketRatesLoaded = true;
  }

  // ==========================================================
  // REFRESH
  // ==========================================================

  static Future<void> refresh() async {
    _initialized = false;

    _marketRatesLoaded = false;

    await initialize();
  }

  // ==========================================================
  // REFRESH MARKET RATES ONLY
  // ==========================================================

  static Future<void>
  refreshMarketRates() async {
    await _loadMarketRates();
  }

  // ==========================================================
  // GET EXCHANGE RATE
  //
  // _usdRates means:
  //
  // How many units of an asset equal 1 USD.
  //
  // Example:
  //
  // BTC = 1 / 83318.25
  // INR = 96.18
  //
  // BTC -> INR:
  //
  // INR rate / BTC rate
  // ==========================================================

  static double getExchangeRate({
    required String fromCurrency,
    required String toCurrency,
  }) {
    final String from =
    fromCurrency.toUpperCase();

    final String to =
    toCurrency.toUpperCase();

    if (!_marketRatesLoaded) {
      throw StateError(
        'Market rates are not loaded yet.',
      );
    }

    final double? fromRate =
    _usdRates[from];

    final double? toRate =
    _usdRates[to];

    if (fromRate == null ||
        fromRate <= 0) {
      throw StateError(
        'Unsupported source currency: $from',
      );
    }

    if (toRate == null ||
        toRate <= 0) {
      throw StateError(
        'Unsupported destination currency: $to',
      );
    }

    return toRate / fromRate;
  }

  // ==========================================================
  // CALCULATE RECEIVED AMOUNT
  // ==========================================================

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
      fromCurrency:
      fromCurrency,
      toCurrency:
      toCurrency,
    );

    final double fee =
    calculateFee(
      fromAmount,
    );

    final double amountAfterFee =
        fromAmount - fee;

    return amountAfterFee *
        rate;
  }

  // ==========================================================
  // FEE
  // ==========================================================

  static double calculateFee(
      double amount,
      ) {
    if (amount <= 0) {
      return 0;
    }

    return amount *
        (_swapFeePercent / 100);
  }

  // ==========================================================
  // USD VALUE
  // ==========================================================

  static double getUsdValue({
    required double amount,
    required String currency,
  }) {
    if (!_marketRatesLoaded) {
      throw StateError(
        'Market rates are not loaded yet.',
      );
    }

    final double? rate =
    _usdRates[
    currency.toUpperCase()
    ];

    if (rate == null ||
        rate <= 0) {
      throw StateError(
        'Unsupported currency: '
            '${currency.toUpperCase()}',
      );
    }

    return amount / rate;
  }

  // ==========================================================
  // MAX SWAP AMOUNT
  // ==========================================================

  static double getMaxSwapAmountUsd({
    required double totalUsdBalance,
  }) {
    if (totalUsdBalance <= 0) {
      return 0;
    }

    return totalUsdBalance;
  }

  // ==========================================================
  // CREATE SWAP
  // ==========================================================

  static Future<SwapTransaction>
  createSwap({
    required String fromCurrency,
    required String fromNetwork,
    required String toCurrency,
    required String toNetwork,
    required double fromAmount,
  }) async {
    // Make sure live market rates exist.
    await initialize();

    final String from =
    fromCurrency.toUpperCase();

    final String to =
    toCurrency.toUpperCase();

    if (!_usdRates.containsKey(
      from,
    )) {
      throw StateError(
        'Unsupported source currency: $from',
      );
    }

    if (!_usdRates.containsKey(
      to,
    )) {
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

    if (!networks.contains(
      fromNetwork,
    )) {
      throw StateError(
        'Unsupported source network: '
            '$fromNetwork',
      );
    }

    if (!networks.contains(
      toNetwork,
    )) {
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

    // --------------------------------------------------------
    // Calculate the preview using the same live rates.
    // Backend will independently calculate again.
    // --------------------------------------------------------

    final double rate =
    getExchangeRate(
      fromCurrency: from,
      toCurrency: to,
    );

    final double fee =
    calculateFee(
      fromAmount,
    );

    final double received =
    calculateReceivedAmount(
      fromAmount: fromAmount,
      fromCurrency: from,
      toCurrency: to,
    );

    // --------------------------------------------------------
    // Backend only needs the source amount.
    //
    // Do not send toAmount/rate as authoritative values.
    // Backend calculates them itself.
    // --------------------------------------------------------

    final response =
    await ApiService.post(
      '/swaps',
      {
        'fromAsset': from,
        'fromNetwork':
        fromNetwork,
        'toAsset': to,
        'toNetwork':
        toNetwork,
        'fromAmount':
        fromAmount,
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

    final double
    backendFromAmount =
    _toDouble(
      swapData['fromAmount'],
    );

    final double
    backendToAmount =
    _toDouble(
      swapData['toAmount'],
    );

    final double backendRate =
    _toDouble(
      swapData['rate'],
    );

    final SwapTransaction swap =
    SwapTransaction(
      id:
      swapData['swapId']
          ?.toString() ??
          swapData['_id']
              ?.toString() ??
          'SWAP-${DateTime.now().millisecondsSinceEpoch}',

      fromCurrency:
      swapData['fromAsset']
          ?.toString() ??
          from,

      fromNetwork:
      swapData['fromNetwork']
          ?.toString() ??
          fromNetwork,

      toCurrency:
      swapData['toAsset']
          ?.toString() ??
          to,

      toNetwork:
      swapData['toNetwork']
          ?.toString() ??
          toNetwork,

      fromAmount:
      backendFromAmount > 0
          ? backendFromAmount
          : fromAmount,

      toAmount:
      backendToAmount > 0
          ? backendToAmount
          : received,

      exchangeRate:
      backendRate > 0
          ? backendRate
          : rate,

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

  // ==========================================================
  // GET SWAPS
  // ==========================================================

  static Future<
      List<SwapTransaction>>
  getSwaps() async {
    await _refreshFromBackend();

    return List<
        SwapTransaction>.unmodifiable(
      _swaps,
    );
  }

  // ==========================================================
  // RECENT SWAPS
  // ==========================================================

  static Future<
      List<SwapTransaction>>
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

    return List<
        SwapTransaction>.unmodifiable(
      _swaps
          .take(count)
          .toList(),
    );
  }

  // ==========================================================
  // GET ONE SWAP
  // ==========================================================

  static Future<
      SwapTransaction?>
  getSwap(
      String id,
      ) async {
    await _refreshFromBackend();

    try {
      return _swaps.firstWhere(
            (
            SwapTransaction swap,
            ) =>
        swap.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  // ==========================================================
  // DELETE LOCAL HISTORY ITEM
  // ==========================================================

  static Future<void> deleteSwap(
      String id,
      ) async {
    _swaps.removeWhere(
          (
          SwapTransaction swap,
          ) =>
      swap.id == id,
    );
  }

  // ==========================================================
  // CLEAR LOCAL HISTORY
  // ==========================================================

  static Future<void>
  clearHistory() async {
    _swaps.clear();
  }

  // ==========================================================
  // REFRESH SWAPS FROM BACKEND
  // ==========================================================

  static Future<void>
  _refreshFromBackend() async {
    try {
      final response =
      await ApiService.get(
        '/swaps',
      );

      if (response['success'] !=
          true) {
        return;
      }

      final List<dynamic>
      swapsData =
          response['swaps'] ?? [];

      _swaps.clear();

      for (
      final dynamic item
      in swapsData
      ) {
        if (item
        is Map<String, dynamic>) {
          _swaps.add(
            _fromBackendMap(
              item,
            ),
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

  // ==========================================================
  // BACKEND MAP -> MODEL
  // ==========================================================

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

  // ==========================================================
  // STATUS
  // ==========================================================

  static String _convertStatus(
      String status,
      ) {
    switch (
    status.toLowerCase()) {
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

  // ==========================================================
  // DOUBLE PARSER
  // ==========================================================

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

  // ==========================================================
  // DATE PARSER
  // ==========================================================

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

  // ==========================================================
  // SORT
  // ==========================================================

  static void _sortSwaps() {
    _swaps.sort(
          (
          SwapTransaction a,
          SwapTransaction b,
          ) {
        return b.timestamp
            .compareTo(
          a.timestamp,
        );
      },
    );
  }
}