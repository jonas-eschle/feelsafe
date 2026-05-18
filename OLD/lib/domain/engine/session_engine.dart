/// `SessionEngine` — the pure-Dart escalation state machine.
///
/// Drives a safety session: traverses a list of [ChainStep]s through
/// their `wait → duration → grace` phases, emits
/// [ChainEventData] via a broadcast [Stream], and accepts user
/// signals (disarm, hold, fake-call actions, etc.) via its command
/// methods.
///
/// Pure Dart — no Flutter imports. Side effects (SMS, alarm, calls)
/// live in `lib/domain/orchestration/` strategies that consume the
/// engine's event stream via `SessionOrchestrator`.
library;

import 'dart:async';
import 'dart:math';

import 'package:clock/clock.dart' as pkg_clock;

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/timer_phase.dart';
import 'package:guardianangela/domain/models/chain_event.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/step_config.dart';

/// The session escalation state machine.
///
/// Drives the session's progression through an ordered list of
/// [ChainStep]s via a single internal [Timer]. At any point the
/// engine is in exactly one of four sealed [EngineState] subtypes
/// ([EngineIdle] → [EngineRunning] → [EnginePaused] → [EngineEnded]).
///
/// The engine is deterministic given a fixed [Random] — all timing
/// jitter flows through its [nextDouble] so tests can pass a
/// [FixedRandom] to eliminate variance. Transitions emit
/// [ChainEventData] on the [events] broadcast stream.
final class SessionEngine {
  /// Creates a session engine.
  ///
  /// [chainSteps] — ordered escalation steps; non-empty when
  /// [start] is called.
  /// [isSimulation] — if true, the engine allows a
  /// non-unity [speedMultiplier] and permits the `leap` /
  /// `jumpToStep` fast-forward controls.
  /// [speedMultiplier] — real sessions must use `1.0`; simulations
  /// may use any finite positive value. Defaults to `1.0`. Throws
  /// [ArgumentError] on NaN, infinity, or a non-`1.0` value when
  /// [isSimulation] is false, and on any non-positive value.
  /// [random] — optional RNG for timer jitter; defaults to a new
  /// `Random()` instance.
  /// [clock] — optional wall-clock source; defaults to
  /// `DateTime.now`.
  SessionEngine({
    required List<ChainStep> chainSteps,
    this.isSimulation = false,
    double speedMultiplier = 1.0,
    Random? random,
    DateTime Function()? clock,
    Duration? maxPauseDuration,
  }) : _steps = List.of(chainSteps),
       _speedMultiplier = speedMultiplier.clamp(
         _speedMultiplierMin,
         _speedMultiplierMax,
       ),
       _random = random ?? Random(),
       _clock = clock ?? (() => pkg_clock.clock.now()),
       _maxPauseDuration = maxPauseDuration {
    if (speedMultiplier.isNaN ||
        speedMultiplier.isInfinite ||
        speedMultiplier <= 0) {
      throw ArgumentError.value(
        speedMultiplier,
        'speedMultiplier',
        'must be a finite positive number',
      );
    }
    if (!isSimulation && speedMultiplier != 1.0) {
      throw ArgumentError.value(
        speedMultiplier,
        'speedMultiplier',
        'real sessions must use speedMultiplier == 1.0',
      );
    }
  }

  static const double _speedMultiplierMin = 0.01;
  static const double _speedMultiplierMax = 1000.0;

  /// The active chain (may be replaced by a distress chain).
  List<ChainStep> get steps => List.unmodifiable(_steps);

  /// True iff this session is a simulation.
  final bool isSimulation;

  /// Speed multiplier (simulation only, else `1.0`).
  ///
  /// Mutable in simulation mode so [setSpeedMultiplier] can adjust
  /// timing on the fly (spec 01 §Engine API).
  double get speedMultiplier => _speedMultiplier;

  double _speedMultiplier;

