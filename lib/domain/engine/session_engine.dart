import 'dart:async';
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:guardianangela/domain/engine/chain_event.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/trigger_manager.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/enums/pause_reason.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/session_mode.dart';

/// Pure-Dart state machine that walks a [SessionMode]'s chain of
/// [ChainStep]s and drives the safety session lifecycle.
///
/// **Zero Flutter dependencies** — only `dart:async` and `dart:math`. All
/// interaction with Flutter (UI, services, navigation) is handled by
/// `SessionController`, which wraps this engine.
///
/// ## Three-phase timing model
///
/// Each step executes: wait → duration → grace → (advance or retry).
/// The wait phase is skipped on retries (spec 01 §Three-Phase Timing).
///
/// ## Lifecycle
///
/// ```
/// SessionEngine(...) → [start] → [EngineRunning] → ... → [EngineEnded]
/// ```
///
/// See spec 01 §Engine API for the full method contract.
final class SessionEngine {
  /// Creates a session engine.
  ///
  /// [mode] provides the chain steps, triggers, and per-mode flags. The
  /// engine reads [SessionMode.chainSteps] at start time and treats the
  /// list as immutable (invariant 12).
  ///
  /// [isSimulation] enables [leap], [jumpToStep], and
  /// [setSpeedMultiplier]. Real sessions MUST have
  /// [speedMultiplier] == 1.0; any other value throws [ArgumentError].
  ///
  /// [speedMultiplier] defaults to 1.0. In simulation mode it is clamped
  /// to [0.01, 1000.0]; NaN / infinity / non-positive values always throw.
  ///
  /// [maxPauseDuration] sets an upper bound on how long a pause may last
  /// before the engine auto-resumes and emits [ChainEvent.pauseExpired].
  /// Null (default) means unlimited.
  ///
  /// [random] is the randomizer used for ±20% jitter. Pass a deterministic
  /// instance in tests (e.g., `_FixedRandom(0.5)`).
  SessionEngine(
    SessionMode mode, {
    bool isSimulation = false,
    double speedMultiplier = 1.0,
    Duration? maxPauseDuration,
    Random? random,
  }) : _mode = mode,
       _isSimulation = isSimulation,
       _maxPauseDuration = maxPauseDuration,
       _random = random ?? Random() {
    _validateSpeedMultiplier(speedMultiplier, isSimulation);
    _speedMultiplier = speedMultiplier;

    _eventController = StreamController<ChainEventData>.broadcast(sync: true);
  }

  final SessionMode _mode;
  final bool _isSimulation;
  final Duration? _maxPauseDuration;
  final Random _random;

  late final StreamController<ChainEventData> _eventController;

  double _speedMultiplier = 1.0;
  bool _backgroundClamped = false;

  EngineState _state = EngineIdle();

  // Active step execution state.
  List<ChainStep> _activeChain = const [];
  int _currentStepIndex = -1;
  int _missCount = 0;
  bool _isHolding = false;
  bool _isDistressChain = false;
  EndReason? _distressTriggerReason;

  // Active timers — at most one per phase.
  Timer? _phaseTimer;
  Timer? _maxPauseTimer;

  // Trigger manager.
  TriggerManager? _triggerManager;

  // Tracks whether we are in the first execution of a step (not a retry).
  bool _isFirstExecution = true;

  // Tracks phase start time and scheduled duration for accurate remaining calc.
  DateTime? _phaseStartedAt;
  Duration? _phaseTotalDuration;

  // ─── State accessors ──────────────────────────────────────────────────

  /// Index of the currently executing step, or -1 if not started.
  int get currentStepIndex => _currentStepIndex;

  /// The currently executing step, or null if not started or ended.
  ChainStep? get currentStep {
    if (_currentStepIndex < 0 || _currentStepIndex >= _activeChain.length) {
      return null;
    }
    return _activeChain[_currentStepIndex];
  }

  /// Whether [endSession] has been called.
  bool get isEnded => _state is EngineEnded;

  /// Whether the user is currently holding the hold-button.
  bool get isHolding => _isHolding;

  /// Whether simulation mode is enabled.
  bool get isSimulation => _isSimulation;

