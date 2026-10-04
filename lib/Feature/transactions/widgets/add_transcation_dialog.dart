import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';
import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:expense_mate/Feature/Categories/model/categories_model.dart';
import 'package:expense_mate/Core/theme/custom_colors.dart';
import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:expense_mate/Feature/Categories/controller/categories_controller.dart';



import 'package:expense_mate/Feature/wallets/controller/wallets_controller.dart';

class AddTransactionDialog extends StatefulWidget {
  final TransactionModel? transaction;

  const AddTransactionDialog({
    super.key,
    this.transaction,
  });

  bool get isEdit => transaction != null;

  @override
  State<AddTransactionDialog> createState() =>
      _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;

  late final TransactionsController _transactionController;
  late final CategoriesController _categoryController;
  late final WalletsController _walletController;

  String? _selectedCategoryId;
  String? _selectedWalletId;

  bool _isIncome = false;
  bool _isSaving = false;

  @override
void initState() {
  super.initState();

  _titleController = TextEditingController();
  _amountController = TextEditingController();

_transactionController = Get.find<TransactionsController>();
_categoryController = Get.find<CategoriesController>();

if (Get.isRegistered<WalletsController>()) {
  _walletController = Get.find<WalletsController>();
} else {
  _walletController = Get.put(WalletsController());
}

  final transaction = widget.transaction;

  if (transaction != null) {
    _titleController.text = transaction.title;
    _amountController.text = transaction.amount.toString();
    _selectedCategoryId = transaction.categoryId;
    _selectedWalletId = transaction.walletId;
    _isIncome = transaction.type.toLowerCase() == 'income';
  }

  _loadData();
}

  Future<void> _loadData() async {
    try {
      await _walletController.loadWallets();
    } catch (_) {}

    try {
      await _categoryController.fetchCategories();
    } catch (_) {}

    if (!mounted) return;

    setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();

    super.dispose();
  }

  // ------------------------------------------------------------
  // CATEGORY
  // ------------------------------------------------------------

