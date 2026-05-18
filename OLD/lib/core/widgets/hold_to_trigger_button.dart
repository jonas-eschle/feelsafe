/// A large round "hold to stay safe" button.
///
/// Detects press / release and calls [onHoldStart] / [onHoldRelease].
/// Exposes a [Semantics] label for TalkBack / VoiceOver.
library;

import 'package:flutter/material.dart';

import 'package:guardianangela/core/theme/theme_extensions.dart';

/// Hold-to-trigger button.
class HoldToTriggerButton extends StatefulWidget {
  /// Creates a hold button.
  const HoldToTriggerButton({
    super.key,
    required this.onHoldStart,
    required this.onHoldRelease,
    required this.semanticLabel,
    this.label = 'Hold',
    this.size = 200,
  });

  /// Called when the user presses down.
  final VoidCallback onHoldStart;

  /// Called when the user lifts their finger.
  final VoidCallback onHoldRelease;

  /// Accessibility label.
  final String semanticLabel;

  /// Visible label.
  final String label;

  /// Outer diameter.
  final double size;

  @override
  State<HoldToTriggerButton> createState() => _HoldToTriggerButtonState();
}

class _HoldToTriggerButtonState extends State<HoldToTriggerButton> {
  bool _held = false;

  void _start() {
    if (_held) return;
    setState(() => _held = true);
    widget.onHoldStart();
  }

  void _end() {
    if (!_held) return;
    setState(() => _held = false);
    widget.onHoldRelease();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      label: widget.semanticLabel,
      button: true,
      enabled: true,
      child: GestureDetector(
        onTapDown: (_) => _start(),
        onTapUp: (_) => _end(),
        onTapCancel: _end,
        onPanEnd: (_) => _end(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _held ? colors.safe : colors.warning,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: _held ? 4 : 12,
                offset: Offset(0, _held ? 1 : 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: _held ? colors.safeOn : colors.warningOn,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