  /// Internal mutable chain storage. Swapped wholesale by
  /// [replaceWithDistressChain] — never mutated in place.
  List<ChainStep> _steps;

  /// RNG used for ±20% timer jitter.
  final Random _random;

  /// Wall-clock source.
  final DateTime Function() _clock;

  /// Sealed engine state.
  EngineState _state = const EngineIdle();

  /// True after [replaceWithDistressChain] has swapped the chain.
  bool _isDistressChain = false;

  /// The forensic reason recorded when the distress chain was
  /// triggered. Null until [replaceWithDistressChain] is called.
  TriggerReason? _distressTriggerReason;

  /// Returns the forensic distress trigger reason, or null if no
  /// distress chain has been triggered.
  TriggerReason? get distressTriggerReason => _distressTriggerReason;

  /// Single active timer; null when no phase is scheduled.
  Timer? _timer;

  /// Spec 01 §Events Emitted — when set and the engine enters
  /// [EnginePaused], a timer starts. On expiry the engine emits
  /// [ChainEvent.pauseExpired] and auto-resumes. Null disables the
  /// auto-resume.
  final Duration? _maxPauseDuration;

  /// Active pause-expiry timer; null when not paused or when
  /// auto-resume is disabled.
  Timer? _pauseExpiryTimer;

  /// When the current phase was scheduled; used by `pause` to
  /// compute the exact remaining duration. Null between phases.
  DateTime? _phaseStart;

  /// The scheduled duration of the current phase. Null between
  /// phases. Used together with [_phaseStart] to derive remaining.
  Duration? _phaseDuration;

  /// Broadcast stream controller for engine events. Synchronous so
  /// listeners see events in the order emitted without microtask
  /// latency — essential for deterministic test assertions.
  final StreamController<ChainEventData> _eventsCtrl =
      StreamController<ChainEventData>.broadcast(sync: true);

  /// Broadcast, synchronous stream of engine events.
  Stream<ChainEventData> get events => _eventsCtrl.stream;

  /// Current engine state.
  EngineState get state => _state;

  /// Current active step, or null when idle / ended.
  ChainStep? get currentStep {
    final s = _state;
    return switch (s) {
      EngineIdle() => null,
      EngineEnded() => null,
      EngineRunning(:final stepIndex) => _steps[stepIndex],
      EnginePaused(:final snapshot) => _steps[snapshot.stepIndex],
    };
  }

  /// True iff the current chain is the distress chain (i.e.,
  /// `replaceWithDistressChain` has been invoked).
  bool get isDistressChain => _isDistressChain;

  /// Starts the session.
  ///
  /// Throws [StateError] on double-start; throws [ArgumentError] if
  /// [steps] is empty.
  void start() {
    if (_state is! EngineIdle) {
      throw StateError(
        'SessionEngine.start() may only be called from EngineIdle; '
        'current state: $_state',
      );
    }
    if (_steps.isEmpty) {
      throw ArgumentError.value(_steps, 'steps', 'must not be empty');
    }
    _emit(ChainEvent.sessionStarted);
    _enterStep(0);
  }

  /// User check-in / re-arm. Per spec 01 §Disarm/Check-in:
  ///
  /// - Resets the chain to step 0.
  /// - Clears the miss count.
  /// - Emits [ChainEvent.userDisarmed] carrying the step the user
  ///   was on at the moment of disarm (so the log records *where*
  ///   the user re-armed from).
  /// - Re-executes step 0.
  ///
  /// Does **not** end the session — for that, callers fire
  /// [endSession] explicitly. No-op when the engine is idle, paused,
  /// or already ended (callers must `resume()` a paused engine first
  /// to make the disarm effective).
  void disarm() {
    final current = _state;
    if (current is! EngineRunning) {
      return;
    }
    _cancelTimer();
    _emit(ChainEvent.userDisarmed, stepIndex: current.stepIndex);
    // missCount is reset implicitly because _enterStep(0) constructs
    // a fresh EngineRunning with missCount: 0.
    _enterStep(0);
  }

