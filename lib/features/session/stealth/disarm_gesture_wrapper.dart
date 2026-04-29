/// Shared horizontal-swipe + long-press disarm gesture wrapper used
/// by every stealth disguise screen (Music, Podcast, Calendar).
///
/// Per Q24 / spec 04 §Stealth Mode UI all three disguises must
/// honour the same disarm gestures so the user only learns one
/// interaction pattern:
///
///   * Horizontal swipe ≥ 50% of the screen width = disarm. *Why
///     50%:* a tiny thumb-drag is a very common motion (panning a
///     scrollable, accidental flicks); requiring half the screen
///     width turns disarm into a deliberate gesture an attacker
///     cannot trigger by mistake.
///   * Long-press anywhere on the wrapped child = disarm. *Why a
///     long-press:* TalkBack/VoiceOver users cannot reliably
///     execute a half-screen swipe but can long-press; the
///     fallback restores accessibility parity (WCAG 2.1).
///
/// The wrapper uses `behavior: HitTestBehavior.opaque` so it
/// receives gestures even when the underlying child has empty
/// regions (e.g. a music-app's blank space below the transport
/// controls).
library;

import 'package:flutter/material.dart';

/// Wraps a child with the two stealth disarm gestures.
class DisarmGestureWrapper extends StatefulWidget {
  /// Creates the wrapper.
  const DisarmGestureWrapper({
    super.key,
    required this.child,
    required this.onDisarm,
    required this.hint,
  });

  /// The disguise UI to wrap.
  final Widget child;

  /// Callback invoked when the user performs a qualifying disarm
  /// gesture (long-press OR ≥50%-screen-width horizontal swipe).
  final VoidCallback onDisarm;

  /// Semantic hint surfaced to assistive tech.
  final String hint;

  @override
  State<DisarmGestureWrapper> createState() => _DisarmGestureWrapperState();
}

class _DisarmGestureWrapperState extends State<DisarmGestureWrapper> {
  /// Global X coord at drag start. Used to compute the absolute
  /// distance travelled rather than per-frame deltas (which can
  /// reset between gestures).
  double _dragStartX = 0;

  /// Tracks whether this drag has already fired the disarm — keeps
  /// `onHorizontalDragUpdate` from firing repeatedly as the user
  /// continues sliding past the threshold.
  bool _fired = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.hint,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: () {
          if (_fired) return;
          _fired = true;
          widget.onDisarm();
        },
        onHorizontalDragStart: (d) {
          _dragStartX = d.globalPosition.dx;
          _fired = false;
        },
        onHorizontalDragUpdate: (d) {
          if (_fired) return;
          final width = MediaQuery.of(context).size.width;
          final distance = (d.globalPosition.dx - _dragStartX).abs();
          if (distance >= width * 0.5) {
            _fired = true;
            widget.onDisarm();
          }
        },
        onHorizontalDragEnd: (_) {
          // Reset for the next gesture; do not fire here — releasing
          // before the threshold should be a no-op (matches every
          // other swipe-to-confirm widget in the app).
          _fired = false;
        },
        child: widget.child,
      ),
    );
  }
}
