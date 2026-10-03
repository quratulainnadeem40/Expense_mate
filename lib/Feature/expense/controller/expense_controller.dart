import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../Categories/controller/categories_controller.dart';
import '../../home/controller/home_controller.dart';
import '../../transactions/controller/transcation_controller.dart';
import '../../transactions/model/transcation_model.dart';
import '../../wallets/controller/wallets_controller.dart';

class ExpenseController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final isExpense = true.obs;

  final isEditMode = false.obs;
  String? editingTransactionId;

  final amountController = TextEditingController();
  final noteController = TextEditingController();

  final selectedCategoryId = ''.obs;
  final RxString customCategoryName = ''.obs;
  final selectedWalletId = ''.obs;

  final isLoading = false.obs;

  User? get currentUser => _supabase.auth.currentUser;

  late CategoriesController categoriesController;
  late WalletsController walletsController;

  List<dynamic> get expenseCategories {
    return categoriesController.categoryList
        .where((category) => category.type == 'expense')
        .toList();
  }

  List<dynamic> get incomeCategories {
    return categoriesController.categoryList
        .where((category) => category.type == 'income')
        .toList();
  }

  @override
  void onInit() {
    super.onInit();

    if (!Get.isRegistered<CategoriesController>()) {
      Get.put(CategoriesController());
    }

    if (!Get.isRegistered<WalletsController>()) {
      Get.put(WalletsController());
    }

    categoriesController = Get.find<CategoriesController>();
    walletsController = Get.find<WalletsController>();

    final argument = Get.arguments;

    if (argument is TransactionModel) {
      loadTransactionForEdit(argument);
    }
  }

  void toggleType(bool isExp) {
    isExpense.value = isExp;

    if (!isEditMode.value) {
      selectedCategoryId.value = '';
      customCategoryName.value = '';
    }
  }

  void loadTransactionForEdit(TransactionModel transaction) {
    isEditMode.value = true;
    editingTransactionId = transaction.id;

    amountController.text = _amountForEditing(transaction.amount);
    noteController.text = transaction.note ?? transaction.title;

    isExpense.value =
        transaction.type.trim().toLowerCase() == 'expense';

    selectedCategoryId.value = transaction.categoryId;
    customCategoryName.value = transaction.customCategoryName;
    selectedWalletId.value = transaction.walletId;
  }

  Future<void> saveExpense() async {
    final user = currentUser;

    if (user == null) {
      _showError('Please login first.');
      return;
    }

    final amountText = amountController.text.trim();
    final note = noteController.text.trim();

    if (amountText.isEmpty) {
      _showError('Please enter amount.');
      return;
    }

    final cleanAmountText = amountText.replaceAll(',', '');
    final amount = double.tryParse(cleanAmountText);

    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount.');
      return;
    }

    // Category is now required for BOTH Expense and Income.
    if (selectedCategoryId.value.trim().isEmpty &&
        customCategoryName.value.trim().isEmpty) {
      _showError(
        isExpense.value
            ? 'Please select an expense category.'
            : 'Please select an income category.',
      );
      return;
    }

    if (selectedWalletId.value.isEmpty) {
      _showError('No wallet selected');
      return;
    }

    try {
      isLoading.value = true;

      final wasEditing = isEditMode.value;
      final transactionId = editingTransactionId;

      // IMPORTANT:
      // Category ID is now saved for both Expense and Income.
      final String categoryId =
          customCategoryName.value.trim().isEmpty
              ? selectedCategoryId.value.trim()
              : '';

      final String customCategory =
          customCategoryName.value.trim();

      final transaction = TransactionModel(
        id: transactionId ?? '',
        userId: user.id,
        walletId: selectedWalletId.value,
        categoryId: categoryId,
        customCategory: customCategory,
        title: note.isEmpty
            ? (isExpense.value ? 'Expense' : 'Income')
            : note,
        amount: amount,
        type: isExpense.value ? 'expense' : 'income',
        transactionDate: DateTime.now(),
        note: note.isEmpty ? null : note,
      );

      if (!Get.isRegistered<TransactionsController>()) {
        Get.put(TransactionsController());
      }

      final transactionsController =
          Get.find<TransactionsController>();

      bool success;

      if (wasEditing) {
        if (transactionId == null || transactionId.isEmpty) {
          _showError('Transaction ID is missing.');
          return;
        }

        success =
            await transactionsController.updateTransaction(
          transaction,
        );
      } else {
        success =
            await transactionsController.addTransaction(
          transaction,
        );
      }

      if (!success) return;

      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadDashboardData();
      }

      resetForm();
      Get.back();

      Get.snackbar(
        wasEditing ? 'Updated' : 'Success',
        wasEditing
            ? 'Transaction updated successfully.'
            : 'Transaction added successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF2EA44F),
        colorText: Colors.white,
        icon: const Icon(
          Icons.check_circle,
          color: Colors.white,
          size: 28,
        ),
        margin: const EdgeInsets.all(15),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    } on PostgrestException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Failed to save transaction.');
    } finally {
      isLoading.value = false;
    }
  }

  String _amountForEditing(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toStringAsFixed(0);
    }

    return amount.toStringAsFixed(2);
  }

  void resetForm() {
    amountController.clear();
    noteController.clear();

    isEditMode.value = false;
    editingTransactionId = null;

    isExpense.value = true;

    selectedCategoryId.value = '';
    customCategoryName.value = '';
    selectedWalletId.value = '';
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFE53935),
      colorText: Colors.white,
      icon: const Icon(
        Icons.error_outline,
        color: Colors.white,
        size: 28,
      ),
      margin: const EdgeInsets.all(15),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void onClose() {
    amountController.dispose();
    noteController.dispose();
    super.onClose();
  }
}