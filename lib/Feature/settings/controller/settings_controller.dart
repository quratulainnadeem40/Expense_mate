import 'package:expense_mate/Core/constants/app_keys.dart';
import 'package:expense_mate/Core/service/notification_service.dart';
import 'package:expense_mate/Core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsController extends GetxController {
  late Box settingsBox;

  final isDarkMode = false.obs;
  final selectedCurrency = 'PKR'.obs;
  final notificationsEnabled = true.obs;

  final isDeletingAccount = false.obs;

  final NotificationService notificationService =
      Get.find<NotificationService>();

  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    settingsBox = Hive.box(AppKeys.settingsBox);

    loadSettings();
  }

  // ============================================================
  // LOAD SETTINGS
  // ============================================================

  void loadSettings() {
    isDarkMode.value = settingsBox.get(
      AppKeys.isDarkModeKey,
      defaultValue: false,
    ) as bool;

    selectedCurrency.value = settingsBox.get(
      'currency',
      defaultValue: 'PKR',
    ) as String;

    notificationsEnabled.value = settingsBox.get(
      'notifications_enabled',
      defaultValue: true,
    ) as bool;
  }

  // ============================================================
  // DARK MODE
  // ============================================================

  Future<void> toggleDarkMode(bool value) async {
    isDarkMode.value = value;

    await settingsBox.put(
      AppKeys.isDarkModeKey,
      value,
    );

    Get.changeThemeMode(
      value ? ThemeMode.dark : ThemeMode.light,
    );
  }

  // ============================================================
  // CURRENCY
  // ============================================================

  Future<void> changeCurrency(String currency) async {
    selectedCurrency.value = currency;

    await settingsBox.put(
      'currency',
      currency,
    );
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  Future<void> toggleNotifications(bool value) async {
    notificationsEnabled.value = value;

    await settingsBox.put(
      'notifications_enabled',
      value,
    );

    if (!value) {
      try {
        await notificationService.cancelAllNotifications();
      } catch (e) {
        debugPrint(
          'Notification cleanup error: $e',
        );
      }
    }
  }

  // ============================================================
  // RESET SETTINGS
  // ============================================================

  Future<void> resetSettings() async {
    await settingsBox.clear();

    isDarkMode.value = false;
    selectedCurrency.value = 'PKR';
    notificationsEnabled.value = true;

    try {
      await notificationService.cancelAllNotifications();
    } catch (e) {
      debugPrint(
        'Notification cleanup error: $e',
      );
    }

    Get.changeThemeMode(ThemeMode.light);
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();

      Get.offAllNamed(AppRoutes.login);

      Get.snackbar(
        'Logged Out',
        'You have been logged out successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on AuthException catch (e) {
      Get.snackbar(
        'Logout Failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Logout Failed',
        'Unable to logout. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================================
  // DELETE ACCOUNT
  // ============================================================

  Future<void> deleteAccount() async {
    if (isDeletingAccount.value) {
      return;
    }

    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        Get.snackbar(
          'Error',
          'No logged-in account found.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      isDeletingAccount.value = true;

      final response = await _supabase.functions.invoke(
        'delete-account',
      );

      if (response.status != 200) {
        String errorMessage = 'Unable to delete account.';

        if (response.data is Map &&
            response.data['error'] != null) {
          errorMessage = response.data['error'].toString();
        }

        throw Exception(errorMessage);
      }

      // Clear local settings.
      await settingsBox.clear();

      // Cancel any locally scheduled notifications.
      try {
        await notificationService.cancelAllNotifications();
      } catch (e) {
        debugPrint(
          'Notification cleanup error: $e',
        );
      }

      // Sign out locally after successful account deletion.
      await _supabase.auth.signOut();

      Get.offAllNamed(AppRoutes.login);

      Get.snackbar(
        'Account Deleted',
        'Your ExpenseMate account has been permanently deleted.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on AuthException catch (e) {
      Get.snackbar(
        'Delete Account Failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint(
        'Delete account exception: $e',
      );

      Get.snackbar(
        'Delete Account Failed',
        'Unable to delete account. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isDeletingAccount.value = false;
    }
  }
}