  /// Whether the engine is currently paused.
  bool get isPaused => _state is EnginePaused;

  /// Whether the engine is currently running the distress chain.
  bool get isDistressChain => _isDistressChain;

  /// The stored speed multiplier (not capped by background clamp).
  double get speedMultiplier => _speedMultiplier;

  /// The effective speed multiplier used for timer math (G-013).
  ///
  /// Returns `min(speedMultiplier, 60.0)` when [setBackgroundClamp] is
  /// engaged; returns [speedMultiplier] otherwise.
  double get effectiveSpeedMultiplier =>
      _backgroundClamped ? min(_speedMultiplier, 60.0) : _speedMultiplier;

  /// Whether the background clamp is currently engaged (G-013).
  bool get isBackgroundClamped => _backgroundClamped;

  /// Broadcast stream of [ChainEventData] events.
  ///
  /// Synchronous (no microtask latency). Closed after [endSession].
  Stream<ChainEventData> get events => _eventController.stream;

  // ─── Lifecycle ────────────────────────────────────────────────────────

  /// Begin session execution at step 0.
  ///
  /// Throws [StateError] if the engine is not in [EngineIdle] state.
  /// Emits [ChainEvent.sessionStarted] then [ChainEvent.stepStarted] for
  /// step 0. See spec 01 §Lifecycle Methods.
  void start() {
    if (_state is! EngineIdle) {
      throw StateError(
        'SessionEngine.start() called on a non-idle engine '
        '(current state: ${_state.runtimeType}). '
        'Create a new SessionEngine for each session.',
      );
    }

    _activeChain = List.unmodifiable(_mode.chainSteps);
    if (_activeChain.isEmpty) {
      throw StateError('SessionMode.chainSteps must not be empty.');
    }

    _emit(ChainEvent.sessionStarted);

    // Start trigger manager.
    _triggerManager = TriggerManager(
      distressTriggers: _mode.distressTriggers,
      disarmTriggers: _mode.disarmTriggers,
      onDistress: (reason) =>
          replaceWithDistressChain(chain: [], triggerReason: reason),
      onDisarm: disarm,
      allowDisarmDuringDistress: _mode.allowDisarmAsDistress,
    );
    _triggerManager!.start();

    _advanceToStep(0);
  }

  /// Clean shutdown — cancels all timers and transitions to [EngineEnded].
  ///
  /// Emits [ChainEvent.sessionEnded] exactly once. Idempotent.
  /// See spec 01 §Lifecycle Methods.
  void endSession({EndReason reason = EndReason.userQuit}) {
    if (_state is EngineEnded) {
      return;
    }
    _cancelTimers();
    _triggerManager?.stop();
    _state = EngineEnded(reason: reason);
    _emit(ChainEvent.sessionEnded, metadata: {'reason': reason.name});
    _eventController.close();
  }

  // ─── Pause / resume ───────────────────────────────────────────────────

  /// Suspend all active timers.
  ///
  /// No-op if already paused or ended. See spec 01 §Pause / Resume.
  void pause({PauseReason reason = PauseReason.userRequested}) {
    if (_state is! EngineRunning) {
      return;
    }
    final running = _state as EngineRunning;

    // Compute accurate remaining time from phase start.
    final remaining = _computeRemaining();
    final snapshot = running.copyWith(remaining: remaining);

    _cancelTimers();
    _state = EnginePaused(snapshot: snapshot, reason: reason);
    _emit(ChainEvent.pausedRequested, metadata: {'reason': reason.name});

    // Start max-pause timer if configured.
    final maxPause = _maxPauseDuration;
    if (maxPause != null) {
      _maxPauseTimer = Timer(maxPause, _onPauseExpired);
    }
  }

  /// Resume after [pause].
  ///
  /// Restarts the saved timer with the exact remaining duration.
  /// No-op if not paused or ended. See spec 01 §Pause / Resume.
  void resume() {
    if (_state is! EnginePaused) {
      return;
    }
    final paused = _state as EnginePaused;
    _maxPauseTimer?.cancel();
    _maxPauseTimer = null;
    _state = paused.snapshot;
    _emit(ChainEvent.resumed);
    _restartCurrentPhase(paused.snapshot.remaining);
  }

