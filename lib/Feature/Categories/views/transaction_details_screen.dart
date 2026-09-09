
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:expense_mate/Feature/expense/binding/epense_binding.dart';
import 'package:expense_mate/Feature/expense/controller/expense_controller.dart';
import 'package:expense_mate/Feature/expense/view/add_expense_view.dart';
import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';
import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
  });

  // ------------------------------------------------------------
  // DELETE
  // ------------------------------------------------------------

  Future<void> _deleteTransaction() async {
    final controller = Get.find<TransactionsController>();

    await controller.deleteTransaction(transaction.id);

    Get.back();

    Get.snackbar(
      'Deleted',
      'Transaction removed successfully',
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

    expenseController.amountController.text =
        transaction.amount.toString();

    expenseController.noteController.text =
        transaction.note ?? transaction.title;

    expenseController.isExpense.value =
        transaction.type == 'expense';

    expenseController.selectedCategoryId.value =
        transaction.categoryId;

    expenseController.selectedWalletId.value =
        transaction.walletId;

    Get.to(
      () => const AddExpenseView(),
      arguments: transaction,
    );
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // ------------------------------------------------
              // ICON
              // ------------------------------------------------

              CircleAvatar(
                radius: 35,
                backgroundColor: transaction.isIncome
                    ? Colors.green.withOpacity(0.15)
                    : Colors.red.withOpacity(0.15),
                child: Icon(
                  transaction.isIncome
                      ? Icons.arrow_downward
                      : Icons.shopping_bag,
                  color: transaction.isIncome
                      ? Colors.green
                      : Colors.red,
                  size: 35,
                ),
              ),

              const SizedBox(height: 12),

              // ------------------------------------------------
              // TITLE
              // ------------------------------------------------

              Text(
                transaction.title,
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
                '${transaction.isIncome ? '+' : '-'}'
                '₨${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: transaction.isIncome
                      ? Colors.green
                      : Colors.red,
                ),
              ),

              const SizedBox(height: 6),

              // ------------------------------------------------
              // CATEGORY ID
              // ------------------------------------------------

              Text(
                transaction.categoryId.isEmpty
                    ? 'No category'
                    : transaction.categoryId,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
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
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      'Date',
                      DateFormat('MMM dd, yyyy')
                          .format(transaction.date),
                    ),

                    const Divider(height: 24),

                    _buildDetailRow(
                      'Wallet',
                      _walletName(),
                    ),

                    const Divider(height: 24),

                    _buildDetailRow(
                      'Note',
                      transaction.note?.isNotEmpty == true
                          ? transaction.note!
                          : 'No note',
                    ),

                    const Divider(height: 24),

                    _buildDetailRow(
                      'Status',
                      transaction.isIncome
                          ? 'Income'
                          : 'Expense',
                      valueColor: transaction.isIncome
                          ? Colors.green
                          : Colors.red,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ------------------------------------------------
              // ACTIONS
              // ------------------------------------------------

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor:
                          Colors.red.withOpacity(0.1),
                    ),
                    onPressed: _deleteTransaction,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                  ),

                  FloatingActionButton.small(
                    onPressed: _onEditPressed,
                    backgroundColor: Colors.blue,
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // WALLET NAME
  // ------------------------------------------------------------

  String _walletName() {
    if (!Get.isRegistered<ExpenseController>()) {
      return transaction.walletId.isEmpty
          ? 'No wallet'
          : transaction.walletId;
    }

    final expenseController =
        Get.find<ExpenseController>();

    final wallets =
        expenseController.walletsController.wallets;

    final wallet = wallets.firstWhereOrNull(
      (wallet) => wallet.id == transaction.walletId,
    );

    return wallet?.name ??
        (transaction.walletId.isEmpty
            ? 'No wallet'
            : transaction.walletId);
  }

  // ------------------------------------------------------------
  // DETAIL ROW
  // ------------------------------------------------------------

  Widget _buildDetailRow(
    String title,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),

        const SizedBox(width: 20),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
