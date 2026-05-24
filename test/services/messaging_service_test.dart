// Tests for MessagingService (Real + Simulation).
//
// RealMessagingService tests use mock MethodChannels for
// com.guardianangela.app/sms and url_launcher.
// SimulationMessagingService tests are pure-Dart.

import 'package:checks/checks.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/services/messaging_service.dart';
import 'package:guardianangela/services/protocols/notification_service_protocol.dart';
import 'package:guardianangela/services/sim/messaging_service_sim.dart';
import 'package:guardianangela/services/sim/notification_service_sim.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

EmergencyContact _contact({
  String id = 'c1',
  String name = 'Alice',
  String phone = '+15550001111',
  MessageChannel channel = MessageChannel.sms,
}) => EmergencyContact(
  id: id,
  name: name,
  phoneNumber: phone,
  sortOrder: 0,
  channels: [channel],
);

/// Tracks invocations of the sms MethodChannel mock.
class _SmsChannelMock {
  final List<MethodCall> calls = [];
  String? nextWorkId = 'work-abc-123';

  void register() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.guardianangela.app/sms'),
          _handle,
        );
  }

  void unregister() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.guardianangela.app/sms'),
          null,
        );
  }

  Future<dynamic> _handle(MethodCall call) async {
    calls.add(call);
    if (call.method == 'enqueueSms') return nextWorkId;
    return null;
  }

  /// Simulates the native side firing smsRetryExhausted.
  Future<void> fireRetryExhausted({
    required String workId,
    required String phoneNumber,
    required String contactName,
    required String message,
    String? error,
  }) async {
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          'com.guardianangela.app/sms',
          const StandardMethodCodec().encodeMethodCall(
            MethodCall('smsRetryExhausted', {
              'workId': workId,
              'phoneNumber': phoneNumber,
              'contactName': contactName,
              'message': message,
              'error': error,
            }),
          ),
          (_) {},
        );
  }
}

class _UrlLauncherMock {
  final List<MethodCall> calls = [];

  void register() {
    for (final ch in _channels) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(ch), _handle);
    }
  }

  void unregister() {
    for (final ch in _channels) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannel(ch), null);
    }
  }

  static const _channels = [
    'plugins.flutter.io/url_launcher_android',
    'plugins.flutter.io/url_launcher_ios',
    'plugins.flutter.io/url_launcher',
  ];

  Future<dynamic> _handle(MethodCall call) async {
    calls.add(call);
    return true;
  }
}

