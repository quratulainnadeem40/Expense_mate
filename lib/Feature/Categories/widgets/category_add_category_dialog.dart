import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:expense_mate/Feature/Categories/model/categories_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/categories_controller.dart';

class AddCategoryDialog extends StatelessWidget {
  const AddCategoryDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final CategoriesController controller = Get.find();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Text('Add New Category', style: AppTextStyles.headingMedium(isDark)),
      content: TextField(
        controller: nameController,
        decoration: const InputDecoration(
          hintText: 'Enter category name',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (nameController.text.isNotEmpty) {
              final newCategory = CategoryModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text.trim(),
                icon: 'bookmark',
                colorValue: 0xFF2E7D32,
                isDefault: false,
              );
              controller.addCategory(newCategory);
              Get.back();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}