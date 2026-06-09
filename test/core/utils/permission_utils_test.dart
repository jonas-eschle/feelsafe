/// Widget tests for [ensureNotificationPermission] (spec 04:461 + 10:90,
/// Extra 42).
///
/// Strategy: the helper reads `Theme.of(context).platform` and talks to
/// `package:permission_handler`. We pump a tiny [_Harness] that exposes a
/// button which calls the helper and records the returned bool, and we
/// replace the permission platform with [_FakePermissionHandlerPlatform]
/// so each test can pin the reported status, the request result, and count
/// `openAppSettings` calls. The platform branch is driven via
/// `ThemeData(platform:)` through `pumpScreen`'s new [platform] arg.
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:guardianangela/core/utils/permission_utils.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakePermissionHandlerPlatform extends PermissionHandlerPlatform
    with MockPlatformInterfaceMixin {
  _FakePermissionHandlerPlatform({
    required this.statusToReturn,
    this.requestResult,
    this.statusAfterSettings,
  });

  PermissionStatus statusToReturn;
  final PermissionStatus? requestResult;

  /// Status reported on the *second* status read (after `openAppSettings`).
  /// When null the status does not change.
  final PermissionStatus? statusAfterSettings;

  int openAppSettingsCalls = 0;
  int checkPermissionStatusCalls = 0;
  int requestPermissionsCalls = 0;

  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    checkPermissionStatusCalls++;
    if (checkPermissionStatusCalls > 1 && statusAfterSettings != null) {
      return statusAfterSettings!;
    }
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

/// Minimal host with a single button that calls the helper and records the
/// boolean result so tests can assert on it.
class _Harness extends StatefulWidget {
  const _Harness();

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  bool? result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final r = await ensureNotificationPermission(context);
            setState(() => result = r);
          },
          child: const Text('go'),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<_FakePermissionHandlerPlatform> _pump(
  WidgetTester tester, {
  required PermissionStatus status,
  PermissionStatus? requestResult,
  PermissionStatus? statusAfterSettings,
  TargetPlatform platform = TargetPlatform.android,
}) async {
  final perm = _FakePermissionHandlerPlatform(
    statusToReturn: status,
    requestResult: requestResult,
    statusAfterSettings: statusAfterSettings,
  );
  final original = PermissionHandlerPlatform.instance;
  PermissionHandlerPlatform.instance = perm;
  addTearDown(() => PermissionHandlerPlatform.instance = original);
  await pumpScreen(tester, const _Harness(), platform: platform);
  return perm;
}

Future<bool?> _result(WidgetTester tester) async {
  final state = tester.state<_HarnessState>(find.byType(_Harness));
  return state.result;
}

void main() {
  group('ensureNotificationPermission — iOS no-op', () {
    testWidgets('returns true without touching permission_handler on iOS', (
      WidgetTester tester,
    ) async {
      final perm = await _pump(
        tester,
        status: PermissionStatus.denied,
        platform: TargetPlatform.iOS,
      );
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      check(await _result(tester)).equals(true);
      // The iOS branch never reads or requests the runtime permission.
      check(perm.checkPermissionStatusCalls).equals(0);
      check(perm.requestPermissionsCalls).equals(0);
      check(perm.openAppSettingsCalls).equals(0);
    });
  });

  group('ensureNotificationPermission — Android granted', () {
    testWidgets('already granted returns true with no dialog', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final perm = await _pump(tester, status: PermissionStatus.granted);
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      check(await _result(tester)).equals(true);
      check(perm.requestPermissionsCalls).equals(0);
      // No rationale / denied dialog should appear.
      expect(find.text(l10n.permissionNotifRationaleTitle), findsNothing);
      expect(find.text(l10n.permissionNotifDeniedTitle), findsNothing);
    });
  });

  group('ensureNotificationPermission — Android denied (not permanent)', () {
    testWidgets('shows rationale; Allow → requests → granted returns true', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final perm = await _pump(
        tester,
        status: PermissionStatus.denied,
        requestResult: PermissionStatus.granted,
      );
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      // Rationale dialog is shown.
      expect(find.text(l10n.permissionNotifRationaleTitle), findsOneWidget);
      await tester.tap(find.text(l10n.permissionNotifAllow));
      await tester.pumpAndSettle();
      check(perm.requestPermissionsCalls).equals(1);
      check(await _result(tester)).equals(true);
    });

    testWidgets('rationale Allow → request denied returns false', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final perm = await _pump(
        tester,
        status: PermissionStatus.denied,
        requestResult: PermissionStatus.denied,
      );
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.permissionNotifAllow));
      await tester.pumpAndSettle();
      check(perm.requestPermissionsCalls).equals(1);
      check(await _result(tester)).equals(false);
    });

    testWidgets('rationale "Not now" returns false without requesting', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final perm = await _pump(tester, status: PermissionStatus.denied);
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.permissionNotifNotNow));
      await tester.pumpAndSettle();
      check(perm.requestPermissionsCalls).equals(0);
      check(await _result(tester)).equals(false);
    });
  });

  group('ensureNotificationPermission — Android permanently denied', () {
    testWidgets(
      'shows deep-link dialog; Open settings → openAppSettings; granted '
      'after returns true',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final perm = await _pump(
          tester,
          status: PermissionStatus.permanentlyDenied,
          statusAfterSettings: PermissionStatus.granted,
        );
        await tester.tap(find.text('go'));
        await tester.pumpAndSettle();
        // Permanently-denied dialog (NOT the rationale dialog) is shown.
        expect(find.text(l10n.permissionNotifDeniedTitle), findsOneWidget);
        expect(find.text(l10n.permissionNotifRationaleTitle), findsNothing);
        await tester.tap(find.text(l10n.permissionNotifOpenSettings));
        await tester.pumpAndSettle();
        check(perm.openAppSettingsCalls).equals(1);
        // It never falls back to the OS request when permanently denied.
        check(perm.requestPermissionsCalls).equals(0);
        check(await _result(tester)).equals(true);
      },
    );

    testWidgets('deep-link dialog "Not now" returns false; no settings open', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final perm = await _pump(
        tester,
        status: PermissionStatus.permanentlyDenied,
      );
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.permissionNotifNotNow));
      await tester.pumpAndSettle();
      check(perm.openAppSettingsCalls).equals(0);
      check(await _result(tester)).equals(false);
    });

    testWidgets('Open settings but still denied after returns false', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final perm = await _pump(
        tester,
        status: PermissionStatus.permanentlyDenied,
        statusAfterSettings: PermissionStatus.permanentlyDenied,
      );
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.permissionNotifOpenSettings));
      await tester.pumpAndSettle();
      check(perm.openAppSettingsCalls).equals(1);
      check(await _result(tester)).equals(false);
    });
  });
}
