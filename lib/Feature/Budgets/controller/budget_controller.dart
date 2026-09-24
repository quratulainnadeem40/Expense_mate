import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../Core/constants/app_keys.dart';
import '../../Categories/controller/categories_controller.dart';
import '../../Categories/model/categories_model.dart';
import '../../transactions/controller/transcation_controller.dart';
import '../model/budget_model.dart';

class BudgetController extends GetxController {
  late CategoriesController categoriesController;
  late TransactionsController transactionsController;

  var customLimits = <String, double>{}.obs; 
  var budgetList = <BudgetModel>[].obs;
  
  var customTotalBudget = Rxn<double>();

  Box get _budgetBox {
    if (!Hive.isBoxOpen(AppKeys.budgetBox)) {
      Hive.openBox(AppKeys.budgetBox);
    }
    return Hive.box(AppKeys.budgetBox);
  }

  static String _normalizeName(String value) => value.trim().toLowerCase();

  double _resolvedCategoryLimit(CategoryModel category) {
    final byId = customLimits[category.id];
    if (byId != null) return byId;

    final byName = customLimits[category.name];
    if (byName != null) return byName;

    return 0.0;
  }

  double getCategoryLimit(CategoryModel category) => _resolvedCategoryLimit(category);

  @override
  void onInit() {
    super.onInit();

    categoriesController = Get.isRegistered<CategoriesController>()
        ? Get.find<CategoriesController>()
        : Get.put(CategoriesController());

    transactionsController = Get.isRegistered<TransactionsController>()
        ? Get.find<TransactionsController>()
        : Get.put(TransactionsController());

    ever(transactionsController.transactions, (_) => calculateBudgets());
    ever(categoriesController.categoryList, (_) => calculateBudgets());
    ever(customLimits, (_) {
      calculateBudgets();
      savePersistedState();
    });
    ever(customTotalBudget, (_) {
      calculateBudgets();
      savePersistedState();
    });

    loadPersistedState();
    calculateBudgets();
  }

  void savePersistedState() {
    _budgetBox.put(AppKeys.monthlyBudgetKey, customTotalBudget.value);

    final serializableLimits = <String, double>{};
    for (final entry in customLimits.entries) {
      serializableLimits[entry.key] = entry.value;
    }

    _budgetBox.put(AppKeys.categoryBudgetKey, serializableLimits);
  }

  void loadPersistedState() {
    final storedBudget = _budgetBox.get(AppKeys.monthlyBudgetKey) as double?;
    if (storedBudget != null) {
      customTotalBudget.value = storedBudget;
    }

    final storedLimits = _budgetBox.get(AppKeys.categoryBudgetKey);
    if (storedLimits is Map) {
      customLimits.clear();
      for (final entry in storedLimits.entries) {
        final key = entry.key.toString();
        final value = entry.value is num ? (entry.value as num).toDouble() : 0.0;
        customLimits[key] = value;
      }
    }
  }

  void calculateBudgets() {
    final categories = categoriesController.categoryList;
    final transactionsList = transactionsController.transactions;

    final List<BudgetModel> tempList = categories.map((cat) {
      double spent = transactionsList
          .where((t) {
            final matchesCategoryId = t.categoryId.isNotEmpty &&
                t.categoryId == cat.id;
            final matchesLegacyName =
                t.categoryId.isEmpty &&
                _normalizeName(t.category) == _normalizeName(cat.name);

            return !t.isIncome && (matchesCategoryId || matchesLegacyName);
          })
          .fold(0.0, (sum, t) => sum + t.amount);

      final limit = getCategoryLimit(cat);

      return BudgetModel(
        id: cat.id,
        categoryName: cat.name,
        allocatedAmount: limit,
        spentAmount: spent,
      );
    }).toList();

    budgetList.assignAll(tempList);
  }

  double get totalAllocated => customTotalBudget.value ??
      categoriesController.categoryList.fold(0.0, (sum, category) => sum + _resolvedCategoryLimit(category));

  double get totalSpent => budgetList.fold(0.0, (sum, item) => sum + item.spentAmount).clamp(0.0, double.infinity);

  void resetMonthlySpent() {
    if (budgetList.isEmpty) return;

    budgetList.assignAll(
      budgetList.map(
        (budget) => BudgetModel(
          id: budget.id,
          categoryName: budget.categoryName,
          allocatedAmount: budget.allocatedAmount,
          spentAmount: 0.0,
        ),
      ),
    );
  }

  double get currentCategoryAllocationTotal {
    return categoriesController.categoryList.fold(0.0, (sum, category) {
      return sum + _resolvedCategoryLimit(category);
    });
  }

  double projectedAllocationAfterUpdate(
    String categoryName,
    double newLimit,
  ) {
    final normalizedName = categoryName.trim().toLowerCase();
    final existingCategory = categoriesController.categoryList.firstWhereOrNull(
      (category) => category.name.trim().toLowerCase() == normalizedName,
    );

    final previousLimit = existingCategory != null
        ? _resolvedCategoryLimit(existingCategory)
        : 0.0;

    return currentCategoryAllocationTotal - previousLimit + newLimit;
  }

  bool willExceedMonthlyBudget(String categoryName, double newLimit) {
    final monthlyLimit = customTotalBudget.value;
    if (monthlyLimit == null) return false;

    return projectedAllocationAfterUpdate(categoryName, newLimit) > monthlyLimit;
  }

  void setCategoryLimit(String categoryName, double newLimit) {
    final matchedCategory = categoriesController.categoryList.firstWhereOrNull(
      (category) => _normalizeName(category.name) == _normalizeName(categoryName),
    );

    if (matchedCategory != null) {
      customLimits[matchedCategory.id] = newLimit;
    }
    customLimits[categoryName] = newLimit;
    calculateBudgets();
  }

  void setTotalBudget(double newTotalLimit) {
    customTotalBudget.value = newTotalLimit;
    savePersistedState();
  }

  void addNewBudget(String categoryName, double amount) {
    final normalizedName = _normalizeName(categoryName);
    final existingCategory = categoriesController.categoryList.firstWhereOrNull(
      (element) => _normalizeName(element.name) == normalizedName,
    );

    if (existingCategory != null) {
      customLimits[existingCategory.id] = amount;
      customLimits[existingCategory.name] = amount;
    } else {
      final newCategory = CategoryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: categoryName,
        icon: 'attach_money',
        colorValue: 0xFF2B82FB,
        isDefault: false,
      );

      categoriesController.categoryList.add(newCategory);
      customLimits[newCategory.id] = amount;
      customLimits[newCategory.name] = amount;
    }

    savePersistedState();
    calculateBudgets();
  }
}