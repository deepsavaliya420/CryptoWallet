import 'dart:convert';

class ReceiveRequest {
  final String id;

  /// Wallet address that is being asked to send the funds.
  final String requestedFrom;

  /// Wallet address that will receive the funds.
  final String requestedTo;

  /// Requested asset, currently USDT.
  final String asset;

  /// Requested network, currently TRC-20.
  final String network;

  /// Amount requested in USD/USDT.
  final double amount;

  /// pending / completed / cancelled
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
      asset: asset ?? this.asset,
      network: network ?? this.network,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt:
      completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requestedFrom': requestedFrom,
      'requestedTo': requestedTo,
      'asset': asset,
      'network': network,
      'amount': amount,
      'status': status,
      'createdAt':
      createdAt.toIso8601String(),
      'completedAt':
      completedAt?.toIso8601String(),
    };
  }

  factory ReceiveRequest.fromMap(
      Map<String, dynamic> map,
      ) {
    return ReceiveRequest(
      id: map['id']?.toString() ?? '',
      requestedFrom:
      map['requestedFrom']
          ?.toString() ??
          '',
      requestedTo:
      map['requestedTo']
          ?.toString() ??
          '',
      asset:
      map['asset']?.toString() ??
          'USDT',
      network:
      map['network']?.toString() ??
          'TRC-20',
      amount:
      (map['amount'] as num?)
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

  String toJson() {
    return jsonEncode(
      toMap(),
    );
  }

  factory ReceiveRequest.fromJson(
      String source,
      ) {
    return ReceiveRequest.fromMap(
      jsonDecode(source)
      as Map<String, dynamic>,
    );
  }
}