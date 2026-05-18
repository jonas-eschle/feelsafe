/// Timing phases the engine steps through for each chain step.
///
/// Pure Dart. Part of the sealed `EngineState` hierarchy — a running
/// engine carries the current phase as a field on `EngineRunning`.
library;

/// The five timer phases applied to every chain step.
///
/// Every step type traverses a subset of these phases in order. The
/// engine advances from phase to phase when its single `Timer` fires;
/// side effects (strategy execution, log events) are scheduled at
/// phase boundaries.
///
/// Phases by step type (informational — see `docs/spec/01-chain-engine.md`):
/// - `holdButton`: `holdWait` → (on release) `sensitivity` → `grace`
/// - `disguisedReminder`: `wait` → `duration` → `grace`
/// - `countdownWarning` / `loudAlarm` / `fakeCall` etc.: `wait` → `duration`
/// - `smsContact` / `phoneCallContact` / `callEmergency`: `duration` (fire-and-advance)
enum TimerPhase {
  /// Waiting before the step's active phase begins (pre-step delay).
  wait,

  /// The step is actively doing its thing (countdown visible, alarm
  /// playing, call ringing, etc.).
  duration,

  /// Post-duration grace period in which the user can still respond.
  /// Exhausted → advance to next step OR miss counter increments.
  grace,

  /// Short release-sensitivity window on hold-button steps — if the
  /// user re-holds within this window, treat as a continuous hold.
  sensitivity,

  /// Pre-hold wait state on hold-button steps — the engine is armed
  /// but waiting for the first press.
  holdWait,
}
