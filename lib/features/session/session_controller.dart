import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import 'package:guardianangela/data/repositories/contacts_repository.dart';
import 'package:guardianangela/domain/engine/chain_event.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/engine/triggers.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/enums/gps_destination_source.dart';
import 'package:guardianangela/domain/enums/pause_reason.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/session_context.dart';
import 'package:guardianangela/domain/models/session_log.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/triggers/disarm_trigger.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/session_log_recorder.dart';

/// Phase of the current step the session UI should render.
///
/// Mirrors [EnginePhase] but only carries the values that matter to the
/// session screen — everything else collapses into [SessionPhase.running].
enum SessionPhase {
  /// Engine has not started yet (just-mounted state).
  idle,

  /// Waiting for the step's wait timer to elapse before the event fires.
  wait,

  /// The step's event is active (e.g., a disguised reminder is on-screen).
  duration,

  /// Step is in grace — last chance to disarm before escalation.
  grace,

  /// Hold-button is awaiting the first press.
  holdWait,

  /// Hold-button is being held by the user.
  holding,

  /// Hold-button released — sensitivity window before grace kicks in.
  sensitivity,

  /// Session has ended cleanly.
  ended,
}

/// Immutable view-model for [SessionScreen].
///
/// Exposed by [SessionController]. Encapsulates everything the screen
/// needs to render in one frame — the screen never reaches into the
/// engine directly.
@immutable
class SessionState {
  /// Creates a [SessionState].
  const SessionState({
    required this.isSimulation,
    required this.elapsedSeconds,
    required this.phase,
    required this.activeChain,
    required this.currentStepIndex,
    required this.missCount,
    required this.isHolding,
    required this.isPaused,
    required this.isDistressChain,
    this.remainingSeconds,
    this.simSpeedMultiplier = 1.0,
    this.simulationSilent = true,
    this.distressConfirmRemaining,
    this.priorInterrupted = false,
    this.priorModeName,
    this.priorStartedAt,
    this.lastError,
    this.needsGpsDestinationPrompt = false,
    this.stealthEnabled = false,
  });

  /// The clean starting state used before the engine is wired.
  const SessionState.initial()
    : this(
        isSimulation: false,
        elapsedSeconds: 0,
        phase: SessionPhase.idle,
        activeChain: const [],
        currentStepIndex: -1,
        missCount: 0,
        isHolding: false,
        isPaused: false,
        isDistressChain: false,
      );

  /// Whether this session is a simulation (orange border + speed slider).
  final bool isSimulation;

  /// Elapsed wall-clock seconds since session start.
  final int elapsedSeconds;

  /// Current phase of the active step.
  final SessionPhase phase;

  /// Chain currently being executed (main or distress).
  final List<ChainStep> activeChain;

  /// Index of the currently executing step, or -1 if no step is active.
  final int currentStepIndex;

  /// Number of grace periods that have expired on the current step.
  final int missCount;

  /// Whether the user is currently holding the hold-button.
  final bool isHolding;

  /// Whether the engine is paused (foreground service / explicit pause).
  final bool isPaused;

  /// Whether the engine is currently in the distress chain.
  final bool isDistressChain;

  /// Remaining seconds in the current phase, when known. Null = not timed.
  final int? remainingSeconds;

  /// Effective simulation speed multiplier (1–1000).
  final double simSpeedMultiplier;

  /// Whether simulation audio is silenced (default true per Extra 49).
  final bool simulationSilent;

  /// Remaining seconds in the distress-confirmation 5-second window.
  ///
  /// Non-null only while the confirmation modal is showing.
  final int? distressConfirmRemaining;

  /// Whether the prior session was interrupted (Extra 13).
  final bool priorInterrupted;

  /// Name of the prior interrupted session's mode.
  final String? priorModeName;

  /// Wall-clock start time of the prior interrupted session.
  final DateTime? priorStartedAt;

  /// Surfaceable error message from the most recent controller action.
  final String? lastError;

