import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransactionModel {
  final String title;
  final double amount;
  final bool isIncome;
  final String date;

  TransactionModel({
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.date,
  });
}

class ReportController extends GetxController {
  // Text Controllers for Input
  final titleController = TextEditingController();
  final amountController = TextEditingController();

  // Dynamic Observable Lists & Values (Default $0.00)
  var transactions = <TransactionModel>[].obs;
  var totalIncome = 0.0.obs;
  var totalExpense = 0.0.obs;

  // Add New Transaction Method
  void addTransaction(bool isIncome) {
    String title = titleController.text.trim();
    String amountText = amountController.text.trim();

    if (title.isNotEmpty && amountText.isNotEmpty) {
      double amount = double.tryParse(amountText) ?? 0.0;

      if (amount > 0) {
        // Add to list
        transactions.insert(
          0,
          TransactionModel(
            title: title,
            amount: amount,
            isIncome: isIncome,
            date: '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
          ),
        );

        // Update Totals automatically
        if (isIncome) {
          totalIncome.value += amount;
        } else {
          totalExpense.value += amount;
        }

        // Clear Inputs
        titleController.clear();
        amountController.clear();
        Get.back(); // Close Bottom Sheet/Dialog
      }
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    amountController.dispose();
    super.onClose();
  }
}