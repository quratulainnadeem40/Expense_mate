
import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:expense_mate/Core/utils/formatters.dart';
import 'package:expense_mate/Feature/Categories/controller/categories_controller.dart';
import 'package:expense_mate/Feature/expense/binding/epense_binding.dart';
import 'package:expense_mate/Feature/expense/view/add_expense_view.dart';
import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';
import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final bool isDark;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.isDark,
  });

  void _editTransaction() {
    Get.to(
      () => const AddExpenseView(),
      binding: ExpenseBinding(),
      arguments: transaction,
    );
  }

  void _deleteTransaction() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();

              final controller =
                  Get.find<TransactionsController>();

              final success =
                  await controller.deleteTransaction(
                transaction.id,
              );

              if (success) {
                Get.snackbar(
                  'Deleted',
                  'Transaction deleted successfully.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName() {
    if (!Get.isRegistered<CategoriesController>()) {
      return transaction.categoryId;
    }

    final categoriesController =
        Get.find<CategoriesController>();

    final category =
        categoriesController.categoryList.firstWhereOrNull(
      (category) => category.id == transaction.categoryId,
    );

    return category?.name ?? transaction.categoryId;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _editTransaction,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: transaction.isIncome
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    child: Icon(
                      transaction.isIncome
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: transaction.isIncome
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.title,
                          style: AppTextStyles.bodyLarge(isDark),
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 2),

                        Text(
                          '${_getCategoryName()} • ${Formatters.formatDate(transaction.date)}',
                          style: AppTextStyles.caption(isDark),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${transaction.isIncome ? '+' : '-'}${Formatters.formatCurrency(transaction.amount)}',
                  style: TextStyle(
                    color: transaction.isIncome
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(width: 4),

                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    size: 20,
                    color:
                        Theme.of(context).colorScheme.primary,
                  ),
                  padding: EdgeInsets.zero,
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editTransaction();
                    } else if (value == 'delete') {
                      _deleteTransaction();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.red,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

