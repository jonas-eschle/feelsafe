/// Coverage test for [HomeScreen] — exercises:
///   * Line 23: `const HomeScreen({super.key})` constructor via non-const
///     instantiation.
///   * Line 236: `onTap: () => context.push(RouteNames.contacts)` — the
///     contacts-warning banner tap that navigates to the Contacts screen.
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
import 'package:guardianangela/features/home/home_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

import '../../helpers/test_helpers.dart';
import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Helper: router that includes /contacts so the banner tap doesn't crash
// ---------------------------------------------------------------------------

Widget _hostWithContacts({
  required Widget child,
  List<Override> overrides = const [],
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (ctx, st) => child),
      GoRoute(
        path: RouteNames.contacts,
        builder: (ctx, st) => const Scaffold(body: Text('Contacts')),
      ),
      GoRoute(
        path: '/other',
        builder: (ctx, st) => const Scaffold(body: SizedBox()),
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

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('HomeScreen contacts-banner tap (line 236)', () {
    testWidgets('tapping the zero-contacts banner navigates to contacts', (
      tester,
    ) async {
      // No contacts → banner is rendered with count < 3.
      await tester.pumpWidget(
        _hostWithContacts(
          overrides: [
            modesRepositoryProvider.overrideWithValue(
              FakeModesRepository([makeMode()]),
            ),
            contactsRepositoryProvider.overrideWithValue(
              FakeContactsRepository(), // empty
            ),
            settingsRepositoryProvider.overrideWithValue(
              FakeSettingsRepository(),
            ),
          ],
          child: const HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // The contacts-warning banner renders as an InkWell.
      final inkWells = find.byType(InkWell);
      check(inkWells.evaluate()).isNotEmpty();

      // Tap the contacts banner.
      await tester.tap(inkWells.first);
      await tester.pumpAndSettle();

      // Navigation succeeded — Contacts placeholder should be visible.
      check(find.text('Contacts').evaluate()).isNotEmpty();
    });
  });

  group('HomeScreen non-const constructor (line 23)', () {
    testWidgets(
      'non-const HomeScreen instantiation covers the constructor line',
      (tester) async {
        // Instantiate without const to ensure coverage instruments the ctor.
        // ignore: prefer_const_constructors
        final widget = HomeScreen(key: UniqueKey());
        await tester.pumpWidget(
          hostScreenWithRouter(
            overrides: [
              modesRepositoryProvider.overrideWithValue(FakeModesRepository()),
              contactsRepositoryProvider.overrideWithValue(
                FakeContactsRepository(),
              ),
              settingsRepositoryProvider.overrideWithValue(
                FakeSettingsRepository(),
              ),
            ],
            child: widget,
          ),
        );
        await tester.pumpAndSettle();
        check(find.byType(HomeScreen).evaluate()).isNotEmpty();
      },
    );
  });
}
