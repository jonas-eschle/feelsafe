/// Shared host integration harness for the INT-### session scenarios.
///
/// The integration scenarios (INT-001..014, spec 07 §Integration Test
/// Scenarios) drive the **real** [SessionController] + [SessionEngine] through
/// a full session lifecycle under `fakeAsync`, asserting the end-to-end chain
/// of engine events, the strategy side-effects recorded by fake services, and
/// the terminal state — proving the wired features actually compose into a
/// working session (not a shallow render).
///
/// This file establishes the reusable pieces every INT scenario needs:
///
/// - [RecordingFakes] — a bundle of the recording fake services (re-using the
///   established `FakeMessagingService` / `FakePhoneService` / … set from
///   `test/domain/orchestration/_test_fakes.dart`) so a scenario can assert
///   `fakes.messaging.calls` / `fakes.phone.calls` after a run.
/// - [buildIntegrationContainer] — wires every service provider in
///   `service_providers.dart` to the fakes, an in-memory [GuardianAngelaDatabase],
///   a fake settings/profile repository, and the real [SimulationSessionLogRecorder]
///   (so the in-progress / finalised [SessionLog] marker path runs for real).
/// - [SessionDriver] — wraps the controller-under-test: starts a session,
///   subscribes to the engine event stream, and exposes the collected
///   [events] / live [snapshot] / [endReason] for assertions.
///
/// **`fakeAsync` + `_FixedRandom` contract (read before adding a scenario).**
/// `SessionController.startSession` builds its [SessionEngine] **without**
/// injecting a `random` — it uses the real `Random()`. To keep phase timing
/// *exact* (the `_FixedRandom(0.5)` engine-test standard yields the identical
/// no-jitter timing) every scenario must disable jitter at the source:
///
///  1. Set `randomize: false` on every [ChainStep] (governs the generic
///     wait/duration/grace jitter).
///  2. For a `disguisedReminder` step, ALSO set `randomizeInterval: false` AND
///     `randomizeTemplateOrder: false` on its [DisguisedReminderConfig] — both
///     default to **true**, and `ChainStep.randomize` does NOT override them, so
///     leaving them on jitters the reminder wait phase by ±20% (a 10s wait
///     becomes 8–12s) and picks a non-deterministic template — a `fakeAsync`
///     boundary flake. (This bit C1 once; documented so C2/C3 don't repeat it.)
///
/// Phase timers are wall-clock `Timer`s reading the ambient `package:clock`,
/// which `fakeAsync` overrides via `withClock` — so `async.elapse(...)` advances
/// the engine deterministically with no real delay.
///
/// C2/C3 (INT-005..014) reuse this file verbatim — add new scenario files
/// under `test/integration/` and import `_session_harness.dart`.
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart' show addTearDown;

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/data/repositories/session_log_repository.dart';
import 'package:guardianangela/data/repositories/user_profile_repository.dart';
import 'package:guardianangela/domain/engine/chain_event.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/session_context.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/user_profile.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/session_log_recorder.dart';
import 'package:guardianangela/services/sim/background_session_service_sim.dart';
import 'package:guardianangela/services/sim/call_state_service_sim.dart';
import 'package:guardianangela/services/sim/home_widget_service_sim.dart';
import 'package:guardianangela/services/sim/system_ui_service_sim.dart';
import '../domain/orchestration/_test_fakes.dart';

// Re-export the recording fakes so an INT scenario only imports this harness.
export '../domain/orchestration/_test_fakes.dart'
    show
        FakeAudioService,
        FakeContactService,
        FakeFlashService,
        FakeLocationService,
        FakeMessagingService,
        FakeNotificationService,
        FakePhoneService,
        FakeRecordingService,
        FakeScreenFlashService,
        FakeVibrationService;

// ─── Fake repositories ──────────────────────────────────────────────────────

/// In-memory [AppSettingsRepository] returning a fixed [AppSettings].
///
/// The base class needs a key + dir provider even though [load] is overridden;
/// they are supplied with throwaway values so no real keystore / filesystem is
/// touched.
final class FakeAppSettingsRepository extends AppSettingsRepository {
  /// Creates a fake that always [load]s [_settings].
  FakeAppSettingsRepository(this._settings)
    : super(
        keyProvider: () async =>
            '0102030405060708090a0b0c0d0e0f'
            '101112131415161718191a1b1c1d1e1f20',
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('int_harness_settings_'),
      );

  final AppSettings _settings;

  @override
  Future<AppSettings> load() async => _settings;
}

