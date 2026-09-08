import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/home_controller.dart';
import '../widgets/balance_card.dart';

// Settings Controller Import
import '../../settings/controller/settings_controller.dart';

// More options screens
import '../../wallets/view/wallets_view.dart';
import '../../wallets/binding/wallets_binding.dart';

import '../../bills_reminders/view/bills_reminders_view.dart';
import '../../bills_reminders/binding/bills_reminders_binding.dart';

import '../../Budgets/view/budget_view.dart';
import '../../Budgets/bindings/budget_bindings.dart';

import '../../goals/view/goals_view.dart';
import '../../goals/binding/goals_binding.dart';

import '../../settings/view/settings_view.dart';
import '../../settings/binding/settings_binding.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inject or Find SettingsController
    final settingsController = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : Get.put(SettingsController());

    return Scaffold(
      // =========================
      // APP BAR
      // =========================
      appBar: AppBar(
        title: const Text('Hello, Alex'),
        actions: [
          // 1. REFRESH BUTTON
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => controller.loadDashboardData(),
          ),

          // 2. MORE OPTIONS BUTTON (Opens Sheet Over BottomNav & FAB)
          IconButton(
            icon: const Icon(Icons.menu_rounded),
            tooltip: 'More Options',
            onPressed: () => _showMoreSheet(context),
          ),
        ],
      ),

      // =========================
      // BODY
      // =========================
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BalanceCard(
              totalBalance: controller.totalBalance,
              totalIncome: controller.totalIncome,
              totalExpense: controller.totalExpense,
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                TextButton(
                  onPressed: () {
                    Get.find<HomeController>().changePage(1);
                  },
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Expanded(
              child: Obx(() {
                if (controller.recentTransactions.isEmpty) {
                  return const Center(
                    child: Text('No transactions yet.'),
                  );
                }

                return ListView.builder(
                  itemCount: controller.recentTransactions.length,
                  itemBuilder: (context, index) {
                    final tx = controller.recentTransactions[index];
                    final isIncome = tx['type'] == 'Income';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          isIncome
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: isIncome ? Colors.green : Colors.red,
                        ),
                        title: Text(tx['title'] ?? 'Transaction'),
                        subtitle: Text(tx['category'] ?? 'General'),
                        trailing: Obx(
                          () => Text(
                            '${isIncome ? '+' : '-'}${settingsController.selectedCurrency.value} ${(tx['amount'] ?? 0.0).toStringAsFixed(2)}',
                            style: TextStyle(
                              color: isIncome ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
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
      ),
    );
  }

  // ============================================================
  // MORE OPTIONS SHEET (Fixes Bottom Bar & FAB Overlap)
  // ============================================================

  void _showMoreSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true, // Bottom Bar & FAB ke UPAR show karega
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (bottomSheetContext) {
        return Container(
          height: MediaQuery.of(bottomSheetContext).size.height * 0.75,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.grid_view_rounded,
                      color: colorScheme.primary,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'More Options',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(bottomSheetContext),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Items List
              Expanded(
                child: ListView(
                  children: [
                    _buildDrawerItem(
                      bottomSheetContext,
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'Wallets',
                      subtitle: 'Manage your wallets and balances',
                      onTap: () {
                        Navigator.pop(bottomSheetContext);
                        Get.to(() => const WalletsView(), binding: WalletsBinding());
                      },
                    ),
                    _buildDrawerItem(
                      bottomSheetContext,
                      icon: Icons.notifications_active_rounded,
                      title: 'Bills & Reminders',
                      subtitle: 'Manage bills and payment reminders',
                      onTap: () {
                        Navigator.pop(bottomSheetContext);
                        Get.to(() => const BillsRemindersView(), binding: BillsRemindersBinding());
                      },
                    ),
                    _buildDrawerItem(
                      bottomSheetContext,
                      icon: Icons.pie_chart_rounded,
                      title: 'Budget',
                      subtitle: 'Manage & track your monthly limits',
                      onTap: () {
                        Navigator.pop(bottomSheetContext);
                        Get.to(() => const BudgetView(), binding: BudgetBinding());
                      },
                    ),
                    _buildDrawerItem(
                      bottomSheetContext,
                      icon: Icons.track_changes_rounded,
                      title: 'Goals',
                      subtitle: 'Track and manage your savings goals',
                      onTap: () {
                        Navigator.pop(bottomSheetContext);
                        Get.to(() => const GoalsView(), binding: GoalsBinding());
                      },
                    ),
                    _buildDrawerItem(
                      bottomSheetContext,
                      icon: Icons.settings_rounded,
                      title: 'Settings',
                      subtitle: 'Manage app preferences',
                      onTap: () {
                        Navigator.pop(bottomSheetContext);
                        Get.to(() => const SettingsView(), binding: SettingsBinding());
                      },
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Expense Mate',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // ITEM WIDGET
  // ============================================================

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
        ),
      ),
    );
  }
}