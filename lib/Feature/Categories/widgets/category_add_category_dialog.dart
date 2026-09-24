import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:expense_mate/Core/theme/custom_colors.dart';
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
    {
      'name': 'food',
      'emoji': '🍽️',
      'icon': Icons.restaurant_rounded,
      'color': Color(0xFFE58A3D),
    },
    {
      'name': 'transport',
      'emoji': '🚗',
      'icon': Icons.directions_car_rounded,
      'color': Color(0xFF4E9A94),
    },
    {
      'name': 'groceries',
      'emoji': '🛒',
      'icon': Icons.shopping_basket_rounded,
      'color': Color(0xFF66BB6A),
    },
    {
      'name': 'shopping',
      'emoji': '🛍️',
      'icon': Icons.shopping_bag_rounded,
      'color': Color(0xFFE56B5D),
    },
    {
      'name': 'rent',
      'emoji': '🏠',
      'icon': Icons.home_work_rounded,
      'color': Color(0xFF5C83C6),
    },
    {
      'name': 'bills',
      'emoji': '🧾',
      'icon': Icons.receipt_long_rounded,
      'color': Color(0xFFFF9800),
    },
    {
      'name': 'fuel',
      'emoji': '⛽',
      'icon': Icons.local_gas_station_rounded,
      'color': Color(0xFFE53935),
    },
    {
      'name': 'health',
      'emoji': '🏥',
      'icon': Icons.health_and_safety_rounded,
      'color': Color(0xFFD85C78),
    },
    {
      'name': 'education',
      'emoji': '🎓',
      'icon': Icons.school_rounded,
      'color': Color(0xFF4F75B8),
    },
    {
      'name': 'mobile',
      'emoji': '📱',
      'icon': Icons.phone_android_rounded,
      'color': Color(0xFF5A9A8C),
    },
    {
      'name': 'internet',
      'emoji': '🌐',
      'icon': Icons.wifi_rounded,
      'color': Color(0xFF29B6F6),
    },
    {
      'name': 'clothing',
      'emoji': '👕',
      'icon': Icons.checkroom_rounded,
      'color': Color(0xFFEC407A),
    },
    {
      'name': 'travel',
      'emoji': '✈️',
      'icon': Icons.flight_rounded,
      'color': Color(0xFF26A69A),
    },
    {
      'name': 'entertainment',
      'emoji': '🎬',
      'icon': Icons.movie_rounded,
      'color': Color(0xFF8A6CC7),
    },
    {
      'name': 'fitness',
      'emoji': '🏋️',
      'icon': Icons.fitness_center_rounded,
      'color': Color(0xFFE0784D),
    },
    {
      'name': 'gifts',
      'emoji': '🎁',
      'icon': Icons.card_giftcard_rounded,
      'color': Color(0xFFD45D82),
    },
    {
      'name': 'beauty',
      'emoji': '💄',
      'icon': Icons.face_retouching_natural_rounded,
      'color': Color(0xFFEC407A),
    },
    {
      'name': 'pets',
      'emoji': '🐾',
      'icon': Icons.pets_rounded,
      'color': Color(0xFF8D6E63),
    },
    {
      'name': 'home',
      'emoji': '🏡',
      'icon': Icons.house_rounded,
      'color': Color(0xFF5C83C6),
    },
    {
      'name': 'other',
      'emoji': '📦',
      'icon': Icons.more_horiz_rounded,
      'color': Color(0xFF78909C),
    },
  ];

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    const Color accent = AppColors.primary;

    final Color surface = isDark
        ? const Color(0xFF202522)
        : const Color(0xFFF9FBF6);

    return AlertDialog(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 18,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      title: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [accent, Color(0xFF1B5E20)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 25,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CATEGORY SETUP',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.72),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Add New Category',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'Enter category name',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey[600],
                  fontSize: 14,
                ),

                // Pencil/Edit icon intentionally removed.
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white.withOpacity(0.72),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: accent, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Select Icon',
              style: AppTextStyles.bodyMedium(isDark).copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: categoryIcons.map((item) {
                final String iconName = item['name'] as String;

                // The Material icon stays in the list because the rest of
                // the app still maps the saved name to it. Here we only
                // *show* the emoji, which reads as a real object rather
                // than a flat glyph.
                final String emoji = item['emoji'] as String;

                final Color iconColor = item['color'] as Color;

                final bool isSelected = selectedIcon == iconName;

                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedIcon = iconName;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      // A solid dark fill would swallow the emoji's own
                      // colours, so the selected state is a stronger tint
                      // plus a ring instead.
                      color: isSelected
                          ? iconColor.withOpacity(isDark ? 0.34 : 0.24)
                          : (isDark
                                ? Colors.white.withOpacity(0.04)
                                : iconColor.withOpacity(0.10)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? iconColor
                            : (isDark ? Colors.white24 : Colors.black12),
                        width: isSelected ? 2.2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: iconColor.withOpacity(0.38),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          emoji,
                          style: const TextStyle(fontSize: 26, height: 1.15),
                        ),

                        if (isSelected)
                          Positioned(
                            right: 3,
                            top: 3,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: iconColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.16),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
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
          style: TextButton.styleFrom(
            foregroundColor: isDark ? Colors.white70 : Colors.grey[700],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text('Cancel'),
        ),

        FilledButton(
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
          style: FilledButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
