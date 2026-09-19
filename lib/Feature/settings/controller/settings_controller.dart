import 'dart:async';

import 'package:expense_mate/Core/constants/app_keys.dart';
import 'package:expense_mate/Core/routes/app_routes.dart';
import 'package:expense_mate/Core/service/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsController extends GetxController {
  StreamSubscription<AuthState>? _authSubscription;

  // ============================================================
  // SETTINGS
  // ============================================================

  late Box settingsBox;

  final isDarkMode = false.obs;
  final selectedCurrency = 'PKR'.obs;
  final notificationsEnabled = true.obs;

  // ============================================================
  // ACCOUNT
  // ============================================================

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

  // Prevent multiple profile requests at the same time.
  bool _isLoadingProfile = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    settingsBox = Hive.box(AppKeys.settingsBox);

    loadSettings();

    // ----------------------------------------------------------
    // Load profile once if a session already exists.
    // ----------------------------------------------------------

    if (_supabase.auth.currentSession != null) {
      loadProfile();
    }

    // ----------------------------------------------------------
    // Listen ONLY for real login/logout events.
    //
    // Do NOT call loadProfile() for tokenRefreshed or
    // userUpdated. That can create repeated requests and
    // eventually cause Supabase 429 rate-limit errors.
    // ----------------------------------------------------------

    _authSubscription =
        _supabase.auth.onAuthStateChange.listen((authState) {
      final event = authState.event;
      final session = authState.session;

      debugPrint(
        'AUTH EVENT: $event | SESSION: ${session != null}',
      );

      // User logged in.
      if (event == AuthChangeEvent.signedIn) {
        if (session?.user != null) {
          loadProfile();
        }
      }

      // User logged out.
      if (event == AuthChangeEvent.signedOut) {
        profileName.value = '';
        profileEmail.value = '';
        profilePictureUrl.value = '';
      }
    });
  }

  // ============================================================
  // CURRENT USER
  // ============================================================

  User? get currentUser => _supabase.auth.currentUser;

  // ============================================================
  // LOAD PROFILE
  // ============================================================

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
      // --------------------------------------------------------
      // AUTH DATA
      // --------------------------------------------------------

      final metadata = user.userMetadata ?? {};

      final authName =
          metadata['name']?.toString().trim() ?? '';

      final authEmail =
          user.email?.trim() ?? '';

      final authAvatar =
          metadata['avatar_url']?.toString().trim() ?? '';

      // --------------------------------------------------------
      // PROFILE TABLE DATA
      // --------------------------------------------------------

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
        debugPrint(
          'Profiles table error: ${e.message}',
        );
      }

      // --------------------------------------------------------
      // SELECT PROFILE VALUES
      // --------------------------------------------------------

      final finalName = authName.isNotEmpty
          ? authName
          : databaseName.isNotEmpty
              ? databaseName
              : 'User';

      final finalEmail = authEmail.isNotEmpty
          ? authEmail
          : databaseEmail.isNotEmpty
              ? databaseEmail
              : 'No Email';

      // --------------------------------------------------------
      // UPDATE CONTROLLER
      // --------------------------------------------------------

      profileName.value = finalName;
      profileEmail.value = finalEmail;
      profilePictureUrl.value = authAvatar;

      // --------------------------------------------------------
      // DEBUG
      // --------------------------------------------------------

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
      debugPrint(
        'Auth profile error: ${e.message}',
      );
    } catch (e) {
      debugPrint(
        'Load profile error: $e',
      );
    } finally {
      _isLoadingProfile = false;
    }
  }

  // ============================================================
  // UPDATE PROFILE
  // ============================================================

 // ============================================================
// UPDATE PROFILE
// ============================================================

// ============================================================
// UPDATE PROFILE
// ============================================================

