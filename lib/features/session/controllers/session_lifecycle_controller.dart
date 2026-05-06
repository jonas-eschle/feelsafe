/// Session lifecycle controller — engine assembly + event dispatch.
///
/// One of the four sub-controllers Q48 splits
/// `SessionController` into. Owns the live engine, services bundle,
/// orchestrator, recorder, and trigger manager that together drive
/// the active safety session. Translates engine events into the
/// `WalkSession` view-model exposed by the parent
/// [SessionController] facade.
///
/// This controller is a *plain Dart helper* — not a Riverpod
/// notifier. The facade owns the WalkSession state setter and passes
/// it in via [stateSetter] / [stateGetter]. Splitting per Q48 keeps
/// the public Riverpod surface (`sessionControllerProvider`)
/// unchanged while the internal responsibilities are decomposed.
///
/// Wires L1 / L4 / L5 / L7 / L8 / L14 wiring concerns (see facade
/// docstring for the full list).
library;

import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/data/repositories/modes_repository.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/engine/session_log_recorder.dart';
import 'package:guardianangela/domain/engine/tracking_buffer.dart';
import 'package:guardianangela/domain/engine/trigger_manager.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';
import 'package:guardianangela/domain/orchestration/session_orchestrator.dart';
import 'package:guardianangela/features/session/emergency_confirm_request.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Bundle collecting the live session's runtime handles so
/// [SessionLifecycleController.disposeRuntime] can tear down the whole
/// graph atomically.
class SessionRuntime {
  /// Creates a runtime bundle.
  SessionRuntime({
    required this.engine,
    required this.orchestrator,
    required this.recorder,
    required this.triggerManager,
    required this.eventsSub,
    required this.services,
    required this.mode,
    this.incomingCallSub,
    this.notificationActionSub,
    this.trackingBuffer,
    this.trackingTimer,
  });

  /// Pure-Dart state machine driving the session.
  final SessionEngine engine;

  /// Orchestrator routing engine events into side-effect strategies.
  final SessionOrchestrator orchestrator;

  /// Persistable session-log recorder.
  final SessionLogRecorder recorder;

  /// Hardware / GPS / timer trigger manager (real sessions only).
  final TriggerManager? triggerManager;

  /// Engine event subscription (cancelled on disposal).
  final StreamSubscription<ChainEventData> eventsSub;

  /// Incoming-call state subscription (real sessions only).
  final StreamSubscription<CallState>? incomingCallSub;

  /// Subscription to notification-action taps. Fires when the user
  /// taps an action button on a disarm-trigger (or future) posted
  /// notification.
  final StreamSubscription<String>? notificationActionSub;

  /// Active session mode — retained so pause semantics
  /// (`pauseAllowed`, `maxPauseMinutes`) can be enforced at the
  /// controller layer. The engine stays mode-agnostic.
  final SessionMode mode;

  /// Resolved services bundle (real or simulation) — retained so
  /// lifecycle events (pause) can stop active audio / vibration
  /// without running a fresh step through the orchestrator.
  final SessionServices services;

  /// Spec 11 §DE-3 — ephemeral GPS sample buffer when the active
  /// mode has [SessionMode.trackingEnabled]. Null otherwise. Lives
  /// only for the duration of the session.
  final TrackingBuffer? trackingBuffer;

  /// Spec 11 §DE-3 — periodic timer that samples GPS at
  /// `mode.trackingIntervalSeconds`. Null when tracking is disabled.
  /// Cancelled on pause and on session end.
  Timer? trackingTimer;
}

/// Bundle of services for one session. Picked by
/// [SessionLifecycleController._resolveServices] based on the
/// simulation flag.
class SessionServices {
  /// Creates a services bundle.
  SessionServices({
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
  });

  /// Audio (alarm + ringtone + voice recording).
  final AudioServiceProtocol audio;

  /// Messaging (SMS / WhatsApp / Telegram).
  final MessagingServiceProtocol messaging;

