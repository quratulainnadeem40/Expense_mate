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

  final CategoriesController controller = Get.find();

  String selectedIcon = 'shopping_bag';

  final List<Map<String, dynamic>> categoryIcons = [
    {
      'name': 'shopping_bag',
      'icon': Icons.shopping_bag_outlined,
    },
    {
      'name': 'restaurant',
      'icon': Icons.restaurant_outlined,
    },
    {
      'name': 'home',
      'icon': Icons.home_outlined,
    },
    {
      'name': 'directions_car',
      'icon': Icons.directions_car_outlined,
    },
    {
      'name': 'movie',
      'icon': Icons.movie_outlined,
    },
    {
      'name': 'school',
      'icon': Icons.school_outlined,
    },
    {
      'name': 'health',
      'icon': Icons.health_and_safety_outlined,
    },
    {
      'name': 'phone',
      'icon': Icons.phone_android_outlined,
    },
    {
      'name': 'fitness',
      'icon': Icons.fitness_center_outlined,
    },
    {
      'name': 'bookmark',
      'icon': Icons.bookmark_border,
    },
  ];

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Text(
        'Add New Category',
        style: AppTextStyles.headingMedium(isDark),
      ),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Enter category name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Select Icon',
              style: AppTextStyles.bodyMedium(isDark),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: categoryIcons.map((item) {
                final String iconName = item['name'];
                final IconData iconData = item['icon'];

                final bool isSelected =
                    selectedIcon == iconName;

                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedIcon = iconName;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                            : Colors.grey.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Icon(
                      iconData,
                      size: 24,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),

       ElevatedButton(
  onPressed: () async {
    final String categoryName = nameController.text.trim();

    if (categoryName.isEmpty) {
      Get.snackbar(
        'Required',
        'Please enter category name.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final newCategory = CategoryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: categoryName,
      icon: selectedIcon,
      colorValue: 0xFF2E7D32,
      isDefault: false,
      type: 'expense',
    );

    await controller.addCategory(newCategory);

    if (Get.isDialogOpen == true) {
      Get.back();
    }
  },
  child: const Text('Add'),
),
      ],
    );
  }
}

