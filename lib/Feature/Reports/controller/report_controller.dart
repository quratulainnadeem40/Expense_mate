import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class TransactionModel {
  final String title;
  final double amount;
  final bool isIncome;
  final String category;
  final String date;

  TransactionModel({
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'isIncome': isIncome,
      'category': category,
      'date': date,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      title: map['title'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      isIncome: map['isIncome'] ?? false,
      category: map['category'] ?? 'General',
      date: map['date'] ?? '',
    );
  }
}

class ReportController extends GetxController {
  final GetStorage _storage = GetStorage();
  
  // Storage key common rakhein taake Home & Reports synchronized rahein
  final String _key = 'user_transactions';

  final titleController = TextEditingController();
  final amountController = TextEditingController();

  var selectedCategory = 'General'.obs;

  var transactions = <TransactionModel>[].obs;
  var totalIncome = 0.0.obs;
  var totalExpense = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDataFromStorage();
  }

  void _loadDataFromStorage() {
    List? stored = _storage.read<List>(_key);
    if (stored != null && stored.isNotEmpty) {
      transactions.assignAll(
        stored
            .map((e) => TransactionModel.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
      );
    } else {
      // Agaye real app scenario me jab koi entry na ho
      transactions.clear();
    }
    _calculateTotals();
  }

  void _saveDataToStorage() {
    List<Map<String, dynamic>> data =
        transactions.map((e) => e.toMap()).toList();
    _storage.write(_key, data);
  }

  void _calculateTotals() {
    double incomeSum = 0.0;
    double expenseSum = 0.0;

    for (var t in transactions) {
      if (t.isIncome) {
        incomeSum += t.amount;
      } else {
        expenseSum += t.amount;
      }
    }

    totalIncome.value = incomeSum;
    totalExpense.value = expenseSum;
  }

  Map<String, double> get categoryBreakdown {
    Map<String, double> map = {};
    for (var t in transactions.where((e) => !e.isIncome)) {
      map[t.category] = (map[t.category] ?? 0.0) + t.amount;
    }
    return map;
  }

  void addTransaction(bool isIncome) {
    String title = titleController.text.trim();
    String amountText = amountController.text.trim();

    if (title.isNotEmpty && amountText.isNotEmpty) {
      double amount = double.tryParse(amountText) ?? 0.0;

      if (amount > 0) {
        transactions.insert(
          0,
          TransactionModel(
            title: title,
            amount: amount,
            isIncome: isIncome,
            category: isIncome ? 'Salary' : selectedCategory.value,
            date:
                '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
          ),
        );

        _calculateTotals();
        _saveDataToStorage();

        titleController.clear();
        amountController.clear();
        selectedCategory.value = 'General';
        Get.back();
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