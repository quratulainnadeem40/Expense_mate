class ExpenseModel {
  final String id;
  final double amount;
  final String category;
  final String paymentMethod;
  final String note;
  final DateTime date;
  final bool isExpense;

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.paymentMethod,
    required this.note,
    required this.date,
    required this.isExpense,
  });
}