import 'package:expense_mate/Core/theme/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// SettingsController ka path
import 'package:expense_mate/Feature/settings/controller/settings_controller.dart';

class BalanceCard extends StatefulWidget {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;

  const BalanceCard({
    super.key,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isBalanceVisible = false;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Balance',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              IconButton(
                tooltip: _isBalanceVisible ? 'Hide balance' : 'Show balance',
                onPressed: () {
                  setState(() {
                    _isBalanceVisible = !_isBalanceVisible;
                  });
                },
                icon: Icon(
                  _isBalanceVisible
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Obx(
            () => Text(
              _isBalanceVisible
                  ? '${settingsController.selectedCurrency.value} ${widget.totalBalance.toStringAsFixed(2)}'
                  : '${settingsController.selectedCurrency.value} ******',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                'Income',
                widget.totalIncome,
                Colors.green,
                settingsController,
              ),
              _buildInfoItem(
                'Expense',
                widget.totalExpense,
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
        Obx(
          () => Text(
            _isBalanceVisible
                ? '${settingsController.selectedCurrency.value} ${safeAmount.toStringAsFixed(2)}'
                : '${settingsController.selectedCurrency.value} ******',
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