  /// Pauses a running session.
  ///
  /// [reason] — why the engine is pausing; defaults to
  /// [PauseReason.userRequested]. No-op if the engine is not in
  /// [EngineRunning].
  void pause({PauseReason reason = PauseReason.userRequested}) {
    final current = _state;
    if (current is! EngineRunning) {
      return;
    }
    final remaining = _remainingFromTimer(current.remaining);
    _cancelTimer();
    _state = EnginePaused(
      snapshot: current.copyWith(remaining: remaining),
      reason: reason,
    );
    _emit(
      ChainEvent.sessionPaused,
      stepIndex: current.stepIndex,
      stepType: _steps[current.stepIndex].type,
      metadata: {'reason': reason.name},
    );
    _startPauseExpiryTimer();
  }

  /// Starts the pause-expiry timer when [_maxPauseDuration] is set.
  /// On fire, emits [ChainEvent.pauseExpired] and auto-resumes the
  /// session. Spec 01 §Events Emitted.
  void _startPauseExpiryTimer() {
    final maxPause = _maxPauseDuration;
    if (maxPause == null) return;
    final scaled = Duration(
      microseconds: (maxPause.inMicroseconds / effectiveSpeedMultiplier)
          .round()
          .clamp(0, 1 << 53),
    );
    _pauseExpiryTimer?.cancel();
    _pauseExpiryTimer = Timer(scaled, _onPauseExpired);
  }

  void _onPauseExpired() {
    _pauseExpiryTimer = null;
    final current = _state;
    if (current is! EnginePaused) return;
    _emit(
      ChainEvent.pauseExpired,
      stepIndex: current.snapshot.stepIndex,
      stepType: _steps[current.snapshot.stepIndex].type,
    );
    resume();
  }

  /// Resumes a paused session.
  ///
  /// No-op if the engine is not in [EnginePaused]. Restores the
  /// snapshot's `remaining` exactly — no rounding, no buffer.
  void resume() {
    final current = _state;
    if (current is! EnginePaused) {
      return;
    }
    _pauseExpiryTimer?.cancel();
    _pauseExpiryTimer = null;
    final snapshot = current.snapshot;
    _state = snapshot;
    _emit(
      ChainEvent.sessionResumed,
      stepIndex: snapshot.stepIndex,
      stepType: _steps[snapshot.stepIndex].type,
    );
    // Hold-button steps waiting for first touch re-arm with no timer.
    if (snapshot.phase == TimerPhase.holdWait && !snapshot.isHolding) {
      return;
    }
    _scheduleTimer(snapshot.phase, snapshot.remaining);
  }

  /// Ends the session with the given [reason].
  ///
  /// Cancels any running timer, transitions to [EngineEnded], emits
  /// [ChainEvent.sessionEnded]. Idempotent — subsequent calls while
  /// already ended are no-ops (the original [EndReason] is kept).
  void endSession({required EndReason reason}) {
    if (_state is EngineEnded) {
      return;
    }
    _cancelTimer();
    _pauseExpiryTimer?.cancel();
    _pauseExpiryTimer = null;
    final prevIndex = _currentStepIndexOrNull();
    _state = EngineEnded(reason: reason);
    _emit(
      ChainEvent.sessionEnded,
      stepIndex: prevIndex,
      metadata: {'reason': reason.name},
    );
  }

  /// Signals that the user started holding the button
  /// (`holdButton` steps).
  ///
  /// No-op outside [EngineRunning] or on non-holdButton steps, and
  /// no-op when already holding (edge-triggered). During grace, a
  /// re-hold counts as a disarm per spec §2.2.
  void holdStart() {
    final current = _state;
    if (current is! EngineRunning) return;
    final step = _steps[current.stepIndex];
    if (step.type != ChainStepType.holdButton) return;
    if (current.isHolding) return;
    // Re-hold during grace = disarm (spec §2.2).
    if (current.phase == TimerPhase.grace) {
      disarm();
      return;
    }
    _cancelTimer();
    _state = current.copyWith(
      phase: TimerPhase.duration,
      remaining: _scaledPhaseDuration(step, TimerPhase.duration),
      isHolding: true,
    );
    // While holding, the duration countdown pauses — no timer runs.
  }

