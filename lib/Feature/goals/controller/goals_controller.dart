import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../model/goal_icon.dart';
import '../model/goals_model.dart';

class GoalsController extends GetxController {
  final goals = <GoalModel>[].obs;
  final recentIconKeys = <String>[].obs;

  final GetStorage _storage = GetStorage();
  static const String _storageKey = 'saved_user_goals';
  static const String _recentIconsStorageKey = 'recent_goal_icons';

  // ----------------------------------------------------------------
  // FORM STATE  (used by the add / edit sheet)
  // ----------------------------------------------------------------
  final titleController = TextEditingController();
  final targetController = TextEditingController();
  final savedController = TextEditingController();
  final amountController = TextEditingController();

  final selectedDate = Rxn<DateTime>();
  final selectedIconKey = 'target'.obs;

  /// Null when creating, set to the goal id when editing.
  final editingId = RxnString();

  bool get isEditing => editingId.value != null;

  /// Frequently used goal icons shown before opening the full picker.
  static const List<String> quickIconKeys = [
    'target',
    'home',
    'car',
    'phone',
    'laptop',
    'travel',
    'education',
    'wedding',
    'health',
    'gift',
  ];

  String get nameHint => 'e.g. ${goalIconFor(selectedIconKey.value).label} goal';

  // ----------------------------------------------------------------
  // SUMMARY  (for the header card)
  // ----------------------------------------------------------------
  List<GoalModel> get activeGoals =>
      goals.where((g) => !g.isCompleted).toList()
        ..sort((a, b) => a.targetDate.compareTo(b.targetDate));

  List<GoalModel> get completedGoals =>
      goals.where((g) => g.isCompleted).toList();

  double get totalSaved => goals.fold(0.0, (sum, g) => sum + g.savedAmount);

  double get totalTarget => goals.fold(0.0, (sum, g) => sum + g.targetAmount);

  double get overallProgress =>
      totalTarget > 0 ? (totalSaved / totalTarget).clamp(0.0, 1.0) : 0.0;

  @override
  void onInit() {
    super.onInit();
    _load();
    _loadRecentIcons();
  }

  // ----------------------------------------------------------------
  // STORAGE
  // ----------------------------------------------------------------
  void _load() {
    final stored = _storage.read<List>(_storageKey);
    if (stored == null) return;

    try {
      goals.assignAll(
        stored
            .map((e) => GoalModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
    } catch (_) {
      // A corrupt entry should never crash the screen.
      goals.clear();
    }
  }

  void _save() {
    _storage.write(_storageKey, goals.map((g) => g.toMap()).toList());
  }

  void _loadRecentIcons() {
    final stored = _storage.read<List>(_recentIconsStorageKey);
    if (stored == null) return;

    final knownKeys = goalIconOptions.map((option) => option.key).toSet();
    recentIconKeys.assignAll(
      stored
          .whereType<String>()
          .where(knownKeys.contains)
          .toSet()
          .toList(),
    );
  }

  void recordRecentIcon(String iconKey) {
    if (!goalIconOptions.any((option) => option.key == iconKey)) return;

    recentIconKeys.remove(iconKey);
    recentIconKeys.insert(0, iconKey);
    _storage.write(_recentIconsStorageKey, recentIconKeys.toList());
  }

  // ----------------------------------------------------------------
  // FORM HELPERS
  // ----------------------------------------------------------------
  void prepareForCreate() {
    editingId.value = null;
    titleController.clear();
    targetController.clear();
    savedController.clear();
    selectedDate.value = null;
    selectedIconKey.value = 'target';
  }

  void prepareForEdit(GoalModel goal) {
    editingId.value = goal.id;
    titleController.text = goal.title;
    targetController.text = goal.targetAmount.toStringAsFixed(0);
    savedController.text = goal.savedAmount.toStringAsFixed(0);
    selectedDate.value = goal.targetDate;
    selectedIconKey.value = goal.iconKey;
  }

  /// Quick date chips: 3 months, 6 months, 1 year.
  void setDateInMonths(int months) {
    final now = DateTime.now();
    selectedDate.value = DateTime(now.year, now.month + months, now.day);
  }

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? now.add(const Duration(days: 90)),
      firstDate: now,
      lastDate: DateTime(now.year + 15),
    );
    if (picked != null) selectedDate.value = picked;
  }

  // ----------------------------------------------------------------
  // CREATE / UPDATE
  // ----------------------------------------------------------------
  void saveGoal() {
    final title = titleController.text.trim();
    final target = double.tryParse(targetController.text.trim());
    final saved = double.tryParse(savedController.text.trim()) ?? 0.0;

    if (title.isEmpty) {
      _warn('Please give your goal a name');
      return;
    }
    if (target == null || target <= 0) {
      _warn('Please enter a target amount');
      return;
    }
    if (saved > target) {
      _warn('Saved amount cannot be more than the target');
      return;
    }
    if (selectedDate.value == null) {
      _warn('Please choose a target date');
      return;
    }

    if (isEditing) {
      final index = goals.indexWhere((g) => g.id == editingId.value);
      if (index != -1) {
        final goal = goals[index];
        goal.title = title;
        goal.iconKey = selectedIconKey.value;
        goal.targetAmount = target;
        goal.savedAmount = saved;
        goal.targetDate = selectedDate.value!;
        goals.refresh();
        _save();
        Get.back();
        _ok('Goal updated');
      }
      return;
    }

    goals.add(
      GoalModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        iconKey: selectedIconKey.value,
        targetAmount: target,
        savedAmount: saved,
        targetDate: selectedDate.value!,
      ),
    );
    _save();
    Get.back();
    _ok('Goal created');
  }

  // ----------------------------------------------------------------
  // MONEY IN / OUT
  // ----------------------------------------------------------------
  void deposit(String id) {
    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      _warn('Please enter a valid amount');
      return;
    }

    final index = goals.indexWhere((g) => g.id == id);
    if (index == -1) return;

    final goal = goals[index];
    final wasCompleted = goal.isCompleted;
    goal.savedAmount += amount;
    goals.refresh();
    _save();

    amountController.clear();
    Get.back();

    if (!wasCompleted && goal.isCompleted) {
      _ok('🎉 Goal reached! ${goal.title} is complete.');
    } else {
      _ok('Rs. ${amount.toStringAsFixed(0)} added');
    }
  }

  void withdraw(String id) {
    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      _warn('Please enter a valid amount');
      return;
    }

    final index = goals.indexWhere((g) => g.id == id);
    if (index == -1) return;

    final goal = goals[index];
    if (amount > goal.savedAmount) {
      _warn('You have only Rs. ${goal.savedAmount.toStringAsFixed(0)} saved');
      return;
    }

    goal.savedAmount -= amount;
    goals.refresh();
    _save();

    amountController.clear();
    Get.back();
    _ok('Rs. ${amount.toStringAsFixed(0)} withdrawn');
  }

  void deleteGoal(String id) {
    goals.removeWhere((g) => g.id == id);
    _save();
    _ok('Goal deleted');
  }

  // ----------------------------------------------------------------
  // FEEDBACK
  // ----------------------------------------------------------------
  void _warn(String message) => Get.snackbar(
    'Almost there',
    message,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(16),
  );

  void _ok(String message) => Get.snackbar(
    'Done',
    message,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(16),
  );

  @override
  void onClose() {
    titleController.dispose();
    targetController.dispose();
    savedController.dispose();
    amountController.dispose();
    super.onClose();
  }
}
