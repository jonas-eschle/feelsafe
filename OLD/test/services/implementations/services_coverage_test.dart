/// Fills remaining coverage gaps in `lib/services/implementations/*`
/// by mocking third-party plugin channels (url_launcher, vibration,
/// home_widget, geolocator, battery_plus) on the Linux test host.
library;

import 'package:checks/checks.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/platform/platform_info.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/services/implementations/battery_monitor_service.dart';
import 'package:guardianangela/services/implementations/geofence_service.dart';
import 'package:guardianangela/services/implementations/hardware_button_service.dart';
import 'package:guardianangela/services/implementations/home_widget_service.dart';
import 'package:guardianangela/services/implementations/incoming_call_service.dart';
import 'package:guardianangela/services/implementations/location_service.dart';
import 'package:guardianangela/services/implementations/messaging_service.dart';
import 'package:guardianangela/services/implementations/phone_service.dart';
import 'package:guardianangela/services/implementations/vibration_service.dart';
import 'package:guardianangela/services/protocols/messaging_service_protocol.dart';

import 'channel_test_utils.dart';

/// Convenience handle to the static `defaultBinaryMessenger` used to
/// post synthetic platform messages.
T _binaryMessenger<T>(T Function(TestDefaultBinaryMessenger bm) body) =>
    body(TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger);

/// Installs a mock responder for the url_launcher v3 channel. Every
/// `canLaunch` call resolves to `canLaunch`; every `launch` resolves
/// to `launchResult`.
List<MethodCall> installUrlLauncherMock({
  bool canLaunch = true,
  bool launchResult = true,
}) {
  const ch = MethodChannel('plugins.flutter.io/url_launcher_linux');
  const ios = MethodChannel('plugins.flutter.io/url_launcher_ios');
  const android = MethodChannel('plugins.flutter.io/url_launcher_android');
  const fallback = MethodChannel('plugins.flutter.io/url_launcher');
  final all = <MethodCall>[];
  for (final c in [ch, ios, android, fallback]) {
    installMethodChannelMock(c, responder: (call) {
      all.add(call);
      if (call.method == 'canLaunch') return canLaunch;
      if (call.method == 'launch') return launchResult;
      if (call.method == 'supportsMode') return true;
      if (call.method == 'supportsCloseForMode') return true;
      return null;
    });
  }
  return all;
}

