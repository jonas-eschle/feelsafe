/// The sealed `EngineState` hierarchy plus its companion `EndReason`
/// and `PauseReason` enums.
///
/// Pure Dart. `lib/domain/**` does not import `package:flutter/`.
///
/// Design (per plan D-ENGINE-1): sealed class hierarchy + concrete
/// `final` subclasses so `switch` expressions are compile-time
/// exhaustive. Companion enums (`EndReason`, `PauseReason`) are
/// co-located because their lifetime is the engine's.
library;

import 'timer_phase.dart';

/// Root of the engine state hierarchy.
///
/// Four concrete states: [EngineIdle], [EngineRunning], [EnginePaused],
/// [EngineEnded]. Each transition is explicit; there is no "unknown" or
/// "error" state — errors surface as exceptions, not states.
sealed class EngineState {
  const EngineState();
}

/// No session active. The engine has not yet been started, or the
/// previous session has been fully cleaned up.
final class EngineIdle extends EngineState {
  const EngineIdle();
}

/// A session is running. Carries the index of the current step, the
/// active [TimerPhase], the remaining duration for the current phase,
/// how many `miss` counts have accumulated, and whether the user is
/// actively holding (for `holdButton` steps).
final class EngineRunning extends EngineState {
  const EngineRunning({
    required this.stepIndex,
    required this.phase,
    required this.remaining,
    required this.missCount,
    required this.isHolding,
  });

  /// Zero-based index into the active chain's `steps` list.
  final int stepIndex;

  /// Current timer phase for the active step.
  final TimerPhase phase;

  /// Remaining duration for [phase]. Frozen while [EnginePaused].
  final Duration remaining;

  /// How many consecutive missed grace-period completions have
  /// accumulated for the current step. Reset on disarm or advance.
  final int missCount;

  /// True when the user is physically holding (hold-button steps only).
  final bool isHolding;

  EngineRunning copyWith({
    int? stepIndex,
    TimerPhase? phase,
    Duration? remaining,
    int? missCount,
    bool? isHolding,
  }) =>
      EngineRunning(
        stepIndex: stepIndex ?? this.stepIndex,
        phase: phase ?? this.phase,
        remaining: remaining ?? this.remaining,
        missCount: missCount ?? this.missCount,
        isHolding: isHolding ?? this.isHolding,
      );
}

/// The session is paused. Carries the [EngineRunning] snapshot the
/// engine will resume from, plus the [reason] for pausing.
final class EnginePaused extends EngineState {
  const EnginePaused({required this.snapshot, required this.reason});

  /// The running state at the moment of pause. Resuming restores this
  /// state with the same `remaining`.
  final EngineRunning snapshot;

  /// Why the engine paused.
  final PauseReason reason;
}

/// The session has ended. Terminal state; no further transitions.
final class EngineEnded extends EngineState {
  const EngineEnded({required this.reason});

  /// How the session ended.
  final EndReason reason;
}

/// Why a running engine was paused.
enum PauseReason {
  /// The UI / user explicitly requested a pause.
  userRequested,

  /// An incoming phone call was detected; engine pauses so audio does
  /// not bleed into the call. Auto-resumes when the call ends.
  incomingCall,

  /// A fake call step's `answer` action paused the chain while the
  /// voice recording plays. The chain is suspended, not ended;
  /// `hangUp` disarms; `declineFakeCall` resolves per config.
  fakeCallAnswered,

  /// The app was relaunched after being backgrounded long enough that
  /// the engine needs the recovery-dialog flow (per D-ENGINE-22: no
  /// auto-resume).
  bootRestart,
}

/// Why a session ended.
enum EndReason {
  /// User-initiated disarm (I'm safe / session-end PIN / GPS arrival).
  disarm,

  /// The last step of the chain completed successfully.
  chainExhausted,

  /// Hardware panic trigger fired; distress chain completed.
  hardwarePanic,

  /// Duress PIN entered; distress chain completed.
  duressPin,

  /// Wrong-PIN threshold exhausted; distress chain completed.
  wrongPinExhausted,

  /// User quit the session (app-level termination path).
  userQuit,

  /// Application termination without an in-progress recovery dialog.
  appTermination,
}