  /// Phone call placement.
  final PhoneServiceProtocol phone;

  /// Local notifications (disguised reminders + disarm-trigger).
  final NotificationServiceProtocol notification;

  /// Haptic feedback.
  final VibrationServiceProtocol vibration;

  /// Hardware button (volume) panic listener.
  final HardwareButtonServiceProtocol hardwareButton;

  /// GPS-arrival geofence.
  final GeofenceServiceProtocol geofence;

  /// Battery level monitor.
  final BatteryMonitorServiceProtocol batteryMonitor;

  /// Flashlight + screen state.
  final DeviceStateServiceProtocol deviceState;

  /// Incoming-call detector (TelephonyCallback / CXCallObserver).
  final IncomingCallServiceProtocol incomingCall;

  /// Live GPS location lookup.
  final LocationServiceProtocol location;
}

/// Plain-Dart helper that owns the active session's engine, services,
/// orchestrator, recorder, and trigger manager. Composed by the
/// [SessionController] facade.
class SessionLifecycleController {
  /// Creates a lifecycle controller. Callbacks let the facade plumb
  /// callbacks (e.g. distress confirmation) and react to runtime
  /// changes without coupling this helper to a specific Notifier
  /// implementation.
  SessionLifecycleController({
    required this.ref,
    required this.stateGetter,
    required this.stateSetter,
    required this.distressConfirmationProvider,
    required this.disarmRequestedHandler,
  });

  /// Riverpod ref handed in by the facade.
  final Ref ref;

  /// Reads the current `WalkSession?` from the facade's `state`.
  final WalkSession? Function() stateGetter;

  /// Writes a new `AsyncValue<WalkSession?>` into the facade's
  /// `state`. The facade is responsible for the AsyncNotifier
  /// contract; this helper just hands back values.
  final void Function(AsyncValue<WalkSession?>) stateSetter;

  /// Looks up the latest distress-confirmation callback from the
  /// facade. Indirection lets the UI swap the closure between
  /// SessionScreen mount/unmount without us caching a stale ref.
  final Future<bool> Function()? Function() distressConfirmationProvider;

  /// Handles the "the engine wants the user to confirm a disarm" UI
  /// hook — read from the facade. Wrapped here so we ALSO post a
  /// background notification when the app is backgrounded.
  final void Function()? Function() disarmRequestedHandler;

  /// Broadcast stream of emergency-call confirmation requests.
  /// Spec 04 §EmergencyCallConfirmationScreen.
  Stream<EmergencyConfirmRequest> get emergencyConfirmationRequests =>
      _emergencyConfirmCtrl.stream;

  final StreamController<EmergencyConfirmRequest> _emergencyConfirmCtrl =
      StreamController<EmergencyConfirmRequest>.broadcast();

  /// Broadcast stream of disarm-trigger background notifications.
  Stream<void> get pendingBackgroundDisarmTriggers =>
      _pendingDisarmTriggerCtrl.stream;

  final StreamController<void> _pendingDisarmTriggerCtrl =
      StreamController<void>.broadcast();

  /// Current app lifecycle state. Updated by the SessionScreen's
  /// lifecycle observer via [setAppLifecycleState].
  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;

  /// Live runtime; null when no session is active.
  SessionRuntime? _runtime;

  /// Returns the live runtime, or null if no session is active.
  /// Package-private so the other sub-controllers (PinGate,
  /// DistressOrchestration) can reach in to invoke the engine.
  SessionRuntime? get runtime => _runtime;

  /// Updates the cached app lifecycle state. Called by the
  /// SessionScreen's `WidgetsBindingObserver`.
  void setAppLifecycleState(AppLifecycleState state) {
    _appLifecycleState = state;
  }

  bool get _appBackgrounded => _appLifecycleState != AppLifecycleState.resumed;

  /// True when the active mode permits manual pause. Spec 01
  /// §Pause Behavior.
  bool get isPauseAllowed {
    final runtime = _runtime;
    if (runtime == null) return false;
    return runtime.mode.pauseAllowed;
  }

