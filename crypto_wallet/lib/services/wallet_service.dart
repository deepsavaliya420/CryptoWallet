import 'package:shared_preferences/shared_preferences.dart';

import '../models/asset.dart';

class WalletService {
  // ============================================================
  // STORAGE
  // ============================================================

  static const String _balancePrefix =
      'wallet_balance_';

  static const String _legacyUsdtKey =
      'wallet_usdt_amount';

  // ============================================================
  // DEFAULT BALANCES
  // ============================================================

  static const Map<String, double>
  _defaultBalances = {
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
  // DEMO EXCHANGE RATES
  //
  // 1 USD = rate units of the currency.
  // ============================================================

  static const Map<String, double>
  currencyRates = {
    'USD': 1.0,

    'USDT': 1.0,
    'USDC': 1.0,

    'INR': 83.50,
    'EUR': 0.92,
    'GBP': 0.79,
    'AED': 3.6725,
    'JPY': 157.0,

    'BTC': 0.0000105,
    'ETH': 0.00030,
    'SOL': 0.00680,
    'TRX': 12.0,
  };

  // ============================================================
  // CURRENCY INFORMATION
  // ============================================================

  static const Map<String, String>
  _names = {
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

  static const Map<String, String>
  _networks = {
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
  //
  // INR/EUR/GBP/AED/JPY are NOT counted in Home total.
  //
  // USD IS counted because USD received through an internal
  // reverse swap becomes an actual USD wallet balance.
  // ============================================================

  static const Set<String>
  _homeBalanceCurrencies = {
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

  static final Map<String, double>
  _balances = <String, double>{};

  static final List<Asset>
  _assets = <Asset>[];

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

    _balances.clear();

    for (final MapEntry<String, double>
    entry in _defaultBalances.entries) {
      final String currency = entry.key;

      final double defaultValue =
          entry.value;

      double savedValue =
          prefs.getDouble(
            '$_balancePrefix$currency',
          ) ??
              defaultValue;

      // Backward compatibility
      if (currency == 'USDT') {
        savedValue =
            prefs.getDouble(
              '$_balancePrefix$currency',
            ) ??
                prefs.getDouble(
                  _legacyUsdtKey,
                ) ??
                defaultValue;
      }

      _balances[currency] =
          savedValue;
    }

    _initialized = true;

    _syncAssets();
  }

  // ============================================================
  // TOTAL HOME BALANCE
  // ============================================================

  static Future<double>
  getTotalBalance() async {
    await initialize();

    double total = 0.0;

    for (final String currency
    in _homeBalanceCurrencies) {
      final double amount =
          _balances[currency] ?? 0.0;

      if (amount <= 0) {
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

  static Future<double>
  getCurrencyBalance(
      String currency,
      ) async {
    await initialize();

    final String normalized =
    currency.trim().toUpperCase();

    _validateCurrency(normalized);

    // USD represents the total USD-valued wallet
    // when selecting USD as source currency.
    if (normalized == 'USD') {
      return getTotalBalance();
    }

    return _balances[normalized] ?? 0.0;
  }

  // ============================================================
  // USDT
  // ============================================================

  static Future<double>
  getUSDTBalance() async {
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

  static Future<double>
  getINRBalance() async {
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

    _balances[normalized] =
        current + amount;

    await _saveCurrency(
      normalized,
    );

    _syncAssets();
  }

  // ============================================================
  // SUBTRACT CURRENCY
  // ============================================================

  static Future<void>
  subtractCurrency({
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
    (current - amount)
        .clamp(
      0.0,
      double.infinity,
    );

    _balances[normalized] =
        newBalance;

    await _saveCurrency(
      normalized,
    );

    _syncAssets();
  }

  // ============================================================
  // SEND USD
  //
  // IMPORTANT:
  //
  // If actual USD exists, remove USD first.
  //
  // Otherwise remove USD value from crypto portfolio.
  // ============================================================

  static Future<void>
  sendUsd(
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

    await _removeUsdValueFromPortfolio(
      usdAmount,
    );

    await _saveAllBalances();

    _syncAssets();
  }

  // ============================================================
  // RECEIVE USD
  //
  // Keep existing behavior:
  // received USD becomes USDT.
  // ============================================================

  static Future<void>
  receiveUsd(
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

  static Future<void>
  subtractUsdValue(
      double usdAmount,
      ) async {
    await sendUsd(
      usdAmount,
    );
  }

  static Future<void>
  addUsdValue(
      double usdAmount,
      ) async {
    await receiveUsd(
      usdAmount,
    );
  }

  // ============================================================
  // SUBTRACT CURRENCY BY USD VALUE
  //
  // Used by SwapScreen.
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

    // USD source:
    // remove USD value from actual USD first,
    // then crypto portfolio if necessary.
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

  static Future<void>
  setCurrencyBalance({
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

    _balances[normalized] =
        amount;

    await _saveCurrency(
      normalized,
    );

    _syncAssets();
  }

  // ============================================================
  // GET ASSETS
  // ============================================================

  static Future<List<Asset>>
  getAssets() async {
    await initialize();

    _syncAssets();

    return List<Asset>.unmodifiable(
      _assets,
    );
  }

  // ============================================================
  // GET ONE ASSET
  // ============================================================

  static Future<Asset?>
  getAsset(
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

  static double
  toUsdValue({
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
    final double? rate =
    currencyRates[currency];

    if (rate == null) {
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
    final double? rate =
    currencyRates[currency];

    if (rate == null) {
      throw StateError(
        'Unsupported currency: $currency',
      );
    }

    return usdAmount * rate;
  }

  // ============================================================
  // REMOVE USD VALUE FROM WALLET
  //
  // PRIORITY:
  //
  // 1. Actual USD balance
  // 2. ETH
  // 3. USDT
  // 4. USDC
  // 5. SOL
  // 6. TRX
  // 7. BTC
  //
  // This fixes:
  //
  // INR → USD → another USD transaction
  //
  // where previously the USD balance was ignored.
  // ============================================================

  static Future<void>
  _removeUsdValueFromPortfolio(
      double usdAmount,
      ) async {
    double remainingUsd =
        usdAmount;

    // ------------------------------------------------------------
    // FIRST: ACTUAL USD
    // ------------------------------------------------------------

    final double currentUsd =
        _balances['USD'] ?? 0.0;

    if (currentUsd > 0) {
      final double removeUsd =
      currentUsd < remainingUsd
          ? currentUsd
          : remainingUsd;

      _balances['USD'] =
          currentUsd - removeUsd;

      remainingUsd -= removeUsd;
    }

    // ------------------------------------------------------------
    // THEN CRYPTO PORTFOLIO
    // ------------------------------------------------------------

    const List<String>
    sourceAssets = [
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
  // SAVE ONE CURRENCY
  // ============================================================

  static Future<void>
  _saveCurrency(
      String currency,
      ) async {
    final SharedPreferences prefs =
    await SharedPreferences
        .getInstance();

    final double amount =
        _balances[currency] ?? 0.0;

    await prefs.setDouble(
      '$_balancePrefix$currency',
      amount,
    );

    if (currency == 'USDT') {
      await prefs.setDouble(
        _legacyUsdtKey,
        amount,
      );
    }
  }

  // ============================================================
  // SAVE ALL
  // ============================================================

  static Future<void>
  _saveAllBalances() async {
    final SharedPreferences prefs =
    await SharedPreferences
        .getInstance();

    for (final MapEntry<String, double>
    entry in _balances.entries) {
      await prefs.setDouble(
        '$_balancePrefix${entry.key}',
        entry.value,
      );
    }

    await prefs.setDouble(
      _legacyUsdtKey,
      _balances['USDT'] ?? 0.0,
    );
  }

  // ============================================================
  // VALIDATE
  // ============================================================

  static void _validateCurrency(
      String currency,
      ) {
    if (!currencyRates.containsKey(
      currency,
    )) {
      throw StateError(
        'Unsupported currency: $currency',
      );
    }
  }

  // ============================================================
  // SYNC ALL ASSETS
  //
  // THIS IS THE MAIN ASSET FIX.
  //
  // Previously only:
  // ETH
  // USDT
  // SOL
  // TRX
  //
  // were synced.
  //
  // Now:
  // USD
  // INR
  // EUR
  // GBP
  // AED
  // JPY
  // BTC
  // USDC
  // ETH
  // USDT
  // SOL
  // TRX
  //
  // are synced.
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

      // Do not display zero assets.
      if (amount <= 0.0000000001) {
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
          change: _changeFor(
            symbol,
          ),
          isPositive:
          _isPositiveFor(
            symbol,
          ),
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
  // RESET FOR TESTING
  // ============================================================

  static Future<void>
  resetWalletForTesting() async {
    final SharedPreferences prefs =
    await SharedPreferences
        .getInstance();

    for (final String currency
    in _defaultBalances.keys) {
      await prefs.remove(
        '$_balancePrefix$currency',
      );
    }

    await prefs.remove(
      _legacyUsdtKey,
    );

    _balances.clear();
    _assets.clear();

    _initialized = false;

    await initialize();
  }
}