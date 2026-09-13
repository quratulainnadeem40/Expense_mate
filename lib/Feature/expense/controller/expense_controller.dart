import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../Categories/controller/categories_controller.dart';
import '../../Home/controller/home_controller.dart';
import '../../transactions/controller/transcation_controller.dart';
import '../../transactions/model/transcation_model.dart';
import '../../wallets/controller/wallets_controller.dart';

class ExpenseController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ------------------------------------------------------------
  // TYPE
  // ------------------------------------------------------------

  final isExpense = true.obs;

  // ------------------------------------------------------------
  // EDIT MODE
  // ------------------------------------------------------------

  final isEditMode = false.obs;
  String? editingTransactionId;

  // ------------------------------------------------------------
  // TEXT CONTROLLERS
  // ------------------------------------------------------------

  final amountController = TextEditingController();
  final noteController = TextEditingController();

  // ------------------------------------------------------------
  // SELECTIONS (Initially empty)
  // ------------------------------------------------------------

  final selectedCategoryId = ''.obs;
  final selectedWalletId = ''.obs;

  // ------------------------------------------------------------
  // LOADING
  // ------------------------------------------------------------

  final isLoading = false.obs;

  User? get currentUser => _supabase.auth.currentUser;

  // ------------------------------------------------------------
  // CONTROLLERS
  // ------------------------------------------------------------

  late CategoriesController categoriesController;
  late WalletsController walletsController;

  // ------------------------------------------------------------
  // CATEGORY LISTS
  // ------------------------------------------------------------

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

  // ------------------------------------------------------------
  // INIT
  // ------------------------------------------------------------

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

    // CHECK IF THIS IS EDIT MODE
    final argument = Get.arguments;

    if (argument is TransactionModel) {
      loadTransactionForEdit(argument);
    }
  }

  // ------------------------------------------------------------
  // EXPENSE / INCOME TOGGLE
  // ------------------------------------------------------------

  void toggleType(bool isExp) {
    isExpense.value = isExp;

    if (!isEditMode.value) {
      selectedCategoryId.value = ''; // Reset category on type switch
    }
  }

  // ------------------------------------------------------------
  // LOAD TRANSACTION FOR EDIT
  // ------------------------------------------------------------

  void loadTransactionForEdit(TransactionModel transaction) {
    isEditMode.value = true;
    editingTransactionId = transaction.id;

    amountController.text = transaction.amount.toString();
    noteController.text = transaction.note ?? transaction.title;

    isExpense.value = transaction.type.toLowerCase() == 'expense';
    selectedCategoryId.value = transaction.categoryId;
    selectedWalletId.value = transaction.walletId;
  }

  // ------------------------------------------------------------
  // SAVE TRANSACTION
  // ------------------------------------------------------------

  Future<void> saveExpense() async {
    final user = currentUser;

    if (user == null) {
      _showError('Please login first.');
      return;
    }

    final amountText = amountController.text.trim();
    final note = noteController.text.trim();

    // ----------------------------------------------------------
    // VALIDATIONS
    // ----------------------------------------------------------

    if (amountText.isEmpty) {
      _showError('Please enter amount.');
      return;
    }

    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount.');
      return;
    }

    if (selectedCategoryId.value.isEmpty) {
      _showError('No category selected');
      return;
    }

    if (selectedWalletId.value.isEmpty) {
      _showError('No wallet selected');
      return;
    }

    // ----------------------------------------------------------
    // SAVE PROCESS
    // ----------------------------------------------------------

    try {
      isLoading.value = true;

      final wasEditing = isEditMode.value;
      final transactionId = editingTransactionId;

      final transaction = TransactionModel(
        id: transactionId ?? '',
        userId: user.id,
        walletId: selectedWalletId.value,
        categoryId: selectedCategoryId.value,
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

      final transactionsController = Get.find<TransactionsController>();

      bool success;

      if (wasEditing) {
        if (transactionId == null || transactionId.isEmpty) {
          _showError('Transaction ID is missing.');
          return;
        }

        success = await transactionsController.updateTransaction(
          transaction,
        );
      } else {
        success = await transactionsController.addTransaction(
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

  // ------------------------------------------------------------
  // RESET FORM
  // ------------------------------------------------------------

  void resetForm() {
    amountController.clear();
    noteController.clear();

    isEditMode.value = false;
    editingTransactionId = null;

    isExpense.value = true;

    selectedCategoryId.value = '';
    selectedWalletId.value = '';
  }

  // ------------------------------------------------------------
  // ERROR SNACKBAR
  // ------------------------------------------------------------

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFE53935),
      colorText: Colors.white,
      icon: const Icon(Icons.error_outline, color: Colors.white, size: 28),
      margin: const EdgeInsets.all(15),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  // ------------------------------------------------------------
  // DISPOSE
  // ------------------------------------------------------------

  @override
  void onClose() {
    amountController.dispose();
    noteController.dispose();
    super.onClose();
  }
}