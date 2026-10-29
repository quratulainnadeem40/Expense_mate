import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:expense_mate/core/routes/app_routes.dart';
import 'package:expense_mate/Feature/settings/controller/settings_controller.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    final settingsController =
        Get.find<SettingsController>();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // PROFILE HEADER
            // ==================================================

            Obx(() {
              final imageUrl =
                  settingsController.profilePictureUrl.value;

              final name =
                  settingsController.profileName.value;

              final email =
                  settingsController.profileEmail.value;

              // First letter for fallback avatar
              final firstLetter = name.isNotEmpty
                  ? name[0].toUpperCase()
                  : 'U';

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  18,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF1B5E20)
                      : const Color(0xFF2E7D32),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.center,
                  children: [
                    // ------------------------------------------
                    // PROFILE PICTURE
                    // ------------------------------------------

                    CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl)
                              : null,
                      child: imageUrl.isEmpty
                          ? Text(
                              firstLetter,
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            )
                          : null,
                    ),

                    const SizedBox(width: 16),

                    // ------------------------------------------
                    // NAME + EMAIL
                    // ------------------------------------------

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.isNotEmpty
                                ? name
                                : 'User',
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            email.isNotEmpty
                                ? email
                                : 'No Email',
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            // ==================================================
            // APP TITLE + CLOSE BUTTON
            // ==================================================

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

            // ==================================================
            // WALLETS
            // ==================================================

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

            // ==================================================
            // BUDGETS
            // ==================================================

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

            // ==================================================
            // GOALS
            // ==================================================

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

            // ==================================================
            // BILLS & REMINDERS
            // ==================================================

            ListTile(
              leading: const Icon(
                Icons.notifications_none,
              ),
              title: const Text('Bills & Reminders'),
              onTap: () {
                Get.back();
                Get.toNamed(
                  AppRoutes.billsReminders,
                );
              },
            ),

            // ==================================================
            // SETTINGS
            // ==================================================
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