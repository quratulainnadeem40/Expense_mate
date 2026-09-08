class GoalModel {
  final String id;
  final String title;
  final double targetAmount;
  double savedAmount;
  final DateTime targetDate;

  GoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.savedAmount = 0.0,
    required this.targetDate,
  });

  // Safe progress calculation
  double get progress =>
      targetAmount > 0 ? (savedAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  // For Local Storage (GetStorage / SharedPreferences)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'targetDate': targetDate.toIso8601String(),
    };
  }

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'],
      title: map['title'],
      targetAmount: map['targetAmount'],
      savedAmount: map['savedAmount'],
      targetDate: DateTime.parse(map['targetDate']),
    );
  }
}