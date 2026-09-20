import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Bindings & Views
import 'package:expense_mate/Feature/Budgets/bindings/budget_bindings.dart';
import 'package:expense_mate/Feature/Budgets/view/budget_view.dart';
import 'package:expense_mate/Feature/wallets/binding/wallets_binding.dart';
import 'package:expense_mate/Feature/wallets/view/wallets_view.dart';
import 'package:expense_mate/Feature/goals/binding/goals_binding.dart';
import 'package:expense_mate/Feature/goals/view/goals_view.dart';
import 'package:expense_mate/Feature/bills_reminders/binding/bills_reminders_binding.dart';
import 'package:expense_mate/Feature/bills_reminders/view/bills_reminders_view.dart';
import 'package:expense_mate/Feature/settings/binding/settings_binding.dart';
import 'package:expense_mate/Feature/settings/view/settings_view.dart';

class AppDrawer extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const AppDrawer({super.key, required this.scaffoldKey});

  String get _userName {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final nameFromMetaData =
          user.userMetadata?['full_name'] ?? user.userMetadata?['name'];

      if (nameFromMetaData != null &&
          nameFromMetaData.toString().isNotEmpty) {
        return nameFromMetaData.toString();
      }

      if (user.email != null && user.email!.contains('@')) {
        final emailPrefix = user.email!.split('@').first;
        return emailPrefix[0].toUpperCase() + emailPrefix.substring(1);
      }
    }
    return 'User';
  }

  void _closeDrawerAndNavigate(Widget Function() page, {Bindings? binding}) {
    if (scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
      scaffoldKey.currentState?.closeEndDrawer();
    }
    Future.delayed(const Duration(milliseconds: 150), () {
      Get.to(page, binding: binding);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 16, right: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Drawer(
            elevation: 4,
            backgroundColor: isDarkMode
                ? const Color(0xFF1E1E1E)
                : const Color(0xFFF9FAFB),
            child: Column(
              children: [
                UserAccountsDrawerHeader(
                  margin: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDarkMode
                          ? [const Color(0xFF2E7D32), const Color(0xFF1B5E20)]
                          : [const Color(0xFF4CAF50), const Color(0xFF388E3C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  currentAccountPictureSize: const Size.square(64),
                  currentAccountPicture: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        _userName.isNotEmpty
                            ? _userName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ),
                  accountName: Text(
                    _userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  accountEmail: Text(
                    Supabase.instance.client.auth.currentUser?.email ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                    children: [
                      _buildDrawerOption(
                        context: context,
                        icon: Icons.account_balance_wallet_rounded,
                        iconColor: const Color(0xFF2B82FB),
                        title: 'Wallets',
                        subtitle: 'Manage your cash, bank and other wallets',
                        onTap: () => _closeDrawerAndNavigate(
                          () => const WalletsView(),
                          binding: WalletsBinding(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDrawerOption(
                        context: context,
                        icon: Icons.pie_chart_rounded,
                        iconColor: const Color(0xFFFF9800),
                        title: 'Budgets',
                        subtitle: 'Set and track monthly spending limits',
                        onTap: () => _closeDrawerAndNavigate(
                          () => const BudgetView(),
                          binding: BudgetBinding(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDrawerOption(
                        context: context,
                        icon: Icons.stars_rounded,
                        iconColor: const Color(0xFFE91E63),
                        title: 'Goals',
                        subtitle: 'Track your financial targets and savings',
                        onTap: () => _closeDrawerAndNavigate(
                          () => const GoalsView(),
                          binding: GoalsBinding(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDrawerOption(
                        context: context,
                        icon: Icons.notifications_active_rounded,
                        iconColor: const Color(0xFF9C27B0),
                        title: 'Bills & Reminders',
                        subtitle: 'Manage upcoming bills and reminders',
                        onTap: () => _closeDrawerAndNavigate(
                          () => const BillsRemindersView(),
                          binding: BillsRemindersBinding(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDrawerOption(
                        context: context,
                        icon: Icons.person_rounded,
                        iconColor: const Color(0xFF00BCD4),
                        title: 'Profile',
                        subtitle: 'Manage your profile and account settings',
                        onTap: () => _closeDrawerAndNavigate(
                          () => const SettingsView(),
                          binding: SettingsBinding(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerOption({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDarkMode
                              ? Colors.grey.shade400
                              : const Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDarkMode
                      ? Colors.grey.shade500
                      : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}