  /// Signals that the user released the button
  /// (`holdButton` steps).
  ///
  /// No-op outside [EngineRunning] or on non-holdButton steps, and
  /// no-op when not currently holding (edge-triggered).
  void holdRelease() {
    final current = _state;
    if (current is! EngineRunning) return;
    final step = _steps[current.stepIndex];
    if (step.type != ChainStepType.holdButton) return;
    if (!current.isHolding) return;
    final sensitivity = _holdSensitivityDuration(step);
    _state = current.copyWith(
      phase: TimerPhase.sensitivity,
      remaining: sensitivity,
      isHolding: false,
    );
    _scheduleTimer(TimerPhase.sensitivity, sensitivity);
  }

  /// User answered a fake call.
  ///
  /// Per cross-cutting Pivot 2 ("fakeCall is event, not pause") the
  /// engine timer keeps running while the voice clip plays — the
  /// FakeCallScreen is a route push, not a pause-and-overlay. This
  /// method is therefore a no-op at the engine level; the UI layer
  /// performs the navigation and audio playback.
  void answerFakeCall() {
    // Intentional no-op (Pivot 2).
  }

  /// User hung up an answered fake call — disarms the session.
  ///
  /// No-op outside a `fakeCall` step.
  void hangUp() {
    final current = _state;
    final stepIndex = switch (current) {
      EngineRunning(:final stepIndex) => stepIndex,
      EnginePaused(:final snapshot) => snapshot.stepIndex,
      _ => null,
    };
    if (stepIndex == null) return;
    if (_steps[stepIndex].type != ChainStepType.fakeCall) return;
    disarm();
  }

  /// User declined the fake call (tapped "Decline"); outcome is
  /// per-step config.
  ///
  /// If `declineIsSafe == true`, decline is treated as disarm. If
  /// `declineIsSafe == false`, the call is registered as a miss; if
  /// retries remain, the step restarts, else the chain advances.
  /// No-op outside a `fakeCall` step.
  void declineFakeCall() {
    final current = _state;
    if (current is! EngineRunning) return;
    final step = _steps[current.stepIndex];
    if (step.type != ChainStepType.fakeCall) return;
    final cfg = step.config;
    // FakeCallConfig.declineIsSafe defaults to true; preserve that
    // when the step has no explicit config.
    final declineIsSafe = cfg is FakeCallConfig ? cfg.declineIsSafe : true;
    if (declineIsSafe) {
      disarm();
      return;
    }
    _cancelTimer();
    _onGraceExpired(current.stepIndex, current.missCount);
  }

  /// Simulation-only fast-forward: fires the current timer
  /// immediately, collapsing the remaining duration of the active
  /// phase to zero.
  ///
  /// Throws [StateError] if the engine is not in simulation mode.
  /// No-op when not [EngineRunning] (idle, paused, ended).
  void leap() {
    if (!isSimulation) {
      throw StateError('leap() requires isSimulation == true');
    }
    final current = _state;
    if (current is! EngineRunning) return;
    // Re-run the timer callback immediately.
    _cancelTimer();
    _onTimerFired(current.stepIndex, current.phase, current.missCount);
  }

  /// Jumps directly to [index] (tests + simulation only).
  ///
  /// Throws [RangeError] if [index] is out of bounds.
  /// Throws [StateError] if the engine is not running or not in
  /// simulation mode (use [start] for the initial entry).
  void jumpToStep(int index) {
    if (!isSimulation) {
      throw StateError('jumpToStep() requires isSimulation == true');
    }
    if (index < 0 || index >= _steps.length) {
      throw RangeError.range(index, 0, _steps.length - 1, 'index');
    }
    if (_state is! EngineRunning) {
      throw StateError(
        'jumpToStep() requires EngineRunning; current state: $_state',
      );
    }
    _cancelTimer();
    _enterStep(index);
  }

