import 'package:expense_mate/Feature/Budgets/controller/budget_controller.dart';
import 'package:expense_mate/Feature/Budgets/view/budget_view.dart';
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

  test('budget reset date always follows the selected day in the next month with month-end clamping', () {
    expect(
      calculateNextBudgetResetDate(now: DateTime(2026, 9, 1), selectedDay: 8),
      DateTime(2026, 10, 8),
    );
    expect(
      calculateNextBudgetResetDate(now: DateTime(2026, 9, 24), selectedDay: 24),
      DateTime(2026, 10, 24),
    );
    expect(
      calculateNextBudgetResetDate(now: DateTime(2026, 9, 30), selectedDay: 30),
      DateTime(2026, 10, 30),
    );
    expect(
      calculateNextBudgetResetDate(now: DateTime(2026, 4, 30), selectedDay: 31),
      DateTime(2026, 5, 31),
    );
    expect(
      calculateNextBudgetResetDate(now: DateTime(2026, 1, 15), selectedDay: 31),
      DateTime(2026, 2, 28),
    );
  });

  test('manual reset clears spent amount without changing the budget limit', () {
    final controller = BudgetController();
    controller.categoriesController = CategoriesController();
    controller.transactionsController = TransactionsController();
    controller.categoriesController.categoryList.value = [
      CategoryModel(
        id: 'cat_food',
        name: 'Food',
        icon: 'food',
        colorValue: 0xFFFF7043,
        isDefault: true,
      ),
    ];
    controller.customTotalBudget.value = 600000.0;
    controller.transactionsController.transactions.value = [
      TransactionModel(
        id: 'tx_1',
        userId: 'u1',
        walletId: 'w1',
        categoryId: 'cat_food',
        title: 'Groceries',
        amount: 350000,
        type: 'expense',
      ),
    ];

    controller.calculateBudgets();
    expect(controller.totalSpent, 350000.0);
    expect(controller.customTotalBudget.value, 600000.0);

    controller.resetMonthlySpent();

    expect(controller.totalSpent, 0.0);
    expect(controller.customTotalBudget.value, 600000.0);
  });
}
