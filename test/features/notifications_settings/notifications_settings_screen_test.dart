/// Widget tests for [NotificationsSettingsScreen].
///
/// Strategy: the screen consumes two services. The permission status
/// surfaces via [Permission.notification] through
/// `permission_handler` — we replace its platform implementation with
/// [_FakePermissionHandlerPlatform]. Per-channel state surfaces via
/// `notificationServiceProvider` — we override it with
/// [SimulationNotificationService], which lets each test configure
/// `simulatedChannelEnabled` and assert on
/// `openChannelSettingsCalls`.
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:guardianangela/features/notifications_settings/notifications_settings_screen.dart';
import 'package:guardianangela/services/protocols/notification_service_protocol.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/sim/notification_service_sim.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Fake PermissionHandlerPlatform
// ---------------------------------------------------------------------------

class _FakePermissionHandlerPlatform extends PermissionHandlerPlatform
    with MockPlatformInterfaceMixin {
  _FakePermissionHandlerPlatform({
    required this.statusToReturn,
    this.requestResult,
  });

  final PermissionStatus statusToReturn;
  final PermissionStatus? requestResult;

  int openAppSettingsCalls = 0;
  int checkPermissionStatusCalls = 0;
  int requestPermissionsCalls = 0;

  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    checkPermissionStatusCalls++;
    return statusToReturn;
  }

  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
    List<Permission> permissions,
  ) async {
    requestPermissionsCalls++;
    final result = requestResult ?? statusToReturn;
    return {for (final p in permissions) p: result};
  }

  @override
  Future<bool> openAppSettings() async {
    openAppSettingsCalls++;
    return true;
  }

  @override
  Future<bool> shouldShowRequestPermissionRationale(
    Permission permission,
  ) async => false;

  @override
  Future<ServiceStatus> checkServiceStatus(Permission permission) async =>
      ServiceStatus.enabled;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<
  ({_FakePermissionHandlerPlatform perm, SimulationNotificationService notif})
