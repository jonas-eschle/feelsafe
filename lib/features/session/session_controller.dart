import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import 'package:guardianangela/data/repositories/contacts_repository.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/engine/chain_event.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/engine/triggers.dart';
import 'package:guardianangela/domain/enums/call_state.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/enums/gps_destination_source.dart';
import 'package:guardianangela/domain/enums/home_widget_status.dart';
import 'package:guardianangela/domain/enums/pause_reason.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/domain/models/session_context.dart';
import 'package:guardianangela/domain/models/session_log.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy_registry.dart';
import 'package:guardianangela/domain/orchestration/reminder_template_selector.dart';
import 'package:guardianangela/domain/triggers/disarm_trigger.dart';
import 'package:guardianangela/services/protocols/call_state_service_protocol.dart';
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
    this.fakeCallShowNonce = 0,
    this.activeReminderTemplate,
    this.reminderShowNonce = 0,
    this.pauseReason,
    this.fakeCallCancelNonce = 0,
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

  /// Monotonic counter that increments each time a `fakeCall` step starts
  /// (including retries). The session screen listens for changes and pushes
  /// the full-screen [FakeCallScreen] — the fake call "auto-appears like a real
  /// incoming call" (spec 02 §fakeCall, 04 §Fake Call Screen). A nonce (rather
  /// than a bool) so a retry of the same step index still triggers a re-show.
  final int fakeCallShowNonce;

  /// The reminder template selected for the currently firing
  /// `disguisedReminder` step, or null when no reminder is on-screen.
  ///
  /// Selected by the controller on each `reminderFired` event (spec 02
  /// §disguisedReminder template selection) and consumed by the in-app
  /// reminder UI ([_DisguisedReminderStepUi] and the full-screen
  /// `DisguisedReminderScreen`) to render the disguise and its confirmation
  /// interaction.
  final ReminderTemplate? activeReminderTemplate;

  /// Monotonic counter that increments each time a `disguisedReminder` fires
  /// (including retries). The session screen pushes the full-screen
  /// `DisguisedReminderScreen` when the bump corresponds to a `fullScreen`
  /// [activeReminderTemplate]. A nonce (rather than a bool) so a re-fire of
  /// the same step still triggers a re-show (mirrors [fakeCallShowNonce]).
  final int reminderShowNonce;

  /// Why the engine is paused, when [isPaused] is true. Lets the session
  /// screen show a specific badge — e.g. "incoming call" for an auto-pause
  /// triggered by a real phone call (spec 01 §Real Phone Call Detection, A2).
  /// Null when not paused, or paused for the generic user-requested reason.
  final PauseReason? pauseReason;

  /// Monotonic counter that increments when an active `fakeCall` is cancelled
  /// by a real incoming call (spec 01 §Real Phone Call During Fake Call,
  /// Extra-24/25). [FakeCallScreen] listens and dismisses itself; the session
  /// then auto-disarms when the real call ends.
  final int fakeCallCancelNonce;

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
    int? fakeCallShowNonce,
    ReminderTemplate? activeReminderTemplate,
    bool clearReminderTemplate = false,
    int? reminderShowNonce,
    PauseReason? pauseReason,
    bool clearPauseReason = false,
    int? fakeCallCancelNonce,
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
    fakeCallShowNonce: fakeCallShowNonce ?? this.fakeCallShowNonce,
    activeReminderTemplate: clearReminderTemplate
        ? null
        : (activeReminderTemplate ?? this.activeReminderTemplate),
    reminderShowNonce: reminderShowNonce ?? this.reminderShowNonce,
    pauseReason: clearPauseReason ? null : (pauseReason ?? this.pauseReason),
    fakeCallCancelNonce: fakeCallCancelNonce ?? this.fakeCallCancelNonce,
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
  EventServices? _eventServices;
  DateTime? _startedAt;
  String? _markerLogId;

  /// Subscription to [CallStateServiceProtocol.callState] for real
  /// incoming-call detection; non-null only while a session is running.
  StreamSubscription<CallState>? _callStateSub;

  /// The call-state service started for the current session, retained so it can
  /// be stopped on teardown without re-reading the provider.
  CallStateServiceProtocol? _callStateService;

  /// True between a real call becoming active (ringing/offhook) and returning
  /// to idle. Edge-tracked so a single call's ringing→offhook transition fires
  /// the handler exactly once (spec 01 §Real Phone Call Detection).
  bool _realCallActive = false;

  /// True when this controller paused the engine for a real call, so call-end
  /// resume does not clobber a separate user-requested pause.
  bool _pausedByRealCall = false;

  /// True when a real call cancelled an active fakeCall; the session disarms
  /// when that call ends (spec 01 §Real Phone Call During Fake Call,
  /// Extra-24/25).
  bool _disarmOnRealCallEnd = false;

  /// Merged pool of reminder templates (global + mode-local) resolved once at
  /// [startSession] and read by [_selectReminderTemplate]. Empty outside a
  /// session.
  List<ReminderTemplate> _reminderTemplatePool = const [];

  /// The template chosen for the current `disguisedReminder` fire. Mirrors
  /// [SessionState.activeReminderTemplate] but is read by [_dispatchStep] to
  /// attach the disguise to the out-of-app notification. Null between fires.
  ReminderTemplate? _activeReminderTemplate;

  /// ID of the previously shown reminder template, so [_selectReminderTemplate]
  /// can avoid showing the same disguise twice in a row (C4). Reset to null on
  /// [startSession]; the strategy itself stays stateless.
  String? _lastShownReminderTemplateId;

  // Pre-localised labels for the home-screen widget. Callers (HomeScreen)
  // supply these before calling startSession via [configureWidgetLabels] so
  // the controller can publish fully-localised widget data without needing a
  // BuildContext (spec 04 §Home Screen Widget).
  String _widgetStatusIdle = 'Idle';
  String _widgetStatusSession = 'Session active';
  String _widgetStatusSim = 'Simulation active';
  String _widgetStatusBattery = 'Battery alert';
  String _widgetQuickExit = 'Quick Exit';
  String _widgetFakeCall = 'Fake Call';

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

  /// Supplies pre-localised widget labels from [HomeScreen] (which has a
  /// [BuildContext] for l10n) before session transitions.
  ///
  /// Callers provide labels once at app startup or when the locale changes.
  /// The controller uses them for every subsequent [_publishWidgetStatus] call,
  /// avoiding BuildContext access inside the notifier.
  void configureWidgetLabels({
    required String statusIdle,
    required String statusSession,
    required String statusSim,
    required String statusBattery,
    required String quickExit,
    required String fakeCall,
  }) {
    _widgetStatusIdle = statusIdle;
    _widgetStatusSession = statusSession;
    _widgetStatusSim = statusSim;
    _widgetStatusBattery = statusBattery;
    _widgetQuickExit = quickExit;
    _widgetFakeCall = fakeCall;
  }

  /// Returns the wall-clock elapsed duration since session start, or null when
  /// no session is active.
  ///
  /// Used by [_publishWidgetStatus] callers to snapshot the elapsed time at
  /// each session-state transition for the home-screen widget timer.
  Duration? _elapsedSinceStart() {
    final start = _startedAt;
    if (start == null) return null;
    return DateTime.now().difference(start);
  }

  /// Publishes [status] to the home-screen widget via [homeWidgetServiceProvider].
  ///
  /// Fire-and-forget — widget updates must never block session transitions.
  /// [elapsed] is forwarded to the service to render the mm:ss timer.
  void _publishWidgetStatus(HomeWidgetStatus status, {Duration? elapsed}) {
    final statusText = switch (status) {
      HomeWidgetStatus.idle => _widgetStatusIdle,
      HomeWidgetStatus.sessionActive => _widgetStatusSession,
      HomeWidgetStatus.simulationActive => _widgetStatusSim,
      HomeWidgetStatus.batteryAlert => _widgetStatusBattery,
    };
    unawaited(
      ref
          .read(homeWidgetServiceProvider)
          .publishStatus(
            status: status,
            elapsed: elapsed,
            statusText: statusText,
            quickExitLabel: _widgetQuickExit,
            fakeCallLabel: _widgetFakeCall,
          )
          .catchError((Object e) {
            log(
              'homeWidgetService.publishStatus error: $e',
              name: 'SessionController',
            );
          }),
    );
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
    bool writeInterruptMarker = true,
  }) async {
    if (_engine != null) {
      throw StateError(
        'startSession called while another session is already running.',
      );
    }
    final settings = await ref.read(appSettingsRepositoryProvider).load();
    final profile = await ref.read(userProfileRepositoryProvider).load();
    // Merge global templates with this mode's local templates — the effective
    // pool a disguisedReminder draws from (spec 02:91, mode_overrides.dart:10).
    final templates = <ReminderTemplate>[
      ...settings.defaults.templates,
      ...?mode.overrides?.localTemplates,
    ];
    _reminderTemplatePool = templates;
    _lastShownReminderTemplateId = null;
    _activeReminderTemplate = null;
    final context = SessionContext(
      mode: mode,
      profile: profile,
      reminderTemplates: templates,
    );
    // Write an in-progress marker log so cold launch can detect an
    // interrupted session (Extra 13). The marker is overwritten by the final
    // log on clean end.
    //
    // Skipped when [writeInterruptMarker] is false — used by the App-lock
    // launch gate's cold-start distress. The marker's `modeName` would be the
    // distress mode ("Default Distress"); surfacing the interrupted-session
    // prompt on the next launch would reveal a covert Duress-PIN distress run
    // to an attacker who force-stopped the app, defeating the Duress PIN.
    if (!simulate && writeInterruptMarker) {
      final repo = await ref.read(sessionLogRepositoryProvider.future);
      final markerId = const Uuid().v4();
      _markerLogId = markerId;
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
    // Publish with elapsed=Duration.zero at session start — the widget timer
    // will be updated on the next session-active transition. The snapshot is
    // OS-throttled and cannot tick per-second from the app; a future
    // enhancement can publish a start-epoch for a native live timer.
    _publishWidgetStatus(
      simulate
          ? HomeWidgetStatus.simulationActive
          : HomeWidgetStatus.sessionActive,
      elapsed: Duration.zero,
    );
    _distressMode = distressMode;
    // Build one EventServices bundle per session. Constructed here (before
    // engine.start) so every strategy executed during this session shares the
    // same resolved contact list and profile data without re-reading providers
    // inside hot paths. Stored in _eventServices and nulled out in the finalize
    // path alongside _engine and _recorder.
    final contactService = await ref.read(contactServiceProvider.future);
    _eventServices = EventServices(
      audio: ref.read(audioServiceProvider),
      vibration: ref.read(vibrationServiceProvider),
      messaging: ref.read(messagingServiceProvider),
      phone: ref.read(phoneServiceProvider),
      location: ref.read(locationServiceProvider),
      recording: ref.read(recordingServiceProvider),
      flash: ref.read(flashServiceProvider),
      screenFlash: ref.read(screenFlashServiceProvider),
      contacts: contactService,
      notification: ref.read(notificationServiceProvider),
      isSimulation: simulate,
      userName: profile.name,
      userDescription: profile.physicalDescription,
      userMedicalInfo: profile.medicalConditions,
      emergencyNumberDefault: settings.emergencyCallNumber,
      alarmDndOverride: settings.alarmDndOverride,
      alarmGradualVolume: settings.alarmGradualVolume,
      alarmGradualVolumeDurationSeconds:
          settings.alarmGradualVolumeDurationSeconds,
      isCancelled: () {
        final e = _engine;
        return e == null || e.isEnded;
      },
    );
    // Engage Android lock-task / pinned-app mode when the user enabled
    // it in stealth settings. Non-Android platforms no-op (spec 04
    // §Stealth Settings: lockTaskMode).
    if (stealth.lockTaskMode && !simulate) {
      await ref.read(systemUiServiceProvider).toggleLockTaskMode(true);
    }
    engine.start();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());

    // Wire real incoming-call detection (spec 01 §Real Phone Call Detection).
    // Subscribe before start() so no early telephony event is missed. Skipped
    // in simulation — there is no real telephony to observe.
    if (!simulate) {
      final callStateService = ref.read(callStateServiceProvider);
      _callStateService = callStateService;
      _realCallActive = false;
      _pausedByRealCall = false;
      _disarmOnRealCallEnd = false;
      _callStateSub = callStateService.callState.listen(_onCallStateChanged);
      await callStateService.start();
    }
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

  /// Called when the user taps a disguised reminder during its wait phase —
  /// before it fires — to check in early (spec 02 §Early Check-in, D4).
  ///
  /// Reads the step's [DisguisedReminderConfig.resetOnEarlyCheckIn]: when
  /// `false`, the engine deliberately ignores the early tap and the reminder
  /// still fires on schedule (stricter verification). The engine no-ops
  /// outside a disguisedReminder wait phase.
  void earlyCheckIn() {
    final config = _engine?.currentStep?.config;
    final reset =
        config is! DisguisedReminderConfig || config.resetOnEarlyCheckIn;
    _engine?.earlyCheckIn(resetOnEarlyCheckIn: reset);
  }

  /// Restart the current step after the user dismisses a fake call etc.
  void restartCurrentStep() {
    _engine?.restartCurrentStep();
  }

  /// Called when the user answers the fake call (slide-to-answer completes).
  ///
  /// Stops the ringtone and plays the configured voice recording (or the
  /// built-in default). The engine timer keeps running — fakeCall is an event,
  /// not a pause (Pivot 2 / R-1); [SessionEngine.answerFakeCall] is a no-op at
  /// the engine level, so the audio is owned here. No-op if no session is
  /// active. [useSpeaker] routes the clip to the speaker (vs the earpiece).
  Future<void> answerFakeCall({
    String? voiceRecordingPath,
    bool useSpeaker = false,
  }) async {
    _engine?.answerFakeCall();
    final services = _eventServices;
    if (services == null) return;
    await services.audio.stop();
    await services.audio.playVoiceRecording(
      voiceRecordingPath,
      useSpeaker: useSpeaker,
      isSimulation: services.isSimulation,
    );
  }

  /// Called when the user hangs up after answering the fake call.
  ///
  /// Stops the voice clip and disarms (resets the chain to step 0) per the
  /// fake-call hang-up semantics (spec 02 §fakeCall, Pivot 2).
  void hangUpFakeCall() {
    unawaited(_eventServices?.audio.stop() ?? Future<void>.value());
    _engine?.hangUp();
  }

  /// Called when the user declines the incoming fake call (brief tap).
  ///
  /// Stops the ringtone, then either disarms (when [declineIsSafe] — the user
  /// signalled they are safe) or counts a miss and re-rings via
  /// [restartCurrentStep] (spec 02 §fakeCall Decline).
  void declineFakeCall({required bool declineIsSafe}) {
    unawaited(_eventServices?.audio.stop() ?? Future<void>.value());
    if (declineIsSafe) {
      _engine?.disarm();
    } else {
      _engine?.restartCurrentStep();
    }
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

  /// Fires the distress chain when there is no active session.
  ///
  /// Used by the App-lock launch gate (spec 06 §App PIN / §Duress PIN): a
  /// Duress PIN entered at cold start, or the wrong-PIN threshold reached
  /// there, must silently start the distress chain even though no safety
  /// session is running. Resolves the **global** default distress mode
  /// (`AppDefaults.defaultDistressModeId` — there is no active mode to inherit
  /// from at launch), starts it, and immediately enters the distress chain so
  /// the run is flagged distress and stamped with [reason] for forensics.
  ///
  /// When a session IS already running this delegates to [confirmDistress]
  /// (the running-session path). Fail-loud — surfaces an error rather than
  /// silently doing nothing — when no default distress mode is configured or
  /// the referenced mode is missing.
  Future<void> startDistressSession({required EndReason reason}) async {
    if (_engine != null) {
      confirmDistress(reason: reason);
      return;
    }
    final settings = await ref.read(appSettingsRepositoryProvider).load();
    final distressId = settings.defaults.defaultDistressModeId;
    if (distressId == null) {
      _surfaceError(
        'Distress requested at the launch gate but no default distress mode '
        'is configured.',
      );
      return;
    }
    final db = await ref.read(databaseProvider.future);
    final distressMode = await db.sessionModesDao.getById(distressId);
    if (distressMode == null) {
      _surfaceError('Default distress mode "$distressId" not found.');
      return;
    }
    // Start the distress mode as the session, then immediately enter the
    // distress chain so it is flagged distress and stamped with [reason]. This
    // reuses the fully-tested startSession + confirmDistress paths rather than
    // duplicating engine bootstrap.
    //
    // writeInterruptMarker: false — a killed cold-start distress must NOT
    // surface a "Mode: Default Distress" interrupted-session prompt on next
    // launch, which would reveal the covert Duress run to an attacker.
    await startSession(
      mode: distressMode,
      simulate: false,
      distressMode: distressMode,
      writeInterruptMarker: false,
    );
    confirmDistress(reason: reason);
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

  /// Notifies the home-screen widget that a battery alert has fired.
  ///
  /// Called by [SessionScreen] when [BatteryMonitorService] fires a low-battery
  /// alert during an active session. The widget switches to the batteryAlert
  /// status until the session ends (spec 04 §Home Screen Widget). No-op when
  /// no session is active.
  void notifyBatteryAlert() {
    if (_engine == null) return;
    _publishWidgetStatus(
      HomeWidgetStatus.batteryAlert,
      elapsed: _elapsedSinceStart(),
    );
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

  /// Handles a telephony state change from [CallStateServiceProtocol].
  ///
  /// Edge-tracks the transition idle→active (ringing/offhook) and active→idle
  /// so a single call's ringing→offhook change does not double-fire. See
  /// spec 01 §Real Phone Call Detection.
  void _onCallStateChanged(CallState callState) {
    if (_engine == null) return;
    final active = callState != CallState.idle;
    if (active && !_realCallActive) {
      _realCallActive = true;
      _onRealCallStarted();
    } else if (!active && _realCallActive) {
      _realCallActive = false;
      _onRealCallEnded();
    }
  }

  /// A real call started while a session is active.
  ///
  /// The chain is always paused so it cannot escalate during the call (a
  /// `fakeCall` step has `retryCount=0` by default and would otherwise advance
  /// to the next step). On a `fakeCall` step the fake call is additionally
  /// cancelled — ringtone stopped and the screen dismissed — and flagged to
  /// auto-disarm when the call ends (spec 01 §Real Phone Call During Fake Call,
  /// Extra-24/25; §Real Phone Call Detection, A2 / Extra-30/31).
  void _onRealCallStarted() {
    final engine = _engine;
    if (engine == null) return;
    final isFakeCall = engine.currentStep?.type == ChainStepType.fakeCall;
    if (!engine.isPaused) {
      engine.pause(reason: PauseReason.incomingCall);
      _pausedByRealCall = true;
    }
    if (isFakeCall) {
      unawaited(_eventServices?.audio.stop() ?? Future<void>.value());
      _disarmOnRealCallEnd = true;
      final s = state.value;
      if (s != null) {
        state = AsyncData(
          s.copyWith(fakeCallCancelNonce: s.fakeCallCancelNonce + 1),
        );
      }
    }
  }

  /// The real call ended.
  ///
  /// Resumes a session this controller paused for the call, then — when the
  /// call had cancelled a fake call — disarms (resets to step 0). The resume
  /// only restarts the saved phase timer; the immediately-following disarm
  /// cancels it, so the fake call never re-rings (spec 01 §Real Phone Call
  /// During Fake Call, Extra-24/25).
  void _onRealCallEnded() {
    final engine = _engine;
    if (engine == null) return;
    if (_pausedByRealCall) {
      _pausedByRealCall = false;
      engine.resume();
    }
    if (_disarmOnRealCallEnd) {
      _disarmOnRealCallEnd = false;
      engine.disarm();
    }
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
    _publishWidgetStatus(HomeWidgetStatus.idle);
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
    _eventServices = null;
    _resetReminderState();
  }

  Future<void> _disposeRunOnly() async {
    _tick?.cancel();
    _tick = null;
    _distressCountdownTimer?.cancel();
    _distressCountdownTimer = null;
    await _eventsSub?.cancel();
    _eventsSub = null;
    _teardownCallState();
    _engine = null;
    _eventServices = null;
    _resetReminderState();
  }

  /// Stops real incoming-call detection and clears its session-scoped state.
  void _teardownCallState() {
    unawaited(_callStateSub?.cancel() ?? Future<void>.value());
    _callStateSub = null;
    unawaited(_callStateService?.stop() ?? Future<void>.value());
    _callStateService = null;
    _realCallActive = false;
    _pausedByRealCall = false;
    _disarmOnRealCallEnd = false;
  }

  /// Clears the session-scoped reminder selection state (pool, last-shown
  /// avoidance id, and active disguise) when a session ends or is torn down.
  void _resetReminderState() {
    _reminderTemplatePool = const [];
    _activeReminderTemplate = null;
    _lastShownReminderTemplateId = null;
  }

  void _disposeAll() {
    _tick?.cancel();
    _distressCountdownTimer?.cancel();
    _eventsSub?.cancel();
    _teardownCallState();
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

  /// Resolves the active step's strategy and runs its real action.
  ///
  /// No-op in simulation (Layer-1 sim guard — strategies also self-guard via
  /// Layer-2 in [EventServices.isSimulation]). Fire-and-forget: the engine's
  /// phase timers advance the chain independently so a slow or failing action
  /// never blocks escalation (spec 01 §Non-Blocking Event Execution). Failures
  /// are isolated and reported via [SessionEngine.notifyStepExecutionFailed].
  Future<void> _dispatchStep() async {
    final services = _eventServices;
    final engine = _engine;
    if (services == null || engine == null || services.isSimulation) return;
    final step = engine.currentStep;
    if (step == null) return;
    final index = engine.currentStepIndex;
    // Attach the selected disguise so the reminder notification shows the
    // template's title/body rather than a generic string (spec 02
    // §disguisedReminder). Other step types use the session-constant bundle.
    final dispatchServices = step.type == ChainStepType.disguisedReminder
        ? services.copyWith(selectedReminderTemplate: _activeReminderTemplate)
        : services;
    try {
      await const EventStrategyRegistry()
          .forStep(step)
          .executeReal(step, dispatchServices);
    } catch (error) {
      engine.notifyStepExecutionFailed(index, error);
    }
  }

  /// Selects the disguise for the current `disguisedReminder` fire using the
  /// pure [selectReminderTemplate] algorithm, honouring the step's
  /// `templateIds` / `randomizeTemplateOrder` config and avoiding a repeat of
  /// the previously shown template (C4). The clock is read here (not in the
  /// pure helper) so the helper stays deterministic.
  ReminderTemplate _selectReminderTemplate() {
    final config = _engine?.currentStep?.config;
    final templateIds = config is DisguisedReminderConfig
        ? config.templateIds
        : const <String>[];
    final randomize =
        config is! DisguisedReminderConfig || config.randomizeTemplateOrder;
    return selectReminderTemplate(
      pool: _reminderTemplatePool,
      templateIds: templateIds,
      randomizeTemplateOrder: randomize,
      nowMillis: DateTime.now().millisecondsSinceEpoch,
      avoidId: _lastShownReminderTemplateId,
    );
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
        // Bump the fake-call show signal so the session screen auto-pushes the
        // full-screen call UI (including on a retry of the same step index).
        final isFakeCall = event.stepType == ChainStepType.fakeCall;
        state = AsyncData(
          s.copyWith(
            currentStepIndex: event.stepIndex ?? s.currentStepIndex,
            phase: isHold ? SessionPhase.holdWait : SessionPhase.wait,
            isHolding: engine?.isHolding ?? false,
            missCount: 0,
            clearError: true,
            fakeCallShowNonce: isFakeCall
                ? s.fakeCallShowNonce + 1
                : s.fakeCallShowNonce,
          ),
        );
        // Dispatch the real action for every step type except disguisedReminder.
        // disguisedReminder waits for its interval/delay and only fires on
        // reminderFired — dispatching here would run the notification before
        // the wait elapses (spec 01 §Non-Blocking Event Execution, spec 02
        // §disguisedReminder waitSeconds).
        if (event.stepType != ChainStepType.disguisedReminder) {
          unawaited(_dispatchStep());
        }
      case ChainEvent.reminderFired:
        // Select the disguise for this fire BEFORE dispatching, so both the
        // in-app overlay (via state) and the out-of-app notification (via
        // _dispatchStep) show the same template (spec 02 §disguisedReminder
        // template selection). The nonce bump drives the full-screen route.
        final template = _selectReminderTemplate();
        _activeReminderTemplate = template;
        _lastShownReminderTemplateId = template.id;
        state = AsyncData(
          s.copyWith(
            phase: SessionPhase.duration,
            activeReminderTemplate: template,
            reminderShowNonce: s.reminderShowNonce + 1,
          ),
        );
        unawaited(_dispatchStep());
      case ChainEvent.graceExpired:
        final missCount =
            (event.metadata['missCount'] as int?) ?? s.missCount + 1;
        state = AsyncData(s.copyWith(missCount: missCount));
      case ChainEvent.repeatMissed:
        // Already reflected via missCount in the graceExpired branch.
        break;
      case ChainEvent.stepAdvancing:
        // The reminder (if any) is over — clear the disguise so the
        // full-screen route auto-pops and no stale card lingers.
        _activeReminderTemplate = null;
        state = AsyncData(
          s.copyWith(phase: SessionPhase.wait, clearReminderTemplate: true),
        );
      case ChainEvent.userDisarmed:
        _activeReminderTemplate = null;
        state = AsyncData(
          s.copyWith(
            currentStepIndex: 0,
            missCount: 0,
            phase: SessionPhase.wait,
            isHolding: false,
            clearReminderTemplate: true,
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
        // Distress chain activation is a significant status transition that
        // the home-screen widget should reflect immediately.
        _publishWidgetStatus(
          HomeWidgetStatus.sessionActive,
          elapsed: _elapsedSinceStart(),
        );
      case ChainEvent.distressCompleted:
        // No additional UI handling — sessionEnded will fire next.
        break;
      case ChainEvent.sessionPaused:
        final reasonName = event.metadata['reason'] as String?;
        final reason = reasonName == null
            ? null
            : PauseReason.values.firstWhere(
                (PauseReason r) => r.name == reasonName,
                orElse: () => PauseReason.userRequested,
              );
        state = AsyncData(
          s.copyWith(
            isPaused: true,
            pauseReason: reason,
            clearPauseReason: reason == null,
          ),
        );
      case ChainEvent.sessionResumed:
        state = AsyncData(s.copyWith(isPaused: false, clearPauseReason: true));
      case ChainEvent.pauseExpired:
        state = AsyncData(s.copyWith(isPaused: false, clearPauseReason: true));
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
        _publishWidgetStatus(HomeWidgetStatus.idle);
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
