class WalletTransaction {
  final String id;
  final String type;
  final String asset;
  final String network;
  final double amount;
  final double value;
  final String from;
  final String to;
  final DateTime timestamp;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.asset,
    required this.network,
    required this.amount,
    required this.value,
    this.from = '',
    this.to = '',
    required this.timestamp,
  });

  // ============================================================
  // FROM MAP
  // ============================================================

  factory WalletTransaction.fromMap(
      Map<String, dynamic> map,
      ) {
    return WalletTransaction(
      id: _stringValue(
        map['id'],
      ),
      type: _stringValue(
        map['type'],
      ),
      asset: _stringValue(
        map['asset'],
      ),
      network: _stringValue(
        map['network'],
      ),
      amount: _doubleValue(
        map['amount'],
      ),
      value: _doubleValue(
        map['value'],
      ),
      from: _stringValue(
        map['from'],
      ),
      to: _stringValue(
        map['to'],
      ),
      timestamp: _dateTimeValue(
        map['timestamp'],
      ),
    );
  }

  // ============================================================
  // TO MAP
  // ============================================================

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'type': type,
      'asset': asset,
      'network': network,
      'amount': amount,
      'value': value,
      'from': from,
      'to': to,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // ============================================================
  // JSON
  // ============================================================

  factory WalletTransaction.fromJson(
      String source,
      ) {
    return WalletTransaction.fromMap(
      Map<String, dynamic>.from(
        _decodeJson(source),
      ),
    );
  }

  String toJson() {
    return _encodeJson(
      toMap(),
    );
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  WalletTransaction copyWith({
    String? id,
    String? type,
    String? asset,
    String? network,
    double? amount,
    double? value,
    String? from,
    String? to,
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
      timestamp:
      timestamp ?? this.timestamp,
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static String _stringValue(
      dynamic value,
      ) {
    if (value == null) {
      return '';
    }

    return value.toString();
  }

  static double _doubleValue(
      dynamic value,
      ) {
    if (value == null) {
      return 0.0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    ) ??
        0.0;
  }

  static DateTime _dateTimeValue(
      dynamic value,
      ) {
    if (value is DateTime) {
      return value;
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(
        value,
      );
    }

    if (value is String) {
      final DateTime? parsed =
      DateTime.tryParse(value);

      if (parsed != null) {
        return parsed;
      }
    }

    return DateTime.now();
  }

  static Map<String, dynamic>
  _decodeJson(
      String source,
      ) {
    // This method is intentionally
    // implemented below without adding
    // another package dependency.
    throw UnsupportedError(
      'Use WalletTransaction.fromMap() '
          'with decoded JSON data.',
    );
  }

  static String _encodeJson(
      Map<String, dynamic> map,
      ) {
    return map.toString();
  }
}