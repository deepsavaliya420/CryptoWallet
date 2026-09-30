import '../models/asset.dart';
import 'api_service.dart';
import 'market_data_service.dart';

class WalletService {
  // ============================================================
  // DEFAULT BALANCES
  // ============================================================

  static const Map<String, double> _defaultBalances = {
    'ETH': 0.82,
    'USDT': 250.0,
    'SOL': 1.50,
    'TRX': 12.0,

    // Fiat
    'USD': 0.0,
    'INR': 0.0,
    'EUR': 0.0,
    'GBP': 0.0,
    'AED': 0.0,
    'JPY': 0.0,

    // Crypto
    'USDC': 0.0,
    'BTC': 0.0,
  };

  // ============================================================
  // FIAT EXCHANGE RATES
  // ============================================================

  static const Map<String, double> currencyRates = {
    'USD': 1.0,
    'INR': 83.50,
    'EUR': 0.92,
    'GBP': 0.79,
    'AED': 3.6725,
    'JPY': 157.0,
  };

  // ============================================================
  // LIVE CRYPTO USD RATES
  // ============================================================

  static final Map<String, double> _cryptoUsdRates = {};

  static bool _marketRatesLoaded = false;

  // ============================================================
  // CURRENCY INFORMATION
  // ============================================================

  static const Map<String, String> _names = {
    'USD': 'US Dollar',
    'INR': 'Indian Rupee',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'AED': 'UAE Dirham',
    'JPY': 'Japanese Yen',
    'USDT': 'Tether',
    'USDC': 'USD Coin',
    'BTC': 'Bitcoin',
    'ETH': 'Ethereum',
    'SOL': 'Solana',
    'TRX': 'TRON',
  };

  static const Map<String, String> _networks = {
    'USD': 'Fiat',
    'INR': 'Fiat',
    'EUR': 'Fiat',
    'GBP': 'Fiat',
    'AED': 'Fiat',
    'JPY': 'Fiat',
    'USDT': 'TRON',
    'USDC': 'ERC-20',
    'BTC': 'Bitcoin',
    'ETH': 'Ethereum',
    'SOL': 'Solana',
    'TRX': 'TRON',
  };

  // ============================================================
  // HOME TOTAL BALANCE
  // ============================================================

  static const Set<String> _homeBalanceCurrencies = {
    'USD',
    'ETH',
    'USDT',
    'USDC',
    'SOL',
    'TRX',
    'BTC',
  };

  // ============================================================
  // INTERNAL
  // ============================================================

  static final Map<String, double> _balances =
  <String, double>{};

  static final List<Asset> _assets =
  <Asset>[];

  static bool _initialized = false;

  // ============================================================
  // RESET SESSION
  // ============================================================

  static void resetSession() {
    _balances.clear();
    _assets.clear();

    _marketRatesLoaded = false;

    _initialized = false;
  }

