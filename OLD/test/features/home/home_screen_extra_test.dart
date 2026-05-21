/// Supplemental tests for [HomeScreen] covering branches not exercised
/// by the existing tests:
///   - lines 169, 172: the Simulate button's onPressed closure fires when
///     `mode != null && active == null`.
///   - line 291: the Cancel button in the start-confirmation dialog.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/home/home_screen.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

import '../../helpers/test_helpers.dart';
import '../fake_repositories.dart';

// ---------------------------------------------------------------------------
// A null-session controller (no running session).
// ---------------------------------------------------------------------------
class _NoSessionController extends SessionController {
  @override
  Future<WalkSession?> build() async => null;
}

// ---------------------------------------------------------------------------
// Host helper with all routes used by the home screen.
// ---------------------------------------------------------------------------
Widget _hostWithRoutes({
  required Widget child,
  List<Override> overrides = const [],
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (ctx, st) => child),
      GoRoute(
        path: RouteNames.session,
        builder: (ctx, st) => const Scaffold(body: Text('Session')),
      ),
      GoRoute(
        path: RouteNames.contacts,
        builder: (ctx, st) => const Scaffold(body: Text('Contacts')),
      ),
      GoRoute(
        path: RouteNames.modes,
        builder: (ctx, st) => const Scaffold(body: Text('Modes')),
      ),
      GoRoute(
        path: RouteNames.settings,
        builder: (ctx, st) => const Scaffold(body: Text('Settings')),
      ),
      GoRoute(
        path: RouteNames.pastEvents,
        builder: (ctx, st) => const Scaffold(body: Text('History')),
      ),
    ],
  );
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

List<Override> _overridesWithSelectedMode(
  String modeId,
  List<SessionMode> modes,
) => [
  modesRepositoryProvider.overrideWithValue(FakeModesRepository(modes)),
  contactsRepositoryProvider.overrideWithValue(FakeContactsRepository()),
  settingsRepositoryProvider.overrideWithValue(
    FakeSettingsRepository(
      AppSettings(defaults: const AppDefaults(), selectedModeId: modeId),
    ),
  ),
  sessionControllerProvider.overrideWith(_NoSessionController.new),
];

void main() {
  group('HomeScreen simulate button — selected mode, no active session', () {
    testWidgets('Simulate button is enabled when a mode is pre-selected', (
      tester,
    ) async {
      final mode = makeMode(id: 'm1', name: 'Walk');
      await tester.pumpWidget(
        _hostWithRoutes(
          overrides: _overridesWithSelectedMode('m1', [mode]),
          child: const HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find the Simulate TextButton — it should have a non-null onPressed.
      final simulateBtn = find.widgetWithIcon(
        TextButton,
        Icons.science_outlined,
      );
      check(simulateBtn.evaluate()).isNotEmpty();
      final btn = tester.widget<TextButton>(simulateBtn);
      check(btn.onPressed).isNotNull();
    });

    testWidgets('tapping Simulate opens confirmation dialog (lines 169, 172)', (
      tester,
    ) async {
      final mode = makeMode(id: 'm1', name: 'Walk');
      await tester.pumpWidget(
        _hostWithRoutes(
          overrides: _overridesWithSelectedMode('m1', [mode]),
          child: const HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Simulate — this executes the onPressed closure (lines 169, 172)
      // and shows the confirmation dialog.
      await tester.tap(find.widgetWithIcon(TextButton, Icons.science_outlined));
      await tester.pumpAndSettle();

      // The confirmation dialog should be visible.
      check(find.byType(AlertDialog).evaluate()).isNotEmpty();
    });

    testWidgets('Cancel in confirmation dialog dismisses it (line 291)', (
      tester,
    ) async {
      final mode = makeMode(id: 'm1', name: 'Walk');
      await tester.pumpWidget(
        _hostWithRoutes(
          overrides: _overridesWithSelectedMode('m1', [mode]),
          child: const HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Open dialog via Start button (also covers lines 154–159).
      await tester.tap(find.widgetWithIcon(FilledButton, Icons.play_arrow));
      await tester.pumpAndSettle();
      check(find.byType(AlertDialog).evaluate()).isNotEmpty();

      // Tap Cancel — this executes line 291.
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      // Dialog dismissed — HomeScreen still visible.
      check(find.byType(HomeScreen).evaluate()).isNotEmpty();
      check(find.byType(AlertDialog).evaluate()).isEmpty();
    });
  });
}
