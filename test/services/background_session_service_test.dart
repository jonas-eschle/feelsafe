// Tests for BackgroundSessionService (Real + Simulation).

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/services/background_session_service.dart';
import 'package:guardianangela/services/sim/background_session_service_sim.dart';
import 'package:guardianangela/services/sim/notification_service_sim.dart';

// ---------------------------------------------------------------------------
// SimulationBackgroundSessionService tests
// ---------------------------------------------------------------------------

void main() {
  group('SimulationBackgroundSessionService', () {
    late SimulationBackgroundSessionService svc;

    setUp(() => svc = SimulationBackgroundSessionService());
    tearDown(() => svc.dispose());

    test('configure() records a call', () async {
      await svc.configure();
      check(svc.calls).length.equals(1);
      check(svc.calls.first.method).equals('configure');
    });

    test('startService() records method + title + body + stealth', () async {
      await svc.startService(title: 'Active', body: 'Step 1');
      check(svc.calls.first.method).equals('startService');
      check(svc.calls.first.title).equals('Active');
      check(svc.calls.first.body).equals('Step 1');
      check(svc.calls.first.stealth).equals(false);
    });

    test('startService() stealth flag propagated', () async {
      await svc.startService(title: 'Music', body: '...', stealth: true);
      check(svc.calls.first.stealth).equals(true);
    });

    test('updateNotification() records method + title + body', () async {
      await svc.updateNotification(title: 'Paused', body: 'Step 2');
      check(svc.calls.first.method).equals('updateNotification');
      check(svc.calls.first.title).equals('Paused');
    });

    test('stopService() records call', () async {
      await svc.stopService();
      check(svc.calls.first.method).equals('stopService');
    });

    test('reset() clears calls', () async {
      await svc.configure();
      await svc.startService(title: 'T', body: 'B');
      svc.reset();
      check(svc.calls).isEmpty();
    });

    test('onImSafe emits after injectImSafe()', () async {
      final received = <void>[];
      final sub = svc.onImSafe.listen((_) => received.add(null));
      svc.injectImSafe();
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      check(received).length.equals(1);
    });

    test('onPause emits after injectPause()', () async {
      final received = <void>[];
      final sub = svc.onPause.listen((_) => received.add(null));
      svc.injectPause();
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      check(received).length.equals(1);
    });

    test('onResume emits after injectResume()', () async {
      final received = <void>[];
      final sub = svc.onResume.listen((_) => received.add(null));
      svc.injectResume();
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      check(received).length.equals(1);
    });

    test('multiple listeners on onImSafe all receive event', () async {
      final r1 = <void>[];
      final r2 = <void>[];
      final s1 = svc.onImSafe.listen((_) => r1.add(null));
      final s2 = svc.onImSafe.listen((_) => r2.add(null));
      svc.injectImSafe();
      await Future<void>.delayed(Duration.zero);
      await s1.cancel();
      await s2.cancel();
      check(r1).length.equals(1);
      check(r2).length.equals(1);
    });

    test('streams are independent', () async {
      final safe = <void>[];
      final pause = <void>[];
      final resume = <void>[];
      final s1 = svc.onImSafe.listen((_) => safe.add(null));
      final s2 = svc.onPause.listen((_) => pause.add(null));
      final s3 = svc.onResume.listen((_) => resume.add(null));
      svc.injectPause();
      await Future<void>.delayed(Duration.zero);
      await s1.cancel();
      await s2.cancel();
      await s3.cancel();
      check(safe).isEmpty();
      check(pause).length.equals(1);
      check(resume).isEmpty();
    });
  });

  // -------------------------------------------------------------------------
  // RealBackgroundSessionService tests
  // -------------------------------------------------------------------------

  group('RealBackgroundSessionService', () {
    late SimulationNotificationService notif;
    late RealBackgroundSessionService svc;

    setUp(() {
      notif = SimulationNotificationService();
      svc = RealBackgroundSessionService(notification: notif);
    });

    tearDown(() async {
      await svc.dispose();
      await notif.dispose();
    });

    test('configure() completes without error', () async {
      await svc.configure();
    });

    test('startService() calls showForegroundServiceNotification', () async {
      await svc.startService(title: 'Guardian Angela active', body: 'Step 1');
      final fgCalls = notif.calls.where(
        (c) => c.method == 'showForegroundServiceNotification',
      );
      check(fgCalls).isNotEmpty();
      check(fgCalls.first.title).equals('Guardian Angela active');
      check(fgCalls.first.body).equals('Step 1');
      check(fgCalls.first.stealth).equals(false);
    });

    test('startService() stealth=true passed to notification', () async {
      await svc.startService(title: 'Music', body: 'Playing', stealth: true);
      final call = notif.calls
          .where((c) => c.method == 'showForegroundServiceNotification')
          .first;
      check(call.stealth).equals(true);
    });

    test(
      'updateNotification() calls showForegroundServiceNotification',
      () async {
        await svc.updateNotification(title: 'Updated', body: 'Step 2');
        final call = notif.calls
            .where((c) => c.method == 'showForegroundServiceNotification')
            .first;
        check(call.title).equals('Updated');
      },
    );

    test('stopService() calls notification.cancel', () async {
      await svc.stopService();
      final cancel = notif.calls.where((c) => c.method == 'cancel');
      check(cancel).isNotEmpty();
    });

    test('onImSafe fires when kActionImSafe tap received', () async {
      final received = <void>[];
      final sub = svc.onImSafe.listen((_) => received.add(null));
      notif.injectActionTap(kActionImSafe);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      check(received).length.equals(1);
    });

    test('onPause fires when kActionPause tap received', () async {
      final received = <void>[];
      final sub = svc.onPause.listen((_) => received.add(null));
      notif.injectActionTap(kActionPause);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      check(received).length.equals(1);
    });

    test('onResume fires when kActionResume tap received', () async {
      final received = <void>[];
      final sub = svc.onResume.listen((_) => received.add(null));
      notif.injectActionTap(kActionResume);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      check(received).length.equals(1);
    });

    test('onImSafe does NOT fire for unrelated action taps', () async {
      final received = <void>[];
      final sub = svc.onImSafe.listen((_) => received.add(null));
      notif.injectActionTap('some:other:action');
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      check(received).isEmpty();
    });

    test('only matching stream fires for each action ID', () async {
      final safe = <void>[];
      final pause = <void>[];
      final resume = <void>[];
      final s1 = svc.onImSafe.listen((_) => safe.add(null));
      final s2 = svc.onPause.listen((_) => pause.add(null));
      final s3 = svc.onResume.listen((_) => resume.add(null));

      notif.injectActionTap(kActionPause);
      await Future<void>.delayed(Duration.zero);
      notif.injectActionTap(kActionResume);
      await Future<void>.delayed(Duration.zero);

      await s1.cancel();
      await s2.cancel();
      await s3.cancel();

      check(safe).isEmpty();
      check(pause).length.equals(1);
      check(resume).length.equals(1);
    });

    test('startService then stopService results in cancel call', () async {
      await svc.startService(title: 'T', body: 'B');
      await svc.stopService();
      final cancel = notif.calls.where((c) => c.method == 'cancel');
      check(cancel).isNotEmpty();
    });

    test(
      'multiple startService calls each trigger notification update',
      () async {
        await svc.startService(title: 'T1', body: 'B1');
        await svc.startService(title: 'T2', body: 'B2');
        final fgCalls = notif.calls.where(
          (c) => c.method == 'showForegroundServiceNotification',
        );
        check(fgCalls).length.equals(2);
      },
    );
  });
}
