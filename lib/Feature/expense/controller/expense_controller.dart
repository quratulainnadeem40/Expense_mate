import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_keys.dart';
import '../../Budgets/controller/budget_controller.dart';
import '../../Home/controller/home_controller.dart';
import '../../transactions/controller/transcation_controller.dart';

class ExpenseController extends GetxController {
  var isExpense = true.obs;

  final amountController = TextEditingController();
  final noteController = TextEditingController();

  final List<String> expenseCategories = [
    'Food & Dining',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment'
  ];

  final List<String> incomeCategories = [
    'Salary',
    'Business',
    'Investment',
    'Freelance',
    'Gift'
  ];

  final List<String> paymentMethods = ['Cash', 'Credit Card', 'Debit Card', 'UPI'];

  var selectedCategory = 'Food & Dining'.obs;
  var selectedPaymentMethod = 'Cash'.obs;

  void toggleType(bool isExp) {
    isExpense.value = isExp;
    selectedCategory.value = isExp ? expenseCategories.first : incomeCategories.first;
  }

  void saveExpense() async {
    if (amountController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    try {
      double amount = double.tryParse(amountController.text.trim()) ?? 0.0;
      final String typeText = isExpense.value ? 'expense' : 'income';

      // 1. Data Map for Hive
      Map<String, dynamic> transactionData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'amount': amount,
        'category': selectedCategory.value,
        'paymentMethod': selectedPaymentMethod.value,
        'note': noteController.text.trim(),
        'date': DateTime.now().toIso8601String(),
        'type': isExpense.value ? 'Expense' : 'Income',
        'isIncome': !isExpense.value, // Added for direct mapping
      };

      // 2. Save in Hive Box
      final box = Hive.box(AppKeys.transactionsBox);
      await box.add(transactionData);

      // 3. Update Transactions Controller (Real-time update)
      if (Get.isRegistered<TransactionsController>()) {
        await Get.find<TransactionsController>().loadTransactions();
      }

      // 4. Update Dashboard State
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadDashboardData();
      }

      // 5. Update Budget State (Force refresh)
      if (Get.isRegistered<BudgetController>()) {
        Get.find<BudgetController>().customLimits.refresh();
      }

      // 6. Clear Text Fields
      amountController.clear();
      noteController.clear();

      // 7. Navigate back to Home first
      Get.until((route) => route.isFirst);

      // 8. Show Green Tick Snackbar at Bottom
      Get.snackbar(
        'Great!',
        'Your $typeText has been added successfully.',
        icon: const Icon(
          Icons.check_circle,
          color: Colors.white,
          size: 28,
        ),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save transaction',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    noteController.dispose();
    super.onClose();
  }
}