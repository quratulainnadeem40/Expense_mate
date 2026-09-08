import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';
import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';

class AddTransactionDialog extends StatelessWidget {
  const AddTransactionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController amountController = TextEditingController();

    final RxString selectedCategory = 'General'.obs;
    final List<String> categories = [
      'General',
      'Food',
      'Transport',
      'Shopping',
      'Bills',
      'Entertainment'
    ];

    // Find registered global instance instead of creating a duplicate
    final TransactionsController controller = Get.isRegistered<TransactionsController>()
        ? Get.find<TransactionsController>()
        : Get.put(TransactionsController());

    // Theme details extract
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final RxBool isIncome = false.obs;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Add Transaction', style: AppTextStyles.headingMedium(isDark)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. TITLE INPUT FIELD
            TextField(
              controller: titleController,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 2. AMOUNT INPUT FIELD
            TextField(
              controller: amountController,
              style: TextStyle(color: colorScheme.onSurface),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 3. CATEGORY DROPDOWN
            Obx(
              () => DropdownButtonFormField<String>(
                value: selectedCategory.value,
                dropdownColor: colorScheme.surface,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                ),
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(
                      category,
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    selectedCategory.value = newValue;
                  }
                },
              ),
            ),

            const SizedBox(height: 12),

            // 4. INCOME / EXPENSE SWITCH
            Obx(
              () => SwitchListTile(
                title: Text(
                  isIncome.value ? 'Income' : 'Expense',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                value: isIncome.value,
                activeColor: Colors.green,
                onChanged: (val) => isIncome.value = val,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'Cancel',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          onPressed: () {
            final titleText = titleController.text.trim();
            final amountText = amountController.text.trim();

            if (titleText.isNotEmpty && amountText.isNotEmpty) {
              final newTx = TransactionModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleText,
                amount: double.tryParse(amountText) ?? 0.0,
                category: selectedCategory.value,
                date: DateTime.now(),
                isIncome: isIncome.value,
              );

              controller.addTransaction(newTx);
              Get.back();
            } else {
              Get.snackbar(
                'Error',
                'Please fill all fields',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: colorScheme.errorContainer,
                colorText: colorScheme.onErrorContainer,
              );
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}