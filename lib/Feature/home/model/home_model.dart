class HomeDashboardModel {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final List<Map<dynamic, dynamic>> recentTransactions;

  HomeDashboardModel({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.recentTransactions,
  });
}