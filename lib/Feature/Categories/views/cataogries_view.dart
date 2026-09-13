import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoriesView extends StatelessWidget {
  CategoriesView({Key? key}) : super(key: key);

  // Example reactive variables (aap ise apne GetX Controller ke sath replace kar sakte hain)
  final RxBool isDark = false.obs;
  final RxBool isDrawerOpen = false.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: isDark.value 
              ? const Color(0xFF121212) 
              : const Color(0xFFF9F9F9),
          
          // 1. Corrected AppBar
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            leading: IconButton(
              icon: Icon(
                Icons.menu_rounded,
                color: isDark.value ? Colors.white : const Color(0xFF2E7D32),
                size: 28,
              ),
              onPressed: () {
                isDrawerOpen.value = true;
              },
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Categories',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: isDark.value ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Manage your expense categories',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark.value ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // 2. Body Content (Categories List)
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.fastfood, color: Color(0xFF2E7D32)),
                  ),
                  title: const Text('Food & Drinks'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
                // Aap yahan apni baqi categories ki list builder ya items add kar sakte hain
              ],
            ),
          ),

          // 3. Add Category Floating Action Button
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              // Yahan category add karne ka dialog ya screen open karne ka code likhein
              // Jaise: Get.defaultDialog(...);
            },
            icon: const Icon(Icons.add, size: 18, color: Colors.white),
            label: const Text(
              'Add Category',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        ));
  }
}