import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_keys.dart';

class HomeController extends GetxController {
  // Bottom Navigation
  var currentIndex = 0.obs;

  var totalBalance = 0.0.obs;
  var totalIncome = 0.0.obs;
  var totalExpense = 0.0.obs;

  // Only today's transactions
  var recentTransactions = <Map<dynamic, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  @override
  void onReady() {
    super.onReady();
    loadDashboardData();
  }

  // Bottom Navigation
  void changePage(int index) {
    currentIndex.value = index;
  }

  void loadDashboardData() {
    final box = Hive.box(AppKeys.transactionsBox);
    final data = box.values.toList();

    double income = 0.0;
    double expense = 0.0;

    for (var item in data) {
      if (item['type']?.toString().toLowerCase() == 'income') {
        income += _getAmount(item['amount']);
      } else {
        expense += _getAmount(item['amount']);
      }
    }

    totalIncome.value = income;
    totalExpense.value = expense;
    totalBalance.value = income - expense;

    // ==========================================================
    // ONLY TODAY'S TRANSACTIONS FOR HOME SCREEN
    // ==========================================================

    final todayTransactions = data
        .where((item) {
          final date = _getTransactionDate(item);
          return date != null && _isToday(date);
        })
        .map((item) => item as Map<dynamic, dynamic>)
        .toList();

    // Newest transaction first
    todayTransactions.sort((a, b) {
      final dateA = _getTransactionDate(a);
      final dateB = _getTransactionDate(b);

      if (dateA == null || dateB == null) {
        return 0;
      }

      return dateB.compareTo(dateA);
    });

    recentTransactions.assignAll(todayTransactions);
  }

  // ==========================================================
  // CHECK WHETHER TRANSACTION IS FROM TODAY
  // ==========================================================

  bool _isToday(DateTime date) {
    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // ==========================================================
  // GET TRANSACTION DATE
  // ==========================================================

  DateTime? _getTransactionDate(Map<dynamic, dynamic> item) {
    final value =
        item['transaction_date'] ??
        item['transactionDate'] ??
        item['date'];

    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  // ==========================================================
  // GET AMOUNT SAFELY
  // ==========================================================

  double _getAmount(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}