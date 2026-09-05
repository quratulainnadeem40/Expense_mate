class BudgetModel {
  final String id;
  final String categoryName;
  final double allocatedAmount;
  final double spentAmount;

  BudgetModel({
    required this.id,
    required this.categoryName,
    required this.allocatedAmount,
    this.spentAmount = 0.0,
  });

  double get remainingAmount => allocatedAmount - spentAmount;
  double get progress => (allocatedAmount > 0) ? (spentAmount / allocatedAmount).clamp(0.0, 1.0) : 0.0;
}