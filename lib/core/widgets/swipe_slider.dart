import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Horizontal swipe-to-confirm control used at the dead-man's-switch
/// surfaces that must distinguish a deliberate user choice from a stray
/// tap (e.g. cancel-emergency-call, end-session, distress-cancel).
///
/// The user drags the knob from the left edge to the right edge; once
/// the knob crosses `threshold * track-width` the widget fires
/// [onConfirm] exactly once. Releasing the knob below the threshold
/// animates it back to the start, ready for another attempt. Each
/// drag-cycle can fire [onConfirm] at most once; a fresh drag (new
/// pan-down event) re-arms the slider.
///
/// Accessibility: the slider exposes itself through [Semantics] as a
/// horizontal slider with the supplied [label] so screen readers can
/// announce both its purpose and progress.
///
/// Spec ref: 02 Extra 56 (cancel emergency call), 04 §Grace Period
/// Slider (end-session), 04 §Stealth slider variants.
class SwipeSlider extends StatefulWidget {
  /// Creates a [SwipeSlider].
  ///
  /// [threshold] defaults to `0.7` (70 % of the track width) per spec
  /// 02 Extra 56. [trackColor] / [knobColor] default to null and fall
  /// through to the active theme's `colorScheme.primaryContainer` /
  /// `colorScheme.primary`. [semanticsLabel] defaults to null and falls
  /// through to [label]; pass an explicit value when the visible label
  /// is decorative.
  const SwipeSlider({
    super.key,
    required this.label,
    required this.onConfirm,
    this.threshold = 0.7,
    this.trackColor,
    this.knobColor,
    this.height = 64,
    this.semanticsLabel,
  }) : assert(threshold > 0 && threshold <= 1.0, 'threshold must be in (0, 1]'),
       assert(height >= 48, 'height must be >= 48 for touch target');

  /// Text rendered along the track and read by screen readers (when
  /// [semanticsLabel] is null).
  final String label;

  /// Fired once when the user drags the knob past [threshold] of the
  /// track width. A new pan-down event re-arms the slider for another
  /// confirm.
  final VoidCallback onConfirm;

  /// Fraction of the track width the user must traverse before
  /// [onConfirm] fires. Defaults to `0.7`.
  final double threshold;

  /// Color of the track behind the knob. Null = inherit from the
  /// theme's `colorScheme.primaryContainer`.
  final Color? trackColor;

  /// Color of the knob. Null = inherit from the theme's
  /// `colorScheme.primary`.
  final Color? knobColor;

  /// Vertical height of the slider. Defaults to `64`. Must be `>= 48`
  /// to satisfy the WCAG / Material touch-target minimum.
  final double height;

  /// Override for the screen-reader label; defaults to [label].
  final String? semanticsLabel;

  @override
  State<SwipeSlider> createState() => _SwipeSliderState();
}

class _SwipeSliderState extends State<SwipeSlider>
    with SingleTickerProviderStateMixin {
  /// Current horizontal offset of the knob in pixels.
  double _dragX = 0;

  /// Whether the knob has crossed [SwipeSlider.threshold] during the
  /// current drag. Reset to false on every new [_onPanDown].
  bool _didFire = false;

  /// Cached width of the track measured by [LayoutBuilder]. Initial 0
  /// so a stray pan-update before layout cannot trigger a fire.
  double _trackWidth = 0;

  late final AnimationController _resetCtl;
  late final Animation<double> _resetAnim;
  double _resetFrom = 0;

  @override
  void initState() {
    super.initState();
    _resetCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _resetAnim = CurvedAnimation(parent: _resetCtl, curve: Curves.easeOutCubic);
    _resetAnim.addListener(_onResetTick);
  }

  void _onResetTick() {
    setState(() {
      _dragX = _resetFrom * (1 - _resetAnim.value);
    });
  }

  @override
  void dispose() {
    _resetAnim.removeListener(_onResetTick);
    _resetCtl.dispose();
    super.dispose();
  }

  void _onPanDown(DragDownDetails _) {
    _resetCtl.stop();
    _didFire = false;
  }

  void _onPanUpdate(DragUpdateDetails details, double knobSize) {
    if (_didFire) return;
    final maxX = _trackWidth - knobSize;
    if (maxX <= 0) return;
    final next = (_dragX + details.delta.dx).clamp(0.0, maxX);
    setState(() => _dragX = next);
    final progress = next / maxX;
    if (progress >= widget.threshold && !_didFire) {
      _didFire = true;
      // Snap the knob to the end so the visual confirms the action.
      setState(() => _dragX = maxX);
      // Light-impact haptic mirrors the fake-call slide-to-answer feedback
      // so the user feels the commit even before the visual snap completes.
      HapticFeedback.lightImpact();
      widget.onConfirm();
    }
  }

  void _onPanEnd(DragEndDetails _) {
    if (_didFire) return;
    if (_dragX <= 0) return;
    _resetFrom = _dragX;
    _resetCtl
      ..reset()
      ..forward();
  }

  void _onPanCancel() {
    if (_didFire) return;
    if (_dragX <= 0) return;
    _resetFrom = _dragX;
    _resetCtl
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final trackColor = widget.trackColor ?? cs.primaryContainer;
    final knobColor = widget.knobColor ?? cs.primary;
    final l10n = AppLocalizations.of(context);
    final semanticsLabel = widget.semanticsLabel ?? widget.label;
    return Semantics(
      slider: true,
      label: semanticsLabel,
      hint: l10n.swipeSliderSemantics,
      child: SizedBox(
        height: widget.height,
        child: LayoutBuilder(
          builder: (BuildContext _, BoxConstraints constraints) {
            _trackWidth = constraints.maxWidth;
            final knobSize = widget.height;
            final maxX = _trackWidth - knobSize;
            final progress = maxX <= 0 ? 0.0 : (_dragX / maxX).clamp(0.0, 1.0);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanDown: _onPanDown,
              onPanUpdate: (DragUpdateDetails d) => _onPanUpdate(d, knobSize),
              onPanEnd: _onPanEnd,
              onPanCancel: _onPanCancel,
              child: Stack(
                children: <Widget>[
                  // Track
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: trackColor,
                      borderRadius: BorderRadius.circular(widget.height / 2),
                    ),
                    child: SizedBox.expand(
                      child: Center(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 120),
                          opacity: 1 - progress,
                          child: Text(
                            widget.label,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: cs.onPrimaryContainer,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Knob with chevron arrow.
                  Positioned(
                    left: _dragX,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: knobSize,
                      height: knobSize,
                      decoration: BoxDecoration(
                        color: knobColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: cs.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
