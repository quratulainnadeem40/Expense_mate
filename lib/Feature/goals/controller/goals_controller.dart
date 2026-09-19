import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../model/goals_model.dart';

class GoalsController extends GetxController {
  var goals = <GoalModel>[].obs;
  final GetStorage _storage = GetStorage();
  final String _storageKey = 'saved_user_goals';

  // Form Controllers
  final titleController = TextEditingController();
  final targetController = TextEditingController();
  final savedController = TextEditingController();
  final addMoneyController = TextEditingController();

  var selectedDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    _loadGoalsFromStorage(); // Page open hote hi local storage se load karega
  }

  // 1. Storage se goals load karna
  void _loadGoalsFromStorage() {
    List? storedData = _storage.read<List>(_storageKey);
    if (storedData != null) {
      goals.assignAll(
        storedData.map((e) => GoalModel.fromMap(Map<String, dynamic>.from(e))).toList(),
      );
    }
  }

  // 2. Local Storage me save karna
  void _saveGoalsToStorage() {
    List<Map<String, dynamic>> dataToSave = goals.map((g) => g.toMap()).toList();
    _storage.write(_storageKey, dataToSave);
  }

  // Date Picker
  void pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  // Submit New Goal
  void submitNewGoal(BuildContext context) {
    final title = titleController.text.trim();
    final target = double.tryParse(targetController.text.trim());
    final initialSaved = double.tryParse(savedController.text.trim()) ?? 0.0;

    if (title.isEmpty || target == null || target <= 0 || selectedDate.value == null) {
      Get.snackbar(
        'Required', 
        'Please fill title, target amount & select target date',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    addGoal(GoalModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      targetAmount: target,
      savedAmount: initialSaved,
      targetDate: selectedDate.value!,
    ));

    clearForm();
    Get.back();
  }

  void addGoal(GoalModel goal) {
    goals.add(goal);
    _saveGoalsToStorage(); // Auto save on add
  }

  // Update Collected Amount
  void addSavings(String id) {
    final amount = double.tryParse(addMoneyController.text.trim());
    if (amount == null || amount <= 0) return;

    int index = goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      goals[index].savedAmount += amount;
      goals.refresh();
      _saveGoalsToStorage(); // Auto save on update
    }

    addMoneyController.clear();
    Get.back();
  }

  void deleteGoal(String id) {
    goals.removeWhere((g) => g.id == id);
    _saveGoalsToStorage(); // Auto save on delete
  }

  void clearForm() {
    titleController.clear();
    targetController.clear();
    savedController.clear();
    selectedDate.value = null;
  }

  @override
  void onClose() {
    titleController.dispose();
    targetController.dispose();
    savedController.dispose();
    addMoneyController.dispose();
    super.onClose();
  }
}