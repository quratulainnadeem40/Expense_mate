import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:flutter/material.dart';

import '../../../Core/theme/custom_colors.dart';
import '../model/wallet_model.dart';

class WalletCard extends StatelessWidget {
  final WalletModel wallet;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final bool isSelectionMode;
  final bool isSelected;

  const WalletCard({
    super.key,
    required this.wallet,
    this.onTap,
    this.onLongPress,
    this.isSelectionMode = false,
    this.isSelected = false,
  });

  // ============================================================
  // WALLET ICON
  // ============================================================

  IconData _getWalletIcon() {
    switch (wallet.type) {
      case 'Cash':
        return Icons.payments_outlined;

      case 'Bank Account':
        return Icons.account_balance;

      case 'JazzCash':
        return Icons.account_balance_wallet;

      case 'Easypaisa':
        return Icons.account_balance_wallet;

      case 'Credit Card':
        return Icons.credit_card;

      case 'Other':
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final isNegative = wallet.balance < 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,

      color: isSelected
          ? (isDark
              ? const Color(0xFF263D2A)
              : const Color(0xFFE8F5E9))
          : (isDark
              ? AppColors.surfaceDark
              : AppColors.surfaceLight),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? const BorderSide(
                color: AppColors.primary,
                width: 2,
              )
            : BorderSide.none,
      ),

      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),

        // ======================================================
        // WALLET ICON
        // ======================================================

        leading: Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              backgroundColor:
                  AppColors.secondary.withValues(
                alpha: 0.25,
              ),
              child: Icon(
                _getWalletIcon(),
                color: AppColors.primary,
              ),
            ),

            if (isSelectionMode && isSelected)
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.white,
                ),
              ),
          ],
        ),

        // ======================================================
        // WALLET NAME
        // ======================================================

        title: Text(
          wallet.name,
          style: AppTextStyles.bodyLarge(isDark).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        // ======================================================
        // WALLET TYPE
        // ======================================================

        subtitle: Text(
          wallet.type,
          style: AppTextStyles.bodyMedium(isDark),
        ),

        // ======================================================
        // BALANCE + SELECTION
        // ======================================================

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

            if (isSelectionMode) ...[
              const SizedBox(width: 10),

              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                color: isSelected
                    ? AppColors.primary
                    : Colors.grey,
                size: 24,
              ),
            ],
          ],
        ),
      ),
    );
  }
}