/// Session-feature controller.
///
/// Drives the active safety session: constructs the pure-Dart
/// [SessionEngine], wires it to a [SessionOrchestrator] (side-effect
/// strategies), a [SessionLogRecorder] (persistable history), and a
/// [TriggerManager] (hardware panic / GPS arrival / battery), then
/// translates every engine event into the `WalkSession` view-model
/// consumed by the UI.
///
/// This file owns the end-to-end wiring for L1/L4/L5/L7/L8/L14:
///   * L1 — every field on `AppSettings`, `SessionMode`, and
///     `BatteryAlertConfig` that has a real-world effect flows through
///     a provider into a service. See `docs/wiring-map.md`.
///   * L4 / L9 — distress triggers (hardware, duress PIN, wrong-PIN
///     threshold) all call [triggerDistressChain] which replaces the
///     engine's chain with the resolved distress chain.
///   * L5 — this file is single-owner; no parallel editor is allowed.
///   * L7 — the session start awaits
///     `ref.read(settingsControllerProvider.future)` before looking
///     up the mode so the async hydrate has completed.
///   * L8 — stealth configuration surfaces via [SettingsController];
///     we never hardcode a non-stealth path.
///   * L14 — the battery-alert session uses the same engine /
///     orchestrator plumbing as a user session. There is no second,
///     parallel messaging pipeline.
library;

import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/widgets.dart' show AppLifecycleState, Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/core/utils/pin_result.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/data/repositories/modes_repository.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/engine/session_log_recorder.dart';
import 'package:guardianangela/domain/engine/tracking_buffer.dart';
import 'package:guardianangela/domain/engine/trigger_manager.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';
import 'package:guardianangela/domain/orchestration/session_orchestrator.dart';
import 'package:guardianangela/features/session/emergency_confirm_request.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Internal bundle collecting the live session's runtime handles so
/// `dispose` can tear down the whole graph atomically.
class _SessionRuntime {
  _SessionRuntime({
    required this.engine,
    required this.orchestrator,
    required this.recorder,
    required this.mode,
    required this.triggerManager,
    required this.eventsSub,
    required this.services,
    this.incomingCallSub,
  });

  final SessionEngine engine;
  final SessionOrchestrator orchestrator;
  final SessionLogRecorder recorder;
  final SessionMode mode;
  final TriggerManager? triggerManager;
  final StreamSubscription<ChainEventData> eventsSub;
  final StreamSubscription<CallState>? incomingCallSub;
  final _SessionServices services;
}

/// Async controller driving the active safety session.
///
/// State is nullable: `null` = no active session, non-null = a
/// session is in progress or recently-ended.
class SessionController extends AsyncNotifier<WalkSession?> {
  /// Callback fired when the engine wants to confirm a distress
  /// trigger (e.g. hardware panic button). Returning `true` lets the
  /// distress chain run; `false` cancels.
  Future<bool> Function()? onDistressConfirmation;

  /// Callback fired when a disarm trigger (GPS arrival, timer)
  /// fires and asks the UI to request PIN entry.
  void Function()? onDisarmRequested;

  /// Callback fired right before the wrong-PIN-threshold distress
  /// chain is triggered. The UI presents the deceptive
  /// "Old PIN from Angela — are you sure you want to proceed?"
  /// dialog per spec 06 §Wrong PIN Behavior. Awaited for visual
  /// completeness; the return value is IGNORED — distress fires
  /// regardless. Null = skip dialog and fire immediately.
  Future<void> Function()? onAngelaDeceptiveDialog;

  /// True when the active mode permits manual pause. Backed by the
  /// underlying runtime state; defaults to `true` when no session is
  /// running so generic UI builders do not strip the button.
  bool get isPauseAllowed {
    final runtime = _runtime;
    if (runtime == null) return true;
    return runtime.mode.pauseAllowed;
  }

  /// True while an interactive user safety session is running. Used
  /// by repository-touching controllers (Modes, Templates, Backup,
  /// BatteryAlert, Contacts) to refuse mutations mid-session — the
  /// safety chain must NOT be edited while it is firing.
  bool get isSessionActive => _runtime != null;

