import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:expense_mate/core/routes/app_routes.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            SizedBox(
              height: 60,
              width: double.infinity,
              child: Stack(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Expense Mate',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // X button - Top Right
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: Icon(
                        Icons.close,
                        size: 28,
                        color: isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Wallets
            ListTile(
              leading: const Icon(
                Icons.account_balance_wallet_outlined,
              ),
              title: const Text('Wallets'),
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.wallets);
              },
            ),

            // Budgets
            ListTile(
              leading: const Icon(
                Icons.account_balance_outlined,
              ),
              title: const Text('Budgets'),
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.budget);
              },
            ),

            // Goals
            ListTile(
              leading: const Icon(
                Icons.flag_outlined,
              ),
              title: const Text('Goals'),
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.goals);
              },
            ),

            // Bills & Reminders
            ListTile(
              leading: const Icon(
                Icons.notifications_none,
              ),
              title: const Text('Bills & Reminders'),
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.billsReminders);
              },
            ),

            // Settings
            ListTile(
              leading: const Icon(
                Icons.settings_outlined,
              ),
              title: const Text('Settings'),
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.settings);
              },
            ),
          ],
        ),
      ),
    );
  }
}
