import 'package:expense_mate/Feature/wallets/binding/wallets_binding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../bills_reminders/binding/bills_reminders_binding.dart';
import '../../bills_reminders/view/bills_reminders_view.dart';
import '../../settings/binding/settings_binding.dart';
import '../../settings/view/settings_view.dart';

import '../../wallets/view/wallets_view.dart';
// We'll add these later:
// import '../../bills_reminders/view/bills_reminders_view.dart';
// import '../../settings/view/settings_view.dart';

class MoreView extends StatelessWidget {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F2),
      appBar: AppBar(
        title: const Text(
          'More',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF6F7F2),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildOption(
            context: context,
            icon: Icons.account_balance_wallet_rounded,
            title: 'Wallets',
            subtitle: 'Manage your cash, bank and other wallets',
            onTap: () {
              Get.to(
  () => const WalletsView(),
  binding: WalletsBinding(),
);
            },
          ),

          const SizedBox(height: 12),

          _buildOption(
            context: context,
            icon: Icons.notifications_active_rounded,
            title: 'Bills & Reminders',
            subtitle: 'Manage upcoming bills and reminders',
            onTap: () {
      
  Get.to(
    () => const BillsRemindersView(),
    binding: BillsRemindersBinding(),
  );
},
          
          ),

          const SizedBox(height: 12),

          _buildOption(
            context: context,
            icon: Icons.settings_rounded,
            title: 'Settings',
            subtitle: 'Manage app preferences and settings',
            onTap: () {
            
  Get.to(
    () => const SettingsView(),
    binding: SettingsBinding(),
  );

            },
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF2B82FB).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
               child: Icon(
  icon,
  color: const Color(0xFF2B82FB),
  size: 26,
),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Color(0xFF757575),
              ),
            ],
          ),
        ),
      ),
    );
  }
}