  /// Whether the GPS-destination prompt sheet should be shown (Extra 22).
  final bool needsGpsDestinationPrompt;

  /// Whether the resolved [StealthConfig] for the current session has
  /// `enabled == true`. Captured at `startSession` time from the mode
  /// override (or `AppDefaults.stealth`) so every session-screen surface
  /// can re-render in the stealth variant without re-reading providers
  /// — keeps the grace-period slider label, fake music player chrome and
  /// other stealth toggles consistent throughout the session. Resets to
  /// `false` on `endSession`. Spec 04 §Stealth Mode UI.
  final bool stealthEnabled;

  /// The currently executing [ChainStep], or null if no step is active.
  ChainStep? get currentStep {
    if (currentStepIndex < 0 || currentStepIndex >= activeChain.length) {
      return null;
    }
    return activeChain[currentStepIndex];
  }

  /// Returns a copy with the supplied fields replaced.
  SessionState copyWith({
    bool? isSimulation,
    int? elapsedSeconds,
    SessionPhase? phase,
    List<ChainStep>? activeChain,
    int? currentStepIndex,
    int? missCount,
    bool? isHolding,
    bool? isPaused,
    bool? isDistressChain,
    int? remainingSeconds,
    bool clearRemaining = false,
    double? simSpeedMultiplier,
    bool? simulationSilent,
    int? distressConfirmRemaining,
    bool clearDistressConfirm = false,
    bool? priorInterrupted,
    String? priorModeName,
    DateTime? priorStartedAt,
    bool clearPrior = false,
    String? lastError,
    bool clearError = false,
    bool? needsGpsDestinationPrompt,
    bool? stealthEnabled,
  }) => SessionState(
    isSimulation: isSimulation ?? this.isSimulation,
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    phase: phase ?? this.phase,
    activeChain: activeChain ?? this.activeChain,
    currentStepIndex: currentStepIndex ?? this.currentStepIndex,
    missCount: missCount ?? this.missCount,
    isHolding: isHolding ?? this.isHolding,
    isPaused: isPaused ?? this.isPaused,
    isDistressChain: isDistressChain ?? this.isDistressChain,
    remainingSeconds: clearRemaining
        ? null
        : (remainingSeconds ?? this.remainingSeconds),
    simSpeedMultiplier: simSpeedMultiplier ?? this.simSpeedMultiplier,
    simulationSilent: simulationSilent ?? this.simulationSilent,
    distressConfirmRemaining: clearDistressConfirm
        ? null
        : (distressConfirmRemaining ?? this.distressConfirmRemaining),
    priorInterrupted:
        !clearPrior && (priorInterrupted ?? this.priorInterrupted),
    priorModeName: clearPrior ? null : (priorModeName ?? this.priorModeName),
    priorStartedAt: clearPrior ? null : (priorStartedAt ?? this.priorStartedAt),
    lastError: clearError ? null : (lastError ?? this.lastError),
    needsGpsDestinationPrompt:
        needsGpsDestinationPrompt ?? this.needsGpsDestinationPrompt,
    stealthEnabled: stealthEnabled ?? this.stealthEnabled,
  );
}

/// Controller for the session screen.
///
/// Owns a per-session [SessionEngine] and bridges it to the screen.
/// Methods drive engine state transitions; [build] detects an
/// interrupted prior session and seeds the Session-Interrupted Prompt
/// (Extra 13). Engine streams update [state] as events arrive.
class SessionController extends AsyncNotifier<SessionState> {
  SessionEngine? _engine;
  StreamSubscription<ChainEventData>? _eventsSub;
  Timer? _tick;
  SessionLogRecorder? _recorder;
  DateTime? _startedAt;
  String? _markerLogId;

