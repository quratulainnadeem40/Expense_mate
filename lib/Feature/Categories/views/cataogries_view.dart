import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:expense_mate/Feature/Categories/widgets/category_add_category_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controller/categories_controller.dart';
import 'category_transactions_screen.dart';

// Drawer Navigation
import 'package:expense_mate/Feature/wallets/binding/wallets_binding.dart';
import 'package:expense_mate/Feature/wallets/view/wallets_view.dart';
import 'package:expense_mate/Feature/Budgets/bindings/budget_bindings.dart';
import 'package:expense_mate/Feature/Budgets/view/budget_view.dart';
import 'package:expense_mate/Feature/goals/binding/goals_binding.dart';
import 'package:expense_mate/Feature/goals/view/goals_view.dart';
import 'package:expense_mate/Feature/bills_reminders/binding/bills_reminders_binding.dart';
import 'package:expense_mate/Feature/bills_reminders/view/bills_reminders_view.dart';
import 'package:expense_mate/Feature/settings/binding/settings_binding.dart';
import 'package:expense_mate/Feature/settings/view/settings_view.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  String? selectedForDeleteId;

  late final CategoriesController controller;

  final RxBool isDrawerOpen = false.obs;

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<CategoriesController>()
        ? Get.find<CategoriesController>()
        : Get.put(CategoriesController());
  }

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

  void _closeDrawerAndNavigate(
    Widget Function() page, {
    Bindings? binding,
  }) {
    isDrawerOpen.value = false;

    Future.delayed(const Duration(milliseconds: 180), () {
      Get.to(
        page,
        binding: binding,
      );
    });
  }

  Color _getCategoryColor(
    String name,
    int defaultColorValue,
  ) {
    switch (name.toLowerCase().trim()) {
      case 'transport':
        return const Color(0xFF42A5F5);

      case 'shopping':
        return const Color(0xFFAB47BC);

      case 'salary':
        return const Color(0xFFFFA726);

      case 'investment':
        return const Color(0xFFEF5350);

      case 'health':
        return const Color(0xFF7E57C2);

      case 'gift':
        return const Color(0xFFEC407A);

      case 'freelance':
        return const Color(0xFF26A69A);

      case 'business':
        return const Color(0xFF5C6BC0);

      case 'bills':
        return const Color(0xFFFF7043);

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

    final int hash = name.codeUnits.fold(
      0,
      (prev, curr) => prev + curr,
    );

    return customColors[hash % customColors.length];
  }

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

      case 'school':
      case 'education':
        return Icons.school_rounded;

      case 'home':
        return Icons.home_rounded;

      case 'phone':
        return Icons.phone_android_rounded;

      case 'fitness':
        return Icons.fitness_center_rounded;

      case 'bookmark':
        return Icons.bookmark_rounded;

      default:
        return Icons.category_rounded;
    }
  }

  Future<void> _openAddCategoryDialog() async {
    await Get.dialog(
      const AddCategoryDialog(),
      barrierDismissible: false,
    );

    await controller.fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF7F9F8),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,

        leading: IconButton(
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
                color: isDark
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),

      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (selectedForDeleteId != null) {
                setState(() {
                  selectedForDeleteId = null;
                });
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

              // Removed .take(5) to show all user-added categories completely
              final categories = controller.categoryList;

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

                  final bool isDeleteVisible =
                      selectedForDeleteId == category.id;

                  bool isDefaultCategory = false;
                  try {
                    isDefaultCategory = category.isDefault;
                  } catch (_) {}

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),

                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1E1E)
                          : Colors.white,
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
                            Get.to(
                              () => CategoryTransactionsScreen(
                                categoryName: category.name,
                              ),
                            );
                          }
                        },

                        onLongPress: () {
                          if (!isDefaultCategory) {
                            setState(() {
                              selectedForDeleteId = category.id;
                            });
                          }
                        },

                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),

                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color:
                                      baseColor.withOpacity(0.18),
                                  shape: BoxShape.circle,
                                ),

                                child: Icon(
                                  _getIconData(category.icon),
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
                                          const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),

                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.grey[800]
                                            : const Color(
                                                0xFFF0F2F5,
                                              ),
                                        borderRadius:
                                            BorderRadius.circular(
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

                              if (!isDeleteVisible)
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.grey[400],
                                  size: 22,
                                ),

                              if (isDeleteVisible) ...[
                                const SizedBox(width: 8),

                                InkWell(
                                  onTap: () async {
                                    await controller.deleteCategory(
                                      category.id,
                                    );

                                    if (mounted) {
                                      setState(() {
                                        selectedForDeleteId = null;
                                      });
                                    }
                                  },

                                  borderRadius:
                                      BorderRadius.circular(8),

                                  child: Container(
                                    padding:
                                        const EdgeInsets.all(8),

                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFEBEE),
                                      borderRadius:
                                          BorderRadius.circular(8),
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
                            MediaQuery.of(context).size.width * 0.78,

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
                              color:
                                  Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
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
                                            const Color(0xFF2E7D32),
                                            const Color(0xFF1B5E20),
                                          ]
                                        : [
                                            const Color(0xFF4CAF50),
                                            const Color(0xFF388E3C),
                                          ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),

                                currentAccountPictureSize:
                                    const Size.square(64),

                                currentAccountPicture:
                                    Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),

                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,

                                    child: Text(
                                      _userName.isNotEmpty
                                          ? _userName[0]
                                              .toUpperCase()
                                          : 'U',

                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight:
                                            FontWeight.bold,
                                        color:
                                            Color(0xFF2E7D32),
                                      ),
                                    ),
                                  ),
                                ),

                                accountName: Text(
                                  _userName,
                                  style: const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),

                                accountEmail: Text(
                                  Supabase.instance.client.auth
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
                                      const EdgeInsets.symmetric(
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
                                          const Color(0xFF2B82FB),
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

                                    const SizedBox(height: 12),

                                    _buildDrawerOption(
                                      context: context,
                                      icon: Icons
                                          .pie_chart_rounded,
                                      iconColor:
                                          const Color(0xFFFF9800),
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

                                    const SizedBox(height: 12),

                                    _buildDrawerOption(
                                      context: context,
                                      icon:
                                          Icons.stars_rounded,
                                      iconColor:
                                          const Color(0xFFE91E63),
                                      title: 'Goals',
                                      subtitle:
                                          'Track your financial targets and savings',
                                      onTap: () =>
                                          _closeDrawerAndNavigate(
                                        () => const GoalsView(),
                                        binding:
                                            GoalsBinding(),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    _buildDrawerOption(
                                      context: context,
                                      icon: Icons
                                          .notifications_active_rounded,
                                      iconColor:
                                          const Color(0xFF9C27B0),
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

                                    const SizedBox(height: 12),

                                    _buildDrawerOption(
                                      context: context,
                                      icon:
                                          Icons.person_rounded,
                                      iconColor:
                                          const Color(0xFF00BCD4),
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
        ],
      ),

      floatingActionButton: Obx(() {
        if (isDrawerOpen.value) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton(
          onPressed: _openAddCategoryDialog,

          backgroundColor:
              const Color(0xFF2E7D32),

          elevation: 4,

          mini: true,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),

          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 22,
          ),
        );
      }),
    );
  }

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
          borderRadius: BorderRadius.circular(16),

          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),

            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,

                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
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
                          fontWeight: FontWeight.w700,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF212121),
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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