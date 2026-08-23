import 'package:shared_preferences/shared_preferences.dart';

import '../models/asset.dart';

class WalletService {
  // ============================================================
  // STORAGE KEYS
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

    // Direct USD balance.
    'USD': 0.0,

    // Fiat balances.
    'INR': 0.0,
    'EUR': 0.0,
    'GBP': 0.0,
    'AED': 0.0,
    'JPY': 0.0,

    // Other crypto.
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
  // HOME BALANCE CURRENCIES
  //
  // IMPORTANT:
  //
  // Home Total Balance counts ONLY these currencies.
  //
  // INR is intentionally NOT here.
  // EUR is intentionally NOT here.
  // GBP is intentionally NOT here.
  // AED is intentionally NOT here.
  // JPY is intentionally NOT here.
  //
  // Therefore:
  //
  // $3241
  // - $1000 swap
  // = $2241
  //
  // Even if INR becomes ₹83,500, Home remains $2241.
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
  // INTERNAL BALANCES
  // ============================================================

  static final Map<String, double>
  _balances = <String, double>{};

  static bool _initialized = false;

  // ============================================================
  // HOME ASSETS
  // ============================================================

  static final List<Asset> _assets = [
    const Asset(
      symbol: 'ETH',
      name: 'Ethereum',
      network: 'Ethereum',
      amount: '0.82 ETH',
      value: '\$2,009.00',
      change: '+4.82%',
      isPositive: true,
    ),
    const Asset(
      symbol: 'USDT',
      name: 'Tether',
      network: 'TRON',
      amount: '250 USDT',
      value: '\$250.00',
      change: '+0.02%',
      isPositive: true,
    ),
    const Asset(
      symbol: 'SOL',
      name: 'Solana',
      network: 'Solana',
      amount: '1.50 SOL',
      value: '\$277.50',
      change: '+2.41%',
      isPositive: true,
    ),
    const Asset(
      symbol: 'TRX',
      name: 'TRON',
      network: 'TRON',
      amount: '12 TRX',
      value: '\$3.84',
      change: '-1.24%',
      isPositive: false,
    ),
  ];

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
      final String currency =
          entry.key;

      final double defaultValue =
          entry.value;

      double savedValue =
          prefs.getDouble(
            '$_balancePrefix$currency',
          ) ??
              defaultValue;

      // Backward compatibility for
      // old USDT storage.
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
  //
  // THIS IS THE MOST IMPORTANT METHOD.
  //
  // INR DOES NOT ENTER THIS CALCULATION.
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

    _validateCurrency(
      normalized,
    );

    if (normalized == 'USD') {
      return getTotalBalance();
    }

    return _balances[normalized] ?? 0.0;
  }

  // ============================================================
  // GET USDT
  // ============================================================

  static Future<double>
  getUSDTBalance() async {
    await initialize();

    return _balances['USDT'] ?? 0.0;
  }

  // ============================================================
  // GET INR
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

    _validateCurrency(
      normalized,
    );

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

    _validateCurrency(
      normalized,
    );

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
  // ADD USDT
  // ============================================================

  static Future<void> addUSDT(
      double amount,
      ) async {
    await addCurrency(
      currency: 'USDT',
      amount: amount,
    );
  }

  // ============================================================
  // SUBTRACT USDT
  // ============================================================

  static Future<void> subtractUSDT(
      double amount,
      ) async {
    await subtractCurrency(
      currency: 'USDT',
      amount: amount,
    );
  }

  // ============================================================
  // SEND USD
  //
  // Example:
  //
  // Home = $3241
  // Send = $1000
  // Home = $2241
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

    if (total <= 0) {
      throw StateError(
        'Wallet balance is zero.',
      );
    }

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
  // USD received becomes USDT internally.
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

  // ============================================================
  // COMPATIBILITY
  // ============================================================

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
  // USED BY SWAP.
  //
  // USD -> INR:
  //
  // subtractCurrencyByUsdValue(
  //   currency: 'USD',
  //   usdValue: 1000,
  // )
  //
  // removes $1000 from Home balance.
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

    _validateCurrency(
      normalized,
    );

    // ----------------------------------------------------------
    // USD SOURCE
    // ----------------------------------------------------------

    if (normalized == 'USD') {
      await sendUsd(
        usdValue,
      );

      return;
    }

    // ----------------------------------------------------------
    // OTHER SOURCE CURRENCY
    // ----------------------------------------------------------

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
  // P2P PURCHASE
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

    _validateCurrency(
      normalized,
    );

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
  // GET ASSET
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
  // CONVERT TO USD
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
  // USD -> CURRENCY
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
  // REMOVE USD VALUE FROM PORTFOLIO
  //
  // THIS IS USED FOR SEND AND USD SWAP.
  //
  // INR IS NEVER TOUCHED HERE.
  // ============================================================

  static Future<void>
  _removeUsdValueFromPortfolio(
      double usdAmount,
      ) async {
    double remainingUsd =
        usdAmount;

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
  // SAVE ONE CURRENCY
  // ============================================================

  static Future<void>
  _saveCurrency(
      String currency,
      ) async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

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
  // SAVE EVERYTHING
  // ============================================================

  static Future<void>
  _saveAllBalances() async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

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
  // VALIDATE CURRENCY
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
  // SYNC ASSETS
  // ============================================================

  static void _syncAssets() {
    _updateAsset(
      symbol: 'ETH',
      name: 'Ethereum',
      network: 'Ethereum',
      change: '+4.82%',
      isPositive: true,
    );

    _updateAsset(
      symbol: 'USDT',
      name: 'Tether',
      network: 'TRON',
      change: '+0.02%',
      isPositive: true,
    );

    _updateAsset(
      symbol: 'SOL',
      name: 'Solana',
      network: 'Solana',
      change: '+2.41%',
      isPositive: true,
    );

    _updateAsset(
      symbol: 'TRX',
      name: 'TRON',
      network: 'TRON',
      change: '-1.24%',
      isPositive: false,
    );
  }

  // ============================================================
  // UPDATE ASSET
  // ============================================================

  static void _updateAsset({
    required String symbol,
    required String name,
    required String network,
    required String change,
    required bool isPositive,
  }) {
    final double amount =
        _balances[symbol] ?? 0.0;

    final double usdValue =
    _convertToUsd(
      amount: amount,
      currency: symbol,
    );

    final Asset updated =
    Asset(
      symbol: symbol,
      name: name,
      network: network,
      amount:
      '${_formatAmount(amount)} $symbol',
      value:
      '\$${usdValue.toStringAsFixed(2)}',
      change: change,
      isPositive: isPositive,
    );

    final int index =
    _assets.indexWhere(
          (Asset asset) =>
      asset.symbol.toUpperCase() ==
          symbol.toUpperCase(),
    );

    if (index == -1) {
      _assets.add(
        updated,
      );
    } else {
      _assets[index] =
          updated;
    }
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
      return amount.toStringAsFixed(
        2,
      );
    }

    if (amount.abs() >= 1) {
      return amount.toStringAsFixed(
        4,
      );
    }

    return amount.toStringAsFixed(
      8,
    );
  }

  // ============================================================
  // RESET WALLET FOR TESTING
  //
  // IMPORTANT:
  // Your previous code already changed the
  // SharedPreferences balances.
  //
  // Run this ONCE for a clean test, then remove
  // the call.
  // ============================================================

  static Future<void>
  resetWalletForTesting() async {
    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

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

    _initialized = false;

    await initialize();
  }
}