  /// Replaces the active chain with the distress chain [steps].
  ///
  /// The main chain is discarded; once this completes,
  /// [isDistressChain] becomes true until the engine reaches an end
  /// state. Per D-SAFETY-17, calling this while already running a
  /// distress chain is a no-op — distress escalation is
  /// non-interruptible.
  ///
  /// [triggerReason] — propagated to `sessionEnded.endReason` so
  /// `SessionLog` records the distinct forensic reason. Defaults to
  /// `TriggerReason.hardwarePanic` for backwards compatibility.
  void replaceWithDistressChain(
    List<ChainStep> steps, {
    TriggerReason triggerReason = TriggerReason.hardwarePanic,
  }) {
    if (_state is EngineEnded) return;
    if (_isDistressChain) return;
    if (steps.isEmpty) {
      throw ArgumentError.value(steps, 'steps', 'must not be empty');
    }
    _cancelTimer();
    _steps = List.of(steps);
    _isDistressChain = true;
    _distressTriggerReason = triggerReason;
    // Emit with no stepIndex — this is a chain-level event.
    _emit(ChainEvent.distressTriggered);
    // If the engine was Idle before, transition through
    // sessionStarted — this supports triggering distress as the
    // first action (e.g., duress PIN before a session is explicit).
    if (_state is EngineIdle) {
      _emit(ChainEvent.sessionStarted);
    }
    _enterStep(0);
  }

  /// Explicit user check-in during a `disguisedReminder` step.
  ///
  /// Spec 01 §Engine API: alias for [disarm] — used by
  /// `SessionController` and `disguisedReminder` UI to express the
  /// "I'm safe" intent. Re-arms the chain to step 0 (does NOT
  /// advance to the next step).
  void checkIn() => disarm();

  /// Early check-in: user responds BEFORE the reminder fires (during
  /// wait phase) on a `disguisedReminder` step.
  ///
  /// Spec 01 §Engine API / Q6 / D-UX-4: re-arms to step 0 (false-alarm
  /// reset). Equivalent to [disarm] semantically — kept as a distinct
  /// entry point so the UI can disambiguate "tapped the reminder
  /// before it surfaced" from "tapped the reminder after it surfaced".
  void earlyCheckIn() => disarm();

  /// Simulation-only: adjust [speedMultiplier] mid-run.
  ///
  /// Spec 01 §Engine API. Currently-scheduled timers keep their
  /// original wall-clock deadlines; the new multiplier applies to
  /// every phase scheduled after this call.
  ///
  /// Throws [StateError] on non-simulation engines. Throws
  /// [ArgumentError] on NaN / infinity / non-positive values.
  void setSpeedMultiplier(double value) {
    if (!isSimulation) {
      throw StateError('setSpeedMultiplier() requires isSimulation == true');
    }
    if (value.isNaN || value.isInfinite || value <= 0) {
      throw ArgumentError.value(
        value,
        'value',
        'must be a finite positive number',
      );
    }
    _speedMultiplier = value.clamp(_speedMultiplierMin, _speedMultiplierMax);
  }

  /// Effective speed multiplier accounting for background clamp.
  ///
  /// Spec 01 §Speed Multiplier (D-UX-2026-04-23 #4): when the app is
  /// pushed to background during a simulation, the OS doze layer
  /// won't actually let the wall clock tick faster than ~60×, so we
  /// cap the *effective* rate at 60× while leaving the stored
  /// `speedMultiplier` untouched. Real sessions are always 1×, so
  /// the cap is effectively a no-op there.
  double get effectiveSpeedMultiplier =>
      _backgroundClamp ? min(_speedMultiplier, 60.0) : _speedMultiplier;