  void _onPauseExpired() {
    if (_state is! EnginePaused) {
      return;
    }
    final paused = _state as EnginePaused;
    _state = paused.snapshot;
    _emit(ChainEvent.pauseExpired);
    _emit(ChainEvent.resumed);
    _restartCurrentPhase(paused.snapshot.remaining);
  }

  /// Compute remaining time in the current phase using wall-clock elapsed.
  ///
  /// Returns the remaining duration, clamped to [Duration.zero].
  Duration _computeRemaining() {
    final startedAt = _phaseStartedAt;
    final total = _phaseTotalDuration;
    if (startedAt == null || total == null) {
      return Duration.zero;
    }
    final elapsed = clock.now().difference(startedAt);
    final remaining = total - elapsed;
    return remaining < Duration.zero ? Duration.zero : remaining;
  }

  // ─── Disarm / check-in ────────────────────────────────────────────────

  /// Re-arm the chain to step 0 without ending the session.
  ///
  /// Clears the miss count and re-executes step 0. No-op outside
  /// [EngineRunning]. See spec 01 §Disarm / Check-in.
  void disarm() {
    if (_state is! EngineRunning) {
      return;
    }
    final fromIndex = _currentStepIndex;
    _cancelTimers();
    _missCount = 0;
    _isHolding = false;
    _emit(ChainEvent.userDisarmed, metadata: {'fromStepIndex': fromIndex});
    _advanceToStep(0);
  }

  /// Alias for [disarm]. Expresses the "I'm safe" intent.
  void checkIn() => disarm();

  /// Called when user taps a disguised-reminder notification during the wait
  /// phase (before the reminder has fired).
  ///
  /// No-op if: not running, not a disguisedReminder step, not in wait phase,
  /// or [resetOnEarlyCheckIn] is false. See spec 01 §Early Check-in (D4).
  void earlyCheckIn({bool resetOnEarlyCheckIn = true}) {
    if (_state is! EngineRunning) {
      return;
    }
    final running = _state as EngineRunning;
    if (currentStep?.type != ChainStepType.disguisedReminder) {
      return;
    }
    if (running.phase != EnginePhase.wait) {
      return;
    }
    if (!resetOnEarlyCheckIn) {
      return;
    }
    disarm();
  }

  // ─── Hold-button interaction ──────────────────────────────────────────

  /// Called when the user begins holding the hold-button.
  ///
  /// No-op if not a holdButton step or if already holding.
  /// Triggers disarm if called during the grace phase.
  /// See spec 01 §Hold Button Methods.
  void holdStart() {
    if (_state is! EngineRunning) {
      return;
    }
    if (currentStep?.type != ChainStepType.holdButton) {
      return;
    }
    if (_isHolding) {
      return; // Edge-triggered: no-op if already holding.
    }

    final running = _state as EngineRunning;

    // Re-hold during grace = disarm.
    if (running.phase == EnginePhase.grace) {
      _isHolding = true;
      _state = running.copyWith(isHolding: true);
      disarm();
      return;
    }

    // Re-hold during duration or sensitivity = cancel countdown, resume hold.
    _isHolding = true;
    _state = running.copyWith(isHolding: true);
    _cancelTimers();
    // Engine remains running at the same step, waiting for next release.
  }

  /// Called when the user releases the hold-button.
  ///
  /// No-op if not a holdButton step or if not currently holding.
  /// Starts the sensitivity timer. See spec 01 §Hold Button Methods.
  void holdRelease() {
    if (_state is! EngineRunning) {
      return;
    }
    if (currentStep?.type != ChainStepType.holdButton) {
      return;
    }
    if (!_isHolding) {
      return; // Edge-triggered: no-op if not holding.
    }

    _isHolding = false;
    final step = currentStep!;
    final running = _state as EngineRunning;
    _state = running.copyWith(isHolding: false);

    // Start sensitivity timer.
    final sensitivitySeconds = _holdSensitivity(step);
    final sensitivityDuration = _adjustDuration(
      Duration(milliseconds: (sensitivitySeconds * 1000).round()),
    );
    _startPhaseTimer(
      sensitivityDuration,
      EnginePhase.sensitivity,
      _onSensitivityExpired,
    );
  }

