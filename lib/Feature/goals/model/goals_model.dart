class GoalModel {
  final String id;
  String title;
  String emoji;
  double targetAmount;
  double savedAmount;
  DateTime targetDate;
  final DateTime createdAt;

  GoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.targetDate,
    this.savedAmount = 0.0,
    this.emoji = '🎯',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ---------------------------------------------------------------
  // DERIVED VALUES  (kept here so the UI never does maths itself)
  // ---------------------------------------------------------------

  /// 0.0 to 1.0, safe when targetAmount is 0.
  double get progress =>
      targetAmount > 0 ? (savedAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  int get progressPercent => (progress * 100).round();

  /// How much is still needed. Never negative.
  double get remaining =>
      (targetAmount - savedAmount) <= 0 ? 0 : targetAmount - savedAmount;

  bool get isCompleted => savedAmount >= targetAmount && targetAmount > 0;

  /// Days between today and the target date. Negative means overdue.
  int get daysLeft {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return end.difference(start).inDays;
  }

  bool get isOverdue => !isCompleted && daysLeft < 0;

  /// Suggested amount to put aside each month to finish on time.
  double get monthlyTarget {
    if (isCompleted) return 0;
    final months = (daysLeft / 30).ceil();
    if (months <= 0) return remaining;
    return remaining / months;
  }

  // ---------------------------------------------------------------
  // STORAGE
  // ---------------------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'emoji': emoji,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'targetDate': targetDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Tolerant of goals saved by the older version of the app, which had
  /// no emoji and no createdAt.
  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title']?.toString() ?? 'Untitled goal',
      emoji: map['emoji']?.toString() ?? '🎯',
      targetAmount: (map['targetAmount'] as num?)?.toDouble() ?? 0.0,
      savedAmount: (map['savedAmount'] as num?)?.toDouble() ?? 0.0,
      targetDate: DateTime.tryParse(map['targetDate']?.toString() ?? '') ??
          DateTime.now().add(const Duration(days: 30)),
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? ''),
    );
  }

  GoalModel copy() => GoalModel(
        id: id,
        title: title,
        emoji: emoji,
        targetAmount: targetAmount,
        savedAmount: savedAmount,
        targetDate: targetDate,
        createdAt: createdAt,
      );
}