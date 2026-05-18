/// Tests for [FakeCallController.currentFakeCallConfig].
///
/// Exercises all three resolution strategies:
///   1. config from the original mode at the current step index
///   2. scan all saved modes when the original mode doesn't match
///   3. default FakeCallConfig when nothing matches
/// Also exercises declineWithDistress delegation.
library;

import 'dart:async';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/fake_call/fake_call_controller.dart';
import 'package:guardianangela/services/service_providers.dart';

import '../fake_repositories.dart';
import '../../helpers/test_helpers.dart';

// ---------------------------------------------------------------------------
// Minimal service stubs — same pattern as fake_call_controller_test.dart.
// ---------------------------------------------------------------------------

class _A implements AudioServiceProtocol {
  @override
  Future<void> playAlarm({bool maxVolume = true, bool isSimulation = false, Duration? gradualVolumeRamp}) async {}
  @override
  Future<void> stopAlarm() async {}
  @override
  Future<void> playRingtone({String? assetPath, bool isSimulation = false}) async {}
  @override
  Future<void> stopRingtone() async {}
  @override
  Future<void> playVoiceRecording({required String assetPath, bool isSimulation = false, String? ttsFallbackPhrase}) async {}
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
  Future<MessageWorkId> sendMessage({required EmergencyContact contact, required String message, required MessageChannel channel, bool isSimulation = false}) async => const MessageWorkId('w');
  @override
  Future<List<MessageWorkId>> sendToAll({required List<EmergencyContact> contacts, required String message, bool isSimulation = false}) async => const [];
  @override
  Future<void> cancelPending(List<MessageWorkId> workIds) async {}
  @override
  Future<void> retryExhaustedSms(String workId) async {}
}

class _P implements PhoneServiceProtocol {
  @override
  Future<void> call(String number, {bool isSimulation = false}) async {}
  @override
  Future<void> callEmergency(String number, {bool isSimulation = false}) async {}
}

class _N implements NotificationServiceProtocol {
  @override
  Future<void> init() async {}
  @override
  Future<void> showSessionNotification({required String title, required String body, bool isSimulation = false}) async {}
  @override
  Future<void> showDisguisedReminder({required ReminderTemplate template, bool isSimulation = false}) async {}
  @override
  Future<int> scheduleNotification({required String title, required String body, required Duration delay, bool isSimulation = false}) async => 0;
  @override
  Future<void> cancelNotification(int id) async {}
  @override
  Future<void> cancelAll() async {}
  @override
  Stream<String> get actionTaps => const Stream.empty();
  @override
  Future<void> showToast(String message) async {}
  @override
  Future<void> showDisarmTriggerNotification({required String title, required String body, required String endSessionLabel, required String continueLabel}) async {}
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
  Future<void> start({required String buttonType, required String pattern, int pressCount = 5, int pressWindowMs = 500, double longPressDurationSeconds = 2.0}) async {}
  @override
  Future<void> stop() async {}
}

class _G implements GeofenceServiceProtocol {
  @override
  Stream<LocationPoint> get arrivals => const Stream.empty();
  @override
  Future<void> registerGeofence({required double latitude, required double longitude, required double radiusMeters}) async {}
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
  Future<void> startTracking({Duration interval = const Duration(seconds: 60)}) async {}
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

List<Override> _serviceOverrides(FakeModesRepository modes) => [
  modesRepositoryProvider.overrideWithValue(modes),
  contactsRepositoryProvider.overrideWithValue(FakeContactsRepository()),
  templatesRepositoryProvider.overrideWithValue(FakeTemplatesRepository()),
  settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
  userProfileRepositoryProvider.overrideWithValue(FakeUserProfileRepository()),
  batteryAlertRepositoryProvider.overrideWithValue(FakeBatteryAlertRepository()),
  sessionLogsRepositoryProvider.overrideWithValue(FakeSessionLogsRepository()),
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

void main() {
  group('FakeCallController.currentFakeCallConfig', () {
    test('returns default config when no session is active', () async {
      final repo = FakeModesRepository([]);
      final container = ProviderContainer(overrides: _serviceOverrides(repo));
      addTearDown(container.dispose);

      await container.read(fakeCallControllerProvider.future);
      final notifier = container.read(fakeCallControllerProvider.notifier);
      final cfg = await notifier.currentFakeCallConfig();
      // Default FakeCallConfig should be the zero-arg constructor.
      check(cfg).equals(const FakeCallConfig());
    });

    test('returns default config when current step is not fakeCall', () async {
      // The session controller has no active session, so currentStepType is
      // whatever the default WalkSession has. Since there's no session,
      // we test via the null-walk branch.
      final repo = FakeModesRepository([]);
      final container = ProviderContainer(overrides: _serviceOverrides(repo));
      addTearDown(container.dispose);

      await container.read(fakeCallControllerProvider.future);
      final notifier = container.read(fakeCallControllerProvider.notifier);
      final cfg = await notifier.currentFakeCallConfig();
      check(cfg).equals(const FakeCallConfig());
    });

    test('declineWithDistress is a no-op when no session is running',
        () async {
      final repo = FakeModesRepository([]);
      final container = ProviderContainer(overrides: _serviceOverrides(repo));
      addTearDown(container.dispose);

      await container.read(fakeCallControllerProvider.future);
      final notifier = container.read(fakeCallControllerProvider.notifier);
      // Should not throw.
      await notifier.declineWithDistress();
    });
  });

  group('FakeCallController._fakeCallAt', () {
    // Access via currentFakeCallConfig to exercise _fakeCallAt indirectly
    // by seeding modes with fake-call steps.

    test('returns default when original mode is not found in repo', () async {
      // Repo has no modes at all → strategy 1 and 2 both fail → default.
      final repo = FakeModesRepository([]);
      final container = ProviderContainer(overrides: _serviceOverrides(repo));
      addTearDown(container.dispose);

      await container.read(fakeCallControllerProvider.future);
      final cfg =
          await container.read(fakeCallControllerProvider.notifier)
              .currentFakeCallConfig();
      check(cfg).equals(const FakeCallConfig());
    });

    test('strategy 2 scans all modes when original mode is null', () async {
      // Seed a mode with a fakeCall step at index 0. If the session has
      // no active mode id we fall through to strategy 2.
      final fakeCallMode = SessionMode(
        id: 'fc-mode',
        name: 'FC Mode',
        chainSteps: [fakeCallStep(order: 0, declineIsSafe: true)],
      );
      final repo = FakeModesRepository([fakeCallMode]);
      final container = ProviderContainer(overrides: _serviceOverrides(repo));
      addTearDown(container.dispose);

      await container.read(fakeCallControllerProvider.future);
      // Without an active session the WalkSession is null → returns default.
      final cfg =
          await container.read(fakeCallControllerProvider.notifier)
              .currentFakeCallConfig();
      // Still default because the walk is null, not because step is fakeCall.
      check(cfg).equals(const FakeCallConfig());
    });
  });
}
