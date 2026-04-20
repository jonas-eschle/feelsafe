/// A 3×4 numeric keypad used by PIN-entry and PIN-setup flows.
library;

import 'package:flutter/material.dart';

/// Numeric keypad widget. Emits [onDigit] for 0–9 and [onBackspace]
/// for the `⌫` key.
class PinKeypad extends StatelessWidget {
  /// Creates a PIN keypad.
  const PinKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
  });

  /// Called with a single digit `0..9` when a digit key is tapped.
  final void Function(int digit) onDigit;

  /// Called when the backspace key is tapped.
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var row = 0; row < 3; row++)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var col = 0; col < 3; col++)
                  _KeyButton(
                    label: '${row * 3 + col + 1}',
                    onTap: () => onDigit(row * 3 + col + 1),
                  ),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _KeyButton(label: '', onTap: null),
              _KeyButton(label: '0', onTap: () => onDigit(0)),
              _KeyButton(label: '⌫', onTap: onBackspace),
            ],
          ),
        ],
      );
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(6),
        child: SizedBox(
          width: 72,
          height: 56,
          child: OutlinedButton(
            onPressed: onTap,
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
      );
}
