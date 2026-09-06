import 'package:expense_mate/Feature/Budgets/bindings/budget_bindings.dart';
import 'package:expense_mate/Feature/Categories/controller/categories_controller.dart';
import 'package:expense_mate/Feature/Categories/views/cataogries_view.dart';
import 'package:expense_mate/Feature/bills_reminders/binding/bills_reminders_binding.dart';
import 'package:expense_mate/Feature/bills_reminders/view/bills_reminders_view.dart';
import 'package:expense_mate/Feature/expense/binding/epense_binding.dart';
import 'package:expense_mate/Feature/expense/view/add_expense_view.dart';
import 'package:expense_mate/Feature/settings/binding/settings_binding.dart';
import 'package:expense_mate/Feature/settings/view/settings_view.dart';
import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';
import 'package:expense_mate/Feature/transactions/view/transcatio_screen.dart';
import 'package:expense_mate/Feature/more/view/more_view.dart';
import 'package:expense_mate/Feature/wallets/binding/wallets_binding.dart';
import 'package:expense_mate/Feature/wallets/view/wallets_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Budget view import
import 'package:expense_mate/Feature/Budgets/view/budget_view.dart';

import '../controller/home_controller.dart';
import 'home_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

 void _showMoreMenu(BuildContext context, HomeController controller) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'More Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 16),

              _buildMoreOption(
                icon: Icons.account_balance_wallet_rounded,
                title: 'Wallets',
                subtitle: 'Manage your wallets and balances',
                onTap: () {
                  Navigator.pop(context);

                  Get.to(
                    () => const WalletsView(),
                    binding: WalletsBinding(),
                  );
                },
              ),

              const SizedBox(height: 10),

              _buildMoreOption(
                icon: Icons.notifications_active_rounded,
                title: 'Bills & Reminders',
                subtitle: 'Manage bills and payment reminders',
                onTap: () {
                  Navigator.pop(context);

                  Get.to(
                    () => const BillsRemindersView(),
                    binding: BillsRemindersBinding(),
                  );
                },
              ),

              const SizedBox(height: 10),

              _buildMoreOption(
                icon: Icons.pie_chart_rounded,
                title: 'Budget',
                subtitle: 'Manage & track your monthly limits',
                onTap: () {
                  Navigator.pop(context);

                  Get.to(
                    () => const BudgetView(),
                    binding: BudgetBinding(),
                  );
                },
              ),

              const SizedBox(height: 10),

              _buildMoreOption(
                icon: Icons.settings_rounded,
                title: 'Settings',
                subtitle: 'Manage app preferences',
                onTap: () {
                  Navigator.pop(context);

                  Get.to(
                    () => const SettingsView(),
                    binding: SettingsBinding(),
                  );
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    },
  );
}
Widget _buildMoreOption({
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  final theme = Theme.of(Get.context!);
  final colorScheme = theme.colorScheme;

  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.arrow_forward_ios_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 16,
          ),
        ],
      ),
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    Get.put(CategoriesController());
    Get.put(TransactionsController());

    final List<Widget> pages = [
      const HomeScreen(),
      const TransactionsView(),
      const CategoriesView(),
      const Center(child: Text("Reports Screen")),
      const MoreView(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        ),
      ),
      floatingActionButton: Obx(
        () => controller.currentIndex.value == 0
            ? SizedBox(
                width: 56,
                height: 56,
                child: FloatingActionButton(
                  onPressed: () {
                    Get.to(
                      () => const AddExpenseView(),
                      binding: ExpenseBinding(),
                    );
                  },
                  backgroundColor: const Color(0xFF2B82FB),
                  elevation: 4,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              )
            : const SizedBox.shrink(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Obx(
          () => BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8.0,
           color: Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF1A1A1A)
    : const Color(0xFFEFF2E7),
            elevation: 0,
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(
                          icon: Icons.home_rounded,
                          label: 'Home',
                          index: 0,
                          controller: controller,
                          context: context,
                        ),
                        _buildNavItem(
                          icon: Icons.swap_horiz_rounded,
                          label: 'Transactions',
                          index: 1,
                          controller: controller,
                          context: context,
                        ),
                      ],
                    ),
                  ),
                  if (controller.currentIndex.value == 0)
                    const SizedBox(width: 48),
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(
                          icon: Icons.category_rounded,
                          label: 'Categories',
                          index: 2,
                          controller: controller,
                          context: context,
                        ),
                        _buildNavItem(
                          icon: Icons.bar_chart_rounded,
                          label: 'Reports',
                          index: 3,
                          controller: controller,
                          context: context,
                        ),
                        _buildNavItem(
                          icon: Icons.grid_view_rounded,
                          label: 'More',
                          index: 4,
                          controller: controller,
                          context: context,
                          isMoreTab: true,
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
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required HomeController controller,
    required BuildContext context,
    bool isMoreTab = false,
  }) {
    final isSelected = controller.currentIndex.value == index;
   final colorScheme = Theme.of(context).colorScheme;

final activeColor = colorScheme.primary;
final inactiveColor = colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: () {
        if (isMoreTab) {
          _showMoreMenu(context, controller);
        } else {
          controller.changePage(index);
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? activeColor : inactiveColor,
            size: 20,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}