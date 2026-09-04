import 'package:expense_mate/Feature/Categories/controller/categories_controller.dart';
import 'package:expense_mate/Feature/Categories/views/cataogries_view.dart';
import 'package:expense_mate/Feature/expense/binding/epense_binding.dart';
import 'package:expense_mate/Feature/expense/view/add_expense_view.dart';
import 'package:expense_mate/Feature/transactions/controller/transcation_controller.dart';
import 'package:expense_mate/Feature/transactions/view/transcatio_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';
import 'home_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Required Controllers Initialization
    final HomeController controller = Get.put(HomeController());
    Get.put(CategoriesController());
    Get.put(TransactionsController());

    // Complete 5 pages list
    final List<Widget> pages = [
      const HomeScreen(),                      // Index 0
      const TransactionsView(),                // Index 1
      const CategoriesView(),                  // Index 2
      const Center(child: Text("Reports Screen")), // Index 3
      const Center(child: Text("More Screen")), // Index 4
    ];

    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: pages,
          )),

      // Floating Add Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(
            () => const AddExpenseView(),
            binding: ExpenseBinding(),
          );
        },
        backgroundColor: Colors.blue,
        elevation: 4.0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Navigation Bar with 5 Navigation Destinations
      bottomNavigationBar: Obx(
        () => BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 6.0,
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Left Side Items
                _buildNavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                  controller: controller,
                ),
                _buildNavItem(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Transactions',
                  index: 1,
                  controller: controller,
                ),

                // FAB Gap Space
                const SizedBox(width: 20),

                // Right Side Items
                _buildNavItem(
                  icon: Icons.category_rounded,
                  label: 'Categories',
                  index: 2,
                  controller: controller,
                ),
                _buildNavItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Reports',
                  index: 3,
                  controller: controller,
                ),
                _buildNavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'More',
                  index: 4,
                  controller: controller,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Navigation Item Widget
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required HomeController controller,
  }) {
    final isSelected = controller.currentIndex.value == index;
    final color = isSelected ? Colors.blue : Colors.grey.shade600;

    return InkWell(
      onTap: () => controller.changePage(index),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}