/// In-memory [UserProfileRepository] returning a fixed [UserProfile].
final class FakeUserProfileRepository extends UserProfileRepository {
  /// Creates a fake that always [load]s [_profile].
  FakeUserProfileRepository([UserProfile? profile])
    : _profile = profile ?? const UserProfile(),
      super(keyProvider: _key);

  final UserProfile _profile;

  static Future<String> _key() async => '00' * 32;

  @override
  Future<UserProfile> load() async => _profile;
}

// ─── Recording fakes bundle ─────────────────────────────────────────────────

/// Bundle of the recording fake services wired into an integration container.
///
/// Hold a reference to this (via [buildIntegrationContainer]) so a scenario can
/// assert the strategy side-effects after driving the session, e.g.
/// `expect(fakes.messaging.calls, isEmpty)` (no SMS fired) or
/// `expect(fakes.phone.calls.where((c) => c['method'] == 'callEmergency'),
/// isNotEmpty)`.
final class RecordingFakes {
  /// Creates a bundle, defaulting each fake to a fresh recorder.
  ///
  /// [contacts] seeds the [FakeContactService] so the `smsContact` strategy has
  /// recipients to resolve (an empty contact list makes `sendMessage` a no-op).
  RecordingFakes({List<EmergencyContact>? contacts})
    : audio = FakeAudioService(),
      vibration = FakeVibrationService(),
      messaging = FakeMessagingService(),
      phone = FakePhoneService(),
      location = FakeLocationService(),
      recording = FakeRecordingService(),
      flash = FakeFlashService(),
      screenFlash = FakeScreenFlashService(),
      notification = FakeNotificationService(),
      contacts = FakeContactService(contacts ?? const []);

  /// Recording audio service (alarm / ringtone / voice-clip calls).
  final FakeAudioService audio;

  /// Recording vibration service.
  final FakeVibrationService vibration;

  /// Recording messaging service — `messaging.calls` proves `smsContact` sends.
  final FakeMessagingService messaging;

  /// Recording phone service — `phone.calls` proves `callEmergency` /
  /// `phoneCallContact` dials.
  final FakePhoneService phone;

  /// Fake location service (returns a fixed maps URL).
  final FakeLocationService location;

  /// Recording audio-recording service.
  final FakeRecordingService recording;

  /// Recording flashlight service.
  final FakeFlashService flash;

  /// Recording screen-flash service.
  final FakeScreenFlashService screenFlash;

  /// Recording notification service — proves `disguisedReminder` / alarm
  /// notifications.
  final FakeNotificationService notification;

  /// Contact lookup backing `smsContact` recipient resolution.
  final FakeContactService contacts;
}

// ─── Teardown: drain-then-close ──────────────────────────────────────────────

/// Drains the real event loop, then closes [db]. **Every**
/// `buildIntegrationContainer`-based session scenario MUST tear its DB down
/// through this helper (`tearDown(() => closeIntegrationDb(db))`), never a bare
/// `await db.close()`.
///
/// **Why (host-VM teardown crash — the M5 root cause).** These scenarios run a
/// `fakeAsync` body, but the **real** [SessionController] finalises its
/// [SessionLog] via `unawaited(_finaliseLog(...))` and seeds the in-progress
/// marker via an unawaited `upsert`. Those are genuine `package:drift` writes
/// against the native sqlite3 in-memory [db], so they **escape the `fakeAsync`
/// zone** and settle on the *real* event loop AFTER the `fakeAsync` body has
/// returned. If `tearDown` then closes the native DB while one of those writes
/// is still in flight, a native-layer free races a live statement and crashes
/// the shared `flutter_tester` shell — surfacing non-deterministically under
/// `--concurrency=6` as `Shell subprocess crashed with segmentation fault` /
/// SIGTERM / `<test> - did not complete`, AFTER every assertion has already
/// passed (so the test logic is correct — it is purely a teardown-ordering
/// fault). Awaiting two zero-duration *real* `Timer`s here yields the event loop
/// long enough for every escaped write to complete against the still-open DB
/// before it is closed, making finalization deterministic. No assertion is
/// affected. (Empirically: `flutter test --concurrency=6 test/integration/` goes
/// from ~15-30%-crash to 20/20 clean with this helper applied to every
/// DB-closing session scenario.)
Future<void> closeIntegrationDb(GuardianAngelaDatabase db) async {
  // Two real-event-loop turns: the first lets the escaped `_finaliseLog`
  // future run, the second lets its awaited `upsert` continuation settle.
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
  await db.close();
}

// ─── Container builder ──────────────────────────────────────────────────────

