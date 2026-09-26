import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../Core/constants/app_keys.dart';
import '../../Categories/controller/categories_controller.dart';
import '../../Categories/model/categories_model.dart';
import '../../transactions/controller/transcation_controller.dart';
import '../../wallets/controller/wallets_controller.dart';
import '../model/budget_model.dart';

class BudgetController extends GetxController {
  late CategoriesController categoriesController;
  late TransactionsController transactionsController;

  var customLimits = <String, double>{}.obs; 
  var budgetList = <BudgetModel>[].obs;
  
  var customTotalBudget = Rxn<double>();

  // ================================================================
  // BUDGET CYCLE
  // ================================================================
  var monthStartDay = 25.obs;
  var isAutomaticReset = true.obs;
  var lastResetDate = Rxn<DateTime>();

  /// Finished cycles, newest first.
  var cycleHistory = <BudgetCycleHistory>[].obs;

  /// The automatic reset must not run before the transactions have
  /// loaded, otherwise it would act on figures that are still zero.
  bool _autoResetChecked = false;

  /// Start of the cycle the user is currently in. Every spent figure is
  /// measured from this moment.
  DateTime get cycleStartDate {
    final saved = lastResetDate.value;
    if (saved != null) return saved;

    final now = DateTime.now();
    final dayThisMonth = _clampDay(now.year, now.month, monthStartDay.value);
    final thisMonthStart = DateTime(now.year, now.month, dayThisMonth);

    if (!now.isBefore(thisMonthStart)) return thisMonthStart;

    final prev = DateTime(now.year, now.month - 1, 1);
    return DateTime(
      prev.year,
      prev.month,
      _clampDay(prev.year, prev.month, monthStartDay.value),
    );
  }

  /// The day the next reset is due.
  DateTime get nextResetDate {
    final start = cycleStartDate;
    final next = DateTime(start.year, start.month + 1, 1);
    return DateTime(
      next.year,
      next.month,
      _clampDay(next.year, next.month, monthStartDay.value),
    );
  }

  bool get isResetDue => !DateTime.now().isBefore(nextResetDate);

