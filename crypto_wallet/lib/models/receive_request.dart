class ReceiveRequest {
  final String id;
  final String requestedFrom;
  final String requestedTo;
  final String asset;
  final String network;
  final double amount;
  final String status;
  final DateTime createdAt;
  final DateTime? completedAt;

  const ReceiveRequest({
    required this.id,
    required this.requestedFrom,
    required this.requestedTo,
    required this.asset,
    required this.network,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  ReceiveRequest copyWith({
    String? id,
    String? requestedFrom,
    String? requestedTo,
    String? asset,
    String? network,
    double? amount,
    String? status,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return ReceiveRequest(
      id: id ?? this.id,
      requestedFrom:
      requestedFrom ?? this.requestedFrom,
      requestedTo:
      requestedTo ?? this.requestedTo,
      asset:
      asset ?? this.asset,
      network:
      network ?? this.network,
      amount:
      amount ?? this.amount,
      status:
      status ?? this.status,
      createdAt:
      createdAt ?? this.createdAt,
      completedAt:
      completedAt ?? this.completedAt,
    );
  }
}