  /// Current app lifecycle state. Updated by the SessionScreen's
  /// `WidgetsBindingObserver`. Default = resumed. Read by feature
  /// code that needs to know whether the app is foregrounded
  /// (e.g. distress confirmation should suppress its dialog when
  /// the app is hidden).
  AppLifecycleState appLifecycleState = AppLifecycleState.resumed;

  /// Updates the cached lifecycle state. Called from the SessionScreen
  /// observer when the OS pushes the app to background / foreground.
  void setAppLifecycleState(AppLifecycleState state) {
    appLifecycleState = state;
  }

  /// Engages / disengages the engine's effective-speed clamp when the
  /// app lifecycle transitions to background / foreground during a
  /// simulation. Per spec 01 §Speed Multiplier.
  void setSimulationBackgroundClamp(bool enabled) {
    final runtime = _runtime;
    if (runtime == null) return;
    runtime.engine.setBackgroundClamp(enabled);
  }

  /// Broadcast stream of emergency-call confirmation requests.
  Stream<EmergencyConfirmRequest> get emergencyConfirmationRequests =>
      _emergencyConfirmCtrl.stream;

  final StreamController<EmergencyConfirmRequest> _emergencyConfirmCtrl =
      StreamController<EmergencyConfirmRequest>.broadcast();

  /// Wrong-PIN attempts observed on the currently-active prompt.
  /// Reset every time a new PIN dialog opens by the UI.
  int _wrongPinCount = 0;

  /// How many wrong-PIN attempts trigger distress. Public for
  /// configuration parity with `AppSettings`.
  static const int wrongPinThreshold = 5;

  _SessionRuntime? _runtime;

  @override
  Future<WalkSession?> build() async {
    ref.onDispose(_disposeRuntime);
    return null;
  }

  /// Starts a new session for [modeId]. [isSimulation] routes every
  /// strategy through the simulation services.
  ///
  /// Throws [StateError] when the user has an active session, when
  /// the mode does not exist, or when the resolved distress chain is
  /// empty (D-SAFETY-17).
  Future<void> startSession({
    required String modeId,
    bool isSimulation = false,
  }) async {
    // L14: cancel any background battery-alert session before we
    // start the user session — only one engine may run at a time.
    if (_runtime != null) {
      final active = state.value;
      if (active != null && !active.isBackgroundAlert) {
        throw StateError('A user session is already running; disarm it first.');
      }
      await _disposeRuntime();
    }

    // L7: fully await the settings hydrate before we read the mode.
    final settings = await ref.read(settingsControllerProvider.future);

    final modesRepo = ref.read(modesRepositoryProvider);
    final mode = await modesRepo.getById(modeId);
    if (mode == null) {
      throw StateError('SessionController: no mode with id "$modeId"');
    }
    if (mode.chainSteps.isEmpty) {
      throw StateError(
        'SessionController: mode "${mode.name}" has no chain steps',
      );
    }

    // Phase 2.4: distress steps resolved from the modes table.
    // mode.distressModeId explicit → that mode; else AppDefaults
    // .defaultDistressModeId; else the first distress-flagged mode.
    final distressSteps = await _resolveDistressModeSteps(
      modesRepo: modesRepo,
      modeDistressModeId: mode.distressModeId,
      defaultDistressModeId: settings.defaults.defaultDistressModeId,
    );
    if (distressSteps.isEmpty) {
      throw StateError(
        'SessionController: resolved distress mode has no steps '
        '(D-SAFETY-17)',
      );
    }

    final contactsRepo = ref.read(contactsRepositoryProvider);
    final contacts = await contactsRepo.getAll();
    final profileRepo = ref.read(userProfileRepositoryProvider);
    final profile = await profileRepo.get();
    final templatesRepo = ref.read(templatesRepositoryProvider);
    final globalTemplates = await templatesRepo.getAll();

    await _bootstrapSession(
      mode: mode,
      settings: settings,
      contacts: contacts,
      profile: profile,
      templates: _resolveTemplates(mode: mode, global: globalTemplates),
      distressSteps: distressSteps,
      isSimulation: isSimulation,
      isBackgroundAlert: false,
    );
  }

