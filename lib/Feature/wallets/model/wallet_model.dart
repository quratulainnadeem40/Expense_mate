class WalletModel {
  final String id;
  final String userId;
  final String name;
  final String type;
  final double balance;
  final String currency;
  final DateTime createdAt;

  WalletModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
    required this.createdAt,
  });

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      balance: (map['balance'] as num).toDouble(),
      currency: map['currency'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'balance': balance,
      'currency': currency,
      'created_at': createdAt.toIso8601String(),
    };
  }

  WalletModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    double? balance,
    String? currency,
    DateTime? createdAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}