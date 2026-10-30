
import 'dart:async';

import 'package:expense_mate/Core/constants/app_keys.dart';
import 'package:expense_mate/Core/routes/app_routes.dart';
import 'package:expense_mate/Core/service/notification_service.dart';
import '../../../Core/service/sound_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsController extends GetxController {
  StreamSubscription<AuthState>? _authSubscription;

  // SETTINGS

  late Box settingsBox;

  final isDarkMode = false.obs;
  final hideAmounts = true.obs;

  /// Confirmation sound after a transaction is saved.
  final transactionSound = true.obs;

  final selectedCurrency = 'PKR'.obs;
  final customCurrencies = <String>[].obs;
  final notificationsEnabled = true.obs;

  static const Set<String> supportedLanguages = {
    'en',
    'ur',
    'ps',
    'sd',
    'ar',
    'hi',
  };

  final selectedLanguage = 'en'.obs;

  // ACCOUNT

  final isDeletingAccount = false.obs;

  final NotificationService notificationService =
      Get.find<NotificationService>();

  final SupabaseClient _supabase = Supabase.instance.client;

  // PROFILE

  final profileName = ''.obs;
  final profileEmail = ''.obs;
  final profilePictureUrl = ''.obs;

  final isUpdatingProfile = false.obs;

  final ImagePicker _imagePicker = ImagePicker();

  bool _isLoadingProfile = false;

  // INIT

  @override
  void onInit() {
    super.onInit();

    settingsBox = Hive.box(AppKeys.settingsBox);

    loadSettings();

    if (_supabase.auth.currentSession != null) {
      loadProfile();
    }

    _authSubscription =
        _supabase.auth.onAuthStateChange.listen((authState) {
      final event = authState.event;
      final session = authState.session;

      debugPrint('AUTH EVENT: $event | SESSION: ${session != null}');

      if (event == AuthChangeEvent.signedIn) {
        if (session?.user != null) {
          loadProfile();
        }
      }

      if (event == AuthChangeEvent.signedOut) {
        profileName.value = '';
        profileEmail.value = '';
        profilePictureUrl.value = '';
      }
    });
  }

  // CURRENT USER

  User? get currentUser => _supabase.auth.currentUser;

  // LOAD PROFILE

  Future<void> loadProfile() async {
    if (_isLoadingProfile) {
      debugPrint('LOAD PROFILE: Already loading. Skipping.');
      return;
    }

    final session = _supabase.auth.currentSession;
    final user = session?.user;

    if (user == null) {
      debugPrint('LOAD PROFILE: No active session.');
      return;
    }

    _isLoadingProfile = true;

    try {
      final metadata = user.userMetadata ?? {};

      final authName = metadata['name']?.toString().trim() ?? '';
      final authEmail = user.email?.trim() ?? '';
      final authAvatar = metadata['avatar_url']?.toString().trim() ?? '';

      String databaseName = '';
      String databaseEmail = '';

      try {
        final profileResponse = await _supabase
            .from('profiles')
            .select('name, email')
            .eq('id', user.id)
            .maybeSingle();

        if (profileResponse != null) {
          databaseName =
              profileResponse['name']?.toString().trim() ?? '';
          databaseEmail =
              profileResponse['email']?.toString().trim() ?? '';
        }
      } on PostgrestException catch (e) {
        debugPrint('Profiles table error: ${e.message}');
      }

      final finalName = authName.isNotEmpty
          ? authName
          : databaseName.isNotEmpty
              ? databaseName
              : 'User'.tr;

      final finalEmail = authEmail.isNotEmpty
          ? authEmail
          : databaseEmail.isNotEmpty
              ? databaseEmail
              : 'No email available'.tr;

      profileName.value = finalName;
      profileEmail.value = finalEmail;
      profilePictureUrl.value = authAvatar;

      debugPrint('================================');
      debugPrint('PROFILE LOADED');
      debugPrint('User ID: ${user.id}');
      debugPrint('Auth Email: ${user.email}');
      debugPrint('Database Name: $databaseName');
      debugPrint('Database Email: $databaseEmail');
      debugPrint('Final Name: ${profileName.value}');
      debugPrint('Final Email: ${profileEmail.value}');
      debugPrint('Avatar URL: ${profilePictureUrl.value}');
      debugPrint('================================');
    } on AuthException catch (e) {
      debugPrint('Auth profile error: ${e.message}');
    } catch (e) {
      debugPrint('Load profile error: $e');
    } finally {
      _isLoadingProfile = false;
    }
  }

  // UPDATE PROFILE

  Future<void> updateProfile({
    required String name,
    String? email,
    String? password,
  }) async {
    final newName = name.trim();
    final newEmail = email?.trim() ?? '';
    final newPassword = password?.trim();

    if (newName.isEmpty) {
      _showError('Please enter your name.'.tr);
      return;
    }

    if (newPassword != null &&
        newPassword.isNotEmpty &&
        newPassword.length < 6) {
      _showError('Password must be at least 6 characters.'.tr);
      return;
    }

    try {
      isUpdatingProfile.value = true;

      final session = _supabase.auth.currentSession;
      final user = session?.user;

      if (user == null) {
        debugPrint('SESSION IS NULL');
        debugPrint('CURRENT USER: ${_supabase.auth.currentUser}');
        _showError('No logged-in account found.'.tr);
        return;
      }

      debugPrint('================================');
      debugPrint('PROFILE UPDATE START');
      debugPrint('USER ID: ${user.id}');
      debugPrint('CURRENT AUTH EMAIL: ${user.email}');
      debugPrint('NEW EMAIL FROM TEXT FIELD: $newEmail');
      debugPrint('================================');

      final currentName =
          user.userMetadata?['name']?.toString().trim() ?? '';
      final currentEmail = user.email?.trim() ?? '';
      final finalEmail = newEmail.isEmpty ? currentEmail : newEmail;

      final nameChanged = newName != currentName;
      final emailChanged = finalEmail != currentEmail;
      final passwordChanged =
          newPassword != null && newPassword.isNotEmpty;

      if (!nameChanged && !emailChanged && !passwordChanged) {
        if (Get.isDialogOpen == true) {
          Get.back();
        }

        Get.snackbar(
          'No Changes'.tr,
          'There are no changes to save.'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // 1. Update email.
      if (emailChanged) {
        debugPrint('================================');
        debugPrint('UPDATING AUTH EMAIL');
        debugPrint('OLD EMAIL: $currentEmail');
        debugPrint('NEW EMAIL: $finalEmail');
        debugPrint('================================');

        final authResponse = await _supabase.auth.updateUser(
          UserAttributes(email: finalEmail),
        );

        final updatedUser = authResponse.user;

        debugPrint('================================');
        debugPrint('AFTER AUTH EMAIL UPDATE');
        debugPrint('AUTH EMAIL: ${updatedUser?.email}');
        debugPrint('USER ID: ${updatedUser?.id}');
        debugPrint('================================');

        final authEmailAfterUpdate =
            updatedUser?.email?.trim() ?? '';

        if (authEmailAfterUpdate != finalEmail) {
          debugPrint('EMAIL CHANGE IS PENDING CONFIRMATION');

          if (Get.isDialogOpen == true) {
            Get.back();
          }

          Get.snackbar(
            'Confirmation Required'.tr,
            'A confirmation email has been sent to your new email address. '
                    'Please confirm it before the email change becomes active.'
                .tr,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 6),
          );
          return;
        }
      }

      // 2. Update password.
      if (passwordChanged) {
        debugPrint('UPDATING AUTH PASSWORD');

        await _supabase.auth.updateUser(
          UserAttributes(password: newPassword),
        );
      }

      // 3. Update name in Auth metadata.
      if (nameChanged) {
        debugPrint('UPDATING AUTH NAME');

        final metadata =
            Map<String, dynamic>.from(user.userMetadata ?? {});

        metadata['name'] = newName;

        await _supabase.auth.updateUser(
          UserAttributes(data: metadata),
        );
      }

      // 4. Update profiles table.
      final profileData = <String, dynamic>{'name': newName};

      if (emailChanged) {
        profileData['email'] = finalEmail;
      }

      debugPrint('UPDATING PROFILES TABLE');
      debugPrint('PROFILE DATA: $profileData');

      await _supabase
          .from('profiles')
          .update(profileData)
          .eq('id', user.id);

      // 5. Refresh Auth session.
      try {
        await _supabase.auth.refreshSession();
      } catch (e) {
        debugPrint('Session refresh warning: $e');
      }

      // 6. Read final Auth user.
      final finalUser = _supabase.auth.currentUser;
      final verifiedEmail = finalUser?.email?.trim() ?? '';

      debugPrint('================================');
      debugPrint('FINAL PROFILE UPDATE RESULT');
      debugPrint('AUTH USER ID: ${finalUser?.id}');
      debugPrint('FINAL AUTH EMAIL: $verifiedEmail');
      debugPrint('FINAL PROFILE EMAIL: $finalEmail');
      debugPrint('================================');

      // 7. Update local UI.
      profileName.value = newName;

      if (emailChanged) {
        profileEmail.value =
            verifiedEmail.isNotEmpty ? verifiedEmail : finalEmail;
      } else {
        profileEmail.value = currentEmail;
      }

      // 8. Close dialog.
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      // 9. Success message.
      if (nameChanged && emailChanged) {
        Get.snackbar(
          'Profile Updated'.tr,
          'Name and email updated successfully.'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (nameChanged) {
        Get.snackbar(
          'Profile Updated'.tr,
          'Name updated successfully.'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (emailChanged) {
        Get.snackbar(
          'Profile Updated'.tr,
          'Email updated successfully.'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (passwordChanged) {
        Get.snackbar(
          'Profile Updated'.tr,
          'Password updated successfully.'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on AuthException catch (e) {
      debugPrint('================================');
      debugPrint('PROFILE UPDATE AUTH ERROR');
      debugPrint('Message: ${e.message}');
      debugPrint('Status: ${e.statusCode}');
      debugPrint('Code: ${e.code}');
      debugPrint('================================');

      _showError('${e.message} (Code: ${e.code})');
    } on PostgrestException catch (e) {
      debugPrint('================================');
      debugPrint('PROFILE TABLE UPDATE ERROR');
      debugPrint('Message: ${e.message}');
      debugPrint('Code: ${e.code}');
      debugPrint('================================');

      _showError('Profile database update failed.'.tr);
    } catch (e) {
      debugPrint('================================');
      debugPrint('PROFILE UPDATE ERROR');
      debugPrint('Error: $e');
      debugPrint('================================');

      _showError('Unable to update profile. Please try again.'.tr);
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  // UPDATE NAME ONLY

  Future<void> updateName(String name) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      _showError('Please enter your name.'.tr);
      return;
    }

    try {
      isUpdatingProfile.value = true;

      final session = _supabase.auth.currentSession;
      final user = session?.user;

      if (user == null) {
        debugPrint('SESSION IS NULL');
        debugPrint('CURRENT USER: ${_supabase.auth.currentUser}');
        _showError('No logged-in account found.'.tr);
        return;
      }

      debugPrint('LOGGED IN USER ID: ${user.id}');
      debugPrint('LOGGED IN EMAIL: ${user.email}');

      final metadata =
          Map<String, dynamic>.from(user.userMetadata ?? {});

      metadata['name'] = trimmedName;

      await _supabase.auth.updateUser(
        UserAttributes(data: metadata),
      );

      profileName.value = trimmedName;

      await _supabase
          .from('profiles')
          .update({'name': trimmedName})
          .eq('id', user.id);

      Get.snackbar(
        'Success'.tr,
        'Name updated successfully.'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on AuthException catch (e) {
      debugPrint('Update name auth error: ${e.message}');
      _showError(e.message);
    } catch (e) {
      debugPrint('Update name error: $e');
      _showError('Unable to update name.'.tr);
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  // PICK PROFILE PICTURE

  Future<void> pickProfilePicture() async {
    try {
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedImage == null) {
        return;
      }

      final user = _supabase.auth.currentUser;

      if (user == null) {
        _showError('No logged-in account found.'.tr);
        return;
      }

      isUpdatingProfile.value = true;

      final bytes = await pickedImage.readAsBytes();

      final filePath =
          '${user.id}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

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

      final metadata =
          Map<String, dynamic>.from(user.userMetadata ?? {});

      metadata['avatar_url'] = imageUrl;

      await _supabase.auth.updateUser(
        UserAttributes(data: metadata),
      );

      profilePictureUrl.value = imageUrl;

      Get.snackbar(
        'Success'.tr,
        'Profile picture updated successfully.'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on StorageException catch (e) {
      debugPrint('Storage error: ${e.message}');
      _showError(e.message);
    } on AuthException catch (e) {
      debugPrint('Auth error: ${e.message}');
      _showError(e.message);
    } catch (e) {
      debugPrint('Profile picture error: $e');
      _showError('Unable to update profile picture.'.tr);
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  // CLEAR PROFILE PICTURE

  Future<void> clearProfilePicture() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      _showError('No logged-in account found.'.tr);
      return;
    }

    try {
      isUpdatingProfile.value = true;

      final metadata =
          Map<String, dynamic>.from(user.userMetadata ?? {});

      metadata.remove('avatar_url');

      await _supabase.auth.updateUser(
        UserAttributes(data: metadata),
      );

      profilePictureUrl.value = '';

      Get.snackbar(
        'Profile Picture Removed'.tr,
        'Your profile picture has been cleared.'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      debugPrint('Clear profile picture error: $e');
      _showError('Unable to clear profile picture.'.tr);
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  // LOAD SETTINGS

  Future<void> loadSettings() async {
    isDarkMode.value =
        settingsBox.get(AppKeys.isDarkModeKey, defaultValue: false) as bool;

    final savedLanguage =
        settingsBox.get('app_language', defaultValue: 'en').toString();

    selectedLanguage.value = supportedLanguages.contains(savedLanguage)
        ? savedLanguage
        : 'en';

    await Get.updateLocale(Locale(selectedLanguage.value));

    await loadCurrencySettings();

    notificationsEnabled.value =
        settingsBox.get('notifications_enabled', defaultValue: true) as bool;

    hideAmounts.value =
        settingsBox.get('hide_amounts', defaultValue: true) as bool;

    transactionSound.value =
        settingsBox.get(AppKeys.transactionSoundKey, defaultValue: true)
            as bool;
  }

  // DARK MODE

  Future<void> toggleDarkMode(bool value) async {
    isDarkMode.value = value;

    await settingsBox.put(AppKeys.isDarkModeKey, value);

    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  // CURRENCY

  static const List<String> defaultCurrencies = [
    'PKR',
    'USD',
    'EUR',
    'GBP',
  ];

  Future<void> loadCurrencySettings() async {
    final savedCurrency = settingsBox.get(
      'currency',
      defaultValue: 'PKR',
    );

    final savedCurrencies = settingsBox.get(
      'custom_currencies',
      defaultValue: <String>[],
    );

    final currencies = <String>[];

    if (savedCurrencies is List) {
      for (final item in savedCurrencies) {
        final currency = item.toString().trim().toUpperCase();

        if (currency.isEmpty) {
          continue;
        }

        if (!currencies.contains(currency) &&
            !defaultCurrencies.contains(currency)) {
          currencies.add(currency);
        }
      }
    }

    customCurrencies.assignAll(currencies);

    final currency = savedCurrency.toString().trim().toUpperCase();

    if (currency.isEmpty) {
      selectedCurrency.value = 'PKR';
      await settingsBox.put('currency', 'PKR');
    } else {
      selectedCurrency.value = currency;
    }

    await settingsBox.put(
      'custom_currencies',
      customCurrencies.toList(),
    );
  }

  /// Enables/disables the transaction confirmation sound.
  Future<void> toggleTransactionSound(bool value) async {
    transactionSound.value = value;

    await settingsBox.put(AppKeys.transactionSoundKey, value);

    await SoundService.instance.setEnabled(value);

    // A quick play so the user hears what they just switched on.
    if (value) {
      await SoundService.instance.playSuccess();
    }
  }

  /// Flips the balance card between real figures and dots.
  Future<void> toggleHideAmounts() async {
    hideAmounts.value = !hideAmounts.value;

    await settingsBox.put('hide_amounts', hideAmounts.value);
  }

  Future<void> changeCurrency(String currency) async {
    final code = currency.trim().toUpperCase();

    if (code.isEmpty) {
      return;
    }

    selectedCurrency.value = code;

    await settingsBox.put('currency', code);
  }

  // LANGUAGE

  Future<void> changeLanguage(String languageCode) async {
    final code = languageCode.trim().toLowerCase();

    if (!supportedLanguages.contains(code)) {
      return;
    }

    selectedLanguage.value = code;

    await settingsBox.put('app_language', code);

    await Get.updateLocale(Locale(code));
  }

  // CUSTOM CURRENCY

  Future<void> addCustomCurrency(String currency) async {
    final code = currency.trim().toUpperCase();

    if (code.isEmpty) {
      return;
    }

    if (defaultCurrencies.contains(code)) {
      await changeCurrency(code);
      return;
    }

    final alreadyExists = customCurrencies.any(
      (item) => item.toUpperCase() == code,
    );

    if (!alreadyExists) {
      customCurrencies.add(code);

      await settingsBox.put(
        'custom_currencies',
        customCurrencies.toList(),
      );
    }

    await changeCurrency(code);
  }

  Future<void> deleteCustomCurrency(String currency) async {
    final code = currency.trim().toUpperCase();

    if (code.isEmpty) {
      return;
    }

    if (defaultCurrencies.contains(code)) {
      return;
    }

    customCurrencies.removeWhere(
      (item) => item.toUpperCase() == code,
    );

    await settingsBox.put(
      'custom_currencies',
      customCurrencies.toList(),
    );

    if (selectedCurrency.value.toUpperCase() == code) {
      await changeCurrency('PKR');
    }
  }

  // NOTIFICATIONS

  Future<void> toggleNotifications(bool value) async {
    notificationsEnabled.value = value;

    await settingsBox.put('notifications_enabled', value);

    if (!value) {
      try {
        await notificationService.cancelAllNotifications();
      } catch (e) {
        debugPrint('Notification cleanup error: $e');
      }
    }
  }

  // LOGOUT

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();

      Get.offAllNamed(AppRoutes.login);

      Get.snackbar(
        'Logged Out'.tr,
        'You have been logged out successfully.'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Unable to logout. Please try again.'.tr);
    }
  }

  // DELETE ACCOUNT

  Future<void> deleteAccount() async {
    if (isDeletingAccount.value) {
      return;
    }

    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        _showError('No logged-in account found.'.tr);
        return;
      }

      isDeletingAccount.value = true;

      final response =
          await _supabase.functions.invoke('delete-account');

      if (response.status != 200) {
        String errorMessage = 'Unable to delete account.'.tr;

        if (response.data is Map &&
            response.data['error'] != null) {
          errorMessage = response.data['error'].toString();
        }

        throw Exception(errorMessage);
      }

      await settingsBox.clear();

      try {
        await notificationService.cancelAllNotifications();
      } catch (e) {
        debugPrint('Notification cleanup error: $e');
      }

      await _supabase.auth.signOut();

      Get.offAllNamed(AppRoutes.login);

      Get.snackbar(
        'Account Deleted'.tr,
        'Your ExpenseMate account has been permanently deleted.'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      debugPrint('Delete account exception: $e');
      _showError('Unable to delete account. Please try again.'.tr);
    } finally {
      isDeletingAccount.value = false;
    }
  }

  // ERROR

  void _showError(String message) {
    Get.snackbar(
      'Error'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // CLOSE

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }
}
