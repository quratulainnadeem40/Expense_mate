import 'package:expense_mate/Feature/Budgets/controller/budget_controller.dart';
import 'package:expense_mate/Feature/Categories/controller/categories_controller.dart';
import 'package:expense_mate/Feature/Categories/model/categories_model.dart';
import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';
import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('budget spending is calculated from real category ids and limits are summed accurately', () {
    final budgetController = BudgetController();
    budgetController.categoriesController = CategoriesController();
    budgetController.transactionsController = TransactionsController();

    budgetController.categoriesController.categoryList.value = [
      CategoryModel(
        id: 'cat_food',
        name: 'Food',
        icon: 'food',
        colorValue: 0xFFFF7043,
        isDefault: true,
      ),
      CategoryModel(
        id: 'cat_transport',
        name: 'Transport',
        icon: 'transport',
        colorValue: 0xFF42A5F5,
        isDefault: true,
      ),
    ];

    budgetController.transactionsController.transactions.value = [
      TransactionModel(
        id: 'tx_1',
        userId: 'u1',
        walletId: 'w1',
        categoryId: 'cat_food',
        title: 'Lunch',
        amount: 2000,
        type: 'expense',
      ),
      TransactionModel(
        id: 'tx_2',
        userId: 'u1',
        walletId: 'w1',
        categoryId: 'cat_transport',
        title: 'Taxi',
        amount: 500,
        type: 'expense',
      ),
      TransactionModel(
        id: 'tx_3',
        userId: 'u1',
        walletId: 'w1',
        categoryId: 'cat_food',
        title: 'Salary',
        amount: 50000,
        type: 'income',
      ),
    ];

    budgetController.customLimits['Food'] = 5000;
    budgetController.customLimits['Transport'] = 3000;
    budgetController.calculateBudgets();

    final foodBudget = budgetController.budgetList
        .firstWhere((budget) => budget.categoryName == 'Food');
    final transportBudget = budgetController.budgetList
        .firstWhere((budget) => budget.categoryName == 'Transport');

    expect(foodBudget.spentAmount, 2000.0);
    expect(foodBudget.allocatedAmount, 5000.0);
    expect(transportBudget.spentAmount, 500.0);
    expect(transportBudget.allocatedAmount, 3000.0);
    expect(budgetController.totalAllocated, 8000.0);
    expect(budgetController.totalSpent, 2500.0);
  });
}
