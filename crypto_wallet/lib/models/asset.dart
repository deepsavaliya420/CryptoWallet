class Asset {
  final String symbol;
  final String name;
  final String network;
  final String amount;
  final String value;
  final String change;
  final bool isPositive;

  const Asset({
    required this.symbol,
    required this.name,
    required this.network,
    required this.amount,
    required this.value,
    required this.change,
    required this.isPositive,
  });
}