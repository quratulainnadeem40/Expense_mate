import 'dart:io';

import 'package:expense_mate/Core/constants/app_keys.dart';
import 'package:expense_mate/Feature/Budgets/controller/budget_controller.dart';
import 'package:expense_mate/Feature/Categories/controller/categories_controller.dart';
import 'package:expense_mate/Feature/Categories/model/categories_model.dart';
import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://epjzyrjxrhbfdyrbdsli.supabase.co',
      anonKey: 'sb_publishable_2VnrpBbdOhiJpqw74rhufg_rp8GgJ_p',
    );
    final tempDir = await Directory.systemTemp.createTemp('budget_test_');
    Hive.init(tempDir.path);
    if (Hive.isBoxOpen(AppKeys.budgetBox)) {
      await Hive.box(AppKeys.budgetBox).clear();
    } else {
      await Hive.openBox(AppKeys.budgetBox);
    }
  });

  tearDown(() async {
    if (Hive.isBoxOpen(AppKeys.budgetBox)) {
      await Hive.box(AppKeys.budgetBox).clear();
    }
  });

  test('budget totals and custom category limits persist after reopening the screen', () async {
    final categoryList = [
      CategoryModel(
        id: 'food',
        name: 'Food',
        icon: 'food',
        colorValue: 0xFFFF7043,
        isDefault: true,
      ),
      CategoryModel(
        id: 'health',
        name: 'Health',
        icon: 'health',
        colorValue: 0xFF42A5F5,
        isDefault: true,
      ),
    ];

    final controllerA = BudgetController();
    controllerA.categoriesController = CategoriesController();
    controllerA.transactionsController = TransactionsController();
    controllerA.categoriesController.categoryList.value = categoryList;

    controllerA.setTotalBudget(10000);
    controllerA.setCategoryLimit('Food', 5000);
    controllerA.setCategoryLimit('Health', 5000);
    controllerA.savePersistedState();

    final controllerB = BudgetController();
    controllerB.categoriesController = CategoriesController();
    controllerB.transactionsController = TransactionsController();
    controllerB.categoriesController.categoryList.value = categoryList;

    controllerB.loadPersistedState();

    expect(controllerB.customTotalBudget.value, 10000.0);
    expect(controllerB.customLimits['food'], 5000.0);
    expect(controllerB.customLimits['health'], 5000.0);
    expect(controllerB.totalAllocated, 10000.0);
  });
}
