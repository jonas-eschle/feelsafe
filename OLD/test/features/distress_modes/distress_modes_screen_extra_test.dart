/// Supplemental tests for [DistressModesScreen] covering branches not
/// exercised by the smoke tests:
///   - line 16: non-const constructor instantiation instruments the line.
///   - lines 37–38: tile onTap navigates to distressModeEditor.
///   - line 59: FAB onPressed navigates to distressModeEditor.
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
import 'package:guardianangela/features/distress_modes/distress_modes_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

import '../../helpers/test_helpers.dart';
import '../fake_repositories.dart';

Widget _hostWithDistressEditorRoute({
  required Widget child,
  List<Override> overrides = const [],
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (ctx, st) => child),
      GoRoute(
        path: RouteNames.distressModeEditor,
        builder: (ctx, st) => const Scaffold(body: Text('DistressModeEditor')),
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

void main() {
  group('DistressModesScreen — extra branches', () {
    testWidgets('non-const constructor instruments line 16', (tester) async {
      // ignore: prefer_const_constructors
      final widget = DistressModesScreen(key: UniqueKey());
      await tester.pumpWidget(
        _hostWithDistressEditorRoute(
          overrides: [
            modesRepositoryProvider.overrideWithValue(FakeModesRepository([])),
          ],
          child: widget,
        ),
      );
      await tester.pumpAndSettle();
      check(find.byType(DistressModesScreen).evaluate()).isNotEmpty();
    });

    testWidgets(
      'tapping a tile navigates to distressModeEditor (lines 37–38)',
      (tester) async {
        await tester.pumpWidget(
          _hostWithDistressEditorRoute(
            overrides: [
              modesRepositoryProvider.overrideWithValue(
                FakeModesRepository([
                  makeDistressMode(id: 'd1', name: 'Alpha'),
                  makeDistressMode(id: 'd2', name: 'Beta'),
                ]),
              ),
            ],
            child: const DistressModesScreen(),
          ),
        );
        await tester.pumpAndSettle();
        // Tap the first tile — executes onTap (lines 37–38).
        await tester.tap(find.text('Alpha'));
        await tester.pumpAndSettle();
        // Navigation must succeed — distress mode editor placeholder visible.
        check(find.text('DistressModeEditor').evaluate()).isNotEmpty();
      },
    );

    testWidgets('FAB navigates to distressModeEditor (line 59)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _hostWithDistressEditorRoute(
          overrides: [
            modesRepositoryProvider.overrideWithValue(FakeModesRepository([])),
          ],
          child: const DistressModesScreen(),
        ),
      );
      await tester.pumpAndSettle();
      final fab = find.byType(FloatingActionButton);
      check(fab.evaluate()).isNotEmpty();
      await tester.tap(fab);
      await tester.pumpAndSettle();
      check(find.text('DistressModeEditor').evaluate()).isNotEmpty();
    });
  });
}
