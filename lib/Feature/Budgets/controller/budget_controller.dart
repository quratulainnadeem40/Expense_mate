import 'dart:async';
import 'dart:math';

import 'package:expense_mate/Core/Database/sync/sync_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:expense_mate/Core/constants/app_keys.dart';
import 'package:expense_mate/Core/Database/repository_provider.dart';
import 'package:expense_mate/Core/Database/repositories/budget_local_repository.dart';
import 'package:expense_mate/Core/Database/repositories/budget_sync_repository.dart';

import 'package:expense_mate/Core/service/notification_service.dart';

import '../../Categories/controller/categories_controller.dart';
import '../../Categories/model/categories_model.dart';
import '../../transactions/controller/transcation_controller.dart';
import '../../wallets/controller/wallets_controller.dart';
import '../model/budget_model.dart';

class BudgetController extends GetxController {
  late CategoriesController categoriesController;
  late TransactionsController transactionsController;

  late final BudgetLocalRepository budgetLocal;
  late final BudgetSyncRepository budgetSync;

  var customLimits = <String, double>{}.obs;
  var budgetList = <BudgetModel>[].obs;

  var customTotalBudget = Rxn<double>();

  // ================================================================
  // BUDGET CYCLE
  // ================================================================

  static const int defaultMonthStartDay = 1;
  static const bool defaultAutomaticReset = true;

  var monthStartDay = defaultMonthStartDay.obs;
  var isAutomaticReset = defaultAutomaticReset.obs;

  var isCycleConfigured = false.obs;
  var lastResetDate = Rxn<DateTime>();

  var resetReminderOn = true.obs;
  var reminderDaysBefore = 1.obs;

  var cycleHistory = <BudgetCycleHistory>[].obs;

  bool _autoResetChecked = false;

  bool _databaseBudgetsLoaded = false;

  // ================================================================
  // DATABASE
  // ================================================================

  String? get _currentUserId =>
      Supabase.instance.client.auth.currentUser?.id;

  // ================================================================
  // CYCLE DATES
  // ================================================================

  DateTime get cycleStartDate {
    final saved = lastResetDate.value;

    if (saved != null) {
      return saved;
    }

    final now = DateTime.now();

    final dayThisMonth =
        _clampDay(now.year, now.month, monthStartDay.value);

    final thisMonthStart =
        DateTime(now.year, now.month, dayThisMonth);

    if (!now.isBefore(thisMonthStart)) {
      return thisMonthStart;
    }

    final prev =
        DateTime(now.year, now.month - 1, 1);

    return DateTime(
      prev.year,
      prev.month,
      _clampDay(
        prev.year,
        prev.month,
        monthStartDay.value,
      ),
    );
  }

  DateTime get nextResetDate {
    final start = cycleStartDate;

    final startDate =
        DateTime(start.year, start.month, start.day);

    final thisMonth = DateTime(
      start.year,
      start.month,
      _clampDay(
        start.year,
        start.month,
        monthStartDay.value,
      ),
    );

    if (thisMonth.isAfter(startDate)) {
      return thisMonth;
    }

    final next =
        DateTime(start.year, start.month + 1, 1);

    return DateTime(
      next.year,
      next.month,
      _clampDay(
        next.year,
        next.month,
        monthStartDay.value,
      ),
    );
  }

  DateTime get cycleEndDate =>
      nextResetDate.subtract(
        const Duration(days: 1),
      );

  DateTime get cycleStartDay {
    final start = cycleStartDate;

    return DateTime(
      start.year,
      start.month,
      start.day,
    );
  }

  int get cycleLengthInDays =>
      cycleEndDate
          .difference(cycleStartDay)
          .inDays +
      1;

  int get daysLeftInCycle {
    final now = DateTime.now();

    final today =
        DateTime(now.year, now.month, now.day);

    final left =
        cycleEndDate.difference(today).inDays;

    return left < 0 ? 0 : left;
  }

  static const List<String> _shortMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String get cycleLabel {
    final start = cycleStartDay;
    final end = cycleEndDate;

    return '${start.day} ${_shortMonths[start.month - 1]}'
        ' - ${end.day} ${_shortMonths[end.month - 1]}';
  }

