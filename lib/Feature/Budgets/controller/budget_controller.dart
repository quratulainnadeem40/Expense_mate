import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../Core/constants/app_keys.dart';
import '../../Categories/controller/categories_controller.dart';
import '../../Categories/model/categories_model.dart';
import '../../transactions/controller/transcation_controller.dart';
import '../../../Core/service/notification_service.dart';
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
  // Step 23 - defaults for a user who never opens the settings.
  // The 1st with automatic reset behaves like an ordinary calendar
  // month, which is what most people expect without being told.
  //
  // Anyone who already chose a day keeps it: loadPersistedState()
  // overwrites these as soon as a stored value is found.
  static const int defaultMonthStartDay = 1;
  static const bool defaultAutomaticReset = true;

  var monthStartDay = defaultMonthStartDay.obs;
  var isAutomaticReset = defaultAutomaticReset.obs;

  /// True until the user saves the cycle for the first time. Step 22
  /// uses this to decide whether to offer the setup screen.
  var isCycleConfigured = false.obs;
  var lastResetDate = Rxn<DateTime>();

  /// Step 18 - optional reminder before the automatic reset.
  var resetReminderOn = true.obs;
  var reminderDaysBefore = 1.obs;

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
  ///
  /// It is always the next occurrence of the chosen day, not "one month
  /// after whatever date the last reset happened on". So a manual reset
  /// on the 10th with a start day of 25 still points at the 25th of that
  /// same month, not the 25th of the following one.
  DateTime get nextResetDate {
    final start = cycleStartDate;

    // lastResetDate carries a time of day, so compare dates only.
    final startDate = DateTime(start.year, start.month, start.day);

    final thisMonth = DateTime(
      start.year,
      start.month,
      _clampDay(start.year, start.month, monthStartDay.value),
    );

    if (thisMonth.isAfter(startDate)) return thisMonth;

    final next = DateTime(start.year, start.month + 1, 1);
    return DateTime(
      next.year,
      next.month,
      _clampDay(next.year, next.month, monthStartDay.value),
    );
  }

  /// Last day of the cycle: the day before the next reset.
  ///
  /// With a start day of 25 this gives 25 Aug - 24 Sep, 25 Sep - 24 Oct,
  /// and so on, rather than plain calendar months.
  DateTime get cycleEndDate =>
      nextResetDate.subtract(const Duration(days: 1));

  /// The cycle's first day with the time stripped off.
  ///
  /// cycleStartDate keeps the exact moment of the reset because the spend
  /// filter needs it, but anything shown on screen should use this.
  DateTime get cycleStartDay {
    final start = cycleStartDate;
    return DateTime(start.year, start.month, start.day);
  }

  /// How many days the current cycle covers.
  int get cycleLengthInDays =>
      cycleEndDate.difference(cycleStartDay).inDays + 1;

  /// How many days are left before the reset. 0 on the last day.
  int get daysLeftInCycle {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final left = cycleEndDate.difference(today).inDays;
    return left < 0 ? 0 : left;
  }

  static const List<String> _shortMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// Ready to display, e.g. "25 Sep - 24 Oct".
  String get cycleLabel {
    final start = cycleStartDay;
    final end = cycleEndDate;

    return '${start.day} ${_shortMonths[start.month - 1]}'
        ' - ${end.day} ${_shortMonths[end.month - 1]}';
  }

  bool get isResetDue => !DateTime.now().isBefore(nextResetDate);

  /// February has no 31st, so a chosen day is pulled back to the last
  /// day the month actually has.
  static int _clampDay(int year, int month, int day) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return day > lastDay ? lastDay : day;
  }

  /// What the next reset would be if the start day were [candidateDay].
  ///
  /// Used by the confirmation dialog so the user can see the effect of
  /// the change before committing to it.
  DateTime previewNextReset(int candidateDay) {
    final start = cycleStartDate;
    final startDate = DateTime(start.year, start.month, start.day);

    final thisMonth = DateTime(
      start.year,
      start.month,
      _clampDay(start.year, start.month, candidateDay),
    );

    if (thisMonth.isAfter(startDate)) return thisMonth;

    final next = DateTime(start.year, start.month + 1, 1);
    return DateTime(
      next.year,
      next.month,
      _clampDay(next.year, next.month, candidateDay),
    );
  }

  /// The current cycle as it would end up with [candidateDay],
  /// e.g. "25 Sep - 9 Oct".
  String previewCycleLabel(int candidateDay) {
    final start = cycleStartDay;
    final end = previewNextReset(candidateDay)
        .subtract(const Duration(days: 1));

    return '${start.day} ${_shortMonths[start.month - 1]}'
        ' - ${end.day} ${_shortMonths[end.month - 1]}';
  }

  /// The cycle that begins after the change, e.g. "10 Oct - 9 Nov".
  String previewNextCycleLabel(int candidateDay) {
    final start = previewNextReset(candidateDay);

    final afterMonth = DateTime(start.year, start.month + 1, 1);
    final end = DateTime(
      afterMonth.year,
      afterMonth.month,
      _clampDay(afterMonth.year, afterMonth.month, candidateDay),
    ).subtract(const Duration(days: 1));

    return '${start.day} ${_shortMonths[start.month - 1]}'
        ' - ${end.day} ${_shortMonths[end.month - 1]}';
  }

  /// Records that the user has been through the cycle setup, so the
  /// first-time screen is not offered again.
  void markCycleConfigured() {
    isCycleConfigured.value = true;
    savePersistedState();
    syncResetReminder();
  }

  void setMonthStartDay(int day) {
    monthStartDay.value = day;
    isCycleConfigured.value = true;
    savePersistedState();
    calculateBudgets();
    checkAutoReset();
    syncResetReminder();
  }

  void setAutomaticReset(bool value) {
    isAutomaticReset.value = value;
    isCycleConfigured.value = true;
    savePersistedState();
    checkAutoReset();
    syncResetReminder();
  }

  void setResetReminderOn(bool value) {
    resetReminderOn.value = value;
    savePersistedState();
    syncResetReminder();
  }

  void setReminderDaysBefore(int days) {
    reminderDaysBefore.value = days;
    savePersistedState();
    syncResetReminder();
  }

  /// Books the reminder, or clears it when it should not fire.
  ///
  /// Called after anything that moves the reset date, so there is never
  /// a leftover notification pointing at an old date.
  Future<void> syncResetReminder() async {
    final service = NotificationService();

    // Manual mode never resets on its own, so a reminder would be a lie.
    if (!resetReminderOn.value || !isAutomaticReset.value) {
      await service.cancelBudgetResetReminder();
      return;
    }

    await service.scheduleBudgetResetReminder(
      resetDate: nextResetDate,
      daysBefore: reminderDaysBefore.value,
      budgetAmount: totalAllocated,
      spentAmount: totalSpent,
    );
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

    // The reset date has just moved, so the reminder must move with it.
    // Without this, the old notification would still be pointing at the
    // date that has already passed.
    await syncResetReminder();

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
        syncResetReminder();
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

    // Written for reference and for the reset reminder to read. The app
    // never trusts this copy for its own logic - nextResetDate is always
    // recalculated, so a stale value can never send the cycle wrong.
    _budgetBox.put(
      AppKeys.budgetNextResetKey,
      nextResetDate.toIso8601String(),
    );

    _budgetBox.put(AppKeys.budgetReminderOnKey, resetReminderOn.value);
    _budgetBox.put(AppKeys.budgetReminderDaysKey, reminderDaysBefore.value);
    _budgetBox.put(
      AppKeys.budgetCycleConfiguredKey,
      isCycleConfigured.value,
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

    // Its own key, because savePersistedState() also runs when a category
    // limit changes - that must not count as configuring the cycle.
    isCycleConfigured.value =
        _budgetBox.get(AppKeys.budgetCycleConfiguredKey) == true;

    final storedMode = _budgetBox.get(AppKeys.budgetResetModeKey);
    if (storedMode is bool) {
      isAutomaticReset.value = storedMode;
    }

    final storedReset = _budgetBox.get(AppKeys.budgetLastResetKey);
    if (storedReset is String) {
      lastResetDate.value = DateTime.tryParse(storedReset);
    }

    // budgetNextResetKey is deliberately not read back. It is a record,
    // not a source of truth.

    final storedReminderOn = _budgetBox.get(AppKeys.budgetReminderOnKey);
    if (storedReminderOn is bool) {
      resetReminderOn.value = storedReminderOn;
    }

    final storedReminderDays = _budgetBox.get(AppKeys.budgetReminderDaysKey);
    if (storedReminderDays is int &&
        storedReminderDays >= 1 &&
        storedReminderDays <= 3) {
      reminderDaysBefore.value = storedReminderDays;
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

  // ================================================================
  // STEP 27 - overspending
  // ================================================================

  /// True once the cycle's spending has passed the budget.
  bool get isOverBudget =>
      totalAllocated > 0 && totalSpent > totalAllocated;

  /// How far past the budget the user is. Zero when still within it.
  double get overspentAmount {
    final over = totalSpent - totalAllocated;
    return over > 0 ? over : 0;
  }

  /// 0.0 to 1.0 for the bar. Stays full once the budget is passed.
  double get spendProgress {
    if (totalAllocated <= 0) return 0;
    return (totalSpent / totalAllocated).clamp(0.0, 1.0);
  }

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