EmergencyContact _contact({
  String id = 'c1',
  String phone = '+15551234567',
  List<MessageChannel> channels = const [MessageChannel.sms],
}) =>
    EmergencyContact(
      id: id,
      name: 'Alice',
      phoneNumber: phone,
      sortOrder: 0,
      channels: channels,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // --------------------------------------------------------------------
  // MessagingService: WhatsApp, Telegram, iOS SMS handoff (success + fail)
  // --------------------------------------------------------------------
  group('MessagingService url_launcher branches', () {
    const smsChannel = MethodChannel('com.guardianangela.app/sms');

    test('WhatsApp success → handoff update', () async {
      installMethodChannelMock(smsChannel);
      installUrlLauncherMock();
      final s = MessagingService(platform: const FakePlatformInfo());
      final fut = s.deliveryUpdates.first;
      await s.sendMessage(
        contact: _contact(channels: const [MessageChannel.whatsapp]),
        message: 'hi',
        channel: MessageChannel.whatsapp,
      );
      final u = await fut;
      check(u.status).equals('handoff');
      await s.dispose();
    });

    test('WhatsApp failure → failed update', () async {
      installMethodChannelMock(smsChannel);
      installUrlLauncherMock(launchResult: false);
      final s = MessagingService(platform: const FakePlatformInfo());
      final fut = s.deliveryUpdates.first;
      await s.sendMessage(
        contact: _contact(channels: const [MessageChannel.whatsapp]),
        message: 'hi',
        channel: MessageChannel.whatsapp,
      );
      final u = await fut;
      check(u.status).equals('failed');
      await s.dispose();
    });

    test('Telegram success → handoff update', () async {
      installMethodChannelMock(smsChannel);
      installUrlLauncherMock();
      final s = MessagingService(platform: const FakePlatformInfo());
      final fut = s.deliveryUpdates.first;
      await s.sendMessage(
        contact: _contact(channels: const [MessageChannel.telegram]),
        message: 'hi',
        channel: MessageChannel.telegram,
      );
      final u = await fut;
      check(u.status).equals('handoff');
      await s.dispose();
    });

    test('Telegram failure → failed update', () async {
      installMethodChannelMock(smsChannel);
      installUrlLauncherMock(launchResult: false);
      final s = MessagingService(platform: const FakePlatformInfo());
      final fut = s.deliveryUpdates.first;
      await s.sendMessage(
        contact: _contact(channels: const [MessageChannel.telegram]),
        message: 'hi',
        channel: MessageChannel.telegram,
      );
      final u = await fut;
      check(u.status).equals('failed');
      await s.dispose();
    });

    test('iOS SMS → handoff (success)', () async {
      installMethodChannelMock(smsChannel);
      installUrlLauncherMock();
      final s = MessagingService(
        platform: const FakePlatformInfo(isIOS: true),
      );
      final fut = s.deliveryUpdates.first;
      await s.sendMessage(
        contact: _contact(),
        message: 'hi',
        channel: MessageChannel.sms,
      );
      final u = await fut;
      check(u.status).equals('handoff');
      await s.dispose();
    });

    test('iOS SMS → failed (launch=false)', () async {
      installMethodChannelMock(smsChannel);
      installUrlLauncherMock(launchResult: false);
      final s = MessagingService(
        platform: const FakePlatformInfo(isIOS: true),
      );
      final fut = s.deliveryUpdates.first;
      await s.sendMessage(
        contact: _contact(),
        message: 'hi',
        channel: MessageChannel.sms,
      );
      final u = await fut;
      check(u.status).equals('failed');
      await s.dispose();
    });

    test('Android: event-channel error callback path fires no update',
        () async {
      const eventChannel =
          EventChannel('com.guardianangela.app/sms_events');
      final mock = installEventChannelMock(eventChannel);
      installMethodChannelMock(smsChannel);
      final s = MessagingService(
        platform: const FakePlatformInfo(isAndroid: true),
      );
      final received = <MessageDeliveryUpdate>[];
      final sub = s.deliveryUpdates.listen(received.add);
      // Simulate an error on the native stream via binary messenger.
      final emc = MethodChannel(eventChannel.name, eventChannel.codec);
      await _binaryMessenger((bm) {
        return bm.handlePlatformMessage(
          emc.name,
          const StandardMethodCodec()
              .encodeErrorEnvelope(code: 'E', message: 'native err'),
          (_) {},
        );
      });
      await Future<void>.delayed(Duration.zero);
      check(received).isEmpty();
      await sub.cancel();
      // Keep mock referenced so lints don't trigger.
      check(mock).isNotNull();
      await s.dispose();
    });

    test('dispose called twice is safe (idempotent)', () async {
      installMethodChannelMock(smsChannel);
      final s = MessagingService();
      await s.dispose();
      await s.dispose();
    });
  });

  // --------------------------------------------------------------------
  // PhoneService: url_launcher fallback on non-Android (success + fail)
  // --------------------------------------------------------------------
  group('PhoneService url_launcher fallback', () {
    test('non-Android: url_launcher succeeds → no exception', () async {
      installUrlLauncherMock();
      final s = PhoneService(platform: const FakePlatformInfo());
      await s.call('+1234567890');
      await s.callEmergency('112');
    });

    test('non-Android: url_launcher launch=false → StateError', () async {
      installUrlLauncherMock(launchResult: false);
      final s = PhoneService(platform: const FakePlatformInfo());
      await check(s.call('+1234')).throws<StateError>();
    });
  });

  // --------------------------------------------------------------------
  // VibrationService
  // --------------------------------------------------------------------
  group('VibrationService', () {
    const channel = MethodChannel('vibration');

    test('alarmPattern(isSimulation:true) is a no-op', () async {
      final calls = installMethodChannelMock(channel);
      await VibrationService().alarmPattern(isSimulation: true);
      check(calls).isEmpty();
    });

    test('warningPattern(isSimulation:true) is a no-op', () async {
      final calls = installMethodChannelMock(channel);
      await VibrationService().warningPattern(isSimulation: true);
      check(calls).isEmpty();
    });

    test('fakeCallPattern(isSimulation:true) is a no-op', () async {
      final calls = installMethodChannelMock(channel);
      await VibrationService().fakeCallPattern(isSimulation: true);
      check(calls).isEmpty();
    });

    // Note: the vibration plugin's `hasVibrator()` is implemented in
    // pure Dart and short-circuits on `Platform.isAndroid`/`.isIOS`.
    // On Linux the method never dispatches through the MethodChannel,
    // so the `Vibration.vibrate(...)` body is unreachable from the
    // host. The alarm/warning/fakeCall real paths therefore remain
    // covered only via Android instrumentation tests.
    test('alarmPattern real path on non-physical device is a no-op',
        () async {
      final calls = installMethodChannelMock(channel);
      await VibrationService().alarmPattern();
      // On Linux the plugin short-circuits before dispatching.
      check(calls.where((c) => c.method == 'vibrate')).isEmpty();
    });

    test('warningPattern real path on non-physical device is a no-op',
        () async {
      final calls = installMethodChannelMock(channel);
      await VibrationService().warningPattern();
      check(calls.where((c) => c.method == 'vibrate')).isEmpty();
    });

    test('fakeCallPattern real path on non-physical device is a no-op',
        () async {
      final calls = installMethodChannelMock(channel);
      await VibrationService().fakeCallPattern();
      check(calls.where((c) => c.method == 'vibrate')).isEmpty();
    });

    test('stop cancels vibration', () async {
      final calls = installMethodChannelMock(channel);
      await VibrationService().stop();
      check(calls).which((it) => it.length.equals(1));
      check(calls.first.method).equals('cancel');
    });
  });

  // --------------------------------------------------------------------
  // HomeWidgetService
  // --------------------------------------------------------------------
  group('HomeWidgetService', () {
    const channel = MethodChannel('home_widget');

    test('updateStatus writes data and triggers widget refresh',
        () async {
      final calls = installMethodChannelMock(channel);
      await HomeWidgetService().updateStatus(
        status: 'armed',
        modeName: 'Walk Mode',
        isRunning: true,
      );
      final methods = calls.map((c) => c.method).toList();
      check(methods).contains('saveWidgetData');
      check(methods).contains('updateWidget');
    });

    test('writeLastMarker saves under the marker key', () async {
      final calls = installMethodChannelMock(channel);
      await HomeWidgetService().writeLastMarker('m1');
      final save = calls.firstWhere((c) => c.method == 'saveWidgetData');
      final args = save.arguments as Map;
      check(args['id']).equals('ga_last_marker');
      check(args['data']).equals('m1');
    });

    test('consumePendingMarker returns null when absent', () async {
      installMethodChannelMock(channel, responder: (c) {
        if (c.method == 'getWidgetData') return null;
        return null;
      });
      final m = await HomeWidgetService().consumePendingMarker();
      check(m).isNull();
    });

    test('consumePendingMarker returns & clears stored value',
        () async {
      final calls = installMethodChannelMock(channel, responder: (c) {
        if (c.method == 'getWidgetData') return 'pending!';
        return null;
      });
      final m = await HomeWidgetService().consumePendingMarker();
      check(m).equals('pending!');
      // Second saveWidgetData call resets to null.
      final saves =
          calls.where((c) => c.method == 'saveWidgetData').toList();
      check(saves).which((it) => it.length.equals(1));
      check((saves.first.arguments as Map)['data']).isNull();
    });

    test('registerInteractivity does not throw', () async {
      installMethodChannelMock(channel);
      await HomeWidgetService().registerInteractivity((Uri? _) {});
    });

    test('initiallyLaunchedUri returns null when not available',
        () async {
      installMethodChannelMock(channel);
      final u = await HomeWidgetService().initiallyLaunchedUri();
      check(u).isNull();
    });
  });

  // --------------------------------------------------------------------
  // HardwareButtonService: native event stream error-path
  // --------------------------------------------------------------------
  group('HardwareButtonService native error path', () {
    const methodChannel =
        MethodChannel('com.guardianangela.app/hardware_buttons');
    const eventChannel =
        EventChannel('com.guardianangela.app/hardware_button_events');

    test('stream error is logged, does not crash', () async {
      installMethodChannelMock(methodChannel);
      final emc = MethodChannel(eventChannel.name, eventChannel.codec);
      installMethodChannelMock(emc, responder: (c) {
        if (c.method == 'listen') return null;
        return null;
      });
      final s = HardwareButtonService();
      await s.start(buttonType: 'v', pattern: 'p');
      await _binaryMessenger((bm) => bm.handlePlatformMessage(
            emc.name,
            const StandardMethodCodec()
                .encodeErrorEnvelope(code: 'x', message: 'y'),
            (_) {},
          ));
      await Future<void>.delayed(Duration.zero);
      await s.dispose();
    });
  });

  // --------------------------------------------------------------------
  // IncomingCallService native error path
  // --------------------------------------------------------------------
  group('IncomingCallService native error path', () {
    const methodChannel =
        MethodChannel('com.guardianangela.app/call_state');
    const eventChannel =
        EventChannel('com.guardianangela.app/call_state_events');

    test('stream error is logged, does not crash', () async {
      installMethodChannelMock(methodChannel);
      final emc = MethodChannel(eventChannel.name, eventChannel.codec);
      installMethodChannelMock(emc, responder: (c) => null);
      final s = IncomingCallService();
      await s.startListening();
      await _binaryMessenger((bm) => bm.handlePlatformMessage(
            emc.name,
            const StandardMethodCodec()
                .encodeErrorEnvelope(code: 'x', message: 'y'),
            (_) {},
          ));
      await Future<void>.delayed(Duration.zero);
      await s.dispose();
    });
  });

  // --------------------------------------------------------------------
  // BatteryMonitorService platform-error path
  // --------------------------------------------------------------------
  group('BatteryMonitorService error paths', () {
    const channel = MethodChannel('dev.fluttercommunity.plus/battery');

    test('invalid threshold is rejected', () async {
      final s = BatteryMonitorService();
      await check(s.startMonitoring(thresholdPercent: -1))
          .throws<ArgumentError>();
      await check(s.startMonitoring(thresholdPercent: 101))
          .throws<ArgumentError>();
    });

    test('startMonitoring sets isActive true, stopMonitoring clears',
        () async {
      installMethodChannelMock(channel, responder: (c) {
        if (c.method == 'getBatteryLevel') return 80;
        return null;
      });
      final s = BatteryMonitorService();
      check(s.isActive).isFalse();
      await s.startMonitoring(thresholdPercent: 20);
      check(s.isActive).isTrue();
      await s.stopMonitoring();
      check(s.isActive).isFalse();
    });
  });

  // --------------------------------------------------------------------
  // GeofenceService & LocationService basic paths (no platform branch)
  // --------------------------------------------------------------------
  group('GeofenceService register / remove', () {
    test('removeGeofence clears state even when no register', () async {
      final g = GeofenceService();
      await g.removeGeofence();
      await g.dispose();
    });
  });

  group('LocationService basic lifecycle', () {
    test('clearHistory empties the FIFO; getLast* returns null', () {
      final l = LocationService();
      check(l.history).isEmpty();
      check(l.getLastLocationUrl()).isNull();
      check(l.getLastLocationPoint()).isNull();
      l.clearHistory();
      check(l.history).isEmpty();
    });

    test('stopTracking with no subscription is a no-op', () async {
      await LocationService().stopTracking();
    });
  });
}
