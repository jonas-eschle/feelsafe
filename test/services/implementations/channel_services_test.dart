/// Tests for the method-channel-backed real services.
///
/// NOTE: `flutter test` on CI runs on the host OS (Linux / macOS /
/// Windows), so `Platform.isAndroid` is false. Android-only paths
/// (every branch guarded by `if (!Platform.isAndroid) return ...`)
/// short-circuit and never reach the channel. These tests assert the
/// non-Android contract for those services; channel-heavy services
/// (hardware_button, incoming_call, messaging) have no OS guard and
/// are exercised normally.
library;

import 'package:checks/checks.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/models/stealth_config.dart';
import 'package:guardianangela/services/implementations/device_state_service.dart';
import 'package:guardianangela/services/implementations/hardware_button_service.dart';
import 'package:guardianangela/services/implementations/incoming_call_service.dart';
import 'package:guardianangela/services/implementations/phone_service.dart';
import 'package:guardianangela/services/implementations/stealth_icon_service.dart';
import 'package:guardianangela/services/implementations/system_ui_service.dart';
import 'package:guardianangela/services/protocols/hardware_button_service_protocol.dart';
import 'package:guardianangela/services/protocols/incoming_call_service_protocol.dart';

import 'channel_test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceStateService (non-Android host — short-circuits)', () {
    test('isDndOn returns false on non-Android without touching channel',
        () async {
      const channel = MethodChannel('com.guardianangela.app/device_state');
      final calls = installMethodChannelMock(channel);
      final s = DeviceStateService();
      check(await s.isDndOn()).isFalse();
      check(await s.isSilent()).isFalse();
      check(calls).isEmpty();
    });
  });

  group('HardwareButtonService', () {
    const methodChannel =
        MethodChannel('com.guardianangela.app/hardware_buttons');
    const eventChannel =
        EventChannel('com.guardianangela.app/hardware_button_events');

    test('start passes correct args and sets listening=true', () async {
      final methodCalls = installMethodChannelMock(methodChannel);
      installEventChannelMock(eventChannel);
      final s = HardwareButtonService();
      check(s.isListening).isFalse();
      await s.start(
        buttonType: 'volume',
        pattern: '5x_press',
        pressCount: 7,
        pressWindowMs: 700,
        longPressDurationSeconds: 3.5,
      );
      check(s.isListening).isTrue();
      check(methodCalls).which((it) => it.length.equals(1));
      final arg = methodCalls.first.arguments as Map<Object?, Object?>;
      check(arg['buttonType']).equals('volume');
      check(arg['pattern']).equals('5x_press');
      check(arg['pressCount']).equals(7);
      check(arg['pressWindowMs']).equals(700);
      check(arg['longPressDurationSeconds']).equals(3.5);
      await s.dispose();
    });

    test('start is idempotent when already listening', () async {
      final calls = installMethodChannelMock(methodChannel);
      installEventChannelMock(eventChannel);
      final s = HardwareButtonService();
      await s.start(buttonType: 'v', pattern: 'p');
      await s.start(buttonType: 'v', pattern: 'p');
      check(calls.length).equals(1);
      await s.dispose();
    });

    test('start surfaces "Not wired — Phase 10" on MissingPluginException',
        () async {
      installMissingPluginMock(methodChannel);
      installEventChannelMock(eventChannel);
      final s = HardwareButtonService();
      await check(s.start(buttonType: 'v', pattern: 'p')).throws<Object>();
      check(s.isListening).isFalse();
      await s.dispose();
    });

    test('start rethrows PlatformException', () async {
      installPlatformErrorMock(methodChannel);
      installEventChannelMock(eventChannel);
      final s = HardwareButtonService();
      await check(s.start(buttonType: 'v', pattern: 'p'))
          .throws<PlatformException>();
      await s.dispose();
    });

    test('stop invokes native and clears listening', () async {
      final calls = installMethodChannelMock(methodChannel);
      installEventChannelMock(eventChannel);
      final s = HardwareButtonService();
      await s.start(buttonType: 'v', pattern: 'p');
      await s.stop();
      check(s.isListening).isFalse();
      check(calls.map((c) => c.method).toList())
          .deepEquals(['start', 'stop']);
      await s.dispose();
    });

    test('stop tolerates MissingPluginException', () async {
      installMissingPluginMock(methodChannel);
      installEventChannelMock(eventChannel);
      final s = HardwareButtonService();
      await s.stop();
      check(s.isListening).isFalse();
      await s.dispose();
    });

    test('stop logs PlatformException without rethrow', () async {
      installPlatformErrorMock(methodChannel);
      installEventChannelMock(eventChannel);
      final s = HardwareButtonService();
      await s.stop();
      check(s.isListening).isFalse();
      await s.dispose();
    });

    test('native event is parsed into HardwarePanicEvent', () async {
      installMethodChannelMock(methodChannel);
      final mock = installEventChannelMock(eventChannel);
      final s = HardwareButtonService();
      await s.start(buttonType: 'volume', pattern: '5x_press');
      final fut = s.panicEvents.first;
      await mock.push({
        'buttonType': 'volume',
        'pattern': '5x_press',
        'timestampMs': 1000,
      });
      final event = await fut;
      check(event.buttonType).equals('volume');
      check(event.pattern).equals('5x_press');
      check(event.timestamp.millisecondsSinceEpoch).equals(1000);
      await s.dispose();
    });

    test('native event with missing fields uses defaults', () async {
      installMethodChannelMock(methodChannel);
      final mock = installEventChannelMock(eventChannel);
      final s = HardwareButtonService();
      await s.start(buttonType: 'volume', pattern: '5x_press');
      final fut = s.panicEvents.first;
      await mock.push(<String, Object?>{});
      final e = await fut;
      check(e.buttonType).equals('unknown');
      check(e.pattern).equals('unknown');
      await s.dispose();
    });

    test('non-map native events are ignored', () async {
      installMethodChannelMock(methodChannel);
      final mock = installEventChannelMock(eventChannel);
      final s = HardwareButtonService();
      final events = <HardwarePanicEvent>[];
      final sub = s.panicEvents.listen(events.add);
      await s.start(buttonType: 'v', pattern: 'p');
      await mock.push('not-a-map');
      await Future<void>.delayed(Duration.zero);
      check(events).isEmpty();
      await sub.cancel();
      await s.dispose();
    });

    test('dispose is idempotent', () async {
      installMethodChannelMock(methodChannel);
      installEventChannelMock(eventChannel);
      final s = HardwareButtonService();
      await s.dispose();
      await s.dispose();
    });
  });

  group('IncomingCallService', () {
    const methodChannel =
        MethodChannel('com.guardianangela.app/call_state');
    const eventChannel =
        EventChannel('com.guardianangela.app/call_state_events');

    test('startListening invokes start and is idempotent', () async {
      final calls = installMethodChannelMock(methodChannel);
      installEventChannelMock(eventChannel);
      final s = IncomingCallService();
      await s.startListening();
      await s.startListening();
      check(calls.length).equals(1);
      check(calls.first.method).equals('start');
      await s.dispose();
    });

    test('startListening surfaces Phase 10 error on missing plugin',
        () async {
      installMissingPluginMock(methodChannel);
      installEventChannelMock(eventChannel);
      final s = IncomingCallService();
      await check(s.startListening()).throws<Object>();
      await s.dispose();
    });

    test('startListening rethrows PlatformException', () async {
      installPlatformErrorMock(methodChannel);
      installEventChannelMock(eventChannel);
      final s = IncomingCallService();
      await check(s.startListening()).throws<PlatformException>();
      await s.dispose();
    });

    test('stopListening cancels native side', () async {
      final calls = installMethodChannelMock(methodChannel);
      installEventChannelMock(eventChannel);
      final s = IncomingCallService();
      await s.startListening();
      await s.stopListening();
      check(calls.map((c) => c.method).toList())
          .deepEquals(['start', 'stop']);
      await s.dispose();
    });

    test('stopListening tolerates MissingPluginException', () async {
      installMissingPluginMock(methodChannel);
      installEventChannelMock(eventChannel);
      final s = IncomingCallService();
      await s.stopListening();
      await s.dispose();
    });

    test('stopListening tolerates PlatformException', () async {
      installPlatformErrorMock(methodChannel);
      installEventChannelMock(eventChannel);
      final s = IncomingCallService();
      await s.stopListening();
      await s.dispose();
    });

    test('native strings are parsed into CallState', () async {
      installMethodChannelMock(methodChannel);
      final mock = installEventChannelMock(eventChannel);
      final s = IncomingCallService();
      await s.startListening();
      final received = <CallState>[];
      final sub = s.callState.listen(received.add);
      await mock.push('idle');
      await mock.push('ringing');
      await mock.push('active');
      await mock.push('ended');
      await mock.push('bogus'); // ignored
      await Future<void>.delayed(Duration.zero);
      check(received).deepEquals([
        CallState.idle,
        CallState.ringing,
        CallState.active,
        CallState.ended,
      ]);
      await sub.cancel();
      await s.dispose();
    });

    test('dispose is idempotent', () async {
      installMethodChannelMock(methodChannel);
      installEventChannelMock(eventChannel);
      final s = IncomingCallService();
      await s.dispose();
      await s.dispose();
    });
  });

  group('PhoneService (non-Android host — falls to url_launcher)', () {
    test('isSimulation=true short-circuits both methods', () async {
      const channel = MethodChannel('com.guardianangela.app/phone');
      final calls = installMethodChannelMock(channel);
      final s = PhoneService();
      await s.call('+1234', isSimulation: true);
      await s.callEmergency('112', isSimulation: true);
      check(calls).isEmpty();
    });

    test(
        'non-Android real call goes to url_launcher which throws '
        'in unit test harness', () async {
      // url_launcher throws MissingPluginException in pure Dart test harness.
      final s = PhoneService();
      await check(s.call('+1234')).throws<Object>();
      await check(s.callEmergency('112')).throws<Object>();
    });
  });

  group('StealthIconService (non-Android host — caches only)', () {
    test('setPreset caches preset; non-Android does not invoke channel',
        () async {
      const channel = MethodChannel('com.guardianangela.app/stealth_icon');
      final calls = installMethodChannelMock(channel);
      final s = StealthIconService();
      await s.setPreset(StealthIconPreset.music);
      check(calls).isEmpty();
      check(await s.getCurrentPreset()).equals(StealthIconPreset.music);
      await s.setPreset(StealthIconPreset.fitness);
      check(await s.getCurrentPreset()).equals(StealthIconPreset.fitness);
    });

    test('default cached preset is calendar', () async {
      final s = StealthIconService();
      check(await s.getCurrentPreset()).equals(StealthIconPreset.calendar);
    });
  });

  group('SystemUiService (non-Android host — short-circuits)', () {
    test('quickExit is a no-op on non-Android', () async {
      const channel = MethodChannel('com.guardianangela.app/system_ui');
      final calls = installMethodChannelMock(channel);
      final s = SystemUiService();
      await s.quickExit();
      await s.requestBatteryOptimizationExemption();
      check(await s.isBatteryOptimized()).isFalse();
      check(calls).isEmpty();
    });
  });
}
