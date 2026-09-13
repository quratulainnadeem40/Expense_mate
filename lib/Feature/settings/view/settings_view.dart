
import 'package:expense_mate/Core/theme/custom_colors.dart';
import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
          'Profile',
          style: AppTextStyles.headingMedium(isDark).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),

      body: Obx(
        () => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
          children: [
            // =====================================================
            // PROFILE HEADER
            // =====================================================

            _buildProfileHeader(
              context,
              isDark,
            ),

            const SizedBox(height: 28),

            // =====================================================
            // APPEARANCE
            // =====================================================

            _SectionHeader(
              title: 'Appearance',
              isDark: isDark,
              icon: Icons.palette_outlined,
            ),

            const SizedBox(height: 10),

            _SettingsCard(
              isDark: isDark,
              children: [
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  secondary: _IconContainer(
                    icon: controller.isDarkMode.value
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    isDark: isDark,
                  ),
                  title: Text(
                    'Dark Mode',
                    style:
                        AppTextStyles.bodyLarge(isDark).copyWith(
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

            // =====================================================
            // CURRENCY
            // =====================================================

            _SectionHeader(
              title: 'Currency',
              isDark: isDark,
              icon: Icons.currency_exchange_rounded,
            ),

            const SizedBox(height: 10),

            _SettingsCard(
              isDark: isDark,
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: _IconContainer(
                    icon: Icons.currency_exchange_rounded,
                    isDark: isDark,
                  ),
                  title: Text(
                    'Default Currency',
                    style:
                        AppTextStyles.bodyLarge(isDark).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Choose the currency used by the app',
                    style: AppTextStyles.bodyMedium(isDark),
                  ),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedCurrency.value,
                      borderRadius: BorderRadius.circular(14),
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
                ),
              ],
            ),

            const SizedBox(height: 24),

            // =====================================================
            // NOTIFICATIONS
            // =====================================================

            _SectionHeader(
              title: 'Notifications',
              isDark: isDark,
              icon: Icons.notifications_outlined,
            ),

            const SizedBox(height: 10),

            _SettingsCard(
              isDark: isDark,
              children: [
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  secondary: _IconContainer(
                    icon: Icons.notifications_active_outlined,
                    isDark: isDark,
                  ),
                  title: Text(
                    'Bill Notifications',
                    style:
                        AppTextStyles.bodyLarge(isDark).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Receive reminders for upcoming bills',
                    style: AppTextStyles.bodyMedium(isDark),
                  ),
                  value:
                      controller.notificationsEnabled.value,
                  onChanged:
                      controller.toggleNotifications,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // =====================================================
            // ACCOUNT
            // =====================================================

            _SectionHeader(
              title: 'Account',
              isDark: isDark,
              icon: Icons.person_outline_rounded,
            ),

            const SizedBox(height: 10),

            _SettingsCard(
              isDark: isDark,
              children: [
                // LOGOUT
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: _IconContainer(
                    icon: Icons.logout_rounded,
                    isDark: isDark,
                  ),
                  title: Text(
                    'Logout',
                    style:
                        AppTextStyles.bodyLarge(isDark).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Sign out from your ExpenseMate account',
                    style: AppTextStyles.bodyMedium(isDark),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15,
                  ),
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                ),

                Divider(
                  height: 1,
                  indent: 74,
                  endIndent: 16,
                  color: isDark
                      ? Colors.white12
                      : Colors.black12,
                ),

                // DELETE ACCOUNT
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.expenseRed.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      color: AppColors.expenseRed,
                    ),
                  ),
                  title: Text(
                    'Delete Account',
                    style:
                        AppTextStyles.bodyLarge(isDark).copyWith(
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
                    size: 15,
                  ),
                  onTap: () {
                    _showDeleteAccountDialog(context);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // =====================================================
            // DATA
            // =====================================================

            _SectionHeader(
              title: 'Data',
              isDark: isDark,
              icon: Icons.storage_outlined,
            ),

            const SizedBox(height: 10),

            _SettingsCard(
              isDark: isDark,
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.expenseRed.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.restart_alt_rounded,
                      color: AppColors.expenseRed,
                    ),
                  ),
                  title: Text(
                    'Reset Settings',
                    style:
                        AppTextStyles.bodyLarge(isDark).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Restore settings to their defaults',
                    style: AppTextStyles.bodyMedium(isDark),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15,
                  ),
                  onTap: () {
                    _showResetDialog(context);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // =====================================================
            // ABOUT
            // =====================================================

            _SectionHeader(
              title: 'About',
              isDark: isDark,
              icon: Icons.info_outline_rounded,
            ),

            const SizedBox(height: 10),

            _SettingsCard(
              isDark: isDark,
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: _IconContainer(
                    icon: Icons.account_balance_wallet_rounded,
                    isDark: isDark,
                  ),
                  title: Text(
                    'ExpenseMate',
                    style:
                        AppTextStyles.bodyLarge(isDark).copyWith(
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

            // =====================================================
            // APP FOOTER
            // =====================================================

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

  // =============================================================
  // PROFILE HEADER
  // =============================================================

  Widget _buildProfileHeader(
    BuildContext context,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.12 : 0.05,
            ),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          // =======================================================
          // PROFILE PICTURE
          // =======================================================

          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(
                      alpha: 0.25,
                    ),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary,
                  backgroundImage:
                      controller.profilePictureUrl.value.isNotEmpty
                          ? NetworkImage(
                              controller.profilePictureUrl.value,
                            )
                          : null,
                  child:
                      controller.profilePictureUrl.value.isEmpty
                          ? Text(
                              controller.profileName.value.isNotEmpty
                                  ? controller.profileName.value[0]
                                      .toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 29,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                ),
              ),

              // CAMERA
              Positioned(
                right: -2,
                bottom: -2,
                child: Material(
                  color: AppColors.primary,
                  shape: const CircleBorder(),
                  elevation: 3,
                  child: InkWell(
                    onTap: controller.pickProfilePicture,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 31,
                      height: 31,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? AppColors.surfaceDark
                              : AppColors.surfaceLight,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 18),

          // =======================================================
          // NAME + EMAIL
          // =======================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        controller.profileName.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            AppTextStyles.headingMedium(isDark).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 5),

                    InkWell(
                      onTap: () {
                        _showEditNameDialog(context);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Icon(
                          Icons.edit_rounded,
                          size: 17,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  Supabase.instance.client.auth.currentUser?.email ??
                      controller.profileEmail.value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium(isDark),
                ),

                const SizedBox(height: 9),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ExpenseMate Account',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // EDIT NAME
  // =============================================================

  void _showEditNameDialog(BuildContext context) {
    final nameController = TextEditingController(
      text: controller.profileName.value,
    );

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'Enter your name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();

              if (name.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter your name.',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              Get.back();
              await controller.updateName(name);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // RESET SETTINGS
  // =============================================================

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
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),

        TextButton(
          onPressed: () async {
            // Close dialog first
            Get.back();

            // Give the dialog time to close
            await Future.delayed(
              const Duration(milliseconds: 200),
            );

            // Reset settings
            await controller.resetSettings();

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
  // =============================================================
  // LOGOUT
  // =============================================================

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout?'),
        content: const Text(
          'Are you sure you want to logout from your ExpenseMate account?',
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.logout();
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

  // =============================================================
  // DELETE ACCOUNT
  // =============================================================

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
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.deleteAccount();
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
}

// ===============================================================
// SECTION HEADER
// ===============================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.isDark,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(
              alpha: 0.10,
            ),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            size: 17,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: AppTextStyles.headingMedium(isDark).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ===============================================================
// SETTINGS CARD
// ===============================================================

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;

  const _SettingsCard({
    required this.children,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: isDark ? 0.08 : 0.035,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: children,
        ),
      ),
    );
  }
}

// ===============================================================
// ICON CONTAINER
// ===============================================================

class _IconContainer extends StatelessWidget {
  final IconData icon;
  final bool isDark;

  const _IconContainer({
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(
          alpha: 0.10,
        ),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(
        icon,
        color: AppColors.primary,
      ),
    );
  }
}