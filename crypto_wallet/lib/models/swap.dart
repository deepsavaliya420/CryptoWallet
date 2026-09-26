class SwapRecord {
  final String id;

  final String fromCurrency;

  final String toCurrency;

  final String network;

  final double fromAmount;

  final double toAmount;

  final double exchangeRate;

  final double usdValue;

  final String status;

  final DateTime createdAt;

  final DateTime? completedAt;

  const SwapRecord({
    required this.id,
    required this.fromCurrency,
    required this.toCurrency,
    required this.network,
    required this.fromAmount,
    required this.toAmount,
    required this.exchangeRate,
    required this.usdValue,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  SwapRecord copyWith({
    String? id,
    String? fromCurrency,
    String? toCurrency,
    String? network,
    double? fromAmount,
    double? toAmount,
    double? exchangeRate,
    double? usdValue,
    String? status,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return SwapRecord(
      id: id ?? this.id,
      fromCurrency:
      fromCurrency ?? this.fromCurrency,
      toCurrency:
      toCurrency ?? this.toCurrency,
      network:
      network ?? this.network,
      fromAmount:
      fromAmount ?? this.fromAmount,
      toAmount:
      toAmount ?? this.toAmount,
      exchangeRate:
      exchangeRate ?? this.exchangeRate,
      usdValue:
      usdValue ?? this.usdValue,
      status:
      status ?? this.status,
      createdAt:
      createdAt ?? this.createdAt,
      completedAt:
      completedAt ?? this.completedAt,
    );
  }
}