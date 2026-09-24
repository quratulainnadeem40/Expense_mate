import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:expense_mate/Feature/Categories/controller/categories_controller.dart';
import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';
import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';
import 'package:expense_mate/Feature/wallets/controller/wallets_controller.dart';

class AddTransactionDialog extends StatefulWidget {
  const AddTransactionDialog({super.key});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  late final TextEditingController titleController;
  late final TextEditingController amountController;

  late final TransactionsController txController;
  late final CategoriesController categoryController;
  late final WalletsController walletController;

  String selectedCategoryId = '';
  String selectedWalletId = '';
  bool isIncome = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController();
    amountController = TextEditingController();

    txController = Get.find<TransactionsController>();

    categoryController = Get.isRegistered<CategoriesController>()
        ? Get.find<CategoriesController>()
        : Get.put(CategoriesController());

    walletController = Get.isRegistered<WalletsController>()
        ? Get.find<WalletsController>()
        : Get.put(WalletsController());

    walletController.loadWallets();
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _addTransaction() async {
    if (isSaving) return;

    final title = titleController.text.trim();
    final amount = double.tryParse(
      amountController.text.trim(),
    );

    if (title.isEmpty) {
      _showError('Please enter a title.');
      return;
    }

    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount.');
      return;
    }

    if (selectedWalletId.isEmpty) {
      _showError('Please select a wallet.');
      return;
    }

    if (selectedCategoryId.isEmpty) {
      _showError('Please select a category.');
      return;
    }

    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      walletId: selectedWalletId,
      categoryId: selectedCategoryId,
      title: title,
      amount: amount,
      type: isIncome ? 'income' : 'expense',
      transactionDate: DateTime.now(),
      note: title,
    );

    setState(() {
      isSaving = true;
    });

    final success = await txController.addTransaction(transaction);

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    if (success) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            // =========================
            // TITLE
            // =========================
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

            // =========================
            // AMOUNT
            // =========================
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

            // =========================
            // WALLET
            // =========================
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

              if (selectedWalletId.isEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && selectedWalletId.isEmpty) {
                    setState(() {
                      selectedWalletId = wallets.first.id;
                    });
                  }
                });
              }

              final validWalletId = wallets.any(
                (wallet) => wallet.id == selectedWalletId,
              );

              return DropdownButtonFormField<String>(
                value: validWalletId ? selectedWalletId : null,
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
                  if (value == null) return;

                  setState(() {
                    selectedWalletId = value;
                  });
                },
              );
            }),

            const SizedBox(height: 12),

            // =========================
            // CATEGORY
            // =========================
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

              if (selectedCategoryId.isEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && selectedCategoryId.isEmpty) {
                    setState(() {
                      selectedCategoryId = categories.first.id;
                    });
                  }
                });
              }

              final validCategoryId = categories.any(
                (category) => category.id == selectedCategoryId,
              );

              return DropdownButtonFormField<String>(
                value: validCategoryId ? selectedCategoryId : null,
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
                  if (value == null) return;

                  setState(() {
                    selectedCategoryId = value;
                  });
                },
              );
            }),

            const SizedBox(height: 12),

            // =========================
            // INCOME / EXPENSE
            // =========================
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                isIncome ? 'Income' : 'Expense',
                style: TextStyle(
                  color: colorScheme.onSurface,
                ),
              ),
              value: isIncome,
              activeThumbColor: Colors.green,
              onChanged: isSaving
                  ? null
                  : (value) {
                      setState(() {
                        isIncome = value;
                      });
                    },
            ),
          ],
        ),
      ),

      // =========================
      // ACTIONS
      // =========================
      actions: [
        TextButton(
          onPressed: isSaving
              ? null
              : () {
                  Navigator.of(context).pop();
                },
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
          onPressed: isSaving ? null : _addTransaction,
          child: isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Add'),
        ),
      ],
    );
  }
}