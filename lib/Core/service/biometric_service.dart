import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_keys.dart';
import 'pin_service.dart';

/// Fingerprint or face unlock, sitting on top of the PIN.
///
/// PIN and biometric settings are independent of notification settings.
class BiometricService {
  BiometricService._();

  static final BiometricService instance = BiometricService._();

  static const String _enabledKey = 'biometric_enabled';

  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool>? _availabilityFuture;

Future<bool> get availabilityFuture {
  return _availabilityFuture ??= isAvailable();
}

  // Reactive fingerprint state.
  final RxBool isEnabledRx = false.obs;

  Box? get _box => Hive.isBoxOpen(AppKeys.settingsBox)
      ? Hive.box(AppKeys.settingsBox)
      : null;

  /// Refresh fingerprint state from its own Hive key.
void refreshEnabledState() {
  final box = _box;

  // Box available nahi hai to existing state change na karein.
  if (box == null) return;

  final savedValue =
      (box.get(_enabledKey, defaultValue: false) as bool?) ?? false;

  isEnabledRx.value = PinService.instance.isPinSet && savedValue;
}

  /// Whether the phone has a usable fingerprint or face sensor.
  Future<bool> isAvailable() async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return false;

      return await _auth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  /// Whether anything is actually enrolled.
  Future<bool> hasEnrolled() async {
    try {
      final types = await _auth.getAvailableBiometrics();
      return types.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  /// What to call it on screen.
  Future<String> label() async {
    try {
      final types = await _auth.getAvailableBiometrics();

      if (types.contains(BiometricType.face)) return 'Face unlock';
      if (types.contains(BiometricType.fingerprint)) return 'Fingerprint';
      if (types.contains(BiometricType.iris)) return 'Iris';

      return 'Biometric unlock';
    } on PlatformException {
      return 'Biometric unlock';
    }
  }

  /// Whether fingerprint unlock is enabled.
  ///
  /// This setting is independent of bill notifications.
  bool get isEnabled {
    refreshEnabledState();
    return isEnabledRx.value;
  }

  /// Enable or disable fingerprint without changing notifications.
 Future<bool> setEnabled(bool value) async {
  try {
    if (value && !PinService.instance.isPinSet) {
      isEnabledRx.value = false;
      return false;
    }

    if (value) {
      final available = await isAvailable();
      final enrolled = await hasEnrolled();

      if (!available || !enrolled) {
        return false;
      }
    }

    final box = await Hive.openBox(AppKeys.settingsBox);

    await box.put(_enabledKey, value);
    debugPrint(
  'NOTIFICATION VALUE: '
  '${box.get('notifications_enabled')}',
);

debugPrint(
  'BIOMETRIC VALUE: '
  '${box.get('biometric_enabled')}',
);

    isEnabledRx.value = value;

    debugPrint('BIOMETRIC SETTING SAVED: $value');

    return true;
  } catch (e) {
    debugPrint('BIOMETRIC SETTING ERROR: $e');
    return false;
  }
}

  /// Shows the system prompt.
  ///
  /// PIN remains available as a fallback.
  Future<bool> authenticate({
    String reason = 'Unlock Expense Mate',
  }) async {
    if (!isEnabled) return false;

    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}