  void _onSensitivityExpired() {
    // If user re-held during sensitivity, holdStart() was called and
    // cancelled this timer — so if we reach here the release was real.
    if (currentStep?.type != ChainStepType.holdButton) {
      return;
    }
    final step = currentStep!;
    final durationSeconds = _jitterAndAdjust(
      step.durationSeconds,
      _shouldRandomizeDuration(step),
    );
    _startPhaseTimer(durationSeconds, EnginePhase.duration, _onDurationExpired);
  }

  double _holdSensitivity(ChainStep step) {
    if (step.config case final cfg?) {
      try {
        // Access releaseSensitivity via dynamic dispatch.
        return (cfg as dynamic).releaseSensitivity as double;
      } catch (_) {
        // Fallthrough to default.
      }
    }
    return 1.0; // Default 1.0s sensitivity window.
  }

  // ─── Fake call interaction ────────────────────────────────────────────

  /// Called when the user answers the fake call.
  ///
  /// **No-op at the engine level** — Pivot 2 (fakeCall is an event, not a
  /// pause). The UI performs navigation and audio playback independently.
  /// The engine timer keeps running. See spec 01 §Fake Call Methods.
  void answerFakeCall() {
    // Deliberate no-op. See spec 01 §Fake Call Methods (Pivot 2).
  }

  /// Called when the user hangs up after answering the fake call.
  ///
  /// Fires [disarm], resetting the chain to step 0.
  void hangUp() {
    disarm();
  }

  /// Restart the current step after a decline (when declineIsSafe = false).
  ///
  /// Preserves the miss count; applies the grace period before re-execution.
  void restartCurrentStep() {
    if (_state is! EngineRunning) {
      return;
    }
    _cancelTimers();
    final step = currentStep;
    if (step == null) {
      return;
    }
    final graceDuration = _jitterAndAdjust(
      step.gracePeriodSeconds,
      _shouldRandomizeGrace(step),
    );
    _startPhaseTimer(graceDuration, EnginePhase.grace, () {
      // After grace, retry (skip wait).
      _isFirstExecution = false;
      _executeStep(_currentStepIndex);
    });
  }

  // ─── Hardware panic ───────────────────────────────────────────────────

  /// Called when hardware panic (e.g., 5× volume press) is detected.
  ///
  /// This is the step-advance path (for HardwareButton chain steps).
  /// For trigger-based panic, [TriggerManager.notifyHardwarePanic] calls
  /// [replaceWithDistressChain] directly.
  void advanceFromHardwarePanic() {
    if (_state is! EngineRunning) {
      return;
    }
    _cancelTimers();
    _advanceToNext();
  }

  // ─── Distress chain ───────────────────────────────────────────────────

  /// Replace the main chain with the distress chain.
  ///
  /// The main chain stops permanently. The distress chain runs from step 0.
  /// The engine ends with [triggerReason] when the distress chain completes.
  ///
  /// [allowDisarmAsDistress] is read from [SessionMode.allowDisarmAsDistress]
  /// (G-014). When the distress mode's own steps are provided from outside,
  /// pass them via [chain]; passing an empty list signals that the caller
  /// must have already set the chain on the mode (the engine re-reads
  /// [SessionMode.chainSteps] when [chain] is empty and the mode has
  /// [isDistressMode] = true, but in practice the controller resolves and
  /// passes the steps).
  void replaceWithDistressChain({
    required List<ChainStep> chain,
    required EndReason triggerReason,
  }) {
    if (_state is EngineEnded) {
      return;
    }
    // If already in distress, ignore (A4 — second duress PIN press is no-op).
    if (_isDistressChain) {
      return;
    }

    _cancelTimers();
    _isDistressChain = true;
    _distressTriggerReason = triggerReason;

    _emit(
      ChainEvent.replaceWithDistress,
      metadata: {'triggerReason': triggerReason.name},
    );

    _triggerManager?.enterDistressMode();

    // Set the active chain to the distress steps.
    _activeChain = chain.isNotEmpty
        ? List.unmodifiable(chain)
        : List.unmodifiable(_mode.chainSteps);

    _missCount = 0;
    _isHolding = false;
    _isFirstExecution = true;

    // Start distress chain from step 0.
    _state = EngineIdle(); // Reset to allow advanceToStep.
    _currentStepIndex = -1;
    // Manually transition to running without emitting sessionStarted again.
    _advanceToStep(0);
  }

