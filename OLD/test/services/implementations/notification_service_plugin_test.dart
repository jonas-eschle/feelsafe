/// Plugin-boundary tests for [NotificationService].
///
/// Injects a `FlutterLocalNotificationsPlugin` mock via the DI seam
/// so the real-branch paths (`init`, `showSessionNotification`,
/// `showDisguisedReminder`, `scheduleNotification`, `cancelNotification`,
/// `cancelAll`, `showToast`) can be verified on the Linux host — the
/// paths the existing tests could never reach because the real plugin
/// has no Linux binding.
library;

import 'dart:async';

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:guardianangela/core/platform/platform_info.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/services/implementations/notification_service.dart';

class _MockPlugin extends Mock implements FlutterLocalNotificationsPlugin {}

class _FakeInitSettings extends Fake implements InitializationSettings {}

class _FakeNotificationDetails extends Fake implements NotificationDetails {}

ReminderTemplate _template() => const ReminderTemplate(
  id: 't1',
  name: 'ping',
  title: 'Hello',
  body: 'body text',
  confirmationType: ConfirmationType.tapButton,
  displayStyle: ReminderDisplayStyle.fullScreen,
  isGlobal: true,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(_FakeInitSettings());
    registerFallbackValue(_FakeNotificationDetails());
  });

  _MockPlugin makePlugin() {
    final p = _MockPlugin();
    when(
      () => p.initialize(
        settings: any(named: 'settings'),
        onDidReceiveNotificationResponse: any(
          named: 'onDidReceiveNotificationResponse',
        ),
      ),
    ).thenAnswer((_) async => true);
    when(
      () => p.show(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        notificationDetails: any(named: 'notificationDetails'),
      ),
    ).thenAnswer((_) async {});
    when(() => p.cancel(id: any(named: 'id'))).thenAnswer((_) async {});
    when(p.cancelAll).thenAnswer((_) async {});
    when(
      () => p
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >(),
    ).thenReturn(null);
    return p;
  }

  NotificationService build({
    required _MockPlugin plugin,
    PlatformInfo platform = const FakePlatformInfo(),
  }) => NotificationService(platform: platform, pluginFactory: () => plugin);

  group('NotificationService.init', () {
    test('initializes the plugin exactly once', () async {
      final plugin = makePlugin();
      final s = build(plugin: plugin);
      await s.init();
      await s.init();
      verify(
        () => plugin.initialize(
          settings: any(named: 'settings'),
          onDidReceiveNotificationResponse: any(
            named: 'onDidReceiveNotificationResponse',
          ),
        ),
      ).called(1);
      await s.dispose();
    });

    test('skips Android channel registration on non-Android host', () async {
      final plugin = makePlugin();
      final s = build(plugin: plugin);
      await s.init();
      verifyNever(
        () => plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >(),
      );
      await s.dispose();
    });

    test(
      'resolves the Android plugin on Android (null impl still ok)',
      () async {
        final plugin = makePlugin();
        final s = build(
          plugin: plugin,
          platform: const FakePlatformInfo(isAndroid: true),
        );
        await s.init();
        verify(
          () => plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >(),
        ).called(1);
        await s.dispose();
      },
    );
  });

  group('NotificationService.showSessionNotification', () {
    test(
      'isSimulation=true routes to showToast and skips the session id',
      () async {
        final plugin = makePlugin();
        final s = build(plugin: plugin);
        await s.showSessionNotification(
          title: 'Title',
          body: 'Body',
          isSimulation: true,
        );
        // Should not have shown anything against id=1 (session id).
        verifyNever(
          () => plugin.show(
            id: 1,
            title: any(named: 'title'),
            body: any(named: 'body'),
            notificationDetails: any(named: 'notificationDetails'),
          ),
        );
        await s.dispose();
      },
    );

    test('real branch shows id=1 with the given title/body', () async {
      final plugin = makePlugin();
      final s = build(plugin: plugin);
      await s.showSessionNotification(title: 'A', body: 'B');
      verify(
        () => plugin.show(
          id: 1,
          title: 'A',
          body: 'B',
          notificationDetails: any(named: 'notificationDetails'),
        ),
      ).called(1);
      await s.dispose();
    });

    test('auto-inits the plugin on first call', () async {
      final plugin = makePlugin();
      final s = build(plugin: plugin);
      await s.showSessionNotification(title: 'A', body: 'B');
      verify(
        () => plugin.initialize(
          settings: any(named: 'settings'),
          onDidReceiveNotificationResponse: any(
            named: 'onDidReceiveNotificationResponse',
          ),
        ),
      ).called(1);
      await s.dispose();
    });
  });

  group('NotificationService.showDisguisedReminder', () {
    test('real branch shows the template title+body', () async {
      final plugin = makePlugin();
      final s = build(plugin: plugin);
      await s.showDisguisedReminder(template: _template());
      verify(
        () => plugin.show(
          id: any(named: 'id'),
          title: 'Hello',
          body: 'body text',
          notificationDetails: any(named: 'notificationDetails'),
        ),
      ).called(1);
      await s.dispose();
    });

    test('isSimulation=true skips the disguised-reminder show call', () async {
      final plugin = makePlugin();
      final s = build(plugin: plugin);
      await s.showDisguisedReminder(template: _template(), isSimulation: true);
      // Toast path goes through plugin.show too, but with the toast
      // title (the message string). The disguised path used the
      // template.title = 'Hello'. A toast shows 'Hello — body text'.
      verifyNever(
        () => plugin.show(
          id: any(named: 'id'),
          title: 'Hello',
          body: 'body text',
          notificationDetails: any(named: 'notificationDetails'),
        ),
      );
      await s.dispose();
    });
  });

  group('NotificationService.scheduleNotification', () {
    test('isSimulation=true returns an id without queueing a timer', () async {
      final plugin = makePlugin();
      final s = build(plugin: plugin);
      final id = await s.scheduleNotification(
        title: 'A',
        body: 'B',
        delay: const Duration(seconds: 10),
        isSimulation: true,
      );
      check(id).isGreaterThan(0);
      verifyNever(
        () => plugin.show(
          id: any(named: 'id'),
          title: 'A',
          body: 'B',
          notificationDetails: any(named: 'notificationDetails'),
        ),
      );
      await s.dispose();
    });

    test('real branch fires the notification after the delay', () {
      fakeAsync((async) {
        final plugin = makePlugin();
        final s = build(plugin: plugin);
        unawaited(
          s.scheduleNotification(
            title: 'later',
            body: 'body',
            delay: const Duration(seconds: 5),
          ),
        );
        async.elapse(const Duration(seconds: 1));
        verifyNever(
          () => plugin.show(
            id: any(named: 'id'),
            title: 'later',
            body: 'body',
            notificationDetails: any(named: 'notificationDetails'),
          ),
        );
        async.elapse(const Duration(seconds: 5));
        verify(
          () => plugin.show(
            id: any(named: 'id'),
            title: 'later',
            body: 'body',
            notificationDetails: any(named: 'notificationDetails'),
          ),
        ).called(1);
        unawaited(s.dispose());
        async.flushMicrotasks();
      });
    });

    test('cancelNotification before fire cancels the Timer and the id', () {
      fakeAsync((async) {
        final plugin = makePlugin();
        final s = build(plugin: plugin);
        late int id;
        unawaited(
          s
              .scheduleNotification(
                title: 'x',
                body: 'y',
                delay: const Duration(seconds: 10),
              )
              .then((v) => id = v),
        );
        async.flushMicrotasks();
        unawaited(s.cancelNotification(id));
        async.elapse(const Duration(seconds: 20));
        verifyNever(
          () => plugin.show(
            id: any(named: 'id'),
            title: 'x',
            body: 'y',
            notificationDetails: any(named: 'notificationDetails'),
          ),
        );
        verify(() => plugin.cancel(id: id)).called(1);
        unawaited(s.dispose());
        async.flushMicrotasks();
      });
    });
  });

  group('NotificationService.cancelNotification', () {
    test('delegates to plugin.cancel', () async {
      final plugin = makePlugin();
      final s = build(plugin: plugin);
      await s.cancelNotification(42);
      verify(() => plugin.cancel(id: 42)).called(1);
      await s.dispose();
    });
  });

  group('NotificationService.cancelAll', () {
    test('cancels the timers map and delegates to plugin.cancelAll', () async {
      final plugin = makePlugin();
      final s = build(plugin: plugin);
      // Schedule one so there's a timer to cancel too.
      await s.scheduleNotification(
        title: 'a',
        body: 'b',
        delay: const Duration(seconds: 30),
      );
      await s.cancelAll();
      verify(plugin.cancelAll).called(1);
      await s.dispose();
    });
  });

  group('NotificationService.showToast', () {
    test('shows once and schedules auto-dismiss cancel', () {
      fakeAsync((async) {
        final plugin = makePlugin();
        final s = build(plugin: plugin);
        unawaited(s.showToast('hello'));
        async.flushMicrotasks();
        verify(
          () => plugin.show(
            id: any(named: 'id'),
            title: 'hello',
            body: null,
            notificationDetails: any(named: 'notificationDetails'),
          ),
        ).called(1);
        // Auto-dismiss after 3s.
        async.elapse(const Duration(seconds: 3));
        verify(
          () => plugin.cancel(id: any(named: 'id')),
        ).called(greaterThanOrEqualTo(1));
        unawaited(s.dispose());
        async.flushMicrotasks();
      });
    });
  });

  group('NotificationService.actionTaps', () {
    test('onResponse callback forwards payload to actionTaps stream', () async {
      final plugin = makePlugin();
      DidReceiveNotificationResponseCallback? captured;
      when(
        () => plugin.initialize(
          settings: any(named: 'settings'),
          onDidReceiveNotificationResponse: any(
            named: 'onDidReceiveNotificationResponse',
          ),
        ),
      ).thenAnswer((invocation) async {
        captured =
            invocation.namedArguments[const Symbol(
                  'onDidReceiveNotificationResponse',
                )]
                as DidReceiveNotificationResponseCallback?;
        return true;
      });
      final s = build(plugin: plugin);
      await s.init();
      final taps = <String>[];
      final sub = s.actionTaps.listen(taps.add);
      captured!(
        NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          payload: 'tap-42',
        ),
      );
      await Future<void>.delayed(Duration.zero);
      check(taps).contains('tap-42');
      // Empty / null payload drops silently.
      captured!(
        NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          payload: '',
        ),
      );
      captured!(
        NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      check(taps).deepEquals(['tap-42']);
      await sub.cancel();
      await s.dispose();
    });

    test('dispose closes the actionTaps stream (idempotent)', () async {
      final plugin = makePlugin();
      final s = build(plugin: plugin);
      await s.dispose();
      await s.dispose();
      // Stream is closed — listen returns a done-closed subscription.
      var completed = false;
      s.actionTaps.listen((_) {}, onDone: () => completed = true);
      await Future<void>.delayed(Duration.zero);
      check(completed).isTrue();
    });
  });

  group('NotificationService backward compat', () {
    test('zero-arg constructor still builds', () {
      check(() => NotificationService()).returnsNormally();
    });
  });
}
