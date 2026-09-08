import 'package:expense_mate/Core/theme/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// SettingsController ka relative/exact path import karein
import 'package:expense_mate/Feature/settings/controller/settings_controller.dart';

class BalanceCard extends StatelessWidget {
  final RxDouble totalBalance;
  final RxDouble totalIncome;
  final RxDouble totalExpense;

  const BalanceCard({
    Key? key,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // SettingsController locate karein
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
          const Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Obx(() => Text(
                '${settingsController.selectedCurrency.value} ${totalBalance.value.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              )),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem('Income', totalIncome, AppColors.incomeGreen, settingsController),
              _buildInfoItem('Expense', totalExpense, AppColors.expenseRed, settingsController),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    String title, 
    RxDouble amount, 
    Color color, 
    SettingsController settingsController
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Obx(() => Text(
              '${settingsController.selectedCurrency.value} ${amount.value.toStringAsFixed(2)}',
              style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
            )),
      ],
    );
  }
}