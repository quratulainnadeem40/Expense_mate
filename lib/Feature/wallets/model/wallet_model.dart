class WalletModel {
  final String id;
  final String name;
  final String type;
  final double balance;
  final String currency;

  const WalletModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'balance': balance,
      'currency': currency,
    };
  }

  factory WalletModel.fromMap(Map<dynamic, dynamic> map) {
    return WalletModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      type: map['type']?.toString() ?? 'Cash',
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency']?.toString() ?? 'PKR',
    );
  }

  WalletModel copyWith({
    String? id,
    String? name,
    String? type,
    double? balance,
    String? currency,
  }) {
    return WalletModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
    );
  }
}