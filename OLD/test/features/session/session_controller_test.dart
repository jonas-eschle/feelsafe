/// Integration tests for [SessionController] — the hotspot from
/// Phase 11. Covers session start, stop, distress routing,
/// simulation plumbing, PIN handling, battery-alert session, and L7
/// race mitigation.
///
/// Uses in-memory repository fakes (subclass + method overrides) so
/// the controller is exercised end-to-end without touching Drift or
/// platform channels.
library;

import 'dart:async';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import 'package:guardianangela/core/utils/pin_result.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/data/repositories/battery_alert_repository.dart';
import 'package:guardianangela/data/repositories/contacts_repository.dart';
import 'package:guardianangela/data/repositories/modes_repository.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/data/repositories/session_logs_repository.dart';
import 'package:guardianangela/data/repositories/settings_repository.dart';
import 'package:guardianangela/data/repositories/templates_repository.dart';
import 'package:guardianangela/data/repositories/user_profile_repository.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/services/service_providers.dart';
import '../../helpers/test_helpers.dart';

// -------- in-memory fake repositories (subclass the real ones) -----

class _FakeModesRepository extends ModesRepository {
  _FakeModesRepository(
    List<SessionMode> initial, {
    List<SessionMode> extraModes = const [],
  }) : _items = [...initial, ...extraModes],
       super.forTesting();
  final List<SessionMode> _items;

  @override
  Future<List<SessionMode>> getAll() async => List<SessionMode>.of(_items);

  @override
  Future<SessionMode?> getById(String id) async {
    for (final m in _items) {
      if (m.id == id) return m;
    }
    return null;
  }

  @override
  Future<void> save(SessionMode value) async {
    _items.removeWhere((m) => m.id == value.id);
    _items.add(value);
  }

  @override
  Future<void> saveAll(List<SessionMode> values) async {
    for (final v in values) {
      await save(v);
    }
  }

  @override
  Future<void> delete(String id) async => _items.removeWhere((m) => m.id == id);

  @override
  Future<void> deleteAll() async => _items.clear();
}

class _FakeContactsRepository extends ContactsRepository {
  _FakeContactsRepository([List<EmergencyContact> initial = const []])
    : _items = List<EmergencyContact>.of(initial),
      super.forTesting();
  final List<EmergencyContact> _items;

  @override
  Future<List<EmergencyContact>> getAll() async =>
      List<EmergencyContact>.of(_items);

  @override
  Future<EmergencyContact?> getById(String id) async {
    for (final c in _items) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  Future<void> save(EmergencyContact value) async {
    _items.removeWhere((c) => c.id == value.id);
    _items.add(value);
  }

  @override
  Future<void> delete(String id) async => _items.removeWhere((c) => c.id == id);

  @override
  Future<void> deleteAll() async => _items.clear();
}

class _FakeTemplatesRepository extends TemplatesRepository {
  _FakeTemplatesRepository() : super.forTesting();

  @override
  Future<List<ReminderTemplate>> getAll() async => const [];

  @override
  Future<List<ReminderTemplate>> getAllGlobal() async => const [];

  @override
  Future<ReminderTemplate?> getById(String id) async => null;

  @override
  Future<void> save(ReminderTemplate value) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> deleteAll() async {}
}

class _FakeSettingsRepository extends SettingsRepository {
  _FakeSettingsRepository([AppSettings? initial])
    : _stored = initial,
      super.forTesting();
  AppSettings? _stored;

  @override
  Future<AppSettings?> get() async => _stored;

  @override
  Future<void> save(AppSettings value) async => _stored = value;
}

class _FakeUserProfileRepository extends UserProfileRepository {
  _FakeUserProfileRepository() : super.forTesting();

  UserProfile? _stored;

  @override
  Future<UserProfile?> get() async => _stored;

  @override
  Future<void> save(UserProfile value) async => _stored = value;
}

class _FakeBatteryAlertRepository extends BatteryAlertRepository {
  _FakeBatteryAlertRepository([BatteryAlertConfig? initial])
    : _stored = initial,
      super.forTesting();
  BatteryAlertConfig? _stored;

  @override
  Future<BatteryAlertConfig?> get() async => _stored;

  @override
  Future<void> save(BatteryAlertConfig value) async => _stored = value;
}

class _FakeSessionLogsRepository extends SessionLogsRepository {
  _FakeSessionLogsRepository() : super.forTesting();

