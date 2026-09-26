class P2POffer {
  final String id;
  final String sellerUserId;
  final String sellerName;
  final String sellerRating;
  final int completedOrders;
  final String asset;
  final double price;
  final double availableAmount;
  final double minAmount;
  final double maxAmount;
  final List<String> paymentMethods;
  final String network;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const P2POffer({
    required this.id,
    this.sellerUserId = '',
    required this.sellerName,
    this.sellerRating = '0%',
    this.completedOrders = 0,
    this.asset = 'USDT',
    required this.price,
    required this.availableAmount,
    required this.minAmount,
    required this.maxAmount,
    required this.paymentMethods,
    this.network = 'TRC-20',
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  P2POffer copyWith({
    String? id,
    String? sellerUserId,
    String? sellerName,
    String? sellerRating,
    int? completedOrders,
    String? asset,
    double? price,
    double? availableAmount,
    double? minAmount,
    double? maxAmount,
    List<String>? paymentMethods,
    String? network,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return P2POffer(
      id: id ?? this.id,
      sellerUserId: sellerUserId ?? this.sellerUserId,
      sellerName: sellerName ?? this.sellerName,
      sellerRating: sellerRating ?? this.sellerRating,
      completedOrders:
      completedOrders ?? this.completedOrders,
      asset: asset ?? this.asset,
      price: price ?? this.price,
      availableAmount:
      availableAmount ?? this.availableAmount,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      paymentMethods:
      paymentMethods ?? this.paymentMethods,
      network: network ?? this.network,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}