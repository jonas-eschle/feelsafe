/// Additional plugin-boundary tests for [NotificationService] covering
/// paths not reached by the existing test files:
///
/// * Android: `init` creates all 3 notification channels when the
///   Android plugin impl is non-null.
/// * `showDisarmTriggerNotification` posts with id=2 and the supplied
///   title/body/labels.
library;

import 'package:checks/checks.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:guardianangela/core/platform/platform_info.dart';
import 'package:guardianangela/services/implementations/notification_service.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class _MockPlugin extends Mock implements FlutterLocalNotificationsPlugin {}

class _MockAndroidPlugin extends Mock
    implements AndroidFlutterLocalNotificationsPlugin {}

class _FakeInitSettings extends Fake implements InitializationSettings {}

class _FakeNotificationDetails extends Fake implements NotificationDetails {}

class _FakeAndroidNotificationChannel extends Fake
    implements AndroidNotificationChannel {}

// ---------------------------------------------------------------------------
// Builders
// ---------------------------------------------------------------------------

_MockPlugin _makePlugin({AndroidFlutterLocalNotificationsPlugin? androidImpl}) {
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
  ).thenReturn(androidImpl);
  return p;
}

_MockAndroidPlugin _makeAndroidPlugin() {
  final a = _MockAndroidPlugin();
  when(() => a.createNotificationChannel(any())).thenAnswer((_) async {});
  return a;
}

NotificationService _build({
  required _MockPlugin plugin,
  PlatformInfo platform = const FakePlatformInfo(),
}) => NotificationService(platform: platform, pluginFactory: () => plugin);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(_FakeInitSettings());
    registerFallbackValue(_FakeNotificationDetails());
    registerFallbackValue(_FakeAndroidNotificationChannel());
  });

  group('NotificationService.init — Android channel creation', () {
    test('creates all 3 channels when Android impl is non-null', () async {
      final androidPlugin = _makeAndroidPlugin();
      final plugin = _makePlugin(androidImpl: androidPlugin);
      final s = _build(
        plugin: plugin,
        platform: const FakePlatformInfo(isAndroid: true),
      );
      await s.init();

      // All 3 channel IDs (ga_session, ga_reminders, ga_toasts) must
      // have been created exactly once each.
      verify(() => androidPlugin.createNotificationChannel(any())).called(3);

      await s.dispose();
    });

    test('does not create channels on iOS (no Android impl)', () async {
      final plugin = _makePlugin();
      final s = _build(
        plugin: plugin,
        platform: const FakePlatformInfo(isIOS: true),
      );
      await s.init();
      // On iOS resolvePlatformSpecificImplementation returns null →
      // createNotificationChannel is never invoked.
      verifyNever(
        () => plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >(),
      );
      await s.dispose();
    });
  });

  group('NotificationService.showDisarmTriggerNotification', () {
    test('posts with the fixed id=2 and supplied title/body', () async {
      final plugin = _makePlugin();
      final s = _build(plugin: plugin);

      await s.showDisarmTriggerNotification(
        title: 'Arrived?',
        body: 'You appear to be home.',
        endSessionLabel: 'End session',
        continueLabel: 'Keep going',
      );

      verify(
        () => plugin.show(
          id: 2,
          title: 'Arrived?',
          body: 'You appear to be home.',
          notificationDetails: any(named: 'notificationDetails'),
        ),
      ).called(1);
      await s.dispose();
    });

    test('auto-inits the plugin before posting', () async {
      final plugin = _makePlugin();
      final s = _build(plugin: plugin);

      await s.showDisarmTriggerNotification(
        title: 'T',
        body: 'B',
        endSessionLabel: 'End',
        continueLabel: 'Continue',
      );

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

    test('actionId response is forwarded to actionTaps stream', () async {
      final plugin = _makePlugin();
      DidReceiveNotificationResponseCallback? captured;
      when(
        () => plugin.initialize(
          settings: any(named: 'settings'),
          onDidReceiveNotificationResponse: any(
            named: 'onDidReceiveNotificationResponse',
          ),
        ),
      ).thenAnswer((inv) async {
        final sym = const Symbol('onDidReceiveNotificationResponse');
        captured =
            inv.namedArguments[sym] as DidReceiveNotificationResponseCallback?;
        return true;
      });

      final s = _build(plugin: plugin);
      await s.showDisarmTriggerNotification(
        title: 'T',
        body: 'B',
        endSessionLabel: 'End',
        continueLabel: 'Continue',
      );

      final taps = <String>[];
      final sub = s.actionTaps.listen(taps.add);

      captured!(
        NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotificationAction,
          actionId: 'disarmTriggerEnd',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      check(taps).contains('disarmTriggerEnd');
      await sub.cancel();
      await s.dispose();
    });
  });
}