  // ─── Wrong-PIN notification ───────────────────────────────────────────

  /// Notify the engine that a wrong PIN was entered.
  ///
  /// Emits [ChainEvent.deceptiveOldPinShown] with
  /// `metadata['attemptCount'] = attemptCount`. Called by
  /// [SessionController] after incrementing its own wrong-PIN counter.
  /// See spec 01 §Events Emitted.
  void notifyWrongPin(int attemptCount) {
    if (_state is EngineEnded) {
      return;
    }
    _emit(
      ChainEvent.deceptiveOldPinShown,
      metadata: {'attemptCount': attemptCount},
    );
  }

  // ─── Background clamp (G-013) ─────────────────────────────────────────

  /// Engage or release the background speed cap (G-013).
  ///
  /// When [engaged] is true, [effectiveSpeedMultiplier] returns
  /// `min(speedMultiplier, 60.0)`. No-op for non-simulation engines at
  /// runtime (real timers are wall-clock driven and unaffected).
  ///
  /// Called by [SessionController] on [AppLifecycleState] changes.
  void setBackgroundClamp(bool engaged) {
    _backgroundClamped = engaged;
  }

  // ─── Simulation-only methods ──────────────────────────────────────────

  /// Collapse the current timer to zero immediately.
  ///
  /// Simulation mode only. Throws [StateError] on real sessions.
  /// No-op when not [EngineRunning]. See spec 01 §Simulation.
  void leap() {
    if (!_isSimulation) {
      throw StateError(
        'SessionEngine.leap() is only available in simulation mode.',
      );
    }
    if (_state is! EngineRunning) {
      return;
    }
    _phaseTimer?.cancel();
    _phaseTimer = null;
    _fireCurrentPhase();
  }

  /// Jump directly to step [index].
  ///
  /// Simulation mode only. Throws [StateError] on real sessions or when
  /// not running. Throws [RangeError] for out-of-range index.
  /// Resets miss count to 0. See spec 01 §Simulation.
  void jumpToStep(int index) {
    if (!_isSimulation) {
      throw StateError(
        'SessionEngine.jumpToStep() is only available in simulation mode.',
      );
    }
    if (_state is! EngineRunning) {
      throw StateError(
        'SessionEngine.jumpToStep() requires the engine to be running.',
      );
    }
    if (index < 0 || index >= _activeChain.length) {
      throw RangeError.range(index, 0, _activeChain.length - 1, 'index');
    }
    _cancelTimers();
    _missCount = 0;
    _isFirstExecution = true;
    _advanceToStep(index);
  }

  /// Change the speed multiplier mid-session (simulation mode only).
  ///
  /// Throws [StateError] on non-simulation engines.
  /// Throws [ArgumentError] for NaN, infinity, or non-positive values.
  /// Clamped to [0.01, 1000.0].
  void setSpeedMultiplier(double value) {
    if (!_isSimulation) {
      throw StateError(
        'SessionEngine.setSpeedMultiplier() is only available in '
        'simulation mode.',
      );
    }
    _validateSpeedMultiplier(value, true);
    _speedMultiplier = value;
  }

  // ─── Internal step execution ──────────────────────────────────────────

  void _advanceToStep(int index) {
    _cancelTimers();
    _currentStepIndex = index;
    _missCount = 0;
    _isHolding = false;
    _isFirstExecution = true;

    final running = EngineRunning(
      currentStepIndex: index,
      remaining: Duration.zero,
      missCount: 0,
      isHolding: false,
      phase: EnginePhase.wait,
    );
    _state = running;

    _executeStep(index);
  }

  void _executeStep(int index) {
    final step = _activeChain[index];

    _emit(ChainEvent.stepStarted, stepIndex: index, stepType: step.type);

    if (step.type == ChainStepType.holdButton) {
      _executeHoldButtonStep(step, index);
    } else {
      _executeTimedStep(step, index);
    }
  }

