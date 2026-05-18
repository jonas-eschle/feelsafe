/// Behavioral tests for every `Fake*Service` test double.
///
/// Fakes are deterministic, recorded-invocation doubles used by other
/// layers' tests. These tests exercise every public method, the
/// invocation log, the scripted-return properties, the
/// stream-injection helpers, and `dispose()` so that coverage is
/// close to 100% on each fake.
library;

import 'dart:async';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/location_point.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/domain/models/stealth_config.dart';
import 'package:guardianangela/services/fakes/fake_audio_service.dart';
import 'package:guardianangela/services/fakes/fake_battery_monitor_service.dart';
import 'package:guardianangela/services/fakes/fake_device_state_service.dart';
import 'package:guardianangela/services/fakes/fake_geofence_service.dart';
import 'package:guardianangela/services/fakes/fake_hardware_button_service.dart';
import 'package:guardianangela/services/fakes/fake_home_widget_service.dart';
import 'package:guardianangela/services/fakes/fake_incoming_call_service.dart';
import 'package:guardianangela/services/fakes/fake_location_service.dart';
import 'package:guardianangela/services/fakes/fake_messaging_service.dart';
import 'package:guardianangela/services/fakes/fake_notification_service.dart';
import 'package:guardianangela/services/fakes/fake_phone_service.dart';
import 'package:guardianangela/services/fakes/fake_stealth_icon_service.dart';
import 'package:guardianangela/services/fakes/fake_system_ui_service.dart';
import 'package:guardianangela/services/fakes/fake_vibration_service.dart';
import 'package:guardianangela/services/fakes/fake_wakelock_service.dart';
import 'package:guardianangela/services/protocols/hardware_button_service_protocol.dart';
import 'package:guardianangela/services/protocols/incoming_call_service_protocol.dart';
import 'package:guardianangela/services/protocols/messaging_service_protocol.dart';

ReminderTemplate _fakeTemplate() => const ReminderTemplate(
  id: 't1',
  name: 'ping',
  title: 'Hello',
  body: 'body',
  confirmationType: ConfirmationType.tapButton,
  displayStyle: ReminderDisplayStyle.fullScreen,
  isGlobal: true,
);

EmergencyContact _fakeContact({
  String id = 'c1',
  String phone = '+15551234567',
  List<MessageChannel> channels = const [MessageChannel.sms],
}) => EmergencyContact(
  id: id,
  name: 'Alice',
  phoneNumber: phone,
  sortOrder: 0,
  channels: channels,
);

