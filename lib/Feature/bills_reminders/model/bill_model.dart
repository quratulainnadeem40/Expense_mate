class BillModel {
  final String id;
  final String name;
  final double amount;
  final DateTime dueDate;
  final String category;
  final String repeat;
  final bool isPaid;

  const BillModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.category,
    required this.repeat,
    required this.isPaid,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'category': category,
      'repeat': repeat,
      'isPaid': isPaid,
    };
  }

  factory BillModel.fromMap(Map<dynamic, dynamic> map) {
    return BillModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      dueDate: DateTime.tryParse(
            map['dueDate']?.toString() ?? '',
          ) ??
          DateTime.now(),
      category: map['category']?.toString() ?? 'Other',
      repeat: map['repeat']?.toString() ?? 'None',
      isPaid: map['isPaid'] == true,
    );
  }

  BillModel copyWith({
    String? id,
    String? name,
    double? amount,
    DateTime? dueDate,
    String? category,
    String? repeat,
    bool? isPaid,
  }) {
    return BillModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      repeat: repeat ?? this.repeat,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}