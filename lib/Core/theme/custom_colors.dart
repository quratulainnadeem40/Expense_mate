import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2E7D32);
  static const Color secondary = Color(0xFF81C784);

  // ---------------------------------------------------------------
  // LIGHT MODE
  // ---------------------------------------------------------------
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardAltLight = Color(0xFFF7F8FA);
  static const Color borderLight = Color(0x0F000000);
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);

  // ---------------------------------------------------------------
  // DARK MODE  (true black - AMOLED friendly)
  // ---------------------------------------------------------------
  // backgroundDark is pure black. Everything that sits ON TOP of it
  // uses cardDark / cardAltDark so the layers stay distinguishable.
  static const Color backgroundDark = Color(0xFF000000);
  static const Color surfaceDark = Color(0xFF000000);
  static const Color cardDark = Color(0xFF121212);
  static const Color cardAltDark = Color(0xFF1C1C1C);
  static const Color borderDark = Color(0xFF262626);
  static const Color textPrimaryDark = Color(0xFFF2F2F2);
  static const Color textSecondaryDark = Color(0xFF9E9E9E);

  static const Color expenseRed = Color(0xFFE53935);
  static const Color incomeGreen = Color(0xFF43A047);

  // ---------------------------------------------------------------
  // HELPERS - use these instead of hardcoding hex values in views
  // ---------------------------------------------------------------
  static Color background(bool isDark) =>
      isDark ? backgroundDark : backgroundLight;

  static Color card(bool isDark) => isDark ? cardDark : cardLight;

  static Color cardAlt(bool isDark) => isDark ? cardAltDark : cardAltLight;

  static Color border(bool isDark) => isDark ? borderDark : borderLight;

  static Color textPrimary(bool isDark) =>
      isDark ? textPrimaryDark : textPrimaryLight;

  static Color textSecondary(bool isDark) =>
      isDark ? textSecondaryDark : textSecondaryLight;
}