import '../../../Core/service/biometric_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Core/service/pin_service.dart';
import '../widgets/pin_keypad.dart';

/// Create a PIN, or change an existing one.
///
/// Pass `canSkip: true` when it is offered right after signing in, so a
/// user who does not want a lock is not trapped here.
class PinSetupView extends StatefulWidget {
  const PinSetupView({super.key});

  static const String argNextRoute = 'nextRoute';
  static const String argCanSkip = 'canSkip';

  @override
  State<PinSetupView> createState() => _PinSetupViewState();
}

class _PinSetupViewState extends State<PinSetupView> {
  static const int _length = 4;

  String _first = '';
  String _entry = '';
  String? _error;

  bool get _isConfirming => _first.isNotEmpty;

  bool get _canSkip {
    final args = Get.arguments;
    return args is Map && args[PinSetupView.argCanSkip] == true;
  }

  String? get _nextRoute {
    final args = Get.arguments;
    return args is Map ? args[PinSetupView.argNextRoute] as String? : null;
  }

  void _onDigit(String d) {
    if (_entry.length >= _length) return;

    setState(() {
      _entry += d;
      _error = null;
    });

    if (_entry.length == _length) _submit();
  }

  void _onBackspace() {
    if (_entry.isEmpty) return;
    setState(() => _entry = _entry.substring(0, _entry.length - 1));
  }

  Future<void> _submit() async {
    // Give the fourth dot a moment to appear before the screen changes.
    await Future<void>.delayed(const Duration(milliseconds: 140));
    if (!mounted) return;

    if (!_isConfirming) {
      // Four identical or straight digits are the first thing anyone
      // guesses, so they are refused here rather than later.
      if (_isTooSimple(_entry)) {
        setState(() {
          _error = 'Pick something harder to guess';
          _entry = '';
        });
        return;
      }

      setState(() {
        _first = _entry;
        _entry = '';
      });
      return;
    }

    if (_entry != _first) {
      setState(() {
        _error = 'The two PINs did not match';
        _first = '';
        _entry = '';
      });
      return;
    }

    await PinService.instance.setPin(_entry);

    // Asked right here, while the lock is on the user's mind. Doing it
    // later from Settings is something almost nobody goes looking for.
    await _offerBiometric();

    final next = _nextRoute;
    if (next != null) {
      Get.offAllNamed(next);
    } else {
      Get.back(result: true);
    }
  }

  Future<void> _offerBiometric() async {
    final service = BiometricService.instance;

    if (!await service.isAvailable()) return;
    if (!await service.hasEnrolled()) return;
    if (!mounted) return;

    final label = await service.label();
    if (!mounted) return;

    final useIt = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Use $label too?'),
        content: Text(
          'Unlock with $label instead of typing the PIN each time. '
          'Your PIN still works whenever it fails.',
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Not now'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPinGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Get.back(result: true),
            child: const Text('Turn on'),
          ),
        ],
      ),
    );

    if (useIt == true) await service.setEnabled(true);
  }

  bool _isTooSimple(String pin) {
    if (pin.split('').toSet().length == 1) return true;

    final digits = pin.split('').map(int.parse).toList();

    final ascending = List.generate(
      digits.length - 1,
      (i) => digits[i + 1] - digits[i],
    );

    if (ascending.every((d) => d == 1)) return true;
    if (ascending.every((d) => d == -1)) return true;

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark ? Colors.white : const Color(0xFF1C1C1C);
    final secondaryText = isDark ? Colors.white70 : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101010) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 52,
              child: Row(
                children: [
                  if (_isConfirming)
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: secondaryText,
                      ),
                      onPressed: () => setState(() {
                        _first = '';
                        _entry = '';
                        _error = null;
                      }),
                    ),
                  const Spacer(),
                  if (_canSkip && !_isConfirming)
                    TextButton(
                      onPressed: () {
                        final next = _nextRoute;
                        next != null
                            ? Get.offAllNamed(next)
                            : Get.back(result: false);
                      },
                      child: Text(
                        'Skip',
                        style: TextStyle(color: secondaryText),
                      ),
                    ),
                ],
              ),
            ),

            const Spacer(flex: 2),

            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: kPinGreen.withOpacity(isDark ? 0.18 : 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 34,
                color: kPinGreen,
              ),
            ),

            const SizedBox(height: 22),

            Text(
              _isConfirming ? 'Enter it again' : 'Create a PIN',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: primaryText,
              ),
            ),

            const SizedBox(height: 7),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _isConfirming
                    ? 'Type the same four digits once more.'
                    : 'Four digits. You will enter this each time the '
                          'app opens.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: secondaryText,
                ),
              ),
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

            const Spacer(),

            PinKeypad(onDigit: _onDigit, onBackspace: _onBackspace),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
