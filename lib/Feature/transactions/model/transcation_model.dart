class TransactionModel {
  final String id;
  final String userId;
  final String walletId;
  final String categoryId;
  final String title;
  final double amount;
  final String type;
  final DateTime transactionDate;
  final String? note;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    this.userId = '',
    this.walletId = '',
    this.categoryId = '',
    required this.title,
    required this.amount,
    this.type = 'expense',
    DateTime? transactionDate,
    String? note,
    DateTime? createdAt,
    String? category,
    DateTime? date,
    bool? isIncome,
  })  : transactionDate =
            transactionDate ?? date ?? DateTime.now(),
        note = note ?? title,
        createdAt =
            createdAt ?? transactionDate ?? date ?? DateTime.now();

  // Backward-compatible getters
  String get category => categoryId;

  DateTime get date => transactionDate;

  bool get isIncome => type == 'income';

  bool get isExpense => type == 'expense';

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      walletId: map['wallet_id']?.toString() ?? '',
      categoryId: map['category_id']?.toString() ??
          map['category']?.toString() ??
          '',
      title: map['title']?.toString() ??
          map['note']?.toString() ??
          '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      type: map['type']?.toString().toLowerCase() ??
          (map['isIncome'] == true ? 'income' : 'expense'),
      transactionDate: DateTime.tryParse(
            map['transaction_date']?.toString() ??
                map['date']?.toString() ??
                '',
          ) ??
          DateTime.now(),
      note: map['note']?.toString(),
      createdAt: DateTime.tryParse(
            map['created_at']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'wallet_id': walletId,
      'category_id': categoryId,
      'title': title,
      'amount': amount,
      'type': type,
      'transaction_date': transactionDate.toIso8601String(),
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'isIncome': isIncome,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      category: json['category']?.toString(),
      date: DateTime.tryParse(
        json['date']?.toString() ?? '',
      ),
      isIncome: json['isIncome'] == true,
    );
  }

  TransactionModel copyWith({
    String? id,
    String? userId,
    String? walletId,
    String? categoryId,
    String? title,
    double? amount,
    String? type,
    DateTime? transactionDate,
    String? note,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      walletId: walletId ?? this.walletId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      transactionDate: transactionDate ?? this.transactionDate,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}