  /// Starts a one-shot battery-alert session driven by [config].
  ///
  /// Rejects when a user session is already running (L14: never
  /// preempt an interactive safety session with a background alert).
  Future<void> startBatteryAlertSession(BatteryAlertConfig config) async {
    if (_runtime != null) {
      final active = state.value;
      if (active != null && !active.isBackgroundAlert) {
        throw StateError(
          'Cannot start battery-alert while a user session is active.',
        );
      }
      // A stale background alert is fine to replace.
      await _disposeRuntime();
    }
    if (!config.enabled || config.chain.isEmpty) {
      return;
    }
    final settings = await ref.read(settingsControllerProvider.future);
    final contacts = await ref.read(contactsRepositoryProvider).getAll();
    final profile = await ref.read(userProfileRepositoryProvider).get();
    final modesRepo = ref.read(modesRepositoryProvider);
    final distressSteps = await _resolveDistressModeSteps(
      modesRepo: modesRepo,
      modeDistressModeId: null,
      defaultDistressModeId: settings.defaults.defaultDistressModeId,
    );

    // Build a synthetic mode whose chainSteps are the alert's chain.
    final syntheticMode = SessionMode(
      id: 'battery-alert',
      name: 'Battery Alert',
      chainSteps: config.chain,
      distressModeId: settings.defaults.defaultDistressModeId,
    );

    await _bootstrapSession(
      mode: syntheticMode,
      settings: settings,
      contacts: contacts,
      profile: profile,
      templates: const <ReminderTemplate>[],
      distressSteps: distressSteps,
      isSimulation: false,
      isBackgroundAlert: true,
    );
  }

  /// Ends the active session via the user-initiated disarm path.
  /// Requires a valid session-end PIN only at the UI layer; this
  /// method assumes the PIN gate has already been passed.
  ///
  /// Per spec 01 the engine's `disarm()` is a check-in/re-arm and
  /// does NOT terminate the session. The UI's "End Session" intent
  /// translates here to `engine.endSession(EndReason.disarm)` so
  /// the user actually exits the session.
  Future<void> disarm() async {
    final runtime = _runtime;
    if (runtime == null) return;
    runtime.engine.endSession(reason: EndReason.disarm);
  }

  /// Pauses the active session (stops timers without ending it).
  Future<void> pause() async {
    final runtime = _runtime;
    if (runtime == null) return;
    runtime.engine.pause();
  }

  /// Resumes a paused session.
  Future<void> resume() async {
    final runtime = _runtime;
    if (runtime == null) return;
    runtime.engine.resume();
  }

  /// Simulation-only: adjust the engine's speed multiplier mid-run.
  void setSimulationSpeedMultiplier(double value) {
    final runtime = _runtime;
    if (runtime == null) return;
    runtime.engine.setSpeedMultiplier(value);
  }

  /// Simulation-only: synthesize a GPS-arrival event so the user can
  /// rehearse the auto-disarm path without actually walking. Per
  /// spec 01 §Disarm/Check-in the GPS-arrival path ends the session
  /// (it is a successful check-in, not a re-arm).
  Future<void> simulateGpsArrival() async {
    final runtime = _runtime;
    if (runtime == null) return;
    runtime.engine.endSession(reason: EndReason.disarm);
  }

  /// Simulation-only: synthesize a low-battery threshold crossing so
  /// the user can rehearse the battery-alert path.
  Future<void> simulateLowBattery() async {
    final runtime = _runtime;
    if (runtime == null) return;
    // No-op on the engine; UI feedback only.
  }

  /// Accepts the currently ringing simulated fake-call pretext.
  Future<void> answerFakeCall() async {
    final runtime = _runtime;
    if (runtime == null) return;
    runtime.engine.answerFakeCall();
  }

  /// Ends a simulated fake call that is in progress. Disarms the
  /// engine.
  Future<void> hangUp() async {
    final runtime = _runtime;
    if (runtime == null) return;
    runtime.engine.hangUp();
  }

  /// Declines a simulated fake-call pretext.
  Future<void> declineFakeCall() async {
    final runtime = _runtime;
    if (runtime == null) return;
    runtime.engine.declineFakeCall();
  }

  /// Signals that the user started holding the hold-button widget.
  ///
  /// Fix for bugs.json Bug #1 (holdButton UI disconnected from engine):
  /// `SessionScreen` previously handed empty lambdas to
  /// `HoldToTriggerButton`, so the engine never received touch events.
  /// Thin wrapper around [SessionEngine.holdStart].
  void holdStart() {
    final runtime = _runtime;
    if (runtime == null) return;
    runtime.engine.holdStart();
  }

