class SwapTransaction {
  final String id;

  final String fromCurrency;
  final String fromNetwork;

  final String toCurrency;
  final String toNetwork;

  final double fromAmount;
  final double toAmount;

  final double exchangeRate;
  final double fee;

  final String status;

  final DateTime timestamp;

  const SwapTransaction({
    required this.id,
    required this.fromCurrency,
    required this.fromNetwork,
    required this.toCurrency,
    required this.toNetwork,
    required this.fromAmount,
    required this.toAmount,
    required this.exchangeRate,
    required this.fee,
    required this.status,
    required this.timestamp,
  });

  SwapTransaction copyWith({
    String? id,
    String? fromCurrency,
    String? fromNetwork,
    String? toCurrency,
    String? toNetwork,
    double? fromAmount,
    double? toAmount,
    double? exchangeRate,
    double? fee,
    String? status,
    DateTime? timestamp,
  }) {
    return SwapTransaction(
      id: id ?? this.id,
      fromCurrency:
      fromCurrency ?? this.fromCurrency,
      fromNetwork:
      fromNetwork ?? this.fromNetwork,
      toCurrency:
      toCurrency ?? this.toCurrency,
      toNetwork:
      toNetwork ?? this.toNetwork,
      fromAmount:
      fromAmount ?? this.fromAmount,
      toAmount:
      toAmount ?? this.toAmount,
      exchangeRate:
      exchangeRate ?? this.exchangeRate,
      fee:
      fee ?? this.fee,
      status:
      status ?? this.status,
      timestamp:
      timestamp ?? this.timestamp,
    );
  }
}