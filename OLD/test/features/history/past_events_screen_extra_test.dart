/// Supplemental tests for [PastEventsScreen] covering branches not
/// exercised by the smoke tests:
///   - line 91: error state shows error text.
///   - lines 121–123: simulated log tab with delete callback.
///   - lines 240–241: tile onTap navigates to pastEventDetail.
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
import 'package:guardianangela/features/history/history_controller.dart';
import 'package:guardianangela/features/history/past_events_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

import '../fake_repositories.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _ThrowingHistoryController extends HistoryController {
  @override
  Future<List<SessionLog>> build() async =>
      throw Exception('history load error');
}

SessionLog _log({
  required String id,
  String modeName = 'Walk',
  bool isSimulation = false,
}) => SessionLog(
  id: id,
  modeId: 'mode-1',
  modeName: modeName,
  startedAt: DateTime(2025, 1, 1, 12),
  isSimulation: isSimulation,
);

Widget _hostWithPastEventDetail({
  required Widget child,
  List<Override> overrides = const [],
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (ctx, st) => child),
      GoRoute(
        path: RouteNames.pastEventDetail,
        builder: (ctx, st) => const Scaffold(body: Text('PastEventDetail')),
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
  group('PastEventsScreen — extra branches', () {
    testWidgets('error state shows error text (line 91)', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            historyControllerProvider.overrideWith(
              _ThrowingHistoryController.new,
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PastEventsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      check(find.textContaining('history load error').evaluate()).isNotEmpty();
    });

    testWidgets('simulated tab has delete callback (lines 121–123)', (
      tester,
    ) async {
      final repo = FakeSessionLogsRepository([
        _log(id: 's1', modeName: 'SimWalk', isSimulation: true),
      ]);
      await tester.pumpWidget(
        _hostWithPastEventDetail(
          overrides: [sessionLogsRepositoryProvider.overrideWithValue(repo)],
          child: const PastEventsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // The PastEventsScreen has a TabBar with real + simulated tabs.
      // Switch to the second tab (Simulated).
      final tabs = find.byType(Tab);
      if (tabs.evaluate().length >= 2) {
        await tester.tap(tabs.at(1));
        await tester.pumpAndSettle();
      }

      // The simulated log entry should appear.
      check(find.text('SimWalk').evaluate()).isNotEmpty();

      // Tap delete on the sim log — exercises lines 121–123.
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      check(await repo.getAll()).isEmpty();
    });

    testWidgets('tapping a real log tile navigates to detail (lines 240–241)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _hostWithPastEventDetail(
          overrides: [
            sessionLogsRepositoryProvider.overrideWithValue(
              FakeSessionLogsRepository([
                _log(id: 'r1', modeName: 'RealWalk', isSimulation: false),
              ]),
            ),
          ],
          child: const PastEventsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('RealWalk'));
      await tester.pumpAndSettle();
      check(find.text('PastEventDetail').evaluate()).isNotEmpty();
    });
  });
}