  // ============================================================
  // INITIALIZE
  // ============================================================

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    try {
      final response = await ApiService.get(
        '/wallet',
      );

      if (response['success'] != true ||
          response['wallet'] == null) {
        throw StateError(
          'Wallet could not be loaded.',
        );
      }

      final Map<String, dynamic> wallet =
      Map<String, dynamic>.from(
        response['wallet'],
      );

      final dynamic balancesData =
      wallet['balances'];

      _balances.clear();

      for (final String currency
      in _defaultBalances.keys) {
        double value =
            _defaultBalances[currency] ?? 0.0;

        if (balancesData is Map) {
          final dynamic backendValue =
          balancesData[currency];

          if (backendValue != null) {
            value = _toDouble(
              backendValue,
            );
          }
        }

        _balances[currency] = value;
      }

      // --------------------------------------------------------
      // IMPORTANT:
      // Market-price failure must NOT destroy wallet loading.
      // --------------------------------------------------------

      try {
        await _loadMarketRates();
      } catch (error) {
        _marketRatesLoaded =
            _cryptoUsdRates.isNotEmpty;

        // Wallet balances were loaded successfully.
        // Do not rethrow the market API error.
      }

      _initialized = true;

      _syncAssets();
    } catch (e) {
      _initialized = false;
      rethrow;
    }
  }

  // ============================================================
  // LOAD LIVE MARKET RATES
  // ============================================================

  static Future<void> _loadMarketRates() async {
    final Map<String, double?> rates =
    await MarketDataService.getCryptoRates();

    final Map<String, double> newRates =
    <String, double>{};

    for (final MapEntry<String, double?> entry
    in rates.entries) {
      final double? value = entry.value;

      if (value != null && value > 0) {
        newRates[entry.key] = value;
      }
    }

    // Only replace existing rates if the response
    // actually contains usable rates.
    if (newRates.isNotEmpty) {
      _cryptoUsdRates
        ..clear()
        ..addAll(newRates);

      _marketRatesLoaded = true;
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  static Future<void> refresh() async {
    resetSession();

    await initialize();
  }

  // ============================================================
  // REFRESH MARKET RATES ONLY
  // ============================================================

  static Future<void> refreshMarketRates() async {
    try {
      await _loadMarketRates();
    } catch (_) {
      // Keep the last successful rates.
    }

    if (_initialized) {
      _syncAssets();
    }
  }

  // ============================================================
  // TOTAL HOME BALANCE
  // ============================================================

  static Future<double> getTotalBalance() async {
    await initialize();

    double total = 0.0;

    for (final String currency
    in _homeBalanceCurrencies) {
      final double amount =
          _balances[currency] ?? 0.0;

      if (amount <= 0) {
        continue;
      }

      // If a live rate is temporarily unavailable,
      // do not crash the entire wallet.
      if (_isCrypto(currency) &&
          !_cryptoUsdRates.containsKey(currency)) {
        continue;
      }

      total += _convertToUsd(
        amount: amount,
        currency: currency,
      );
    }

    return total;
  }

  // ============================================================
  // GET CURRENCY BALANCE
  // ============================================================

  static Future<double> getCurrencyBalance(
      String currency,
      ) async {
    await initialize();

    final String normalized =
    currency.trim().toUpperCase();

    _validateCurrency(normalized);

    if (normalized == 'USD') {
      return getTotalBalance();
    }

    return _balances[normalized] ?? 0.0;
  }

  // ============================================================
  // USDT
  // ============================================================

  static Future<double> getUSDTBalance() async {
    await initialize();

    return _balances['USDT'] ?? 0.0;
  }

  static Future<void> addUSDT(
      double amount,
      ) async {
    await addCurrency(
      currency: 'USDT',
      amount: amount,
    );
  }

  static Future<void> subtractUSDT(
      double amount,
      ) async {
    await subtractCurrency(
      currency: 'USDT',
      amount: amount,
    );
  }

  // ============================================================
  // INR
  // ============================================================

  static Future<double> getINRBalance() async {
    await initialize();

    return _balances['INR'] ?? 0.0;
  }

  // ============================================================
  // ADD CURRENCY
  // ============================================================

  static Future<void> addCurrency({
    required String currency,
    required double amount,
  }) async {
    await initialize();

    final String normalized =
    currency.trim().toUpperCase();

    _validateCurrency(normalized);

    if (amount <= 0) {
      throw StateError(
        'Amount must be greater than zero.',
      );
    }

    final double current =
        _balances[normalized] ?? 0.0;

    final double newBalance =
        current + amount;

    await _updateBackendBalance(
      normalized,
      newBalance,
    );

    _balances[normalized] =
        newBalance;

    _syncAssets();
  }

  // ============================================================
  // SUBTRACT CURRENCY
  // ============================================================

  static Future<void> subtractCurrency({
    required String currency,
    required double amount,
  }) async {
    await initialize();

    final String normalized =
    currency.trim().toUpperCase();

    _validateCurrency(normalized);

    if (amount <= 0) {
      throw StateError(
        'Amount must be greater than zero.',
      );
    }

    final double current =
        _balances[normalized] ?? 0.0;

    if (amount >
        current + 0.00000001) {
      throw StateError(
        'Insufficient $normalized balance. '
            'Available: '
            '${current.toStringAsFixed(8)} $normalized',
      );
    }

    final double newBalance =
    (current - amount).clamp(
      0.0,
      double.infinity,
    );

    await _updateBackendBalance(
      normalized,
      newBalance,
    );

    _balances[normalized] =
        newBalance;

    _syncAssets();
  }

  // ============================================================
  // SEND USD
  // ============================================================

  static Future<void> sendUsd(
      double usdAmount,
      ) async {
    await initialize();

    if (usdAmount <= 0) {
      throw StateError(
        'USD amount must be greater than zero.',
      );
    }

    final double total =
    await getTotalBalance();

    if (usdAmount >
        total + 0.00000001) {
      throw StateError(
        'Insufficient wallet balance. '
            'Available: '
            '\$${total.toStringAsFixed(2)}',
      );
    }

    final Map<String, double> oldBalances =
    Map<String, double>.from(
      _balances,
    );

    try {
      await _removeUsdValueFromPortfolio(
        usdAmount,
      );

      await _saveAllBalances();

      _syncAssets();
    } catch (e) {
      _balances
        ..clear()
        ..addAll(oldBalances);

      _syncAssets();

      rethrow;
    }
  }

  // ============================================================
  // TRANSFER USD
  // ============================================================

  static Future<void> transferUsd({
    required String recipientAddress,
    required double amount,
  }) async {
    await initialize();

    final String normalizedAddress =
    recipientAddress.trim();

    if (normalizedAddress.isEmpty) {
      throw StateError(
        'Recipient wallet address is required.',
      );
    }

    if (amount <= 0) {
      throw StateError(
        'USD amount must be greater than zero.',
      );
    }

    final double total =
    await getTotalBalance();

    if (amount >
        total + 0.00000001) {
      throw StateError(
        'Insufficient wallet balance. '
            'Available: '
            '\$${total.toStringAsFixed(2)}',
      );
    }

    final response = await ApiService.put(
      '/wallet/transfer',
      {
        'recipientAddress':
        normalizedAddress,
        'amount': amount,
      },
    );

    if (response['success'] != true) {
      throw StateError(
        response['message']?.toString() ??
            'Transfer failed.',
      );
    }

    resetSession();

    await initialize();
  }

  // ============================================================
  // RECEIVE USD
  // ============================================================

  static Future<void> receiveUsd(
      double usdAmount,
      ) async {
    await initialize();

    if (usdAmount <= 0) {
      throw StateError(
        'USD amount must be greater than zero.',
      );
    }

    await addCurrency(
      currency: 'USDT',
      amount: usdAmount,
    );
  }

  // ============================================================
  // COMPATIBILITY
  // ============================================================

  static Future<void> subtractUsdValue(
      double usdAmount,
      ) async {
    await sendUsd(
      usdAmount,
    );
  }

  static Future<void> addUsdValue(
      double usdAmount,
      ) async {
    await receiveUsd(
      usdAmount,
    );
  }

  // ============================================================
  // SUBTRACT CURRENCY BY USD VALUE
  // ============================================================

  static Future<void>
  subtractCurrencyByUsdValue({
    required String currency,
    required double usdValue,
  }) async {
    await initialize();

    if (usdValue <= 0) {
      throw StateError(
        'USD value must be greater than zero.',
      );
    }

    final String normalized =
    currency.trim().toUpperCase();

    _validateCurrency(normalized);

    if (normalized == 'USD') {
      await _removeUsdValueFromPortfolio(
        usdValue,
      );

      await _saveAllBalances();

      _syncAssets();

      return;
    }

    final double amount =
    _convertFromUsd(
      usdAmount: usdValue,
      currency: normalized,
    );

    await subtractCurrency(
      currency: normalized,
      amount: amount,
    );
  }

  // ============================================================
  // P2P
  // ============================================================

  static Future<void>
  addP2PPurchasedCrypto({
    required String asset,
    required double amount,
  }) async {
    await addCurrency(
      currency: asset,
      amount: amount,
    );
  }

  // ============================================================
  // SET BALANCE
  // ============================================================

  static Future<void> setCurrencyBalance({
    required String currency,
    required double amount,
  }) async {
    await initialize();

    final String normalized =
    currency.trim().toUpperCase();

    _validateCurrency(normalized);

    if (amount < 0) {
      throw StateError(
        'Balance cannot be negative.',
      );
    }

    await _updateBackendBalance(
      normalized,
      amount,
    );

    _balances[normalized] =
        amount;

    _syncAssets();
  }

  // ============================================================
  // GET ASSETS
  // ============================================================

  static Future<List<Asset>> getAssets() async {
    await initialize();

    _syncAssets();

    return List<Asset>.unmodifiable(
      _assets,
    );
  }

  // ============================================================
  // GET ONE ASSET
  // ============================================================

  static Future<Asset?> getAsset(
      String symbol,
      ) async {
    await initialize();

    final String normalized =
    symbol.trim().toUpperCase();

    _syncAssets();

    try {
      return _assets.firstWhere(
            (Asset asset) =>
        asset.symbol.toUpperCase() ==
            normalized,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // USD CONVERSION
  // ============================================================

  static double toUsdValue({
    required double amount,
    required String currency,
  }) {
    final String normalized =
    currency.trim().toUpperCase();

    return _convertToUsd(
      amount: amount,
      currency: normalized,
    );
  }

  static double _convertToUsd({
    required double amount,
    required String currency,
  }) {
    if (currency == 'USD') {
      return amount;
    }

    if (_isCrypto(currency)) {
      final double? usdRate =
      _cryptoUsdRates[currency];

      if (usdRate == null ||
          usdRate <= 0) {
        throw StateError(
          'Live market price unavailable for $currency.',
        );
      }

      return amount * usdRate;
    }

    final double? rate =
    currencyRates[currency];

    if (rate == null ||
        rate <= 0) {
      throw StateError(
        'Unsupported currency: $currency',
      );
    }

    return amount / rate;
  }

  // ============================================================
  // USD → CURRENCY
  // ============================================================

  static double _convertFromUsd({
    required double usdAmount,
    required String currency,
  }) {
    if (currency == 'USD') {
      return usdAmount;
    }

    if (_isCrypto(currency)) {
      final double? usdRate =
      _cryptoUsdRates[currency];

      if (usdRate == null ||
          usdRate <= 0) {
        throw StateError(
          'Live market price unavailable for $currency.',
        );
      }

      return usdAmount / usdRate;
    }

    final double? rate =
    currencyRates[currency];

    if (rate == null ||
        rate <= 0) {
      throw StateError(
        'Unsupported currency: $currency',
      );
    }

    return usdAmount * rate;
  }

  // ============================================================
  // CHECK CRYPTO
  // ============================================================

  static bool _isCrypto(
      String currency,
      ) {
    return const {
      'BTC',
      'ETH',
      'SOL',
      'TRX',
      'USDT',
      'USDC',
    }.contains(currency);
  }

  // ============================================================
  // REMOVE USD VALUE
  // ============================================================

  static Future<void>
  _removeUsdValueFromPortfolio(
      double usdAmount,
      ) async {
    double remainingUsd =
        usdAmount;

    final double currentUsd =
        _balances['USD'] ?? 0.0;

    if (currentUsd > 0) {
      final double removeUsd =
      currentUsd < remainingUsd
          ? currentUsd
          : remainingUsd;

      _balances['USD'] =
          currentUsd - removeUsd;

      remainingUsd -=
          removeUsd;
    }

    const List<String> sourceAssets = [
      'ETH',
      'USDT',
      'USDC',
      'SOL',
      'TRX',
      'BTC',
    ];

    for (final String asset
    in sourceAssets) {
      if (remainingUsd <=
          0.00000001) {
        break;
      }

      final double current =
          _balances[asset] ?? 0.0;

      if (current <= 0) {
        continue;
      }

      final double assetUsd =
      _convertToUsd(
        amount: current,
        currency: asset,
      );

      if (assetUsd <= 0) {
        continue;
      }

      final double removeUsd =
      assetUsd < remainingUsd
          ? assetUsd
          : remainingUsd;

      final double removeAmount =
      _convertFromUsd(
        usdAmount: removeUsd,
        currency: asset,
      );

      double newAmount =
          current - removeAmount;

      if (newAmount < 0) {
        newAmount = 0.0;
      }

      _balances[asset] =
          newAmount;

      remainingUsd -=
          removeUsd;
    }

    if (remainingUsd >
        0.00000001) {
      throw StateError(
        'Unable to deduct \$'
            '${usdAmount.toStringAsFixed(2)} '
            'from wallet.',
      );
    }
  }

  // ============================================================
  // UPDATE ONE BACKEND BALANCE
  // ============================================================

  static Future<void>
  _updateBackendBalance(
      String currency,
      double amount,
      ) async {
    final response =
    await ApiService.put(
      '/wallet/balance',
      {
        'asset': currency,
        'amount': amount,
      },
    );

    if (response['success'] != true) {
      throw StateError(
        response['message']?.toString() ??
            'Wallet balance update failed.',
      );
    }
  }

  // ============================================================
  // SAVE ALL BALANCES
  // ============================================================

  static Future<void> _saveAllBalances() async {
    final Map<String, double> backup =
    Map<String, double>.from(
      _balances,
    );

    try {
      for (final MapEntry<String, double>
      entry in _balances.entries) {
        await _updateBackendBalance(
          entry.key,
          entry.value,
        );
      }
    } catch (e) {
      _balances
        ..clear()
        ..addAll(backup);

      rethrow;
    }
  }

  // ============================================================
  // VALIDATE
  // ============================================================

  static void _validateCurrency(
      String currency,
      ) {
    const Set<String> supportedCurrencies = {
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
    };

    if (!supportedCurrencies.contains(
      currency,
    )) {
      throw StateError(
        'Unsupported currency: $currency',
      );
    }
  }

  // ============================================================
  // SYNC ALL ASSETS
  // ============================================================

  static void _syncAssets() {
    _assets.clear();

    const List<String> order = [
      'USD',
      'INR',
      'EUR',
      'GBP',
      'AED',
      'JPY',
      'BTC',
      'ETH',
      'USDT',
      'USDC',
      'SOL',
      'TRX',
    ];

    for (final String symbol
    in order) {
      final double amount =
          _balances[symbol] ?? 0.0;

      if (amount <=
          0.0000000001) {
        continue;
      }

      // Do not let one unavailable market price
      // crash the entire wallet.
      if (_isCrypto(symbol) &&
          !_cryptoUsdRates.containsKey(symbol)) {
        continue;
      }

      final double usdValue =
      _convertToUsd(
        amount: amount,
        currency: symbol,
      );

      _assets.add(
        Asset(
          symbol: symbol,
          name:
          _names[symbol] ?? symbol,
          network:
          _networks[symbol] ?? 'Wallet',
          amount:
          '${_formatAmount(amount)} $symbol',
          value:
          '\$${usdValue.toStringAsFixed(2)}',
          change:
          _changeFor(symbol),
          isPositive:
          _isPositiveFor(symbol),
        ),
      );
    }
  }

  // ============================================================
  // DEMO CHANGE VALUES
  // ============================================================

  static String _changeFor(
      String symbol,
      ) {
    switch (symbol) {
      case 'ETH':
        return '+4.82%';

      case 'USDT':
        return '+0.02%';

      case 'SOL':
        return '+2.41%';

      case 'TRX':
        return '-1.24%';

      case 'BTC':
        return '+3.15%';

      case 'USDC':
        return '+0.01%';

      default:
        return '0.00%';
    }
  }

  static bool _isPositiveFor(
      String symbol,
      ) {
    return symbol != 'TRX';
  }

  // ============================================================
  // FORMAT
  // ============================================================

  static String _formatAmount(
      double amount,
      ) {
    if (amount == 0) {
      return '0';
    }

    if (amount.abs() >= 1000) {
      return amount.toStringAsFixed(2);
    }

    if (amount.abs() >= 1) {
      return amount.toStringAsFixed(4);
    }

    return amount.toStringAsFixed(8);
  }

  // ============================================================
  // NUMBER PARSER
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
  // RESET FOR TESTING
  // ============================================================

  static Future<void>
  resetWalletForTesting() async {
    for (final MapEntry<String, double>
    entry in _defaultBalances.entries) {
      await _updateBackendBalance(
        entry.key,
        entry.value,
      );
    }

    _balances
      ..clear()
      ..addAll(
        _defaultBalances,
      );

    _assets.clear();

    try {
      await _loadMarketRates();
    } catch (_) {
      // Keep any previously successful rates.
    }

    _initialized = true;

    _syncAssets();
  }
}