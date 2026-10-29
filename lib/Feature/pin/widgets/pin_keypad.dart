import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color kPinGreen = Color(0xFF2EA44F);

/// The four dots that fill as digits are typed.
class PinDots extends StatelessWidget {
  const PinDots({
    super.key,
    required this.filled,
    required this.length,
    this.isError = false,
  });

  final int filled;
  final int length;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        final isOn = i < filled;

        final colour = isError
            ? const Color(0xFFE53935)
            : (isOn
                ? kPinGreen
                : (isDark ? Colors.white24 : Colors.black26));

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 9),
          width: isOn ? 15 : 13,
          height: isOn ? 15 : 13,
          decoration: BoxDecoration(
            color: isOn || isError ? colour : Colors.transparent,
            border: Border.all(color: colour, width: 1.6),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

/// The number pad.
///
/// Built in the app rather than using the system keyboard, so the layout
/// is the same on every phone and the digits stay large enough to hit
/// without looking.
class PinKeypad extends StatelessWidget {
  const PinKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    this.onAction,
    this.actionIcon,
    this.actionLabel,
    this.enabled = true,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  /// Optional bottom-left key, used for "Forgot PIN".
  final VoidCallback? onAction;
  final IconData? actionIcon;
  final String? actionLabel;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColour = isDark ? Colors.white : const Color(0xFF1C1C1C);
    final hint = isDark ? Colors.white60 : Colors.black54;

    Widget digit(String value) {
      return _Key(
        enabled: enabled,
        onTap: () {
          HapticFeedback.selectionClick();
          onDigit(value);
        },
        child: Text(
          value,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: enabled ? textColour : hint,
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map(digit).toList(),
          ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (onAction != null)
              _Key(
                enabled: true,
                onTap: onAction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(actionIcon ?? Icons.help_outline_rounded,
                        size: 20, color: hint),
                    if (actionLabel != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        actionLabel!,
                        style: TextStyle(fontSize: 9.5, color: hint),
                      ),
                    ],
                  ],
                ),
              )
            else
              const SizedBox(width: 78, height: 70),

            digit('0'),

            _Key(
              enabled: enabled,
              onTap: () {
                HapticFeedback.selectionClick();
                onBackspace();
              },
              child: Icon(
                Icons.backspace_outlined,
                size: 22,
                color: enabled ? textColour : hint,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    required this.child,
    required this.onTap,
    required this.enabled,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      height: 70,
      child: Material(
        color: Colors.transparent,
        child: InkResponse(
          onTap: enabled ? onTap : null,
          radius: 38,
          child: Center(child: child),
        ),
      ),
    );
  }
}