  /// Signals that the user released the hold-button widget.
  ///
  /// Fix for bugs.json Bug #1 (holdButton UI disconnected from engine).
  /// Thin wrapper around [SessionEngine.holdRelease].
  void holdRelease() {
    final runtime = _runtime;
    if (runtime == null) return;
    runtime.engine.holdRelease();
  }

  /// Force-fires the distress chain (e.g. hardware panic, duress
  /// PIN, wrong-PIN threshold exhausted).
  Future<void> triggerDistressChain() async {
    final runtime = _runtime;
    if (runtime == null) return;
    runtime.engine.replaceWithDistressChain(
      await _currentDistressChainSteps(),
      triggerReason: TriggerReason.hardwarePanic,
    );
  }

  /// Handles the outcome of a PIN prompt.
  ///
  /// Returns `true` when the session should proceed past the prompt
  /// (correct PIN), `false` otherwise. [PinResult.duress] and
  /// [PinResult.wrongPinThreshold] both fire the distress chain and
  /// return `false`.
  bool handlePinResult(PinResult result) {
    switch (result) {
      case PinResult.correct:
        _wrongPinCount = 0;
        return true;
      case PinResult.wrong:
        _wrongPinCount++;
        if (_wrongPinCount >= wrongPinThreshold) {
          // Threshold reached — unconditionally fire distress.
          unawaited(_fireDistressBecauseOfPin(EndReason.wrongPinExhausted));
          _wrongPinCount = 0;
        }
        return false;
      case PinResult.duress:
        _wrongPinCount = 0;
        unawaited(_fireDistressBecauseOfPin(EndReason.duressPin));
        return false;
      case PinResult.wrongPinThreshold:
        _wrongPinCount = 0;
        unawaited(_fireDistressBecauseOfPin(EndReason.wrongPinExhausted));
        return false;
      case PinResult.timeout:
      case PinResult.cancelled:
        return false;
    }
  }

  Future<void> _fireDistressBecauseOfPin(EndReason reason) async {
    if (reason == EndReason.wrongPinExhausted) {
      final dialog = onAngelaDeceptiveDialog;
      if (dialog != null) {
        // Safety-critical: any exception inside the modal route is
        // swallowed so the OS dismissing the dialog cannot leave an
        // attacker with a working PIN attempt and no escalation.
        try {
          await dialog();
        } on Object catch (_) {
          // Intentionally swallowed.
        }
      }
    }
    final runtime = _runtime;
    if (runtime == null) return;
    final triggerReason = switch (reason) {
      EndReason.duressPin => TriggerReason.duressPin,
      EndReason.wrongPinExhausted => TriggerReason.wrongPinExhausted,
      _ => TriggerReason.hardwarePanic,
    };
    runtime.engine.replaceWithDistressChain(
      await _currentDistressChainSteps(),
      triggerReason: triggerReason,
    );
  }

  Future<List<ChainStep>> _currentDistressChainSteps() async {
    final modesRepo = ref.read(modesRepositoryProvider);
    final settings = await ref.read(settingsControllerProvider.future);
    return _resolveDistressModeSteps(
      modesRepo: modesRepo,
      modeDistressModeId: null,
      defaultDistressModeId: settings.defaults.defaultDistressModeId,
    );
  }

  // ----- Internal: bootstrapping -------------------------------------