  /// Whether the background clamp is currently engaged. Defaults to
  /// `false`.
  bool get backgroundClamp => _backgroundClamp;

  bool _backgroundClamp = false;

  /// Engages / disengages the background clamp. Used by the
  /// lifecycle controller when the OS pushes the simulation app
  /// into the background. No-op for real (non-simulation) sessions —
  /// real timers are already wall-clock-driven and need no clamp.
  void setBackgroundClamp(bool value) {
    if (!isSimulation) return;
    _backgroundClamp = value;
  }

  /// Restart the current step: cancel the running timer and re-enter
  /// the current step's `wait` phase from scratch.
  ///
  /// Spec 01 §Engine API; used by recovery flows (e.g., crash
  /// restart while within the maxPauseDuration window).
  /// No-op outside [EngineRunning].
  void restartCurrentStep() {
    final current = _state;
    if (current is! EngineRunning) return;
    final index = current.stepIndex;
    _cancelTimer();
    _enterStep(index);
  }

  /// Emits [ChainEvent.stepExecutionFailed] on the event stream.
  /// Called by the orchestrator when a strategy's `executeReal`
  /// throws (D-STRATEGY-2). The chain itself keeps running.
  void emitStepExecutionFailed({
    required int stepIndex,
    required ChainStep step,
  }) {
    _emit(
      ChainEvent.stepExecutionFailed,
      stepIndex: stepIndex,
      stepType: step.type,
    );
  }

  /// Releases internal resources (timers, stream controllers).
  ///
  /// Idempotent. Does not emit any trailing events.
  void dispose() {
    _cancelTimer();
    _pauseExpiryTimer?.cancel();
    _pauseExpiryTimer = null;
    if (!_eventsCtrl.isClosed) {
      _eventsCtrl.close();
    }
  }

  // ----- Internal: state transitions --------------------------------

  void _enterStep(int index) {
    final step = _steps[index];
    // Reset phase tracking; missCount resets on step advance.
    if (step.type == ChainStepType.holdButton) {
      _state = EngineRunning(
        stepIndex: index,
        phase: TimerPhase.holdWait,
        remaining: Duration.zero,
        missCount: 0,
        isHolding: false,
      );
      _emit(ChainEvent.stepStarted, stepIndex: index, stepType: step.type);
      // holdButton waits for the user's first touch; no timer.
      return;
    }
    if (step.type == ChainStepType.hardwareButton) {
      // Not a user-progressible step in the engine; fire the step
      // event then advance immediately. The trigger plumbing lives
      // in `TriggerManager`.
      _state = EngineRunning(
        stepIndex: index,
        phase: TimerPhase.duration,
        remaining: Duration.zero,
        missCount: 0,
        isHolding: false,
      );
      _emit(ChainEvent.stepStarted, stepIndex: index, stepType: step.type);
      _advanceOrComplete(index);
      return;
    }
    // Standard steps: wait → duration → grace.
    final waitDur = _scaledPhaseDuration(step, TimerPhase.wait);
    _state = EngineRunning(
      stepIndex: index,
      phase: TimerPhase.wait,
      remaining: waitDur,
      missCount: 0,
      isHolding: false,
    );
    _emit(ChainEvent.stepStarted, stepIndex: index, stepType: step.type);
    if (waitDur == Duration.zero) {
      _enterDurationPhase(index, 0);
    } else {
      _scheduleTimer(TimerPhase.wait, waitDur);
    }
  }

