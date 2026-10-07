import 'package:get/get.dart';

import 'package:expense_mate/Feature/Categories/controller/categories_controller.dart';
import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';
import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';

class ReportController extends GetxController {
  late final TransactionsController _txController;
  late final CategoriesController _categoriesController;

  RxList<TransactionModel> get transactions =>
      _txController.transactions;

  final RxnInt selectedMonth = RxnInt();

  void setMonthFilter(int month) {
    selectedMonth.value = month;
    update();
  }

  List<TransactionModel> get allTransactions {
    return _txController.transactions.toList();
  }

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
  // BALANCE
  // ==========================================================

  double get totalBalance {
    return totalIncome - totalExpense;
  }

  // ==========================================================
  // GET CATEGORY NAME
  // ==========================================================

  String _getCategoryName(TransactionModel transaction) {
    // --------------------------------------------------------
    // 1. First try custom category name
    // --------------------------------------------------------

    final String customName =
        transaction.customCategoryName.trim();

    if (customName.isNotEmpty) {
      return customName;
    }

    // --------------------------------------------------------
    // 2. Get category ID from transaction
    // --------------------------------------------------------

    final String categoryId =
        transaction.categoryId.trim();

    if (categoryId.isEmpty) {
      return '';
    }

    // --------------------------------------------------------
    // 3. Find category by ID
    // --------------------------------------------------------

    final category =
        _categoriesController.categoryList.firstWhereOrNull(
      (item) {
        return item.id.trim().toLowerCase() ==
            categoryId.toLowerCase();
      },
    );

    if (category != null) {
      final String name = category.name.trim();

      if (name.isNotEmpty) {
        return name;
      }
    }

    // --------------------------------------------------------
    // 4. Try transaction category value
    // --------------------------------------------------------

    final String categoryValue =
        transaction.category.trim();

    if (categoryValue.isNotEmpty &&
        categoryValue.toLowerCase() !=
            categoryId.toLowerCase()) {
      return categoryValue;
    }

    // --------------------------------------------------------
    // 5. Handle default category IDs
    // --------------------------------------------------------

    if (categoryId.toLowerCase().startsWith('default_')) {
      final String defaultName =
          categoryId.substring('default_'.length).trim();

      if (defaultName.isNotEmpty) {
        return defaultName[0].toUpperCase() +
            defaultName.substring(1);
      }
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
  // INCOME CATEGORIES
  // ==========================================================

  Map<String, double> get incomeCategories {
    final Map<String, double> categoryTotals = {};

    for (final transaction in filteredTransactions) {
      // Only income transactions
      if (!_isIncome(transaction)) {
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
  // MONTHLY INCOME
  // ==========================================================

  Map<int, double> get monthlyIncome {
    final Map<int, double> monthlyTotals = {
      for (int month = 1; month <= 12; month++)
        month: 0.0,
    };

    for (final transaction in allTransactions) {
      if (!_isIncome(transaction)) {
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
  // STATUS
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

  bool get hasIncomeCategoryData {
    return incomeCategories.isNotEmpty;
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
  // DEBUG REPORT DATA
  // ==========================================================

  void printReportData() {
    print('');
    print('========================================');
    print('          EXPENSE MATE REPORTS');
    print('========================================');

    print('Transactions: ${allTransactions.length}');
    print('Filtered: ${filteredTransactions.length}');
    print('Income: $totalIncome');
    print('Expense: $totalExpense');
    print('Balance: $totalBalance');

    print('Expense Categories: $expenseCategories');
    print('Income Categories: $incomeCategories');

    print('Monthly Expenses: $monthlyExpenses');
    print('Monthly Income: $monthlyIncome');

    print('========================================');
    print('');

    for (final transaction in allTransactions) {
      print(
        'REPORT TRANSACTION | '
        'title=${transaction.title} | '
        'amount=${transaction.amount} | '
        'type=${transaction.type} | '
        'date=${transaction.transactionDate} | '
        'categoryId=${transaction.categoryId} | '
        'category=${transaction.category} | '
        'customCategory=${transaction.customCategoryName}',
      );
    }
  }

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void onInit() {
    super.onInit();

    if (Get.isRegistered<TransactionsController>()) {
      _txController =
          Get.find<TransactionsController>();
    } else {
      _txController =
          Get.put(TransactionsController());
    }

    if (Get.isRegistered<CategoriesController>()) {
      _categoriesController =
          Get.find<CategoriesController>();
    } else {
      _categoriesController =
          Get.put(CategoriesController());
    }

    // Refresh Reports whenever transactions change
    ever(
      _txController.transactions,
      (_) {
        update();
      },
    );

    // Refresh Reports whenever categories change
    ever(
      _categoriesController.categoryList,
      (_) {
        update();
      },
    );

    printReportData();
  }
}
