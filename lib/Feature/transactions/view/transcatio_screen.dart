import 'package:expense_mate/Feature/Budgets/bindings/budget_bindings.dart';
import 'package:expense_mate/Feature/Budgets/view/budget_view.dart';
import 'package:expense_mate/Feature/Categories/controller/categories_controller.dart';
import 'package:expense_mate/Feature/goals/binding/goals_binding.dart';
import 'package:expense_mate/Feature/goals/view/goals_view.dart';
import 'package:expense_mate/Feature/bills_reminders/binding/bills_reminders_binding.dart';
import 'package:expense_mate/Feature/bills_reminders/view/bills_reminders_view.dart';
import 'package:expense_mate/Feature/settings/binding/settings_binding.dart';
import 'package:expense_mate/Feature/settings/view/settings_view.dart';
import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';
import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';
import 'package:expense_mate/Feature/wallets/binding/wallets_binding.dart';
import 'package:expense_mate/Feature/wallets/view/wallets_view.dart';
import 'package:expense_mate/Feature/expense/binding/epense_binding.dart';
import 'package:expense_mate/Feature/expense/view/add_expense_view.dart';

// Home Controller
import 'package:expense_mate/Feature/Home/controller/home_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Feature Controllers & Models

class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView>
    with WidgetsBindingObserver {
  final RxBool isDrawerOpen = false.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      isDrawerOpen.value = false;
    }
  }

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

  String _getCategoryName(String categoryId) {
    if (!Get.isRegistered<CategoriesController>()) {
      return categoryId;
    }

    final categoriesController = Get.find<CategoriesController>();

    final category = categoriesController.categoryList.firstWhereOrNull(
      (cat) => cat.id == categoryId,
    );

    return category?.name ?? categoryId;
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

    return "${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}";
  }

  void _closeDrawerAndNavigate(
    Widget Function() page, {
    Bindings? binding,
  }) {
    isDrawerOpen.value = false;

    Future.delayed(const Duration(milliseconds: 150), () {
      Get.to(page, binding: binding);
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionsController = Get.find<TransactionsController>();
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        if (isDrawerOpen.value) {
          isDrawerOpen.value = false;
          return false;
        }

        return true;
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          // BACK BUTTON
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: isDarkMode ? Colors.white : Colors.black87,
              size: 28,
            ),
            onPressed: () {
              final homeController = Get.find<HomeController>();
              homeController.changePage(0);
            },
          ),

          title: Text(
            'Transactions',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),

          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,

          actions: [
            Obx(
              () => IconButton(
                icon: Icon(
                  isSearching.value
                      ? Icons.close_rounded
                      : Icons.search_rounded,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                onPressed: () {
                  if (isSearching.value) {
                    isSearching.value = false;
                    searchQuery.value = '';
                    _searchController.clear();
                  } else {
                    isSearching.value = true;
                  }
                },
              ),
            ),
          ],
        ),

        body: Stack(
          children: [
            // Main Transactions Screen Content
            Column(
              children: [
                // 1. Income & Expense Summary Card
                Obx(() {
                  final list = transactionsController.transactions;

                  double totalIncome = list
                      .where((tx) => tx.isIncome == true)
                      .fold(
                        0.0,
                        (sum, tx) => sum + tx.amount,
                      );

                  double totalExpense = list
                      .where((tx) => tx.isIncome == false)
                      .fold(
                        0.0,
                        (sum, tx) => sum + tx.amount,
                      );

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF1E1E1E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            isDarkMode ? 0.3 : 0.05,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Income',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'PKR ${totalIncome.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          height: 35,
                          width: 1,
                          color: isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                        ),

                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Expense',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'PKR ${totalExpense.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFEB5757),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // 2. Transaction History List
                Expanded(
                  child: Obx(() {
                    final query = searchQuery.value.toLowerCase();

                    final list =
                        transactionsController.transactions.where((tx) {
                      if (query.isEmpty) return true;

                      final categoryName =
                          _getCategoryName(tx.categoryId).toLowerCase();

                      final title = tx.title.toLowerCase();

                      return title.contains(query) ||
                          categoryName.contains(query);
                    }).toList();

                    if (list.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                              'No transactions found.',
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

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final TransactionModel transaction = list[index];

                        final bool isIncome = transaction.isIncome;

                        final String categoryName =
                            _getCategoryName(transaction.categoryId);

                        final String displayTitle =
                            transaction.title.trim().isEmpty
                                ? categoryName
                                : transaction.title;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF1E1E1E)
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
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            leading: CircleAvatar(
                              radius: 22,
                              backgroundColor: isIncome
                                  ? (isDarkMode
                                      ? const Color(0xFF1E382B)
                                      : const Color(0xFFEBF9EE))
                                  : (isDarkMode
                                      ? const Color(0xFF3B1E1E)
                                      : const Color(0xFFFDEEEE)),
                              child: Icon(
                                isIncome
                                    ? Icons.arrow_downward_rounded
                                    : Icons.arrow_upward_rounded,
                                color: isIncome
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFEB5757),
                                size: 20,
                              ),
                            ),
                            title: Text(
                              displayTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                "$categoryName • ${_getFormattedDate(transaction.date)}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            trailing: Text(
                              "${isIncome ? '+' : '-'}PKR ${transaction.amount.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: isIncome
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFEB5757),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),

            // Custom Floating Drawer Overlay
            Obx(() {
              if (!isDrawerOpen.value) {
                return const SizedBox.shrink();
              }

              return Stack(
                children: [
                  GestureDetector(
                    onTap: () => isDrawerOpen.value = false,
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.78,
                      height: MediaQuery.of(context).size.height * 0.76,
                      margin: const EdgeInsets.only(
                        left: 12,
                        top: 10,
                        bottom: 80,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF1E1E1E)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Column(
                          children: [
                            UserAccountsDrawerHeader(
                              margin: EdgeInsets.zero,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
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
                                      color: Color(0xFF4CAF50),
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
                                Supabase.instance.client.auth.currentUser
                                        ?.email ??
                                    '',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ),

                            Expanded(
                              child: ListView(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                physics: const BouncingScrollPhysics(),
                                children: [
                                  _buildDrawerOption(
                                    context: context,
                                    icon:
                                        Icons.account_balance_wallet_rounded,
                                    iconColor: const Color(0xFF2B82FB),
                                    title: 'Wallets',
                                    subtitle:
                                        'Manage your cash, bank and other...',
                                    onTap: () => _closeDrawerAndNavigate(
                                      () => const WalletsView(),
                                      binding: WalletsBinding(),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  _buildDrawerOption(
                                    context: context,
                                    icon: Icons.pie_chart_rounded,
                                    iconColor: const Color(0xFFFF9800),
                                    title: 'Budgets',
                                    subtitle:
                                        'Set and track monthly spen...',
                                    onTap: () => _closeDrawerAndNavigate(
                                      () => const BudgetView(),
                                      binding: BudgetBinding(),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  _buildDrawerOption(
                                    context: context,
                                    icon: Icons.stars_rounded,
                                    iconColor: const Color(0xFFE91E63),
                                    title: 'Goals',
                                    subtitle:
                                        'Track your financial targets...',
                                    onTap: () => _closeDrawerAndNavigate(
                                      () => const GoalsView(),
                                      binding: GoalsBinding(),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  _buildDrawerOption(
                                    context: context,
                                    icon:
                                        Icons.notifications_active_rounded,
                                    iconColor: const Color(0xFF9C27B0),
                                    title: 'Bills & Reminders',
                                    subtitle:
                                        'Manage upcoming bills an...',
                                    onTap: () => _closeDrawerAndNavigate(
                                      () => const BillsRemindersView(),
                                      binding: BillsRemindersBinding(),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  _buildDrawerOption(
                                    context: context,
                                    icon: Icons.person_rounded,
                                    iconColor: const Color(0xFF00BCD4),
                                    title: 'Profile',
                                    subtitle:
                                        'Manage your profile and acc...',
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
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    TransactionsController controller,
    TransactionModel transaction,
  ) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor:
            isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Delete Transaction',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this transaction?',
          style: TextStyle(
            color: isDarkMode
                ? Colors.grey.shade300
                : Colors.grey.shade700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();

              final success = await controller.deleteTransaction(
                transaction.id,
              );

              if (success) {
                Get.snackbar(
                  'Deleted',
                  'Transaction deleted successfully.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
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
                    borderRadius: BorderRadius.circular(12),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDarkMode
                              ? Colors.grey.shade400
                              : const Color(0xFF757575),
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

