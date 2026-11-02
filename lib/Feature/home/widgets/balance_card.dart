import 'package:expense_mate/Core/theme/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// SettingsController ka path
import 'package:expense_mate/Feature/settings/controller/settings_controller.dart';

class BalanceCard extends StatelessWidget {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;

  const BalanceCard({
    super.key,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
  });

  /// What a hidden figure looks like.
  ///
  /// A fixed run of dots, not one per digit, so the length of the dots
  /// does not quietly give the amount away.
  static const String _masked = '••••••';

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : Get.put(SettingsController());

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total Balance',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),

              // The eye sits beside the label rather than over the
              // figure, so tapping it never hides what you are reading.
              Obx(() {
                final hidden = settingsController.hideAmounts.value;

                return InkWell(
                  onTap: settingsController.toggleHideAmounts,
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      hidden
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 20,
                      color: Colors.white70,
                    ),
                  ),
                );
              }),
            ],
          ),

          const SizedBox(height: 8),

          // Currency reactive status ke liye Obx inside wrapper
          Obx(() {
            final hidden = settingsController.hideAmounts.value;
            final currency = settingsController.selectedCurrency.value;

            return Text(
              hidden
                  ? '$currency $_masked'
                  : '$currency ${totalBalance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            );
          }),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                'Income',
                totalIncome,
                Colors.green,
                settingsController,
              ),
              _buildInfoItem(
                'Expense',
                totalExpense,
                AppColors.expenseRed,
                settingsController,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    String title,
    double amount,
    Color color,
    SettingsController settingsController,
  ) {
    final safeAmount = amount.isNaN || amount.isInfinite ? 0.0 : amount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),

        // Income and expense are hidden with the balance. Leaving them
        // visible would let anyone work the balance out anyway.
        Obx(() {
          final hidden = settingsController.hideAmounts.value;
          final currency = settingsController.selectedCurrency.value;

          return Text(
            hidden
                ? '$currency $_masked'
                : '$currency ${safeAmount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          );
        }),
      ],
    );
  }
}
