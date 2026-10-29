import 'package:expense_mate/Core/theme/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // =================================================================
  // LIGHT
  // =================================================================
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    canvasColor: AppColors.backgroundLight,
    dividerColor: AppColors.borderLight,
    hintColor: AppColors.textSecondaryLight,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      surface: AppColors.surfaceLight,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      surfaceTintColor: Colors.transparent,
      foregroundColor: AppColors.textPrimaryLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardLight,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.surfaceLight,
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceLight,
      surfaceTintColor: Colors.transparent,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceLight,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimaryLight, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.textSecondaryLight, fontSize: 14),
      titleLarge: TextStyle(
        color: AppColors.textPrimaryLight,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  // =================================================================
  // DARK  (true black)
  // =================================================================
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,

    // Pure black everywhere the page itself shows through.
    scaffoldBackgroundColor: AppColors.backgroundDark,
    canvasColor: AppColors.backgroundDark,
    dividerColor: AppColors.borderDark,
    hintColor: AppColors.textSecondaryDark,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      surface: AppColors.backgroundDark,
      surfaceContainerLowest: AppColors.backgroundDark,
      surfaceContainerLow: AppColors.cardDark,
      surfaceContainer: AppColors.cardDark,
      surfaceContainerHigh: AppColors.cardAltDark,
      surfaceContainerHighest: AppColors.cardAltDark,
      outline: AppColors.borderDark,
    ),

    // Material 3 tints surfaces with the seed colour by default, which is
    // what was making everything look grey-green. Turning the tint off is
    // what actually keeps the black black.
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      surfaceTintColor: Colors.transparent,
      foregroundColor: AppColors.textPrimaryDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardDark,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.cardDark,
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.cardDark,
      surfaceTintColor: Colors.transparent,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.cardDark,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: AppColors.cardDark,
      surfaceTintColor: Colors.transparent,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.cardDark,
      surfaceTintColor: Colors.transparent,
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: AppColors.cardDark,
      surfaceTintColor: Colors.transparent,
    ),
    listTileTheme: const ListTileThemeData(
      textColor: AppColors.textPrimaryDark,
      iconColor: AppColors.textSecondaryDark,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardDark,
      hintStyle: const TextStyle(color: AppColors.textSecondaryDark),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimaryDark, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.textSecondaryDark, fontSize: 14),
      titleLarge: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}