void main() {
  group('FakeAudioService', () {
    test('records every call and dispose is a safe no-op', () async {
      final s = FakeAudioService();
      await s.playAlarm();
      await s.playAlarm(maxVolume: false);
      await s.stopAlarm();
      await s.playRingtone();
      await s.playRingtone(assetPath: 'assets/x.wav');
      await s.stopRingtone();
      await s.playVoiceRecording(assetPath: 'assets/v.mp3');
      await s.stopVoiceRecording();
      check(s.calls).deepEquals([
        'playAlarm:maxVolume=true',
        'playAlarm:maxVolume=false',
        'stopAlarm',
        'playRingtone:',
        'playRingtone:assets/x.wav',
        'stopRingtone',
        'playVoiceRecording:assets/v.mp3',
        'stopVoiceRecording',
      ]);
      s.dispose(); // no-op
    });
  });

  group('FakeBatteryMonitorService', () {
    test('start/stop toggles isActive and stream injection works',
        () async {
      final s = FakeBatteryMonitorService();
      check(s.isActive).isFalse();
      final fut = s.onLowBattery.first;
      await s.startMonitoring(thresholdPercent: 20);
      check(s.isActive).isTrue();
      s.injectLowBattery(15);
      final received = await fut;
      check(received).equals(15);
      await s.stopMonitoring();
      check(s.isActive).isFalse();
      check(s.calls).deepEquals([
        'startMonitoring:20',
        'stopMonitoring',
      ]);
      s.dispose();
    });
  });

  group('FakeDeviceStateService', () {
    test('scripted return values and invocation log', () async {
      final s = FakeDeviceStateService();
      check(await s.isDndOn()).isFalse();
      check(await s.isSilent()).isFalse();
      s.dndOn = true;
      s.silent = true;
      check(await s.isDndOn()).isTrue();
      check(await s.isSilent()).isTrue();
      check(s.calls)
          .deepEquals(['isDndOn', 'isSilent', 'isDndOn', 'isSilent']);
      s.dispose();
    });
  });

  group('FakeGeofenceService', () {
    test('register/remove + injected arrivals hit the stream', () async {
      final s = FakeGeofenceService();
      final fut = s.arrivals.first;
      await s.registerGeofence(
        latitude: 47.0,
        longitude: 8.0,
        radiusMeters: 50,
      );
      s.injectArrival(LocationPoint(
        latitude: 47.0,
        longitude: 8.0,
        timestamp: DateTime.utc(2026, 1, 1),
      ));
      final received = await fut;
      check(received.latitude).equals(47.0);
      await s.removeGeofence();
      check(s.calls).deepEquals([
        'registerGeofence:47.0,8.0/50.0',
        'removeGeofence',
      ]);
      s.dispose();
    });
  });

  group('FakeHardwareButtonService', () {
    test('start/stop + injected panic event hit the stream', () async {
      final s = FakeHardwareButtonService();
      check(s.isListening).isFalse();
      final fut = s.panicEvents.first;
      await s.start(buttonType: 'volume', pattern: '5x_press');
      check(s.isListening).isTrue();
      s.injectPanic(HardwarePanicEvent(
        buttonType: 'volume',
        pattern: '5x_press',
        timestamp: DateTime.utc(2026, 1, 1),
      ));
      final event = await fut;
      check(event.buttonType).equals('volume');
      await s.stop();
      check(s.isListening).isFalse();
      check(s.calls)
          .deepEquals(['start:volume/5x_press', 'stop']);
      s.dispose();
    });
  });

  group('FakeHomeWidgetService', () {
    test('records calls and markers/uri helpers work', () async {
      final s = FakeHomeWidgetService();
      final fut = s.widgetClicked.first;
      await s.registerInteractivity(() {});
      check(await s.initiallyLaunchedUri()).isNull();
      s.initialLaunchUri = Uri.parse('app://x');
      check((await s.initiallyLaunchedUri())?.toString()).equals('app://x');
      await s.updateStatus(status: 'Idle', modeName: 'Walk', isRunning: false);
      await s.writeLastMarker('m1');
      check(await s.consumePendingMarker()).equals('m1');
      check(await s.consumePendingMarker()).isNull();
      s.injectClick(Uri.parse('app://tap'));
      check((await fut).toString()).equals('app://tap');
      check(s.calls).deepEquals([
        'registerInteractivity',
        'initiallyLaunchedUri',
        'initiallyLaunchedUri',
        'updateStatus:Idle/Walk/false',
        'writeLastMarker:m1',
        'consumePendingMarker',
        'consumePendingMarker',
      ]);
      s.dispose();
    });
  });

  group('FakeIncomingCallService', () {
    test('start/stop + injected states hit the stream', () async {
      final s = FakeIncomingCallService();
      final fut = s.callState.take(2).toList();
      await s.startListening();
      s.injectState(CallState.ringing);
      s.injectState(CallState.active);
      await s.stopListening();
      check(await fut)
          .deepEquals([CallState.ringing, CallState.active]);
      check(s.calls).deepEquals(['startListening', 'stopListening']);
      s.dispose();
    });
  });

  group('FakeLocationService', () {
    test('tracking calls, injected points and history clear', () async {
      final s = FakeLocationService();
      check(await s.requestPermission()).isTrue();
      s.permissionGranted = false;
      check(await s.requestPermission()).isFalse();
      await s.startTracking(interval: const Duration(seconds: 30));
      await s.stopTracking();
      check(s.history).isEmpty();
      check(s.getLastLocationPoint()).isNull();
      check(s.getLastLocationUrl()).isNull();
      final p = LocationPoint(
        latitude: 1.0,
        longitude: 2.0,
        timestamp: DateTime.utc(2026, 1, 2),
      );
      s.injectPoint(p);
      check(s.getLastLocationPoint()).equals(p);
      check(s.getLastLocationUrl())
          .equals('https://maps.google.com/?q=1.0,2.0');
      check(s.history).deepEquals([p]);
      s.clearHistory();
      check(s.history).isEmpty();
      check(s.calls.contains('startTracking:30s')).isTrue();
      check(s.calls.contains('clearHistory')).isTrue();
      s.dispose();
    });
  });

  group('FakeMessagingService', () {
    test('sends, fan-out and retry paths', () async {
      final s = FakeMessagingService();
      final deliveryFut = s.deliveryUpdates.first;
      final retryFut = s.smsRetryExhausted.first;
      check(await s.canAutoSend(MessageChannel.sms)).isTrue();
      final wid = await s.sendMessage(
        contact: _fakeContact(),
        message: 'help',
        channel: MessageChannel.sms,
      );
      check(wid.value).equals('fake-0');
      final contacts = [
        _fakeContact(id: 'a'),
        _fakeContact(id: 'b', phone: '+15550000001'),
      ];
      final list = await s.sendToAll(contacts: contacts, message: 'h');
      check(list.length).equals(2);
      check(list.map((w) => w.value).toList())
          .deepEquals(['fake-1', 'fake-2']);
      await s.cancelPending(list);
      await s.retryExhaustedSms('fake-1');
      s.injectDeliveryUpdate(
        const MessageDeliveryUpdate(workId: 'x', status: 'queued'),
      );
      final delivery = await deliveryFut;
      check(delivery.status).equals('queued');
      s.injectRetryExhausted(const SmsRetryExhaustedEvent(
        workId: 'y',
        recipient: '+1',
        message: 'hi',
      ));
      final retry = await retryFut;
      check(retry.workId).equals('y');
      check(s.calls.contains('canAutoSend:sms')).isTrue();
      check(s.calls.contains('sendMessage:+15551234567/sms')).isTrue();
      check(s.calls.contains('sendToAll:2')).isTrue();
      check(s.calls.contains('cancelPending:2')).isTrue();
      check(s.calls.contains('retryExhaustedSms:fake-1')).isTrue();
      s.dispose();
    });

    test('MessageWorkId equality and toString', () {
      const a = MessageWorkId('one');
      const b = MessageWorkId('one');
      const c = MessageWorkId('two');
      check(a == b).isTrue();
      check(a == c).isFalse();
      check(a.hashCode).equals(b.hashCode);
      check(a.toString()).equals('MessageWorkId(one)');
      // ignore: unrelated_type_equality_checks
      check(a == 'one').isFalse();
    });
  });

  group('FakeNotificationService', () {
    test('all methods recorded; schedule returns monotonic ids', () async {
      final s = FakeNotificationService();
      final tapFut = s.actionTaps.first;
      await s.init();
      await s.showSessionNotification(title: 'T', body: 'B');
      await s.showDisguisedReminder(template: _fakeTemplate());
      final id1 = await s.scheduleNotification(
        title: 'A',
        body: 'b',
        delay: const Duration(seconds: 10),
      );
      final id2 = await s.scheduleNotification(
        title: 'B',
        body: 'b',
        delay: const Duration(seconds: 5),
      );
      check(id2).equals(id1 + 1);
      await s.cancelNotification(id1);
      await s.cancelAll();
      await s.showToast('hi');
      s.injectTap('accept');
      check(await tapFut).equals('accept');
      check(s.calls.first).equals('init');
      check(s.calls.contains('showSessionNotification:T')).isTrue();
      check(s.calls.contains('showDisguisedReminder:t1')).isTrue();
      check(s.calls.contains('scheduleNotification:A/10s')).isTrue();
      check(s.calls.contains('cancelNotification:$id1')).isTrue();
      check(s.calls.contains('cancelAll')).isTrue();
      check(s.calls.contains('showToast:hi')).isTrue();
      s.dispose();
    });
  });

  group('FakePhoneService', () {
    test('both call variants recorded', () async {
      final s = FakePhoneService();
      await s.call('+1234');
      await s.callEmergency('112');
      check(s.calls).deepEquals(['call:+1234', 'callEmergency:112']);
      s.dispose();
    });
  });

  group('FakeStealthIconService', () {
    test('setPreset + getCurrentPreset roundtrip', () async {
      final s = FakeStealthIconService();
      check(await s.getCurrentPreset()).equals(StealthIconPreset.calendar);
      await s.setPreset(StealthIconPreset.music);
      check(await s.getCurrentPreset()).equals(StealthIconPreset.music);
      check(s.calls).deepEquals([
        'getCurrentPreset',
        'setPreset:music',
        'getCurrentPreset',
      ]);
      s.dispose();
    });
  });

  group('FakeSystemUiService', () {
    test('quickExit / batteryOptimized recorded', () async {
      final s = FakeSystemUiService();
      await s.quickExit();
      await s.requestBatteryOptimizationExemption();
      check(await s.isBatteryOptimized()).isFalse();
      s.batteryOptimized = true;
      check(await s.isBatteryOptimized()).isTrue();
      check(s.calls).deepEquals([
        'quickExit',
        'requestBatteryOptimizationExemption',
        'isBatteryOptimized',
        'isBatteryOptimized',
      ]);
      s.dispose();
    });
  });

  group('FakeVibrationService', () {
    test('alarm/warning/fakeCall/stop all recorded', () async {
      final s = FakeVibrationService();
      await s.alarmPattern();
      await s.warningPattern();
      await s.fakeCallPattern();
      await s.stop();
      check(s.calls).deepEquals([
        'alarmPattern',
        'warningPattern',
        'fakeCallPattern',
        'stop',
      ]);
      s.dispose();
    });
  });

  group('FakeWakelockService', () {
    test('enable/disable toggles and recorded', () async {
      final s = FakeWakelockService();
      check(await s.isEnabled).isFalse();
      await s.enable();
      check(await s.isEnabled).isTrue();
      await s.disable();
      check(await s.isEnabled).isFalse();
      check(s.calls).deepEquals([
        'isEnabled',
        'enable',
        'isEnabled',
        'disable',
        'isEnabled',
      ]);
      s.dispose();
    });
  });

  test('FakeMessagingService isSimulation flag is ignored by recorded fake',
      () async {
    final s = FakeMessagingService();
    final w = await s.sendMessage(
      contact: _fakeContact(),
      message: 'x',
      channel: MessageChannel.whatsapp,
      isSimulation: true,
    );
    check(w.value).equals('fake-0');
    // Fake doesn't record isSimulation, verifying contract passes.
    check(s.calls.single).equals('sendMessage:+15551234567/whatsapp');
    s.dispose();
  });

  test('FakeLocationService unmodifiable history throws on external mutate',
      () {
    final s = FakeLocationService();
    s.injectPoint(LocationPoint(
      latitude: 1,
      longitude: 2,
      timestamp: DateTime.utc(2026),
    ));
    final hist = s.history;
    check(() => hist.add(LocationPoint(
          latitude: 3,
          longitude: 4,
          timestamp: DateTime.utc(2026),
        ))).throws<UnsupportedError>();
  });

  test('FakeBatteryMonitorService stream only delivers after inject',
      () async {
    final s = FakeBatteryMonitorService();
    final events = <int>[];
    final sub = s.onLowBattery.listen(events.add);
    await Future<void>.delayed(Duration.zero);
    check(events).isEmpty();
    s.injectLowBattery(5);
    await Future<void>.delayed(Duration.zero);
    check(events).deepEquals([5]);
    await sub.cancel();
    s.dispose();
  });

  test('FakeGeofenceService broadcast — multiple listeners', () async {
    final s = FakeGeofenceService();
    final a = <LocationPoint>[];
    final b = <LocationPoint>[];
    final ca = Completer<void>();
    final cb = Completer<void>();
    final sa = s.arrivals.listen((p) {
      a.add(p);
      ca.complete();
    });
    final sb = s.arrivals.listen((p) {
      b.add(p);
      cb.complete();
    });
    s.injectArrival(LocationPoint(
      latitude: 1,
      longitude: 2,
      timestamp: DateTime.utc(2026),
    ));
    await Future.wait([ca.future, cb.future]);
    check(a.length).equals(1);
    check(b.length).equals(1);
    await sa.cancel();
    await sb.cancel();
    s.dispose();
  });
}
