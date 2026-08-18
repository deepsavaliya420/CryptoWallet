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

  /// Get all wallet assets.
  static Future<List<Asset>> getAssets() async {
    return List.unmodifiable(_assets);
  }

  /// Get one asset by symbol.
  static Future<Asset?> getAsset(String symbol) async {
    try {
      return _assets.firstWhere(
            (asset) =>
        asset.symbol.toUpperCase() == symbol.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Calculate total wallet value.
  static double getTotalBalance() {
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
    _assets.add(asset);
  }

  /// Remove an asset by symbol.
  static Future<void> removeAsset(String symbol) async {
    _assets.removeWhere(
          (asset) =>
      asset.symbol.toUpperCase() == symbol.toUpperCase(),
    );
  }
}