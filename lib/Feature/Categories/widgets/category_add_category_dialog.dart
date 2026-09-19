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

  final CategoriesController controller = Get.find<CategoriesController>();

  String selectedIcon = 'food';

  final List<Map<String, dynamic>> categoryIcons = [
    {'name': 'food', 'icon': Icons.restaurant_rounded},
    {'name': 'transport', 'icon': Icons.directions_car_rounded},
    {'name': 'groceries', 'icon': Icons.shopping_basket_rounded},
    {'name': 'shopping', 'icon': Icons.shopping_bag_rounded},
    {'name': 'rent', 'icon': Icons.home_work_rounded},
    {'name': 'bills', 'icon': Icons.receipt_long_rounded},
    {'name': 'fuel', 'icon': Icons.local_gas_station_rounded},
    {'name': 'health', 'icon': Icons.health_and_safety_rounded},
    {'name': 'education', 'icon': Icons.school_rounded},
    {'name': 'mobile', 'icon': Icons.phone_android_rounded},
    {'name': 'internet', 'icon': Icons.wifi_rounded},
    {'name': 'clothing', 'icon': Icons.checkroom_rounded},
    {'name': 'travel', 'icon': Icons.flight_rounded},
    {'name': 'entertainment', 'icon': Icons.movie_rounded},
    {'name': 'fitness', 'icon': Icons.fitness_center_rounded},
    {'name': 'gifts', 'icon': Icons.card_giftcard_rounded},
    {'name': 'beauty', 'icon': Icons.face_retouching_natural_rounded},
    {'name': 'pets', 'icon': Icons.pets_rounded},
    {'name': 'home', 'icon': Icons.house_rounded},
    {'name': 'other', 'icon': Icons.more_horiz_rounded},
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

    final Color primaryColor =
        Theme.of(context).colorScheme.primary;

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

                // Pencil / edit icon ko hide karne ke liye
                prefixIcon: SizedBox.shrink(),
                icon: SizedBox.shrink(),
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
                final String iconName = item['name'] as String;
                final IconData iconData = item['icon'] as IconData;

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
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryColor.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? primaryColor
                            : Colors.grey.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Icon(
                      iconData,
                      size: 25,
                      color: isSelected
                          ? primaryColor
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
          onPressed: () {
            Get.back();
          },
          child: const Text('Cancel'),
        ),

        ElevatedButton(
          onPressed: () async {
            final String categoryName =
                nameController.text.trim();

            if (categoryName.isEmpty) {
              Get.snackbar(
                'Required',
                'Please enter category name.',
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }

            final newCategory = CategoryModel(
              id: DateTime.now()
                  .millisecondsSinceEpoch
                  .toString(),
              name: categoryName,
              icon: selectedIcon,
              colorValue: 0xFF2E7D32,
              isDefault: false,
              type: 'expense',
            );

            await controller.addCategory(newCategory);

            // Controller successful insert ke baad
            // dialog close karega.
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
