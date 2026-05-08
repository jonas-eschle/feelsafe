/// Supplemental tests for [FakeCallController.currentFakeCallConfig] covering
/// uncovered code paths:
///
///   - line 61: early return when active step is not fakeCall.
///   - lines 64–70: strategy 1 — resolve config from original mode by id.
///   - lines 75–77: strategy 2 — scan all modes when original is missing.
///   - line 81: strategy 3 — fall back to default [FakeCallConfig()].
///   - lines 87–93: [_fakeCallAt] helper branch coverage.
///
/// All paths are exercised by overriding [sessionControllerProvider] with a
/// custom [SessionController] that immediately returns a pre-built
/// [WalkSession], eliminating the need for a live engine or platform services.
library;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/fake_call/fake_call_controller.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/services/service_providers.dart';

import '../fake_repositories.dart';

// ---------------------------------------------------------------------------
// Stub session controller — returns a fixed WalkSession.
// ---------------------------------------------------------------------------

class _StubSessionController extends SessionController {
  _StubSessionController(this._session);
  final WalkSession? _session;

  @override
  Future<WalkSession?> build() async => _session;
}

// ---------------------------------------------------------------------------
// Stub services — bare no-ops so the provider graph resolves.
// ---------------------------------------------------------------------------

class _A implements AudioServiceProtocol {
  @override
  Future<void> playAlarm({bool maxVolume = true, bool isSimulation = false, Duration? gradualVolumeRamp})
      async {}
  @override
  Future<void> stopAlarm() async {}
  @override
  Future<void> playRingtone({String? assetPath, bool isSimulation = false})
      async {}
  @override
  Future<void> stopRingtone() async {}
  @override
  Future<void> playVoiceRecording({
    required String assetPath,
    bool isSimulation = false,
    String? ttsFallbackPhrase,
  }) async {}
  @override
  Future<void> stopVoiceRecording() async {}
}

class _M implements MessagingServiceProtocol {
  @override
  Stream<MessageDeliveryUpdate> get deliveryUpdates => const Stream.empty();
  @override
  Stream<SmsRetryExhaustedEvent> get smsRetryExhausted => const Stream.empty();
  @override
  Future<bool> canAutoSend(MessageChannel channel) async => true;
  @override
  Future<MessageWorkId> sendMessage({
    required EmergencyContact contact,
    required String message,
    required MessageChannel channel,
    bool isSimulation = false,
  }) async => const MessageWorkId('w');
  @override
  Future<List<MessageWorkId>> sendToAll({
    required List<EmergencyContact> contacts,
    required String message,
    bool isSimulation = false,
  }) async => const [];
  @override
  Future<void> cancelPending(List<MessageWorkId> workIds) async {}
  @override
  Future<void> retryExhaustedSms(String workId) async {}
}

class _P implements PhoneServiceProtocol {
  @override
  Future<void> call(String number, {bool isSimulation = false}) async {}
  @override
  Future<void> callEmergency(String number, {bool isSimulation = false})
      async {}
}

class _N implements NotificationServiceProtocol {
  @override
  Future<void> init() async {}
  @override
  Future<void> showSessionNotification({
    required String title,
    required String body,
    bool isSimulation = false,
  }) async {}
  @override
  Future<void> showDisguisedReminder({
    required ReminderTemplate template,
    bool isSimulation = false,
  }) async {}
  @override
  Future<int> scheduleNotification({
    required String title,
    required String body,
    required Duration delay,
    bool isSimulation = false,
  }) async => 0;
  @override
  Future<void> cancelNotification(int id) async {}
  @override
  Future<void> cancelAll() async {}
  @override
  Stream<String> get actionTaps => const Stream.empty();
  @override
  Future<void> showToast(String message) async {}
  @override
  Future<void> showDisarmTriggerNotification({
    required String title,
    required String body,
    required String endSessionLabel,
    required String continueLabel,
  }) async {}
}

class _V implements VibrationServiceProtocol {
  @override
  Future<void> alarmPattern({bool isSimulation = false}) async {}
  @override
  Future<void> warningPattern({bool isSimulation = false}) async {}
  @override
  Future<void> fakeCallPattern({bool isSimulation = false}) async {}
  @override
  Future<void> stop() async {}
}

