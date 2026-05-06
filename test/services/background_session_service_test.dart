/// Contract tests for [BackgroundSessionServiceProtocol] and the
/// real [BackgroundSessionService] wrapper around
/// `NotificationServiceProtocol`. Audit Q3.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/services/fakes/fake_background_session_service.dart';
import 'package:guardianangela/services/fakes/fake_notification_service.dart';
import 'package:guardianangela/services/implementations/background_session_service.dart';
import 'package:guardianangela/services/protocols/background_session_service_protocol.dart';

void main() {
  group('FakeBackgroundSessionService contract', () {
    test('starts not running, start flips it', () async {
      final svc = FakeBackgroundSessionService();
      check(svc.isRunning).isFalse();
      await svc.start(title: 'ga', body: 'running');
      check(svc.isRunning).isTrue();
      await svc.stop();
      check(svc.isRunning).isFalse();
    });

    test('records every call', () async {
      final svc = FakeBackgroundSessionService();
      await svc.start(title: 't', body: 'b');
      await svc.updateStatus(title: 'u', body: 'b');
      await svc.stop();
      check(svc.calls).deepEquals(['start:t', 'updateStatus:u', 'stop']);
      svc.dispose();
    });

    test('injectAction pushes onto actions stream', () async {
      final svc = FakeBackgroundSessionService();
      final received = <BackgroundAction>[];
      final sub = svc.actions.listen(received.add);
      svc.injectAction(BackgroundAction.imSafe);
      svc.injectAction(BackgroundAction.pause);
      svc.injectAction(BackgroundAction.resume);
      await Future<void>.delayed(Duration.zero);
      check(received).deepEquals([
        BackgroundAction.imSafe,
        BackgroundAction.pause,
        BackgroundAction.resume,
      ]);
      await sub.cancel();
      svc.dispose();
    });
  });

  group('BackgroundSessionService (real, over FakeNotificationService)', () {
    test(
      'start posts session notification and arms tap subscription',
      () async {
        final notif = FakeNotificationService();
        final svc = BackgroundSessionService(notification: notif);
        await svc.start(title: 't', body: 'b');
        check(notif.calls).contains('showSessionNotification:t');
        check(svc.isRunning).isTrue();
        await svc.dispose();
        notif.dispose();
      },
    );

    test('updateStatus is no-op when not started', () async {
      final notif = FakeNotificationService();
      final svc = BackgroundSessionService(notification: notif);
      await svc.updateStatus(title: 'x', body: 'y');
      check(
        notif.calls.any((c) => c.startsWith('showSessionNotification')),
      ).isFalse();
      await svc.dispose();
      notif.dispose();
    });

    test('action-tap maps to BackgroundAction via the default map', () async {
      final notif = FakeNotificationService();
      final svc = BackgroundSessionService(notification: notif);
      final received = <BackgroundAction>[];
      final sub = svc.actions.listen(received.add);
      await svc.start(title: 't', body: 'b');
      notif.injectTap('imSafe');
      notif.injectTap('pause');
      notif.injectTap('resume');
      notif.injectTap('disarmTriggerEnd');
      notif.injectTap('disarmTriggerContinue');
      notif.injectTap('endSession');
      notif.injectTap('not-a-real-action');
      await Future<void>.delayed(Duration.zero);
      check(received).deepEquals([
        BackgroundAction.imSafe,
        BackgroundAction.pause,
        BackgroundAction.resume,
        BackgroundAction.imSafe,
        BackgroundAction.resume,
        BackgroundAction.imSafe,
      ]);
      await sub.cancel();
      await svc.dispose();
      notif.dispose();
    });

    test('stop cancels session notification + tap subscription', () async {
      final notif = FakeNotificationService();
      final svc = BackgroundSessionService(notification: notif);
      await svc.start(title: 't', body: 'b');
      await svc.stop();
      check(notif.calls).contains('cancelNotification:1');
      check(svc.isRunning).isFalse();
      // Subsequent stop is idempotent.
      await svc.stop();
      await svc.dispose();
      notif.dispose();
    });

    test('custom action map overrides default mapping', () async {
      final notif = FakeNotificationService();
      final svc = BackgroundSessionService(
        notification: notif,
        actionMap: const {'foo': BackgroundAction.pause},
      );
      final received = <BackgroundAction>[];
      final sub = svc.actions.listen(received.add);
      await svc.start(title: 't', body: 'b');
      notif.injectTap('foo');
      notif.injectTap('imSafe');
      await Future<void>.delayed(Duration.zero);
      // Only `foo` is mapped now; `imSafe` falls through.
      check(received).deepEquals([BackgroundAction.pause]);
      await sub.cancel();
      await svc.dispose();
      notif.dispose();
    });
  });
}
