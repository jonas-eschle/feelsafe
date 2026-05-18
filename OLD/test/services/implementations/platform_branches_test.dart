/// Exercises the Android and iOS platform branches of every
/// `lib/services/implementations/*` service that previously guarded
/// behavior behind `dart:io` `Platform.isAndroid`.
///
/// By injecting [FakePlatformInfo] into each service, Linux test hosts
/// can now reach what used to be host-only Android paths — raising
/// services-coverage from ~64 % toward ≥99 %.
library;

import 'package:checks/checks.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/platform/platform_info.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/stealth_config.dart';
import 'package:guardianangela/services/implementations/device_state_service.dart';
import 'package:guardianangela/services/implementations/messaging_service.dart';
import 'package:guardianangela/services/implementations/phone_service.dart';
import 'package:guardianangela/services/implementations/stealth_icon_service.dart';
import 'package:guardianangela/services/implementations/system_ui_service.dart';
import 'package:guardianangela/services/protocols/messaging_service_protocol.dart';

import 'channel_test_utils.dart';

const _android = FakePlatformInfo(isAndroid: true);
const _ios = FakePlatformInfo(isIOS: true);
const _none = FakePlatformInfo();

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
  // PlatformInfo + FakePlatformInfo
  // --------------------------------------------------------------------
  group('PlatformInfo', () {
    test('const production PlatformInfo() is constructible', () {
      const p = PlatformInfo();
      // Linux test host: neither flag is true.
      check(p.isAndroid).isFalse();
      check(p.isIOS).isFalse();
    });

    test('FakePlatformInfo defaults to neither Android nor iOS', () {
      const p = FakePlatformInfo();
      check(p.isAndroid).isFalse();
      check(p.isIOS).isFalse();
    });

    test('FakePlatformInfo honours overrides', () {
      const android = FakePlatformInfo(isAndroid: true);
      const ios = FakePlatformInfo(isIOS: true);
      const both = FakePlatformInfo(isAndroid: true, isIOS: true);
      check(android.isAndroid).isTrue();
      check(android.isIOS).isFalse();
      check(ios.isAndroid).isFalse();
      check(ios.isIOS).isTrue();
      check(both.isAndroid).isTrue();
      check(both.isIOS).isTrue();
    });
  });

  // --------------------------------------------------------------------
  // DeviceStateService
  // --------------------------------------------------------------------
  group('DeviceStateService platform branches', () {
    const channel = MethodChannel('com.guardianangela.app/device_state');

    test('Android: isDndOn returns true from native', () async {
      final calls = installMethodChannelMock(
        channel,
        responder: (c) => c.method == 'isDndOn' ? true : null,
      );
      final s = DeviceStateService(platform: _android);
      check(await s.isDndOn()).isTrue();
      check(calls).which((it) => it.length.equals(1));
      check(calls.first.method).equals('isDndOn');
    });

    test('Android: isDndOn treats null result as false', () async {
      installMethodChannelMock(channel);
      final s = DeviceStateService(platform: _android);
      check(await s.isDndOn()).isFalse();
    });

    test('Android: isDndOn swallows MissingPluginException', () async {
      installMissingPluginMock(channel);
      final s = DeviceStateService(platform: _android);
      check(await s.isDndOn()).isFalse();
    });

    test('Android: isDndOn rethrows PlatformException', () async {
      installPlatformErrorMock(channel);
      final s = DeviceStateService(platform: _android);
      await check(s.isDndOn()).throws<PlatformException>();
    });

    test('Android: isSilent returns native bool', () async {
      installMethodChannelMock(
        channel,
        responder: (c) => c.method == 'isSilent' ? true : null,
      );
      final s = DeviceStateService(platform: _android);
      check(await s.isSilent()).isTrue();
    });

    test('Android: isSilent treats null as false', () async {
      installMethodChannelMock(channel);
      final s = DeviceStateService(platform: _android);
      check(await s.isSilent()).isFalse();
    });

    test('Android: isSilent swallows MissingPluginException', () async {
      installMissingPluginMock(channel);
      final s = DeviceStateService(platform: _android);
      check(await s.isSilent()).isFalse();
    });

    test('Android: isSilent rethrows PlatformException', () async {
      installPlatformErrorMock(channel);
      final s = DeviceStateService(platform: _android);
      await check(s.isSilent()).throws<PlatformException>();
    });

    test('iOS: isDndOn/isSilent short-circuit to false', () async {
      final calls = installMethodChannelMock(channel);
      final s = DeviceStateService(platform: _ios);
      check(await s.isDndOn()).isFalse();
      check(await s.isSilent()).isFalse();
      check(calls).isEmpty();
    });

    test('default (non-Android/iOS) short-circuits', () async {
      final calls = installMethodChannelMock(channel);
      final s = DeviceStateService(platform: _none);
      check(await s.isDndOn()).isFalse();
      check(await s.isSilent()).isFalse();
      check(calls).isEmpty();
    });
  });

  // --------------------------------------------------------------------
  // SystemUiService
  // --------------------------------------------------------------------
  group('SystemUiService platform branches', () {
    const channel = MethodChannel('com.guardianangela.app/system_ui');

    test('Android: quickExit invokes native', () async {
      final calls = installMethodChannelMock(channel);
      final s = SystemUiService(platform: _android);
      await s.quickExit();
      check(calls).which((it) => it.length.equals(1));
      check(calls.first.method).equals('quickExit');
    });

    test('Android: quickExit surfaces MissingPluginException', () async {
      installMissingPluginMock(channel);
      final s = SystemUiService(platform: _android);
      await check(s.quickExit()).throws<Object>();
    });

    test('Android: quickExit rethrows PlatformException', () async {
      installPlatformErrorMock(channel);
      final s = SystemUiService(platform: _android);
      await check(s.quickExit()).throws<PlatformException>();
    });

    test('Android: requestBatteryOptimizationExemption invokes native',
        () async {
      final calls = installMethodChannelMock(channel);
      final s = SystemUiService(platform: _android);
      await s.requestBatteryOptimizationExemption();
      check(calls.first.method)
          .equals('requestBatteryOptimizationExemption');
    });

    test('Android: requestBatteryOptimizationExemption surfaces missing',
        () async {
      installMissingPluginMock(channel);
      final s = SystemUiService(platform: _android);
      await check(s.requestBatteryOptimizationExemption())
          .throws<Object>();
    });

    test('Android: requestBatteryOptimizationExemption rethrows platform err',
        () async {
      installPlatformErrorMock(channel);
      final s = SystemUiService(platform: _android);
      await check(s.requestBatteryOptimizationExemption())
          .throws<PlatformException>();
    });

    test('Android: isBatteryOptimized returns native bool', () async {
      installMethodChannelMock(
        channel,
        responder: (c) =>
            c.method == 'isBatteryOptimized' ? true : null,
      );
      final s = SystemUiService(platform: _android);
      check(await s.isBatteryOptimized()).isTrue();
    });

    test('Android: isBatteryOptimized null → false', () async {
      installMethodChannelMock(channel);
      final s = SystemUiService(platform: _android);
      check(await s.isBatteryOptimized()).isFalse();
    });

    test('Android: isBatteryOptimized swallows MissingPluginException',
        () async {
      installMissingPluginMock(channel);
      final s = SystemUiService(platform: _android);
      check(await s.isBatteryOptimized()).isFalse();
    });

    test('Android: isBatteryOptimized rethrows PlatformException',
        () async {
      installPlatformErrorMock(channel);
      final s = SystemUiService(platform: _android);
      await check(s.isBatteryOptimized()).throws<PlatformException>();
    });

    test('iOS: every method is a no-op / false', () async {
      final calls = installMethodChannelMock(channel);
      final s = SystemUiService(platform: _ios);
      await s.quickExit();
      await s.requestBatteryOptimizationExemption();
      check(await s.isBatteryOptimized()).isFalse();
      check(calls).isEmpty();
    });

    test('default (Linux) is a no-op / false', () async {
      final calls = installMethodChannelMock(channel);
      final s = SystemUiService(platform: _none);
      await s.quickExit();
      await s.requestBatteryOptimizationExemption();
      check(await s.isBatteryOptimized()).isFalse();
      check(calls).isEmpty();
    });
  });

  // --------------------------------------------------------------------
  // StealthIconService
  // --------------------------------------------------------------------
  group('StealthIconService platform branches', () {
    const channel = MethodChannel('com.guardianangela.app/stealth_icon');

    test('Android: setPreset invokes native with enum name', () async {
      final calls = installMethodChannelMock(channel);
      final s = StealthIconService(platform: _android);
      await s.setPreset(StealthIconPreset.music);
      check(calls.first.method).equals('setPreset');
      check((calls.first.arguments as Map)['preset']).equals('music');
    });

    test('Android: setPreset surfaces MissingPluginException', () async {
      installMissingPluginMock(channel);
      final s = StealthIconService(platform: _android);
      await check(s.setPreset(StealthIconPreset.fitness)).throws<Object>();
    });

    test('Android: setPreset rethrows PlatformException', () async {
      installPlatformErrorMock(channel);
      final s = StealthIconService(platform: _android);
      await check(s.setPreset(StealthIconPreset.weather))
          .throws<PlatformException>();
    });

    test('Android: getCurrentPreset returns native string parsed to enum',
        () async {
      installMethodChannelMock(
        channel,
        responder: (c) => c.method == 'getCurrentPreset' ? 'notes' : null,
      );
      final s = StealthIconService(platform: _android);
      check(await s.getCurrentPreset()).equals(StealthIconPreset.notes);
    });

    test('Android: getCurrentPreset null → cached default', () async {
      installMethodChannelMock(channel);
      final s = StealthIconService(platform: _android);
      check(await s.getCurrentPreset()).equals(StealthIconPreset.calendar);
    });

    test('Android: getCurrentPreset unknown string → cached default',
        () async {
      installMethodChannelMock(
        channel,
        responder: (c) =>
            c.method == 'getCurrentPreset' ? 'not-a-real-preset' : null,
      );
      final s = StealthIconService(platform: _android);
      check(await s.getCurrentPreset()).equals(StealthIconPreset.calendar);
    });

    test('Android: getCurrentPreset MissingPluginException → cached',
        () async {
      installMissingPluginMock(channel);
      final s = StealthIconService(platform: _android);
      await s.setPreset(StealthIconPreset.photos).catchError((_) {});
      check(await s.getCurrentPreset()).equals(StealthIconPreset.photos);
    });

    test('Android: getCurrentPreset PlatformException → cached', () async {
      installPlatformErrorMock(channel);
      final s = StealthIconService(platform: _android);
      // setPreset will throw but update cache first.
      await check(s.setPreset(StealthIconPreset.clock))
          .throws<PlatformException>();
      check(await s.getCurrentPreset()).equals(StealthIconPreset.clock);
    });

    test(
        'Android: getCurrentPreset parses every valid preset name from native',
        () async {
      for (final preset in StealthIconPreset.values) {
        installMethodChannelMock(
          channel,
          responder: (c) =>
              c.method == 'getCurrentPreset' ? preset.name : null,
        );
        final s = StealthIconService(platform: _android);
        check(await s.getCurrentPreset()).equals(preset);
      }
    });

    test('iOS: setPreset caches only, never calls native', () async {
      final calls = installMethodChannelMock(channel);
      final s = StealthIconService(platform: _ios);
      await s.setPreset(StealthIconPreset.weather);
      check(calls).isEmpty();
      check(await s.getCurrentPreset()).equals(StealthIconPreset.weather);
    });

    test('default (Linux) caches only', () async {
      final calls = installMethodChannelMock(channel);
      final s = StealthIconService(platform: _none);
      await s.setPreset(StealthIconPreset.news);
      check(calls).isEmpty();
      check(await s.getCurrentPreset()).equals(StealthIconPreset.news);
    });
  });

  // --------------------------------------------------------------------
  // PhoneService
  // --------------------------------------------------------------------
  group('PhoneService platform branches', () {
    const channel = MethodChannel('com.guardianangela.app/phone');

    test('Android: call invokes native with isEmergency=false', () async {
      final calls = installMethodChannelMock(channel);
      final s = PhoneService(platform: _android);
      await s.call('+1234567890');
      check(calls).which((it) => it.length.equals(1));
      check(calls.first.method).equals('call');
      final args = calls.first.arguments as Map;
      check(args['number']).equals('+1234567890');
      check(args['isEmergency']).equals(false);
    });

    test('Android: callEmergency invokes native with isEmergency=true',
        () async {
      final calls = installMethodChannelMock(channel);
      final s = PhoneService(platform: _android);
      await s.callEmergency('112');
      check(calls.first.method).equals('call');
      final args = calls.first.arguments as Map;
      check(args['isEmergency']).equals(true);
    });

    test('Android: call(isSimulation:true) is a no-op', () async {
      final calls = installMethodChannelMock(channel);
      final s = PhoneService(platform: _android);
      await s.call('+1', isSimulation: true);
      await s.callEmergency('112', isSimulation: true);
      check(calls).isEmpty();
    });

    test(
        'Android: MissingPluginException falls back to tel: URI '
        '(which fails in test harness)', () async {
      installMissingPluginMock(channel);
      final s = PhoneService(platform: _android);
      await check(s.call('+1234')).throws<Object>();
    });

    test(
        'Android: PlatformException falls back to tel: URI '
        '(which fails in test harness)', () async {
      installPlatformErrorMock(channel);
      final s = PhoneService(platform: _android);
      await check(s.call('+1234')).throws<Object>();
    });

    test('iOS: skips native channel, goes straight to tel: URI',
        () async {
      final calls = installMethodChannelMock(channel);
      final s = PhoneService(platform: _ios);
      // url_launcher is unwired on the test host and throws.
      await check(s.call('+1234')).throws<Object>();
      check(calls).isEmpty();
    });

    test('iOS: callEmergency likewise skips native', () async {
      final calls = installMethodChannelMock(channel);
      final s = PhoneService(platform: _ios);
      await check(s.callEmergency('112')).throws<Object>();
      check(calls).isEmpty();
    });
  });

  // --------------------------------------------------------------------
  // MessagingService
  // --------------------------------------------------------------------
  group('MessagingService platform branches', () {
    const smsChannel = MethodChannel('com.guardianangela.app/sms');

    test('Android: canAutoSend(sms) is true', () async {
      final s = MessagingService(platform: _android);
      check(await s.canAutoSend(MessageChannel.sms)).isTrue();
      check(await s.canAutoSend(MessageChannel.whatsapp)).isFalse();
      check(await s.canAutoSend(MessageChannel.telegram)).isFalse();
      check(await s.canAutoSend(MessageChannel.phoneCall)).isFalse();
      await s.dispose();
    });

    test('iOS: canAutoSend is always false', () async {
      final s = MessagingService(platform: _ios);
      for (final c in MessageChannel.values) {
        check(await s.canAutoSend(c)).isFalse();
      }
      await s.dispose();
    });

    test('default: canAutoSend is always false', () async {
      final s = MessagingService(platform: _none);
      for (final c in MessageChannel.values) {
        check(await s.canAutoSend(c)).isFalse();
      }
      await s.dispose();
    });

    test('Android: sendMessage(sms) invokes native send, emits queued',
        () async {
      final calls = installMethodChannelMock(smsChannel);
      final s = MessagingService(platform: _android);
      final updates = <MessageDeliveryUpdate>[];
      final sub = s.deliveryUpdates.listen(updates.add);
      final wid = await s.sendMessage(
        contact: _contact(),
        message: 'hi',
        channel: MessageChannel.sms,
      );
      await Future<void>.delayed(Duration.zero);
      final sendCall = calls.firstWhere((c) => c.method == 'send');
      final args = sendCall.arguments as Map;
      check(args['workId']).equals(wid.value);
      check(args['recipient']).equals('+15551234567');
      check(args['message']).equals('hi');
      check(updates.map((u) => u.status)).deepEquals(['queued']);
      await sub.cancel();
      await s.dispose();
    });

    test('Android: SMS send MissingPluginException surfaces Phase-10 error',
        () async {
      installMissingPluginMock(smsChannel);
      final s = MessagingService(platform: _android);
      await check(s.sendMessage(
        contact: _contact(),
        message: 'hi',
        channel: MessageChannel.sms,
      )).throws<Object>();
      await s.dispose();
    });

    test('Android: SMS send PlatformException is rethrown', () async {
      installPlatformErrorMock(smsChannel);
      final s = MessagingService(platform: _android);
      await check(s.sendMessage(
        contact: _contact(),
        message: 'hi',
        channel: MessageChannel.sms,
      )).throws<PlatformException>();
      await s.dispose();
    });

    test('iOS: SMS falls through to url_launcher (tel harness throws)',
        () async {
      final calls = installMethodChannelMock(smsChannel);
      final s = MessagingService(platform: _ios);
      await check(s.sendMessage(
        contact: _contact(),
        message: 'hi',
        channel: MessageChannel.sms,
      )).throws<Object>();
      check(calls.where((c) => c.method == 'send')).isEmpty();
      await s.dispose();
    });

    test('Android: retryExhaustedSms after successful send hits native',
        () async {
      final calls = installMethodChannelMock(smsChannel);
      final s = MessagingService(platform: _android);
      final wid = await s.sendMessage(
        contact: _contact(),
        message: 'bar',
        channel: MessageChannel.sms,
      );
      calls.clear();
      await s.retryExhaustedSms(wid.value);
      final retry = calls.firstWhere((c) => c.method == 'retry');
      final args = retry.arguments as Map;
      check(args['workId']).equals(wid.value);
      check(args['recipient']).equals('+15551234567');
      check(args['message']).equals('bar');
      await s.dispose();
    });

    test('Android: retryExhaustedSms MissingPluginException surfaces',
        () async {
      // Populate cache with a successful send, then swap the handler to
      // one that throws MissingPluginException.
      final calls = installMethodChannelMock(smsChannel);
      final s = MessagingService(platform: _android);
      final wid = await s.sendMessage(
        contact: _contact(),
        message: 'bar',
        channel: MessageChannel.sms,
      );
      calls.clear();
      // Re-install a missing-plugin handler for subsequent calls.
      installMissingPluginMock(smsChannel);
      await check(s.retryExhaustedSms(wid.value)).throws<Object>();
      await s.dispose();
    });

    test('Android: retryExhaustedSms PlatformException is rethrown',
        () async {
      installMethodChannelMock(smsChannel);
      final s = MessagingService(platform: _android);
      final wid = await s.sendMessage(
        contact: _contact(),
        message: 'bar',
        channel: MessageChannel.sms,
      );
      installPlatformErrorMock(smsChannel);
      await check(s.retryExhaustedSms(wid.value))
          .throws<PlatformException>();
      await s.dispose();
    });

    test('Android: native retry_exhausted event fires retry stream',
        () async {
      const eventChannel =
          EventChannel('com.guardianangela.app/sms_events');
      final mock = installEventChannelMock(eventChannel);
      installMethodChannelMock(smsChannel);
      final s = MessagingService(platform: _android);
      // Populate _pending via a successful send.
      final wid = await s.sendMessage(
        contact: _contact(phone: '+42', channels: const [MessageChannel.sms]),
        message: 'm',
        channel: MessageChannel.sms,
      );
      final fut = s.smsRetryExhausted.first;
      await mock.push({
        'type': 'retry_exhausted',
        'workId': wid.value,
      });
      final ev = await fut;
      check(ev.workId).equals(wid.value);
      check(ev.recipient).equals('+42');
      check(ev.message).equals('m');
      await s.dispose();
    });

    test('Android: native retry_exhausted for unknown workId uses blanks',
        () async {
      const eventChannel =
          EventChannel('com.guardianangela.app/sms_events');
      final mock = installEventChannelMock(eventChannel);
      installMethodChannelMock(smsChannel);
      final s = MessagingService(platform: _android);
      final fut = s.smsRetryExhausted.first;
      await mock.push({
        'type': 'retry_exhausted',
        'workId': 'never-seen',
      });
      final ev = await fut;
      check(ev.workId).equals('never-seen');
      check(ev.recipient).equals('');
      check(ev.message).equals('');
      await s.dispose();
    });

    test('Android: generic native event without workId is ignored',
        () async {
      const eventChannel =
          EventChannel('com.guardianangela.app/sms_events');
      final mock = installEventChannelMock(eventChannel);
      installMethodChannelMock(smsChannel);
      final s = MessagingService(platform: _android);
      final received = <MessageDeliveryUpdate>[];
      final sub = s.deliveryUpdates.listen(received.add);
      await mock.push({'type': 'queued'}); // no workId
      await Future<void>.delayed(Duration.zero);
      check(received).isEmpty();
      await sub.cancel();
      await s.dispose();
    });

    test('Android: generic native event with status emits delivery update',
        () async {
      const eventChannel =
          EventChannel('com.guardianangela.app/sms_events');
      final mock = installEventChannelMock(eventChannel);
      installMethodChannelMock(smsChannel);
      final s = MessagingService(platform: _android);
      final fut = s.deliveryUpdates.first;
      await mock.push({'workId': 'w1', 'status': 'sent'});
      final u = await fut;
      check(u.workId).equals('w1');
      check(u.status).equals('sent');
      await s.dispose();
    });

    test('Android: generic native event without explicit status falls '
        'back to type', () async {
      const eventChannel =
          EventChannel('com.guardianangela.app/sms_events');
      final mock = installEventChannelMock(eventChannel);
      installMethodChannelMock(smsChannel);
      final s = MessagingService(platform: _android);
      final fut = s.deliveryUpdates.first;
      await mock.push({'workId': 'w2', 'type': 'delivered'});
      final u = await fut;
      check(u.status).equals('delivered');
      await s.dispose();
    });

    test('Android: non-map native event is ignored', () async {
      const eventChannel =
          EventChannel('com.guardianangela.app/sms_events');
      final mock = installEventChannelMock(eventChannel);
      installMethodChannelMock(smsChannel);
      final s = MessagingService(platform: _android);
      final received = <MessageDeliveryUpdate>[];
      final sub = s.deliveryUpdates.listen(received.add);
      await mock.push('not-a-map');
      await Future<void>.delayed(Duration.zero);
      check(received).isEmpty();
      await sub.cancel();
      await s.dispose();
    });

    test('Android: event with no type or status defaults to "unknown"',
        () async {
      const eventChannel =
          EventChannel('com.guardianangela.app/sms_events');
      final mock = installEventChannelMock(eventChannel);
      installMethodChannelMock(smsChannel);
      final s = MessagingService(platform: _android);
      final fut = s.deliveryUpdates.first;
      await mock.push({'workId': 'w3'});
      final u = await fut;
      check(u.status).equals('unknown');
      await s.dispose();
    });

    test(
        'Android: subscribing to event channel swallows MissingPluginException',
        () async {
      const eventChannel =
          EventChannel('com.guardianangela.app/sms_events');
      final emc = MethodChannel(eventChannel.name, eventChannel.codec);
      installMissingPluginMock(emc);
      installMethodChannelMock(smsChannel);
      // Constructor subscribes eagerly; should not throw.
      final s = MessagingService(platform: _android);
      await s.dispose();
    });
  });
}