  void _enterDurationPhase(int index, int missCount) {
    if (_state is EngineEnded) return;
    final step = _steps[index];
    final duration = _scaledPhaseDuration(step, TimerPhase.duration);
    _state = EngineRunning(
      stepIndex: index,
      phase: TimerPhase.duration,
      remaining: duration,
      missCount: missCount,
      isHolding: false,
    );
    // Spec 01 §Disguised Reminder State Machine: emit reminderFired
    // when wait→duration transitions — the reminder overlay is now
    // visible. UI consumers coalesce on this single event.
    if (step.type == ChainStepType.disguisedReminder) {
      _emit(
        ChainEvent.reminderFired,
        stepIndex: index,
        stepType: step.type,
        metadata: {'missCount': missCount},
      );
    }
    if (duration == Duration.zero) {
      _enterGracePhase(index, missCount);
    } else {
      _scheduleTimer(TimerPhase.duration, duration);
    }
  }

  void _enterGracePhase(int index, int missCount) {
    if (_state is EngineEnded) return;
    final step = _steps[index];
    final grace = _scaledPhaseDuration(step, TimerPhase.grace);
    _state = EngineRunning(
      stepIndex: index,
      phase: TimerPhase.grace,
      remaining: grace,
      missCount: missCount,
      isHolding: false,
    );
    if (grace == Duration.zero) {
      _onGraceExpired(index, missCount);
    } else {
      _scheduleTimer(TimerPhase.grace, grace);
    }
  }

  void _onGraceExpired(int index, int missCount) {
    if (_state is EngineEnded) return;
    final newMiss = missCount + 1;
    final step = _steps[index];
    _emit(
      ChainEvent.graceExpired,
      stepIndex: index,
      stepType: step.type,
      metadata: {'missCount': newMiss},
    );
    // Per spec: miss 1 uses the initial attempt; retryCount permits
    // N further retries.  Advance after (retryCount + 1) misses.
    if (newMiss <= step.retryCount) {
      _emit(
        ChainEvent.repeatMissed,
        stepIndex: index,
        stepType: step.type,
        metadata: {'missCount': newMiss},
      );
      // On retry, skip wait — duration → grace per spec §2.
      _enterDurationPhase(index, newMiss);
      return;
    }
    _advanceOrComplete(index);
  }

  void _advanceOrComplete(int index) {
    final next = index + 1;
    if (next >= _steps.length) {
      // End of chain.
      if (_isDistressChain) {
        _emit(ChainEvent.distressCompleted, stepIndex: index);
        // Q19: forensic reason propagation — the distress trigger
        // dictates how the session is recorded.
        endSession(reason: _endReasonForDistress(_distressTriggerReason));
        return;
      }
      _emit(ChainEvent.stepAdvancing, stepIndex: index, nextStep: null);
      endSession(reason: EndReason.chainExhausted);
      return;
    }
    final nextStep = _steps[next];
    _emit(ChainEvent.stepAdvancing, stepIndex: index, nextStep: nextStep);
    _enterStep(next);
  }

  static EndReason _endReasonForDistress(TriggerReason? trigger) =>
      switch (trigger) {
        TriggerReason.hardwarePanic => EndReason.hardwarePanic,
        TriggerReason.duressPin => EndReason.duressPin,
        TriggerReason.wrongPinExhausted => EndReason.wrongPinExhausted,
        null => EndReason.chainExhausted,
      };

  // ----- Internal: timer plumbing -----------------------------------

  void _scheduleTimer(TimerPhase phase, Duration duration) {
    _cancelTimer();
    _phaseStart = _clock();
    _phaseDuration = duration;
    final current = _state;
    if (current is! EngineRunning) return;
    final stepIndex = current.stepIndex;
    final missCount = current.missCount;
    _timer = Timer(duration, () {
      _phaseStart = null;
      _phaseDuration = null;
      _timer = null;
      _onTimerFired(stepIndex, phase, missCount);
    });
  }

