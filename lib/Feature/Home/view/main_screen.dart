import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Categories
import 'package:expense_mate/Feature/Categories/controller/categories_controller.dart';
import 'package:expense_mate/Feature/Categories/views/cataogries_view.dart';

// Transactions
import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';
import 'package:expense_mate/Feature/transactions/view/transcatio_screen.dart';

// Reports
import 'package:expense_mate/Feature/Reports/view/report_view.dart';

// Expense
import 'package:expense_mate/Feature/expense/binding/epense_binding.dart';
import 'package:expense_mate/Feature/expense/view/add_expense_view.dart';

// Wallets
import 'package:expense_mate/Feature/wallets/binding/wallets_binding.dart';
import 'package:expense_mate/Feature/wallets/view/wallets_view.dart';

// Bills & Reminders
import 'package:expense_mate/Feature/bills_reminders/binding/bills_reminders_binding.dart';
import 'package:expense_mate/Feature/bills_reminders/view/bills_reminders_view.dart';

// Budget
import 'package:expense_mate/Feature/Budgets/bindings/budget_bindings.dart';
import 'package:expense_mate/Feature/Budgets/view/budget_view.dart';

// Home
import '../controller/home_controller.dart';
import 'home_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    Get.put(CategoriesController());
    Get.put(TransactionsController());

    // ============================================================
    // MAIN PAGES
    // ============================================================

    final List<Widget> pages = [
      const HomeScreen(),
      const TransactionsView(),
      const CategoriesView(),
      const ReportsView(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      // ==========================================================
      // MAIN BODY
      // ==========================================================

      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        ),
      ),

      // ==========================================================
      // FLOATING ACTION BUTTON (Always Visible)
      // ==========================================================

      floatingActionButton: SizedBox(
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
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,

      // ==========================================================
      // BOTTOM NAVIGATION (Always Cutout Notched)
      // ==========================================================

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
                  // =================================================
                  // LEFT SIDE
                  // =================================================

                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                      children: [
                        // HOME
                        _buildNavItem(
                          icon: Icons.home_rounded,
                          label: 'Home',
                          index: 0,
                          controller: controller,
                          context: context,
                        ),

                        // TRANSACTIONS
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

                  // Fixed Space for Floating Action Button Notch
                  const SizedBox(width: 48),

                  // =================================================
                  // RIGHT SIDE
                  // =================================================

                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                      children: [
                        // CATEGORIES
                        _buildNavItem(
                          icon: Icons.category_rounded,
                          label: 'Categories',
                          index: 2,
                          controller: controller,
                          context: context,
                        ),

                        // REPORTS
                        _buildNavItem(
                          icon: Icons.bar_chart_rounded,
                          label: 'Reports',
                          index: 3,
                          controller: controller,
                          context: context,
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

  // ==============================================================
  // BOTTOM NAVIGATION ITEM
  // ==============================================================

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required HomeController controller,
    required BuildContext context,
  }) {
    final isSelected =
        controller.currentIndex.value == index;

    final colorScheme =
        Theme.of(context).colorScheme;

    final activeColor =
        colorScheme.primary;

    final inactiveColor =
        colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: () {
        controller.changePage(index);
      },

      borderRadius: BorderRadius.circular(10),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Icon(
            icon,
            color: isSelected
                ? activeColor
                : inactiveColor,
            size: 20,
          ),

          const SizedBox(height: 2),

          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isSelected
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: isSelected
                  ? activeColor
                  : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}