  Future<void> _bootstrapSession({
    required SessionMode mode,
    required AppSettings settings,
    required List<EmergencyContact> contacts,
    required UserProfile? profile,
    required List<ReminderTemplate> templates,
    required List<ChainStep> distressSteps,
    required bool isSimulation,
    required bool isBackgroundAlert,
  }) async {
    final services = _resolveServices(isSimulation: isSimulation);
    // Fix for bugs.json Warn 3 / Warn 4: seed localized fallbacks
    // (TTS phrase, default SMS body, default pre-call SMS body) for
    // the user's app language plus a per-language resolver each
    // contact uses to pick its own SMS body when the contact's
    // `languageCode` differs.
    final appL = await AppLocalizations.delegate.load(
      Locale(settings.languageCode),
    );
    final smsResolver = _buildSmsTemplateResolver(pick: _smsDefaultTemplateOf);
    final preSmsResolver = _buildSmsTemplateResolver(
      pick: _preSmsDefaultTemplateOf,
    );
    final context = SessionContext(
      mode: mode,
      contacts: contacts,
      userProfile: profile,
      isSimulation: isSimulation,
      reminderTemplates: templates,
      eventDefaults: _effectiveDefaults(settings, mode),
      // Fix for bugs.json Bug #7: thread the user's configured
      // emergency number into the session context so
      // CallEmergencyStrategy no longer hardcodes '112'.
      emergencyNumber: settings.emergencyCallNumber,
      ttsLatePhrase: appL.audioRunningLatePhrase,
      defaultSmsTemplate: _smsDefaultTemplateOf(appL),
      defaultPreSmsTemplate: _preSmsDefaultTemplateOf(appL),
      smsTemplateForLanguage: smsResolver,
      preSmsTemplateForLanguage: preSmsResolver,
      // Q33: surface the gradual-volume ramp to LoudAlarmStrategy.
      alarmGradualVolumeRamp: settings.alarmGradualVolume
          ? Duration(seconds: settings.alarmGradualVolumeDurationSeconds)
          : null,
    );
    // Spec 11 §DE-3 — interval-based GPS recording. The buffer is
    // ephemeral: created at session-start, cleared at session-end,
    // never persisted (no session restore from disk).
    final TrackingBuffer? trackingBuffer = mode.trackingEnabled
        ? TrackingBuffer(capacity: mode.trackingBufferSize)
        : null;
    final engine = SessionEngine(
      chainSteps: mode.chainSteps,
      isSimulation: isSimulation,
      // Spec 01 §Events Emitted — pauseExpired auto-resume timer.
      maxPauseDuration: mode.maxPauseMinutes != null
          ? Duration(minutes: mode.maxPauseMinutes!)
          : null,
    );
    final orchestrator = SessionOrchestrator(
      isSimulation: isSimulation,
      servicesBuilder: (isCancelled, registerWorkId) => EventServices(
        audio: services.audio,
        messaging: services.messaging,
        phone: services.phone,
        notification: services.notification,
        vibration: services.vibration,
        deviceState: services.deviceState,
        // Q46: pipe the live location service so LocationResolver
        // can substitute `{location}` in SMS templates.
        location: services.location,
        context: context,
        isCancelled: isCancelled,
        registerSmsWorkId: registerWorkId,
        // Spec 11 §DE-3 — strategies prefer the buffer's latest
        // point over a fresh GPS fix when resolving `{location}`.
        trackingBuffer: trackingBuffer,
        // Q24 — LoudAlarmStrategy strobes the LED when flashLight=true.
        flash: services.flash,
        // Q23 — SmsContactStrategy honours autoRecordAudio when set.
        recording: services.recording,
      ),
      chainStepsResolver: () => engine.steps,
      messagingService: services.messaging,
      // Fix for bugs.json Bug #3: the orchestrator accepts an
      // onSimulationDescription sink but the controller never
      // supplied one, so SimulationSummaryScreen always showed an
      // empty list. Route descriptions into the live WalkSession
      // so the summary screen renders them.
      onSimulationDescription: _appendFiredDescription,
      // Spec 01 §Events Emitted — surface strategy failures as engine
      // events so SessionLogRecorder can record them.
      onStepExecutionFailedEvent: ({required step, required stepIndex}) {
        engine.emitStepExecutionFailed(stepIndex: stepIndex, step: step);
      },
    );
    final recorder = SessionLogRecorder(
      log: SessionLog(
        id: _newSessionId(),
        modeId: mode.id,
        modeName: mode.name,
        startedAt: DateTime.now(),
        isSimulation: isSimulation,
      ),
    );

    TriggerManager? triggerManager;
    // L14: battery-alert sessions never arm hardware triggers — they
    // are background-only and must not re-fire distress chains
    // themselves.
    if (!isBackgroundAlert && !isSimulation) {
      triggerManager = TriggerManager(
        engine: engine,
        mode: mode,
        hardwareButtonService: services.hardwareButton,
        geofenceService: services.geofence,
        batteryMonitorService: services.batteryMonitor,
        onDisarmRequested: onDisarmRequested,
        onDistressConfirmation: onDistressConfirmation,
        distressStepsResolver: () => distressSteps,
      );
      await triggerManager.start();
    }

    // Subscribe to engine events BEFORE calling start() so the
    // sync broadcast of `sessionStarted` is captured.
    final eventsSub = engine.events.listen((event) {
      _handleEngineEvent(
        event: event,
        orchestrator: orchestrator,
        recorder: recorder,
      );
    });

    // Risk-12 documentation: battery-alert sessions also pause when a
    // real call arrives, so the alert does not bleed into the call
    // audio. Symmetric behavior with interactive sessions.
    StreamSubscription<CallState>? incomingCallSub;
    if (!isSimulation) {
      incomingCallSub = services.incomingCall.callState.listen((state) {
        _handleIncomingCall(engine: engine, state: state);
      });
      await services.incomingCall.startListening();
    }

    _runtime = _SessionRuntime(
      engine: engine,
      orchestrator: orchestrator,
      recorder: recorder,
      mode: mode,
      triggerManager: triggerManager,
      eventsSub: eventsSub,
      incomingCallSub: incomingCallSub,
      services: services,
    );

    // Seed `state` with an active WalkSession BEFORE starting so
    // the UI has something to render when `sessionStarted` arrives.
    state = AsyncValue.data(
      WalkSession(
        id: recorder.log.id,
        modeId: mode.id,
        isSimulation: isSimulation,
        startedAt: recorder.log.startedAt,
        phase: const SessionPhaseIdle(),
        currentStepIndex: 0,
        isBackgroundAlert: isBackgroundAlert,
      ),
    );

    engine.start();
  }