  Future<void> _openMoreCategoryDialog() async {
    if (!mounted) return;

    final String? categoryName = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return const _CustomCategoryDialog();
      },
    );

    if (!mounted || categoryName == null) return;

    final String name = categoryName.trim();

    if (name.isEmpty) return;

    final bool alreadyExists =
        _categoryController.categoryList.any(
      (category) =>
          category.name.trim().toLowerCase() ==
              name.toLowerCase() &&
          category.type.trim().toLowerCase() == 'expense',
    );

    if (alreadyExists) {
      await _showMessage(
        'Category already exists',
        'Please choose a different category name.',
      );
      return;
    }

    final String categoryId = _generateUuid();

    final CategoryModel newCategory = CategoryModel(
      id: categoryId,
      name: name,
      icon: 'category',
      colorValue: 0xFF2E7D32,
      isDefault: false,
      type: 'expense',
    );

    try {
      await _categoryController.addCategory(
        newCategory,
        closeDialog: false,
      );

      if (!mounted) return;

      setState(() {
        _selectedCategoryId = categoryId;
        _isIncome = false;
      });
    } catch (e) {
      if (!mounted) return;

      await _showMessage(
        'Category Error',
        'Unable to create category. Please try again.',
      );
    }
  }

  // ------------------------------------------------------------
  // SELECTED CATEGORY
  // ------------------------------------------------------------

  CategoryModel? _getSelectedCategory() {
    final String? selectedId = _selectedCategoryId;

    if (selectedId == null || selectedId.trim().isEmpty) {
      return null;
    }

    for (final category
        in _categoryController.categoryList) {
      if (category.id.trim() == selectedId.trim()) {
        return category;
      }
    }

    return null;
  }

  // ------------------------------------------------------------
  // SAVE TRANSACTION
  // ------------------------------------------------------------

  Future<void> _saveTransaction() async {
  if (_isSaving) return;

  final String title = _titleController.text.trim();
  final String amountText = _amountController.text.trim();

  if (title.isEmpty) {
    await _showMessage(
      'Missing title',
      'Please enter a transaction title.',
    );
    return;
  }

  if (amountText.isEmpty) {
    await _showMessage(
      'Missing amount',
      'Please enter an amount.',
    );
    return;
  }

  final double? amount = double.tryParse(amountText);

  if (amount == null || amount <= 0) {
    await _showMessage(
      'Invalid amount',
      'Please enter a valid amount.',
    );
    return;
  }

  if (_selectedCategoryId == null ||
      _selectedCategoryId!.trim().isEmpty) {
    await _showMessage(
      'Missing category',
      'Please select a category.',
    );
    return;
  }

  if (_selectedWalletId == null ||
      _selectedWalletId!.trim().isEmpty) {
    await _showMessage(
      'Missing wallet',
      'Please select a wallet.',
    );
    return;
  }

  setState(() {
    _isSaving = true;
  });

  try {
    final existingTransaction = widget.transaction;

    final TransactionModel transaction = TransactionModel(
      id: existingTransaction?.id ?? _generateUuid(),
      userId: existingTransaction?.userId ?? '',
      walletId: _selectedWalletId!,
      categoryId: _selectedCategoryId!,
      title: title,
      amount: amount,
      type: _isIncome ? 'income' : 'expense',
      transactionDate:
          existingTransaction?.transactionDate ?? DateTime.now(),
      note: existingTransaction?.note ?? title,
      createdAt: existingTransaction?.createdAt ?? DateTime.now(),
    );

    bool success;

    if (widget.isEdit) {
      success = await _transactionController.updateTransaction(
        transaction,
      );
    } else {
      success = await _transactionController.addTransaction(
        transaction,
      );
    }

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _isSaving = false;
      });
    }
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    await _showMessage(
      widget.isEdit ? 'Update failed' : 'Save failed',
      widget.isEdit
          ? 'Unable to update transaction. Please try again.'
          : 'Unable to save transaction. Please try again.',
    );
  }
}
  // ------------------------------------------------------------
  // MESSAGE
  // ------------------------------------------------------------

  Future<void> _showMessage(
    String title,
    String message,
  ) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // UUID
  // ------------------------------------------------------------

  String _generateUuid() {
    final now = DateTime.now().microsecondsSinceEpoch;

    return '${now.toRadixString(16)}-'
        '${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}-'
        '${now.toString().substring(0, 8)}';
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Text(
  widget.isEdit ? 'Edit Transaction' : 'Add Transaction',
  style: AppTextStyles.headingMedium(isDark),
),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------
              // TYPE
              // --------------------------------------------------

              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Expense'),
                      selected: !_isIncome,
                      onSelected: (_) {
                        if (!mounted) return;

                        setState(() {
                          _isIncome = false;
                          _selectedCategoryId = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Income'),
                      selected: _isIncome,
                      onSelected: (_) {
                        if (!mounted) return;

                        setState(() {
                          _isIncome = true;
                          _selectedCategoryId = null;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // --------------------------------------------------
              // TITLE
              // --------------------------------------------------

              TextField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g. Grocery shopping',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // --------------------------------------------------
              // AMOUNT
              // --------------------------------------------------

              TextField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: 'Enter amount',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // --------------------------------------------------
              // CATEGORY
              // --------------------------------------------------

              Obx(
                () {
                  final String requiredType =
                      _isIncome ? 'income' : 'expense';

                  final categories =
                      _categoryController.categoryList
                          .where(
                            (category) =>
                                category.type
                                    .trim()
                                    .toLowerCase() ==
                                requiredType,
                          )
                          .toList();

                  return DropdownButtonFormField<String>(
                    value: categories.any(
                      (category) =>
                          category.id ==
                          _selectedCategoryId,
                    )
                        ? _selectedCategoryId
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    hint: Text(
                      _isIncome
                          ? 'Select income category'
                          : 'Select expense category',
                    ),
                    items: categories.map(
                      (category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      },
                    ).toList(),
                    onChanged: (value) {
                      if (!mounted) return;

                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: 8),

              // --------------------------------------------------
              // MORE CATEGORY BUTTON
              // --------------------------------------------------

              if (!_isIncome)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _openMoreCategoryDialog,
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'More... Add your own category',
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // --------------------------------------------------
              // WALLET
              // --------------------------------------------------

              Obx(
                () {
                  final wallets =
                      _walletController.wallets;

                  return DropdownButtonFormField<String>(
                    value: wallets.any(
                      (wallet) =>
                          wallet.id ==
                          _selectedWalletId,
                    )
                        ? _selectedWalletId
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Wallet',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Select wallet'),
                    items: wallets.map(
                      (wallet) {
                        return DropdownMenuItem<String>(
                          value: wallet.id,
                          child: Text(wallet.name),
                        );
                      },
                    ).toList(),
                    onChanged: (value) {
                      if (!mounted) return;

                      setState(() {
                        _selectedWalletId = value;
                      });
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),

      // ----------------------------------------------------------
      // ACTIONS
      // ----------------------------------------------------------

      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              _isSaving ? null : _saveTransaction,
          child: _isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
             : Text(widget.isEdit ? 'Update' : 'Save'),
        ),
      ],
    );
  }
}

// ============================================================================
// CUSTOM CATEGORY DIALOG
// ============================================================================

class _CustomCategoryDialog extends StatefulWidget {
  const _CustomCategoryDialog();

  @override
  State<_CustomCategoryDialog> createState() =>
      _CustomCategoryDialogState();
}

class _CustomCategoryDialogState
    extends State<_CustomCategoryDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void _useName() {
    final String name = _controller.text.trim();

    if (name.isEmpty) {
      return;
    }

    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Custom Category'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          labelText: 'Category name',
          hintText: 'e.g. Shopping',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) {
          _useName();
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _useName,
          child: const Text('Use Name'),
        ),
      ],
    );
  }
}