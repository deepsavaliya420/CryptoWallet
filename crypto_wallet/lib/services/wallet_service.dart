import 'package:shared_preferences/shared_preferences.dart';

import '../models/asset.dart';

class WalletService {
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

  static bool _initialized = false;

  // ============================================================
  // INITIALIZE
  // ============================================================

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    final prefs =
    await SharedPreferences.getInstance();

    final savedUsdt =
    prefs.getDouble('wallet_usdt_amount');

    if (savedUsdt != null) {
      _setUsdtAmountInMemory(savedUsdt);
    }

    _initialized = true;
  }

  // ============================================================
  // ASSETS
  // ============================================================

  static Future<List<Asset>> getAssets() async {
    await initialize();

    return List.unmodifiable(_assets);
  }

  static Future<Asset?> getAsset(
      String symbol,
      ) async {
    await initialize();

    try {
      return _assets.firstWhere(
            (asset) =>
        asset.symbol.toUpperCase() ==
            symbol.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // TOTAL BALANCE
  // ============================================================

  static Future<double> getTotalBalance() async {
    await initialize();

    double total = 0;

    for (final asset in _assets) {
      total += _valueOfAsset(asset);
    }

    return total;
  }

  static double _valueOfAsset(
      Asset asset,
      ) {
    final value = asset.value
        .replaceAll('\$', '')
        .replaceAll(',', '')
        .trim();

    return double.tryParse(value) ?? 0;
  }

  // ============================================================
  // USDT
  // ============================================================

  static Future<double> getUSDTBalance() async {
    await initialize();

    final usdt =
    await getAsset('USDT');

    if (usdt == null) {
      return 0;
    }

    return _extractAmount(
      usdt.amount,
    );
  }

  // ============================================================
  // ADD USDT
  // ============================================================

  static Future<void> addUSDT(
      double amount,
      ) async {
    if (amount <= 0) {
      throw StateError(
        'Amount must be greater than zero.',
      );
    }

    await initialize();

    final current =
    await getUSDTBalance();

    final newBalance =
        current + amount;

    await _updateUsdtBalance(
      newBalance,
    );
  }

  // ============================================================
  // SUBTRACT USDT
  // ============================================================

  static Future<void> subtractUSDT(
      double amount,
      ) async {
    if (amount <= 0) {
      throw StateError(
        'Amount must be greater than zero.',
      );
    }

    await initialize();

    final current =
    await getUSDTBalance();

    if (amount > current) {
      throw StateError(
        'Insufficient USDT balance.',
      );
    }

    final newBalance =
        current - amount;

    await _updateUsdtBalance(
      newBalance,
    );
  }

  // ============================================================
  // SET USDT
  // ============================================================

  static Future<void> setUSDTBalance(
      double amount,
      ) async {
    if (amount < 0) {
      throw StateError(
        'Balance cannot be negative.',
      );
    }

    await initialize();

    await _updateUsdtBalance(
      amount,
    );
  }

  // ============================================================
  // P2P PURCHASE
  // ============================================================

  static Future<void> addP2PPurchasedCrypto({
    required String asset,
    required double amount,
  }) async {
    if (amount <= 0) {
      return;
    }

    await initialize();

    final normalizedAsset =
    asset.toUpperCase();

    final index =
    _assets.indexWhere(
          (item) =>
      item.symbol.toUpperCase() ==
          normalizedAsset,
    );

    if (index == -1) {
      _assets.add(
        Asset(
          symbol: normalizedAsset,
          name:
          normalizedAsset == 'USDT'
              ? 'Tether'
              : normalizedAsset,
          network:
          normalizedAsset == 'USDT'
              ? 'TRON'
              : 'Unknown',
          amount:
          '${amount.toStringAsFixed(2)} '
              '$normalizedAsset',
          value:
          '\$${amount.toStringAsFixed(2)}',
          change: '+0.00%',
          isPositive: true,
        ),
      );

      await _saveAssetAmount(
        normalizedAsset,
        amount,
      );

      return;
    }

    final oldAsset =
    _assets[index];

    final oldAmount =
    _extractAmount(
      oldAsset.amount,
    );

    final newAmount =
        oldAmount + amount;

    _assets[index] = Asset(
      symbol: oldAsset.symbol,
      name: oldAsset.name,
      network: oldAsset.network,
      amount:
      '${newAmount.toStringAsFixed(2)} '
          '${oldAsset.symbol}',
      value:
      '\$${newAmount.toStringAsFixed(2)}',
      change: oldAsset.change,
      isPositive: oldAsset.isPositive,
    );

    await _saveAssetAmount(
      normalizedAsset,
      newAmount,
    );
  }

  // ============================================================
  // UPDATE USDT IN MEMORY + STORAGE
  // ============================================================

  static Future<void> _updateUsdtBalance(
      double amount,
      ) async {
    _setUsdtAmountInMemory(
      amount,
    );

    await _saveAssetAmount(
      'USDT',
      amount,
    );
  }

  static void _setUsdtAmountInMemory(
      double amount,
      ) {
    final index =
    _assets.indexWhere(
          (asset) =>
      asset.symbol.toUpperCase() ==
          'USDT',
    );

    if (index == -1) {
      _assets.add(
        Asset(
          symbol: 'USDT',
          name: 'Tether',
          network: 'TRON',
          amount:
          '${amount.toStringAsFixed(2)} USDT',
          value:
          '\$${amount.toStringAsFixed(2)}',
          change: '+0.02%',
          isPositive: true,
        ),
      );

      return;
    }

    final oldAsset =
    _assets[index];

    _assets[index] = Asset(
      symbol: oldAsset.symbol,
      name: oldAsset.name,
      network: oldAsset.network,
      amount:
      '${amount.toStringAsFixed(2)} USDT',
      value:
      '\$${amount.toStringAsFixed(2)}',
      change: oldAsset.change,
      isPositive: oldAsset.isPositive,
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static double _extractAmount(
      String amountText,
      ) {
    final value = amountText
        .split(' ')
        .first
        .replaceAll(',', '')
        .trim();

    return double.tryParse(value) ?? 0;
  }

  static Future<void> _saveAssetAmount(
      String asset,
      double amount,
      ) async {
    if (asset.toUpperCase() != 'USDT') {
      return;
    }

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setDouble(
      'wallet_usdt_amount',
      amount,
    );
  }
}