/// Builds a [ProviderContainer] that drives the **real** [SessionController]
/// with the recording [fakes], an in-memory [db], and a fixed [settings] /
/// [profile].
///
/// Every service provider in `service_providers.dart` is overridden so
/// `startSession` never touches real hardware or platform channels. The
/// session-log recorder is the real [SimulationSessionLogRecorder] writing to a
/// [SessionLogRepository] over [db], so the in-progress→finalised marker path
/// runs for real (exercised by INT-012 later).
///
/// The container is registered for disposal via [addTearDown]. End the session
/// inside the `fakeAsync` body before the callback returns so no engine timer
/// outlives the test (fakeAsync asserts a clean timer queue on exit).
/// [callState] lets a scenario inject its own [SimulationCallStateService] so
/// it can drive `setState(CallState.ringing/idle)` and exercise the real
/// controller pause/resume-on-real-call wiring (INT-007/INT-008). When omitted
/// a fresh no-op instance is used (the call-state path is never triggered).
ProviderContainer buildIntegrationContainer({
  required GuardianAngelaDatabase db,
  required RecordingFakes fakes,
  AppSettings settings = const AppSettings(),
  UserProfile profile = const UserProfile(),
  SimulationCallStateService? callState,
}) {
  final container = ProviderContainer(
    overrides: [
      appSettingsRepositoryProvider.overrideWithValue(
        FakeAppSettingsRepository(settings),
      ),
      userProfileRepositoryProvider.overrideWithValue(
        FakeUserProfileRepository(profile),
      ),
      databaseProvider.overrideWith((ref) async => db),
      // Real recorder over the in-memory DB — exercises the SessionLog marker
      // write/finalise path end-to-end.
      sessionLogRecorderProvider.overrideWith((ref) async {
        final repo = await ref.watch(sessionLogRepositoryProvider.future);
        return (SessionContext ctx) =>
            SimulationSessionLogRecorder(context: ctx, repo: repo);
      }),
      // Recording fakes — strategy side-effects land in their `.calls` lists.
      audioServiceProvider.overrideWithValue(fakes.audio),
      vibrationServiceProvider.overrideWithValue(fakes.vibration),
      messagingServiceProvider.overrideWithValue(fakes.messaging),
      phoneServiceProvider.overrideWithValue(fakes.phone),
      locationServiceProvider.overrideWithValue(fakes.location),
      recordingServiceProvider.overrideWithValue(fakes.recording),
      flashServiceProvider.overrideWithValue(fakes.flash),
      screenFlashServiceProvider.overrideWithValue(fakes.screenFlash),
      notificationServiceProvider.overrideWithValue(fakes.notification),
      contactServiceProvider.overrideWith((_) async => fakes.contacts),
      // Platform-only side services that startSession touches but the INT
      // scenarios do not assert — sim no-ops keep the lifecycle hardware-free.
      systemUiServiceProvider.overrideWithValue(SimulationSystemUiService()),
      homeWidgetServiceProvider.overrideWithValue(
        SimulationHomeWidgetService(),
      ),
      callStateServiceProvider.overrideWithValue(
        callState ?? SimulationCallStateService(),
      ),
      backgroundSessionServiceProvider.overrideWithValue(
        SimulationBackgroundSessionService(),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

// ─── Session driver ─────────────────────────────────────────────────────────

/// Drives one [SessionController] session and collects the engine event log.
///
/// Construct via [SessionDriver.start] inside a `fakeAsync` body. It reads the
/// controller, starts the session for [mode], subscribes to the live engine
/// event stream, and flushes microtasks so `startSession`'s awaited provider
/// reads settle before any `async.elapse`.
///
/// **Start-event capture (KEY behavior).** `engine.start()` runs *synchronously*
/// near the end of the awaited `startSession`, so it emits the initial
/// `sessionStarted` + `stepStarted(0)` during the same microtask drain that the
/// driver flushes before it can obtain the engine reference and subscribe.
/// Those two t=0 events are therefore **not** in [events]; they are proven
/// instead by the engine *state* immediately after start ([currentStepIndex] ==
/// 0 in the wait/holdWait phase). Every event after start — disarm-replayed
/// `stepStarted`, `graceExpired`, `stepAdvancing`, `reminderFired`,
/// `distressTriggered`, `sessionEnded`, … — is captured in full because it fires
/// during a later `async.elapse(...)`.
///
/// Thereafter:
///
/// - [events] — every [ChainEvent] emitted since start, in order.
/// - [snapshot] — the live [EngineState] (delegates to `engine.snapshot`; the
///   spec's prose name `engine.state` maps here — KEY API reconciliation).
/// - [currentStepIndex] / [isDistressChain] / [isEnded] — convenience reads.
/// - [endReason] — the reason carried by the terminal `sessionEnded` event.
/// - [stop] — ends the session and flushes, leaving a clean timer queue.
final class SessionDriver {
  SessionDriver._(this._container, this._notifier);

  /// Starts a real session for [mode] and begins collecting engine events.
  ///
  /// Must be called inside a `fakeAsync` body; [async] flushes the controller's
  /// awaited `build` + `startSession` provider reads. [simulate] toggles a
  /// simulation session; [distressMode] supplies the distress chain the
  /// controller swaps in on a distress trigger (INT-004/005).
  static SessionDriver start(
    dynamic async, {
    required ProviderContainer container,
    required SessionMode mode,
    bool simulate = false,
    SessionMode? distressMode,
    double speedMultiplier = 1.0,
  }) {
    // Settle the AsyncNotifier.build() future (reads sessionLogRepository).
    unawaited(container.read(sessionControllerProvider.future));
    async.flushMicrotasks();
    final notifier = container.read(sessionControllerProvider.notifier);
    final driver = SessionDriver._(container, notifier);

    unawaited(
      notifier.startSession(
        mode: mode,
        simulate: simulate,
        distressMode: distressMode,
        speedMultiplier: speedMultiplier,
      ),
    );
    // startSession awaits several providers + the marker upsert; flushing here
    // runs them to completion AND lets engine.start() emit sessionStarted /
    // stepStarted(0) so the very first events are captured.
    async.flushMicrotasks();

    final engine = notifier.engine;
    if (engine == null) {
      throw StateError(
        'SessionDriver.start: engine is null after startSession — the '
        'session failed to start (check the container overrides).',
      );
    }
    driver._sub = engine.events.listen((ChainEventData e) {
      driver._events.add(e.event);
      if (e.event == ChainEvent.sessionEnded) {
        final reasonName = e.metadata['reason'] as String?;
        driver._endReason = reasonName == null
            ? null
            : EndReason.values.firstWhere(
                (r) => r.name == reasonName,
                orElse: () => EndReason.userQuit,
              );
      }
    });
    return driver;
  }

  final ProviderContainer _container;
  final SessionController _notifier;
  final List<ChainEvent> _events = [];
  StreamSubscription<ChainEventData>? _sub;
  EndReason? _endReason;

  /// The controller under test.
  SessionController get controller => _notifier;

  /// The live engine, or null once the session has been fully torn down.
  SessionEngine? get engine => _notifier.engine;

  /// The live engine state (`engine.snapshot`). Reconciles the spec's
  /// `engine.state` prose name to the real getter.
  EngineState get snapshot {
    final e = _notifier.engine;
    if (e == null) {
      throw StateError(
        'SessionDriver.snapshot read after the engine was torn '
        'down (call it before stop()).',
      );
    }
    return e.snapshot;
  }

  /// Every [ChainEvent] emitted since start, in emission order.
  List<ChainEvent> get events => List.unmodifiable(_events);

  /// Index of the currently executing step on the engine (-1 when none).
  int get currentStepIndex => _notifier.engine?.currentStepIndex ?? -1;

  /// Whether the engine is currently running the distress chain.
  bool get isDistressChain => _notifier.engine?.isDistressChain ?? false;

  /// Whether the engine has reached its terminal [EngineEnded] state.
  bool get isEnded => _notifier.engine?.isEnded ?? true;

  /// The reason carried by the terminal `sessionEnded` event, or null if the
  /// session has not ended yet.
  EndReason? get endReason => _endReason;

  /// The current [SessionState] view-model exposed to the UI.
  SessionState get state {
    final v = _container.read(sessionControllerProvider).value;
    if (v == null) {
      throw StateError(
        'SessionDriver.state: controller AsyncValue has no '
        'value yet.',
      );
    }
    return v;
  }

  /// Number of times [ChainEvent.event] appears in the collected log.
  int count(ChainEvent event) => _events.where((e) => e == event).length;

  /// Ends the session cleanly and flushes, leaving no live engine timer.
  ///
  /// Safe to call when the session already ended (the controller no-ops). Pass
  /// the same `async` from the enclosing `fakeAsync` body.
  void stop(dynamic async, {EndReason reason = EndReason.userQuit}) {
    unawaited(_notifier.endSession(reason: reason));
    async.flushMicrotasks();
    unawaited(_sub?.cancel());
    _sub = null;
  }
}
