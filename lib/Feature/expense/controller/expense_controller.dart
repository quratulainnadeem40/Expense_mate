import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExpenseController extends GetxController {
  var isExpense = true.obs;

  final amountController = TextEditingController();
  final noteController = TextEditingController();

  var selectedCategory = 'Food & Dining'.obs;
  var selectedPaymentMethod = 'Cash'.obs;
  var selectedDate = DateTime.now().obs;

  final List<String> categories = [
    'Food & Dining',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment'
  ];

  final List<String> paymentMethods = ['Cash', 'Credit Card', 'Debit Card', 'UPI'];

  void toggleType(bool value) {
    isExpense.value = value;
  }

  void saveExpense() {
    if (amountController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter amount', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    Get.back();
  }

  @override
  void onClose() {
    amountController.dispose();
    noteController.dispose();
    super.onClose();
  }
}