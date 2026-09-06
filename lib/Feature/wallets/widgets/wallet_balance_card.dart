import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:flutter/material.dart';

import '../../../Core/theme/custom_colors.dart';


class WalletBalanceCard extends StatelessWidget {
  final double totalBalance;
  final String currency;

  const WalletBalanceCard({
    super.key,
    required this.totalBalance,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: AppTextStyles.bodyMedium(isDark).copyWith(
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '$currency ${totalBalance.toStringAsFixed(2)}',
            style: AppTextStyles.headingLarge(isDark).copyWith(
              color: Colors.white,
              fontSize: 28,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Across all wallets',
            style: AppTextStyles.caption(isDark).copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}