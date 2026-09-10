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
import 'package:expense_mate/Feature/reports/controller/report_controller.dart';
import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';
import 'package:expense_mate/Feature/transactions/model/transcation_model.dart';
import 'package:expense_mate/Feature/transactions/view/transcatio_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String get _userName {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final nameFromMetaData = user.userMetadata?['full_name'] ?? user.userMetadata?['name'];
      if (nameFromMetaData != null && nameFromMetaData.toString().isNotEmpty) {
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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[date.month - 1];
    final day = date.day.toString().padLeft(2, '0');
    return "$month $day, ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final reportController = Get.find<ReportController>();
    final transactionsController = Get.find<TransactionsController>();

    // Dynamic Theme Context (Dark Mode Fix)
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      // ✅ Dynamic Background
      backgroundColor: theme.scaffoldBackgroundColor,

      endDrawer: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 16, bottom: 20, right: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Drawer(
              backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF6F7F2),
              child: Column(
                children: [
                  UserAccountsDrawerHeader(
                    margin: EdgeInsets.zero,
                    decoration: const BoxDecoration(color: Color(0xFF4CAF50)),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                    accountName: Text(
                      _userName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    accountEmail: Text(
                      Supabase.instance.client.auth.currentUser?.email ?? '',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      children: [
                        _buildDrawerOption(
                          context: context,
                          icon: Icons.account_balance_wallet_rounded,
                          title: 'Wallets',
                          subtitle: 'Manage your cash, bank and other wallets',
                          onTap: () {
                            Get.back();
                            Get.to(() => const WalletsView(), binding: WalletsBinding());
                          },
                        ),
                        const SizedBox(height: 10),
                        _buildDrawerOption(
                          context: context,
                          icon: Icons.pie_chart_rounded,
                          title: 'Budgets',
                          subtitle: 'Set and track monthly spending limits',
                          onTap: () {
                            Get.back();
                            Get.to(() => const BudgetView(), binding: BudgetBinding());
                          },
                        ),
                        const SizedBox(height: 10),
                        _buildDrawerOption(
                          context: context,
                          icon: Icons.stars_rounded,
                          title: 'Goals',
                          subtitle: 'Track your financial targets and savings',
                          onTap: () {
                            Get.back();
                            Get.to(() => const GoalsView(), binding: GoalsBinding());
                          },
                        ),
                      
                        const SizedBox(height: 10),
                        _buildDrawerOption(
                          context: context,
                          icon: Icons.notifications_active_rounded,
                          title: 'Bills & Reminders',
                          subtitle: 'Manage upcoming bills and reminders',
                          onTap: () {
                            Get.back();
                            Get.to(() => const BillsRemindersView(), binding: BillsRemindersBinding());
                          },
                        ),
                        const SizedBox(height: 10),
                        _buildDrawerOption(
                          context: context,
                          icon: Icons.settings_rounded,
                          title: 'Settings',
                          subtitle: 'Manage app preferences and settings',
                          onTap: () {
                            Get.back();
                            Get.to(() => const SettingsView(), binding: SettingsBinding());
                          },
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ✅ Dynamic Header Text
                          Text(
                            'Hello, $_userName 👋',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.titleLarge?.color ?? (isDarkMode ? Colors.white : Colors.black87),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Welcome back to Expense Mate',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.menu, 
                          size: 28, 
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Obx(
                    () => BalanceCard(
                      totalBalance: reportController.totalBalance,
                      totalIncome: reportController.totalIncome,
                      totalExpense: reportController.totalExpense,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleMedium?.color ?? (isDarkMode ? Colors.white : Colors.black87),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.to(() => const TransactionsView()),
                        child: const Text('View All'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Obx(() {
                    final list = transactionsController.transactions;

                    if (list.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 48,
                              color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No recent transactions found.',
                              style: TextStyle(
                                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final recentItems = list.take(5).toList();

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentItems.length,
                      itemBuilder: (context, index) {
                        final TransactionModel transaction = recentItems[index];
                        final bool isIncome = transaction.isIncome;

                        final String displayTitle = transaction.title.trim().isEmpty
                            ? transaction.category
                            : transaction.title;

                        return Card(
                          elevation: 0,
                          // ✅ Dynamic Card Background
                          color: theme.cardColor,
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 2,
                              ),
                              leading: CircleAvatar(
                                radius: 22,
                                backgroundColor: isIncome
                                    ? (isDarkMode ? const Color(0xFF1E382B) : const Color(0xFFEBF9EE))
                                    : (isDarkMode ? const Color(0xFF3B1E1E) : const Color(0xFFFDEEEE)),
                                child: Icon(
                                  isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                  color: isIncome ? const Color(0xFF4CAF50) : const Color(0xFFEB5757),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                displayTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  "${transaction.category} • ${_getFormattedDate(transaction.date)}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              trailing: Text(
                                "${isIncome ? '+' : '-'}PKR ${transaction.amount.toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: isIncome ? const Color(0xFF4CAF50) : const Color(0xFFEB5757),
                                  fontWeight: FontWeight.bold,
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

  Widget _buildDrawerOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: theme.cardColor,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF2B82FB).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:  Icon(
                  icon,
                  color: Color(0xFF2B82FB),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : const Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDarkMode ? Colors.grey.shade400 : const Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: isDarkMode ? Colors.grey.shade400 : const Color(0xFF757575),
              ),
            ],
          ),
        ),
      ),
    );
  }
}