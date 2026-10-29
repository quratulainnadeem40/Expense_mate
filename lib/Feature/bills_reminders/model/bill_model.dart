class BillModel {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final DateTime dueDate;
  final String? categoryId;
  final String? walletId;
  final String? note;
  final bool isPaid;
  final bool reminderEnabled;
  final DateTime? reminderTime;
  final DateTime createdAt;

  const BillModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.categoryId,
    required this.walletId,
    required this.note,
    required this.isPaid,
    required this.reminderEnabled,
    required this.reminderTime,
    required this.createdAt,
  });

  // ==========================================================
  // FROM SUPABASE
  // ==========================================================

  factory BillModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return BillModel(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,

      dueDate: DateTime.tryParse(
            map['due_date']?.toString() ?? '',
          ) ??
          DateTime.now(),

      categoryId: map['category_id']?.toString(),
      walletId: map['wallet_id']?.toString(),
      note: map['note']?.toString(),

      isPaid: map['is_paid'] == true,

      reminderEnabled:
          map['reminder_enabled'] == true,

      reminderTime: map['reminder_time'] != null
          ? DateTime.tryParse(
              map['reminder_time'].toString(),
            )
          : null,

      createdAt: DateTime.tryParse(
            map['created_at']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }

  // ==========================================================
  // TO MAP
  // ==========================================================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'amount': amount,
      'due_date': dueDate.toIso8601String(),
      'category_id': categoryId,
      'wallet_id': walletId,
      'note': note,
      'is_paid': isPaid,
      'reminder_enabled': reminderEnabled,
      'reminder_time':
          reminderTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // ==========================================================
  // COPY WITH
  // ==========================================================

  BillModel copyWith({
    String? id,
    String? userId,
    String? title,
    double? amount,
    DateTime? dueDate,
    String? categoryId,
    String? walletId,
    String? note,
    bool? isPaid,
    bool? reminderEnabled,
    DateTime? reminderTime,
    DateTime? createdAt,
  }) {
    return BillModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      categoryId: categoryId ?? this.categoryId,
      walletId: walletId ?? this.walletId,
      note: note ?? this.note,
      isPaid: isPaid ?? this.isPaid,
      reminderEnabled:
          reminderEnabled ?? this.reminderEnabled,
      reminderTime:
          reminderTime ?? this.reminderTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}