  void _onTimerFired(int index, TimerPhase phase, int missCount) {
    if (_state is EngineEnded) return;
    switch (phase) {
      case TimerPhase.wait:
        _enterDurationPhase(index, missCount);
      case TimerPhase.duration:
        _enterGracePhase(index, missCount);
      case TimerPhase.grace:
        _onGraceExpired(index, missCount);
      case TimerPhase.sensitivity:
        // Sensitivity expired without re-hold → start duration
        // countdown (spec §2.2).
        _enterDurationPhase(index, missCount);
      case TimerPhase.holdWait:
        // Hold-wait never schedules a timer; defensively no-op.
        return;
    }
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
    _phaseStart = null;
    _phaseDuration = null;
  }

  Duration _remainingFromTimer(Duration fallback) {
    final start = _phaseStart;
    final total = _phaseDuration;
    if (start == null || total == null) return fallback;
    final elapsed = _clock().difference(start);
    final remaining = total - elapsed;
    if (remaining.isNegative) return Duration.zero;
    return remaining;
  }

  // ----- Internal: phase sizing / jitter ----------------------------

  Duration _scaledPhaseDuration(ChainStep step, TimerPhase phase) {
    final baseSeconds = switch (phase) {
      TimerPhase.wait => step.waitSeconds.toDouble(),
      TimerPhase.duration => step.durationSeconds.toDouble(),
      TimerPhase.grace => step.gracePeriodSeconds.toDouble(),
      TimerPhase.sensitivity => _holdSensitivitySeconds(step),
      TimerPhase.holdWait => 0.0,
    };
    if (baseSeconds <= 0) return Duration.zero;
    final jitterFactor = _jitterFactor(step.randomize);
    // Use the *effective* multiplier so the background clamp caps
    // simulation speed at 60× (spec 01 §Speed Multiplier).
    final scaled = (baseSeconds * jitterFactor) / effectiveSpeedMultiplier;
    // Quantize to microseconds to avoid rounding noise.
    final microseconds = (scaled * Duration.microsecondsPerSecond).round();
    return Duration(microseconds: microseconds);
  }

  Duration _holdSensitivityDuration(ChainStep step) {
    final seconds = _holdSensitivitySeconds(step);
    final scaled = seconds / effectiveSpeedMultiplier;
    final microseconds = (scaled * Duration.microsecondsPerSecond).round();
    return Duration(microseconds: microseconds);
  }

  double _holdSensitivitySeconds(ChainStep step) {
    final cfg = step.config;
    if (cfg is HoldButtonConfig) return cfg.releaseSensitivity;
    return const HoldButtonConfig().releaseSensitivity;
  }

  /// Returns a jitter factor in `[1 - 0.2*r, 1 + 0.2*r]` for
  /// `randomize` factor `r ∈ [0, 1]`.  `r == 0` always returns
  /// exactly 1.0 (no randomness consumed).
  double _jitterFactor(double randomize) {
    if (randomize <= 0) return 1.0;
    final r = randomize.clamp(0.0, 1.0);
    // Map [0, 1) → [-1, 1); FixedRandom(0.5) → 0.0 → factor 1.0.
    final swing = (_random.nextDouble() * 2.0) - 1.0;
    return 1.0 + (0.2 * r * swing);
  }

  // ----- Internal: event emission -----------------------------------

  void _emit(
    ChainEvent event, {
    int? stepIndex,
    ChainStepType? stepType,
    ChainStep? nextStep,
    Map<String, Object?>? metadata,
  }) {
    if (_eventsCtrl.isClosed) return;
    final meta = <String, Object?>{};
    if (metadata != null) meta.addAll(metadata);
    if (nextStep != null) {
      meta['nextStepId'] = nextStep.id;
      meta['nextStepType'] = nextStep.type.name;
    }
    _eventsCtrl.add(
      ChainEventData(
        event: event,
        timestamp: _clock(),
        stepIndex: stepIndex,
        stepType: stepType,
        metadata: Map<String, Object?>.unmodifiable(meta),
      ),
    );
  }

  int? _currentStepIndexOrNull() => switch (_state) {
    EngineRunning(:final stepIndex) => stepIndex,
    EnginePaused(:final snapshot) => snapshot.stepIndex,
    _ => null,
  };
}
