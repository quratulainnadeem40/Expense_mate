import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';

import '../constants/app_keys.dart';
import 'pin_service.dart';

/// Fingerprint or face unlock, sitting on top of the PIN.
///
/// The PIN is always the fallback: biometrics can fail for wet hands, a
/// cut finger, or a sensor that stops working, so there is never a state
/// where the only way in is a fingerprint.
class BiometricService {
  BiometricService._();

  static final BiometricService instance = BiometricService._();

  static const String _enabledKey = 'biometric_enabled';

  final LocalAuthentication _auth = LocalAuthentication();

  Box? get _box =>
      Hive.isBoxOpen(AppKeys.settingsBox) ? Hive.box(AppKeys.settingsBox) : null;

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

  /// Whether anything is actually enrolled. A phone can have a sensor
  /// with no fingerprint registered, and prompting then is pointless.
  Future<bool> hasEnrolled() async {
    try {
      final types = await _auth.getAvailableBiometrics();
      return types.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  /// What to call it on screen, since it differs by phone.
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

  /// Turned on by the user, and only meaningful while a PIN exists.
  bool get isEnabled {
    if (!PinService.instance.isPinSet) return false;
    return (_box?.get(_enabledKey, defaultValue: false) as bool?) ?? false;
  }

  Future<void> setEnabled(bool value) async {
    await _box?.put(_enabledKey, value);
  }

  /// Shows the system prompt.
  ///
  /// Returns false on any refusal or error, which simply leaves the PIN
  /// keypad on screen.
  Future<bool> authenticate({String reason = 'Unlock Expense Mate'}) async {
    if (!isEnabled) return false;

    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          // The PIN screen is already behind this, so the system's own
          // device-credential fallback would just be a second lock.
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