  bool get isResetDue =>
      !DateTime.now().isBefore(nextResetDate);

  static int _clampDay(
    int year,
    int month,
    int day,
  ) {
    final lastDay =
        DateTime(year, month + 1, 0).day;

    return day > lastDay ? lastDay : day;
  }

  // ================================================================
  // CYCLE PREVIEWS
  // ================================================================

  DateTime previewNextReset(int candidateDay) {
    final start = cycleStartDate;

    final startDate =
        DateTime(start.year, start.month, start.day);

    final thisMonth = DateTime(
      start.year,
      start.month,
      _clampDay(
        start.year,
        start.month,
        candidateDay,
      ),
    );

    if (thisMonth.isAfter(startDate)) {
      return thisMonth;
    }

    final next =
        DateTime(start.year, start.month + 1, 1);

    return DateTime(
      next.year,
      next.month,
      _clampDay(
        next.year,
        next.month,
        candidateDay,
      ),
    );
  }

  String previewCycleLabel(int candidateDay) {
    final start = cycleStartDay;

    final end = previewNextReset(candidateDay)
        .subtract(
          const Duration(days: 1),
        );

    return '${start.day} ${_shortMonths[start.month - 1]}'
        ' - ${end.day} ${_shortMonths[end.month - 1]}';
  }

  String previewNextCycleLabel(int candidateDay) {
    final start =
        previewNextReset(candidateDay);

    final afterMonth =
        DateTime(start.year, start.month + 1, 1);

    final end = DateTime(
      afterMonth.year,
      afterMonth.month,
      _clampDay(
        afterMonth.year,
        afterMonth.month,
        candidateDay,
      ),
    ).subtract(
      const Duration(days: 1),
    );

    return '${start.day} ${_shortMonths[start.month - 1]}'
        ' - ${end.day} ${_shortMonths[end.month - 1]}';
  }

  // ================================================================
  // CYCLE SETTINGS
  // ================================================================

  void markCycleConfigured() {
    isCycleConfigured.value = true;

    savePersistedState();

    syncResetReminder();

    _syncCurrentBudgetsToDatabase();
  }