Future<void> updateProfile({
  required String name,
  String? email,
  String? password,
}) async {
  final newName = name.trim();
  final newEmail = email?.trim() ?? '';
  final newPassword = password?.trim();

  // ----------------------------------------------------------
  // VALIDATION
  // ----------------------------------------------------------

  if (newName.isEmpty) {
    _showError('Please enter your name.');
    return;
  }

  if (newPassword != null &&
      newPassword.isNotEmpty &&
      newPassword.length < 6) {
    _showError('Password must be at least 6 characters.');
    return;
  }

  try {
    isUpdatingProfile.value = true;

    // --------------------------------------------------------
    // GET CURRENT AUTH USER
    // --------------------------------------------------------

    final session = _supabase.auth.currentSession;
    final user = session?.user;

    if (user == null) {
      debugPrint('SESSION IS NULL');
      debugPrint(
        'CURRENT USER: ${_supabase.auth.currentUser}',
      );

      _showError('No logged-in account found.');
      return;
    }

    debugPrint('================================');
    debugPrint('PROFILE UPDATE START');
    debugPrint('USER ID: ${user.id}');
    debugPrint('CURRENT AUTH EMAIL: ${user.email}');
    debugPrint('NEW EMAIL FROM TEXT FIELD: $newEmail');
    debugPrint('================================');

    // --------------------------------------------------------
    // CURRENT VALUES
    // --------------------------------------------------------

    final currentName =
        user.userMetadata?['name']?.toString().trim() ?? '';

    final currentEmail =
        user.email?.trim() ?? '';

    final finalEmail =
        newEmail.isEmpty ? currentEmail : newEmail;

    final nameChanged =
        newName != currentName;

    final emailChanged =
        finalEmail != currentEmail;

    final passwordChanged =
        newPassword != null &&
        newPassword.isNotEmpty;

    // --------------------------------------------------------
    // NOTHING CHANGED
    // --------------------------------------------------------

    if (!nameChanged &&
        !emailChanged &&
        !passwordChanged) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      Get.snackbar(
        'No Changes',
        'There are no changes to save.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    // ========================================================
    // 1. UPDATE EMAIL IN SUPABASE AUTH
    // ========================================================

    if (emailChanged) {
      debugPrint('================================');
      debugPrint('UPDATING AUTH EMAIL');
      debugPrint('OLD EMAIL: $currentEmail');
      debugPrint('NEW EMAIL: $finalEmail');
      debugPrint('================================');

      final authResponse =
          await _supabase.auth.updateUser(
        UserAttributes(
          email: finalEmail,
        ),
      );

      // ------------------------------------------------------
      // GET THE USER AFTER EMAIL UPDATE
      // ------------------------------------------------------

      final updatedUser = authResponse.user;

      debugPrint('================================');
      debugPrint('AFTER AUTH EMAIL UPDATE');
      debugPrint(
        'AUTH EMAIL: ${updatedUser?.email}',
      );
      debugPrint(
        'USER ID: ${updatedUser?.id}',
      );
      debugPrint('================================');

      // ------------------------------------------------------
      // IMPORTANT:
      // Only continue if Supabase Auth actually accepted
      // the new email.
      // ------------------------------------------------------

      final authEmailAfterUpdate =
          updatedUser?.email?.trim() ?? '';

      if (authEmailAfterUpdate != finalEmail) {
  debugPrint('EMAIL CHANGE IS PENDING CONFIRMATION');

  if (Get.isDialogOpen == true) {
    Get.back();
  }

  Get.snackbar(
    'Confirmation Required',
    'A confirmation email has been sent to your new email address. '
    'Please confirm it before the email change becomes active.',
    snackPosition: SnackPosition.BOTTOM,
    duration: const Duration(seconds: 6),
  );

  return;
}
    }

    // ========================================================
    // 2. UPDATE PASSWORD IN SUPABASE AUTH
    // ========================================================

    if (passwordChanged) {
      debugPrint('UPDATING AUTH PASSWORD');

      await _supabase.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );
    }

    // ========================================================
    // 3. UPDATE NAME IN SUPABASE AUTH
    // ========================================================

    if (nameChanged) {
      debugPrint('UPDATING AUTH NAME');

      final metadata = Map<String, dynamic>.from(
        user.userMetadata ?? {},
      );

      metadata['name'] = newName;

      await _supabase.auth.updateUser(
        UserAttributes(
          data: metadata,
        ),
      );
    }

    // ========================================================
    // 4. UPDATE PROFILES TABLE
    // ========================================================

    final profileData = <String, dynamic>{
      'name': newName,
    };

    if (emailChanged) {
      profileData['email'] = finalEmail;
    }

    debugPrint('UPDATING PROFILES TABLE');
    debugPrint('PROFILE DATA: $profileData');

    await _supabase
        .from('profiles')
        .update(profileData)
        .eq('id', user.id);

    // ========================================================
    // 5. REFRESH AUTH SESSION
    // ========================================================

    try {
      await _supabase.auth.refreshSession();
    } catch (e) {
      debugPrint(
        'Session refresh warning: $e',
      );
    }

    // ========================================================
    // 6. GET FINAL AUTH USER
    // ========================================================

    final finalUser =
        _supabase.auth.currentUser;

    final verifiedEmail =
        finalUser?.email?.trim() ?? '';

    debugPrint('================================');
    debugPrint('FINAL PROFILE UPDATE RESULT');
    debugPrint('AUTH USER ID: ${finalUser?.id}');
    debugPrint('FINAL AUTH EMAIL: $verifiedEmail');
    debugPrint('FINAL PROFILE EMAIL: $finalEmail');
    debugPrint('================================');

    // ========================================================
    // 7. UPDATE LOCAL UI
    // ========================================================

    profileName.value = newName;

    if (emailChanged) {
      profileEmail.value = verifiedEmail.isNotEmpty
          ? verifiedEmail
          : finalEmail;
    } else {
      profileEmail.value = currentEmail;
    }

    // ========================================================
    // 8. CLOSE DIALOG
    // ========================================================

    if (Get.isDialogOpen == true) {
      Get.back();
    }

    // ========================================================
    // 9. SUCCESS MESSAGE
    // ========================================================

    if (nameChanged && emailChanged) {
      Get.snackbar(
        'Profile Updated',
        'Name and email updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else if (nameChanged) {
      Get.snackbar(
        'Profile Updated',
        'Name updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else if (emailChanged) {
      Get.snackbar(
        'Profile Updated',
        'Email updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else if (passwordChanged) {
      Get.snackbar(
        'Profile Updated',
        'Password updated successfully.',
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

    _showError(
      '${e.message} (Code: ${e.code})',
    );
  } on PostgrestException catch (e) {
    debugPrint('================================');
    debugPrint('PROFILE TABLE UPDATE ERROR');
    debugPrint('Message: ${e.message}');
    debugPrint('Code: ${e.code}');
    debugPrint('================================');

    _showError(
      'Profile database update failed.',
    );
  } catch (e) {
    debugPrint('================================');
    debugPrint('PROFILE UPDATE ERROR');
    debugPrint('Error: $e');
    debugPrint('================================');

    _showError(
      'Unable to update profile. Please try again.',
    );
  } finally {
    isUpdatingProfile.value = false;
  }
}
 // ============================================================
  // UPDATE NAME ONLY
  // ============================================================

  Future<void> updateName(String name) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      _showError('Please enter your name.');
      return;
    }

    try {
      isUpdatingProfile.value = true;

      // --------------------------------------------------------
      // GET CURRENT AUTHENTICATED USER
      // --------------------------------------------------------

      final session = _supabase.auth.currentSession;
      final user = session?.user;

      if (user == null) {
        debugPrint('SESSION IS NULL');
        debugPrint(
          'CURRENT USER: ${_supabase.auth.currentUser}',
        );

        _showError('No logged-in account found.');
        return;
      }

      debugPrint('LOGGED IN USER ID: ${user.id}');
      debugPrint('LOGGED IN EMAIL: ${user.email}');

      // --------------------------------------------------------
      // UPDATE USER METADATA
      // --------------------------------------------------------

      final metadata = Map<String, dynamic>.from(
        user.userMetadata ?? {},
      );

      metadata['name'] = trimmedName;

      await _supabase.auth.updateUser(
        UserAttributes(
          data: metadata,
        ),
      );

      // --------------------------------------------------------
      // UPDATE LOCAL UI
      // --------------------------------------------------------

      profileName.value = trimmedName;

      // --------------------------------------------------------
      // UPDATE PROFILES TABLE
      // --------------------------------------------------------

      await _supabase
          .from('profiles')
          .update({
            'name': trimmedName,
          })
          .eq('id', user.id);

      // --------------------------------------------------------
      // SUCCESS
      // --------------------------------------------------------

      Get.snackbar(
        'Success',
        'Name updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on AuthException catch (e) {
      debugPrint(
        'Update name auth error: ${e.message}',
      );

      _showError(e.message);
    } catch (e) {
      debugPrint(
        'Update name error: $e',
      );

      _showError(
        'Unable to update name.',
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
      final XFile? pickedImage =
          await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedImage == null) {
        return;
      }

      final user = _supabase.auth.currentUser;

      if (user == null) {
        _showError('No logged-in account found.');
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

      final metadata = Map<String, dynamic>.from(
        user.userMetadata ?? {},
      );

      metadata['avatar_url'] = imageUrl;

      await _supabase.auth.updateUser(
        UserAttributes(
          data: metadata,
        ),
      );

      profilePictureUrl.value = imageUrl;

      Get.snackbar(
        'Success',
        'Profile picture updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on StorageException catch (e) {
      debugPrint(
        'Storage error: ${e.message}',
      );

      _showError(e.message);
    } on AuthException catch (e) {
      debugPrint(
        'Auth error: ${e.message}',
      );

      _showError(e.message);
    } catch (e) {
      debugPrint(
        'Profile picture error: $e',
      );

      _showError(
        'Unable to update profile picture.',
      );
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  // ============================================================
  // CLEAR PROFILE PICTURE
  // ============================================================

  Future<void> clearProfilePicture() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      _showError('No logged-in account found.');
      return;
    }

    try {
      isUpdatingProfile.value = true;

      final metadata = Map<String, dynamic>.from(
        user.userMetadata ?? {},
      );

      metadata.remove('avatar_url');

      await _supabase.auth.updateUser(
        UserAttributes(
          data: metadata,
        ),
      );

      profilePictureUrl.value = '';

      Get.snackbar(
        'Profile Picture Removed',
        'Your profile picture has been cleared.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      debugPrint(
        'Clear profile picture error: $e',
      );

      _showError(
        'Unable to clear profile picture.',
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
      _showError(e.message);
    } catch (e) {
      _showError(
        'Unable to logout. Please try again.',
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
        _showError('No logged-in account found.');
        return;
      }

      isDeletingAccount.value = true;

      final response =
          await _supabase.functions.invoke(
        'delete-account',
      );

      if (response.status != 200) {
        String errorMessage =
            'Unable to delete account.';

        if (response.data is Map &&
            response.data['error'] != null) {
          errorMessage =
              response.data['error'].toString();
        }

        throw Exception(errorMessage);
      }

      await settingsBox.clear();

      try {
        await notificationService
            .cancelAllNotifications();
      } catch (e) {
        debugPrint(
          'Notification cleanup error: $e',
        );
      }

      await _supabase.auth.signOut();

      Get.offAllNamed(AppRoutes.login);

      Get.snackbar(
        'Account Deleted',
        'Your ExpenseMate account has been permanently deleted.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      debugPrint(
        'Delete account exception: $e',
      );

      _showError(
        'Unable to delete account. Please try again.',
      );
    } finally {
      isDeletingAccount.value = false;
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // ============================================================
  // CLOSE
  // ============================================================

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }
}