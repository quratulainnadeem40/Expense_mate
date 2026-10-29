import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Tells the server about sign-ins and failed unlock attempts, so it can
/// email the account owner.
///
/// The app never sends mail itself. Doing that would mean shipping an
/// API key or SMTP password inside the APK, where anyone could pull it
/// out and send mail in your name. Here the app only reports what
/// happened; the key lives on Supabase.
class SecurityAlertService {
  SecurityAlertService._();

  static final SecurityAlertService instance = SecurityAlertService._();

  static const String _functionName = 'send-security-alert';

  SupabaseClient get _supabase => Supabase.instance.client;

  /// Rough description of the phone, so the email can say where it
  /// happened. No identifiers are collected beyond this.
  Future<String> _deviceLabel() async {
    if (kIsWeb) return 'Web browser';

    try {
      if (Platform.isAndroid) return 'Android phone';
      if (Platform.isIOS) return 'iPhone';
      if (Platform.isWindows) return 'Windows PC';
      if (Platform.isMacOS) return 'Mac';
      return Platform.operatingSystem;
    } catch (_) {
      return 'Unknown device';
    }
  }

  Future<void> _send(String event, Map<String, dynamic> extra) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final body = <String, dynamic>{
      'event': event,
      'email': user.email,
      'user_id': user.id,
      'device': await _deviceLabel(),
      'at': DateTime.now().toUtc().toIso8601String(),
      ...extra,
    };

    try {
      await _supabase.functions.invoke(_functionName, body: body);
    } catch (e) {
      // An alert that cannot be sent must never block signing in or
      // unlocking. It is a notification, not a gate.
      debugPrint('SECURITY ALERT NOT SENT: $e');
    }
  }

  /// Someone signed in with the account password.
  Future<void> loginSucceeded() => _send('login_success', const {});

  /// Enough wrong PINs in a row that the keypad was held shut.
  ///
  /// Deliberately not sent on every single wrong digit: a few mistypes
  /// are normal, and an email each time would train the user to ignore
  /// them.
  Future<void> pinLockout({required int attempts}) =>
      _send('pin_lockout', {'attempts': attempts});
}