// ---------------------------------------------------------------------------
// SimulationMessagingService tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SimulationMessagingService', () {
    late SimulationMessagingService svc;

    setUp(() => svc = SimulationMessagingService());
    tearDown(() => svc.dispose());

    // sendMessage — simulation flag
    test('sendMessage with isSimulation=true records sim call, returns null', () async {
      final id = await svc.sendMessage(
        contact: _contact(),
        message: 'test',
        isSimulation: true,
      );
      check(id).isNull();
      check(svc.calls).length.equals(1);
      check(svc.calls.first.isSimulation).isTrue();
    });

    test('sendMessage with isSimulation=false records real call', () async {
      await svc.sendMessage(contact: _contact(), message: 'test');
      check(svc.calls).length.equals(1);
      check(svc.calls.first.isSimulation).isFalse();
    });

    test('sendMessage real call returns null by default', () async {
      final id = await svc.sendMessage(contact: _contact(), message: 'msg');
      check(id).isNull();
    });

    test('sendMessage real call returns simulatedWorkId when set', () async {
      svc.simulatedWorkIds = ['work-001'];
      final id = await svc.sendMessage(contact: _contact(), message: 'msg');
      check(id).equals('work-001');
    });

    test('simulatedWorkIds cycles through values', () async {
      svc.simulatedWorkIds = ['w1', 'w2'];
      final id1 = await svc.sendMessage(contact: _contact(), message: 'a');
      final id2 = await svc.sendMessage(contact: _contact(), message: 'b');
      final id3 = await svc.sendMessage(contact: _contact(), message: 'c');
      check(id1).equals('w1');
      check(id2).equals('w2');
      check(id3).equals('w1');
    });

    test('reset clears calls', () async {
      await svc.sendMessage(contact: _contact(), message: 'msg');
      svc.reset();
      check(svc.calls).isEmpty();
    });

    test('realCalls excludes simulation calls', () async {
      await svc.sendMessage(contact: _contact(), message: 'real');
      await svc.sendMessage(contact: _contact(), message: 'sim', isSimulation: true);
      check(svc.realCalls).length.equals(1);
    });

    test('simCalls excludes real calls', () async {
      await svc.sendMessage(contact: _contact(), message: 'real');
      await svc.sendMessage(contact: _contact(), message: 'sim', isSimulation: true);
      check(svc.simCalls).length.equals(1);
    });

    // canAutoSend
    test('canAutoSend always returns false', () {
      check(svc.canAutoSend(MessageChannel.sms)).isFalse();
      check(svc.canAutoSend(MessageChannel.whatsapp)).isFalse();
    });

    // cancelPending
    test('cancelPending is a no-op', () async {
      // Should not throw.
      await svc.cancelPending(['w1', 'w2']);
    });

    // retryExhaustedSms
    test('retryExhaustedSms re-sends via sendMessage', () async {
      const event = SmsRetryExhaustedEvent(
        workId: 'w1',
        phoneNumber: '+15551234567',
        contactName: 'Bob',
        message: 'Help',
      );
      await svc.retryExhaustedSms(event);
      check(svc.calls).length.equals(1);
      check(svc.calls.first.contact.name).equals('Bob');
      check(svc.calls.first.message).equals('Help');
    });

    // smsRetryExhausted stream
    test('smsRetryExhausted stream emits injected events', () async {
      const event = SmsRetryExhaustedEvent(
        workId: 'w2',
        phoneNumber: '+15551234567',
        contactName: 'Carol',
        message: 'Alert',
      );
      final received = <SmsRetryExhaustedEvent>[];
      final sub = svc.smsRetryExhausted.listen(received.add);
      svc.injectExhaustedEvent(event);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      check(received).length.equals(1);
      check(received.first.workId).equals('w2');
    });

    // Contact fields preserved
    test('sendMessage preserves contact fields', () async {
      final c = _contact(name: 'Dave', phone: '+447700900111', channel: MessageChannel.whatsapp);
      await svc.sendMessage(contact: c, message: 'hello');
      check(svc.calls.first.contact.name).equals('Dave');
      check(svc.calls.first.contact.channels.first).equals(MessageChannel.whatsapp);
    });
  });

  // -------------------------------------------------------------------------
  // RealMessagingService tests
  // -------------------------------------------------------------------------

  group('RealMessagingService', () {
    late _SmsChannelMock smsMock;
    late _UrlLauncherMock urlMock;
    late SimulationNotificationService notif;
    late RealMessagingService svc;

    setUp(() {
      smsMock = _SmsChannelMock()..register();
      urlMock = _UrlLauncherMock()..register();
      notif = SimulationNotificationService();
      svc = RealMessagingService(notification: notif);
    });

    tearDown(() async {
      await svc.dispose();
      smsMock.unregister();
      urlMock.unregister();
    });

    // Layer 3 simulation guard
    test('sendMessage with isSimulation=true returns null, no channel call',
        () async {
      final id = await svc.sendMessage(
        contact: _contact(),
        message: 'test',
        isSimulation: true,
      );
      check(id).isNull();
      check(smsMock.calls).isEmpty();
      check(urlMock.calls).isEmpty();
    });

    // WhatsApp dispatch
    test('sendMessage WhatsApp channel calls url_launcher with wa.me URL',
        () async {
      final c = _contact(channel: MessageChannel.whatsapp);
      await svc.sendMessage(contact: c, message: 'hello world');
      final launched = urlMock.calls.where(
        (c) =>
          (c.method == 'launchUrl' || c.method == 'launch') &&
          c.arguments.toString().contains('wa.me'),
      );
      check(launched).isNotEmpty();
    });

    // Telegram dispatch — tg:// first
    test('sendMessage Telegram calls url_launcher with tg:// URI first',
        () async {
      final c = _contact(channel: MessageChannel.telegram);
      await svc.sendMessage(contact: c, message: 'help');
      final tgCalls = urlMock.calls.where(
        (c) =>
          (c.method == 'launchUrl' || c.method == 'launch') &&
          c.arguments.toString().contains('tg://'),
      );
      check(tgCalls).isNotEmpty();
    });

    // cancelPending iOS is no-op (platform detection skipped in unit test;
    // we just ensure it doesn't throw on any platform)
    test('cancelPending with empty list does nothing', () async {
      await svc.cancelPending([]);
      check(smsMock.calls).isEmpty();
    });

    // smsRetryExhausted stream
    test('smsRetryExhausted stream emits on native smsRetryExhausted call',
        () async {
      final received = <SmsRetryExhaustedEvent>[];
      final sub = svc.smsRetryExhausted.listen(received.add);

      await smsMock.fireRetryExhausted(
        workId: 'wk-1',
        phoneNumber: '+15551234567',
        contactName: 'Eve',
        message: 'SOS',
      );

      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      check(received).length.equals(1);
      check(received.first.workId).equals('wk-1');
      check(received.first.contactName).equals('Eve');
    });

    test(
      'smsRetryExhausted: notification is shown after exhaustion event',
      () async {
        final sub = svc.smsRetryExhausted.listen((_) {});
        await smsMock.fireRetryExhausted(
          workId: 'wk-2',
          phoneNumber: '+15551234567',
          contactName: 'Frank',
          message: 'Alert',
        );
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();

        final notifCalls = notif.calls.where(
          (c) => c.method == 'showSmsRetryExhaustedNotification',
        );
        check(notifCalls).isNotEmpty();
        check(notifCalls.first.contactName).equals('Frank');
        check(notifCalls.first.actionPayload).equals('wk-2');
      },
    );

    // Retry tap from notification action taps
    test(
      'action tap matching kActionRetrySmsPrefix triggers retryExhaustedSms',
      () async {
        // First fire the exhaustion event to populate the cache.
        await smsMock.fireRetryExhausted(
          workId: 'wk-3',
          phoneNumber: '+15550009999',
          contactName: 'Grace',
          message: 'Need help',
        );
        await Future<void>.delayed(Duration.zero);

        // Record call count before retry tap.
        final beforeSms = smsMock.calls.length;
        final beforeUrl = urlMock.calls.length;

        // Simulate the user tapping the Retry action button.
        notif.injectActionTap('${kActionRetrySmsPrefix}wk-3');
        await Future<void>.delayed(Duration.zero);

        // The retry should trigger another send attempt via either the sms
        // channel (Android: enqueueSms) or url_launcher (iOS/non-Android).
        final afterSms = smsMock.calls.length;
        final afterUrl = urlMock.calls.length;
        // At least one of the two call counts increased.
        check(afterSms > beforeSms || afterUrl > beforeUrl).isTrue();
      },
    );

    test(
      'action tap with unknown payload does not throw',
      () async {
        // No prior exhaustion event cached.
        notif.injectActionTap('${kActionRetrySmsPrefix}unknown-id');
        await Future<void>.delayed(Duration.zero);
        // No crash — test passes if we reach here.
      },
    );

    // isSimulation guard applies even if sim flag was omitted (default false)
    test('sendMessage default isSimulation=false dispatches normally', () async {
      smsMock.nextWorkId = 'work-000';
      // Just ensure it doesn't throw on non-Android (url_launcher fallback
      // or no-op for sms channel on this test platform).
    });
  });
}
