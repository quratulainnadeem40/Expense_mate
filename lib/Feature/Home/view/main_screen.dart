import 'package:expense_mate/Feature/Categories/views/cataogries_view.dart';
import 'package:expense_mate/Feature/transactions/view/transcatio_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';
import 'home_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Controller ko yahan safely put karein taaki HomeScreen ko mil sake
    final HomeController controller = Get.put(HomeController());

    final List<Widget> pages = [
      const HomeScreen(),
      const TransactionsView(),
      const CategoriesView(),
      const Center(child: Text("More Page")),
    ];

    return Scaffold(
      body: Obx(() => pages[controller.currentIndex.value]),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add transaction logic here
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: Obx(
        () => BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.home, color: controller.currentIndex.value == 0 ? Colors.blue : Colors.grey),
                    const Text('Home', style: TextStyle(fontSize: 10)),
                  ],
                ),
                onPressed: () => controller.changePage(0),
              ),
              IconButton(
                icon: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.swap_horiz, color: controller.currentIndex.value == 1 ? Colors.blue : Colors.grey),
                    const Text('Transactions', style: TextStyle(fontSize: 10)),
                  ],
                ),
                onPressed: () => controller.changePage(1),
              ),
              const SizedBox(width: 40),
              IconButton(
                icon: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bar_chart, color: controller.currentIndex.value == 2 ? Colors.blue : Colors.grey),
                    const Text('Reports', style: TextStyle(fontSize: 10)),
                  ],
                ),
                onPressed: () => controller.changePage(2),
              ),
              IconButton(
                icon: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_outline, color: controller.currentIndex.value == 3 ? Colors.blue : Colors.grey),
                    const Text('More', style: TextStyle(fontSize: 10)),
                  ],
                ),
                onPressed: () => controller.changePage(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}