  /// February has no 31st, so a chosen day is pulled back to the last
  /// day the month actually has.
  static int _clampDay(int year, int month, int day) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return day > lastDay ? lastDay : day;
  }

  void setMonthStartDay(int day) {
    monthStartDay.value = day;
    savePersistedState();
    calculateBudgets();
    checkAutoReset();
  }

  void setAutomaticReset(bool value) {
    isAutomaticReset.value = value;
    savePersistedState();
    checkAutoReset();
  }

  /// Fires by itself once the next reset date has arrived, but only
  /// while the user has chosen Automatic.
  Future<void> checkAutoReset() async {
    if (!isAutomaticReset.value) return;
    if (!isResetDue) return;

    await performReset(auto: true);
  }

  /// Starts a fresh budget month.
  ///
  /// Nothing is deleted. The cycle start simply moves to now, so every
  /// spent figure and progress bar drops to zero and stays there.
  /// Limits, categories and transactions are untouched; wallet balances
  /// are cleared but the wallets themselves are kept.
  Future<void> performReset({bool auto = false}) async {
    _archiveCurrentCycle(auto: auto);

    lastResetDate.value = DateTime.now();
    savePersistedState();
    calculateBudgets();

    final walletsController = Get.isRegistered<WalletsController>()
        ? Get.find<WalletsController>()
        : null;

    if (walletsController != null && walletsController.wallets.isNotEmpty) {
      await walletsController.resetAllBalances();
    }

    if (!auto) return;

    Get.snackbar(
      'New budget month',
      'Your budget has been reset for this cycle.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

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

    ever(transactionsController.transactions, (_) {
      calculateBudgets();

      // First real load of the transactions: now the figures are true,
      // so it is safe to roll the cycle over.
      if (!_autoResetChecked) {
        _autoResetChecked = true;
        checkAutoReset();
      }
    });
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

    if (transactionsController.transactions.isNotEmpty) {
      _autoResetChecked = true;
      checkAutoReset();
    }
  }

  void savePersistedState() {
    _budgetBox.put(AppKeys.monthlyBudgetKey, customTotalBudget.value);

    final serializableLimits = <String, double>{};
    for (final entry in customLimits.entries) {
      serializableLimits[entry.key] = entry.value;
    }

    _budgetBox.put(AppKeys.categoryBudgetKey, serializableLimits);

    _budgetBox.put(AppKeys.budgetMonthStartDayKey, monthStartDay.value);
    _budgetBox.put(AppKeys.budgetResetModeKey, isAutomaticReset.value);
    _budgetBox.put(
      AppKeys.budgetLastResetKey,
      lastResetDate.value?.toIso8601String(),
    );
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

    final storedDay = _budgetBox.get(AppKeys.budgetMonthStartDayKey);
    if (storedDay is int && storedDay >= 1 && storedDay <= 31) {
      monthStartDay.value = storedDay;
    }

    final storedMode = _budgetBox.get(AppKeys.budgetResetModeKey);
    if (storedMode is bool) {
      isAutomaticReset.value = storedMode;
    }

    final storedReset = _budgetBox.get(AppKeys.budgetLastResetKey);
    if (storedReset is String) {
      lastResetDate.value = DateTime.tryParse(storedReset);
    }

    final storedHistory = _budgetBox.get(AppKeys.budgetHistoryKey);
    if (storedHistory is List) {
      try {
        cycleHistory.assignAll(
          storedHistory
              .map((e) => BudgetCycleHistory.fromMap(
                    Map<String, dynamic>.from(e as Map),
                  ))
              .toList(),
        );
      } catch (_) {
        cycleHistory.clear();
      }
    }
  }

  void _saveHistory() {
    _budgetBox.put(
      AppKeys.budgetHistoryKey,
      cycleHistory.map((c) => c.toMap()).toList(),
    );
  }

  void deleteHistoryEntry(String id) {
    cycleHistory.removeWhere((c) => c.id == id);
    _saveHistory();
  }

  void clearHistory() {
    cycleHistory.clear();
    _saveHistory();
  }

  /// Saves the cycle that is ending, so the history screen can show what
  /// the limit was, what was spent, and what was left over.
  void _archiveCurrentCycle({required bool auto}) {
    final spent = totalSpent;
    final limit = totalAllocated;

    if (spent <= 0 && limit <= 0) return;

    final entries = budgetList
        .where((b) => b.spentAmount > 0 || b.allocatedAmount > 0)
        .map(
          (b) => CategoryCycleEntry(
            name: b.categoryName,
            limit: b.allocatedAmount,
            spent: b.spentAmount,
          ),
        )
        .toList()
      ..sort((a, b) => b.spent.compareTo(a.spent));

    final end = DateTime.now();

    cycleHistory.insert(
      0,
      BudgetCycleHistory(
        id: end.millisecondsSinceEpoch.toString(),
        startDate: cycleStartDate,
        endDate: end,
        totalLimit: limit,
        totalSpent: spent,
        categories: entries,
        wasAutomatic: auto,
      ),
    );

    // Two years of cycles is plenty.
    if (cycleHistory.length > 24) {
      cycleHistory.removeRange(24, cycleHistory.length);
    }

    _saveHistory();
  }

  void calculateBudgets() {
    final categories = categoriesController.categoryList;
    final transactionsList = transactionsController.transactions;

    // Categories are empty for a moment while they reload. Rebuilding
    // from an empty list would blank the whole screen, so keep what is
    // already there until real categories arrive.
    if (categories.isEmpty && budgetList.isNotEmpty) return;

    // Only the transactions inside the current cycle. Without this the
    // spent totals were the whole history, which is why a reset used to
    // come straight back.
    final cycleStart = cycleStartDate;

    final List<BudgetModel> tempList = categories.map((cat) {
      double spent = transactionsList
          .where((t) {
            if (t.transactionDate.isBefore(cycleStart)) return false;

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

  /// Kept for older call sites.
  void resetMonthlySpent() {
    performReset();
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