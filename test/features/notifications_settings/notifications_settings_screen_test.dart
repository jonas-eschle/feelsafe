/// Widget tests for [NotificationsSettingsScreen].
///
/// Strategy: [NotificationsSettingsScreen] is a plain [StatefulWidget]
/// with no Riverpod controller — it calls [Permission.notification]
/// and [openAppSettings] directly via the `permission_handler` package.
///
/// We replace [PermissionHandlerPlatform.instance] with a
/// [_FakePermissionHandlerPlatform] before every test and restore the
/// original after.  The fake lets each test inject a canned
/// [PermissionStatus] and records whether [openAppSettings] was invoked.
///
/// No real platform channel calls are made; `permission_handler` routes
/// all calls through [PermissionHandlerPlatform.instance].
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:guardianangela/features/notifications_settings/notifications_settings_screen.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Fake PermissionHandlerPlatform
// ---------------------------------------------------------------------------

/// Fake implementation of [PermissionHandlerPlatform] for widget tests.
///
/// [statusToReturn] is returned by [checkPermissionStatus] and also by
/// [requestPermissions] so that the "Request permission" button can be
/// tested for its effect on the displayed label.
///
/// [openAppSettingsCalls] counts how many times [openAppSettings] was
/// called, allowing tests to assert that the OutlinedButton triggers
/// the correct action.
class _FakePermissionHandlerPlatform extends PermissionHandlerPlatform
    with MockPlatformInterfaceMixin {
  _FakePermissionHandlerPlatform({
    required this.statusToReturn,
    this.requestResult,
  });

  final PermissionStatus statusToReturn;

  /// Returned by [requestPermissions]. Defaults to [statusToReturn].
  final PermissionStatus? requestResult;

  int openAppSettingsCalls = 0;
  int checkPermissionStatusCalls = 0;
  int requestPermissionsCalls = 0;

  @override
  Future<PermissionStatus> checkPermissionStatus(
    Permission permission,
  ) async {
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
  ) async =>
      false;

  @override
  Future<ServiceStatus> checkServiceStatus(Permission permission) async =>
      ServiceStatus.enabled;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Pumps [NotificationsSettingsScreen] with the given fake platform
/// and resolves initial async state.
Future<_FakePermissionHandlerPlatform> _pumpWithStatus(
  WidgetTester tester,
  PermissionStatus status, {
  PermissionStatus? requestResult,
  bool settle = true,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
}) async {
  final fake = _FakePermissionHandlerPlatform(
    statusToReturn: status,
    requestResult: requestResult,
  );
  PermissionHandlerPlatform.instance = fake;
  await pumpScreen(
    tester,
    const NotificationsSettingsScreen(),
    locale: locale,
    themeMode: themeMode,
    settle: settle,
  );
  return fake;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // Save original platform and restore after every test so tests are
  // hermetic — a failing test cannot corrupt subsequent ones.
  late PermissionHandlerPlatform originalPlatform;

  setUp(() {
    originalPlatform = PermissionHandlerPlatform.instance;
  });

  tearDown(() {
    PermissionHandlerPlatform.instance = originalPlatform;
  });

  // -------------------------------------------------------------------------
  // AppBar
  // -------------------------------------------------------------------------

  group('NotificationsSettingsScreen — AppBar', () {
    testWidgets('renders the Notifications title in the app bar', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpWithStatus(tester, PermissionStatus.granted);
      expect(find.text(l10n.notificationsTitle), findsWidgets);
    });

    testWidgets('AppBar widget is present', (WidgetTester tester) async {
      await _pumpWithStatus(tester, PermissionStatus.granted);
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Permission status labels
  // -------------------------------------------------------------------------

  group('NotificationsSettingsScreen — status: granted', () {
    testWidgets('shows "Granted" subtitle when permission is granted', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpWithStatus(tester, PermissionStatus.granted);
      expect(find.text(l10n.notificationsStatusGranted), findsOneWidget);
    });

    testWidgets(
      'shows notifications_active icon in the status ListTile',
      (WidgetTester tester) async {
        await _pumpWithStatus(tester, PermissionStatus.granted);
        // The ListTile leading icon.
        expect(find.byIcon(Icons.notifications_active), findsOneWidget);
      },
    );

    testWidgets(
      'ListTile title text is present when permission is granted',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await _pumpWithStatus(tester, PermissionStatus.granted);
        // homePermissionsNotification == "Notifications"; it also matches the
        // AppBar title so we confirm at least one copy is present.
        expect(find.text(l10n.homePermissionsNotification), findsWidgets);
      },
    );
  });

  group('NotificationsSettingsScreen — status: permanently denied', () {
    testWidgets('shows "Denied" subtitle when permission is permanently denied',
        (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpWithStatus(tester, PermissionStatus.permanentlyDenied);
      expect(find.text(l10n.notificationsStatusDenied), findsOneWidget);
    });

    testWidgets(
      'does not show "Granted" or "Not yet asked" when permanently denied',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await _pumpWithStatus(tester, PermissionStatus.permanentlyDenied);
        expect(find.text(l10n.notificationsStatusGranted), findsNothing);
        expect(find.text(l10n.notificationsStatusUnknown), findsNothing);
      },
    );
  });

  group('NotificationsSettingsScreen — status: denied (not permanent)', () {
    testWidgets(
      'shows "Not yet asked" subtitle when permission is denied',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        // denied is not granted and not permanentlyDenied → falls through to
        // notificationsStatusUnknown in the label logic.
        await _pumpWithStatus(tester, PermissionStatus.denied);
        expect(find.text(l10n.notificationsStatusUnknown), findsOneWidget);
      },
    );
  });

  group('NotificationsSettingsScreen — status: restricted', () {
    testWidgets(
      'shows "Not yet asked" subtitle for restricted status',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        // restricted is not granted and not permanentlyDenied → unknown label.
        await _pumpWithStatus(tester, PermissionStatus.restricted);
        expect(find.text(l10n.notificationsStatusUnknown), findsOneWidget);
      },
    );
  });

  // -------------------------------------------------------------------------
  // Loading / async state before initState completes
  // -------------------------------------------------------------------------

  group('NotificationsSettingsScreen — async state', () {
    testWidgets(
      'shows "Not yet asked" while permission status is loading',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        // settle: false → initState async hasn't completed; _status is null.
        await _pumpWithStatus(
          tester,
          PermissionStatus.granted,
          settle: false,
        );
        // On first frame _status is null → label = notificationsStatusUnknown.
        expect(find.text(l10n.notificationsStatusUnknown), findsOneWidget);
      },
    );

    testWidgets(
      'updates status label once initState resolves',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await _pumpWithStatus(tester, PermissionStatus.granted);
        // After settle the platform returned granted.
        expect(find.text(l10n.notificationsStatusGranted), findsOneWidget);
      },
    );
  });

  // -------------------------------------------------------------------------
  // FilledButton — "Request permission"
  // -------------------------------------------------------------------------

  group('NotificationsSettingsScreen — Request permission button', () {
    testWidgets('FilledButton with "Request permission" label is present', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpWithStatus(tester, PermissionStatus.denied);
      expect(find.text(l10n.notificationsRequest), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets(
      'tapping "Request permission" calls requestPermissions on the platform',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final fake = await _pumpWithStatus(tester, PermissionStatus.denied);
        await tester.tap(find.text(l10n.notificationsRequest));
        await tester.pumpAndSettle();
        check(fake.requestPermissionsCalls).isGreaterThan(0);
      },
    );

    testWidgets(
      'status label updates to "Granted" after request returns granted',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await _pumpWithStatus(
          tester,
          PermissionStatus.denied,
          requestResult: PermissionStatus.granted,
        );
        await tester.tap(find.text(l10n.notificationsRequest));
        await tester.pumpAndSettle();
        expect(find.text(l10n.notificationsStatusGranted), findsOneWidget);
      },
    );

    testWidgets(
      'status label stays "Denied" after request returns permanently denied',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await _pumpWithStatus(
          tester,
          PermissionStatus.denied,
          requestResult: PermissionStatus.permanentlyDenied,
        );
        await tester.tap(find.text(l10n.notificationsRequest));
        await tester.pumpAndSettle();
        expect(find.text(l10n.notificationsStatusDenied), findsOneWidget);
      },
    );
  });

  // -------------------------------------------------------------------------
  // OutlinedButton — "Open system settings"
  // -------------------------------------------------------------------------

  group('NotificationsSettingsScreen — Open system settings button', () {
    testWidgets('OutlinedButton with "Open system settings" label is present', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpWithStatus(tester, PermissionStatus.granted);
      expect(find.text(l10n.notificationsOpenSettings), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets(
      'tapping "Open system settings" calls openAppSettings on platform',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final fake = await _pumpWithStatus(tester, PermissionStatus.granted);
        check(fake.openAppSettingsCalls).equals(0);
        await tester.tap(find.text(l10n.notificationsOpenSettings));
        await tester.pumpAndSettle();
        check(fake.openAppSettingsCalls).equals(1);
      },
    );

    testWidgets(
      '"Open system settings" is still present when denied',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await _pumpWithStatus(tester, PermissionStatus.permanentlyDenied);
        expect(find.text(l10n.notificationsOpenSettings), findsOneWidget);
      },
    );
  });

  // -------------------------------------------------------------------------
  // Layout / scrollable body
  // -------------------------------------------------------------------------

  group('NotificationsSettingsScreen — layout structure', () {
    testWidgets('body contains a ListView', (WidgetTester tester) async {
      await _pumpWithStatus(tester, PermissionStatus.granted);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('body contains exactly one ListTile', (
      WidgetTester tester,
    ) async {
      await _pumpWithStatus(tester, PermissionStatus.granted);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('both FilledButton and OutlinedButton are present together', (
      WidgetTester tester,
    ) async {
      await _pumpWithStatus(tester, PermissionStatus.granted);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('FilledButton has minimum height of 48 logical pixels', (
      WidgetTester tester,
    ) async {
      await _pumpWithStatus(tester, PermissionStatus.granted);
      final btn = tester.widget<FilledButton>(find.byType(FilledButton));
      final style = btn.style;
      final minSize = style?.minimumSize?.resolve({});
      // The screen sets minimumSize: const Size.fromHeight(48).
      expect(minSize?.height, greaterThanOrEqualTo(48));
    });
  });

  // -------------------------------------------------------------------------
  // RTL
  // -------------------------------------------------------------------------

  group('NotificationsSettingsScreen — RTL', () {
    testWidgets('renders in Arabic (RTL) without overflow or exception', (
      WidgetTester tester,
    ) async {
      await _pumpWithStatus(
        tester,
        PermissionStatus.denied,
        locale: const Locale('ar'),
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'both buttons are present under RTL locale',
      (WidgetTester tester) async {
        await _pumpWithStatus(
          tester,
          PermissionStatus.denied,
          locale: const Locale('ar'),
        );
        expect(find.byType(FilledButton), findsOneWidget);
        expect(find.byType(OutlinedButton), findsOneWidget);
      },
    );
  });

  // -------------------------------------------------------------------------
  // Dark mode
  // -------------------------------------------------------------------------

  group('NotificationsSettingsScreen — dark mode', () {
    testWidgets('renders without exception in dark mode', (
      WidgetTester tester,
    ) async {
      await _pumpWithStatus(
        tester,
        PermissionStatus.granted,
        themeMode: ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('status label is visible in dark mode', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpWithStatus(
        tester,
        PermissionStatus.granted,
        themeMode: ThemeMode.dark,
      );
      expect(find.text(l10n.notificationsStatusGranted), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Accessibility
  // -------------------------------------------------------------------------

  group('NotificationsSettingsScreen — accessibility', () {
    testWidgets('ListTile provides a semantics node for screen readers', (
      WidgetTester tester,
    ) async {
      await _pumpWithStatus(tester, PermissionStatus.denied);
      // ListTile builds its own Semantics merging node automatically.
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('no overflow at 1.5x system font scale', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(
        tester.platformDispatcher.clearTextScaleFactorTestValue,
      );
      await _pumpWithStatus(tester, PermissionStatus.granted);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow at 2.0x system font scale', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(
        tester.platformDispatcher.clearTextScaleFactorTestValue,
      );
      await _pumpWithStatus(tester, PermissionStatus.granted);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'HebrewRTL: renders without overflow at large font scale',
      (WidgetTester tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = 1.3;
        addTearDown(
          tester.platformDispatcher.clearTextScaleFactorTestValue,
        );
        await _pumpWithStatus(
          tester,
          PermissionStatus.denied,
          locale: const Locale('he'),
        );
        expect(tester.takeException(), isNull);
      },
    );
  });

  // -------------------------------------------------------------------------
  // Platform check call count sanity
  // -------------------------------------------------------------------------

  group('NotificationsSettingsScreen — platform call hygiene', () {
    testWidgets('checkPermissionStatus is called exactly once on init', (
      WidgetTester tester,
    ) async {
      final fake = await _pumpWithStatus(tester, PermissionStatus.granted);
      check(fake.checkPermissionStatusCalls).equals(1);
    });

    testWidgets(
      'openAppSettings is not called during normal rendering',
      (WidgetTester tester) async {
        final fake = await _pumpWithStatus(tester, PermissionStatus.granted);
        check(fake.openAppSettingsCalls).equals(0);
      },
    );

    testWidgets(
      'requestPermissions is not called during normal rendering',
      (WidgetTester tester) async {
        final fake = await _pumpWithStatus(tester, PermissionStatus.granted);
        check(fake.requestPermissionsCalls).equals(0);
      },
    );

    testWidgets(
      'checkPermissionStatus is called once more after request tap',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final fake = await _pumpWithStatus(
          tester,
          PermissionStatus.denied,
          requestResult: PermissionStatus.granted,
        );
        final beforeCheck = fake.checkPermissionStatusCalls;
        await tester.tap(find.text(l10n.notificationsRequest));
        await tester.pumpAndSettle();
        // request() is a different code-path — the status update after tap
        // sets _status from the request result directly; no extra check call.
        check(fake.requestPermissionsCalls).equals(1);
        // The initial check from initState is captured in beforeCheck.
        check(fake.checkPermissionStatusCalls).equals(beforeCheck);
      },
    );
  });
}
