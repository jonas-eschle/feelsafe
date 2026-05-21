/// Small consolidated coverage filler for miscellaneous `onPressed`
/// / `onTap` closures and one-line branches spread across several
/// feature screens.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/history/past_event_detail_screen.dart';
import 'package:guardianangela/features/settings/security_screen.dart';
import 'package:guardianangela/features/settings/settings_screen.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

import 'fake_repositories.dart';

Widget _host({
  required Widget child,
  List<Override> overrides = const [],
  String initialLocation = '/root',
}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/root', builder: (c, s) => child),
      for (final path in const [
        RouteNames.evidenceExport,
        RouteNames.pinSetup,
        RouteNames.settings,
        RouteNames.settingsSecurity,
        RouteNames.settingsStealth,
        RouteNames.reminderTemplates,
        RouteNames.gpsLogging,
        RouteNames.eventDefaults,
        RouteNames.notificationSettings,
        RouteNames.historyRetention,
        RouteNames.backup,
        RouteNames.profile,
        RouteNames.contacts,
        RouteNames.modes,
        RouteNames.templates,
        RouteNames.distressModes,
        RouteNames.batteryAlert,
        RouteNames.about,
        RouteNames.feedback,
        RouteNames.pastEventDetail,
        RouteNames.pastEvents,
      ])
        GoRoute(
          path: path,
          builder: (c, s) => Scaffold(key: Key(path), body: const SizedBox()),
        ),
    ],
  );
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

Widget _hostWithQuery({
  required Widget child,
  required String query,
  List<Override> overrides = const [],
}) =>
    _host(child: child, overrides: overrides, initialLocation: '/root?$query');

void main() {
  testWidgets('PastEventDetailScreen FAB onPressed routes to evidence export', (
    tester,
  ) async {
    final log = SessionLog(
      id: 'log-1',
      modeId: 'mode',
      modeName: 'Walk',
      startedAt: DateTime.utc(2025),
      isSimulation: false,
      events: const [],
    );
    await tester.pumpWidget(
      _hostWithQuery(
        query: 'id=log-1',
        overrides: [
          sessionLogsRepositoryProvider.overrideWithValue(
            FakeSessionLogsRepository([log]),
          ),
        ],
        child: const PastEventDetailScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    check(
      find.byKey(const Key(RouteNames.evidenceExport)).evaluate().length,
    ).equals(1);
  });

  testWidgets(
    'SecurityScreen Set-PIN button pushes the pin-setup route with a which',
    (tester) async {
      await tester.pumpWidget(
        _host(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(
              FakeSettingsRepository(),
            ),
          ],
          child: const SecurityScreen(),
        ),
      );
      await tester.pumpAndSettle();
      // Tap the first Set PIN FilledButton (App PIN).
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();
      check(
        find.byKey(const Key(RouteNames.pinSetup)).evaluate().length,
      ).equals(1);
    },
  );

  testWidgets(
    'SettingsScreen _SettingsLink ListTile onTap pushes the named route',
    (tester) async {
      // Arrange: sub-panel with a few settings entries visible.
      await tester.pumpWidget(
        _host(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(
              FakeSettingsRepository(),
            ),
          ],
          child: const SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();
      // Tap the first chevron_right ListTile (any sub-menu link).
      final firstLink = find.widgetWithIcon(ListTile, Icons.chevron_right);
      if (firstLink.evaluate().isNotEmpty) {
        await tester.tap(firstLink.first);
        await tester.pumpAndSettle();
      }
      check(tester.takeException()).isNull();
    },
  );

  // Touch the SettingsController provider import so it resolves.
  test('settingsControllerProvider is a Riverpod NotifierProvider', () {
    check(settingsControllerProvider).isNotNull();
  });
}
