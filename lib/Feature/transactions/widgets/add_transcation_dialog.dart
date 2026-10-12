import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';
import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';
import 'package:expense_mate/Feature/Categories/model/categories_model.dart';
import 'package:expense_mate/Feature/Categories/controller/categories_controller.dart';
import 'package:expense_mate/Feature/wallets/controller/wallets_controller.dart';

import 'package:expense_mate/Core/theme/custom_textstyle.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

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
  static const Uuid _uuid = Uuid();

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

      _isIncome =
          transaction.type.trim().toLowerCase() == 'income';
    }

    _loadData();
  }


Future<void> _loadData() async {
  try {
    // Load categories from the local database first.
    await _categoryController.fetchCategories();

    if (!mounted) return;

    // Then load wallets.
    await _walletController.loadWallets();
  } catch (e) {
    debugPrint('Unable to load transaction form data: $e');
  }

  if (mounted) {
    setState(() {});
  }
}


  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();

    super.dispose();
  }

  // ============================================================
  // CATEGORY HELPERS
  // ============================================================

  String _normalizeCategoryName(String? name) {
    return (name ?? '')
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  String _generateUuid() {
    return _uuid.v4();
  }

  /// Returns one visible category for each normalized name.
  ///
  /// The controller should group categories too, but this provides
  /// an additional safeguard against duplicate dropdown entries.
 
List<CategoryModel> _getUniqueCategories(
  List<CategoryModel> categories,
) {
  final Map<String, CategoryModel> grouped = {};

  for (final category in categories) {
    final nameKey = _normalizeCategoryName(category.name);

    if (nameKey.isEmpty) continue;

    final existing = grouped[nameKey];

    if (existing == null) {
      final ids = <String>{
        category.id,
        ...category.linkedIds,
      }.where((id) => id.isNotEmpty).toList();

      grouped[nameKey] = CategoryModel(
        id: category.id,
        name: category.name.trim(),
        icon: category.icon,
        colorValue: category.colorValue,
        isDefault: category.isDefault,
        type: 'both',
        linkedIds: ids,
      );

      continue;
    }

    final mergedIds = <String>{
      existing.id,
      ...existing.linkedIds,
      category.id,
      ...category.linkedIds,
    }.where((id) => id.isNotEmpty).toList();

    grouped[nameKey] = CategoryModel(
      id: existing.id,
      name: existing.name,
      icon: existing.icon,
      colorValue: existing.colorValue,
      isDefault: existing.isDefault || category.isDefault,
      type: 'both',
      linkedIds: mergedIds,
    );
  }

  return grouped.values.toList();
}

  /// Finds an existing visible category without filtering by type.
  CategoryModel? _findVisibleCategory(String name) {
    final normalizedName = _normalizeCategoryName(name);

    for (final category in _categoryController.categoryList) {
      if (_normalizeCategoryName(category.name) ==
          normalizedName) {
        return category;
      }
    }

    return null;
  }

  /// Resolves old category IDs to the currently displayed category.
  ///
  /// This is useful when an existing transaction still references
  /// one of the duplicate category IDs.
  String? _resolveCategoryId(String? categoryId) {
    if (categoryId == null || categoryId.isEmpty) {
      return null;
    }

    for (final category in _categoryController.categoryList) {
      if (category.id == categoryId ||
          category.linkedIds.contains(categoryId)) {
        return category.id;
      }
    }

    return categoryId;
  }

  // ============================================================
  // ADD CUSTOM CATEGORY
  // ============================================================

  Future<void> _openMoreCategoryDialog() async {
    if (!mounted || _isSaving) return;

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

    final String normalizedName =
        _normalizeCategoryName(name);

    // Check for an existing category regardless of its type.
    final existingCategory =
        _findVisibleCategory(name);

    if (existingCategory != null) {
      setState(() {
        _selectedCategoryId = existingCategory.id;
      });

      await _showMessage(
        'Category already exists',
        '"${existingCategory.name}" is already available. '
            'The existing category has been selected.',
      );

      return;
    }

    // Check the controller/local database too, in case a category
    // exists locally but is not currently displayed.
    final existingLocalCategory =
        await _categoryController.findCategoryByName(name);

    if (!mounted) return;

   if (existingLocalCategory != null) {
  final resolvedId = _resolveCategoryId(
    existingLocalCategory.id,
  );

  setState(() {
    _selectedCategoryId =
        resolvedId ?? existingLocalCategory.id;
  });

  // Local database mein category already hai.
  // Nayi category create nahi karni.
  return;
}
    final String categoryId = _generateUuid();

    // Keep the stored category type valid.
    // "both" is only a display/grouping concept, not a new
    // category type to store in the database.
    final CategoryModel newCategory = CategoryModel(
      id: categoryId,
      name: name,
      icon: 'category',
      colorValue: 0xFF2E7D32,
      isDefault: false,
      type: _isIncome ? 'income' : 'expense',
      linkedIds: [categoryId],
    );

    try {
      await _categoryController.addCategory(
        newCategory,
        closeDialog: false,
      );

      if (!mounted) return;

      // Reload/refresh category state through the controller's
      // existing addCategory implementation.
      final createdCategory =
          _findVisibleCategory(normalizedName);

      setState(() {
        _selectedCategoryId =
            createdCategory?.id ?? categoryId;
      });
    } catch (e) {
      debugPrint('Category creation failed: $e');

      if (!mounted) return;

      await _showMessage(
        'Category Error',
        'Unable to create the category. Please try again.',
      );
    }
  }

  // ============================================================
  // SAVE / UPDATE TRANSACTION
  // ============================================================

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

    if (amount == null ||
        !amount.isFinite ||
        amount <= 0) {
      await _showMessage(
        'Invalid amount',
        'Please enter a valid amount greater than zero.',
      );
      return;
    }

    // Both Income and Expense transactions must have a category.
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

    // Resolve a legacy category ID to the displayed category ID
    // whenever the grouped category is already available.
    final String resolvedCategoryId =
        _resolveCategoryId(_selectedCategoryId) ??
            _selectedCategoryId!;

    setState(() {
      _isSaving = true;
    });

    try {
      final existingTransaction = widget.transaction;

      final TransactionModel transaction = TransactionModel(
        id: existingTransaction?.id ?? _generateUuid(),

        // Preserve the original transaction's user ID during edit.
        // For new transactions, the controller/sync layer must
        // assign the authenticated user's ID if required.
        userId: existingTransaction?.userId ?? '',

        walletId: _selectedWalletId!,
        categoryId: resolvedCategoryId,
        title: title,
        amount: amount,
        type: _isIncome ? 'income' : 'expense',

        // Preserve the existing date/note behavior.
        transactionDate:
            existingTransaction?.transactionDate ??
                DateTime.now(),

        note: existingTransaction?.note ?? title,

        createdAt:
            existingTransaction?.createdAt ??
                DateTime.now(),
      );

      final bool success;

      if (widget.isEdit) {
        success = await _transactionController
            .updateTransaction(transaction);
      } else {
        success = await _transactionController
            .addTransaction(transaction);
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
      debugPrint('Transaction save/update failed: $e');

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      await _showMessage(
        widget.isEdit ? 'Update failed' : 'Save failed',
        widget.isEdit
            ? 'Unable to update the transaction. Please try again.'
            : 'Unable to save the transaction. Please try again.',
      );
    }
  }

  // ============================================================
  // MESSAGE DIALOG
  // ============================================================

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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Text(
        widget.isEdit
            ? 'Edit Transaction'
            : 'Add Transaction',
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
              // TRANSACTION TYPE
              // --------------------------------------------------

              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Expense'),
                      selected: !_isIncome,
                      onSelected: _isSaving
                          ? null
                          : (_) {
                              setState(() {
                                _isIncome = false;
                              });
                            },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Income'),
                      selected: _isIncome,
                      onSelected: _isSaving
                          ? null
                          : (_) {
                              setState(() {
                                _isIncome = true;
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
                enabled: !_isSaving,
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
                enabled: !_isSaving,
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

              Obx(() {
                final categories = _getUniqueCategories(
                  _categoryController.categoryList.toList(),
                );

debugPrint(
  'TRANSACTION FORM: '
  'type=${_isIncome ? "income" : "expense"}, '
  'categories=${categories.length}',
);
                // Resolve the selected ID, including an old ID
                // associated with a grouped category.
                String? dropdownValue;

                for (final category in categories) {
                  if (category.id == _selectedCategoryId ||
                      category.linkedIds
                          .contains(_selectedCategoryId)) {
                    dropdownValue = category.id;
                    break;
                  }
                }

                return DropdownButtonFormField<String>(
                  key: ValueKey(
                    'category_${_isIncome}_${categories.length}_'
                    '${dropdownValue ?? 'none'}',
                  ),
                  initialValue: dropdownValue,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Select category'),
                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category.id,
                      child: Text(
                        category.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                );
              }),

              const SizedBox(height: 8),

              // --------------------------------------------------
              // ADD CUSTOM CATEGORY
              // --------------------------------------------------

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed:
                      _isSaving ? null : _openMoreCategoryDialog,
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Add your own category',
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // --------------------------------------------------
              // WALLET
              // --------------------------------------------------

              Obx(() {
                final wallets =
                    _walletController.wallets.toList();

                final walletValue = wallets.any(
                  (wallet) =>
                      wallet.id == _selectedWalletId,
                )
                    ? _selectedWalletId
                    : null;

                return DropdownButtonFormField<String>(
                  key: ValueKey(
                    'wallet_${wallets.length}_'
                    '${walletValue ?? 'none'}',
                  ),
                  initialValue: walletValue,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Wallet',
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Select wallet'),
                  items: wallets.map((wallet) {
                    return DropdownMenuItem<String>(
                      value: wallet.id,
                      child: Text(
                        wallet.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          setState(() {
                            _selectedWalletId = value;
                          });
                        },
                );
              }),
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
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  widget.isEdit ? 'Update' : 'Save',
                ),
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

    if (name.isEmpty) return;

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