  /// Consecutive wrong-PIN entries for the lifetime of the current session,
  /// shared across every PIN prompt (App PIN, Session End PIN, distress
  /// cancel). Defaults to 0 and resets on every (a) correct PIN entry,
  /// (b) Duress PIN entry, (c) `startSession` / `endSession` transition.
  ///
  /// Spec 06 §Wrong PIN Behavior (R-27): the counter is **in-memory only**
  /// and never persisted — app restart wipes it. C2 only owns the
  /// Session End PIN prompt; the field lives on the controller so the
  /// other prompts can converge on the same counter later.
  int _wrongPinAttempts = 0;

  @override
  Future<SessionState> build() async {
    ref.onDispose(_disposeAll);
    // Detect a prior session whose log was created at start but never
    // received an `endedAt`. Per spec 04 Extra 13 this prompt is
    // informational — we surface the mode name and start time, then
    // delete the orphan log so the prompt only fires once.
    final repo = await ref.read(sessionLogRepositoryProvider.future);
    final all = await repo.getAll();
    final orphans = all.where((l) => l.endedAt == null).toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    if (orphans.isEmpty) {
      return const SessionState.initial();
    }
    final orphan = orphans.first;
    // Clear the orphan so subsequent builds don't re-prompt.
    for (final o in orphans) {
      await repo.deleteById(o.id);
    }
    log(
      'detected interrupted session: mode=${orphan.modeName} '
      'startedAt=${orphan.startedAt}',
      name: 'SessionController',
    );
    return const SessionState.initial().copyWith(
      priorInterrupted: true,
      priorModeName: orphan.modeName,
      priorStartedAt: orphan.startedAt,
    );
  }

  /// Acknowledges the interrupted-session prompt and clears the flags.
  void acknowledgeInterruptedPrompt() {
    final current = state.value ?? const SessionState.initial();
    state = AsyncData(current.copyWith(clearPrior: true));
  }

