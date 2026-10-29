import 'package:expense_mate/Core/theme/custom_colors.dart';// standard flutter material import
import 'package:flutter/material.dart';
class AppTextStyles {
  static TextStyle headingLarge(bool isDark) => TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle headingMedium(bool isDark) => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle bodyLarge(bool isDark) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle bodyMedium(bool isDark) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      );

  static TextStyle caption(bool isDark) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      );
}