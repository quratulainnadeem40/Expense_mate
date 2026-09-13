import 'package:expense_mate/Core/constants/app_keys.dart';
import 'package:expense_mate/Core/service/notification_service.dart';
import 'package:expense_mate/Core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

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
// PROFILE
// ============================================================

final profileName = ''.obs;
final profileEmail = ''.obs;
final profilePictureUrl = ''.obs;

final isUpdatingProfile = false.obs;

final ImagePicker _imagePicker = ImagePicker();
  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    settingsBox = Hive.box(AppKeys.settingsBox);

    loadSettings();
    loadProfile();
  }

// ============================================================
// LOAD PROFILE
// ============================================================

void loadProfile() {
  final user = _supabase.auth.currentUser;

  if (user == null) {
    profileName.value = 'User';
    profileEmail.value = '';
    profilePictureUrl.value = '';
    return;
  }

  profileEmail.value = user.email ?? '';

  profileName.value =
      user.userMetadata?['name']?.toString() ?? 'User';

  profilePictureUrl.value =
      user.userMetadata?['avatar_url']?.toString() ?? '';
}

// ============================================================
// UPDATE NAME
// ============================================================

Future<void> updateName(String name) async {
  final trimmedName = name.trim();

  if (trimmedName.isEmpty) {
    Get.snackbar(
      'Error',
      'Please enter your name.',
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }

  try {
    isUpdatingProfile.value = true;

    await _supabase.auth.updateUser(
      UserAttributes(
        data: {
          'name': trimmedName,
        },
      ),
    );

    profileName.value = trimmedName;

    Get.snackbar(
      'Success',
      'Name updated successfully.',
      snackPosition: SnackPosition.BOTTOM,
    );
  } on AuthException catch (e) {
    Get.snackbar(
      'Update Failed',
      e.message,
      snackPosition: SnackPosition.BOTTOM,
    );
  } catch (e) {
    Get.snackbar(
      'Update Failed',
      'Unable to update name.',
      snackPosition: SnackPosition.BOTTOM,
    );
  } finally {
    isUpdatingProfile.value = false;
  }
}

// ============================================================
// PICK PROFILE PICTURE
// ============================================================

Future<void> pickProfilePicture() async {
  try {
    final XFile? pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedImage == null) return;

    isUpdatingProfile.value = true;

    final user = _supabase.auth.currentUser;

    if (user == null) {
      Get.snackbar(
        'Error',
        'No logged-in account found.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Read image as bytes instead of using dart:io File.
    final bytes = await pickedImage.readAsBytes();

    final filePath =
        '${user.id}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

debugPrint('USER: ${_supabase.auth.currentUser?.id}');
debugPrint('SESSION: ${_supabase.auth.currentSession != null}');
    await _supabase.storage
        .from('profile-pictures')
        .uploadBinary(
          filePath,
          bytes,
         fileOptions: const FileOptions(
  upsert: false,
  contentType: 'image/jpeg',
),
        );

    final imageUrl = _supabase.storage
        .from('profile-pictures')
        .getPublicUrl(filePath);

    await _supabase.auth.updateUser(
      UserAttributes(
        data: {
          'avatar_url': imageUrl,
        },
      ),
    );

    profilePictureUrl.value = imageUrl;

    Get.snackbar(
      'Success',
      'Profile picture updated successfully.',
      snackPosition: SnackPosition.BOTTOM,
    );
  } on StorageException catch (e) {
    debugPrint('Storage error: ${e.message}');

    Get.snackbar(
      'Upload Failed',
      e.message,
      snackPosition: SnackPosition.BOTTOM,
    );
  } on AuthException catch (e) {
    debugPrint('Auth error: ${e.message}');

    Get.snackbar(
      'Error',
      e.message,
      snackPosition: SnackPosition.BOTTOM,
    );
  } catch (e) {
    debugPrint('Profile picture error: $e');

    Get.snackbar(
      'Upload Failed',
      e.toString(),
      snackPosition: SnackPosition.BOTTOM,
    );
  } finally {
    isUpdatingProfile.value = false;
  }
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
   void loadProfile() {
  final user = _supabase.auth.currentUser;

  if (user == null) {
    profileName.value = 'User';
    profileEmail.value = '';
    profilePictureUrl.value = '';
    return;
  }

  profileName.value =
      user.userMetadata?['name']?.toString() ?? 'User';

  // Login wali email
  profileEmail.value = user.email ?? '';

  profilePictureUrl.value =
      user.userMetadata?['avatar_url']?.toString() ?? '';
}
  }
}

