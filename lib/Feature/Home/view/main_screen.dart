import 'package:expense_mate/Feature/transactions/view/transcatio_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Categories
import 'package:expense_mate/Feature/Categories/controller/categories_controller.dart';
import 'package:expense_mate/Feature/Categories/views/cataogries_view.dart';

// Transactions
import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';

// Reports
import 'package:expense_mate/Feature/Reports/view/report_view.dart';

// Expense
import 'package:expense_mate/Feature/expense/binding/epense_binding.dart';
import 'package:expense_mate/Feature/expense/view/add_expense_view.dart';

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

    // Theme Colors
    const primaryGreen = Color(0xFF2EA44F);

    final List<Widget> pages = [
      const HomeScreen(),
      TransactionsView(),
       CategoriesView(),
      ReportsView(),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
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
      // FLOATING ACTION BUTTON (Center Notched)
      // ==========================================================

      floatingActionButton: SizedBox(
        width: 54,
        height: 54,
        child: FloatingActionButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            Get.to(
              () => const AddExpenseView(),
              binding: ExpenseBinding(),
            );
          },
          backgroundColor: primaryGreen,
          elevation: 3,
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
      // BOTTOM NAVIGATION BAR
      // ==========================================================

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        clipBehavior: Clip.antiAlias,
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 12,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              // =================================================
              // LEFT SIDE ITEMS
              // =================================================
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      index: 0,
                      controller: controller,
                      context: context,
                      activeColor: primaryGreen,
                    ),
                    _buildNavItem(
                      icon: Icons.swap_horiz_rounded,
                      label: 'Transactions',
                      index: 1,
                      controller: controller,
                      context: context,
                      activeColor: primaryGreen,
                    ),
                  ],
                ),
              ),

              // Notch Gap Space for FAB
              const SizedBox(width: 52),

              // =================================================
              // RIGHT SIDE ITEMS
              // =================================================
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      icon: Icons.category_rounded,
                      label: 'Categories',
                      index: 2,
                      controller: controller,
                      context: context,
                      activeColor: primaryGreen,
                    ),
                    _buildNavItem(
                      icon: Icons.bar_chart_rounded,
                      label: 'Reports',
                      index: 3,
                      controller: controller,
                      context: context,
                      activeColor: primaryGreen,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // BOTTOM NAVIGATION ITEM WIDGET (WITH HIGHLIGHT CARD)
  // ==============================================================

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required HomeController controller,
    required BuildContext context,
    required Color activeColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark ? Colors.grey[500] : const Color(0xFF757575);

    return Obx(() {
      final isSelected = controller.currentIndex.value == index;

      return InkWell(
        onTap: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          controller.changePage(index);
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark
                        ? activeColor.withOpacity(0.2)
                        : activeColor.withOpacity(0.12))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isSelected ? activeColor : inactiveColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      );
    });
  }
}