class _H implements HardwareButtonServiceProtocol {
  @override
  Stream<HardwarePanicEvent> get panicEvents => const Stream.empty();
  @override
  bool get isListening => false;
  @override
  Future<void> start({
    required String buttonType,
    required String pattern,
    int pressCount = 5,
    int pressWindowMs = 500,
    double longPressDurationSeconds = 2.0,
  }) async {}
  @override
  Future<void> stop() async {}
}

class _G implements GeofenceServiceProtocol {
  @override
  Stream<LocationPoint> get arrivals => const Stream.empty();
  @override
  Future<void> registerGeofence({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) async {}
  @override
  Future<void> removeGeofence() async {}
}

class _B implements BatteryMonitorServiceProtocol {
  @override
  Stream<int> get onLowBattery => const Stream.empty();
  @override
  bool get isActive => false;
  @override
  Future<void> startMonitoring({required int thresholdPercent}) async {}
  @override
  Future<void> stopMonitoring() async {}
}

class _DS implements DeviceStateServiceProtocol {
  @override
  Future<bool> isDndOn() async => false;
  @override
  Future<bool> isSilent() async => false;
}

class _L implements LocationServiceProtocol {
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> startTracking({Duration interval = const Duration(seconds: 60)})
      async {}
  @override
  Future<void> stopTracking() async {}
  @override
  String? getLastLocationUrl() => null;
  @override
  LocationPoint? getLastLocationPoint() => null;
  @override
  List<LocationPoint> get history => const [];
  @override
  void clearHistory() {}
  @override
  Future<LocationPoint?> getCurrentPosition() async => null;
}

class _IC implements IncomingCallServiceProtocol {
  @override
  Stream<CallState> get callState => const Stream.empty();
  @override
  Future<void> startListening() async {}
  @override
  Future<void> stopListening() async {}
}

// ---------------------------------------------------------------------------
// Fixture helpers
// ---------------------------------------------------------------------------

/// Creates a [WalkSession] representing an active fakeCall step at [stepIndex]
/// in mode [modeId].
WalkSession _fakeCallSession({
  String modeId = 'mode-1',
  int stepIndex = 0,
  ChainStepType stepType = ChainStepType.fakeCall,
}) => WalkSession(
  id: 'sess',
  modeId: modeId,
  isSimulation: false,
  startedAt: DateTime(2024),
  phase: const SessionPhaseActive(),
  currentStepIndex: stepIndex,
  currentStepType: stepType,
);

/// Minimal mode with a fakeCall step at [stepIndex] carrying [config].
SessionMode _modeWithFakeCall({
  required String id,
  required int stepIndex,
  FakeCallConfig config = const FakeCallConfig(callerName: 'Angela'),
}) {
  final steps = <ChainStep>[];
  for (var i = 0; i < stepIndex; i++) {
    steps.add(
      ChainStep(
        id: 'pad-$i',
        type: ChainStepType.smsContact,
        order: i,
        durationSeconds: 5,
        gracePeriodSeconds: 0,
        waitSeconds: 0,
        retryCount: 0,
        randomize: 0,
      ),
    );
  }
  steps.add(
    ChainStep(
      id: 'fc-$stepIndex',
      type: ChainStepType.fakeCall,
      order: stepIndex,
      durationSeconds: 30,
      gracePeriodSeconds: 5,
      waitSeconds: 0,
      retryCount: 0,
      randomize: 0,
      config: config,
    ),
  );
  return SessionMode(
    id: id,
    name: 'Mode $id',
    checkInType: ChainStepType.holdButton,
    chainSteps: steps,
  );
}

/// Builds a [ProviderContainer] with the given [session] and [modes].
///
/// [session] is returned by a stub [SessionController].
/// [modes] are returned by [FakeModesRepository].
ProviderContainer _container(
  WalkSession? session,
  List<SessionMode> modes,
) {
  final modesRepo = FakeModesRepository(modes);
  return ProviderContainer(
    overrides: [
      sessionControllerProvider
          .overrideWith(() => _StubSessionController(session)),
      modesRepositoryProvider.overrideWithValue(modesRepo),
      contactsRepositoryProvider.overrideWithValue(FakeContactsRepository()),
      templatesRepositoryProvider.overrideWithValue(FakeTemplatesRepository()),
      settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
      userProfileRepositoryProvider
          .overrideWithValue(FakeUserProfileRepository()),
      batteryAlertRepositoryProvider
          .overrideWithValue(FakeBatteryAlertRepository()),
      sessionLogsRepositoryProvider
          .overrideWithValue(FakeSessionLogsRepository()),
      audioServiceProvider.overrideWithValue(_A()),
      simulationAudioProvider.overrideWithValue(_A()),
      messagingServiceProvider.overrideWithValue(_M()),
      simulationMessagingProvider.overrideWithValue(_M()),
      phoneServiceProvider.overrideWithValue(_P()),
      simulationPhoneProvider.overrideWithValue(_P()),
      notificationServiceProvider.overrideWithValue(_N()),
      simulationNotificationProvider.overrideWithValue(_N()),
      vibrationServiceProvider.overrideWithValue(_V()),
      simulationVibrationProvider.overrideWithValue(_V()),
      hardwareButtonServiceProvider.overrideWithValue(_H()),
      simulationHardwareButtonProvider.overrideWithValue(_H()),
      geofenceServiceProvider.overrideWithValue(_G()),
      simulationGeofenceProvider.overrideWithValue(_G()),
      batteryMonitorServiceProvider.overrideWithValue(_B()),
      simulationBatteryMonitorProvider.overrideWithValue(_B()),
      deviceStateServiceProvider.overrideWithValue(_DS()),
      simulationDeviceStateProvider.overrideWithValue(_DS()),
      locationServiceProvider.overrideWithValue(_L()),
      simulationLocationProvider.overrideWithValue(_L()),
      incomingCallServiceProvider.overrideWithValue(_IC()),
      simulationIncomingCallProvider.overrideWithValue(_IC()),
    ],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('FakeCallController.currentFakeCallConfig', () {
    // Ensure both provider states are initialized before calling the method.
    Future<FakeCallConfig> resolve(ProviderContainer c) async {
      await c.read(sessionControllerProvider.future);
      await c.read(fakeCallControllerProvider.future);
      return c
          .read(fakeCallControllerProvider.notifier)
          .currentFakeCallConfig();
    }

    test(
      'returns default config when walk is null (no active session)',
      () async {
        final c = _container(null, const []);
        addTearDown(c.dispose);
        check(await resolve(c)).equals(const FakeCallConfig());
      },
    );

    test(
      'returns default when current step is not fakeCall (line 61)',
      () async {
        // Active session whose current step type is smsContact — not fakeCall.
        final session = _fakeCallSession(
          stepType: ChainStepType.smsContact,
        );
        final c = _container(session, const []);
        addTearDown(c.dispose);
        // Line 61-62: early return with default.
        check(await resolve(c)).equals(const FakeCallConfig());
      },
    );

    test(
      'strategy 1: resolves config from original mode by id (lines 64–70)',
      () async {
        const expected = FakeCallConfig(callerName: 'Dr. Stratton');
        final mode = _modeWithFakeCall(
          id: 'mode-1',
          stepIndex: 0,
          config: expected,
        );
        final session = _fakeCallSession(modeId: 'mode-1', stepIndex: 0);
        final c = _container(session, [mode]);
        addTearDown(c.dispose);
        // Lines 68-70: fromOriginal is non-null → returned directly.
        check(await resolve(c)).equals(expected);
      },
    );

    test(
      'strategy 2: scans all modes when original mode is missing (lines 75–77)',
      () async {
        // The session references modeId='other' which does not exist in repo.
        // But mode-1 has a fakeCall at index 0 — strategy 2 picks it up.
        const expected = FakeCallConfig(callerName: 'Scan Angela');
        final mode = _modeWithFakeCall(
          id: 'mode-1',
          stepIndex: 0,
          config: expected,
        );
        // Session has modeId 'other' which is absent from the repo.
        final session = _fakeCallSession(modeId: 'other', stepIndex: 0);
        final c = _container(session, [mode]);
        addTearDown(c.dispose);
        // Strategy 1 returns null (mode 'other' not found).
        // Strategy 2 scans and finds mode-1 at stepIndex 0.
        check(await resolve(c)).equals(expected);
      },
    );

    test(
      'strategy 3: falls back to default when no mode has fakeCall at index '
      '(line 81)',
      () async {
        // Mode has an smsContact at step 0, not a fakeCall.
        const mode = SessionMode(
          id: 'mode-x',
          name: 'Mode X',
          checkInType: ChainStepType.holdButton,
          chainSteps: [
            ChainStep(
              id: 'sms-0',
              type: ChainStepType.smsContact,
              order: 0,
              durationSeconds: 5,
              gracePeriodSeconds: 0,
              waitSeconds: 0,
              retryCount: 0,
              randomize: 0,
            ),
          ],
        );
        // stepIndex=5 — way out of range for every mode.
        final session = _fakeCallSession(modeId: 'mode-x', stepIndex: 5);
        final c = _container(session, const [mode]);
        addTearDown(c.dispose);
        // Strategies 1 & 2 both return null → strategy 3 default.
        check(await resolve(c)).equals(const FakeCallConfig());
      },
    );

    test(
      '_fakeCallAt returns null when mode is null (line 88)',
      () async {
        // Strategy 1: getById('missing') returns null → _fakeCallAt(null, 0)
        // must return null and fall through to strategy 2.
        final session = _fakeCallSession(modeId: 'missing', stepIndex: 0);
        final c = _container(session, const []);
        addTearDown(c.dispose);
        // No modes → strategy 2 loop is empty → strategy 3 default.
        check(await resolve(c)).equals(const FakeCallConfig());
      },
    );

    test(
      '_fakeCallAt returns null when stepIndex out of range (line 89)',
      () async {
        // mode-1 has 1 step at index 0. Session has stepIndex=3 → OOB.
        final mode = _modeWithFakeCall(id: 'mode-1', stepIndex: 0);
        final session = _fakeCallSession(modeId: 'mode-1', stepIndex: 3);
        final c = _container(session, [mode]);
        addTearDown(c.dispose);
        // _fakeCallAt returns null (3 >= mode.chainSteps.length 1).
        check(await resolve(c)).equals(const FakeCallConfig());
      },
    );

    test(
      '_fakeCallAt returns null when step at index is not fakeCall (line 91)',
      () async {
        // mode-1 has an smsContact at stepIndex 0.
        const mode = SessionMode(
          id: 'mode-1',
          name: 'Mode 1',
          checkInType: ChainStepType.holdButton,
          chainSteps: [
            ChainStep(
              id: 'sms-0',
              type: ChainStepType.smsContact,
              order: 0,
              durationSeconds: 5,
              gracePeriodSeconds: 0,
              waitSeconds: 0,
              retryCount: 0,
              randomize: 0,
            ),
          ],
        );
        final session = _fakeCallSession(modeId: 'mode-1', stepIndex: 0);
        final c = _container(session, const [mode]);
        addTearDown(c.dispose);
        // _fakeCallAt: step type is smsContact, not fakeCall → returns null.
        check(await resolve(c)).equals(const FakeCallConfig());
      },
    );

    test(
      '_fakeCallAt returns null when fakeCall step has no FakeCallConfig '
      '(line 92–93)',
      () async {
        // A fakeCall step with config == null (should use defaults).
        const mode = SessionMode(
          id: 'mode-1',
          name: 'Mode 1',
          checkInType: ChainStepType.holdButton,
          chainSteps: [
            ChainStep(
              id: 'fc-0',
              type: ChainStepType.fakeCall,
              order: 0,
              durationSeconds: 30,
              gracePeriodSeconds: 5,
              waitSeconds: 0,
              retryCount: 0,
              randomize: 0,
              // config is null → _fakeCallAt returns null.
            ),
          ],
        );
        final session = _fakeCallSession(modeId: 'mode-1', stepIndex: 0);
        final c = _container(session, const [mode]);
        addTearDown(c.dispose);
        // cfg is null → falls through all strategies → default.
        check(await resolve(c)).equals(const FakeCallConfig());
      },
    );
  });
}
