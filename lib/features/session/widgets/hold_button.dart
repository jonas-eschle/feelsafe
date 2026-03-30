import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/walk_session.dart';
import '../../../l10n/app_localizations.dart';

/// Large circular hold-button for walk mode.
/// Changes color based on session state:
/// - Teal when held (safe)
/// - Amber when released (countdown)
/// - Red when escalating
class HoldButton extends StatefulWidget {
  final SessionState state;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldRelease;

  const HoldButton({
    super.key,
    required this.state,
    required this.onHoldStart,
    required this.onHoldRelease,
  });

  @override
  State<HoldButton> createState() => _HoldButtonState();
}

class _HoldButtonState extends State<HoldButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(HoldButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Pulse when in warning/danger states and not held
    if (!_isPressed && _isDanger) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool get _isDanger =>
      widget.state == SessionState.warning ||
      widget.state == SessionState.fakeCall ||
      widget.state == SessionState.smsSent ||
      widget.state == SessionState.alarm ||
      widget.state == SessionState.emergencyCall;

  Color get _buttonColor {
    if (_isPressed) return AppColors.safe;
    if (widget.state == SessionState.active) return AppColors.safe;
    if (widget.state == SessionState.checkInPrompt) return AppColors.warning;
    if (_isDanger) return AppColors.danger;
    return AppColors.safe;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = _buttonColor;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = _pulseController.isAnimating ? _pulseAnimation.value : 1.0;
        return Transform.scale(
          scale: _isPressed ? 0.95 : scale,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _onDown(),
        onTapUp: (_) => _onUp(),
        onTapCancel: _onUp,
        onLongPressStart: (_) => _onDown(),
        onLongPressEnd: (_) => _onUp(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: _isPressed ? 1.0 : 0.85),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: _isPressed ? 30 : 15,
                spreadRadius: _isPressed ? 8 : 2,
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isPressed ? Icons.shield : Icons.touch_app,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  _isPressed ? l10n.imSafe : l10n.holdToStaySafe,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onDown() {
    if (!_isPressed) {
      setState(() => _isPressed = true);
      widget.onHoldStart();
    }
  }

  void _onUp() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      widget.onHoldRelease();
    }
  }
}
