import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:expense_mate/Feature/Categories/controller/categories_controller.dart';
import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';
import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';
import 'package:expense_mate/Feature/wallets/controller/wallets_controller.dart';

class AddTransactionDialog extends StatelessWidget {
  const AddTransactionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    final selectedCategoryId = ''.obs;
    final selectedWalletId = ''.obs;
    final isIncome = false.obs;

    final txController = Get.find<TransactionsController>();

    final categoryController = Get.isRegistered<CategoriesController>()
        ? Get.find<CategoriesController>()
        : Get.put(CategoriesController());

   final walletController = Get.isRegistered<WalletsController>()
    ? Get.find<WalletsController>()
    : Get.put(WalletsController());

walletController.loadWallets();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        'Add Transaction',
        style: AppTextStyles.headingMedium(isDark),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ==================================================
            // TITLE
            // ==================================================

            TextField(
              controller: titleController,
              style: TextStyle(
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                ),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: colorScheme.outline,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ==================================================
            // AMOUNT
            // ==================================================

            TextField(
              controller: amountController,
              style: TextStyle(
                color: colorScheme.onSurface,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                ),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: colorScheme.outline,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ==================================================
            // WALLET
            // ==================================================

            Obx(() {
              final wallets = walletController.wallets;

              if (wallets.isEmpty) {
                return InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Wallet',
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: colorScheme.outline,
                      ),
                    ),
                  ),
                  child: Text(
                    'No wallets available',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }

              if (selectedWalletId.value.isEmpty) {
                selectedWalletId.value = wallets.first.id;
              }

              return DropdownButtonFormField<String>(
                initialValue: selectedWalletId.value,
                dropdownColor: colorScheme.surface,
                style: TextStyle(
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'Wallet',
                  labelStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                items: wallets.map((wallet) {
                  return DropdownMenuItem<String>(
                    value: wallet.id,
                    child: Text(
                      wallet.name,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedWalletId.value = value;
                  }
                },
              );
            }),

            const SizedBox(height: 12),

            // ==================================================
            // CATEGORY
            // ==================================================

            Obx(() {
              final categories = categoryController.categoryList;

              if (categories.isEmpty) {
                return InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: colorScheme.outline,
                      ),
                    ),
                  ),
                  child: Text(
                    'No categories available',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }

              if (selectedCategoryId.value.isEmpty) {
                selectedCategoryId.value = categories.first.id;
              }

              return DropdownButtonFormField<String>(
                initialValue: selectedCategoryId.value,
                dropdownColor: colorScheme.surface,
                style: TextStyle(
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.id,
                    child: Text(
                      category.name,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedCategoryId.value = value;
                  }
                },
              );
            }),

            const SizedBox(height: 12),

            // ==================================================
            // INCOME / EXPENSE
            // ==================================================

            Obx(
              () => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  isIncome.value ? 'Income' : 'Expense',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                  ),
                ),
                value: isIncome.value,
                activeThumbColor: Colors.green,
                onChanged: (value) {
                  isIncome.value = value;
                },
              ),
            ),
          ],
        ),
      ),

      // ======================================================
      // ACTIONS
      // ======================================================

      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          onPressed: () async {
            final title = titleController.text.trim();
            final amount = double.tryParse(
              amountController.text.trim(),
            );

            if (title.isEmpty || amount == null || amount <= 0) {
              Get.snackbar(
                'Error',
                'Please enter a valid title and amount.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: colorScheme.errorContainer,
                colorText: colorScheme.onErrorContainer,
              );
              return;
            }

            if (selectedWalletId.value.isEmpty) {
              Get.snackbar(
                'Error',
                'Please select a wallet.',
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }

            if (selectedCategoryId.value.isEmpty) {
              Get.snackbar(
                'Error',
                'Please select a category.',
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }

            final transaction = TransactionModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              walletId: selectedWalletId.value,
              categoryId: selectedCategoryId.value,
              title: title,
              amount: amount,
              type: isIncome.value ? 'income' : 'expense',
              transactionDate: DateTime.now(),
              note: title,
            );

            await txController.addTransaction(transaction);

            Get.back();
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}