  void _handleEngineEvent({
    required ChainEventData event,
    required SessionOrchestrator orchestrator,
    required SessionLogRecorder recorder,
  }) {
    recorder.recordEvent(event);
    // bugs.json Note 4: orchestrator.handleEvent is fire-and-forget;
    // log any failure rather than letting it disappear into the
    // microtask queue. Strategies must not propagate exceptions
    // upward — but if one does, we want a breadcrumb in the log.
    unawaited(
      orchestrator.handleEvent(event).onError((e, s) {
        developer.log(
          'orchestrator.handleEvent failed for ${event.event}: $e',
          stackTrace: s,
        );
      }),
    );
    _updateWalkSession(event: event);
    if (event.event == ChainEvent.sessionEnded) {
      _persistSessionLog(recorder.log);
    }
  }

  void _handleIncomingCall({
    required SessionEngine engine,
    required CallState state,
  }) {
    switch (state) {
      case CallState.ringing:
      case CallState.active:
        engine.pause(reason: PauseReason.incomingCall);
      case CallState.ended:
      case CallState.idle:
        // Fix for bugs.json Bug #5: only auto-resume when the pause
        // was initiated by this incoming call. User-requested,
        // fake-call-answered, or boot-restart pauses must not be
        // silently cancelled by an unrelated call ending.
        final engineState = engine.state;
        if (engineState is EnginePaused &&
            engineState.reason == PauseReason.incomingCall) {
          engine.resume();
        }
    }
  }

  void _updateWalkSession({required ChainEventData event}) {
    final current = state.value;
    if (current == null) return;
    final runtime = _runtime;
    if (runtime == null) return;
    final engineState = runtime.engine.state;
    final phase = WalkSession.phaseFromEngine(engineState);
    int? stepIndex = current.currentStepIndex;
    ChainStepType? stepType = current.currentStepType;
    int missCount = current.missCount;
    int? remainingSeconds = current.remainingSeconds;
    if (engineState is EngineRunning) {
      stepIndex = engineState.stepIndex;
      stepType = runtime.engine.steps[engineState.stepIndex].type;
      missCount = engineState.missCount;
      remainingSeconds = engineState.remaining.inSeconds;
    } else if (engineState is EnginePaused) {
      stepIndex = engineState.snapshot.stepIndex;
      stepType = runtime.engine.steps[engineState.snapshot.stepIndex].type;
      missCount = engineState.snapshot.missCount;
      remainingSeconds = engineState.snapshot.remaining.inSeconds;
    }
    state = AsyncValue.data(
      current.copyWith(
        phase: phase,
        currentStepIndex: stepIndex,
        currentStepType: stepType,
        missCount: missCount,
        remainingSeconds: remainingSeconds,
      ),
    );
  }

