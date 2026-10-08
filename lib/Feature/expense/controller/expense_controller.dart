import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../Categories/controller/categories_controller.dart';
import '../../Categories/model/categories_model.dart';
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

  /// Returns the id of the category called [name], creating it first if
  /// it does not exist yet.
  ///
  /// This is what makes a typed-in category show up on the Categories
  /// screen and in the dropdown next time, instead of being stranded
  /// inside one transaction.
  Future<String> _resolveCategoryId(String name, String type) async {
    final normalized = name.trim().toLowerCase();

    CategoryModel? match;
    for (final category in categoriesController.categoryList) {
      if (category.name.trim().toLowerCase() == normalized) {
        match = category;
        break;
      }
    }

    // A default category such as Food is stored as default_food until
    // someone actually uses it, so treat that as a real match too.
    if (match != null && !match.id.startsWith('default_')) {
      return match.id;
    }

    await categoriesController.addCategory(
      CategoryModel(
        id: '',
        name: name.trim(),
        icon: _iconNameFor(name),
        colorValue: 0xFF2E7D32,
        isDefault: false,
        type: type,
      ),
      closeDialog: false,
    );

    for (final category in categoriesController.categoryList) {
      if (category.name.trim().toLowerCase() == normalized &&
          !category.id.startsWith('default_')) {
        return category.id;
      }
    }

    return '';
  }

  /// Picks a sensible icon from the name, so a new category does not all
  /// land on the generic box.
  String _iconNameFor(String name) {
    final n = name.toLowerCase();

    bool has(List<String> keys) => keys.any(n.contains);

    if (has(['food', 'eat', 'dining', 'lunch', 'dinner', 'party'])) {
      return 'food';
    }
    if (has(['grocer', 'vegetable', 'market'])) return 'groceries';
    if (has(['transport', 'taxi', 'uber', 'careem', 'bus', 'rickshaw'])) {
      return 'transport';
    }
    if (has(['fuel', 'petrol', 'diesel'])) return 'fuel';
    if (has(['bill', 'electric', 'gas', 'water'])) return 'bills';
    if (has(['rent'])) return 'rent';
    if (has(['health', 'doctor', 'hospital'])) return 'health';
    if (has(['medicine', 'pharmac'])) return 'medicine';
    if (has(['school', 'educat', 'fee', 'tuition', 'book'])) {
      return 'education';
    }
    if (has(['mobile', 'phone', 'load', 'recharge'])) return 'mobile';
    if (has(['internet', 'wifi'])) return 'internet';
    if (has(['cloth', 'dress', 'shirt'])) return 'clothing';
    if (has(['shop'])) return 'shopping';
    if (has(['travel', 'trip', 'flight', 'umrah'])) return 'travel';
    if (has(['movie', 'game', 'entertain'])) return 'entertainment';
    if (has(['gym', 'fitness', 'sport'])) return 'fitness';
    if (has(['gift', 'donat', 'charity', 'zakat'])) return 'gifts';
    if (has(['salon', 'beauty', 'hair'])) return 'beauty';
    if (has(['pet', 'cat', 'dog'])) return 'pets';
    if (has(['repair', 'maintain', 'service'])) return 'maintenance';
    if (has(['salary', 'income', 'wage'])) return 'salary';
    if (has(['business', 'profit'])) return 'business';

    return 'other';
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

      // A typed-in category used to live only inside the transaction, as
      // free text. Nothing was created, so it never reached the
      // Categories screen or the dropdown. Now it becomes a real
      // category and the transaction points at it like any other.
      final String typedName = customCategoryName.value.trim();

      String categoryId = selectedCategoryId.value.trim();

      if (typedName.isNotEmpty) {
        categoryId = await _resolveCategoryId(
          typedName,
          isExpense.value ? 'expense' : 'income',
        );
      }

      // Kept empty from here on: the name now lives in the category
      // record, not in the transaction.
      const String customCategory = '';

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