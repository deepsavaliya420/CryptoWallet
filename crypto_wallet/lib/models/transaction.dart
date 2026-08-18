class WalletTransaction {
  final String id;
  final String type;
  final String asset;
  final String network;
  final double amount;
  final double value;
  final String from;
  final String to;
  final String status;
  final DateTime timestamp;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.asset,
    required this.network,
    required this.amount,
    required this.value,
    required this.from,
    required this.to,
    required this.status,
    required this.timestamp,
  });

  WalletTransaction copyWith({
    String? id,
    String? type,
    String? asset,
    String? network,
    double? amount,
    double? value,
    String? from,
    String? to,
    String? status,
    DateTime? timestamp,
  }) {
    return WalletTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      asset: asset ?? this.asset,
      network: network ?? this.network,
      amount: amount ?? this.amount,
      value: value ?? this.value,
      from: from ?? this.from,
      to: to ?? this.to,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}