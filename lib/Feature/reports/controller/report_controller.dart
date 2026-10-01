
import 'package:get/get.dart';

import 'package:expense_mate/Feature/Categories/controller/categories_controller.dart';
import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';
import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';

class ReportController extends GetxController {
  late final TransactionsController _txController;
  late final CategoriesController _categoriesController;

  // ==========================================================
  // TRANSACTIONS
  // ==========================================================

  RxList<TransactionModel> get transactions =>
      _txController.transactions;

  // ==========================================================
  // MONTH FILTER
  // ==========================================================

  final RxnInt selectedMonth = RxnInt();

  void setMonthFilter(int month) {
    selectedMonth.value = month;
  }

  // ==========================================================
  // ALL TRANSACTIONS
  // ==========================================================

  List<TransactionModel> get allTransactions {
    return _txController.transactions.toList();
  }

  // ==========================================================
  // FILTERED TRANSACTIONS
  // ==========================================================

  List<TransactionModel> get filteredTransactions {
    final int? month = selectedMonth.value;

    final List<TransactionModel> data =
        _txController.transactions.toList();

    if (month == null) {
      return data;
    }

    return data.where((transaction) {
      return transaction.transactionDate.month == month;
    }).toList();
  }

  // ==========================================================
  // TRANSACTION TYPE
  // ==========================================================

  String _transactionType(TransactionModel transaction) {
    return transaction.type.trim().toLowerCase();
  }

  bool _isIncome(TransactionModel transaction) {
    return _transactionType(transaction) == 'income';
  }

  bool _isExpense(TransactionModel transaction) {
    return _transactionType(transaction) == 'expense';
  }

  // ==========================================================
  // TOTAL INCOME
  // ==========================================================

  double get totalIncome {
    double total = 0.0;

    for (final transaction in filteredTransactions) {
      if (_isIncome(transaction)) {
        total += transaction.amount;
      }
    }

    return total;
  }

  // ==========================================================
  // TOTAL EXPENSE
  // ==========================================================

  double get totalExpense {
    double total = 0.0;

    for (final transaction in filteredTransactions) {
      if (_isExpense(transaction)) {
        total += transaction.amount;
      }
    }

    return total;
  }

  // ==========================================================
  // REMAINING BALANCE
  // ==========================================================

  double get totalBalance {
    return totalIncome - totalExpense;
  }

  // ==========================================================
  // CATEGORY NAME
  // ==========================================================

  String _getCategoryName(TransactionModel transaction) {
    // Custom category
    final String customName =
        transaction.customCategoryName.trim();

    if (customName.isNotEmpty) {
      return customName;
    }

    // Category ID -> Category Name
    final String categoryId =
        transaction.categoryId.trim();

    if (categoryId.isNotEmpty) {
      final category =
          _categoriesController.categoryList.firstWhereOrNull(
        (item) => item.id.trim() == categoryId,
      );

      if (category != null) {
        final String categoryName =
            category.name.trim();

        if (categoryName.isNotEmpty) {
          return categoryName;
        }
      }
    }

    // Stored category value
    final String categoryValue =
        transaction.category.trim();

    if (categoryValue.isNotEmpty &&
        categoryValue != categoryId) {
      return categoryValue;
    }

    return '';
  }

  // ==========================================================
  // EXPENSE CATEGORIES
  // ==========================================================

  Map<String, double> get expenseCategories {
    final Map<String, double> categoryTotals = {};

    for (final transaction in filteredTransactions) {
      if (!_isExpense(transaction)) {
        continue;
      }

      final String categoryName =
          _getCategoryName(transaction);

      if (categoryName.isEmpty) {
        continue;
      }

      categoryTotals[categoryName] =
          (categoryTotals[categoryName] ?? 0.0) +
              transaction.amount;
    }

    return categoryTotals;
  }

  // ==========================================================
  // MONTHLY EXPENSES
  // ==========================================================

  Map<int, double> get monthlyExpenses {
    final Map<int, double> monthlyTotals = {
      for (int month = 1; month <= 12; month++)
        month: 0.0,
    };

    // Monthly graph always uses all transactions.
    for (final transaction in allTransactions) {
      if (!_isExpense(transaction)) {
        continue;
      }

      final int month =
          transaction.transactionDate.month;

      monthlyTotals[month] =
          (monthlyTotals[month] ?? 0.0) +
              transaction.amount;
    }

    return monthlyTotals;
  }

  // ==========================================================
  // FILTERED EXPENSES
  // ==========================================================

  List<TransactionModel> get filteredExpenses {
    return filteredTransactions
        .where(_isExpense)
        .toList();
  }

  // ==========================================================
  // FILTERED INCOME
  // ==========================================================

  List<TransactionModel> get filteredIncome {
    return filteredTransactions
        .where(_isIncome)
        .toList();
  }

  // ==========================================================
  // DATA CHECKS
  // ==========================================================

  bool get hasTransactions {
    return allTransactions.isNotEmpty;
  }

  bool get hasIncome {
    return totalIncome > 0;
  }

  bool get hasExpense {
    return totalExpense > 0;
  }

  bool get hasCategoryData {
    return expenseCategories.isNotEmpty;
  }

  // ==========================================================
  // REFRESH REPORTS
  // ==========================================================

  Future<void> refreshReports() async {
    try {
      await _txController.loadTransactions();

      if (Get.isRegistered<CategoriesController>()) {
        await _categoriesController.fetchCategories();
      }
    } catch (e) {
      print('REPORT REFRESH ERROR: $e');
    }

    update();
  }

  // ==========================================================
  // DEBUG
  // ==========================================================

  void printReportData() {
    print('');
    print('========================================');
    print('          EXPENSE MATE REPORTS');
    print('========================================');
    print(
      'Transactions: ${allTransactions.length}',
    );
    print(
      'Filtered: ${filteredTransactions.length}',
    );
    print(
      'Income: $totalIncome',
    );
    print(
      'Expense: $totalExpense',
    );
    print(
      'Balance: $totalBalance',
    );
    print(
      'Categories: $expenseCategories',
    );
    print(
      'Monthly: $monthlyExpenses',
    );
    print('========================================');
    print('');

    for (final transaction in allTransactions) {
      print(
        'REPORT TRANSACTION | '
        'title=${transaction.title} | '
        'amount=${transaction.amount} | '
        'type=${transaction.type} | '
        'date=${transaction.transactionDate} | '
        'categoryId=${transaction.categoryId}',
      );
    }
  }

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void onInit() {
    super.onInit();

    // Existing TransactionsController use karo.
    if (Get.isRegistered<TransactionsController>()) {
      _txController =
          Get.find<TransactionsController>();
    } else {
      _txController =
          Get.put(TransactionsController());
    }

    // Existing CategoriesController use karo.
    if (Get.isRegistered<CategoriesController>()) {
      _categoriesController =
          Get.find<CategoriesController>();
    } else {
      _categoriesController =
          Get.put(CategoriesController());
    }

    // Transactions change hone par Reports update hoga.
    ever(
      _txController.transactions,
      (_) {
        update();
      },
    );

    // Categories change hone par Reports update hoga.
    ever(
      _categoriesController.categoryList,
      (_) {
        update();
      },
    );

    printReportData();
  }
}