  Future<void> _persistSessionLog(SessionLog log) async {
    final repo = ref.read(sessionLogsRepositoryProvider);
    await repo.save(log);
  }

  /// Appends a simulation-description toast to the live WalkSession.
  ///
  /// Fix for bugs.json Bug #3: previously the orchestrator had no
  /// sink for simulation descriptions, so SimulationSummaryScreen
  /// always showed an empty list. Called from
  /// `onSimulationDescription` inside [_bootstrapSession].
  void _appendFiredDescription(SimulationDescription description) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(
      current.copyWith(
        firedStepDescriptions: [...current.firedStepDescriptions, description],
        lastSimulationDescription: description,
      ),
    );
  }

  // ----- Internal: defaults + helpers --------------------------------

  EventDefaults _effectiveDefaults(AppSettings settings, SessionMode mode) {
    final override = mode.overrides?.eventDefaults;
    return override ?? settings.defaults.eventDefaults;
  }

  /// Returns the localized SMS body template with `{name}`,
  /// `{location}`, `{time}` placeholders preserved so
  /// [SessionContext.resolvePlaceholders] can substitute them at
  /// dispatch time. Calling the generated message function with the
  /// literal placeholder strings is the standard trick to retrieve
  /// the unresolved template — the generated code is plain
  /// `${name}` interpolation, so it round-trips losslessly.
  static String _smsDefaultTemplateOf(AppLocalizations l) =>
      l.smsDefaultTemplate('{name}', '{location}', '{time}');

  /// As [_smsDefaultTemplateOf] but for the pre-call SMS body.
  static String _preSmsDefaultTemplateOf(AppLocalizations l) =>
      l.smsDefaultPreCallTemplate('{name}');

  /// Builds an [SmsTemplateResolver] backed by [AppLocalizations].
  /// See `SessionLifecycleController._buildSmsTemplateResolver` for
  /// the rationale; this duplicate exists because the legacy
  /// `SessionController` facade still owns its own `_bootstrapSession`.
  /// Fix for bugs.json Warn 4.
  SmsTemplateResolver _buildSmsTemplateResolver({
    required String Function(AppLocalizations) pick,
  }) {
    final cache = <String, String>{};
    return (String? languageCode) {
      if (languageCode == null || languageCode.isEmpty) return null;
      final cached = cache[languageCode];
      if (cached != null) return cached;
      final locale = Locale(languageCode);
      if (!AppLocalizations.delegate.isSupported(locale)) return null;
      AppLocalizations? resolved;
      AppLocalizations.delegate.load(locale).then((l) => resolved = l);
      if (resolved == null) return null;
      final value = pick(resolved!);
      cache[languageCode] = value;
      return value;
    };
  }

  List<ReminderTemplate> _resolveTemplates({
    required SessionMode mode,
    required List<ReminderTemplate> global,
  }) {
    final local = mode.overrides?.localTemplates ?? const <ReminderTemplate>[];
    return [...global, ...local];
  }

  /// Phase 2.4 — resolves the distress chain to fire when a distress
  /// trigger goes off, sourced from the modes table.
  ///
  /// Lookup order:
  /// 1. The mode being started has an explicit `distressModeId` →
  ///    use that distress-flagged mode's chain.
  /// 2. Else, `AppDefaults.defaultDistressModeId` → that mode's chain.
  /// 3. Else, the first distress-flagged mode in the modes table.
  ///
  /// Throws `StateError` if no distress-flagged modes exist
  /// (D-SAFETY-17).
  Future<List<ChainStep>> _resolveDistressModeSteps({
    required ModesRepository modesRepo,
    required String? modeDistressModeId,
    required String? defaultDistressModeId,
  }) async {
    final allModes = await modesRepo.getAll();
    final distressModes = allModes.where((m) => m.isDistressMode).toList();
    if (distressModes.isEmpty) {
      throw StateError(
        'No distress modes configured; at least one distress-flagged '
        'mode must exist to handle distress triggers (D-SAFETY-17).',
      );
    }
    final wanted = modeDistressModeId ?? defaultDistressModeId;
    if (wanted != null) {
      for (final m in distressModes) {
        if (m.id == wanted) return m.chainSteps;
      }
    }
    return distressModes.first.chainSteps;
  }

  _SessionServices _resolveServices({required bool isSimulation}) {
    if (isSimulation) {
      return _SessionServices(
        audio: ref.read(simulationAudioProvider),
        messaging: ref.read(simulationMessagingProvider),
        phone: ref.read(simulationPhoneProvider),
        notification: ref.read(simulationNotificationProvider),
        vibration: ref.read(simulationVibrationProvider),
        hardwareButton: ref.read(simulationHardwareButtonProvider),
        geofence: ref.read(simulationGeofenceProvider),
        batteryMonitor: ref.read(simulationBatteryMonitorProvider),
        deviceState: ref.read(simulationDeviceStateProvider),
        incomingCall: ref.read(simulationIncomingCallProvider),
        location: ref.read(simulationLocationProvider),
        flash: ref.read(simulationFlashProvider),
        recording: ref.read(simulationRecordingProvider),
      );
    }
    return _SessionServices(
      audio: ref.read(audioServiceProvider),
      messaging: ref.read(messagingServiceProvider),
      phone: ref.read(phoneServiceProvider),
      notification: ref.read(notificationServiceProvider),
      vibration: ref.read(vibrationServiceProvider),
      hardwareButton: ref.read(hardwareButtonServiceProvider),
      geofence: ref.read(geofenceServiceProvider),
      batteryMonitor: ref.read(batteryMonitorServiceProvider),
      deviceState: ref.read(deviceStateServiceProvider),
      incomingCall: ref.read(incomingCallServiceProvider),
      location: ref.read(locationServiceProvider),
      flash: ref.read(flashServiceProvider),
      recording: ref.read(recordingServiceProvider),
    );
  }

  Future<void> _disposeRuntime() async {
    final runtime = _runtime;
    if (runtime == null) return;
    _runtime = null;
    await runtime.eventsSub.cancel();
    final incomingCallSub = runtime.incomingCallSub;
    if (incomingCallSub != null) {
      await incomingCallSub.cancel();
      // Sev-1 fix: also unregister the platform TelephonyCallback /
      // CXCallObserver so the OS doesn't keep delivering events to
      // a dead session.
      try {
        await runtime.services.incomingCall.stopListening();
      } on Object catch (e) {
        developer.log(
          'incomingCall.stopListening failed: $e',
          name: 'session.dispose',
        );
      }
    }
    await runtime.triggerManager?.dispose();
    await runtime.orchestrator.cancelPendingWork();
    runtime.orchestrator.dispose();
    runtime.engine.dispose();
  }

  /// Returns a unique session id. Implemented as a monotonic counter
  /// prefixed by the current ticks to keep tests deterministic.
  static String _newSessionId() {
    final now = DateTime.now();
    return 'session-${now.microsecondsSinceEpoch}';
  }
}