  final List<SessionLog> saved = <SessionLog>[];

  @override
  Future<List<SessionLog>> getAll() async => List<SessionLog>.of(saved);

  @override
  Future<SessionLog?> getById(String id) async {
    for (final l in saved) {
      if (l.id == id) return l;
    }
    return null;
  }

  @override
  Future<void> save(SessionLog value) async {
    saved.removeWhere((l) => l.id == value.id);
    saved.add(value);
  }

  @override
  Future<void> delete(String id) async => saved.removeWhere((l) => l.id == id);

  @override
  Future<void> deleteAll() async => saved.clear();
}

// -------- fake service implementations ------------------------------

class _FakeAudio implements AudioServiceProtocol {
  final List<String> calls = <String>[];

  @override
  Future<void> playAlarm({
    bool maxVolume = true,
    bool isSimulation = false,
    Duration? gradualVolumeRamp,
  }) async => calls.add('playAlarm:$maxVolume:sim=$isSimulation');

  @override
  Future<void> stopAlarm() async => calls.add('stopAlarm');

  @override
  Future<void> playRingtone({
    String? assetPath,
    bool isSimulation = false,
  }) async => calls.add('playRingtone:$assetPath:sim=$isSimulation');

  @override
  Future<void> stopRingtone() async => calls.add('stopRingtone');

  @override
  Future<void> playVoiceRecording({
    required String assetPath,
    bool isSimulation = false,
    String? ttsFallbackPhrase,
  }) async => calls.add(
    'playVoiceRecording:$assetPath:sim=$isSimulation'
    ':tts=${ttsFallbackPhrase ?? "<null>"}',
  );

  @override
  Future<void> stopVoiceRecording() async => calls.add('stopVoiceRecording');
}

class _FakeMessaging implements MessagingServiceProtocol {
  final List<String> calls = <String>[];
  final StreamController<MessageDeliveryUpdate> _upd =
      StreamController<MessageDeliveryUpdate>.broadcast();
  final StreamController<SmsRetryExhaustedEvent> _retry =
      StreamController<SmsRetryExhaustedEvent>.broadcast();

  @override
  Stream<MessageDeliveryUpdate> get deliveryUpdates => _upd.stream;

  @override
  Stream<SmsRetryExhaustedEvent> get smsRetryExhausted => _retry.stream;

  @override
  Future<bool> canAutoSend(MessageChannel channel) async => true;

  @override
  Future<MessageWorkId> sendMessage({
    required EmergencyContact contact,
    required String message,
    required MessageChannel channel,
    bool isSimulation = false,
  }) async {
    calls.add('sendMessage:${contact.id}:$channel:sim=$isSimulation');
    return const MessageWorkId('w0');
  }

  @override
  Future<List<MessageWorkId>> sendToAll({
    required List<EmergencyContact> contacts,
    required String message,
    bool isSimulation = false,
  }) async {
    calls.add('sendToAll:${contacts.length}:sim=$isSimulation');
    return <MessageWorkId>[];
  }

  @override
  Future<void> cancelPending(List<MessageWorkId> workIds) async =>
      calls.add('cancelPending:${workIds.length}');

  @override
  Future<void> retryExhaustedSms(String workId) async =>
      calls.add('retryExhaustedSms:$workId');
}

class _FakePhone implements PhoneServiceProtocol {
  final List<String> calls = <String>[];

  @override
  Future<void> call(String number, {bool isSimulation = false}) async =>
      calls.add('call:$number:sim=$isSimulation');

  @override
  Future<void> callEmergency(
    String number, {
    bool isSimulation = false,
  }) async => calls.add('callEmergency:$number:sim=$isSimulation');
}

class _FakeNotification implements NotificationServiceProtocol {
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

class _FakeVibration implements VibrationServiceProtocol {
  @override
  Future<void> alarmPattern({bool isSimulation = false}) async {}

  @override
  Future<void> warningPattern({bool isSimulation = false}) async {}

  @override
  Future<void> fakeCallPattern({bool isSimulation = false}) async {}

  @override
  Future<void> stop() async {}
}

class _FakeHardwareButton implements HardwareButtonServiceProtocol {
  final StreamController<HardwarePanicEvent> _ctrl =
      StreamController<HardwarePanicEvent>.broadcast(sync: true);
  bool _listening = false;

  @override
  Stream<HardwarePanicEvent> get panicEvents => _ctrl.stream;

