import '../../../Core/service/biometric_service.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../Core/routes/app_routes.dart';
import '../../../Core/service/pin_service.dart';
import '../widgets/pin_keypad.dart';

/// Asked for every time the app opens while a PIN is set.
class PinLockView extends StatefulWidget {
  const PinLockView({super.key});

  static const String argNextRoute = 'nextRoute';

  @override
  State<PinLockView> createState() => _PinLockViewState();
}

class _PinLockViewState extends State<PinLockView> {
  static const int _length = 4;

  final SupabaseClient _supabase = Supabase.instance.client;

  String _entry = '';
  String? _error;

  Timer? _tick;
  Duration _blockedFor = Duration.zero;

  bool _biometricReady = false;
  String _biometricLabel = 'Fingerprint';

  @override
  void initState() {
    super.initState();
    _watchLockout();
    _setUpBiometric();
  }

  Future<void> _setUpBiometric() async {
    final service = BiometricService.instance;

    if (!service.isEnabled) return;
    if (!await service.isAvailable()) return;
    if (!await service.hasEnrolled()) return;

    final label = await service.label();
    if (!mounted) return;

    setState(() {
      _biometricReady = true;
      _biometricLabel = label;
    });

    // Offered straight away, so the usual case is one touch and in.
    // The keypad stays underneath for when it is refused.
    _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    if (!_biometricReady || _isBlocked) return;

    final ok = await BiometricService.instance.authenticate();
    if (!ok || !mounted) return;

    await PinService.instance.recordSuccess();
    _goOn();
  }

  void _goOn() {
    final args = Get.arguments;
    final next = args is Map ? args[PinLockView.argNextRoute] as String? : null;

    Get.offAllNamed(next ?? AppRoutes.home);
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  /// Counts down while the keypad is held shut after too many tries.
  void _watchLockout() {
    _tick?.cancel();

    _tick = Timer.periodic(const Duration(seconds: 1), (timer) {
      final until = PinService.instance.lockedUntil;

      if (until == null) {
        if (_blockedFor != Duration.zero) {
          setState(() => _blockedFor = Duration.zero);
        }
        return;
      }

      setState(() => _blockedFor = until.difference(DateTime.now()));
    });

    final until = PinService.instance.lockedUntil;
    if (until != null) {
      _blockedFor = until.difference(DateTime.now());
    }
  }

  bool get _isBlocked => PinService.instance.isTemporarilyBlocked;

  void _onDigit(String d) {
    if (_isBlocked || _entry.length >= _length) return;

    setState(() {
      _entry += d;
      _error = null;
    });

    if (_entry.length == _length) _check();
  }

  void _onBackspace() {
    if (_entry.isEmpty) return;
    setState(() => _entry = _entry.substring(0, _entry.length - 1));
  }

  Future<void> _check() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;

    if (PinService.instance.verify(_entry)) {
      await PinService.instance.recordSuccess();
      _goOn();
      return;
    }

    await PinService.instance.recordFailure();
    if (!mounted) return;

    final left = PinService.instance.attemptsLeft;

    setState(() {
      _entry = '';
      _error = PinService.instance.isTemporarilyBlocked
          ? 'Too many tries. Wait a moment.'
          : 'Wrong PIN. $left ${left == 1 ? 'try' : 'tries'} left.';
    });

    _watchLockout();
  }

  // ================================================================
  // FORGOT PIN
  // ================================================================

  /// The PIN cannot be looked up, because only its hash is stored. So
  /// the way back in is the account password, which is checked against
  /// the server. Signing in again proves it is the right person, and a
  /// new PIN can then be set.
  void _forgotPin() {
    final passwordController = TextEditingController();
    final error = RxnString();
    final busy = false.obs;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final email = _supabase.auth.currentUser?.email ?? '';

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Forgot your PIN?',
          style: TextStyle(
            fontSize: 17.5,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              email.isEmpty
                  ? 'Enter your account password to set a new PIN.'
                  : 'Enter the password for $email to set a new PIN.',
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: isDark ? Colors.white70 : const Color(0xFF4B5563),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: passwordController,
              obscureText: true,
              autofocus: true,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Account password',
                filled: true,
                fillColor: isDark
                    ? Colors.white10
                    : Colors.black.withOpacity(0.04),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kPinGreen, width: 1.4),
                ),
              ),
            ),
            Obx(() {
              if (error.value == null) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(top: 9),
                child: Text(
                  error.value!,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFFE53935),
                  ),
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          Obx(() {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPinGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: busy.value
                  ? null
                  : () async {
                      final password = passwordController.text.trim();

                      if (password.isEmpty) {
                        error.value = 'Please enter your password.';
                        return;
                      }

                      if (email.isEmpty) {
                        error.value = 'No account signed in on this phone.';
                        return;
                      }

                      busy.value = true;

                      try {
                        await _supabase.auth.signInWithPassword(
                          email: email,
                          password: password,
                        );

                        await PinService.instance.clearPin();

                        Get.back();
                        Get.offAllNamed(AppRoutes.pinSetup);
                      } on AuthException catch (e) {
                        error.value = e.message;
                      } catch (_) {
                        error.value = 'Could not check that. Try again.';
                      } finally {
                        busy.value = false;
                      }
                    },
              child: busy.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Continue'),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark ? Colors.white : const Color(0xFF1C1C1C);
    final secondaryText = isDark ? Colors.white70 : const Color(0xFF6B7280);

    final seconds = _blockedFor.inSeconds;

    return PopScope(
      // Back must not slip past the lock screen.
      canPop: false,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF101010) : Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: kPinGreen.withOpacity(isDark ? 0.18 : 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 34,
                  color: kPinGreen,
                ),
              ),

              const SizedBox(height: 22),

              Text(
                'Enter your PIN',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: primaryText,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                _isBlocked && seconds > 0
                    ? 'Try again in $seconds '
                          '${seconds == 1 ? 'second' : 'seconds'}'
                    : 'Expense Mate is locked',
                style: TextStyle(fontSize: 13.5, color: secondaryText),
              ),

              const SizedBox(height: 28),

              PinDots(
                filled: _entry.length,
                length: _length,
                isError: _error != null,
              ),

              SizedBox(
                height: 30,
                child: _error == null
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFFE53935),
                          ),
                        ),
                      ),
              ),

              if (_biometricReady && !_isBlocked)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: TextButton.icon(
                    onPressed: _tryBiometric,
                    icon: const Icon(
                      Icons.fingerprint_rounded,
                      size: 21,
                      color: kPinGreen,
                    ),
                    label: Text(
                      'Use $_biometricLabel',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kPinGreen,
                      ),
                    ),
                  ),
                ),

              const Spacer(),

              PinKeypad(
                enabled: !_isBlocked,
                onDigit: _onDigit,
                onBackspace: _onBackspace,
                onAction: _forgotPin,
                actionIcon: Icons.help_outline_rounded,
                actionLabel: 'Forgot',
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
