import 'package:flutter/foundation.dart';

import 'package:guardianangela/domain/configs/step_config.dart';

/// Phase of the fake-call screen.
///
/// `incoming` — ringing UI with slide-to-answer + decline.
/// `active`   — answered, hang-up control visible.
enum FakeCallPhase {
  /// Incoming-call state before the user accepts or declines.
  incoming,

  /// Active-call state after the user slides to answer.
  active,
}

/// Immutable state for the fake-call screen.
@immutable
class FakeCallState {
  /// Creates a [FakeCallState].
  const FakeCallState({
    required this.config,
    this.phase = FakeCallPhase.incoming,
    this.slideProgress = 0,
    this.holdProgress = 0,
    this.activeElapsed = Duration.zero,
  });

  /// The configuration applied to this screen (from the chain step).
  final FakeCallConfig config;

  /// Current visible phase.
  final FakeCallPhase phase;

  /// Horizontal slide progress in `[0, 1]`. Above `0.85` triggers answer.
  final double slideProgress;

  /// Hold-to-distress progress in `[0, 1]`. Reaching `1` fires distress.
  final double holdProgress;

  /// Elapsed time since the call was answered.
  final Duration activeElapsed;

  /// Returns a copy with the named fields replaced.
  FakeCallState copyWith({
    FakeCallPhase? phase,
    double? slideProgress,
    double? holdProgress,
    Duration? activeElapsed,
  }) => FakeCallState(
    config: config,
    phase: phase ?? this.phase,
    slideProgress: slideProgress ?? this.slideProgress,
    holdProgress: holdProgress ?? this.holdProgress,
    activeElapsed: activeElapsed ?? this.activeElapsed,
  );
}

/// Plain ChangeNotifier-style controller that owns the fake-call
/// interaction state.
///
/// Used as a `ValueNotifier`-style host because the controller is
/// short-lived (lives only inside the screen's State) and does not need
/// to be exposed via Riverpod. See spec 04 §Fake Call Screen.
class FakeCallController extends ValueNotifier<FakeCallState> {
  /// Creates a [FakeCallController] initialised with [config].
  FakeCallController(FakeCallConfig config)
    : super(FakeCallState(config: config));

  /// Slide threshold (0–1) above which the call is auto-answered (spec
  /// 04:1117).
  static const double slideAnswerThreshold = 0.85;

  /// Updates the slide-to-answer progress.
  ///
  /// Clamps to `[0, 1]`. When the value reaches [slideAnswerThreshold] the
  /// call transitions to [FakeCallPhase.active].
  void updateSlide(double v) {
    if (value.phase == FakeCallPhase.active) return;
    final clamped = v.clamp(0.0, 1.0);
    if (clamped >= slideAnswerThreshold) {
      value = value.copyWith(slideProgress: 1, phase: FakeCallPhase.active);
      return;
    }
    value = value.copyWith(slideProgress: clamped);
  }

  /// Resets the slide track when the user releases below the threshold.
  void releaseSlide() {
    if (value.phase == FakeCallPhase.active) return;
    value = value.copyWith(slideProgress: 0);
  }

  /// Updates the hold-for-distress progress. `1.0` fires distress.
  void updateHold(double v) {
    final clamped = v.clamp(0.0, 1.0);
    value = value.copyWith(holdProgress: clamped);
  }

  /// Resets the hold progress (release without firing).
  void releaseHold() => value = value.copyWith(holdProgress: 0);

  /// Marks the call as active (used internally when answer completes).
  void answer() =>
      value = value.copyWith(phase: FakeCallPhase.active, slideProgress: 1);

  /// Updates the active-call elapsed duration.
  void tickActive(Duration elapsed) =>
      value = value.copyWith(activeElapsed: elapsed);
}
