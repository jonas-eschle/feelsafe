/// Supplemental tests for [FakeCallController.currentFakeCallConfig]
/// covering the resolution strategies (lines 61–93) that were missed
/// because the existing tests never start a session with a fakeCall
/// active step.
///
/// Strategy 1 — original mode contains a fakeCall step at currentStepIndex.
/// Strategy 2 — original mode is absent; scan all modes for a matching step.
/// Strategy 3 — no mode has a matching step; returns default FakeCallConfig.
/// Also covers `_fakeCallAt` null/out-of-range/wrong-type guards (lines 87–93).
library;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/fake_call/fake_call_controller.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/services/service_providers.dart';

import '../../helpers/test_helpers.dart';
import '../fake_repositories.dart';

// ---------------------------------------------------------------------------
// Minimal protocol stubs (identical to fake_call_controller_test.dart).
// ---------------------------------------------------------------------------

class _A implements AudioServiceProtocol {
  @override
  Future<void> playAlarm({
    bool maxVolume = true,
    bool isSimulation = false,
    Duration? gradualVolumeRamp,
  }) async {}
  @override
  Future<void> stopAlarm() async {}
  @override
  Future<void> playRingtone({
    String? assetPath,
    bool isSimulation = false,
  }) async {}
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
  Future<bool> canAutoSend(MessageChannel ch) async => true;
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
  Future<void> callEmergency(
    String number, {
    bool isSimulation = false,
  }) async {}
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

class _D implements DeviceStateServiceProtocol {
  @override
  Future<bool> isDndOn() async => false;
  @override
  Future<bool> isSilent() async => false;
}

class _L implements LocationServiceProtocol {
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> startTracking({
    Duration interval = const Duration(seconds: 60),
  }) async {}
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
// Session controller stubs.
// ---------------------------------------------------------------------------

class _StaticSessionController extends SessionController {
  _StaticSessionController(this._session);
  final WalkSession? _session;
  @override
  Future<WalkSession?> build() async => _session;
}

// ---------------------------------------------------------------------------
// Helpers.
// ---------------------------------------------------------------------------

List<Override> _overrides({
  required FakeModesRepository modesRepo,
  WalkSession? session,
}) => [
  modesRepositoryProvider.overrideWithValue(modesRepo),
  contactsRepositoryProvider.overrideWithValue(FakeContactsRepository()),
  templatesRepositoryProvider.overrideWithValue(FakeTemplatesRepository()),
  settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
  userProfileRepositoryProvider.overrideWithValue(FakeUserProfileRepository()),
  batteryAlertRepositoryProvider.overrideWithValue(
    FakeBatteryAlertRepository(),
  ),
  sessionLogsRepositoryProvider.overrideWithValue(FakeSessionLogsRepository()),
  sessionControllerProvider.overrideWith(
    () => _StaticSessionController(session),
  ),
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
  deviceStateServiceProvider.overrideWithValue(_D()),
  simulationDeviceStateProvider.overrideWithValue(_D()),
  locationServiceProvider.overrideWithValue(_L()),
  simulationLocationProvider.overrideWithValue(_L()),
  incomingCallServiceProvider.overrideWithValue(_IC()),
  simulationIncomingCallProvider.overrideWithValue(_IC()),
];

WalkSession _fakeCallSession({String modeId = 'm1', int stepIndex = 0}) =>
    WalkSession(
      id: 's1',
      modeId: modeId,
      isSimulation: false,
      startedAt: DateTime.utc(2025),
      phase: const SessionPhaseActive(),
      currentStepType: ChainStepType.fakeCall,
      currentStepIndex: stepIndex,
    );

void main() {
  group('FakeCallController.currentFakeCallConfig', () {
    test(
      'returns default FakeCallConfig when session is null (walk==null)',
      () async {
        final container = ProviderContainer(
          overrides: _overrides(
            modesRepo: FakeModesRepository(),
            session: null,
          ),
        );
        addTearDown(container.dispose);
        await container.read(fakeCallControllerProvider.future);

        final cfg = await container
            .read(fakeCallControllerProvider.notifier)
            .currentFakeCallConfig();
        check(cfg).equals(const FakeCallConfig());
      },
    );

    test(
      'returns default FakeCallConfig when active step is not fakeCall (line 62)',
      () async {
        final session = WalkSession(
          id: 's1',
          modeId: 'm1',
          isSimulation: false,
          startedAt: DateTime.utc(2025),
          phase: const SessionPhaseActive(),
          currentStepType: ChainStepType.holdButton,
        );
        final container = ProviderContainer(
          overrides: _overrides(
            modesRepo: FakeModesRepository(),
            session: session,
          ),
        );
        addTearDown(container.dispose);
        await container.read(fakeCallControllerProvider.future);

        final cfg = await container
            .read(fakeCallControllerProvider.notifier)
            .currentFakeCallConfig();
        check(cfg).equals(const FakeCallConfig());
      },
    );

    test(
      'strategy 1: resolves config from original mode (lines 64–70)',
      () async {
        const customCfg = FakeCallConfig(declineIsSafe: true);
        final fcStep = fakeCallStep(order: 0, declineIsSafe: true);
        final mode = makeMode(id: 'm1', steps: [fcStep]);
        final repo = FakeModesRepository([mode]);
        final session = _fakeCallSession(modeId: 'm1', stepIndex: 0);

        final container = ProviderContainer(
          overrides: _overrides(modesRepo: repo, session: session),
        );
        addTearDown(container.dispose);
        await container.read(fakeCallControllerProvider.future);

        final cfg = await container
            .read(fakeCallControllerProvider.notifier)
            .currentFakeCallConfig();
        check(cfg).equals(customCfg);
      },
    );

    test(
      'strategy 2: scans all modes when original mode id is absent (lines 75–78)',
      () async {
        const customCfg = FakeCallConfig(declineIsSafe: true);
        final fcStep = fakeCallStep(order: 0, declineIsSafe: true);
        // mode id 'other' does not match session's modeId 'm1'.
        final otherMode = makeMode(id: 'other', steps: [fcStep]);
        final repo = FakeModesRepository([otherMode]);
        // Session references modeId 'm1' which has no entry in the repo.
        final session = _fakeCallSession(modeId: 'm1', stepIndex: 0);

        final container = ProviderContainer(
          overrides: _overrides(modesRepo: repo, session: session),
        );
        addTearDown(container.dispose);
        await container.read(fakeCallControllerProvider.future);

        final cfg = await container
            .read(fakeCallControllerProvider.notifier)
            .currentFakeCallConfig();
        check(cfg).equals(customCfg);
      },
    );

    test(
      'strategy 3: returns default when no mode has matching fakeCall step',
      () async {
        // Mode has a holdButton step at index 0, not a fakeCall.
        final mode = makeMode(id: 'm1', steps: [holdStep(order: 0)]);
        final repo = FakeModesRepository([mode]);
        final session = _fakeCallSession(modeId: 'm1', stepIndex: 0);

        final container = ProviderContainer(
          overrides: _overrides(modesRepo: repo, session: session),
        );
        addTearDown(container.dispose);
        await container.read(fakeCallControllerProvider.future);

        final cfg = await container
            .read(fakeCallControllerProvider.notifier)
            .currentFakeCallConfig();
        check(cfg).equals(const FakeCallConfig());
      },
    );

    test(
      '_fakeCallAt returns null when stepIndex is out of range (line 89)',
      () async {
        final fcStep = fakeCallStep(order: 0);
        final mode = makeMode(id: 'm1', steps: [fcStep]);
        final repo = FakeModesRepository([mode]);
        // stepIndex=5 is beyond mode.chainSteps.length.
        final session = _fakeCallSession(modeId: 'm1', stepIndex: 5);

        final container = ProviderContainer(
          overrides: _overrides(modesRepo: repo, session: session),
        );
        addTearDown(container.dispose);
        await container.read(fakeCallControllerProvider.future);

        final cfg = await container
            .read(fakeCallControllerProvider.notifier)
            .currentFakeCallConfig();
        // Out of range → strategy 3 → default.
        check(cfg).equals(const FakeCallConfig());
      },
    );

    test(
      '_fakeCallAt returns null when step type is not fakeCall (line 91)',
      () async {
        // Mode has smsContact at index 0, not fakeCall.
        final mode = makeMode(id: 'm1', steps: [smsStep(order: 0)]);
        final repo = FakeModesRepository([mode]);
        final session = _fakeCallSession(modeId: 'm1', stepIndex: 0);

        final container = ProviderContainer(
          overrides: _overrides(modesRepo: repo, session: session),
        );
        addTearDown(container.dispose);
        await container.read(fakeCallControllerProvider.future);

        final cfg = await container
            .read(fakeCallControllerProvider.notifier)
            .currentFakeCallConfig();
        check(cfg).equals(const FakeCallConfig());
      },
    );

    test(
      'declineWithDistress delegates to sessionController (no exception)',
      () async {
        final container = ProviderContainer(
          overrides: _overrides(
            modesRepo: FakeModesRepository(),
            session: null,
          ),
        );
        addTearDown(container.dispose);
        await container.read(fakeCallControllerProvider.future);
        await container
            .read(fakeCallControllerProvider.notifier)
            .declineWithDistress();
      },
    );
  });
}
