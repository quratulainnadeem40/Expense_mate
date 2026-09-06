import 'package:expense_mate/Core/theme/custom_colors.dart';
import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../controller/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTextStyles.headingMedium(isDark),
        ),
      ),

      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ==================================================
            // APPEARANCE
            // ==================================================

            _SectionHeader(
              title: 'Appearance',
              isDark: isDark,
            ),

            const SizedBox(height: 10),

            _SettingsCard(
              children: [
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  secondary: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      controller.isDarkMode.value
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    'Dark Mode',
                    style: AppTextStyles.bodyLarge(isDark).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    controller.isDarkMode.value
                        ? 'Dark theme is enabled'
                        : 'Light theme is enabled',
                    style: AppTextStyles.bodyMedium(isDark),
                  ),
                  value: controller.isDarkMode.value,
                  onChanged: controller.toggleDarkMode,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ==================================================
            // CURRENCY
            // ==================================================

            _SectionHeader(
              title: 'Currency',
              isDark: isDark,
            ),

            const SizedBox(height: 10),

            _SettingsCard(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),

                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.currency_exchange_rounded,
                      color: AppColors.primary,
                    ),
                  ),

                  title: Text(
                    'Default Currency',
                    style: AppTextStyles.bodyLarge(isDark).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  subtitle: Text(
                    'Choose the currency used by the app',
                    style: AppTextStyles.bodyMedium(isDark),
                  ),

                  trailing: DropdownButton<String>(
                    value: controller.selectedCurrency.value,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: 'PKR',
                        child: Text('PKR'),
                      ),
                      DropdownMenuItem(
                        value: 'USD',
                        child: Text('USD'),
                      ),
                      DropdownMenuItem(
                        value: 'EUR',
                        child: Text('EUR'),
                      ),
                      DropdownMenuItem(
                        value: 'GBP',
                        child: Text('GBP'),
                    ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.changeCurrency(value);
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ==================================================
            // NOTIFICATIONS
            // ==================================================

            _SectionHeader(
              title: 'Notifications',
              isDark: isDark,
            ),

            const SizedBox(height: 10),

            _SettingsCard(
              children: [
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),

                  secondary: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_active_outlined,
                      color: AppColors.primary,
                    ),
                  ),

                  title: Text(
                    'Bill Notifications',
                    style: AppTextStyles.bodyLarge(isDark).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  subtitle: Text(
                    'Receive reminders for upcoming bills',
                    style: AppTextStyles.bodyMedium(isDark),
                  ),

                  value: controller.notificationsEnabled.value,

                  onChanged:
                      controller.toggleNotifications,
                ),
              ],
            ),

            const SizedBox(height: 24),

const SizedBox(height: 24),

// ==================================================
// ACCOUNT
// ==================================================

_SectionHeader(
  title: 'Account',
  isDark: isDark,
),

const SizedBox(height: 10),

_SettingsCard(
  children: [
    // LOGOUT
    ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),

      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(
            alpha: 0.10,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      child: const Icon(
          Icons.logout_rounded,
          color: AppColors.primary,
        ),
      ),

      title: Text(
        'Logout',
        style: AppTextStyles.bodyLarge(isDark).copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),

      subtitle: Text(
        'Sign out from your ExpenseMate account',
        style: AppTextStyles.bodyMedium(isDark),
      ),

      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
      ),

      onTap: () {
        _showLogoutDialog(context);
      },
    ),

    const Divider(height: 1),

    // DELETE ACCOUNT
    ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),

      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.expenseRed.withValues(
            alpha: 0.10,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_forever_rounded,
          color: AppColors.expenseRed,
        ),
      ),

      title: Text(
        'Delete Account',
        style: AppTextStyles.bodyLarge(isDark).copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.expenseRed,
        ),
      ),

      subtitle: Text(
        'Permanently delete your account and data',
        style: AppTextStyles.bodyMedium(isDark),
      ),

      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
      ),

      onTap: () {
        _showDeleteAccountDialog(context);
      },
    ),
  ],
),
            // ==================================================
            // DATA
            // ==================================================

            _SectionHeader(
              title: 'Data',
              isDark: isDark,
            ),

            const SizedBox(height: 10),

            _SettingsCard(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),

                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.expenseRed.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.restart_alt_rounded,
                      color: AppColors.expenseRed,
                    ),
                  ),

                  title: Text(
                    'Reset Settings',
                    style: AppTextStyles.bodyLarge(isDark).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  subtitle: Text(
                    'Restore settings to their defaults',
                    style: AppTextStyles.bodyMedium(isDark),
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),

                  onTap: () {
                    _showResetDialog(context);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ==================================================
            // ABOUT
            // ==================================================

            _SectionHeader(
              title: 'About',
              isDark: isDark,
            ),

            const SizedBox(height: 10),

            _SettingsCard(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),

                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.primary,
                    ),
                  ),

                  title: Text(
                    'ExpenseMate',
                    style: AppTextStyles.bodyLarge(isDark).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  subtitle: Text(
                    'Expense management made simple',
                    style: AppTextStyles.bodyMedium(isDark),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Center(
              child: Text(
                'ExpenseMate',
                style: AppTextStyles.caption(isDark),
              ),
            ),

            const SizedBox(height: 4),

            Center(
              child: Text(
                'Version 1.0.0',
                style: AppTextStyles.caption(isDark),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // RESET SETTINGS DIALOG
  // ============================================================

  void _showResetDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Reset Settings?'),

        content: const Text(
          'This will restore your app settings to their default values. '
          'Your wallets, bills and transactions will not be deleted.',
        ),

        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Cancel'),
          ),

          TextButton(
            onPressed: () async {
              await controller.resetSettings();
              Get.back();

              Get.snackbar(
                'Settings Reset',
                'Your settings have been restored to default.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text(
              'Reset',
              style: TextStyle(
                color: AppColors.expenseRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LOGOUT DIALOG
// ============================================================

void _showLogoutDialog(BuildContext context) {
  Get.dialog(
    AlertDialog(
      title: const Text('Logout?'),

      content: const Text(
        'Are you sure you want to logout from your ExpenseMate account?',
      ),

      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('Cancel'),
        ),

        TextButton(
          onPressed: () async {
            Get.back();
           await Get.find<SettingsController>().logout();
          },
          child: const Text(
            'Logout',
            style: TextStyle(
              color: AppColors.expenseRed,
            ),
          ),
        ),
      ],
    ),
  );
}

// ============================================================
// DELETE ACCOUNT DIALOG
// ============================================================

void _showDeleteAccountDialog(BuildContext context) {
  Get.dialog(
    AlertDialog(
      title: const Text('Delete Account?'),

      content: const Text(
        'This action is permanent. Your ExpenseMate account '
        'and associated account data will be deleted. '
        'You will not be able to recover your account.',
      ),

      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('Cancel'),
        ),

        TextButton(
          onPressed: () async {
            Get.back();
            await Get.find<SettingsController>().deleteAccount();
          },
          child: const Text(
            'Delete Account',
            style: TextStyle(
              color: AppColors.expenseRed,
            ),
          ),
        ),
      ],
    ),
  );
}

// ============================================================
// SECTION HEADER
// ============================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({
    required this.title,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.headingMedium(isDark),
    );
  }
}

// ============================================================
// SETTINGS CARD
// ============================================================

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}