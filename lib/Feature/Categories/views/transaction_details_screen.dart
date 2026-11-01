import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:expense_mate/Core/localization/app_translations.dart';
import 'package:expense_mate/Core/utils/formatters.dart';
import 'package:expense_mate/Feature/expense/binding/epense_binding.dart';
import 'package:expense_mate/Feature/expense/controller/expense_controller.dart';
import 'package:expense_mate/Feature/expense/view/add_expense_view.dart';
import 'package:expense_mate/Feature/Categories/controller/categories_controller.dart';
import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';
import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';
import 'package:expense_mate/Feature/wallets/controller/wallets_controller.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailsScreen({super.key, required this.transaction});

  // ------------------------------------------------------------
  // DELETE
  // ------------------------------------------------------------

  Future<void> _deleteTransaction() async {
    final controller = Get.find<TransactionsController>();

    await controller.deleteTransaction(transaction.id);

    Get.back();

    Get.snackbar(
      'Deleted'.tr,
      'Transaction removed successfully'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ------------------------------------------------------------
  // EDIT
  // ------------------------------------------------------------

  void _onEditPressed() {
    if (!Get.isRegistered<ExpenseController>()) {
      ExpenseBinding().dependencies();
    }

    final expenseController = Get.find<ExpenseController>();

    expenseController.amountController.text = transaction.amount.toString();

    expenseController.noteController.text =
        transaction.note ?? transaction.title;

    expenseController.isExpense.value = !transaction.isIncome;

    expenseController.selectedCategoryId.value = transaction.categoryId;

    expenseController.selectedWalletId.value = transaction.walletId;

    Get.to(() => const AddExpenseView(), arguments: transaction);
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('Transaction Details'.tr), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),

              // ------------------------------------------------
              // ICON
              // ------------------------------------------------
              CircleAvatar(
                radius: 35,
                backgroundColor: transaction.isIncome
                    ? Colors.green.withValues(alpha: 0.15)
                    : Colors.red.withValues(alpha: 0.15),
                child: Icon(
                  transaction.isIncome
                      ? Icons.arrow_downward
                      : Icons.shopping_bag,
                  color: transaction.isIncome ? Colors.green : Colors.red,
                  size: 35,
                ),
              ),

              const SizedBox(height: 12),

              // ------------------------------------------------
              // TITLE
              // ------------------------------------------------
              Text(
                transaction.title.trim().isEmpty
                    ? AppTranslations.localizeCategoryRecord(_categoryName)
                    : transaction.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              // ------------------------------------------------
              // AMOUNT
              // ------------------------------------------------
              Text(
                Formatters.signedMoney(
                  transaction.amount,
                  isIncome: transaction.isIncome,
                  decimals: 2,
                ),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: transaction.isIncome ? Colors.green : Colors.red,
                ),
              ),

              const SizedBox(height: 6),

              // ------------------------------------------------
              // CATEGORY ID
              // ------------------------------------------------
              Text(
                AppTranslations.localizeCategoryRecord(_categoryName),
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),

              const SizedBox(height: 30),

              // ------------------------------------------------
              // DETAILS CARD
              // ------------------------------------------------
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(context, 'Category', _categoryName),

                    const Divider(height: 24),

                    _buildDetailRow(
                      context,
                      'Type',
                      transaction.isIncome ? 'Income'.tr : 'Expense'.tr,
                      valueColor: transaction.isIncome
                          ? Colors.green
                          : Colors.red,
                    ),

                    const Divider(height: 24),

                    _buildDetailRow(
                      context,
                      'Amount',
                      Formatters.signedMoney(
                        transaction.amount,
                        isIncome: transaction.isIncome,
                        decimals: 2,
                      ),
                      valueColor: transaction.isIncome
                          ? Colors.green
                          : Colors.red,
                    ),

                    const Divider(height: 24),

                    _buildDetailRow(
                      context,
                      'Date',
                      '${DateFormat('MMM').format(transaction.date).tr} '
                          '${transaction.date.day}, ${transaction.date.year}',
                    ),

                    const Divider(height: 24),

                    _buildDetailRow(context, 'Wallet', _walletName()),

                    const Divider(height: 24),

                    _buildDetailRow(
                      context,
                      'Note',
                      transaction.note?.isNotEmpty == true
                          ? transaction.note!
                          : 'No note'.tr,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ------------------------------------------------
              // ACTIONS
              // ------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withValues(alpha: 0.1),
                    ),
                    onPressed: _deleteTransaction,
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),

                  FloatingActionButton.small(
                    onPressed: _onEditPressed,
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _categoryName {
    if (Get.isRegistered<CategoriesController>()) {
      final categoriesController = Get.find<CategoriesController>();
      final category = categoriesController.categoryList.firstWhereOrNull(
        (category) =>
            category.id.trim().toLowerCase() ==
                transaction.categoryId.trim().toLowerCase() ||
            category.linkedIds.any(
              (id) =>
                  id.trim().toLowerCase() ==
                  transaction.categoryId.trim().toLowerCase(),
            ),
      );
      if (category != null) return category.name;
    }
    return transaction.displayCategoryFallback;
  }

  // ------------------------------------------------------------
  // WALLET NAME
  // ------------------------------------------------------------

  String _walletName() {
    if (Get.isRegistered<WalletsController>()) {
      final wallet = Get.find<WalletsController>().wallets.firstWhereOrNull(
        (wallet) => wallet.id == transaction.walletId,
      );
      if (wallet != null) return wallet.name;
    }

    if (!Get.isRegistered<ExpenseController>()) {
      return transaction.walletId.isEmpty
          ? 'No wallet'.tr
          : transaction.walletId;
    }

    final expenseController = Get.find<ExpenseController>();

    final wallets = expenseController.walletsController.wallets;

    final wallet = wallets.firstWhereOrNull(
      (wallet) => wallet.id == transaction.walletId,
    );

    final name =
        wallet?.name ??
        (transaction.walletId.isEmpty ? 'No wallet' : transaction.walletId);
    return name;
  }

  // ------------------------------------------------------------
  // DETAIL ROW
  // ------------------------------------------------------------

  Widget _buildDetailRow(
    BuildContext context,
    String title,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.tr,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),

        const SizedBox(width: 20),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