  void _executeHoldButtonStep(ChainStep step, int index) {
    // HoldButton step: wait for user to call holdStart()/holdRelease().
    // Enter the holdWait phase — engine waits for user interaction.
    _state = EngineRunning(
      currentStepIndex: index,
      remaining: Duration.zero,
      missCount: _missCount,
      isHolding: false,
      phase: EnginePhase.holdWait,
    );
    // No timer started — driven by holdStart()/holdRelease() callbacks.
  }

  void _executeTimedStep(ChainStep step, int index) {
    // For disguisedReminder: wait phase == interval between check-ins.
    // For all others: skip wait phase on retries.
    final shouldWait = step.waitSeconds > 0 && _isFirstExecution;

    if (shouldWait) {
      final waitDuration = _jitterAndAdjust(
        step.waitSeconds,
        _shouldRandomizeInterval(step),
      );
      _startPhaseTimer(waitDuration, EnginePhase.wait, _onWaitExpired);
    } else {
      _onWaitExpired();
    }
  }

  void _onWaitExpired() {
    if (_state is! EngineRunning) {
      return;
    }
    final step = currentStep;
    if (step == null) {
      return;
    }

    _emit(
      ChainEvent.stepFired,
      stepIndex: _currentStepIndex,
      stepType: step.type,
    );

    final durationSeconds = _jitterAndAdjust(
      step.durationSeconds,
      _shouldRandomizeDuration(step),
    );
    _startPhaseTimer(durationSeconds, EnginePhase.duration, _onDurationExpired);
  }

  void _onDurationExpired() {
    if (_state is! EngineRunning) {
      return;
    }
    final step = currentStep;
    if (step == null) {
      return;
    }
    final graceSeconds = _jitterAndAdjust(
      step.gracePeriodSeconds,
      _shouldRandomizeGrace(step),
    );
    _startPhaseTimer(graceSeconds, EnginePhase.grace, _onGraceExpired);
  }

  void _onGraceExpired() {
    if (_state is! EngineRunning) {
      return;
    }
    final step = currentStep;
    if (step == null) {
      return;
    }

    _missCount++;
    _emit(
      ChainEvent.stepMissed,
      stepIndex: _currentStepIndex,
      stepType: step.type,
      metadata: {'missCount': _missCount, 'stepIndex': _currentStepIndex},
    );

    if (_missCount <= step.retryCount) {
      // Retry: skip wait phase.
      _isFirstExecution = false;
      _executeStep(_currentStepIndex);
    } else {
      _advanceToNext();
    }
  }

  void _advanceToNext() {
    final nextIndex = _currentStepIndex + 1;
    if (nextIndex >= _activeChain.length) {
      _emit(ChainEvent.chainExhausted);
      final endReason = _isDistressChain
          ? (_distressTriggerReason ?? EndReason.chainExhausted)
          : EndReason.chainExhausted;
      endSession(reason: endReason);
      return;
    }
    _advanceToStep(nextIndex);
  }

  // ─── Phase timer management ───────────────────────────────────────────

  void _startPhaseTimer(
    Duration duration,
    EnginePhase phase,
    void Function() callback,
  ) {
    _phaseTimer?.cancel();

    _phaseStartedAt = clock.now();
    _phaseTotalDuration = duration;

    // Update state with phase + remaining.
    if (_state is EngineRunning) {
      _state = (_state as EngineRunning).copyWith(
        phase: phase,
        remaining: duration,
      );
    }

    if (duration <= Duration.zero) {
      // Fire immediately on next microtask to avoid stack overflows.
      _phaseTimer = Timer(Duration.zero, callback);
    } else {
      _phaseTimer = Timer(duration, callback);
    }
  }

  void _cancelTimers() {
    _phaseTimer?.cancel();
    _phaseTimer = null;
    _maxPauseTimer?.cancel();
    _maxPauseTimer = null;
  }

  void _restartCurrentPhase(Duration remaining) {
    if (_state is! EngineRunning) {
      return;
    }
    final running = _state as EngineRunning;
    _startPhaseTimer(
      remaining,
      running.phase,
      _phaseCallbackFor(running.phase),
    );
  }

