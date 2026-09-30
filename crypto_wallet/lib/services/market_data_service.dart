import 'api_service.dart';

class MarketDataService {
  static Future<Map<String, double>> getUsdRates() async {
    final response = await ApiService.get(
      '/market/rates',
    );

    if (response['success'] != true) {
      throw StateError(
        response['message']?.toString() ??
            'Failed to fetch market rates.',
      );
    }

    final dynamic ratesData =
    response['rates'];

    if (ratesData is! Map) {
      throw StateError(
        'Invalid market rates response.',
      );
    }

    final Map<String, double> rates =
    <String, double>{};

    const List<String> supportedCurrencies = [
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
    in supportedCurrencies
    ) {
      final double? value =
      _toDoubleOrNull(
        ratesData[currency],
      );

      if (
      value != null &&
          value > 0
      ) {
        rates[currency] = value;
      }
    }

    return rates;
  }

  static Future<Map<String, double?>>
  getCryptoRates() async {
    final response =
    await ApiService.get(
      '/market/rates',
    );

    if (response['success'] != true) {
      throw StateError(
        response['message']?.toString() ??
            'Failed to fetch market rates.',
      );
    }

    final dynamic cryptoData =
    response['cryptoUsdPrices'];

    if (cryptoData is! Map) {
      throw StateError(
        'Invalid crypto market rates response.',
      );
    }

    return {
      'BTC':
      _toDoubleOrNull(
        cryptoData['BTC'],
      ),
      'ETH':
      _toDoubleOrNull(
        cryptoData['ETH'],
      ),
      'SOL':
      _toDoubleOrNull(
        cryptoData['SOL'],
      ),
      'TRX':
      _toDoubleOrNull(
        cryptoData['TRX'],
      ),
      'USDT':
      _toDoubleOrNull(
        cryptoData['USDT'],
      ),
      'USDC':
      _toDoubleOrNull(
        cryptoData['USDC'],
      ),
    };
  }

  static double? _toDoubleOrNull(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }
}