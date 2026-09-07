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

  double get progress => (savedAmount / targetAmount).clamp(0.0, 1.0);
}