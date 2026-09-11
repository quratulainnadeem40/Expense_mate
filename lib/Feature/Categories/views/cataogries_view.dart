import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:expense_mate/Feature/Categories/widgets/category_add_category_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/categories_controller.dart';
import 'category_transactions_screen.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  String? selectedForDeleteId;

  // Dynamic & Fallback Color Logic
  Color _getCategoryColor(String name, int defaultColorValue) {
    switch (name.toLowerCase().trim()) {
      case 'transport':
        return const Color(0xFF42A5F5); // Blue
      case 'shopping':
        return const Color(0xFFAB47BC); // Purple
      case 'salary':
        return const Color(0xFFFFA726); // Amber
      case 'investment':
        return const Color(0xFFEF5350); // Coral Red
      case 'health':
        return const Color(0xFF7E57C2); // Deep Purple
      case 'gift':
        return const Color(0xFFEC407A); // Pink
      case 'freelance':
        return const Color(0xFF26A69A); // Teal
      case 'business':
        return const Color(0xFF5C6BC0); // Indigo
      case 'bills':
        return const Color(0xFFFF7043); // Orange
      case 'other':
        return const Color(0xFF78909C); // Blue Grey
    }

    if (defaultColorValue != 0 && defaultColorValue != 0xFF757575) {
      return Color(defaultColorValue);
    }

    // Hash fallback for new categories created by user
    final List<Color> customColors = [
      const Color(0xFF26A69A),
      const Color(0xFFAB47BC),
      const Color(0xFFFFA726),
      const Color(0xFF42A5F5),
      const Color(0xFFEC407A),
      const Color(0xFF66BB6A),
      const Color(0xFFFF7043),
      const Color(0xFF8D6E63),
    ];

    final int hash = name.codeUnits.fold(0, (prev, curr) => prev + curr);
    return customColors[hash % customColors.length];
  }

  // Icons Helper
  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase().trim()) {
      case 'restaurant':
      case 'food':
        return Icons.restaurant;
      case 'directions_car':
      case 'transport':
        return Icons.directions_car_rounded;
      case 'shopping_bag':
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'receipt_long':
      case 'bills':
        return Icons.receipt_long_rounded;
      case 'movie':
      case 'entertainment':
        return Icons.movie_rounded;
      case 'work':
      case 'salary':
      case 'freelance':
        return Icons.account_balance_wallet_rounded;
      case 'business':
        return Icons.business_center_rounded;
      case 'investment':
        return Icons.trending_up_rounded;
      case 'health':
        return Icons.favorite_rounded;
      case 'gift':
        return Icons.card_giftcard_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final controller = Get.isRegistered<CategoriesController>()
        ? Get.find<CategoriesController>()
        : Get.put(CategoriesController());

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Icon(
            Icons.grid_view_rounded,
            color: isDark ? Colors.white : const Color(0xFF2E7D32),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categories',
              style: AppTextStyles.headingMedium(isDark).copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Manage your expense categories',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          if (selectedForDeleteId != null) {
            setState(() {
              selectedForDeleteId = null;
            });
          }
        },
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.categoryList.isEmpty) {
            return const Center(
              child: Text(
                "No categories found",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 12, bottom: 80),
            itemCount: controller.categoryList.length,
            itemBuilder: (context, index) {
              final category = controller.categoryList[index];
              final Color baseColor = _getCategoryColor(category.name, category.colorValue);
              final int transactionCount = controller.getCategoryCount(category.id);
              final bool isDeleteVisible = selectedForDeleteId == category.id;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      if (selectedForDeleteId != null) {
                        setState(() {
                          selectedForDeleteId = null;
                        });
                      } else {
                        Get.to(() => CategoryTransactionsScreen(
                              categoryName: category.name,
                            ));
                      }
                    },
                    onLongPress: () {
                      if (!category.isDefault) {
                        setState(() {
                          selectedForDeleteId = category.id;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          // Colorful Icon Avatar
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: baseColor.withOpacity(0.18),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getIconData(category.icon),
                              color: baseColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Text Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.name,
                                  style: AppTextStyles.bodyLarge(isDark).copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.grey[800] : const Color(0xFFF0F2F5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$transactionCount transactions',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? Colors.grey[300] : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Chevron Right
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.grey[400],
                            size: 22,
                          ),

                          // Delete Option on Long Press
                          if (isDeleteVisible) ...[
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                controller.deleteCategory(category.id);
                                setState(() {
                                  selectedForDeleteId = null;
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Color(0xFFE57373),
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.dialog(const AddCategoryDialog()),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}