class SwapRecord {
  final String id;

  /// Currency/token being exchanged from.
  final String fromCurrency;

  /// Currency/token being received.
  final String toCurrency;

  /// Network selected by the user.
  final String network;

  /// Amount the user gives.
  final double fromAmount;

  /// Amount the user receives.
  final double toAmount;

  /// Exchange rate used for this swap.
  ///
  /// Example:
  /// 1 USD = 83.50 INR
  final double exchangeRate;

  /// Value of the swap in USD.
  final double usdValue;

  /// pending / completed / cancelled
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromCurrency':
      fromCurrency,
      'toCurrency':
      toCurrency,
      'network':
      network,
      'fromAmount':
      fromAmount,
      'toAmount':
      toAmount,
      'exchangeRate':
      exchangeRate,
      'usdValue':
      usdValue,
      'status':
      status,
      'createdAt':
      createdAt.toIso8601String(),
      'completedAt':
      completedAt?.toIso8601String(),
    };
  }

  factory SwapRecord.fromMap(
      Map<String, dynamic> map,
      ) {
    return SwapRecord(
      id:
      map['id']?.toString() ?? '',
      fromCurrency:
      map['fromCurrency']
          ?.toString() ??
          'USD',
      toCurrency:
      map['toCurrency']
          ?.toString() ??
          'INR',
      network:
      map['network']
          ?.toString() ??
          'TRC-20',
      fromAmount:
      (map['fromAmount'] as num?)
          ?.toDouble() ??
          0.0,
      toAmount:
      (map['toAmount'] as num?)
          ?.toDouble() ??
          0.0,
      exchangeRate:
      (map['exchangeRate'] as num?)
          ?.toDouble() ??
          1.0,
      usdValue:
      (map['usdValue'] as num?)
          ?.toDouble() ??
          0.0,
      status:
      map['status']?.toString() ??
          'pending',
      createdAt:
      DateTime.tryParse(
        map['createdAt']
            ?.toString() ??
            '',
      ) ??
          DateTime.now(),
      completedAt:
      map['completedAt'] == null
          ? null
          : DateTime.tryParse(
        map['completedAt']
            .toString(),
      ),
    );
  }
}