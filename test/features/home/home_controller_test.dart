/// Tests for [HomeController] — aggregates read-only view-state from
/// Settings / Modes / Contacts / Session.
library;

import 'dart:async';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/home/home_controller.dart';
import 'package:guardianangela/services/service_providers.dart';

import '../../helpers/test_helpers.dart';
import '../fake_repositories.dart';

// ---- minimal stub services (HomeController only reads Session state) ----

class _NoopAudio implements AudioServiceProtocol {
  @override
  Future<void> playAlarm({bool maxVolume = true, bool isSimulation = false}) async {}
  @override
  Future<void> stopAlarm() async {}
  @override
  Future<void> playRingtone({String? assetPath, bool isSimulation = false}) async {}
  @override
  Future<void> stopRingtone() async {}
  @override
  Future<void> playVoiceRecording({required String assetPath, bool isSimulation = false}) async {}
  @override
  Future<void> stopVoiceRecording() async {}
}

class _NoopMessaging implements MessagingServiceProtocol {
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

class _NoopPhone implements PhoneServiceProtocol {
  @override
  Future<void> call(String number, {bool isSimulation = false}) async {}
  @override
  Future<void> callEmergency(String number, {bool isSimulation = false}) async {}
}

class _NoopNotification implements NotificationServiceProtocol {
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
  Future<void> showDisarmTriggerNotification({
    required String title,
    required String body,
    required String endSessionLabel,
    required String continueLabel,
  }) async {}
}

class _NoopVibration implements VibrationServiceProtocol {
  @override
  Future<void> alarmPattern({bool isSimulation = false}) async {}
  @override
  Future<void> warningPattern({bool isSimulation = false}) async {}
  @override
  Future<void> fakeCallPattern({bool isSimulation = false}) async {}
  @override
  Future<void> stop() async {}
}

class _NoopHardwareButton implements HardwareButtonServiceProtocol {
  @override
  Stream<HardwarePanicEvent> get panicEvents => const Stream.empty();
  @override
  bool get isListening => false;
  @override
  Future<void> start({required String buttonType, required String pattern, int pressCount = 5, int pressWindowMs = 500, double longPressDurationSeconds = 2.0}) async {}
  @override
  Future<void> stop() async {}
}

class _NoopGeofence implements GeofenceServiceProtocol {
  @override
  Stream<LocationPoint> get arrivals => const Stream.empty();
  @override
  Future<void> registerGeofence({required double latitude, required double longitude, required double radiusMeters}) async {}
  @override
  Future<void> removeGeofence() async {}
}

class _NoopBattery implements BatteryMonitorServiceProtocol {
  @override
  Stream<int> get onLowBattery => const Stream.empty();
  @override
  bool get isActive => false;
  @override
  Future<void> startMonitoring({required int thresholdPercent}) async {}
  @override
  Future<void> stopMonitoring() async {}
}

class _NoopDeviceState implements DeviceStateServiceProtocol {
  @override
  Future<bool> isDndOn() async => false;
  @override
  Future<bool> isSilent() async => false;
}

class _NoopLocation implements LocationServiceProtocol {
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

class _NoopIncomingCall implements IncomingCallServiceProtocol {
  @override
  Stream<CallState> get callState => const Stream.empty();
  @override
  Future<void> startListening() async {}
  @override
  Future<void> stopListening() async {}
}

List<Override> _serviceOverrides() => [
  audioServiceProvider.overrideWithValue(_NoopAudio()),
  simulationAudioProvider.overrideWithValue(_NoopAudio()),
  messagingServiceProvider.overrideWithValue(_NoopMessaging()),
  simulationMessagingProvider.overrideWithValue(_NoopMessaging()),
  phoneServiceProvider.overrideWithValue(_NoopPhone()),
  simulationPhoneProvider.overrideWithValue(_NoopPhone()),
  notificationServiceProvider.overrideWithValue(_NoopNotification()),
  simulationNotificationProvider.overrideWithValue(_NoopNotification()),
  vibrationServiceProvider.overrideWithValue(_NoopVibration()),
  simulationVibrationProvider.overrideWithValue(_NoopVibration()),
  hardwareButtonServiceProvider.overrideWithValue(_NoopHardwareButton()),
  simulationHardwareButtonProvider.overrideWithValue(_NoopHardwareButton()),
  geofenceServiceProvider.overrideWithValue(_NoopGeofence()),
  simulationGeofenceProvider.overrideWithValue(_NoopGeofence()),
  batteryMonitorServiceProvider.overrideWithValue(_NoopBattery()),
  simulationBatteryMonitorProvider.overrideWithValue(_NoopBattery()),
  deviceStateServiceProvider.overrideWithValue(_NoopDeviceState()),
  simulationDeviceStateProvider.overrideWithValue(_NoopDeviceState()),
  locationServiceProvider.overrideWithValue(_NoopLocation()),
  simulationLocationProvider.overrideWithValue(_NoopLocation()),
  incomingCallServiceProvider.overrideWithValue(_NoopIncomingCall()),
  simulationIncomingCallProvider.overrideWithValue(_NoopIncomingCall()),
];

ProviderContainer _makeContainer({
  List<SessionMode> modes = const [],
  List<EmergencyContact> contacts = const [],
  AppSettings? settings,
}) => ProviderContainer(
  overrides: [
    modesRepositoryProvider
        .overrideWithValue(FakeModesRepository(modes)),
    contactsRepositoryProvider
        .overrideWithValue(FakeContactsRepository(contacts)),
    templatesRepositoryProvider
        .overrideWithValue(FakeTemplatesRepository()),
    settingsRepositoryProvider
        .overrideWithValue(FakeSettingsRepository(settings)),
    userProfileRepositoryProvider
        .overrideWithValue(FakeUserProfileRepository()),
    batteryAlertRepositoryProvider
        .overrideWithValue(FakeBatteryAlertRepository()),
    sessionLogsRepositoryProvider
        .overrideWithValue(FakeSessionLogsRepository()),
    ..._serviceOverrides(),
  ],
);

void main() {
  group('HomeController.build', () {
    test('propagates empty state', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final s = await container.read(homeControllerProvider.future);
      check(s.modes).isEmpty();
      check(s.contacts).isEmpty();
      check(s.selectedModeId).isNull();
      check(s.activeSession).isNull();
      check(s.isFirstLaunch).isTrue();
    });

    test('aggregates modes, contacts, settings', () async {
      final container = _makeContainer(
        modes: [makeMode(id: 'm-1', name: 'Walk')],
        contacts: [makeContact(id: 'c-1')],
        settings: const AppSettings(
          defaults: AppDefaults(),
          selectedModeId: 'm-1',
          isFirstLaunch: false,
        ),
      );
      addTearDown(container.dispose);
      final s = await container.read(homeControllerProvider.future);
      check(s.modes.length).equals(1);
      check(s.contacts.length).equals(1);
      check(s.selectedModeId).equals('m-1');
      check(s.isFirstLaunch).isFalse();
    });
  });

  group('HomeState.selectedMode', () {
    test('returns null when no modes exist', () {
      const s = HomeState();
      check(s.selectedMode).isNull();
    });

    test('returns first mode when selectedModeId is null', () {
      final s = HomeState(
        modes: [makeMode(id: 'a'), makeMode(id: 'b')],
      );
      check(s.selectedMode!.id).equals('a');
    });

    test('returns matching mode by id', () {
      final s = HomeState(
        modes: [makeMode(id: 'a'), makeMode(id: 'b')],
        selectedModeId: 'b',
      );
      check(s.selectedMode!.id).equals('b');
    });

    test('falls back to first mode when id is not found', () {
      final s = HomeState(
        modes: [makeMode(id: 'a'), makeMode(id: 'b')],
        selectedModeId: 'nonexistent',
      );
      check(s.selectedMode!.id).equals('a');
    });
  });
}
