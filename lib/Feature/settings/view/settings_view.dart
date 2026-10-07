import 'package:expense_mate/Core/theme/custom_colors.dart';
import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:expense_mate/Core/widgets/sync_status_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:expense_mate/Feature/about/view/about_view.dart';

import '../controller/settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  static const String _addCurrencyOption = '__add_currency__';

  SettingsController get controller => Get.find<SettingsController>();

  Future<void> _showAddCurrencyDialog() async {
    final currencyController = TextEditingController();
    final currency = await Get.dialog<String>(
      AlertDialog(
        title: const Text('Add Currency'),
        content: TextField(
          controller: currencyController,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          maxLength: 10,
          decoration: const InputDecoration(
            labelText: 'Currency code or symbol',
            hintText: 'e.g. AED',
          ),
          onSubmitted: (value) {
            final code = value.trim();
            if (code.isNotEmpty) {
              Get.back(result: code);
            }
          },
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final code = currencyController.text.trim();
              if (code.isNotEmpty) {
                Get.back(result: code);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    currencyController.dispose();

    if (currency != null && currency.trim().isNotEmpty) {
      await controller.addCustomCurrency(currency);
    }
  }

  Future<void> _showCurrencyListDialog(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        title: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.currency_exchange_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Currency',
                    style: AppTextStyles.headingMedium(
                      isDark,
                    ).copyWith(fontSize: 19, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Choose your preferred currency',
                    style: AppTextStyles.caption(isDark),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 390),
            child: SingleChildScrollView(
              child: Obx(() {
                const defaultCurrencies = ['PKR', 'USD', 'EUR', 'GBP'];

                final customCurrencies = controller.customCurrencies.toList();

                Widget currencyTile({
                  required String currency,
                  required bool isCustom,
                }) {
                  final isSelected =
                      controller.selectedCurrency.value == currency;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(
                              alpha: isDark ? 0.2 : 0.08,
                            )
                          : AppColors.cardAlt(isDark),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.45)
                            : AppColors.border(isDark),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.only(
                        left: 14,
                        right: isCustom ? 4 : 14,
                      ),
                      minVerticalPadding: 10,
                      leading: Icon(
                        isSelected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary(isDark),
                      ),
                      title: Text(
                        currency,
                        style: AppTextStyles.bodyLarge(
                          isDark,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        isCustom ? 'Custom currency' : 'Default currency',
                        style: AppTextStyles.caption(isDark),
                      ),
                      onTap: () async {
                        await controller.changeCurrency(currency);
                        Get.back();
                      },
                      trailing: isCustom
                          ? IconButton(
                              tooltip: 'Delete currency',
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.expenseRed,
                              ),
                              onPressed: () async {
                                await _confirmDeleteCurrency(context, currency);
                              },
                            )
                          : null,
                    ),
                  );
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...defaultCurrencies.map(
                      (currency) =>
                          currencyTile(currency: currency, isCustom: false),
                    ),
                    if (customCurrencies.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(color: AppColors.border(isDark)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text(
                                'MY CURRENCIES',
                                style: AppTextStyles.caption(isDark).copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: AppColors.border(isDark)),
                            ),
                          ],
                        ),
                      ),
                      ...customCurrencies.map(
                        (currency) =>
                            currencyTile(currency: currency, isCustom: true),
                      ),
                    ],
                  ],
                );
              }),
            ),
          ),
        ),
        actions: [
          FilledButton.icon(
            onPressed: () {
              Get.back();
              _showAddCurrencyDialog();
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Currency'),
            style: FilledButton.styleFrom(
              foregroundColor: AppColors.primary,
              backgroundColor: AppColors.primary.withValues(
                alpha: isDark ? 0.22 : 0.10,
              ),
              elevation: 0,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary(isDark),
              side: BorderSide(color: AppColors.border(isDark)),
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteCurrency(
    BuildContext context,
    String currency,
  ) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Currency?'),
        content: Text(
          'Are you sure you want to remove "$currency" from your custom currencies?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.expenseRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.deleteCustomCurrency(currency);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTextStyles.headingMedium(
            isDark,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: SyncStatusIndicator(),
          ),
        ],
      ),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
          children: [
            _buildProfileHeader(context, isDark),

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
                    style: AppTextStyles.bodyLarge(
                      isDark,
                    ).copyWith(fontWeight: FontWeight.w600),
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
                    vertical: 6,
                  ),
                  leading: _IconContainer(
                    icon: Icons.currency_exchange_rounded,
                    isDark: isDark,
                  ),
                  title: Text(
                    'Default Currency',
                    style: AppTextStyles.bodyLarge(
                      isDark,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Obx(
                    () => Text(
                      controller.selectedCurrency.value,
                      style: AppTextStyles.bodyMedium(isDark),
                    ),
                  ),
                  trailing: Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        controller.selectedCurrency.value,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    _showCurrencyListDialog(context);
                  },
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
                    style: AppTextStyles.bodyLarge(
                      isDark,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Receive reminders for upcoming bills',
                    style: AppTextStyles.bodyMedium(isDark),
                  ),
                  value: controller.notificationsEnabled.value,
                  onChanged: controller.toggleNotifications,
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
                    style: AppTextStyles.bodyLarge(
                      isDark,
                    ).copyWith(fontWeight: FontWeight.w600),
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
                  color: isDark ? Colors.white12 : Colors.black12,
                ),

                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.expenseRed.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(13),
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
                  onTap: () => Get.to(() => const AboutView()),
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
                    style: AppTextStyles.bodyLarge(
                      isDark,
                    ).copyWith(fontWeight: FontWeight.w600),
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
              child: Text('ExpenseMate', style: AppTextStyles.caption(isDark)),
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

  Widget _buildProfileHeader(BuildContext context, bool isDark) {
    // IMPORTANT:
    // Use the controller's observable values here.
    // Do not read authUser directly for the displayed name/email.
    final displayName = controller.profileName.value.isNotEmpty
        ? controller.profileName.value
        : 'User';

    final displayEmail = controller.profileEmail.value.isNotEmpty
        ? controller.profileEmail.value
        : 'No email available';

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 50),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primary,
                        backgroundImage:
                            controller.profilePictureUrl.value.isNotEmpty
                            ? NetworkImage(controller.profilePictureUrl.value)
                            : null,
                        child: controller.profilePictureUrl.value.isEmpty
                            ? Text(
                                displayName.isNotEmpty
                                    ? displayName[0].toUpperCase()
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

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.headingMedium(
                          isDark,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        displayEmail,
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
                          color: AppColors.primary.withValues(alpha: 0.10),
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
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Material(
              color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.09),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _showEditProfileDialog(context),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.16),
                    ),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // EDIT PROFILE DIALOG
  // =============================================================

  void _showEditProfileDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get the latest values at the moment the dialog opens.
    final nameController = TextEditingController(
      text: controller.profileName.value,
    );

    final emailController = TextEditingController(
      text: controller.profileEmail.value,
    );

    final passwordController = TextEditingController();

    final obscurePassword = true.obs;

    InputDecoration profileFieldDecoration({
      required String label,
      required IconData icon,
      String? hint,
      Widget? suffix,
    }) {
      final radius = BorderRadius.circular(12);
      return InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.cardAlt(isDark),
        border: OutlineInputBorder(borderRadius: radius),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: AppColors.border(isDark)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      );
    }

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        titlePadding: const EdgeInsets.fromLTRB(24, 22, 16, 6),
        contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actionsAlignment: MainAxisAlignment.end,
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.manage_accounts_rounded,
                color: AppColors.primary,
                size: 23,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit profile',
                    style: AppTextStyles.headingMedium(
                      isDark,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Update your account details',
                    style: AppTextStyles.caption(isDark),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.close_rounded),
              style: IconButton.styleFrom(
                foregroundColor: AppColors.textSecondary(isDark),
                backgroundColor: AppColors.cardAlt(isDark),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // =================================================
                // PROFILE PICTURE
                // =================================================

                Obx(
                  () => Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.28),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.24 : 0.08,
                          ),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 41,
                      backgroundColor: AppColors.primary,
                      backgroundImage:
                          controller.profilePictureUrl.value.isNotEmpty
                          ? NetworkImage(controller.profilePictureUrl.value)
                          : null,
                      child: controller.profilePictureUrl.value.isEmpty
                          ? Text(
                              controller.profileName.value.isNotEmpty
                                  ? controller.profileName.value[0]
                                        .toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(
                      () => OutlinedButton.icon(
                        onPressed: controller.isUpdatingProfile.value
                            ? null
                            : () async {
                                await controller.pickProfilePicture();
                              },
                        icon: const Icon(
                          Icons.photo_library_outlined,
                          size: 18,
                        ),
                        label: const Text('Change'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.35),
                          ),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 11,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Obx(
                      () => controller.profilePictureUrl.value.isNotEmpty
                          ? OutlinedButton.icon(
                              onPressed: controller.isUpdatingProfile.value
                                  ? null
                                  : () async {
                                      await controller.clearProfilePicture();
                                    },
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: AppColors.expenseRed,
                              ),
                              label: const Text(
                                'Clear',
                                style: TextStyle(color: AppColors.expenseRed),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.expenseRed,
                                side: BorderSide(
                                  color: AppColors.expenseRed.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 11,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ACCOUNT DETAILS',
                    style: AppTextStyles.caption(isDark).copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // =================================================
                // NAME
                // =================================================
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: profileFieldDecoration(
                    label: 'Name',
                    icon: Icons.person_outline_rounded,
                  ),
                ),

                const SizedBox(height: 14),

                // =================================================
                // EMAIL
                // =================================================
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: profileFieldDecoration(
                    label: 'Email',
                    icon: Icons.email_outlined,
                  ),
                ),

                const SizedBox(height: 14),

                // =================================================
                // PASSWORD
                // =================================================
                Obx(
                  () => TextField(
                    controller: passwordController,
                    obscureText: obscurePassword.value,
                    textInputAction: TextInputAction.done,
                    decoration: profileFieldDecoration(
                      label: 'New Password',
                      hint: 'Leave empty to keep current password',
                      icon: Icons.lock_outline_rounded,
                      suffix: IconButton(
                        onPressed: () {
                          obscurePassword.value = !obscurePassword.value;
                        },
                        icon: Icon(
                          obscurePassword.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Leave password empty if you do not want to change it.',
                    style: AppTextStyles.caption(isDark),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary(isDark),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            ),
            child: const Text('Cancel'),
          ),

          Obx(
            () => ElevatedButton(
              onPressed: controller.isUpdatingProfile.value
                  ? null
                  : () async {
                      await controller.updateProfile(
                        name: nameController.text,
                        email: emailController.text,
                        password: passwordController.text,
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
              ),
              child: controller.isUpdatingProfile.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Save changes',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // =============================================================
  // LOGOUT
  // =============================================================

  void _showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        title: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.expenseRed.withValues(
                  alpha: isDark ? 0.18 : 0.1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.expenseRed,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Logout?',
                style: AppTextStyles.headingMedium(
                  isDark,
                ).copyWith(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout from your ExpenseMate account?',
          style: AppTextStyles.bodyMedium(isDark).copyWith(height: 1.5),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary(isDark),
                  side: BorderSide(color: AppColors.border(isDark)),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 13,
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () async {
                  Get.back();
                  await controller.logout();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.expenseRed,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 13,
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Logout'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =============================================================
  // DELETE ACCOUNT
  // =============================================================

  void _showDeleteAccountDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
        actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        title: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.expenseRed.withValues(
                  alpha: isDark ? 0.18 : 0.1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                color: AppColors.expenseRed,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Delete Account?',
                style: AppTextStyles.headingMedium(
                  isDark,
                ).copyWith(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This action is permanent. Your ExpenseMate account '
              'and associated account data will be deleted. '
              'You will not be able to recover your account.',
              style: AppTextStyles.bodyMedium(isDark).copyWith(height: 1.5),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.expenseRed.withValues(
                  alpha: isDark ? 0.16 : 0.08,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.expenseRed.withValues(alpha: 0.22),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.expenseRed,
                    size: 20,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'This cannot be undone.',
                      style: AppTextStyles.bodyMedium(isDark).copyWith(
                        color: AppColors.expenseRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary(isDark),
                  side: BorderSide(color: AppColors.border(isDark)),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 13,
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () async {
                  Get.back();
                  await controller.deleteAccount();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.expenseRed,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 13,
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Delete Account'),
              ),
            ],
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
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 17, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppTextStyles.headingMedium(
            isDark,
          ).copyWith(fontWeight: FontWeight.bold),
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

  const _SettingsCard({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(children: children),
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

  const _IconContainer({required this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: AppColors.primary),
    );
  }
}
