import 'package:expense_mate/Feature/Budgets/bindings/budget_bindings.dart';
import 'package:expense_mate/Feature/Budgets/view/budget_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Feature Views & Bindings
import 'package:expense_mate/Feature/wallets/binding/wallets_binding.dart';
import 'package:expense_mate/Feature/wallets/view/wallets_view.dart';
import 'package:expense_mate/Feature/goals/binding/goals_binding.dart';
import 'package:expense_mate/Feature/goals/view/goals_view.dart';
import 'package:expense_mate/Feature/bills_reminders/binding/bills_reminders_binding.dart';
import 'package:expense_mate/Feature/bills_reminders/view/bills_reminders_view.dart';
import 'package:expense_mate/Feature/settings/binding/settings_binding.dart';
import 'package:expense_mate/Feature/settings/view/settings_view.dart';

// Existing Home Imports
import 'package:expense_mate/Feature/Home/widgets/balance_card.dart';
import 'package:expense_mate/Feature/Categories/controller/categories_controller.dart';
import 'package:expense_mate/Feature/reports/controller/report_controller.dart';
import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';
import 'package:expense_mate/Feature/transactions/view/transcatio_screen.dart';
import 'package:expense_mate/Feature/Home/controller/home_controller.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Scaffold Key to force-close drawer directly
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  String get _userName {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      final nameFromMetaData =
          user.userMetadata?['full_name'] ?? user.userMetadata?['name'];

      if (nameFromMetaData != null &&
          nameFromMetaData.toString().isNotEmpty) {
        return nameFromMetaData.toString();
      }

      if (user.email != null && user.email!.contains('@')) {
        final emailPrefix = user.email!.split('@').first;
        return emailPrefix[0].toUpperCase() + emailPrefix.substring(1);
      }
    }

    return 'User';
  }

  String _getFormattedDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final month = months[date.month - 1];
    final day = date.day.toString().padLeft(2, '0');

    return "$month $day, ${date.year}";
  }

  String _getCategoryName(String categoryId) {
    if (!Get.isRegistered<CategoriesController>()) {
      return categoryId;
    }

    final categoriesController = Get.find<CategoriesController>();

    final category = categoriesController.categoryList.firstWhereOrNull(
      (category) => category.id == categoryId,
    );

    return category?.name ?? categoryId;
  }

  // Guaranteed Drawer Close Helper Method
  void _closeDrawerAndNavigate(
    Widget Function() page, {
    Bindings? binding,
  }) {
    if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeEndDrawer();
    }

    Future.delayed(const Duration(milliseconds: 150), () {
      Get.to(page, binding: binding);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportController = Get.find<ReportController>();
    final transactionsController =
        Get.find<HomeController>().transactionsController;
    

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,

      // =========================
      // DRAWER
      // =========================
      endDrawer: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(
            top: 12,
            bottom: 16,
            right: 12,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Drawer(
              elevation: 4,
              backgroundColor: isDarkMode
                  ? const Color(0xFF1E1E1E)
                  : const Color(0xFFF9FAFB),

              child: Column(
                children: [

                  // =========================
                  // X BUTTON - TOP RIGHT
                  // =========================
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 6,
                        right: 6,
                      ),
                      child: IconButton(
                        onPressed: () {
                          _scaffoldKey.currentState?.closeEndDrawer();
                        },
                        icon: Icon(
                          Icons.close,
                          size: 28,
                          color: isDarkMode
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ),

                  // =========================
                  // USER HEADER
                  // =========================
                  UserAccountsDrawerHeader(
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDarkMode
                            ? [
                                const Color(0xFF2E7D32),
                                const Color(0xFF1B5E20)
                              ]
                            : [
                                const Color(0xFF4CAF50),
                                const Color(0xFF388E3C)
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    currentAccountPictureSize:
                        const Size.square(64),

                    currentAccountPicture: Container(
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
                          )
                        ],
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Text(
                          _userName.isNotEmpty
                              ? _userName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    ),

                    accountName: Text(
                      _userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),

                    accountEmail: Text(
                      Supabase.instance.client.auth.currentUser?.email ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),

                  // =========================
                  // DRAWER OPTIONS
                  // =========================
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 16,
                      ),
                      children: [
                        _buildDrawerOption(
                          context: context,
                          icon: Icons.account_balance_wallet_rounded,
                          iconColor: const Color(0xFF2B82FB),
                          title: 'Wallets',
                          subtitle:
                              'Manage your cash, bank and other wallets',
                          onTap: () => _closeDrawerAndNavigate(
                            () => const WalletsView(),
                            binding: WalletsBinding(),
                          ),
                        ),

                        const SizedBox(height: 12),

                        _buildDrawerOption(
                          context: context,
                          icon: Icons.pie_chart_rounded,
                          iconColor: const Color(0xFFFF9800),
                          title: 'Budgets',
                          subtitle:
                              'Set and track monthly spending limits',
                          onTap: () => _closeDrawerAndNavigate(
                            () => const BudgetView(),
                            binding: BudgetBinding(),
                          ),
                        ),

                        const SizedBox(height: 12),

                        _buildDrawerOption(
                          context: context,
                          icon: Icons.stars_rounded,
                          iconColor: const Color(0xFFE91E63),
                          title: 'Goals',
                          subtitle:
                              'Track your financial targets and savings',
                          onTap: () => _closeDrawerAndNavigate(
                            () => const GoalsView(),
                            binding: GoalsBinding(),
                          ),
                        ),

                        const SizedBox(height: 12),

                        _buildDrawerOption(
                          context: context,
                          icon: Icons.notifications_active_rounded,
                          iconColor: const Color(0xFF9C27B0),
                          title: 'Bills & Reminders',
                          subtitle:
                              'Manage upcoming bills and reminders',
                          onTap: () => _closeDrawerAndNavigate(
                            () => const BillsRemindersView(),
                            binding: BillsRemindersBinding(),
                          ),
                        ),

                        const SizedBox(height: 12),

                        _buildDrawerOption(
                          context: context,
                          icon: Icons.person_rounded,
                          iconColor: const Color(0xFF00BCD4),
                          title: 'Profile',
                          subtitle:
                              'Manage your profile and account settings',
                          onTap: () => _closeDrawerAndNavigate(
                            () => const SettingsView(),
                            binding: SettingsBinding(),
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

      // =========================
      // HOME BODY
      // =========================
      body: SafeArea(
        child: Builder(
          builder: (context) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $_userName 👋',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color:
                                  theme.textTheme.titleLarge?.color ??
                                      (isDarkMode
                                          ? Colors.white
                                          : Colors.black87),
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            'Welcome back to Expense Mate',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDarkMode
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),

                      // MENU BUTTON
                      IconButton(
                        icon: Icon(
                          Icons.menu_rounded,
                          size: 28,
                          color: isDarkMode
                              ? Colors.white
                              : Colors.black87,
                        ),
                        onPressed: () {
                          _scaffoldKey.currentState
                              ?.openEndDrawer();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Obx(
                    () => BalanceCard(
                      totalBalance:
                          reportController.totalBalance,
                      totalIncome:
                          reportController.totalIncome,
                      totalExpense:
                          reportController.totalExpense,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              theme.textTheme.titleMedium?.color ??
                                  (isDarkMode
                                      ? Colors.white
                                      : Colors.black87),
                        ),
                      ),

                      TextButton(
                        onPressed: () => Get.to(
                          () => TransactionsView(),
                        ),
                        child: const Text('View All'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Obx(() {
                    final list =
                        transactionsController.transactions;

                    if (list.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 40.0,
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 48,
                              color: isDarkMode
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade400,
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'No recent transactions found.',
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final recentItems =
                        list.take(5).toList();

                    return ListView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount: recentItems.length,
                      itemBuilder: (context, index) {
                        final TransactionModel transaction =
                            recentItems[index];

                        final bool isIncome =
                            transaction.isIncome;

                        final String categoryName =
                            _getCategoryName(
                          transaction.categoryId,
                        );

                        final String displayTitle =
                            transaction.title.trim().isEmpty
                                ? categoryName
                                : transaction.title;

                        return Card(
                          elevation: 0,
                          color: theme.cardColor,
                          margin:
                              const EdgeInsets.symmetric(
                            vertical: 6.0,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 6.0,
                            ),
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 2,
                              ),

                              leading: CircleAvatar(
                                radius: 22,
                                backgroundColor: isIncome
                                    ? (isDarkMode
                                        ? const Color(
                                            0xFF1E382B)
                                        : const Color(
                                            0xFFEBF9EE))
                                    : (isDarkMode
                                        ? const Color(
                                            0xFF3B1E1E)
                                        : const Color(
                                            0xFFFDEEEE)),
                                child: Icon(
                                  isIncome
                                      ? Icons
                                          .arrow_downward_rounded
                                      : Icons
                                          .arrow_upward_rounded,
                                  color: isIncome
                                      ? const Color(
                                          0xFF4CAF50)
                                      : const Color(
                                          0xFFEB5757),
                                  size: 20,
                                ),
                              ),

                              title: Text(
                                displayTitle,
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize: 16,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),

                              subtitle: Padding(
                                padding:
                                    const EdgeInsets.only(
                                  top: 4.0,
                                ),
                                child: Text(
                                  "$categoryName • ${_getFormattedDate(transaction.date)}",
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),

                              trailing: Text(
                                "${isIncome ? '+' : '-'}PKR ${transaction.amount.toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: isIncome
                                      ? const Color(
                                          0xFF4CAF50)
                                      : const Color(
                                          0xFFEB5757),
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // =========================
  // DRAWER OPTION WIDGET
  // =========================
  Widget _buildDrawerOption({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDarkMode =
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
                                  0xFF212121),
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDarkMode
                              ? Colors.grey.shade400
                              : const Color(
                                  0xFF757575),
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDarkMode
                      ? Colors.grey.shade500
                      : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}