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

// Import your Budget Screen here
// import 'package:expense_mate/Feature/budget/view/budget_view.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  void _showMoreMenu(BuildContext context, HomeController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'More Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 16),
              
              // Budget Container Option
              InkWell(
                onTap: () {
                  Navigator.pop(context); // Menu dismiss karega
                  
                  // Temporary placeholder navigation (Budget View replace karein)
                  Get.to(
                    () => Scaffold(
                      appBar: AppBar(title: const Text("Budget")),
                      body: const Center(child: Text("Budget Screen")),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F7F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B82FB).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Color(0xFF2B82FB),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Budget',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1E1E),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Manage & track your monthly limits',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF555B51),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color(0xFF555B51),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
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
      const Center(child: Text("More Screen")),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F2),

      // Screen body
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        ),
      ),

      // Integrated Floating Action Button
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

      // Curved Bottom Navigation Bar with Center Cutout Notch
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Obx(
          () => BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8.0,
            color: const Color(0xFFEFF2E7),
            elevation: 0,
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  // Left Side Tabs
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

                  // Notch Space for Floating Button (Home Screen dynamic check)
                  if (controller.currentIndex.value == 0)
                    const SizedBox(width: 48),

                  // Right Side Tabs
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
    final activeColor = const Color(0xFF2B82FB);
    final inactiveColor = const Color(0xFF555B51);

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