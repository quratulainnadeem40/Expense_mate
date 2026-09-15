import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:expense_mate/Feature/Categories/model/categories_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/categories_controller.dart';

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final TextEditingController nameController = TextEditingController();

  String selectedType = 'expense';

  @override
  Widget build(BuildContext context) {
    final CategoriesController controller = Get.find();
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Text(
        'Add New Category',
        style: AppTextStyles.headingMedium(isDark),
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: 'Enter category name',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: selectedType,
            decoration: const InputDecoration(
              labelText: 'Category Type',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'expense',
                child: Text('Expense'),
              ),
              DropdownMenuItem(
                value: 'income',
                child: Text('Income'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedType = value;
                });
              }
            },
          ),
        ],
      ),

      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),

       ElevatedButton(
  onPressed: () async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter category name.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final newCategory = CategoryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      icon: 'bookmark',
      colorValue: 0xFF2E7D32,
      isDefault: false,
      type: selectedType,
    );

    // Add category first
    await controller.addCategory(newCategory);

    // Then close the dialog
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  },
  child: const Text('Add'),
),
      ],
    );
  }
  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}