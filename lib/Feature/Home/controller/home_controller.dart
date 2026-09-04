import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_keys.dart';

class HomeController extends GetxController {
  var totalBalance = 0.0.obs;
  var totalIncome = 0.0.obs;
  var totalExpense = 0.0.obs;
  var recentTransactions = <Map<dynamic, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  void loadDashboardData() {
    final box = Hive.box(AppKeys.transactionsBox);
    final data = box.values.toList();
    
    double income = 0.0;
    double expense = 0.0;
    
    for (var item in data) {
      if (item['type'] == 'Income') {
        income += (item['amount'] ?? 0.0);
      } else {
        expense += (item['amount'] ?? 0.0);
      }
    }

    totalIncome.value = income;
    totalExpense.value = expense;
    totalBalance.value = income - expense;
    recentTransactions.assignAll(data.reversed.take(5).map((e) => e as Map<dynamic, dynamic>).toList());
  }
}