  void Function() _phaseCallbackFor(EnginePhase phase) => switch (phase) {
    EnginePhase.wait => _onWaitExpired,
    EnginePhase.duration => _onDurationExpired,
    EnginePhase.grace => _onGraceExpired,
    EnginePhase.sensitivity => _onSensitivityExpired,
    EnginePhase.holdWait =>
      () {}, // holdWait is user-driven — no timer to restart.
  };

  /// Fire whichever callback corresponds to the current phase.
  ///
  /// Used by [leap] to collapse the running timer.
  void _fireCurrentPhase() {
    if (_state is! EngineRunning) {
      return;
    }
    final phase = (_state as EngineRunning).phase;
    _phaseCallbackFor(phase)();
  }

  // ─── Randomization helpers ────────────────────────────────────────────

  bool _shouldRandomizeInterval(ChainStep step) {
    if (step.config case final cfg?) {
      final dynamic config = cfg;
      try {
        return (config as dynamic).randomizeInterval as bool;
      } catch (_) {}
    }
    return step.randomize;
  }

  bool _shouldRandomizeDuration(ChainStep step) {
    if (step.config case final cfg?) {
      final dynamic config = cfg;
      try {
        // fakeCall uses randomizeRingDuration; others use randomizeDuration.
        if (step.type == ChainStepType.fakeCall) {
          return (config as dynamic).randomizeRingDuration as bool;
        }
        return (config as dynamic).randomizeDuration as bool;
      } catch (_) {}
    }
    return step.randomize;
  }

  bool _shouldRandomizeGrace(ChainStep step) {
    if (step.config case final cfg?) {
      final dynamic config = cfg;
      try {
        return (config as dynamic).randomizeGrace as bool;
      } catch (_) {}
    }
    return step.randomize;
  }

  /// Apply ±20% jitter (if enabled) and then divide by the effective speed
  /// multiplier.
  ///
  /// Formula: factor = 0.8 + random.nextDouble() * 0.4 (range 0.8–1.2).
  /// With [_FixedRandom(0.5)]: factor = 0.8 + 0.5 * 0.4 = 1.0 (no jitter).
  Duration _jitterAndAdjust(int seconds, bool randomize) {
    double value = seconds.toDouble();
    if (randomize) {
      final factor = 0.8 + _random.nextDouble() * 0.4;
      value *= factor;
    }
    final effective = effectiveSpeedMultiplier;
    if (effective > 0) {
      value /= effective;
    }
    return Duration(
      microseconds: (value * Duration.microsecondsPerSecond).round(),
    );
  }

  Duration _adjustDuration(Duration d) {
    final effective = effectiveSpeedMultiplier;
    if (effective <= 0) {
      return d;
    }
    final micros = (d.inMicroseconds / effective).round();
    return Duration(microseconds: micros);
  }

  // ─── Event emission ───────────────────────────────────────────────────

  void _emit(
    ChainEvent event, {
    int? stepIndex,
    ChainStepType? stepType,
    Map<String, Object?>? metadata,
  }) {
    if (_eventController.isClosed) {
      return;
    }
    _eventController.add(
      ChainEventData(
        event,
        timestamp: clock.now(),
        stepIndex:
            stepIndex ?? (_currentStepIndex >= 0 ? _currentStepIndex : null),
        stepType: stepType ?? currentStep?.type,
        metadata: metadata,
      ),
    );
  }

  // ─── Validation ───────────────────────────────────────────────────────

  static void _validateSpeedMultiplier(double value, bool isSimulation) {
    if (value.isNaN || value.isInfinite) {
      throw ArgumentError.value(
        value,
        'speedMultiplier',
        'Must not be NaN or infinite.',
      );
    }
    if (value <= 0) {
      throw ArgumentError.value(value, 'speedMultiplier', 'Must be positive.');
    }
    if (!isSimulation && value != 1.0) {
      throw ArgumentError.value(
        value,
        'speedMultiplier',
        'Real sessions must use speedMultiplier == 1.0.',
      );
    }
    if (isSimulation) {
      // Clamp is applied silently but values outside [0.01, 1000.0] throw.
      if (value < 0.01 || value > 1000.0) {
        throw ArgumentError.value(
          value,
          'speedMultiplier',
          'Must be in [0.01, 1000.0] for simulation.',
        );
      }
    }
  }
}
