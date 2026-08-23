class P2POffer {
  final String id;
  final String sellerName;
  final String sellerRating;
  final int completedOrders;
  final double price;
  final double availableAmount;
  final double minAmount;
  final double maxAmount;
  final List<String> paymentMethods;

  // Blockchain network used for the P2P crypto transaction.
  final String network;

  const P2POffer({
    required this.id,
    required this.sellerName,
    required this.sellerRating,
    required this.completedOrders,
    required this.price,
    required this.availableAmount,
    required this.minAmount,
    required this.maxAmount,
    required this.paymentMethods,

    // Default network so existing P2P offers do not break.
    this.network = 'TRC-20',
  });
}