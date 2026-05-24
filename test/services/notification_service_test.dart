import 'dart:async';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import 'package:guardianangela/services/protocols/notification_service_protocol.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/sim/notification_service_sim.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

SimulationNotificationService _sim() => SimulationNotificationService();

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // SimulationNotificationService
  // =========================================================================

  group('SimulationNotificationService', () {
    late SimulationNotificationService s;

    setUp(() => s = _sim());
    tearDown(() => s.dispose());

    group('constructor', () {
      test('implements NotificationServiceProtocol', () {
        check(s).isA<NotificationServiceProtocol>();
      });

      test('starts with empty calls', () {
        check(s.calls).isEmpty();
      });
    });

    group('requestPermission', () {
      test('records call', () async {
        await s.requestPermission();
        check(s.calls).length.equals(1);
        check(s.calls.first.method).equals('requestPermission');
      });

      test('returns true by default', () async {
        check(await s.requestPermission()).isTrue();
      });

      test('returns false when simulatedPermissionGranted=false', () async {
        s.simulatedPermissionGranted = false;
        check(await s.requestPermission()).isFalse();
      });
    });

    group('showDisguisedReminder', () {
      test('records method, id, title, body', () async {
        await s.showDisguisedReminder(id: 42, title: 'T', body: 'B');
        check(s.calls).length.equals(1);
        final call = s.calls.first;
        check(call.method).equals('showDisguisedReminder');
        check(call.id).equals(42);
        check(call.title).equals('T');
        check(call.body).equals('B');
      });

      test('different ids accumulate separately', () async {
        await s.showDisguisedReminder(id: 1, title: 'A', body: 'a');
        await s.showDisguisedReminder(id: 2, title: 'B', body: 'b');
        check(s.calls).length.equals(2);
        check(s.calls[0].id).equals(1);
        check(s.calls[1].id).equals(2);
      });
    });

    group('showSmsRetryExhaustedNotification', () {
      test('records method, contactName, actionPayload', () async {
        await s.showSmsRetryExhaustedNotification(
          contactName: 'Alice',
          actionPayload: 'payload_001',
        );
        final call = s.calls.first;
        check(call.method).equals('showSmsRetryExhaustedNotification');
        check(call.contactName).equals('Alice');
        check(call.actionPayload).equals('payload_001');
      });

      test('actionPayload is distinct from prefix', () async {
        await s.showSmsRetryExhaustedNotification(
          contactName: 'Bob',
          actionPayload: 'job_456',
        );
        check(s.calls.first.actionPayload).equals('job_456');
      });
    });

    group('showForegroundServiceNotification', () {
      test('records title and body', () async {
        await s.showForegroundServiceNotification(
          title: 'Active',
          body: 'Session running',
        );
        final call = s.calls.first;
        check(call.method).equals('showForegroundServiceNotification');
        check(call.title).equals('Active');
        check(call.body).equals('Session running');
      });

      test('stealth=false by default', () async {
        await s.showForegroundServiceNotification(title: 'T', body: 'B');
        check(s.calls.first.stealth).equals(false);
      });

      test('stealth=true recorded when set', () async {
        await s.showForegroundServiceNotification(
          title: 'Music playing',
          body: '',
          stealth: true,
        );
        check(s.calls.first.stealth).equals(true);
      });
    });

    group('cancel', () {
      test('records cancel with id', () async {
        await s.cancel(99);
        check(s.calls.first.method).equals('cancel');
        check(s.calls.first.id).equals(99);
      });

      test('cancelling multiple ids records all', () async {
        await s.cancel(1);
        await s.cancel(2);
        check(s.calls).length.equals(2);
        check(s.calls[1].id).equals(2);
      });
    });

    group('actionTaps', () {
      test('injectActionTap emits to actionTaps', () async {
        final emitted = <String>[];
        final sub = s.actionTaps.listen(emitted.add);
        addTearDown(sub.cancel);

        s.injectActionTap('ga_retry_sms_job_1');
        await Future<void>.delayed(Duration.zero);

        check(emitted).deepEquals(['ga_retry_sms_job_1']);
      });

      test('multiple taps emit in order', () async {
        final emitted = <String>[];
        final sub = s.actionTaps.listen(emitted.add);
        addTearDown(sub.cancel);

        s.injectActionTap('tap_a');
        s.injectActionTap('tap_b');
        await Future<void>.delayed(Duration.zero);

        check(emitted).deepEquals(['tap_a', 'tap_b']);
      });

      test('actionTaps is broadcast stream', () {
        final sub1 = s.actionTaps.listen((_) {});
        final sub2 = s.actionTaps.listen((_) {});
        addTearDown(sub1.cancel);
        addTearDown(sub2.cancel);
        check(true).isTrue(); // no exception = broadcast
      });

      test('action tap prefix matches kActionRetrySmsPrefix', () {
        const payload = 'my_payload';
        check(
          '$kActionRetrySmsPrefix$payload',
        ).startsWith('ga_retry_sms_');
      });
    });

    group('reset', () {
      test('clears all recorded calls', () async {
        await s.showDisguisedReminder(id: 1, title: 'T', body: 'B');
        s.reset();
        check(s.calls).isEmpty();
      });
    });
  });

  // =========================================================================
  // kActionRetrySmsPrefix constant
  // =========================================================================

  group('kActionRetrySmsPrefix', () {
    test('defined as ga_retry_sms_', () {
      check(kActionRetrySmsPrefix).equals('ga_retry_sms_');
    });

    test('can be used to detect retry tap', () {
      const tap = 'ga_retry_sms_job_abc';
      check(tap.startsWith(kActionRetrySmsPrefix)).isTrue();
    });

    test('non-retry tap does not start with prefix', () {
      const tap = 'some_other_action';
      check(tap.startsWith(kActionRetrySmsPrefix)).isFalse();
    });
  });

  // =========================================================================
  // Protocol contracts
  // =========================================================================

  group('NotificationServiceProtocol contracts', () {
    test('SimulationNotificationService satisfies full protocol', () async {
      final service = _sim();
      addTearDown(service.dispose);

      await service.requestPermission();
      await service.showDisguisedReminder(id: 1, title: 'T', body: 'B');
      await service.showSmsRetryExhaustedNotification(
        contactName: 'C',
        actionPayload: 'p',
      );
      await service.showForegroundServiceNotification(title: 'T', body: 'B');
      await service.cancel(1);
      check(service.actionTaps).isA<Stream<String>>();
      check(service.calls).length.equals(5);
    });
  });

  // =========================================================================
  // Simulation swap (Riverpod)
  // =========================================================================

  group('Simulation swap — NotificationService', () {
    late ProviderContainer container;
    late SimulationNotificationService sim;

    setUp(() {
      sim = _sim();
      container = ProviderContainer(
        overrides: [
          notificationServiceProvider.overrideWithValue(sim),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      sim.dispose();
    });

    test('overridden container returns SimulationNotificationService', () {
      final s = container.read(notificationServiceProvider);
      check(s).isA<SimulationNotificationService>();
    });

    test('simulation is not RealNotificationService', () {
      final s = container.read(notificationServiceProvider);
      check(
        s.runtimeType.toString(),
      ).not((c) => c.equals('RealNotificationService'));
    });

    test('simulation starts with empty calls', () {
      final s =
          container.read(notificationServiceProvider)
              as SimulationNotificationService;
      check(s.calls).isEmpty();
    });
  });
}
