import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:expense_mate/Feature/expense/binding/epense_binding.dart';
import 'package:expense_mate/Feature/expense/controller/expense_controller.dart';
import 'package:expense_mate/Feature/expense/view/add_expense_view.dart';
import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';
import 'package:expense_mate/core/constants/app_keys.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
  });

  void _deleteTransaction() async {
    final box = Hive.box(AppKeys.transactionsBox);
    final rawMap = box.toMap();

    dynamic targetKey;
    rawMap.forEach((key, value) {
      if (value is Map && value['id'] == transaction.id) {
        targetKey = key;
      }
    });

    if (targetKey != null) {
      await box.delete(targetKey);
      Get.back();
      Get.snackbar('Deleted', 'Transaction removed successfully',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _onEditPressed() {
    // 1. ExpenseBinding ko manual initialize kar rahe hain
    ExpenseBinding().dependencies();

    // 2. Navigation se pehle Controller mein data set kar rahe hain
    final expenseController = Get.find<ExpenseController>();
    expenseController.amountController.text = transaction.amount.toString();
    expenseController.noteController.text = transaction.title;
    expenseController.selectedCategory.value = transaction.category;
    expenseController.isExpense.value = !transaction.isIncome;

    // 3. Form fill hone ke baad screen navigate hogi
    Get.to(
      () => const AddExpenseView(),
      arguments: transaction,
    );
  }

  @override
  Widget build(BuildContext context) {
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

              CircleAvatar(
                radius: 35,
                backgroundColor: transaction.isIncome
                    ? Colors.green.withOpacity(0.15)
                    : Colors.red.withOpacity(0.15),
                child: Icon(
                  transaction.isIncome
                      ? Icons.arrow_downward
                      : Icons.shopping_bag,
                  color: transaction.isIncome ? Colors.green : Colors.red,
                  size: 35,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                transaction.title,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                '${transaction.isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: transaction.isIncome ? Colors.green : Colors.red,
                ),
              ),
              Text(
                transaction.category,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Date',
                        DateFormat('MMM dd, yyyy').format(transaction.date)),
                    const Divider(height: 24),
                    _buildDetailRow('Payment Method', 'Cash'),
                    const Divider(height: 24),
                    _buildDetailRow('Note', transaction.title),
                    const Divider(height: 24),
                    _buildDetailRow(
                      'Status',
                      transaction.isIncome ? 'Income' : 'Expense',
                      valueColor:
                          transaction.isIncome ? Colors.green : Colors.red,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
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

  Widget _buildDetailRow(String title, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }
}