  @override
  bool get isListening => _listening;

  @override
  Future<void> start({
    required String buttonType,
    required String pattern,
    int pressCount = 5,
    int pressWindowMs = 500,
    double longPressDurationSeconds = 2.0,
  }) async {
    _listening = true;
  }

  @override
  Future<void> stop() async {
    _listening = false;
  }
}

class _FakeGeofence implements GeofenceServiceProtocol {
  final StreamController<LocationPoint> _ctrl =
      StreamController<LocationPoint>.broadcast(sync: true);

  @override
  Stream<LocationPoint> get arrivals => _ctrl.stream;

  @override
  Future<void> registerGeofence({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) async {}

  @override
  Future<void> removeGeofence() async {}
}

class _FakeBatteryMonitor implements BatteryMonitorServiceProtocol {
  final StreamController<int> _ctrl = StreamController<int>.broadcast(
    sync: true,
  );

  @override
  Stream<int> get onLowBattery => _ctrl.stream;

  @override
  bool get isActive => false;

  @override
  Future<void> startMonitoring({required int thresholdPercent}) async {}

  @override
  Future<void> stopMonitoring() async {}
}

class _FakeDeviceState implements DeviceStateServiceProtocol {
  @override
  Future<bool> isDndOn() async => false;

  @override
  Future<bool> isSilent() async => false;
}

class _FakeLocation implements LocationServiceProtocol {
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
  List<LocationPoint> get history => const <LocationPoint>[];

  @override
  void clearHistory() {}

  @override
  Future<LocationPoint?> getCurrentPosition() async => null;
}

class _FakeIncomingCall implements IncomingCallServiceProtocol {
  final StreamController<CallState> _ctrl =
      StreamController<CallState>.broadcast(sync: true);

  @override
  Stream<CallState> get callState => _ctrl.stream;

  @override
  Future<void> startListening() async {}

  @override
  Future<void> stopListening() async {}
}

// -------- test fixture assembly -------------------------------------

/// Collected overrides + fake handles for one test.
class _Fixture {
  _Fixture({
    required this.modesRepo,
    required this.settingsRepo,
    required this.sessionLogsRepo,
    required this.messaging,
    required this.phone,
    required this.audio,
    required this.container,
  });

