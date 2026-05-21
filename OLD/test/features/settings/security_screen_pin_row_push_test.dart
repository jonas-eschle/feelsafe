/// Coverage test for [SecurityScreen] _PinRow — exercises the
/// `context.push('/pin-setup?which=...')` lambda (previously uncovered
/// because the test router in security_screen_coverage99_test.dart only
/// has an `/other` catch-all, not a `/pin-setup` route).
///
/// This test uses a custom router with `/pin-setup` registered so
/// tapping the Set/Change PIN FilledButton can succeed.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/settings/security_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

import '../fake_repositories.dart';

// ---------------------------------------------------------------------------
// Helper: router with /pin-setup registered so push succeeds
// ---------------------------------------------------------------------------

Widget _hostWithPinSetupRoute({required AppSettings settings}) {
  final repo = FakeSettingsRepository(settings);
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SecurityScreen()),
      GoRoute(
        path: RouteNames.pinSetup,
        builder: (context, state) => Scaffold(
          body: Text('PinSetup which=${state.uri.queryParameters['which']}'),
        ),
      ),
    ],
  );
  return ProviderScope(
    overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
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

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SecurityScreen _PinRow context.push lambda', () {
    testWidgets('tapping Set PIN FilledButton pushes to /pin-setup route', (
      tester,
    ) async {
      // No PINs set — three FilledButtons all say "Set PIN".
      await tester.pumpWidget(
        _hostWithPinSetupRoute(
          settings: const AppSettings(defaults: AppDefaults()),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the first FilledButton (App PIN "Set PIN").
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();

      // The pin-setup scaffold should now be visible.
      check(find.textContaining('PinSetup').evaluate()).isNotEmpty();
    });

    testWidgets(
      'tapping Change PIN FilledButton when app PIN is set pushes to /pin-setup',
      (tester) async {
        await tester.pumpWidget(
          _hostWithPinSetupRoute(
            settings: const AppSettings(
              defaults: AppDefaults(),
              appPinHash: 'existing-hash',
            ),
          ),
        );
        await tester.pumpAndSettle();

        // With appPinHash set, the first FilledButton says "Change PIN".
        await tester.tap(find.byType(FilledButton).first);
        await tester.pumpAndSettle();

        check(find.textContaining('PinSetup').evaluate()).isNotEmpty();
      },
    );
  });
}
