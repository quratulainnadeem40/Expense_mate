import 'package:get/get.dart';

import '../../transactions/controller/transcation_controller.dart';
import '../../transactions/model/transcation_model.dart';

class HomeController extends GetxController {
  // ==========================================================
  // BOTTOM NAVIGATION
  // ==========================================================

  final currentIndex = 0.obs;

  // ==========================================================
  // DASHBOARD TOTALS
  // ==========================================================

  final totalBalance = 0.0.obs;
  final totalIncome = 0.0.obs;
  final totalExpense = 0.0.obs;

  // ==========================================================
  // ONLY TODAY'S TRANSACTIONS
  // ==========================================================

  final recentTransactions = <TransactionModel>[].obs;

  late TransactionsController transactionsController;

  @override
  void onInit() {
    super.onInit();

    // Use the existing TransactionsController.
    // Do NOT create another TransactionsController if one already exists.
    if (!Get.isRegistered<TransactionsController>()) {
      Get.put(TransactionsController());
    }

    transactionsController = Get.find<TransactionsController>();

    // Refresh Home whenever transactions are:
    // - added
    // - edited
    // - deleted
    ever(
      transactionsController.transactions,
      (_) => loadDashboardData(),
    );

    loadDashboardData();
  }

  @override
  void onReady() {
    super.onReady();
    loadDashboardData();
  }

  // ==========================================================
  // BOTTOM NAVIGATION
  // ==========================================================

  void changePage(int index) {
    currentIndex.value = index;
  }

  // ==========================================================
  // LOAD DASHBOARD DATA
  // ==========================================================

  void loadDashboardData() {
    final allTransactions = transactionsController.transactions;

    double income = 0.0;
    double expense = 0.0;

    // ----------------------------------------------------------
    // TOTAL INCOME / EXPENSE
    // ----------------------------------------------------------

    for (final transaction in allTransactions) {
      if (transaction.isIncome) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    totalIncome.value = income;
    totalExpense.value = expense;
    totalBalance.value = income - expense;

    // ----------------------------------------------------------
    // TODAY'S TRANSACTIONS ONLY
    // ----------------------------------------------------------

    final todayTransactions = allTransactions.where((transaction) {
      return _isToday(transaction.transactionDate);
    }).toList();

    // ----------------------------------------------------------
    // NEWEST TRANSACTION FIRST
    // ----------------------------------------------------------

    todayTransactions.sort((a, b) {
      return b.transactionDate.compareTo(a.transactionDate);
    });

    // Update Home screen list
    recentTransactions.assignAll(todayTransactions);
  }

  // ==========================================================
  // CHECK WHETHER DATE IS TODAY
  // ==========================================================

  bool _isToday(DateTime date) {
    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}