/// Internal bundle of services for one session. Picked by
/// [_resolveServices] based on simulation flag.
class _SessionServices {
  _SessionServices({
    required this.audio,
    required this.messaging,
    required this.phone,
    required this.notification,
    required this.vibration,
    required this.hardwareButton,
    required this.geofence,
    required this.batteryMonitor,
    required this.deviceState,
    required this.incomingCall,
    required this.location,
    required this.flash,
    required this.recording,
  });

  final AudioServiceProtocol audio;
  final MessagingServiceProtocol messaging;
  final PhoneServiceProtocol phone;
  final NotificationServiceProtocol notification;
  final VibrationServiceProtocol vibration;
  final HardwareButtonServiceProtocol hardwareButton;
  final GeofenceServiceProtocol geofence;
  final BatteryMonitorServiceProtocol batteryMonitor;
  final DeviceStateServiceProtocol deviceState;
  final IncomingCallServiceProtocol incomingCall;
  final LocationServiceProtocol location;
  final FlashServiceProtocol flash;
  final RecordingServiceProtocol recording;
}

/// Provider for `SessionController`.
final AsyncNotifierProvider<SessionController, WalkSession?>
sessionControllerProvider =
    AsyncNotifierProvider<SessionController, WalkSession?>(
      SessionController.new,
    );
