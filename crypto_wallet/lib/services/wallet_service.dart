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

  /// Initialize wallet and load saved balances.
  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    final savedUsdtAmount = prefs.getDouble('wallet_usdt_amount');

    if (savedUsdtAmount != null) {
      final index = _assets.indexWhere(
            (asset) => asset.symbol.toUpperCase() == 'USDT',
      );

      if (index != -1) {
        final oldAsset = _assets[index];

        _assets[index] = Asset(
          symbol: oldAsset.symbol,
          name: oldAsset.name,
          network: oldAsset.network,
          amount:
          '${savedUsdtAmount.toStringAsFixed(2)} USDT',
          value:
          '\$${savedUsdtAmount.toStringAsFixed(2)}',
          change: oldAsset.change,
          isPositive: oldAsset.isPositive,
        );
      }
    }

    _initialized = true;
  }

  /// Get all wallet assets.
  static Future<List<Asset>> getAssets() async {
    await initialize();

    return List.unmodifiable(_assets);
  }

  /// Get one asset by symbol.
  static Future<Asset?> getAsset(String symbol) async {
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

  /// Calculate total wallet balance.
  static Future<double> getTotalBalance() async {
    await initialize();

    double total = 0;

    for (final asset in _assets) {
      final cleanedValue = asset.value
          .replaceAll('\$', '')
          .replaceAll(',', '')
          .trim();

      total += double.tryParse(cleanedValue) ?? 0;
    }

    return total;
  }

  /// Add an asset.
  static Future<void> addAsset(Asset asset) async {
    await initialize();

    _assets.add(asset);
  }

  /// Remove an asset.
  static Future<void> removeAsset(String symbol) async {
    await initialize();

    _assets.removeWhere(
          (asset) =>
      asset.symbol.toUpperCase() ==
          symbol.toUpperCase(),
    );
  }

  /// Add purchased crypto from a successful P2P order.
  ///
  /// Example:
  /// Existing USDT = 250
  /// P2P purchase = 500
  /// New USDT = 750
  static Future<void> addP2PPurchasedCrypto({
    required String asset,
    required double amount,
  }) async {
    await initialize();

    final normalizedAsset = asset.toUpperCase();

    final index = _assets.indexWhere(
          (item) =>
      item.symbol.toUpperCase() == normalizedAsset,
    );

    if (index == -1) {
      _assets.add(
        Asset(
          symbol: normalizedAsset,
          name: normalizedAsset == 'USDT'
              ? 'Tether'
              : normalizedAsset,
          network: normalizedAsset == 'USDT'
              ? 'TRON'
              : 'Unknown',
          amount:
          '${amount.toStringAsFixed(2)} $normalizedAsset',
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

    final oldAsset = _assets[index];

    final oldAmount = _extractAmount(
      oldAsset.amount,
    );

    final newAmount = oldAmount + amount;

    _assets[index] = Asset(
      symbol: oldAsset.symbol,
      name: oldAsset.name,
      network: oldAsset.network,
      amount:
      '${newAmount.toStringAsFixed(2)} ${oldAsset.symbol}',
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

  static double _extractAmount(String amountText) {
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
    final prefs = await SharedPreferences.getInstance();

    if (asset == 'USDT') {
      await prefs.setDouble(
        'wallet_usdt_amount',
        amount,
      );
    }
  }
}