  void setMonthStartDay(int day) {
    monthStartDay.value = day;

    isCycleConfigured.value = true;

    savePersistedState();

    calculateBudgets();

    checkAutoReset();

    syncResetReminder();

    _syncCurrentBudgetsToDatabase();
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

  // ================================================================
  // RESET REMINDER
  // ================================================================

  Future<void> syncResetReminder() async {
    final service = NotificationService();

    if (!resetReminderOn.value ||
        !isAutomaticReset.value) {
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

  // ================================================================
  // AUTO RESET
  // ================================================================

  Future<void> checkAutoReset() async {
    if (!isAutomaticReset.value) return;

    if (!isResetDue) return;

    await performReset(auto: true);
  }

  Future<void> performReset({
    bool auto = false,
  }) async {
    _archiveCurrentCycle(auto: auto);

    lastResetDate.value =
        DateTime.now();

    savePersistedState();

    calculateBudgets();

    final walletsController =
        Get.isRegistered<WalletsController>()
            ? Get.find<WalletsController>()
            : null;

    if (walletsController != null &&
        walletsController.wallets.isNotEmpty) {
      await walletsController.resetAllBalances();
    }

    await syncResetReminder();

    // Create the new cycle's budget rows locally
    // and place them into the sync queue.
    await _syncCurrentBudgetsToDatabase();

    if (!auto) return;

    // Existing behavior preserved.
    // No Get.snackbar here because it can cause the
    // GetX Web animation crash you previously encountered.
  }

  // ================================================================
  // HIVE
  // ================================================================

  Box get _budgetBox {
    if (!Hive.isBoxOpen(AppKeys.budgetBox)) {
      Hive.openBox(AppKeys.budgetBox);
    }

    return Hive.box(AppKeys.budgetBox);
  }

  // ================================================================
  // CATEGORY LIMIT
  // ================================================================

  static String _normalizeName(String value) =>
      value.trim().toLowerCase();

  double _resolvedCategoryLimit(
    CategoryModel category,
  ) {
    final byId =
        customLimits[category.id];

    if (byId != null) {
      return byId;
    }

    final byName =
        customLimits[category.name];

    if (byName != null) {
      return byName;
    }

    return 0.0;
  }

  double getCategoryLimit(
    CategoryModel category,
  ) {
    return _resolvedCategoryLimit(category);
  }

  // ================================================================
  // INIT
  // ================================================================

  @override
  void onInit() {
    super.onInit();

    budgetLocal =
        RepositoryProvider.instance.budgets;

    budgetSync =
        RepositoryProvider.instance.budgetSync;

    categoriesController =
        Get.isRegistered<CategoriesController>()
            ? Get.find<CategoriesController>()
            : Get.put(CategoriesController());

    transactionsController =
        Get.isRegistered<TransactionsController>()
            ? Get.find<TransactionsController>()
            : Get.put(TransactionsController());

    ever(
      transactionsController.transactions,
      (_) {
        calculateBudgets();

        if (!_autoResetChecked) {
          _autoResetChecked = true;

          checkAutoReset();

          syncResetReminder();
        }
      },
    );

    ever(
      categoriesController.categoryList,
      (_) {
        calculateBudgets();
      },
    );

    ever(
      customLimits,
      (_) {
        calculateBudgets();

        savePersistedState();
      },
    );

    ever(
      customTotalBudget,
      (_) {
        calculateBudgets();

        savePersistedState();
      },
    );

    loadPersistedState();

    calculateBudgets();

    if (transactionsController.transactions.isNotEmpty) {
      _autoResetChecked = true;

      checkAutoReset();
    }

    // Load the local Drift budget records.
    unawaited(
      _initializeDatabaseBudgets(),
    );
  }

  // ================================================================
  // DATABASE INITIALIZATION
  // ================================================================

  Future<void> _initializeDatabaseBudgets() async {
    final userId = _currentUserId;

    if (userId == null) {
      return;
    }

    try {
      // First load the local database.
      await _loadBudgetsFromLocalDatabase(
        userId,
      );

      _databaseBudgetsLoaded = true;

      calculateBudgets();

      // Then trigger the existing SyncManager.
      //
      // SyncManager uploads pending local records and
      // downloads cloud records.
      if (Get.isRegistered<SyncManager>()) {
        final syncManager =
            Get.find<SyncManager>();

        try {
          await syncManager.sync();
        } catch (e) {
          debugPrint(
            'Budget initial sync failed: $e',
          );
        }

        // SyncManager may have received new cloud
        // budget rows, so load Drift again.
        await _loadBudgetsFromLocalDatabase(
          userId,
        );

        calculateBudgets();
      }
    } catch (e, stackTrace) {
      debugPrint(
        'Budget database initialization failed: $e',
      );

      debugPrint(
        '$stackTrace',
      );
    }
  }

  // ================================================================
  // LOAD DRIFT → CONTROLLER
  // ================================================================

  Future<void> _loadBudgetsFromLocalDatabase(
    String userId,
  ) async {
    final budgets =
        await budgetLocal.getBudgets(userId);

    final currentStart =
        _dateOnly(cycleStartDate);

    final currentEnd =
        _dateOnly(cycleEndDate);

    for (final budget in budgets) {
      final budgetStart =
          _dateOnly(budget.startDate);

      final budgetEnd =
          _dateOnly(budget.endDate);

      // Only load the current cycle into the
      // active BudgetController values.
      if (!_sameDate(
            budgetStart,
            currentStart,
          ) ||
          !_sameDate(
            budgetEnd,
            currentEnd,
          )) {
        continue;
      }

      // Total budget has no category.
      if (budget.categoryId == null) {
        customTotalBudget.value =
            budget.amount;

        continue;
      }

      final categoryId =
          budget.categoryId!;

      customLimits[categoryId] =
          budget.amount;

      // Keep the category-name key too because
      // the existing controller supports both.
      final category =
          categoriesController.categoryList
              .firstWhereOrNull(
        (category) =>
            category.id == categoryId,
      );

      if (category != null) {
        customLimits[category.name] =
            budget.amount;
      }
    }
  }

  // ================================================================
  // SYNC CURRENT BUDGETS
  // ================================================================

  Future<void> _syncCurrentBudgetsToDatabase() async {
    final userId = _currentUserId;

    if (userId == null) {
      return;
    }

    try {
      // ------------------------------------------------------------
      // TOTAL BUDGET
      // ------------------------------------------------------------

      if (customTotalBudget.value != null) {
        await _saveTotalBudgetToDatabase(
          userId: userId,
          amount: customTotalBudget.value!,
        );
      }

      // ------------------------------------------------------------
      // CATEGORY BUDGETS
      // ------------------------------------------------------------

      for (final category
          in categoriesController.categoryList) {
        final amount =
            _resolvedCategoryLimit(category);

        // No need to create zero-value database
        // records for categories that have never
        // received a budget.
        if (amount <= 0) {
          continue;
        }

        await _saveCategoryBudgetToDatabase(
          userId: userId,
          category: category,
          amount: amount,
        );
      }

      // ------------------------------------------------------------
      // ASK SYNCMANAGER TO PROCESS QUEUE
      // ------------------------------------------------------------

      if (Get.isRegistered<SyncManager>()) {
        final syncManager =
            Get.find<SyncManager>();

        try {
          await syncManager.sync();
        } catch (e) {
          debugPrint(
            'Budget sync failed: $e',
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint(
        'Could not save budgets to database: $e',
      );

      debugPrint(
        '$stackTrace',
      );
    }
  }

  // ================================================================
  // SAVE CATEGORY BUDGET
  // ================================================================

  Future<void> _saveCategoryBudgetToDatabase({
    required String userId,
    required CategoryModel category,
    required double amount,
  }) async {
    final budgets =
        await budgetLocal.getBudgets(userId);

    final currentStart =
        _dateOnly(cycleStartDate);

    final currentEnd =
        _dateOnly(cycleEndDate);

    final existing =
        budgets.firstWhereOrNull(
      (budget) {
        return budget.categoryId ==
                category.id &&
            _sameDate(
              _dateOnly(budget.startDate),
              currentStart,
            ) &&
            _sameDate(
              _dateOnly(budget.endDate),
              currentEnd,
            );
      },
    );

    if (existing == null) {
      await budgetSync.createBudget(
        id: _generateUuid(),
        userId: userId,
        categoryId: category.id,
        name: category.name,
        amount: amount,
        spent: 0.0,
        startDate: cycleStartDate,
        endDate: cycleEndDate,
      );

      return;
    }

    await budgetSync.updateBudget(
      id: existing.id,
      userId: userId,
      categoryId: category.id,
      name: category.name,
      amount: amount,
      spent: existing.spent,
      startDate: cycleStartDate,
      endDate: cycleEndDate,
      createdAt: existing.createdAt,
      version: existing.version,
    );
  }

  // ================================================================
  // SAVE TOTAL BUDGET
  // ================================================================

  Future<void> _saveTotalBudgetToDatabase({
    required String userId,
    required double amount,
  }) async {
    final budgets =
        await budgetLocal.getBudgets(userId);

    final currentStart =
        _dateOnly(cycleStartDate);

    final currentEnd =
        _dateOnly(cycleEndDate);

    final existing =
        budgets.firstWhereOrNull(
      (budget) {
        return budget.categoryId == null &&
            _sameDate(
              _dateOnly(budget.startDate),
              currentStart,
            ) &&
            _sameDate(
              _dateOnly(budget.endDate),
              currentEnd,
            );
      },
    );

    if (existing == null) {
      await budgetSync.createBudget(
        id: _generateUuid(),
        userId: userId,
        categoryId: null,
        name: 'Total Budget',
        amount: amount,
        spent: 0.0,
        startDate: cycleStartDate,
        endDate: cycleEndDate,
      );

      return;
    }

    await budgetSync.updateBudget(
      id: existing.id,
      userId: userId,
      categoryId: null,
      name: existing.name,
      amount: amount,
      spent: existing.spent,
      startDate: cycleStartDate,
      endDate: cycleEndDate,
      createdAt: existing.createdAt,
      version: existing.version,
    );
  }

  // ================================================================
  // DATE HELPERS
  // ================================================================

  DateTime _dateOnly(DateTime value) {
    return DateTime(
      value.year,
      value.month,
      value.day,
    );
  }

  bool _sameDate(
    DateTime first,
    DateTime second,
  ) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  // ================================================================
  // UUID
  // ================================================================

  String _generateUuid() {
    final random = Random.secure();

    final bytes = List<int>.generate(
      16,
      (_) => random.nextInt(256),
    );

    // UUID version 4.
    bytes[6] =
        (bytes[6] & 0x0f) | 0x40;

    // UUID variant RFC 4122.
    bytes[8] =
        (bytes[8] & 0x3f) | 0x80;

    final hex = bytes
        .map(
          (byte) => byte
              .toRadixString(16)
              .padLeft(2, '0'),
        )
        .join();

    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20, 32)}';
  }

  // ================================================================
  // HIVE PERSISTENCE
  // ================================================================

  void savePersistedState() {
    _budgetBox.put(
      AppKeys.monthlyBudgetKey,
      customTotalBudget.value,
    );

    final serializableLimits =
        <String, double>{};

    for (final entry
        in customLimits.entries) {
      serializableLimits[entry.key] =
          entry.value;
    }

    _budgetBox.put(
      AppKeys.categoryBudgetKey,
      serializableLimits,
    );

    _budgetBox.put(
      AppKeys.budgetMonthStartDayKey,
      monthStartDay.value,
    );

    _budgetBox.put(
      AppKeys.budgetResetModeKey,
      isAutomaticReset.value,
    );

    _budgetBox.put(
      AppKeys.budgetLastResetKey,
      lastResetDate.value?.toIso8601String(),
    );

    _budgetBox.put(
      AppKeys.budgetNextResetKey,
      nextResetDate.toIso8601String(),
    );

    _budgetBox.put(
      AppKeys.budgetReminderOnKey,
      resetReminderOn.value,
    );

    _budgetBox.put(
      AppKeys.budgetReminderDaysKey,
      reminderDaysBefore.value,
    );

    _budgetBox.put(
      AppKeys.budgetCycleConfiguredKey,
      isCycleConfigured.value,
    );
  }

  void loadPersistedState() {
    final storedBudget =
        _budgetBox.get(
      AppKeys.monthlyBudgetKey,
    ) as double?;

    if (storedBudget != null) {
      customTotalBudget.value =
          storedBudget;
    }

    final storedLimits =
        _budgetBox.get(
      AppKeys.categoryBudgetKey,
    );

    if (storedLimits is Map) {
      customLimits.clear();

      for (final entry
          in storedLimits.entries) {
        final key =
            entry.key.toString();

        final value =
            entry.value is num
                ? (entry.value as num).toDouble()
                : 0.0;

        customLimits[key] = value;
      }
    }

    final storedDay =
        _budgetBox.get(
      AppKeys.budgetMonthStartDayKey,
    );

    if (storedDay is int &&
        storedDay >= 1 &&
        storedDay <= 31) {
      monthStartDay.value =
          storedDay;
    }

    isCycleConfigured.value =
        _budgetBox.get(
              AppKeys.budgetCycleConfiguredKey,
            ) ==
            true;

    final storedMode =
        _budgetBox.get(
      AppKeys.budgetResetModeKey,
    );

    if (storedMode is bool) {
      isAutomaticReset.value =
          storedMode;
    }

    final storedReset =
        _budgetBox.get(
      AppKeys.budgetLastResetKey,
    );

    if (storedReset is String) {
      lastResetDate.value =
          DateTime.tryParse(
        storedReset,
      );
    }

    final storedReminderOn =
        _budgetBox.get(
      AppKeys.budgetReminderOnKey,
    );

    if (storedReminderOn is bool) {
      resetReminderOn.value =
          storedReminderOn;
    }

    final storedReminderDays =
        _budgetBox.get(
      AppKeys.budgetReminderDaysKey,
    );

    if (storedReminderDays is int &&
        storedReminderDays >= 1 &&
        storedReminderDays <= 3) {
      reminderDaysBefore.value =
          storedReminderDays;
    }

    final storedHistory =
        _budgetBox.get(
      AppKeys.budgetHistoryKey,
    );

    if (storedHistory is List) {
      try {
        cycleHistory.assignAll(
          storedHistory
              .map(
                (e) =>
                    BudgetCycleHistory.fromMap(
                  Map<String, dynamic>.from(
                    e as Map,
                  ),
                ),
              )
              .toList(),
        );
      } catch (_) {
        cycleHistory.clear();
      }
    }
  }

  // ================================================================
  // HISTORY
  // ================================================================

  void _saveHistory() {
    _budgetBox.put(
      AppKeys.budgetHistoryKey,
      cycleHistory
          .map((c) => c.toMap())
          .toList(),
    );
  }

  void deleteHistoryEntry(String id) {
    cycleHistory.removeWhere(
      (c) => c.id == id,
    );

    _saveHistory();
  }

  void clearHistory() {
    cycleHistory.clear();

    _saveHistory();
  }

  void _archiveCurrentCycle({
    required bool auto,
  }) {
    final spent = totalSpent;
    final limit = totalAllocated;

    if (spent <= 0 && limit <= 0) {
      return;
    }

    final entries = budgetList
        .where(
          (b) =>
              b.spentAmount > 0 ||
              b.allocatedAmount > 0,
        )
        .map(
          (b) => CategoryCycleEntry(
            name: b.categoryName,
            limit: b.allocatedAmount,
            spent: b.spentAmount,
          ),
        )
        .toList()
      ..sort(
        (a, b) =>
            b.spent.compareTo(a.spent),
      );

    final end =
        DateTime.now();

    cycleHistory.insert(
      0,
      BudgetCycleHistory(
        id: end.millisecondsSinceEpoch
            .toString(),
        startDate: cycleStartDate,
        endDate: end,
        totalLimit: limit,
        totalSpent: spent,
        categories: entries,
        wasAutomatic: auto,
      ),
    );

    if (cycleHistory.length > 24) {
      cycleHistory.removeRange(
        24,
        cycleHistory.length,
      );
    }

    _saveHistory();
  }

  // ================================================================
  // CALCULATIONS
  // ================================================================

  void calculateBudgets() {
    final categories =
        categoriesController.categoryList;

    final transactionsList =
        transactionsController.transactions;

    if (categories.isEmpty &&
        budgetList.isNotEmpty) {
      return;
    }

    final cycleStart =
        cycleStartDate;

    final List<BudgetModel> tempList =
        categories.map((cat) {
      final spent = transactionsList
          .where(
            (t) {
              if (t.transactionDate
                  .isBefore(cycleStart)) {
                return false;
              }

              final matchesCategoryId =
                  t.categoryId.isNotEmpty &&
                      t.categoryId == cat.id;

              final matchesLegacyName =
                  t.categoryId.isEmpty &&
                      _normalizeName(
                            t.category,
                          ) ==
                          _normalizeName(
                            cat.name,
                          );

              return !t.isIncome &&
                  (matchesCategoryId ||
                      matchesLegacyName);
            },
          )
          .fold(
            0.0,
            (sum, t) =>
                sum + t.amount,
          );

      final limit =
          getCategoryLimit(cat);

      return BudgetModel(
        id: cat.id,
        categoryName: cat.name,
        allocatedAmount: limit,
        spentAmount: spent,
      );
    }).toList();

    budgetList.assignAll(
      tempList,
    );
  }

  double get totalAllocated =>
      customTotalBudget.value ??
      categoriesController.categoryList
          .fold(
        0.0,
        (sum, category) =>
            sum +
            _resolvedCategoryLimit(
              category,
            ),
      );

  double get totalSpent =>
      budgetList
          .fold(
            0.0,
            (sum, item) =>
                sum + item.spentAmount,
          )
          .clamp(
            0.0,
            double.infinity,
          );

  // ================================================================
  // OVERSpending
  // ================================================================

  bool get isOverBudget =>
      totalAllocated > 0 &&
      totalSpent > totalAllocated;

  double get overspentAmount {
    final over =
        totalSpent - totalAllocated;

    return over > 0 ? over : 0;
  }

  double get spendProgress {
    if (totalAllocated <= 0) {
      return 0;
    }

    return (
      totalSpent / totalAllocated
    ).clamp(
      0.0,
      1.0,
    );
  }

  void resetMonthlySpent() {
    performReset();
  }

  double get currentCategoryAllocationTotal {
    return categoriesController
        .categoryList
        .fold(
      0.0,
      (sum, category) =>
          sum +
          _resolvedCategoryLimit(
            category,
          ),
    );
  }

  double projectedAllocationAfterUpdate(
    String categoryName,
    double newLimit,
  ) {
    final normalizedName =
        categoryName
            .trim()
            .toLowerCase();

    final existingCategory =
        categoriesController.categoryList
            .firstWhereOrNull(
      (category) =>
          category.name
                  .trim()
                  .toLowerCase() ==
              normalizedName,
    );

    final previousLimit =
        existingCategory != null
            ? _resolvedCategoryLimit(
                existingCategory,
              )
            : 0.0;

    return currentCategoryAllocationTotal -
        previousLimit +
        newLimit;
  }

  bool willExceedMonthlyBudget(
    String categoryName,
    double newLimit,
  ) {
    final monthlyLimit =
        customTotalBudget.value;

    if (monthlyLimit == null) {
      return false;
    }

    return projectedAllocationAfterUpdate(
          categoryName,
          newLimit,
        ) >
        monthlyLimit;
  }

  // ================================================================
  // SET CATEGORY LIMIT
  // ================================================================

  void setCategoryLimit(
    String categoryName,
    double newLimit,
  ) {
    final matchedCategory =
        categoriesController.categoryList
            .firstWhereOrNull(
      (category) =>
          _normalizeName(
            category.name,
          ) ==
          _normalizeName(
            categoryName,
          ),
    );

    if (matchedCategory != null) {
      customLimits[
          matchedCategory.id] =
          newLimit;
    }

    customLimits[categoryName] =
        newLimit;

    calculateBudgets();

    savePersistedState();

    // Local-first:
    // save to Drift + queue Supabase sync.
    unawaited(
      _syncCurrentBudgetsToDatabase(),
    );
  }

  // ================================================================
  // SET TOTAL BUDGET
  // ================================================================

  void setTotalBudget(
    double newTotalLimit,
  ) {
    customTotalBudget.value =
        newTotalLimit;

    savePersistedState();

    unawaited(
      _syncCurrentBudgetsToDatabase(),
    );
  }

  // ================================================================
  // ADD NEW BUDGET
  // ================================================================

  void addNewBudget(
    String categoryName,
    double amount,
  ) {
    final normalizedName =
        _normalizeName(categoryName);

    final existingCategory =
        categoriesController.categoryList
            .firstWhereOrNull(
      (element) =>
          _normalizeName(
            element.name,
          ) ==
          normalizedName,
    );

    if (existingCategory != null) {
      customLimits[
          existingCategory.id] =
          amount;

      customLimits[
          existingCategory.name] =
          amount;
    } else {
      final newCategory =
          CategoryModel(
        id: _generateUuid(),
        name: categoryName,
        icon: 'attach_money',
        colorValue: 0xFF2B82FB,
        isDefault: false,
      );

      categoriesController
          .categoryList
          .add(newCategory);

      customLimits[
          newCategory.id] =
          amount;

      customLimits[
          newCategory.name] =
          amount;
    }

    savePersistedState();

    calculateBudgets();

    unawaited(
      _syncCurrentBudgetsToDatabase(),
    );
  }
}