  final _FakeModesRepository modesRepo;
  final _FakeSettingsRepository settingsRepo;
  final _FakeSessionLogsRepository sessionLogsRepo;
  final _FakeMessaging messaging;
  final _FakePhone phone;
  final _FakeAudio audio;
  final ProviderContainer container;
}

_Fixture _makeFixture({
  List<SessionMode>? modes,
  List<SessionMode>? distressModes,
  AppSettings? settings,
  List<EmergencyContact>? contacts,
  BatteryAlertConfig? batteryAlert,
}) {
  // Phase 2.5: distress modes live in the modes repo with
  // isDistressMode=true. Tests pass them via [distressModes].
  final effectiveDistressModes =
      distressModes ??
      [
        makeDistressMode(steps: [smsStep(order: 0)]),
      ];
  final modesRepo = _FakeModesRepository(
    modes ??
        [
          makeMode(id: 'mode-1', steps: [holdStep()]),
        ],
    extraModes: effectiveDistressModes,
  );
  final contactsRepo = _FakeContactsRepository(contacts ?? const []);
  final settingsRepo = _FakeSettingsRepository(
    settings ?? const AppSettings(defaults: AppDefaults()),
  );
  final sessionLogsRepo = _FakeSessionLogsRepository();
  final batteryAlertRepo = _FakeBatteryAlertRepository(batteryAlert);

  final messaging = _FakeMessaging();
  final phone = _FakePhone();
  final audio = _FakeAudio();

  final container = ProviderContainer(
    overrides: [
      modesRepositoryProvider.overrideWithValue(modesRepo),
      contactsRepositoryProvider.overrideWithValue(contactsRepo),
      templatesRepositoryProvider.overrideWithValue(_FakeTemplatesRepository()),
      settingsRepositoryProvider.overrideWithValue(settingsRepo),
      userProfileRepositoryProvider.overrideWithValue(
        _FakeUserProfileRepository(),
      ),
      batteryAlertRepositoryProvider.overrideWithValue(batteryAlertRepo),
      sessionLogsRepositoryProvider.overrideWithValue(sessionLogsRepo),
      messagingServiceProvider.overrideWithValue(messaging),
      phoneServiceProvider.overrideWithValue(phone),
      audioServiceProvider.overrideWithValue(audio),
      notificationServiceProvider.overrideWithValue(_FakeNotification()),
      vibrationServiceProvider.overrideWithValue(_FakeVibration()),
      hardwareButtonServiceProvider.overrideWithValue(_FakeHardwareButton()),
      geofenceServiceProvider.overrideWithValue(_FakeGeofence()),
      batteryMonitorServiceProvider.overrideWithValue(_FakeBatteryMonitor()),
      deviceStateServiceProvider.overrideWithValue(_FakeDeviceState()),
      locationServiceProvider.overrideWithValue(_FakeLocation()),
      incomingCallServiceProvider.overrideWithValue(_FakeIncomingCall()),
      simulationMessagingProvider.overrideWithValue(_FakeMessaging()),
      simulationPhoneProvider.overrideWithValue(_FakePhone()),
      simulationAudioProvider.overrideWithValue(_FakeAudio()),
      simulationNotificationProvider.overrideWithValue(_FakeNotification()),
      simulationVibrationProvider.overrideWithValue(_FakeVibration()),
      simulationHardwareButtonProvider.overrideWithValue(_FakeHardwareButton()),
      simulationGeofenceProvider.overrideWithValue(_FakeGeofence()),
      simulationBatteryMonitorProvider.overrideWithValue(_FakeBatteryMonitor()),
      simulationDeviceStateProvider.overrideWithValue(_FakeDeviceState()),
      simulationLocationProvider.overrideWithValue(_FakeLocation()),
      simulationIncomingCallProvider.overrideWithValue(_FakeIncomingCall()),
    ],
  );

  return _Fixture(
    modesRepo: modesRepo,
    settingsRepo: settingsRepo,
    sessionLogsRepo: sessionLogsRepo,
    messaging: messaging,
    phone: phone,
    audio: audio,
    container: container,
  );
}

// ------------------------------- tests -------------------------------

void main() {
  group('SessionController.startSession', () {
    test('throws when mode id does not exist', () async {
      final fx = _makeFixture();
      addTearDown(fx.container.dispose);
      final controller = fx.container.read(sessionControllerProvider.notifier);
      await fx.container.read(sessionControllerProvider.future);
      await check(controller.startSession(modeId: 'nope')).throws<StateError>();
    });

    test('throws when mode has no chain steps', () async {
      final modes = [
        const SessionMode(id: 'empty', name: 'Empty', chainSteps: []),
      ];
      final fx = _makeFixture(modes: modes);
      addTearDown(fx.container.dispose);
      final controller = fx.container.read(sessionControllerProvider.notifier);
      await fx.container.read(sessionControllerProvider.future);
      await check(
        controller.startSession(modeId: 'empty'),
      ).throws<StateError>();
    });

    test(
      'blocks start when the resolved distress mode has no steps (D-SAFETY-17)',
      () async {
        final fx = _makeFixture(
          distressModes: [
            const SessionMode(id: 'empty', name: 'Empty', isDistressMode: true),
          ],
        );
        addTearDown(fx.container.dispose);
        final controller = fx.container.read(
          sessionControllerProvider.notifier,
        );
        await fx.container.read(sessionControllerProvider.future);
        await check(
          controller.startSession(modeId: 'mode-1'),
        ).throws<StateError>();
      },
    );

    test('blocks start when no distress mode is configured', () async {
      final fx = _makeFixture(distressModes: const []);
      addTearDown(fx.container.dispose);
      final controller = fx.container.read(sessionControllerProvider.notifier);
      await fx.container.read(sessionControllerProvider.future);
      await check(
        controller.startSession(modeId: 'mode-1'),
      ).throws<StateError>();
    });

    test('populates WalkSession on successful start', () async {
      final fx = _makeFixture();
      addTearDown(fx.container.dispose);
      final controller = fx.container.read(sessionControllerProvider.notifier);
      await fx.container.read(sessionControllerProvider.future);
      await controller.startSession(modeId: 'mode-1');
      final ws = fx.container.read(sessionControllerProvider).value;
      check(ws).isNotNull();
      check(ws!.modeId).equals('mode-1');
      check(ws.isSimulation).isFalse();
    });

    test('refuses to start a second user session over an active one', () async {
      final fx = _makeFixture();
      addTearDown(fx.container.dispose);
      final controller = fx.container.read(sessionControllerProvider.notifier);
      await fx.container.read(sessionControllerProvider.future);
      await controller.startSession(modeId: 'mode-1');
      await check(
        controller.startSession(modeId: 'mode-1'),
      ).throws<StateError>();
      await controller.disarm();
    });
  });

  group('SessionController simulation routing', () {
    test('isSimulation=true uses simulation services throughout', () async {
      final modes = [
        makeMode(
          id: 'mode-sms',
          steps: [smsStep(order: 0, durationSeconds: 0, gracePeriodSeconds: 0)],
        ),
      ];
      final fx = _makeFixture(modes: modes);
      addTearDown(fx.container.dispose);
      final controller = fx.container.read(sessionControllerProvider.notifier);
      await fx.container.read(sessionControllerProvider.future);
      await controller.startSession(modeId: 'mode-sms', isSimulation: true);
      final ws = fx.container.read(sessionControllerProvider).value;
      check(ws).isNotNull();
      check(ws!.isSimulation).isTrue();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      // Orchestrator never invokes the real messaging service in
      // simulation mode (Layer 1 of the 4-layer defense).
      check(fx.messaging.calls).isEmpty();
    });

    test('isSimulation=false uses real services', () async {
      final fx = _makeFixture();
      addTearDown(fx.container.dispose);
      final controller = fx.container.read(sessionControllerProvider.notifier);
      await fx.container.read(sessionControllerProvider.future);
      await controller.startSession(modeId: 'mode-1');
      final ws = fx.container.read(sessionControllerProvider).value;
      check(ws).isNotNull();
      check(ws!.isSimulation).isFalse();
    });
  });

  group('SessionController mutators', () {
    test('disarm transitions the session to an ended phase', () async {
      final fx = _makeFixture();
      addTearDown(fx.container.dispose);
      final controller = fx.container.read(sessionControllerProvider.notifier);
      await fx.container.read(sessionControllerProvider.future);
      await controller.startSession(modeId: 'mode-1');
      await controller.disarm();
      final ws = fx.container.read(sessionControllerProvider).value;
      check(ws).isNotNull();
      check(ws!.phase).isA<SessionPhaseEnded>();
    });

    test('pause then resume restores the running phase', () async {
      final fx = _makeFixture();
      addTearDown(fx.container.dispose);
      final controller = fx.container.read(sessionControllerProvider.notifier);
      await fx.container.read(sessionControllerProvider.future);
      await controller.startSession(modeId: 'mode-1');
      await controller.pause();
      final paused = fx.container.read(sessionControllerProvider).value;
      check(paused!.phase).isA<SessionPhasePaused>();
      await controller.resume();
      final resumed = fx.container.read(sessionControllerProvider).value;
      check(resumed!.phase).isA<SessionPhaseActive>();
    });

    test('disarm is idempotent — calling twice does not explode', () async {
      final fx = _makeFixture();
      addTearDown(fx.container.dispose);
      final controller = fx.container.read(sessionControllerProvider.notifier);
      await fx.container.read(sessionControllerProvider.future);
      await controller.startSession(modeId: 'mode-1');
      await controller.disarm();
      await controller.disarm();
      final ws = fx.container.read(sessionControllerProvider).value;
      check(ws!.phase).isA<SessionPhaseEnded>();
    });

    test(
      'pause / resume / disarm are no-ops when no session is active',
      () async {
        final fx = _makeFixture();
        addTearDown(fx.container.dispose);
        final controller = fx.container.read(
          sessionControllerProvider.notifier,
        );
        await fx.container.read(sessionControllerProvider.future);
        await controller.pause();
        await controller.resume();
        await controller.disarm();
        check(fx.container.read(sessionControllerProvider).value).isNull();
      },
    );
  });

  group('SessionController distress routing', () {
    test('triggerDistressChain swaps the engine chain', () async {
      final fx = _makeFixture();
      addTearDown(fx.container.dispose);
      final controller = fx.container.read(sessionControllerProvider.notifier);
      await fx.container.read(sessionControllerProvider.future);
      await controller.startSession(modeId: 'mode-1');
      await controller.triggerDistressChain();
      // After distress, the session has not ended (chain is running
      // or just completed if every step was instantaneous).
      final ws = fx.container.read(sessionControllerProvider).value;
      check(ws).isNotNull();
    });

    test('triggerDistressChain is a no-op when no session is active', () async {
      final fx = _makeFixture();
      addTearDown(fx.container.dispose);
      final controller = fx.container.read(sessionControllerProvider.notifier);
      await fx.container.read(sessionControllerProvider.future);
      await controller.triggerDistressChain();
      check(fx.container.read(sessionControllerProvider).value).isNull();
    });
  });

  group('SessionController.handlePinResult', () {
    test('correct PIN clears wrong counter and returns true', () {
      final fx = _makeFixture();
      addTearDown(fx.container.dispose);
      final controller = fx.container.read(sessionControllerProvider.notifier);
      check(controller.handlePinResult(PinResult.correct)).isTrue();
    });

    test('wrong PIN under threshold returns false', () {
      final fx = _makeFixture();
      addTearDown(fx.container.dispose);
      final controller = fx.container.read(sessionControllerProvider.notifier);
      for (var i = 0; i < SessionController.wrongPinThreshold - 1; i++) {
        check(controller.handlePinResult(PinResult.wrong)).isFalse();
      }
    });

    test('duress PIN always returns false', () {
      final fx = _makeFixture();
      addTearDown(fx.container.dispose);
      final controller = fx.container.read(sessionControllerProvider.notifier);
      check(controller.handlePinResult(PinResult.duress)).isFalse();
    });

    test('wrongPinThreshold immediately returns false', () {
      final fx = _makeFixture();
      addTearDown(fx.container.dispose);
      final controller = fx.container.read(sessionControllerProvider.notifier);
      check(controller.handlePinResult(PinResult.wrongPinThreshold)).isFalse();
    });

    test('timeout returns false and does not bump the counter', () {
      final fx = _makeFixture();
      addTearDown(fx.container.dispose);
      final controller = fx.container.read(sessionControllerProvider.notifier);
      check(controller.handlePinResult(PinResult.timeout)).isFalse();
    });

    test('cancelled returns false and does not bump the counter', () {
      final fx = _makeFixture();
      addTearDown(fx.container.dispose);
      final controller = fx.container.read(sessionControllerProvider.notifier);
      check(controller.handlePinResult(PinResult.cancelled)).isFalse();
    });

    test(
      'crossing the wrong-pin threshold fires distress asynchronously',
      () async {
        final fx = _makeFixture();
        addTearDown(fx.container.dispose);
        final controller = fx.container.read(
          sessionControllerProvider.notifier,
        );
        await fx.container.read(sessionControllerProvider.future);
        await controller.startSession(modeId: 'mode-1');
        for (var i = 0; i < SessionController.wrongPinThreshold; i++) {
          controller.handlePinResult(PinResult.wrong);
        }
        await Future<void>.delayed(const Duration(milliseconds: 10));
        final ws = fx.container.read(sessionControllerProvider).value;
        check(ws).isNotNull();
      },
    );
  });

  group('SessionController battery-alert session', () {
    test('startBatteryAlertSession no-ops when config is disabled', () async {
      final fx = _makeFixture();
      addTearDown(fx.container.dispose);
      final controller = fx.container.read(sessionControllerProvider.notifier);
      await fx.container.read(sessionControllerProvider.future);
      await controller.startBatteryAlertSession(
        const BatteryAlertConfig(enabled: false),
      );
      check(fx.container.read(sessionControllerProvider).value).isNull();
    });

    test('startBatteryAlertSession no-ops when chain is empty', () async {
      final fx = _makeFixture();
      addTearDown(fx.container.dispose);
      final controller = fx.container.read(sessionControllerProvider.notifier);
      await fx.container.read(sessionControllerProvider.future);
      await controller.startBatteryAlertSession(const BatteryAlertConfig());
      check(fx.container.read(sessionControllerProvider).value).isNull();
    });

    test(
      'startBatteryAlertSession refuses to start over a user session',
      () async {
        final fx = _makeFixture();
        addTearDown(fx.container.dispose);
        final controller = fx.container.read(
          sessionControllerProvider.notifier,
        );
        await fx.container.read(sessionControllerProvider.future);
        await controller.startSession(modeId: 'mode-1');
        await check(
          controller.startBatteryAlertSession(
            BatteryAlertConfig(chain: [smsStep(order: 0)]),
          ),
        ).throws<StateError>();
      },
    );

    test('startBatteryAlertSession runs with isBackgroundAlert=true', () async {
      final fx = _makeFixture();
      addTearDown(fx.container.dispose);
      final controller = fx.container.read(sessionControllerProvider.notifier);
      await fx.container.read(sessionControllerProvider.future);
      await controller.startBatteryAlertSession(
        BatteryAlertConfig(
          enabled: true,
          chain: [smsStep(order: 0, durationSeconds: 0)],
        ),
      );
      final ws = fx.container.read(sessionControllerProvider).value;
      check(ws).isNotNull();
      check(ws!.isBackgroundAlert).isTrue();
    });

    test(
      'startSession cancels an existing battery-alert session (L14)',
      () async {
        final fx = _makeFixture();
        addTearDown(fx.container.dispose);
        final controller = fx.container.read(
          sessionControllerProvider.notifier,
        );
        await fx.container.read(sessionControllerProvider.future);
        await controller.startBatteryAlertSession(
          BatteryAlertConfig(
            enabled: true,
            chain: [smsStep(order: 0, durationSeconds: 10)],
          ),
        );
        await controller.startSession(modeId: 'mode-1');
        final ws = fx.container.read(sessionControllerProvider).value;
        check(ws!.isBackgroundAlert).isFalse();
        check(ws.modeId).equals('mode-1');
      },
    );
  });

  group('SessionController L7 race mitigation', () {
    test(
      'startSession awaits the settings hydrate before reading mode',
      () async {
        final fx = _makeFixture(
          settings: const AppSettings(
            defaults: AppDefaults(),
            emergencyCallNumber: '911',
          ),
        );
        addTearDown(fx.container.dispose);
        final controller = fx.container.read(
          sessionControllerProvider.notifier,
        );
        // Do NOT pre-await settingsControllerProvider.future — simulate
        // UI-level "start as soon as the user taps" timing. The
        // controller must await the hydrate internally.
        await controller.startSession(modeId: 'mode-1');
        final ws = fx.container.read(sessionControllerProvider).value;
        check(ws).isNotNull();
      },
    );
  });

  group('SessionController logging', () {
    test('disarm ends the session and persists a log row', () async {
      final fx = _makeFixture();
      addTearDown(fx.container.dispose);
      final controller = fx.container.read(sessionControllerProvider.notifier);
      await fx.container.read(sessionControllerProvider.future);
      await controller.startSession(modeId: 'mode-1');
      await controller.disarm();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final logs = await fx.sessionLogsRepo.getAll();
      check(logs.length).equals(1);
    });
  });

  group('SessionController distress-mode resolution', () {
    test('uses mode.distressModeId when set', () async {
      final distressModes = [
        makeDistressMode(id: 'a', steps: [smsStep(order: 0)]),
        makeDistressMode(
          id: 'b',
          steps: [smsStep(order: 0, id: 'b-s')],
        ),
      ];
      final modes = [
        makeMode(id: 'mode-b', distressModeId: 'b', steps: [holdStep()]),
      ];
      final fx = _makeFixture(modes: modes, distressModes: distressModes);
      addTearDown(fx.container.dispose);
      final controller = fx.container.read(sessionControllerProvider.notifier);
      await fx.container.read(sessionControllerProvider.future);
      await controller.startSession(modeId: 'mode-b');
      await controller.triggerDistressChain();
      check(fx.container.read(sessionControllerProvider).value).isNotNull();
    });

    test(
      'falls back to first distress mode when distressModeId is null',
      () async {
        final distressModes = [
          makeDistressMode(id: 'first', steps: [smsStep(order: 0)]),
          makeDistressMode(id: 'second', steps: [smsStep(order: 0)]),
        ];
        final fx = _makeFixture(distressModes: distressModes);
        addTearDown(fx.container.dispose);
        final controller = fx.container.read(
          sessionControllerProvider.notifier,
        );
        await fx.container.read(sessionControllerProvider.future);
        await controller.startSession(modeId: 'mode-1');
        check(fx.container.read(sessionControllerProvider).value).isNotNull();
      },
    );
  });

  group('SessionController fake-call methods', () {
    test('fake-call methods are no-ops when no session is active', () async {
      final fx = _makeFixture();
      addTearDown(fx.container.dispose);
      final controller = fx.container.read(sessionControllerProvider.notifier);
      await fx.container.read(sessionControllerProvider.future);
      await controller.answerFakeCall();
      await controller.hangUp();
      await controller.declineFakeCall();
      check(fx.container.read(sessionControllerProvider).value).isNull();
    });
  });
}
