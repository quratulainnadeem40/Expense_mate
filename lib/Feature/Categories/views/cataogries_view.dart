import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:expense_mate/Feature/Categories/widgets/category_add_category_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/categories_controller.dart';
import 'category_transactions_screen.dart';

class CategoriesView extends StatelessWidget {
  const CategoriesView({super.key});

  // Helper method to convert String icon names to IconData
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'receipt_long':
        return Icons.receipt_long;
      case 'movie':
        return Icons.movie;
      case 'work':
        return Icons.work;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Safety controller initialization
    final controller = Get.isRegistered<CategoriesController>()
        ? Get.find<CategoriesController>()
        : Get.put(CategoriesController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Categories', style: AppTextStyles.headingMedium(isDark)),
        centerTitle: true,
      ),
      body: Obx(() {
        return ListView.builder(
          itemCount: controller.categoryList.length,
          itemBuilder: (context, index) {
            final category = controller.categoryList[index];
            return GestureDetector(
              onTap: () {
                Get.to(() => CategoryTransactionsScreen(
                      categoryName: category.name,
                    ));
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(category.colorValue).withOpacity(0.2),
                      child: Icon(
                        _getIconData(category.icon),
                        color: Color(category.colorValue),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        category.name,
                        style: AppTextStyles.bodyLarge(isDark),
                      ),
                    ),
                    if (!category.isDefault)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey),
                        onPressed: () => controller.deleteCategory(category.id),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.dialog(const AddCategoryDialog()),
        child: const Icon(Icons.add),
      ),
    );
  }
}