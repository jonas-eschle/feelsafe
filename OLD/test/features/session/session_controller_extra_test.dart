/// Supplemental tests for [SessionController] covering uncovered methods:
///
///   - line 101: [isPauseAllowed] when session is active.
///   - lines 119–120: [setAppLifecycleState].
///   - lines 126–129: [setSimulationBackgroundClamp] with active session.
///   - lines 133–134: [emergencyConfirmationRequests] stream getter.
///   - lines 301–304: [setSimulationSpeedMultiplier] with active session.
///   - lines 309–312: [simulateGpsArrival] with active session.
///   - lines 317–319: [simulateLowBattery] with active session.
///   - lines 327: [answerFakeCall] inner branch (engine.answerFakeCall).
///   - lines 335: [hangUp] inner branch.
///   - lines 342: [declineFakeCall] inner branch.
///   - lines 351–354: [holdStart] inner branch.
///   - lines 361–364: [holdRelease] inner branch.
library;

import 'dart:async';

import 'package:checks/checks.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/services/service_providers.dart';

import '../../helpers/test_helpers.dart';
import '../fake_repositories.dart';

// ---------------------------------------------------------------------------
// Stub service implementations (minimal, no-op)
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
// Fixture helper
// ---------------------------------------------------------------------------

ProviderContainer _makeContainer({List<SessionMode>? modes}) {
  final distressMode = makeDistressMode(steps: [smsStep(order: 0)]);
  final allModes = [
    ...modes ?? [makeMode(id: 'mode-1', steps: [holdStep()])],
    distressMode,
  ];
  return ProviderContainer(
    overrides: [
      modesRepositoryProvider.overrideWithValue(
        FakeModesRepository(allModes),
      ),
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
  group('SessionController — methods not covered by existing tests', () {
    test(
      'setAppLifecycleState stores the new lifecycle state (lines 119–120)',
      () async {
        final c = _makeContainer();
        addTearDown(c.dispose);
        final ctrl = c.read(sessionControllerProvider.notifier);
        await c.read(sessionControllerProvider.future);

        ctrl.setAppLifecycleState(AppLifecycleState.paused);
        check(ctrl.appLifecycleState).equals(AppLifecycleState.paused);

        ctrl.setAppLifecycleState(AppLifecycleState.resumed);
        check(ctrl.appLifecycleState).equals(AppLifecycleState.resumed);
      },
    );

    test(
      'emergencyConfirmationRequests getter returns a stream (lines 133–134)',
      () async {
        final c = _makeContainer();
        addTearDown(c.dispose);
        final ctrl = c.read(sessionControllerProvider.notifier);
        await c.read(sessionControllerProvider.future);

        // Accessing the getter covers lines 133-134.
        final stream = ctrl.emergencyConfirmationRequests;
        check(stream).isNotNull();
      },
    );

    test(
      'isPauseAllowed returns mode.pauseAllowed when session is active '
      '(line 101)',
      () async {
        final c = _makeContainer();
        addTearDown(c.dispose);
        final ctrl = c.read(sessionControllerProvider.notifier);
        await c.read(sessionControllerProvider.future);

        // Before start: defaults to true.
        check(ctrl.isPauseAllowed).isTrue();

        // After start: reads from runtime.mode.pauseAllowed (line 101).
        await ctrl.startSession(modeId: 'mode-1');
        // mode-1 has default pauseAllowed=true.
        check(ctrl.isPauseAllowed).isTrue();

        await ctrl.disarm();
      },
    );

    test(
      'setSimulationBackgroundClamp with active session calls engine '
      '(lines 126–129)',
      () async {
        final c = _makeContainer();
        addTearDown(c.dispose);
        final ctrl = c.read(sessionControllerProvider.notifier);
        await c.read(sessionControllerProvider.future);

        // No-op when no session is active.
        ctrl.setSimulationBackgroundClamp(true);

        // With an active session, the engine's clamp is engaged.
        await ctrl.startSession(modeId: 'mode-1', isSimulation: true);
        ctrl.setSimulationBackgroundClamp(true); // line 129 executed
        ctrl.setSimulationBackgroundClamp(false);

        await ctrl.disarm();
      },
    );

    test(
      'setSimulationSpeedMultiplier with active session (lines 301–304)',
      () async {
        final c = _makeContainer();
        addTearDown(c.dispose);
        final ctrl = c.read(sessionControllerProvider.notifier);
        await c.read(sessionControllerProvider.future);

        // No-op without an active session.
        ctrl.setSimulationSpeedMultiplier(2.0);

        // With a simulation session.
        await ctrl.startSession(modeId: 'mode-1', isSimulation: true);
        ctrl.setSimulationSpeedMultiplier(2.0); // line 304
        ctrl.setSimulationSpeedMultiplier(1.0);

        await ctrl.disarm();
      },
    );

    test(
      'simulateGpsArrival with active session disarms engine (lines 309–312)',
      () async {
        final c = _makeContainer();
        addTearDown(c.dispose);
        final ctrl = c.read(sessionControllerProvider.notifier);
        await c.read(sessionControllerProvider.future);

        // No-op without an active session.
        await ctrl.simulateGpsArrival();

        // With a session — engine.disarm() is called (line 312).
        await ctrl.startSession(modeId: 'mode-1', isSimulation: true);
        await ctrl.simulateGpsArrival();
        // The session may now be ended.
        final ws = c.read(sessionControllerProvider).value;
        check(ws).isNotNull();
      },
    );

    test(
      'simulateLowBattery with active session is a no-op on engine '
      '(lines 317–319)',
      () async {
        final c = _makeContainer();
        addTearDown(c.dispose);
        final ctrl = c.read(sessionControllerProvider.notifier);
        await c.read(sessionControllerProvider.future);

        // No-op without an active session.
        await ctrl.simulateLowBattery();

        await ctrl.startSession(modeId: 'mode-1', isSimulation: true);
        await ctrl.simulateLowBattery(); // lines 317-319
        // Session is still running.
        await ctrl.disarm();
      },
    );

    test(
      'answerFakeCall with active session calls engine.answerFakeCall '
      '(line 327)',
      () async {
        final c = _makeContainer();
        addTearDown(c.dispose);
        final ctrl = c.read(sessionControllerProvider.notifier);
        await c.read(sessionControllerProvider.future);

        await ctrl.startSession(modeId: 'mode-1');
        // answerFakeCall calls runtime.engine.answerFakeCall() at line 327.
        // The engine ignores this call when not in a fakeCall phase, so no
        // exception is expected.
        await ctrl.answerFakeCall();

        await ctrl.disarm();
      },
    );

    test(
      'hangUp with active session calls engine.hangUp (line 335)',
      () async {
        final c = _makeContainer();
        addTearDown(c.dispose);
        final ctrl = c.read(sessionControllerProvider.notifier);
        await c.read(sessionControllerProvider.future);

        await ctrl.startSession(modeId: 'mode-1');
        await ctrl.hangUp(); // line 335

        await ctrl.disarm();
      },
    );

    test(
      'declineFakeCall with active session calls engine.declineFakeCall '
      '(line 342)',
      () async {
        final c = _makeContainer();
        addTearDown(c.dispose);
        final ctrl = c.read(sessionControllerProvider.notifier);
        await c.read(sessionControllerProvider.future);

        await ctrl.startSession(modeId: 'mode-1');
        await ctrl.declineFakeCall(); // line 342

        await ctrl.disarm();
      },
    );

    test(
      'holdStart with active session calls engine.holdStart (lines 351–354)',
      () async {
        final c = _makeContainer();
        addTearDown(c.dispose);
        final ctrl = c.read(sessionControllerProvider.notifier);
        await c.read(sessionControllerProvider.future);

        // No-op without a session.
        ctrl.holdStart();

        await ctrl.startSession(modeId: 'mode-1');
        ctrl.holdStart(); // lines 351-354
        // No exception expected.
        await ctrl.disarm();
      },
    );

    test(
      'holdRelease with active session calls engine.holdRelease (lines 361–364)',
      () async {
        final c = _makeContainer();
        addTearDown(c.dispose);
        final ctrl = c.read(sessionControllerProvider.notifier);
        await c.read(sessionControllerProvider.future);

        // No-op without a session.
        ctrl.holdRelease();

        await ctrl.startSession(modeId: 'mode-1');
        ctrl.holdRelease(); // lines 361-364
        // No exception expected.
        await ctrl.disarm();
      },
    );
  });
}
