import 'package:expense_mate/Core/constants/app_keys.dart';
import 'package:expense_mate/Core/service/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsController extends GetxController {
  late Box settingsBox;

  final isDarkMode = false.obs;
  final selectedCurrency = 'PKR'.obs;
  final notificationsEnabled = true.obs;

  final NotificationService notificationService =
      Get.find<NotificationService>();

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
    isDarkMode.value =
        settingsBox.get(
          AppKeys.isDarkModeKey,
          defaultValue: false,
        ) as bool;

    selectedCurrency.value =
        settingsBox.get(
          'currency',
          defaultValue: 'PKR',
        ) as String;

    notificationsEnabled.value =
        settingsBox.get(
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
      // Notifications OFF → cancel all scheduled notifications.
      await notificationService.cancelAllNotifications();
    }
  }

  // ============================================================
  // CLEAR SETTINGS
  // ============================================================

  Future<void> resetSettings() async {
    await settingsBox.clear();

    isDarkMode.value = false;
    selectedCurrency.value = 'PKR';
    notificationsEnabled.value = true;

    // Clear any previously scheduled notifications.
    await notificationService.cancelAllNotifications();

    Get.changeThemeMode(ThemeMode.light);
  }
}