  /// True while an interactive user safety session is running.
  bool get isSessionActive {
    if (_runtime == null) return false;
    final s = stateGetter();
    if (s == null) return false;
    if (s.isBackgroundAlert) return false;
    if (s.phase is SessionPhaseEnded) return false;
    return true;
  }

  /// Disposes any stream controllers held by this helper. Called from
  /// the facade's `ref.onDispose`.
  Future<void> dispose() async {
    await disposeRuntime();
    await _emergencyConfirmCtrl.close();
    await _pendingDisarmTriggerCtrl.close();
  }

  // ----- Public lifecycle API ----------------------------------------

  /// Starts a new user session for [modeId].
  Future<void> startSession({
    required String modeId,
    bool isSimulation = false,
  }) async {
    // L14: cancel any background battery-alert session before we
    // start the user session — only one engine may run at a time.
    if (_runtime != null) {
      final active = stateGetter();
      if (active != null && !active.isBackgroundAlert) {
        throw StateError('A user session is already running; disarm it first.');
      }
      await disposeRuntime();
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

    // Distress chain resolution (Q52): the distress chain is just
    // another `SessionMode`. mode.distressModeId wins; else fall
    // back to AppDefaults.defaultDistressModeId.
    final distressSteps = await resolveDistressModeSteps(
      modesRepo: modesRepo,
      modeDistressModeId: mode.distressModeId,
      defaults: settings.defaults,
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
  Future<void> startBatteryAlertSession(BatteryAlertConfig config) async {
    if (_runtime != null) {
      final active = stateGetter();
      if (active != null && !active.isBackgroundAlert) {
        throw StateError(
          'Cannot start battery-alert while a user session is active.',
        );
      }
      // Spec 06 §Battery Alert: fire once per session. If a
      // battery-alert session is already running, ignore repeated
      // low-battery events — do NOT cancel-and-restart it.
      if (active != null &&
          active.isBackgroundAlert &&
          active.phase is! SessionPhaseEnded) {
        return;
      }
      await disposeRuntime();
    }
    if (!config.enabled || config.chain.isEmpty) {
      return;
    }
    final settings = await ref.read(settingsControllerProvider.future);
    final contacts = await ref.read(contactsRepositoryProvider).getAll();
    final profile = await ref.read(userProfileRepositoryProvider).get();
    final modesRepo = ref.read(modesRepositoryProvider);
    final distressSteps = await resolveDistressModeSteps(
      modesRepo: modesRepo,
      modeDistressModeId: null,
      defaults: settings.defaults,
    );

    final syntheticMode = SessionMode(
      id: 'battery-alert',
      name: 'Battery Alert',
      checkInType: config.chain.first.type,
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

  /// Ends the active session with [EndReason.userQuit] — the
  /// "I'm Safe" slider's gesture (Q1).
  Future<void> disarm() async {
    final runtime = _runtime;
    if (runtime == null) return;
    runtime.engine.endSession(reason: EndReason.userQuit);
  }

  /// User signal "I'm OK, keep checking on me" — resets the chain to
  /// step 0 without ending the session. Q1 + Q6 (Date Mode in-app
  /// button + disguised-reminder notification action).
  ///
  /// Distinct from [disarm] (which ends the session). Engine no-ops
  /// outside an active `disguisedReminder` step.
  Future<void> checkIn() async {
    final runtime = _runtime;
    if (runtime == null) return;
    runtime.engine.checkIn();
  }

  /// Pauses the active session.
  Future<void> pause() async {
    final runtime = _runtime;
    if (runtime == null) return;
    if (!runtime.mode.pauseAllowed) {
      throw StateError(
        'pause() called on a mode that has pauseAllowed == false.',
      );
    }
    runtime.engine.pause();
  }

  /// Resumes a paused session.
  Future<void> resume() async {
    final runtime = _runtime;
    if (runtime == null) return;
    runtime.engine.resume();
  }

  /// Engages / disengages the engine's effective-speed clamp when the
  /// app lifecycle transitions to background / foreground during a
  /// simulation.
  void setSimulationBackgroundClamp(bool enabled) {
    final runtime = _runtime;
    if (runtime == null) return;
    runtime.engine.setBackgroundClamp(enabled);
  }

  /// Simulation-only thin wrapper around
  /// [SessionEngine.setSpeedMultiplier].
  void setSimulationSpeedMultiplier(double value) {
    final runtime = _runtime;
    if (runtime == null) return;
    if (!runtime.engine.isSimulation) return;
    runtime.engine.setSpeedMultiplier(value);
  }

  /// Simulation helper — fires the GPS-arrival disarm-trigger path.
  Future<void> simulateGpsArrival() async {
    final runtime = _runtime;
    if (runtime == null) return;
    if (!runtime.engine.isSimulation) return;
    appendFiredDescription(
      const SimulationDescription('simGpsArrivalTrigger'),
    );
    final cb = disarmRequestedHandler();
    if (cb != null) {
      cb();
    } else {
      runtime.engine.endSession(reason: EndReason.userQuit);
    }
  }

  /// Simulation helper — emits a battery-alert description.
  Future<void> simulateLowBattery() async {
    final runtime = _runtime;
    if (runtime == null) return;
    if (!runtime.engine.isSimulation) return;
    appendFiredDescription(
      const SimulationDescription('simLowBatteryAlert'),
    );
  }

  /// Accepts the currently ringing simulated fake-call pretext.
  Future<void> answerFakeCall() async {
    final runtime = _runtime;
    if (runtime == null) return;
    runtime.engine.answerFakeCall();
  }

  /// Ends a simulated fake call that is in progress.
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
  void holdStart() {
    final runtime = _runtime;
    if (runtime == null) return;
    runtime.engine.holdStart();
  }

  /// Signals that the user released the hold-button widget.
  void holdRelease() {
    final runtime = _runtime;
    if (runtime == null) return;
    runtime.engine.holdRelease();
  }

  // ----- Internal: bootstrapping ------------------------------------

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
    // Fix for bugs.json Warn 3 / Warn 4: seed the localized strings
    // strategies fall back to (TTS phrase, default SMS body, default
    // pre-call SMS body) from `AppLocalizations` for the user's app
    // language, plus a per-language resolver each contact uses to
    // pick its own SMS body when the contact's `languageCode` differs.
    // The resolver is built from the same delegate so any language
    // the app supports can be pulled synchronously (delegate.load
    // returns a SynchronousFuture).
    final appL = await AppLocalizations.delegate.load(
      Locale(settings.languageCode),
    );
    final smsResolver = _buildSmsTemplateResolver(
      pick: (l) => l.smsDefaultTemplate,
    );
    final preSmsResolver = _buildSmsTemplateResolver(
      pick: (l) => l.smsDefaultPreCallTemplate,
    );
    final context = SessionContext(
      mode: mode,
      contacts: contacts,
      userProfile: profile,
      isSimulation: isSimulation,
      reminderTemplates: templates,
      eventDefaults: _effectiveDefaults(settings, mode),
      // Bug #7 fix: thread the user's configured emergency number.
      emergencyNumber: settings.emergencyCallNumber,
      // DE-2: thread the effective global GPS-logging master toggle
      // so strategies can resolve per-step `logGps` overrides
      // without round-tripping through AppSettings.
      gpsLoggingEnabled: _effectiveGpsEnabled(settings, mode),
      // Warn 3 / 4 fix: seed localized fallbacks + per-language
      // resolver.
      ttsLatePhrase: appL.audioRunningLatePhrase,
      defaultSmsTemplate: appL.smsDefaultTemplate,
      defaultPreSmsTemplate: appL.smsDefaultPreCallTemplate,
      smsTemplateForLanguage: smsResolver,
      preSmsTemplateForLanguage: preSmsResolver,
    );
    // Spec 11 §DE-3 — interval-based GPS recording. The buffer is
    // ephemeral: created at session-start, cleared at session-end,
    // never persisted. Pivot 1 (no session restore) means a process
    // death takes the buffer with it.
    final TrackingBuffer? trackingBuffer = mode.trackingEnabled
        ? TrackingBuffer(capacity: mode.trackingBufferSize)
        : null;
    final engine = SessionEngine(
      chainSteps: mode.chainSteps,
      isSimulation: isSimulation,
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
        // Q46: pipe the live location service.
        location: services.location,
        context: context,
        isCancelled: isCancelled,
        registerSmsWorkId: registerWorkId,
        // Spec 11 §DE-3 — strategies prefer the buffer's latest
        // point over a fresh GPS fix when resolving `{location}`.
        trackingBuffer: trackingBuffer,
      ),
      chainStepsResolver: () => engine.steps,
      messagingService: services.messaging,
      // Bug #3 fix: route descriptions into the live WalkSession.
      onSimulationDescription: appendFiredDescription,
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
    if (!isBackgroundAlert && !isSimulation) {
      triggerManager = TriggerManager(
        engine: engine,
        mode: mode,
        hardwareButtonService: services.hardwareButton,
        geofenceService: services.geofence,
        onDisarmRequested: () => _onDisarmRequestedFromTrigger(services),
        onDistressConfirmation: distressConfirmationProvider(),
        distressStepsResolver: () => distressSteps,
      );
      await triggerManager.start();
    }

    final eventsSub = engine.events.listen((event) {
      _handleEngineEvent(
        event: event,
        orchestrator: orchestrator,
        recorder: recorder,
      );
    });

    StreamSubscription<CallState>? incomingCallSub;
    if (!isSimulation) {
      incomingCallSub = services.incomingCall.callState.listen((state) {
        _handleIncomingCall(engine: engine, state: state);
      });
      await services.incomingCall.startListening();
    }

    final notificationActionSub = services.notification.actionTaps.listen(
      _onNotificationAction,
    );

    _runtime = SessionRuntime(
      engine: engine,
      orchestrator: orchestrator,
      recorder: recorder,
      triggerManager: triggerManager,
      eventsSub: eventsSub,
      incomingCallSub: incomingCallSub,
      notificationActionSub: notificationActionSub,
      services: services,
      mode: mode,
      trackingBuffer: trackingBuffer,
    );

    // Q23: totalSteps captured from chain.length.
    stateSetter(
      AsyncValue.data(
        WalkSession(
          id: recorder.log.id,
          modeId: mode.id,
          isSimulation: isSimulation,
          startedAt: recorder.log.startedAt,
          phase: const SessionPhaseIdle(),
          currentStepIndex: 0,
          totalSteps: mode.chainSteps.length,
          isBackgroundAlert: isBackgroundAlert,
        ),
      ),
    );

    engine.start();

    // Spec 11 §DE-3 — start the interval-based tracker. Real
    // sessions only: simulation services log no-op, but spinning a
    // Timer that does nothing on every tick is needless work.
    _maybeStartTracking(isSimulation: isSimulation);
  }

  /// Spec 11 §DE-3 — starts the periodic GPS sampler when the active
  /// mode has [SessionMode.trackingEnabled]. No-op when tracking is
  /// disabled, in simulation, or when no runtime is wired. Cancels
  /// any existing timer first to make this safe to call after a
  /// resume.
  void _maybeStartTracking({required bool isSimulation}) {
    final runtime = _runtime;
    if (runtime == null) return;
    final buffer = runtime.trackingBuffer;
    if (buffer == null) return;
    if (isSimulation) return;
    runtime.trackingTimer?.cancel();
    final interval = Duration(seconds: runtime.mode.trackingIntervalSeconds);
    runtime.trackingTimer = Timer.periodic(interval, (_) async {
      // Read the current runtime each tick — `disposeRuntime` may
      // have run between Timer ticks, in which case the buffer is
      // gone and we should bail.
      final current = _runtime;
      if (current == null) return;
      final point = await current.services.location.getCurrentPosition();
      if (point == null) return;
      final activeBuffer = current.trackingBuffer;
      if (activeBuffer == null) return;
      activeBuffer.add(
        TrackingPoint(
          timestamp: point.timestamp,
          latitude: point.latitude,
          longitude: point.longitude,
          accuracy: point.accuracy,
        ),
      );
    });
  }

  /// Stops the tracking timer without clearing the buffer (used by
  /// pause). Safe to call repeatedly.
  void _stopTrackingTimer() {
    final runtime = _runtime;
    if (runtime == null) return;
    runtime.trackingTimer?.cancel();
    runtime.trackingTimer = null;
  }

  void _handleEngineEvent({
    required ChainEventData event,
    required SessionOrchestrator orchestrator,
    required SessionLogRecorder recorder,
  }) {
    recorder.recordEvent(event);
    unawaited(orchestrator.handleEvent(event));
    if (event.event == ChainEvent.sessionPaused) {
      _stopTransientEffects();
      // Spec 11 §DE-3 — pause stops the tracker. Resume restarts it.
      _stopTrackingTimer();
    }
    if (event.event == ChainEvent.sessionResumed) {
      // Spec 11 §DE-3 — resume re-arms the periodic sampler.
      final runtime = _runtime;
      if (runtime != null) {
        _maybeStartTracking(isSimulation: runtime.engine.isSimulation);
      }
    }
    if (event.event == ChainEvent.stepStarted) {
      _maybeEmitEmergencyConfirm(event: event);
    }
    _updateWalkSession(event: event);
    if (event.event == ChainEvent.sessionEnded) {
      _stopTransientEffects();
      _persistSessionLog(recorder.log);
      // B2 fix: clear the runtime AFTER persisting the log. State is
      // intentionally left populated with phase=Ended so the
      // SimulationSummary / SessionCompleted screens can still read
      // `firedStepDescriptions`. HomeState (lib/features/home/) does
      // its own filter to ignore Ended sessions when deciding whether
      // to show the resume card.
      unawaited(disposeRuntime());
    }
  }

  void _maybeEmitEmergencyConfirm({required ChainEventData event}) {
    final runtime = _runtime;
    if (runtime == null) return;
    final stepIndex = event.stepIndex;
    if (stepIndex == null) return;
    final steps = runtime.engine.steps;
    if (stepIndex < 0 || stepIndex >= steps.length) return;
    final step = steps[stepIndex];
    if (step.type != ChainStepType.callEmergency) return;
    final cfg = step.config;
    if (cfg is! CallEmergencyConfig) return;
    if (!cfg.showConfirmation) return;
    if (runtime.engine.isSimulation) return;
    final stealth = _resolveStealthConfig(runtime);
    if (stealth.enabled && cfg.stealthSuppressConfirmation) return;
    final number = _resolveEmergencyNumber(step, cfg);
    _emergencyConfirmCtrl.add(
      EmergencyConfirmRequest(
        number: number,
        durationSeconds: cfg.confirmationDurationSeconds,
      ),
    );
  }

  StealthConfig _resolveStealthConfig(SessionRuntime runtime) {
    final overrides = runtime.mode.overrides?.stealth;
    if (overrides != null) return overrides;
    final settings = ref.read(settingsControllerProvider).value;
    return settings?.defaults.stealth ?? const StealthConfig();
  }

  String _resolveEmergencyNumber(ChainStep step, CallEmergencyConfig cfg) {
    final n = cfg.emergencyNumber;
    if (n != null && n.isNotEmpty) return n;
    final settings = ref.read(settingsControllerProvider).value;
    return settings?.emergencyCallNumber ?? '112';
  }

  void _stopTransientEffects() {
    final runtime = _runtime;
    if (runtime == null) return;
    unawaited(runtime.services.audio.stopAlarm());
    unawaited(runtime.services.audio.stopRingtone());
    unawaited(runtime.services.audio.stopVoiceRecording());
    unawaited(runtime.services.vibration.stop());
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
        // Bug #5 fix: only auto-resume when the pause was initiated
        // by this incoming call.
        final engineState = engine.state;
        if (engineState is EnginePaused &&
            engineState.reason == PauseReason.incomingCall) {
          engine.resume();
        }
    }
  }

  void _updateWalkSession({required ChainEventData event}) {
    final current = stateGetter();
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
    stateSetter(
      AsyncValue.data(
        current.copyWith(
          phase: phase,
          currentStepIndex: stepIndex,
          currentStepType: stepType,
          missCount: missCount,
          remainingSeconds: remainingSeconds,
        ),
      ),
    );
  }

  Future<void> _persistSessionLog(SessionLog log) async {
    final repo = ref.read(sessionLogsRepositoryProvider);
    await repo.save(log);
  }

  /// Appends a simulation-description toast to the live WalkSession.
  /// Public so DistressOrchestration / other helpers can append.
  void appendFiredDescription(SimulationDescription description) {
    final current = stateGetter();
    if (current == null) return;
    stateSetter(
      AsyncValue.data(
        current.copyWith(
          firedStepDescriptions: [
            ...current.firedStepDescriptions,
            description,
          ],
          lastSimulationDescription: description,
        ),
      ),
    );
  }

  // ----- Internal: defaults + helpers -------------------------------

  EventDefaults _effectiveDefaults(AppSettings settings, SessionMode mode) {
    final override = mode.overrides?.eventDefaults;
    return override ?? settings.defaults.eventDefaults;
  }

  /// Builds an [SmsTemplateResolver] that loads the
  /// [AppLocalizations] delegate for the target language and returns
  /// the localized template via [pick]. Cached so repeated calls for
  /// the same language do not re-walk the delegate.
  ///
  /// Why: the delegate lookup is synchronous (`SynchronousFuture`
  /// inside `_AppLocalizationsDelegate.load`) which lets us call this
  /// inside a strategy's `executeReal` without blocking the engine
  /// timer. Returns null when the language code is not supported, so
  /// strategies fall back to `SessionContext.defaultSmsTemplate`.
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
      // SynchronousFuture: `.load` returns immediately for the
      // generated delegate.
      AppLocalizations? resolved;
      AppLocalizations.delegate.load(locale).then((l) => resolved = l);
      if (resolved == null) return null;
      final value = pick(resolved!);
      cache[languageCode] = value;
      return value;
    };
  }

  /// Effective GPS-logging master toggle for the session (DE-2).
  ///
  /// Resolution: `mode.overrides.gpsLogging.enabled` (when set)
  /// trumps `AppDefaults.gpsLogging.enabled`. *Why:* a mode that
  /// disables GPS for battery reasons should override the global
  /// "GPS on" default — innermost wins, mirroring the rest of
  /// `ModeOverrides`.
  bool _effectiveGpsEnabled(AppSettings settings, SessionMode mode) {
    final modeGps = mode.overrides?.gpsLogging;
    if (modeGps != null) return modeGps.enabled;
    return settings.defaults.gpsLogging.enabled;
  }

  List<ReminderTemplate> _resolveTemplates({
    required SessionMode mode,
    required List<ReminderTemplate> global,
  }) {
    final local = mode.overrides?.localTemplates ?? const <ReminderTemplate>[];
    return [...global, ...local];
  }

  /// Resolves the distress chain steps for the active mode (Q52).
  /// Public so DistressOrchestrationController can use the same
  /// resolution logic.
  Future<List<ChainStep>> resolveDistressModeSteps({
    required ModesRepository modesRepo,
    required String? modeDistressModeId,
    required AppDefaults defaults,
  }) async {
    final id = modeDistressModeId ?? defaults.defaultDistressModeId;
    if (id == null) return const <ChainStep>[];
    final mode = await modesRepo.getById(id);
    if (mode == null) return const <ChainStep>[];
    return mode.chainSteps;
  }

  /// Resolves the distress chain steps for the *currently active*
  /// session: ignores `mode.distressModeId` and always falls back to
  /// `AppDefaults.defaultDistressModeId`. Used by the wrong-PIN /
  /// duress / hardware-panic paths.
  Future<List<ChainStep>> currentDistressChainSteps() async {
    final settings = await ref.read(settingsControllerProvider.future);
    final modesRepo = ref.read(modesRepositoryProvider);
    return resolveDistressModeSteps(
      modesRepo: modesRepo,
      modeDistressModeId: null,
      defaults: settings.defaults,
    );
  }

  SessionServices _resolveServices({required bool isSimulation}) {
    if (isSimulation) {
      return SessionServices(
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
      );
    }
    return SessionServices(
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
    );
  }

  /// Tears down the live runtime atomically.
  Future<void> disposeRuntime() async {
    final runtime = _runtime;
    if (runtime == null) return;
    _runtime = null;
    // Pause-expiry timer now lives in the engine itself (Q5).
    await runtime.eventsSub.cancel();
    // Spec 11 §DE-3 — kill the periodic GPS sampler and drop the
    // ephemeral buffer at session-end. The buffer is intentionally
    // never persisted (pivot 1: no session restore).
    runtime.trackingTimer?.cancel();
    runtime.trackingTimer = null;
    runtime.trackingBuffer?.clear();
    final incomingCallSub = runtime.incomingCallSub;
    if (incomingCallSub != null) {
      await incomingCallSub.cancel();
    }
    final notificationActionSub = runtime.notificationActionSub;
    if (notificationActionSub != null) {
      await notificationActionSub.cancel();
    }
    await runtime.triggerManager?.dispose();
    await runtime.orchestrator.cancelPendingWork();
    runtime.orchestrator.dispose();
    runtime.engine.dispose();
  }

  /// Handler for notification-action taps. When the user taps
  /// "End session" on a disarm-trigger notification, surface via the
  /// pending-disarm-triggers stream so the UI can present the
  /// confirmation dialog (PIN-gated).
  ///
  /// Q6: when the user taps the "I'm checked in" button on a
  /// disguised reminder, route straight to `engine.checkIn()` so the
  /// chain resets to step 0 without ending the session.
  void _onNotificationAction(String actionId) {
    switch (actionId) {
      case 'disarmTriggerEnd':
        _pendingDisarmTriggerCtrl.add(null);
        disarmRequestedHandler()?.call();
      case 'disarmTriggerContinue':
        return;
      case 'disguisedReminder.checkIn':
        unawaited(checkIn());
      default:
        return;
    }
  }

  /// Called when a disarm trigger fires via [TriggerManager]. When
  /// the app is in the background, posts a notification; then
  /// dispatches the UI callback (dialog queues until foreground).
  void _onDisarmRequestedFromTrigger(SessionServices services) {
    if (_appBackgrounded) {
      unawaited(
        services.notification.showDisarmTriggerNotification(
          title: _disarmNotificationTitle,
          body: _disarmNotificationBody,
          endSessionLabel: _disarmNotificationEnd,
          continueLabel: _disarmNotificationContinue,
        ),
      );
    }
    disarmRequestedHandler()?.call();
  }

  static const String _disarmNotificationTitle = 'Disarm trigger fired';
  static const String _disarmNotificationBody =
      'A disarm trigger fired. Tap to confirm ending the session.';
  static const String _disarmNotificationEnd = 'End session';
  static const String _disarmNotificationContinue = 'Continue';

  /// Returns a unique session id.
  static String _newSessionId() {
    final now = DateTime.now();
    return 'session-${now.microsecondsSinceEpoch}';
  }
}
