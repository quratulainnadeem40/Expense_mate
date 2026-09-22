import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:expense_mate/Feature/Budgets/bindings/budget_bindings.dart';
import 'package:expense_mate/Feature/Budgets/view/budget_view.dart';
import 'package:expense_mate/Feature/Categories/widgets/category_add_category_dialog.dart';
import 'package:expense_mate/Feature/goals/binding/goals_binding.dart';
import 'package:expense_mate/Feature/goals/view/goals_view.dart';
import 'package:expense_mate/Feature/bills_reminders/binding/bills_reminders_binding.dart';
import 'package:expense_mate/Feature/bills_reminders/view/bills_reminders_view.dart';
import 'package:expense_mate/Feature/settings/binding/settings_binding.dart';
import 'package:expense_mate/Feature/settings/view/settings_view.dart';
import 'package:expense_mate/Feature/wallets/binding/wallets_binding.dart';
import 'package:expense_mate/Feature/wallets/view/wallets_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expense_mate/Feature/settings/controller/settings_controller.dart';

import '../controller/categories_controller.dart';
import 'category_transactions_screen.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  final Set<String> selectedCategoryIds = <String>{};

  bool isSelectionMode = false;

  late final CategoriesController controller;

  final RxBool isDrawerOpen = false.obs;

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<CategoriesController>()
        ? Get.find<CategoriesController>()
        : Get.put(CategoriesController());
  }

  // ============================================================
  // DRAWER
  // ============================================================

  void _closeDrawerInstantly() {
    if (isDrawerOpen.value) {
      isDrawerOpen.value = false;
    }
  }

  void _closeDrawerAndNavigate(
    Widget Function() page, {
    Bindings? binding,
  }) {
    isDrawerOpen.value = false;

    Future.delayed(const Duration(milliseconds: 180), () {
      Get.to(page, binding: binding);
    });
  }

  // ============================================================
  // SELECTION MODE
  // ============================================================

  void _enterSelectionMode(String categoryId) {
    setState(() {
      isSelectionMode = true;
      selectedCategoryIds.add(categoryId);
    });
  }

  void _toggleCategorySelection(String categoryId) {
    setState(() {
      if (selectedCategoryIds.contains(categoryId)) {
        selectedCategoryIds.remove(categoryId);
      } else {
        selectedCategoryIds.add(categoryId);
      }

      if (selectedCategoryIds.isEmpty) {
        isSelectionMode = false;
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      isSelectionMode = false;
      selectedCategoryIds.clear();
    });
  }

  Future<void> _showDeleteConfirmationDialog(
    List<String> idsToDelete,
  ) async {
    final selectedCategories = controller.categoryList
        .where((category) => idsToDelete.contains(category.id))
        .toList();

    final categoryNames = selectedCategories.map((category) => category.name).toList();
    final linkedCount = selectedCategories.fold<int>(
      0,
      (sum, category) => sum + controller.getCategoryCount(category.id),
    );

    final hasLinkedData = linkedCount > 0;

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete category?'),
        content: Text(
          categoryNames.length == 1
              ? hasLinkedData
                  ? 'This will permanently delete "${categoryNames.first}" and all related transaction data from the Transactions screen.\n\nDo you want to continue?'
                  : 'This will permanently delete "${categoryNames.first}".\n\nDo you want to continue?'
              : hasLinkedData
                  ? 'This will permanently delete ${categoryNames.length} categories and all related transaction data from the Transactions screen.\n\nDo you want to continue?'
                  : 'This will permanently delete ${categoryNames.length} categories.\n\nDo you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
            ),
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    await controller.deleteCategories(idsToDelete);

    if (mounted) {
      setState(() {
        isSelectionMode = false;
        selectedCategoryIds.clear();
      });
    }
  }

  Future<void> _deleteSelectedCategories() async {
    if (selectedCategoryIds.isEmpty) {
      return;
    }

    final idsToDelete = selectedCategoryIds.toList();
    await _showDeleteConfirmationDialog(idsToDelete);
  }

  // ============================================================
  // USER NAME
  // ============================================================

  String get _userName {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      final nameFromMetaData =
          user.userMetadata?['full_name'] ??
          user.userMetadata?['name'];

      if (nameFromMetaData != null &&
          nameFromMetaData.toString().isNotEmpty) {
        return nameFromMetaData.toString();
      }

      if (user.email != null && user.email!.contains('@')) {
        final emailPrefix = user.email!.split('@').first;

        if (emailPrefix.isNotEmpty) {
          return emailPrefix[0].toUpperCase() +
              emailPrefix.substring(1);
        }
      }
    }
    return 'User';
  }

  // ============================================================
  // ADD CATEGORY
  // ============================================================

  Future<void> _openAddCategoryDialog() async {
    await Get.dialog(
      const AddCategoryDialog(),
      barrierDismissible: false,
    );

    await controller.fetchCategories();
  }

  // ============================================================
  // CATEGORY COLORS
  // ============================================================

  Color _getCategoryColor(
    String name,
    int defaultColorValue,
  ) {
    switch (name.toLowerCase().trim()) {
      case 'food':
      case 'food & dining':
      case 'restaurant':
      case 'meal':
        return const Color(0xFFFF7043);

      case 'groceries':
        return const Color(0xFF66BB6A);

      case 'rent':
      case 'housing':
      case 'home':
        return const Color(0xFF42A5F5);

      case 'bills':
      case 'utilities':
        return const Color(0xFFFF9800);

      case 'transport':
      case 'transportation':
        return const Color(0xFF42A5F5);

      case 'fuel':
        return const Color(0xFFE53935);

      case 'shopping':
        return const Color(0xFFAB47BC);

      case 'clothing':
        return const Color(0xFFEC407A);

      case 'health':
      case 'healthcare':
      case 'medicine':
        return const Color(0xFFE53935);

      case 'education':
      case 'school':
        return const Color(0xFF5C6BC0);

      case 'mobile':
      case 'phone':
      case 'mobile & internet':
        return const Color(0xFF26A69A);

      case 'internet':
      case 'wifi':
        return const Color(0xFF29B6F6);

      case 'entertainment':
      case 'movie':
        return const Color(0xFF7E57C2);

      case 'travel':
      case 'flight':
        return const Color(0xFF26A69A);

      case 'beauty':
      case 'personal care':
        return const Color(0xFFEC407A);

      case 'fitness':
      case 'sports':
        return const Color(0xFF66BB6A);

      case 'pets':
        return const Color(0xFF8D6E63);

      case 'gifts':
      case 'gift':
      case 'gifts & donations':
        return const Color(0xFFE91E63);

      case 'subscriptions':
        return const Color(0xFF7E57C2);

      case 'home maintenance':
      case 'maintenance':
      case 'tools':
        return const Color(0xFF78909C);

      case 'salary':
        return const Color(0xFFFFA726);

      case 'investment':
        return const Color(0xFFEF5350);

      case 'freelance':
        return const Color(0xFF26A69A);

      case 'business':
        return const Color(0xFF5C6BC0);

      case 'other':
        return const Color(0xFF78909C);
    }

    if (defaultColorValue != 0 &&
        defaultColorValue != 0xFF757575) {
      return Color(defaultColorValue);
    }

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

    final int hash =
        name.codeUnits.fold(0, (prev, curr) => prev + curr);

    return customColors[hash % customColors.length];
  }

  // ============================================================
  // CATEGORY ICONS
  // ============================================================

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase().trim()) {
      case 'food':
      case 'food & dining':
      case 'restaurant':
      case 'meal':
        return Icons.restaurant_rounded;

      case 'groceries':
        return Icons.shopping_basket_rounded;

      case 'rent':
      case 'housing':
      case 'home':
        return Icons.home_work_rounded;

      case 'bills':
      case 'utilities':
        return Icons.receipt_long_rounded;

      case 'transport':
      case 'transportation':
      case 'directions_car':
        return Icons.directions_car_rounded;

      case 'fuel':
        return Icons.local_gas_station_rounded;

      case 'shopping':
      case 'shopping_bag':
        return Icons.shopping_bag_rounded;

      case 'clothing':
        return Icons.checkroom_rounded;

      case 'health':
      case 'healthcare':
      case 'medicine':
        return Icons.medical_services_rounded;

      case 'education':
      case 'school':
        return Icons.school_rounded;

      case 'mobile':
      case 'phone':
      case 'mobile & internet':
        return Icons.phone_android_rounded;

      case 'internet':
      case 'wifi':
        return Icons.wifi_rounded;

      case 'entertainment':
      case 'movie':
        return Icons.movie_rounded;

      case 'travel':
      case 'flight':
        return Icons.flight_rounded;

      case 'beauty':
      case 'personal care':
        return Icons.face_retouching_natural_rounded;

      case 'fitness':
      case 'sports':
        return Icons.fitness_center_rounded;

      case 'pets':
        return Icons.pets_rounded;

      case 'gifts':
      case 'gift':
      case 'gifts & donations':
        return Icons.card_giftcard_rounded;

      case 'subscriptions':
        return Icons.subscriptions_rounded;

      case 'home maintenance':
      case 'maintenance':
      case 'tools':
        return Icons.handyman_rounded;

      // Existing categories
      case 'work':
      case 'salary':
      case 'freelance':
        return Icons.account_balance_wallet_rounded;

      case 'business':
        return Icons.business_center_rounded;

      case 'investment':
        return Icons.trending_up_rounded;

      case 'bookmark':
        return Icons.bookmark_rounded;

      case 'other':
        return Icons.more_horiz_rounded;

      default:
        return Icons.category_rounded;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

 @override
Widget build(BuildContext context) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;

  final settingsController = Get.find<SettingsController>();

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          _closeDrawerInstantly();
        }
      },
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF121212)
            : const Color(0xFFF7F9F8),

        // ========================================================
        // APP BAR
        // ========================================================

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,

          leading: isSelectionMode
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                  ),
                  onPressed: _exitSelectionMode,
                )
              : IconButton(
                  icon: Icon(
                    Icons.menu_rounded,
                    color: isDark
                        ? Colors.white
                        : const Color(0xFF2E7D32),
                    size: 28,
                  ),
                  onPressed: () {
                    isDrawerOpen.value = true;
                  },
                ),

          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isSelectionMode
                    ? '${selectedCategoryIds.length} selected'
                    : 'Categories',
                style: AppTextStyles.headingMedium(
                  isDark,
                ).copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                'Manage your expense categories',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
            ],
          ),

          actions: [
            if (isSelectionMode)
              IconButton(
                tooltip: 'Delete selected categories',
                onPressed: selectedCategoryIds.isEmpty
                    ? null
                    : _deleteSelectedCategories,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                ),
              )
            else
              TextButton(
                onPressed: () {
                  setState(() {
                    isSelectionMode = true;
                  });
                },
                child: const Text('Select'),
              ),
          ],
        ),

        // ========================================================
        // BODY
        // ========================================================

        body: Stack(
          children: [
            GestureDetector(
              onTap: () {
                if (isSelectionMode) {
                  _exitSelectionMode();
                }
              },

              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (controller.categoryList.isEmpty) {
                  return const Center(
                    child: Text(
                      'No categories found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                final categories =
                    controller.categoryList.toList();

                return ListView.builder(
                  padding: const EdgeInsets.only(
                    top: 12,
                    bottom: 100,
                  ),

                  itemCount: categories.length,

                  itemBuilder: (context, index) {
                    final category = categories[index];

                    final Color baseColor =
                        _getCategoryColor(
                      category.name,
                      category.colorValue,
                    );

                    final int transactionCount =
                        controller.getCategoryCount(
                      category.id,
                    );

                    final bool isDefaultCategory =
                        category.isDefault;

                    final bool isSelected =
                        selectedCategoryIds.contains(
                      category.id,
                    );

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),

                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E1E1E)
                            : Colors.white,

                        borderRadius:
                            BorderRadius.circular(16),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),

                      child: Material(
                        color: Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(16),

                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(16),

                          onTap: () {
                            _closeDrawerInstantly();

                            if (isSelectionMode) {
                              _toggleCategorySelection(
                                category.id,
                              );
                            } else {
                              Get.to(
                                () =>
                                    CategoryTransactionsScreen(
                                  categoryName:
                                      category.name,
                                ),
                              );
                            }
                          },

                          onLongPress: () {
                            if (!isDefaultCategory) {
                              if (isSelectionMode) {
                                _toggleCategorySelection(
                                  category.id,
                                );
                              } else {
                                _enterSelectionMode(
                                  category.id,
                                );
                              }
                            }
                          },

                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),

                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,

                                  decoration: BoxDecoration(
                                    color: baseColor
                                        .withOpacity(0.18),
                                    shape: BoxShape.circle,
                                  ),

                                  child: Icon(
                                    _getIconData(
                                      category.icon,
                                    ),
                                    color: baseColor,
                                    size: 24,
                                  ),
                                ),

                                const SizedBox(width: 16),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Text(
                                        category.name,
                                        style:
                                            AppTextStyles.bodyLarge(
                                          isDark,
                                        ).copyWith(
                                          fontWeight:
                                              FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Container(
                                        padding:
                                            const EdgeInsets
                                                .symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),

                                        decoration:
                                            BoxDecoration(
                                          color: isDark
                                              ? Colors.grey[800]
                                              : const Color(
                                                  0xFFF0F2F5,
                                                ),
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            12,
                                          ),
                                        ),

                                        child: Text(
                                          '$transactionCount transactions',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark
                                                ? Colors.grey[300]
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                if (isSelectionMode)
                                  Icon(
                                    isSelected
                                        ? Icons
                                            .check_circle_rounded
                                        : Icons
                                            .circle_outlined,
                                    color: isSelected
                                        ? const Color(
                                            0xFF2EA44F,
                                          )
                                        : Colors.grey[400],
                                    size: 24,
                                  )
                                else
                                  Icon(
                                    Icons
                                        .chevron_right_rounded,
                                    color: Colors.grey[400],
                                    size: 22,
                                  ),
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

            // ======================================================
            // DRAWER
            // ======================================================

            Obx(() {
              if (!isDrawerOpen.value) {
                return const SizedBox.shrink();
              }

              return Positioned.fill(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        isDrawerOpen.value = false;
                      },
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerLeft,

                      child: SafeArea(
                        child: Container(
                          width:
                              MediaQuery.of(context).size.width *
                                  0.78,

                          margin: const EdgeInsets.only(
                            left: 12,
                            top: 8,
                            bottom: 8,
                          ),

                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E1E1E)
                                : const Color(0xFFF9FAFB),

                            borderRadius:
                                BorderRadius.circular(28),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.3),
                                blurRadius: 20,
                                offset:
                                    const Offset(0, 10),
                              ),
                            ],
                          ),

                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(28),

                            child: Column(
                              children: [
                                UserAccountsDrawerHeader(
                                  margin: EdgeInsets.zero,

                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isDark
                                          ? [
                                              const Color(
                                                0xFF2E7D32,
                                              ),
                                              const Color(
                                                0xFF1B5E20,
                                              ),
                                            ]
                                          : [
                                              const Color(
                                                0xFF4CAF50,
                                              ),
                                              const Color(
                                                0xFF388E3C,
                                              ),
                                            ],

                                      begin:
                                          Alignment.topLeft,
                                      end:
                                          Alignment.bottomRight,
                                    ),
                                  ),

                                  currentAccountPictureSize: const Size.square(
                                    64,
                                  ),

                                  currentAccountPicture: Obx(() {
  final imageUrl = settingsController.profilePictureUrl.value;
  final name = settingsController.profileName.value;

  final firstLetter = name.isNotEmpty
      ? name[0].toUpperCase()
      : 'U';

  return Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: Colors.white,
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: CircleAvatar(
      backgroundColor: Colors.white,
      backgroundImage: imageUrl.isNotEmpty
          ? NetworkImage(imageUrl)
          : null,
      child: imageUrl.isEmpty
          ? Text(
              firstLetter,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            )
          : null,
    ),
  );
}),

                                  accountName: Text(
                                    _userName,
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 18,
                                      color:
                                          Colors.white,
                                    ),
                                  ),

                                  accountEmail: Text(
                                    Supabase
                                            .instance
                                            .client
                                            .auth
                                            .currentUser
                                            ?.email ??
                                        '',

                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white
                                          .withOpacity(0.9),
                                    ),
                                  ),
                                ),

                                Expanded(
                                  child: ListView(
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal: 14,
                                      vertical: 16,
                                    ),

                                    physics:
                                        const BouncingScrollPhysics(),

                                    children: [
                                      _buildDrawerOption(
                                        context: context,
                                        icon: Icons
                                            .account_balance_wallet_rounded,
                                        iconColor:
                                            const Color(
                                          0xFF2B82FB,
                                        ),
                                        title: 'Wallets',
                                        subtitle:
                                            'Manage your cash, bank and other wallets',
                                        onTap: () =>
                                            _closeDrawerAndNavigate(
                                          () =>
                                              const WalletsView(),
                                          binding:
                                              WalletsBinding(),
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 12,
                                      ),

                                      _buildDrawerOption(
                                        context: context,
                                        icon: Icons
                                            .pie_chart_rounded,
                                        iconColor:
                                            const Color(
                                          0xFFFF9800,
                                        ),
                                        title: 'Budgets',
                                        subtitle:
                                            'Set and track monthly spending limits',
                                        onTap: () =>
                                            _closeDrawerAndNavigate(
                                          () =>
                                              const BudgetView(),
                                          binding:
                                              BudgetBinding(),
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 12,
                                      ),

                                      _buildDrawerOption(
                                        context: context,
                                        icon: Icons
                                            .stars_rounded,
                                        iconColor:
                                            const Color(
                                          0xFFE91E63,
                                        ),
                                        title: 'Goals',
                                        subtitle:
                                            'Track your financial targets and savings',
                                        onTap: () =>
                                            _closeDrawerAndNavigate(
                                          () =>
                                              const GoalsView(),
                                          binding:
                                              GoalsBinding(),
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 12,
                                      ),

                                      _buildDrawerOption(
                                        context: context,
                                        icon: Icons
                                            .notifications_active_rounded,
                                        iconColor:
                                            const Color(
                                          0xFF9C27B0,
                                        ),
                                        title:
                                            'Bills & Reminders',
                                        subtitle:
                                            'Manage upcoming bills and reminders',
                                        onTap: () =>
                                            _closeDrawerAndNavigate(
                                          () =>
                                              const BillsRemindersView(),
                                          binding:
                                              BillsRemindersBinding(),
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 12,
                                      ),

                                      _buildDrawerOption(
                                        context: context,
                                        icon: Icons
                                            .person_rounded,
                                        iconColor:
                                            const Color(
                                          0xFF00BCD4,
                                        ),
                                        title: 'Profile',
                                        subtitle:
                                            'Manage your profile and account settings',
                                        onTap: () =>
                                            _closeDrawerAndNavigate(
                                          () =>
                                              const SettingsView(),
                                          binding:
                                              SettingsBinding(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // ======================================================
            // ADD BUTTON
            // ======================================================

            Obx(() {
              if (isDrawerOpen.value) {
                return const SizedBox.shrink();
              }

              return Positioned(
                right: 16,
                bottom: 20,

                child: ElevatedButton.icon(
                  onPressed: _openAddCategoryDialog,

                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),

                  label: const Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    elevation: 5,

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DRAWER OPTION
  // ============================================================

  Widget _buildDrawerOption({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    final bool isDarkMode =
        theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF2A2A2A)
            : Colors.white,

        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              isDarkMode ? 0.2 : 0.04,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(16),

          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),

            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,

                  decoration: BoxDecoration(
                    color:
                        iconColor.withOpacity(0.12),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),

                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        title,

                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.w700,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(
                                  0xFF212121,
                                ),
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        subtitle,

                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,

                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}