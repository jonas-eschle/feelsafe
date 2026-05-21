import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/enums/pause_reason.dart';

/// The phase within a running step.
///
/// Used by [EngineRunning] to describe which part of the three-phase timing
/// model is currently active.
enum EnginePhase {
  /// Waiting before the step action fires (waitSeconds).
  wait,

  /// The step action is active (durationSeconds).
  duration,

  /// Dead time after the action, before advance/repeat (gracePeriodSeconds).
  grace,

  /// Waiting for the user to begin holding (holdButton only, before hold-start
  /// is called).
  holdWait,

  /// Brief-release detection window after the user releases a hold-button.
  sensitivity,
}

/// Sealed state hierarchy for the [SessionEngine].
///
/// Use exhaustive [switch] expressions over this type — the compiler enforces
/// all cases are handled. See spec 01 §Sealed EngineState.
sealed class EngineState {}

/// The engine has not been started yet.
final class EngineIdle extends EngineState {
  /// Creates the idle state.
  EngineIdle();
}

/// The engine is actively running a step.
final class EngineRunning extends EngineState {
  /// Creates the running state.
  EngineRunning({
    required this.currentStepIndex,
    required this.remaining,
    required this.missCount,
    required this.isHolding,
    required this.phase,
  });

  /// Index of the currently executing step (0-based).
  final int currentStepIndex;

  /// Time remaining in the current [phase].
  final Duration remaining;

  /// Number of grace periods that have expired without a user disarm on
  /// the current step.
  final int missCount;

  /// Whether the user is currently holding the hold-button (holdButton steps
  /// only).
  final bool isHolding;

  /// Which phase of the three-phase timing model is active.
  final EnginePhase phase;

  /// Returns a copy with the specified fields replaced.
  EngineRunning copyWith({
    int? currentStepIndex,
    Duration? remaining,
    int? missCount,
    bool? isHolding,
    EnginePhase? phase,
  }) => EngineRunning(
    currentStepIndex: currentStepIndex ?? this.currentStepIndex,
    remaining: remaining ?? this.remaining,
    missCount: missCount ?? this.missCount,
    isHolding: isHolding ?? this.isHolding,
    phase: phase ?? this.phase,
  );
}

/// The engine is paused and awaiting a [SessionEngine.resume] call.
///
/// [snapshot] captures the exact [EngineRunning] state at the moment
/// [SessionEngine.pause] was called — including remaining time. Resume
/// restores this snapshot exactly, satisfying the deterministic invariant.
final class EnginePaused extends EngineState {
  /// Creates the paused state.
  EnginePaused({required this.snapshot, required this.reason});

  /// The running state frozen at pause time.
  final EngineRunning snapshot;

  /// Why the session is paused.
  final PauseReason reason;
}

/// The engine has ended and will emit no further events.
final class EngineEnded extends EngineState {
  /// Creates the ended state.
  EngineEnded({required this.reason});

  /// Why the session ended.
  final EndReason reason;
}
