import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Numeric keypad shared by every PIN entry/setup screen.
///
/// Renders a 4×3 grid of digit buttons (1–9, action, 0, backspace). Each
/// digit triggers [onDigit]; the bottom-left action slot is optional and
/// is used by PIN entry screens to surface a biometric icon. Haptic
/// feedback fires on every press (selectionClick) per spec 04 §PinKeypad.
class PinKeypad extends StatelessWidget {
  /// Creates a [PinKeypad].
  const PinKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    this.onAction,
    this.actionIcon,
    this.biometricAvailable = false,
  });

  /// Called with a value 0–9 when a digit is pressed.
  final ValueChanged<int> onDigit;

  /// Called when the backspace key is pressed.
  final VoidCallback onBackspace;

  /// Callback for the bottom-left action slot (e.g., biometric prompt).
  ///
  /// When null the slot renders empty.
  final VoidCallback? onAction;

  /// Icon for the bottom-left action slot.
  ///
  /// Defaults to [Icons.fingerprint] when [onAction] is non-null.
  final Widget? actionIcon;

  /// When `true`, the action slot exposes a biometric label for screen
  /// readers.
  final bool biometricAvailable;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final row in const <List<int>>[
          <int>[1, 2, 3],
          <int>[4, 5, 6],
          <int>[7, 8, 9],
        ])
          _KeyRow(
            children: <Widget>[
              for (final digit in row)
                Expanded(
                  child: _DigitButton(
                    digit: digit,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      onDigit(digit);
                    },
                  ),
                ),
            ],
          ),
        _KeyRow(
          children: <Widget>[
            Expanded(
              child: onAction == null
                  ? const SizedBox.shrink()
                  : _ActionButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        onAction!();
                      },
                      icon: actionIcon ?? const Icon(Icons.fingerprint),
                      semanticsLabel: biometricAvailable
                          ? 'Use biometric'
                          : 'Action',
                    ),
            ),
            Expanded(
              child: _DigitButton(
                digit: 0,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onDigit(0);
                },
              ),
            ),
            Expanded(
              child: _ActionButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onBackspace();
                },
                icon: const Icon(Icons.backspace_outlined),
                semanticsLabel: 'Backspace',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KeyRow extends StatelessWidget {
  const _KeyRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: children),
    );
  }
}

class _DigitButton extends StatelessWidget {
  const _DigitButton({required this.digit, required this.onPressed});

  final int digit;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: SizedBox(
        height: 56,
        child: Material(
          color: scheme.surfaceContainerHighest,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Center(
              child: Text(
                '$digit',
                style: textTheme.headlineSmall?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.semanticsLabel,
  });

  final VoidCallback onPressed;
  final Widget icon;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: SizedBox(
        height: 56,
        child: Semantics(
          label: semanticsLabel,
          button: true,
          child: Material(
            color: scheme.surfaceContainerHigh,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: Center(child: icon),
            ),
          ),
        ),
      ),
    );
  }
}
