/// Supplemental tests for [SessionCompletedScreen] covering the
/// FilledButton `onPressed` callback (line 36):
///
///   `onPressed: () => context.go(RouteNames.home)`
///
/// The test verifies that tapping the button navigates to the home
/// route without throwing an exception.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/features/session/session_completed_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _host({required List<String> navigatedTo}) {
  final router = GoRouter(
    initialLocation: '/done',
    routes: [
      GoRoute(
        path: '/done',
        // ignore: prefer_const_constructors
        builder: (ctx, st) => SessionCompletedScreen(key: UniqueKey()),
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (ctx, st) {
          navigatedTo.add(RouteNames.home);
          return const Scaffold(body: Text('Home'));
        },
      ),
    ],
  );
  return ProviderScope(
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
  group('SessionCompletedScreen — return-home button (line 36)', () {
    testWidgets(
      'tapping the FilledButton navigates to home (line 36)',
      (tester) async {
        final navigatedTo = <String>[];

        await tester.pumpWidget(_host(navigatedTo: navigatedTo));
        await tester.pumpAndSettle();

        // The screen must be visible.
        check(find.byType(SessionCompletedScreen).evaluate()).isNotEmpty();

        // The FilledButton with the "return home" label should be present.
        final button = find.byType(FilledButton);
        check(button.evaluate()).isNotEmpty();

        // Tap the button — this fires `context.go(RouteNames.home)`.
        await tester.tap(button);
        await tester.pumpAndSettle();

        // Navigation to home must have occurred.
        check(navigatedTo).isNotEmpty();
        check(navigatedTo.first).equals(RouteNames.home);
      },
    );
  });
}
