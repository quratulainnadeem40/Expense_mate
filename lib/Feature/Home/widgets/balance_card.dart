import 'package:expense_mate/Core/theme/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


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
                '\$${totalBalance.value.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              )),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem('Income', totalIncome, AppColors.incomeGreen),
              _buildInfoItem('Expense', totalExpense, AppColors.expenseRed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, RxDouble amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Obx(() => Text(
              '\$${amount.value.toStringAsFixed(2)}',
              style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
            )),
      ],
    );
  }
}