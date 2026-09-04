import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';
import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddTransactionDialog extends StatelessWidget {
  const AddTransactionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    
    final RxString selectedCategory = 'General'.obs;
    final List<String> categories = ['General', 'Food', 'Transport', 'Shopping', 'Bills', 'Entertainment'];

    final TransactionsController controller = Get.put(TransactionsController());
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final RxBool isIncome = false.obs;

    return AlertDialog(
      title: Text('Add Transaction', style: AppTextStyles.headingMedium(isDark)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            
            Obx(() => DropdownButtonFormField<String>(
                  value: selectedCategory.value,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      selectedCategory.value = newValue;
                    }
                  },
                )),
            
            const SizedBox(height: 12),
            Obx(() => SwitchListTile(
                  title: Text(isIncome.value ? 'Income' : 'Expense'),
                  value: isIncome.value,
                  onChanged: (val) => isIncome.value = val,
                )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (titleController.text.trim().isNotEmpty && amountController.text.trim().isNotEmpty) {
              final newTx = TransactionModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleController.text.trim(),
                amount: double.tryParse(amountController.text.trim()) ?? 0.0,
                category: selectedCategory.value,
                date: DateTime.now(),
                isIncome: isIncome.value,
              );
              
              controller.addTransaction(newTx);
              Get.back();
            } else {
              Get.snackbar('Error', 'Please fill all fields', snackPosition: SnackPosition.BOTTOM);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}