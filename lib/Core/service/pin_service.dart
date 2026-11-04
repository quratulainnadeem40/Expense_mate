import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_keys.dart';

/// Keeps the app lock PIN.
///
/// The PIN itself is never written down. Only a salted hash is stored,
/// so reading the database gives nothing away.
class PinService {
  PinService._();

  static final PinService instance = PinService._();

  static const String _hashKey = 'app_pin_hash';
  static const String _saltKey = 'app_pin_salt';
  static const String _setAtKey = 'app_pin_set_at';
  static const String _failsKey = 'app_pin_fails';
  static const String _lockedUntilKey = 'app_pin_locked_until';

  /// How long the app stays unlocked after being sent to the background.
  ///
  /// Without this, glancing at a notification would mean typing the PIN
  /// again, which people quickly start to hate.
  static const Duration gracePeriod = Duration(minutes: 2);

  /// Wrong attempts before the keypad is held shut for a while.
  static const int maxAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 1);

  /// True while the app should be showing the lock screen.
  bool isLocked = false;

  Box? get _box => Hive.isBoxOpen(AppKeys.settingsBox)
      ? Hive.box(AppKeys.settingsBox)
      : null;

  bool get isPinSet => (_box?.get(_hashKey) as String?)?.isNotEmpty ?? false;

  // ================================================================
  // HASHING
  // ================================================================

  String _newSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  String _hash(String pin, String salt) =>
      sha256.convert(utf8.encode('$salt:$pin')).toString();

  // ================================================================
  // SET / CHANGE / CLEAR
  // ================================================================

  Future<void> setPin(String pin) async {
    final box = _box;
    if (box == null) return;

    final salt = _newSalt();

    await box.put(_saltKey, salt);
    await box.put(_hashKey, _hash(pin, salt));
    await box.put(_setAtKey, DateTime.now().toIso8601String());

    await _clearFailures();
    isLocked = false;
  }
Future<bool> hasPinOnServer() async {
  try {
    final response = await Supabase.instance.client.functions.invoke(
      'pin-status',
    );

    if (response.status != 200) {
      throw Exception('Unable to check PIN status');
    }

    final data = response.data;

    return data['hasPin'] == true;
  } catch (e) {
    print('PIN STATUS ERROR: $e');
    rethrow;
  }
}
Future<void> savePinToServer(String pin) async {
  try {
    final response = await Supabase.instance.client.functions.invoke(
      'set-pin',
      body: {'pin': pin},
    );

    if (response.status != 200) {
      throw Exception(
        response.data?['error'] ?? 'Unable to save PIN',
      );
    }
  } catch (e) {
    print('SAVE PIN ERROR: $e');
    rethrow;
  }
}
Future<Map<String, dynamic>> verifyPinOnServer(String pin) async {
  try {
    final response = await Supabase.instance.client.functions.invoke(
      'verify-pin',
      body: {'pin': pin},
    );

    return Map<String, dynamic>.from(response.data);
  } on FunctionException catch (e) {
    if (e.status == 401 || e.status == 429) {
      return Map<String, dynamic>.from(e.details);
    }

    rethrow;
  }
}
  Future<void> clearPin() async {
    final box = _box;
    if (box == null) return;

    await box.delete(_hashKey);
    await box.delete(_saltKey);
    await box.delete(_setAtKey);

    await _clearFailures();
    isLocked = false;
  }

  bool verify(String pin) {
    final box = _box;
    if (box == null) return false;

    final salt = box.get(_saltKey) as String?;
    final stored = box.get(_hashKey) as String?;

    if (salt == null || stored == null) return false;

    return _hash(pin, salt) == stored;
  }

  // ================================================================
  // FAILED ATTEMPTS
  // ================================================================

  int get failedAttempts => (_box?.get(_failsKey) as int?) ?? 0;

  int get attemptsLeft {
    final left = maxAttempts - failedAttempts;
    return left < 0 ? 0 : left;
  }

  /// When the keypad is being held shut, otherwise null.
  DateTime? get lockedUntil {
    final raw = _box?.get(_lockedUntilKey) as String?;
    if (raw == null) return null;

    final until = DateTime.tryParse(raw);
    if (until == null || DateTime.now().isAfter(until)) return null;

    return until;
  }

  bool get isTemporarilyBlocked => lockedUntil != null;

  Future<void> recordFailure() async {
    final box = _box;
    if (box == null) return;

    final next = failedAttempts + 1;
    await box.put(_failsKey, next);

    // Slows down someone trying every combination by hand.
    if (next >= maxAttempts) {
      await box.put(
        _lockedUntilKey,
        DateTime.now().add(lockoutDuration).toIso8601String(),
      );
      await box.put(_failsKey, 0);
    }
  }

  Future<void> _clearFailures() async {
    final box = _box;
    if (box == null) return;

    await box.delete(_failsKey);
    await box.delete(_lockedUntilKey);
  }

  Future<void> recordSuccess() async {
    await _clearFailures();
    isLocked = false;
  }

  void lock() {
    if (!isPinSet) return;
    isLocked = true;
  }
}
