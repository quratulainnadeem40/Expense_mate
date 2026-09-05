import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:flutter/material.dart';

import '../../../Core/theme/custom_colors.dart';

import '../model/wallet_model.dart';

class WalletCard extends StatelessWidget {
  final WalletModel wallet;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const WalletCard({
    super.key,
    required this.wallet,
    this.onDelete,
    this.onTap,
  });

  IconData _getWalletIcon() {
    switch (wallet.type.toLowerCase()) {
      case 'bank account':
        return Icons.account_balance;

      case 'credit card':
        return Icons.credit_card;

      case 'e-wallet':
        return Icons.account_balance_wallet;

      case 'cash':
      default:
        return Icons.payments_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNegative = wallet.balance < 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: isDark
          ? AppColors.surfaceDark
          : AppColors.surfaceLight,
      child: ListTile(
        onTap: onTap,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),

        leading: CircleAvatar(
          backgroundColor: AppColors.secondary.withValues(
            alpha: 0.25,
          ),
          child: Icon(
            _getWalletIcon(),
            color: AppColors.primary,
          ),
        ),

        title: Text(
          wallet.name,
          style: AppTextStyles.bodyLarge(isDark).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Text(
          wallet.type,
          style: AppTextStyles.bodyMedium(isDark),
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${wallet.currency} ${wallet.balance.toStringAsFixed(2)}',
              style: AppTextStyles.bodyMedium(isDark).copyWith(
                fontWeight: FontWeight.bold,
                color: isNegative
                    ? AppColors.expenseRed
                    : AppColors.incomeGreen,
              ),
            ),

            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.expenseRed,
                ),
              ),
          ],
        ),
      ),
    );
  }
}