>
_pump(
  WidgetTester tester, {
  PermissionStatus status = PermissionStatus.granted,
  PermissionStatus? requestResult,
  Map<NotificationChannelKey, bool>? channelEnabled,
  bool settle = true,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
}) async {
  final perm = _FakePermissionHandlerPlatform(
    statusToReturn: status,
    requestResult: requestResult,
  );
  final originalPerm = PermissionHandlerPlatform.instance;
  PermissionHandlerPlatform.instance = perm;
  addTearDown(() => PermissionHandlerPlatform.instance = originalPerm);
  final notif = SimulationNotificationService();
  if (channelEnabled != null) {
    notif.simulatedChannelEnabled.addAll(channelEnabled);
  }
  await pumpScreen(
    tester,
    const NotificationsSettingsScreen(),
    overrides: <Override>[notificationServiceProvider.overrideWithValue(notif)],
    locale: locale,
    themeMode: themeMode,
    settle: settle,
  );
  return (perm: perm, notif: notif);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('NotificationsSettingsScreen — top permission block', () {
    testWidgets('renders Notifications title in AppBar', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(l10n.notificationsTitle),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders permission status row', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(find.text(l10n.notificationsStatusGranted), findsOneWidget);
    });

    testWidgets('Permission Denied status renders denied label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, status: PermissionStatus.permanentlyDenied);
      expect(find.text(l10n.notificationsStatusDenied), findsOneWidget);
    });

    testWidgets('Request permission button is present', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(find.text(l10n.notificationsRequest), findsOneWidget);
    });

    testWidgets('tapping Request permission invokes platform', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final r = await _pump(
        tester,
        status: PermissionStatus.denied,
        requestResult: PermissionStatus.granted,
      );
      await tester.tap(find.text(l10n.notificationsRequest));
      await tester.pumpAndSettle();
      check(r.perm.requestPermissionsCalls).equals(1);
    });

    testWidgets('Open system settings button is present', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(find.text(l10n.notificationsOpenSettings), findsOneWidget);
    });

    testWidgets('tapping Open system settings calls openAppSettings', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final r = await _pump(tester);
      await tester.tap(find.text(l10n.notificationsOpenSettings));
      await tester.pumpAndSettle();
      check(r.perm.openAppSettingsCalls).isGreaterOrEqual(1);
    });
  });

  group('NotificationsSettingsScreen — per-channel toggles', () {
    testWidgets('renders Notification channels section header', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(find.text(l10n.notificationsChannelsHeader), findsOneWidget);
    });

    testWidgets('renders Alarm channel toggle title', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(find.text(l10n.notificationsChannelAlarm), findsOneWidget);
    });

    testWidgets('renders Reminder channel toggle title', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(find.text(l10n.notificationsChannelReminder), findsOneWidget);
    });

    testWidgets('renders FakeCall channel toggle title', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(find.text(l10n.notificationsChannelFakeCall), findsOneWidget);
    });

    testWidgets('enabled channel shows active icon', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        channelEnabled: <NotificationChannelKey, bool>{
          NotificationChannelKey.alarm: true,
          NotificationChannelKey.reminder: true,
          NotificationChannelKey.fakeCall: true,
        },
      );
      // Each channel ListTile carries a notifications_active icon when on.
      expect(find.byIcon(Icons.notifications_active), findsAtLeastNWidgets(3));
    });

    testWidgets('disabled channel shows muted icon', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        channelEnabled: <NotificationChannelKey, bool>{
          NotificationChannelKey.alarm: false,
          NotificationChannelKey.reminder: true,
          NotificationChannelKey.fakeCall: true,
        },
      );
      expect(find.byIcon(Icons.notifications_off), findsAtLeastNWidgets(1));
    });

    testWidgets('tapping a channel invokes openChannelSettings on service', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final r = await _pump(tester);
      await tester.tap(find.text(l10n.notificationsChannelAlarm));
      await tester.pumpAndSettle();
      check(
        r.notif.openChannelSettingsCalls,
      ).contains(NotificationChannelKey.alarm);
    });

    testWidgets('tapping Reminder channel invokes openChannelSettings', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final r = await _pump(tester);
      await tester.tap(find.text(l10n.notificationsChannelReminder));
      await tester.pumpAndSettle();
      check(
        r.notif.openChannelSettingsCalls,
      ).contains(NotificationChannelKey.reminder);
    });

    testWidgets('tapping FakeCall channel invokes openChannelSettings', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final r = await _pump(tester);
      await tester.tap(find.text(l10n.notificationsChannelFakeCall));
      await tester.pumpAndSettle();
      check(
        r.notif.openChannelSettingsCalls,
      ).contains(NotificationChannelKey.fakeCall);
    });

    testWidgets('channel descriptions are visible', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(
        find.textContaining(l10n.notificationsChannelAlarmDescription),
        findsOneWidget,
      );
      expect(
        find.textContaining(l10n.notificationsChannelReminderDescription),
        findsOneWidget,
      );
      expect(
        find.textContaining(l10n.notificationsChannelFakeCallDescription),
        findsOneWidget,
      );
    });

    testWidgets('enabled status label appears for each channel', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(
        find.textContaining(l10n.notificationsChannelEnabled),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('three channel tiles render', (WidgetTester tester) async {
      await _pump(tester);
      expect(find.byType(Card), findsNWidgets(3));
    });

    testWidgets('isChannelEnabled called for each channel at screen open', (
      WidgetTester tester,
    ) async {
      final r = await _pump(tester);
      final ch = r.notif.calls
          .where((c) => c.method == 'isChannelEnabled')
          .length;
      check(ch).isGreaterOrEqual(3);
    });
  });

  group('NotificationsSettingsScreen — RTL & dark mode', () {
    testWidgets('renders in Arabic (RTL) without exception', (
      WidgetTester tester,
    ) async {
      await _pump(tester, locale: const Locale('ar'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in Hebrew (RTL) without exception', (
      WidgetTester tester,
    ) async {
      await _pump(tester, locale: const Locale('he'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in dark mode without exception', (
      WidgetTester tester,
    ) async {
      await _pump(tester, themeMode: ThemeMode.dark);
      expect(tester.takeException(), isNull);
    });
  });

  group('NotificationsSettingsScreen — accessibility', () {
    testWidgets('AppBar has notifications title for screen readers', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(l10n.notificationsTitle),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Request permission FilledButton has visible label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(
        find.descendant(
          of: find.byType(FilledButton),
          matching: find.text(l10n.notificationsRequest),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Open settings OutlinedButton has visible label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(
        find.descendant(
          of: find.byType(OutlinedButton),
          matching: find.text(l10n.notificationsOpenSettings),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Each channel tile has open_in_new trailing affordance', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      expect(find.byIcon(Icons.open_in_new), findsNWidgets(3));
    });
  });
}