  /// Starts the engine for [mode].
  ///
  /// Writes an in-progress [SessionLog] row at start so an interrupted
  /// session can be detected on the next launch. The matching log is
  /// finalised on [endSession]. Throws [ArgumentError] when [mode] has
  /// no chain steps (the model invariant already enforces this; the
  /// extra guard surfaces a developer error early).
  Future<void> startSession({
    required SessionMode mode,
    required bool simulate,
    SessionMode? distressMode,
    double speedMultiplier = 1.0,
  }) async {
    if (_engine != null) {
      throw StateError(
        'startSession called while another session is already running.',
      );
    }
    final settings = await ref.read(appSettingsRepositoryProvider).load();
    final profile = await ref.read(userProfileRepositoryProvider).load();
    final templates = settings.defaults.templates;
    final context = SessionContext(
      mode: mode,
      profile: profile,
      reminderTemplates: templates,
    );
    // Write an in-progress marker log so cold launch can detect an
    // interrupted session (Extra 13). The marker is overwritten by the
    // final log on clean end.
    final repo = await ref.read(sessionLogRepositoryProvider.future);
    final markerId = const Uuid().v4();
    _markerLogId = markerId;
    if (!simulate) {
      await repo.upsert(
        SessionLog(
          id: markerId,
          modeId: mode.id,
          modeName: mode.name,
          startedAt: DateTime.now().toUtc(),
          isSimulation: false,
          events: const [],
        ),
      );
    }
    // Every new session starts the in-memory wrong-PIN counter from zero
    // (spec 06 §Wrong PIN Behavior).
    _wrongPinAttempts = 0;
    final maxPause = mode.maxPauseMinutes;
    final engine = SessionEngine(
      chainSteps: mode.chainSteps,
      triggers: Triggers(
        distressTriggers: mode.distressTriggers,
        disarmTriggers: mode.disarmTriggers,
      ),
      allowDisarmAsDistress: mode.allowDisarmAsDistress,
      isSimulation: simulate,
      speedMultiplier: simulate ? speedMultiplier : 1.0,
      maxPauseDuration: maxPause == null ? null : Duration(minutes: maxPause),
    );
    final recorderFactory = await ref.read(sessionLogRecorderProvider.future);
    final recorder = recorderFactory(context);
    _engine = engine;
    _recorder = recorder;
    _startedAt = DateTime.now();
    _eventsSub = engine.events.listen(_onEngineEvent);

    final needsGps = mode.disarmTriggers.any(
      (DisarmTrigger t) =>
          t is GpsArrivalDisarmTrigger &&
          t.destinationSource == GpsDestinationSource.promptAtStart,
    );

    // Resolved StealthConfig is shared between the lock-task call below and
    // every session-screen surface (via SessionState.stealthEnabled).
    final stealth = mode.overrides?.stealth ?? settings.defaults.stealth;

    final next = (state.value ?? const SessionState.initial()).copyWith(
      isSimulation: simulate,
      elapsedSeconds: 0,
      phase: SessionPhase.idle,
      activeChain: mode.chainSteps,
      currentStepIndex: -1,
      missCount: 0,
      isHolding: false,
      isPaused: false,
      isDistressChain: false,
      simSpeedMultiplier: simulate ? speedMultiplier : 1.0,
      simulationSilent: simulate,
      needsGpsDestinationPrompt: needsGps,
      stealthEnabled: stealth.enabled,
      clearPrior: true,
      clearError: true,
      clearRemaining: true,
      clearDistressConfirm: true,
    );
    state = AsyncData(next);
    _distressMode = distressMode;
    // Engage Android lock-task / pinned-app mode when the user enabled
    // it in stealth settings. Non-Android platforms no-op (spec 04
    // §Stealth Settings: lockTaskMode).
    if (stealth.lockTaskMode && !simulate) {
      await ref.read(systemUiServiceProvider).toggleLockTaskMode(true);
    }
    engine.start();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  SessionMode? _distressMode;

  /// Called when the user begins holding the hold-button.
  void holdPressed() {
    _engine?.holdStart();
  }

  /// Called when the user releases the hold-button.
  void holdReleased() {
    _engine?.holdRelease();
  }

  /// Called when the user disarms (taps "I'm safe" / completes the slider).
  void disarm() {
    _engine?.disarm();
  }

  /// Restart the current step after the user dismisses a fake call etc.
  void restartCurrentStep() {
    _engine?.restartCurrentStep();
  }

  /// Called when the user confirms a distress trigger inside the 5s window.
  ///
  /// Replaces the main chain with the distress chain.
  void confirmDistress({EndReason reason = EndReason.hardwarePanic}) {
    final engine = _engine;
    if (engine == null) return;
    final dist = _distressMode;
    if (dist == null) {
      // No distress mode configured — surface as an error rather than
      // silently ignoring (fail-loud per project policy).
      _surfaceError(
        'Distress chain triggered but no distress mode is configured.',
      );
      return;
    }
    engine.replaceWithDistressChain(
      chain: dist.chainSteps,
      triggerReason: reason,
    );
    _clearDistressCountdown();
  }

  /// Called when the user cancels the distress-confirmation modal.
  void cancelDistress() {
    _clearDistressCountdown();
  }

  /// Begins the distress-confirmation countdown.
  ///
  /// Called by [SessionScreen] when a distress trigger fires and the
  /// confirmation modal mounts. The countdown drives the visible timer;
  /// when it hits zero [confirmDistress] is called automatically.
  void beginDistressCountdown({int seconds = 5}) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(distressConfirmRemaining: seconds));
    _startDistressCountdownTimer();
  }

  /// Pause the distress-confirmation countdown without dismissing the
  /// overlay (spec 04 §Distress Confirmation Window).
  ///
  /// Used by the distress-cancel PIN gate: when the user taps Cancel and
  /// a Session End PIN is configured, the 5-second countdown freezes
  /// while the PIN keypad is on screen so the user has the full
  /// 15-second PIN window to enter the PIN.
  /// [distressConfirmRemaining] is preserved as-is; only the periodic
  /// tick is suspended. No-op when the countdown is not running.
  void pauseDistressCountdown() {
    _distressCountdownTimer?.cancel();
    _distressCountdownTimer = null;
  }

  /// Resume a previously paused distress-confirmation countdown.
  ///
  /// Re-arms the periodic tick at the current
  /// [SessionState.distressConfirmRemaining] value. No-op when the
  /// overlay has already been dismissed or no remaining seconds are
  /// tracked.
  void resumeDistressCountdown() {
    final s = state.value;
    if (s == null) return;
    if ((s.distressConfirmRemaining ?? 0) <= 0) return;
    if (_distressCountdownTimer != null) return;
    _startDistressCountdownTimer();
  }

  void _startDistressCountdownTimer() {
    _distressCountdownTimer?.cancel();
    _distressCountdownTimer = Timer.periodic(const Duration(seconds: 1), (
      Timer t,
    ) {
      final s = state.value;
      if (s == null) {
        t.cancel();
        return;
      }
      final remaining = (s.distressConfirmRemaining ?? 0) - 1;
      if (remaining <= 0) {
        t.cancel();
        confirmDistress();
        return;
      }
      state = AsyncData(s.copyWith(distressConfirmRemaining: remaining));
    });
  }

  Timer? _distressCountdownTimer;

  void _clearDistressCountdown() {
    _distressCountdownTimer?.cancel();
    _distressCountdownTimer = null;
    final s = state.value;
    if (s == null) return;
    state = AsyncData(s.copyWith(clearDistressConfirm: true));
  }

  /// Quick-exit trigger. The native side performs `finishAndRemoveTask` /
  /// `exit(0)`; here we finalise the log so encrypted data survives.
  Future<void> triggerQuickExit() async {
    await _finaliseLog(EndReason.userQuit);
  }

  /// Pause the engine. No-op if pause is disabled on the mode.
  void pause({PauseReason reason = PauseReason.userRequested}) {
    _engine?.pause(reason: reason);
  }

  /// Resume the engine.
  void resume() {
    _engine?.resume();
  }

  /// Toggle the simulation silent-mode flag.
  void setSimulationSilent(bool value) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(simulationSilent: value));
  }

  /// Change the simulation speed multiplier (simulation only).
  void setSimulationSpeed(double value) {
    final engine = _engine;
    if (engine == null || !engine.isSimulation) return;
    engine.setSpeedMultiplier(value);
    final s = state.value;
    if (s != null) {
      state = AsyncData(s.copyWith(simSpeedMultiplier: value));
    }
  }

  /// Leap to the next event (simulation only).
  void leap() {
    final engine = _engine;
    if (engine == null || !engine.isSimulation) return;
    engine.leap();
  }

  /// Confirm the GPS destination chosen by the user (Extra 22).
  void setGpsDestination({required double lat, required double lng}) {
    final s = state.value;
    if (s == null) return;
    log('gps destination set: $lat, $lng', name: 'SessionController');
    state = AsyncData(s.copyWith(needsGpsDestinationPrompt: false));
  }

  /// Skip the GPS-destination prompt — disables the trigger for this session.
  void skipGpsDestination() {
    final s = state.value;
    if (s == null) return;
    state = AsyncData(s.copyWith(needsGpsDestinationPrompt: false));
  }

  /// End the session cleanly and finalise the log.
  Future<void> endSession({EndReason reason = EndReason.userQuit}) async {
    final engine = _engine;
    if (engine == null) {
      return;
    }
    // Clearing the counter here closes the session-lifetime scope.
    _wrongPinAttempts = 0;
    engine.endSession(reason: reason);
    await _finaliseLog(reason);
    await _disposeRunOnly();
    // Release lock-task / pinned-app mode if the previous session
    // engaged it. The platform service no-ops on non-Android.
    try {
      await ref.read(systemUiServiceProvider).toggleLockTaskMode(false);
    } catch (e) {
      log('lock-task release failed: $e', name: 'SessionController');
    }
    final s = state.value ?? const SessionState.initial();
    state = AsyncData(
      s.copyWith(
        phase: SessionPhase.ended,
        isPaused: false,
        stealthEnabled: false,
        clearRemaining: true,
      ),
    );
  }

  /// Reset the in-memory wrong-PIN counter to zero.
  ///
  /// Called by PIN prompts on (a) correct PIN entry and (b) Duress PIN
  /// entry — both are "successful" outcomes per spec 06 §Wrong PIN
  /// Behavior even though the Duress branch fires the distress chain.
  void resetWrongPinAttempts() {
    _wrongPinAttempts = 0;
  }

  /// Increment the wrong-PIN counter and forward to the engine.
  ///
  /// Returns the post-increment count so callers can compare against
  /// `AppSettings.wrongPinThreshold`. Emits
  /// `ChainEvent.deceptiveOldPinShown` via [SessionEngine.notifyWrongPin]
  /// so the session log records every misdirection for forensics
  /// (spec 01 §Events Emitted, R-27).
  int notifyWrongPinAttempt() {
    _wrongPinAttempts += 1;
    _engine?.notifyWrongPin(_wrongPinAttempts);
    return _wrongPinAttempts;
  }

  /// Read-only access to the in-memory wrong-PIN counter.
  ///
  /// Exposed for the session-end overlay and for tests; not persisted.
  int get wrongPinAttempts => _wrongPinAttempts;

  Future<void> _finaliseLog(EndReason reason) async {
    final recorder = _recorder;
    if (recorder == null) return;
    try {
      await recorder.finalise(reason);
    } catch (e, st) {
      log('finalise failed: $e\n$st', name: 'SessionController');
    }
    // Remove the in-progress marker now that we have a finalised log
    // recorded by the recorder. If finalisation failed the marker stays
    // and the next launch will surface the interrupted prompt.
    final markerId = _markerLogId;
    if (markerId != null) {
      try {
        final repo = await ref.read(sessionLogRepositoryProvider.future);
        await repo.deleteById(markerId);
      } catch (e) {
        log('marker cleanup failed: $e', name: 'SessionController');
      }
      _markerLogId = null;
    }
    _recorder = null;
  }

  Future<void> _disposeRunOnly() async {
    _tick?.cancel();
    _tick = null;
    _distressCountdownTimer?.cancel();
    _distressCountdownTimer = null;
    await _eventsSub?.cancel();
    _eventsSub = null;
    _engine = null;
  }

  void _disposeAll() {
    _tick?.cancel();
    _distressCountdownTimer?.cancel();
    _eventsSub?.cancel();
    final engine = _engine;
    if (engine != null && !engine.isEnded) {
      engine.endSession();
    }
  }

  void _onTick() {
    final s = state.value;
    final start = _startedAt;
    if (s == null || start == null) return;
    final elapsed = DateTime.now().difference(start).inSeconds;
    final engine = _engine;
    int? remaining;
    if (engine != null && !engine.isPaused) {
      final engineState = _readEngineRunningState();
      if (engineState != null) {
        remaining = engineState.remaining.inSeconds;
      }
    }
    state = AsyncData(
      s.copyWith(
        elapsedSeconds: elapsed,
        remainingSeconds: remaining,
        clearRemaining: remaining == null,
      ),
    );
  }

  EngineRunning? _readEngineRunningState() {
    final engine = _engine;
    if (engine == null) return null;
    // Read the live EngineState via SessionEngine.snapshot so the UI can
    // surface the precise per-phase remaining time without subscribing
    // to engine events.
    return switch (engine.snapshot) {
      EngineRunning(:final currentStepIndex) when currentStepIndex >= 0 =>
        engine.snapshot as EngineRunning,
      // Paused / idle / ended states do not contribute a remaining-time
      // tick to the UI (the screen freezes the prior value).
      EngineIdle() ||
      EnginePaused() ||
      EngineEnded() ||
      EngineRunning() => null,
    };
  }

  void _onEngineEvent(ChainEventData event) {
    final recorder = _recorder;
    recorder?.onEvent(event);
    final s = state.value;
    if (s == null) return;
    switch (event.event) {
      case ChainEvent.sessionStarted:
        state = AsyncData(s.copyWith(phase: SessionPhase.wait));
      case ChainEvent.stepStarted:
        final engine = _engine;
        final isHold = event.stepType == ChainStepType.holdButton;
        state = AsyncData(
          s.copyWith(
            currentStepIndex: event.stepIndex ?? s.currentStepIndex,
            phase: isHold ? SessionPhase.holdWait : SessionPhase.wait,
            isHolding: engine?.isHolding ?? false,
            missCount: 0,
            clearError: true,
          ),
        );
      case ChainEvent.reminderFired:
        state = AsyncData(s.copyWith(phase: SessionPhase.duration));
      case ChainEvent.graceExpired:
        final missCount =
            (event.metadata['missCount'] as int?) ?? s.missCount + 1;
        state = AsyncData(s.copyWith(missCount: missCount));
      case ChainEvent.repeatMissed:
        // Already reflected via missCount in the graceExpired branch.
        break;
      case ChainEvent.stepAdvancing:
        state = AsyncData(s.copyWith(phase: SessionPhase.wait));
      case ChainEvent.userDisarmed:
        state = AsyncData(
          s.copyWith(
            currentStepIndex: 0,
            missCount: 0,
            phase: SessionPhase.wait,
            isHolding: false,
          ),
        );
      case ChainEvent.distressTriggered:
        final dist = _distressMode;
        state = AsyncData(
          s.copyWith(
            isDistressChain: true,
            activeChain: dist?.chainSteps ?? s.activeChain,
            currentStepIndex: 0,
            missCount: 0,
          ),
        );
      case ChainEvent.distressCompleted:
        // No additional UI handling — sessionEnded will fire next.
        break;
      case ChainEvent.sessionPaused:
        state = AsyncData(s.copyWith(isPaused: true));
      case ChainEvent.sessionResumed:
        state = AsyncData(s.copyWith(isPaused: false));
      case ChainEvent.pauseExpired:
        state = AsyncData(s.copyWith(isPaused: false));
      case ChainEvent.sessionEnded:
        final reasonName = event.metadata['reason'] as String?;
        final reason = reasonName == null
            ? EndReason.userQuit
            : EndReason.values.firstWhere(
                (r) => r.name == reasonName,
                orElse: () => EndReason.userQuit,
              );
        unawaited(_finaliseLog(reason));
        state = AsyncData(s.copyWith(phase: SessionPhase.ended));
      case ChainEvent.stepExecutionFailed:
        final msg = event.metadata['error']?.toString() ?? 'unknown error';
        _surfaceError('Step execution failed: $msg');
      case ChainEvent.deceptiveOldPinShown:
        // Surfaced via PIN flow; no extra session UI change.
        break;
    }
  }

  void _surfaceError(String message) {
    final s = state.value ?? const SessionState.initial();
    state = AsyncData(s.copyWith(lastError: message));
  }

  /// Reference to the underlying engine for tests / advanced callers.
  ///
  /// Returns null when no session is active. Mutating the engine outside
  /// the controller's methods is unsupported.
  @visibleForTesting
  SessionEngine? get engine => _engine;

  /// Reference to the recorder for tests; null when no session is active.
  @visibleForTesting
  SessionLogRecorder? get recorder => _recorder;

  /// Id of the in-flight session log, exposed to UI navigation code so the
  /// completed / simulation-summary screens can deep-link to the right
  /// log. Null when no session is active.
  String? get currentSessionLogId => _recorder?.sessionId;

  /// Direct, test-only entry point that loads contacts so we can stub the
  /// contact-count check in widget tests without depending on a database.
  @visibleForTesting
  Future<int> debugContactCount() async {
    final db = await ref.read(databaseProvider.future);
    return (await ContactsRepository(db.contactsDao).getAll()).length;
  }
}

/// Provides the [SessionController].
final sessionControllerProvider =
    AsyncNotifierProvider<SessionController, SessionState>(
      SessionController.new,
    );
