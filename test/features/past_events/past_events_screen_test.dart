/// Widget tests for [PastEventsScreen].
///
/// Follows the reference pattern from
/// `test/features/home/home_screen_test.dart`:
/// 1. [_FakePastEventsController] subclasses [PastEventsController] and
///    overrides `build()` to return a canned [PastEventsState].
/// 2. Navigation tests use a [_FakeNavigatorObserver] + GoRouter scaffold
///    so `context.pushNamed(...)` resolves without a "No GoRouter" error.
/// 3. Each test calls `pumpScreen` (or `_pumpWithRouter` for nav tests).
///
/// Spec ref: `docs/spec/04-screens-navigation.md §Past Events Screen`
/// (lines 2403–2462).
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/features/past_events/past_events_controller.dart';
import 'package:guardianangela/features/past_events/past_events_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Test fake
// ---------------------------------------------------------------------------

class _FakePastEventsController extends PastEventsController {
  _FakePastEventsController(this._initial);

  final PastEventsState _initial;

  int softDeleteCalls = 0;
  String? lastSoftDeletedId;
  int undoCalls = 0;
  String? lastUndoId;

  @override
  Future<PastEventsState> build() async => _initial;

  @override
  Future<void> softDelete(String id) async {
    softDeleteCalls++;
    lastSoftDeletedId = id;
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      PastEventsState(logs: current.logs.where((l) => l.id != id).toList()),
    );
  }

  @override
  Future<void> undoSoftDelete(String id) async {
    undoCalls++;
    lastUndoId = id;
  }
}

// ---------------------------------------------------------------------------
// Navigator observer
// ---------------------------------------------------------------------------

class _FakeNavigatorObserver extends NavigatorObserver {
  final List<Route<Object?>> pushed = <Route<Object?>>[];

  @override
  void didPush(Route<Object?> route, Route<Object?>? previousRoute) {
    pushed.add(route);
  }
}

// ---------------------------------------------------------------------------
// Data factories
// ---------------------------------------------------------------------------

/// Baseline timestamp used for deterministic tests.
final _base = DateTime(2026, 4, 2, 21, 45);

PastEventsLog _log({
  String id = 'log-1',
  String modeName = 'Test Mode',
  bool isSimulation = false,
  int durationSeconds = 323,
  DateTime? startedAt,
}) => PastEventsLog(
  id: id,
  modeName: modeName,
  startedAt: startedAt ?? _base,
  durationSeconds: durationSeconds,
  isSimulation: isSimulation,
);

PastEventsState _state({List<PastEventsLog>? logs}) =>
    PastEventsState(logs: logs ?? <PastEventsLog>[]);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

List<Override> _override(_FakePastEventsController fake) => <Override>[
  pastEventsControllerProvider.overrideWith(() => fake),
];

/// Pumps [PastEventsScreen] inside a minimal GoRouter so that
/// `context.pushNamed(...)` resolves without a "No GoRouter" error.
///
/// Routes defined:
/// - `/past-events` — renders [PastEventsScreen].
/// - `/past-events/trash` — stub [Scaffold].
/// - `/past-events/detail` — stub [Scaffold].
Future<void> _pumpWithRouter(
  WidgetTester tester, {
  required _FakePastEventsController fake,
  required _FakeNavigatorObserver observer,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
}) async {
  final router = GoRouter(
    initialLocation: '/past-events',
    observers: <NavigatorObserver>[observer],
    routes: <RouteBase>[
      GoRoute(
        path: '/past-events',
        name: RouteNames.pastEvents,
        builder: (_, _) => const PastEventsScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: 'trash',
            name: RouteNames.pastEventsTrash,
            builder: (_, _) => const Scaffold(body: SizedBox.shrink()),
          ),
          GoRoute(
            path: 'detail',
            name: RouteNames.pastEventDetail,
            builder: (_, _) => const Scaffold(body: SizedBox.shrink()),
          ),
        ],
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        pastEventsControllerProvider.overrideWith(() => fake),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        locale: locale,
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        themeMode: themeMode,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF131118)),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF131118),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ── AppBar ────────────────────────────────────────────────────────────────

  group('PastEventsScreen — AppBar', () {
    testWidgets('renders app bar with past-events title', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakePastEventsController(_state());
      await pumpScreen(
        tester,
        const PastEventsScreen(),
        overrides: _override(fake),
      );
      expect(find.text(l10n.pastEventsTitle), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('app bar shows trash icon button with tooltip', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakePastEventsController(_state());
      await pumpScreen(
        tester,
        const PastEventsScreen(),
        overrides: _override(fake),
      );
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      expect(find.byTooltip(l10n.pastEventsTrash), findsOneWidget);
    });

    testWidgets('app bar has two tabs: Real and Simulated', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakePastEventsController(_state());
      await pumpScreen(
        tester,
        const PastEventsScreen(),
        overrides: _override(fake),
      );
      expect(find.text(l10n.pastEventsTabReal), findsOneWidget);
      expect(find.text(l10n.pastEventsTabSimulated), findsOneWidget);
    });
  });

  // ── Async states ──────────────────────────────────────────────────────────

  group('PastEventsScreen — async states', () {
    testWidgets('shows CircularProgressIndicator while loading', (
      WidgetTester tester,
    ) async {
      final fake = _FakePastEventsController(_state());
      await pumpScreen(
        tester,
        const PastEventsScreen(),
        overrides: _override(fake),
        settle: false,
      );
      // First frame: AsyncNotifier is still building.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('no loading spinner once async value resolves', (
      WidgetTester tester,
    ) async {
      final fake = _FakePastEventsController(_state());
      await pumpScreen(
        tester,
        const PastEventsScreen(),
        overrides: _override(fake),
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows error text when controller emits an error', (
      WidgetTester tester,
    ) async {
      // We need a controller that builds to AsyncError.
      final errorCtrl = _ErrorPastEventsController();
      await pumpScreen(
        tester,
        const PastEventsScreen(),
        overrides: <Override>[
          pastEventsControllerProvider.overrideWith(() => errorCtrl),
        ],
      );
      expect(find.textContaining('Error:'), findsOneWidget);
    });
  });

  // ── Empty state ───────────────────────────────────────────────────────────

  group('PastEventsScreen — empty state', () {
    testWidgets('Real tab shows empty banner when no real logs', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      // Only one simulated log — real tab must be empty.
      final fake = _FakePastEventsController(
        _state(logs: <PastEventsLog>[_log(isSimulation: true)]),
      );
      await pumpScreen(
        tester,
        const PastEventsScreen(),
        overrides: _override(fake),
      );
      expect(find.text(l10n.pastEventsEmpty), findsOneWidget);
    });

    testWidgets('no ListTile on Real tab when no real logs', (
      WidgetTester tester,
    ) async {
      final fake = _FakePastEventsController(_state());
      await pumpScreen(
        tester,
        const PastEventsScreen(),
        overrides: _override(fake),
      );
      expect(find.byType(ListTile), findsNothing);
    });
  });

  // ── List rendering ────────────────────────────────────────────────────────

  group('PastEventsScreen — list rendering', () {
    testWidgets('renders one ListTile per real log in Real tab', (
      WidgetTester tester,
    ) async {
      final logs = <PastEventsLog>[
        _log(id: 'r1', modeName: 'Walk Mode'),
        _log(id: 'r2', modeName: 'Date Mode'),
      ];
      final fake = _FakePastEventsController(_state(logs: logs));
      await pumpScreen(
        tester,
        const PastEventsScreen(),
        overrides: _override(fake),
      );
      expect(find.byType(ListTile), findsNWidgets(2));
      expect(find.text('Walk Mode'), findsOneWidget);
      expect(find.text('Date Mode'), findsOneWidget);
    });

    testWidgets('each row shows the mode name as title', (
      WidgetTester tester,
    ) async {
      final fake = _FakePastEventsController(
        _state(logs: <PastEventsLog>[_log(modeName: 'Night Walk')]),
      );
      await pumpScreen(
        tester,
        const PastEventsScreen(),
        overrides: _override(fake),
      );
      expect(find.text('Night Walk'), findsOneWidget);
    });

    testWidgets('each row shows a formatted started-at timestamp', (
      WidgetTester tester,
    ) async {
      // _base = 2026-04-02 21:45 → expects "2026-04-02 21:45"
      final fake = _FakePastEventsController(
        _state(logs: <PastEventsLog>[_log()]),
      );
      await pumpScreen(
        tester,
        const PastEventsScreen(),
        overrides: _override(fake),
      );
      expect(find.text('2026-04-02 21:45'), findsOneWidget);
    });

    testWidgets('row trailing shows formatted duration in minutes', (
      WidgetTester tester,
    ) async {
      // default durationSeconds is 323 → "5m 23s"
      final fake = _FakePastEventsController(
        _state(logs: <PastEventsLog>[_log()]),
      );
      await pumpScreen(
        tester,
        const PastEventsScreen(),
        overrides: _override(fake),
      );
      expect(find.text('5m 23s'), findsOneWidget);
    });

    testWidgets('row trailing shows seconds-only for <60s duration', (
      WidgetTester tester,
    ) async {
      final fake = _FakePastEventsController(
        _state(logs: <PastEventsLog>[_log(durationSeconds: 42)]),
      );
      await pumpScreen(
        tester,
        const PastEventsScreen(),
        overrides: _override(fake),
      );
      expect(find.text('42s'), findsOneWidget);
    });

    testWidgets('real log has shield icon (not simulated)', (
      WidgetTester tester,
    ) async {
      // Default _log() has isSimulation: false — shield icon expected.
      final fake = _FakePastEventsController(
        _state(logs: <PastEventsLog>[_log()]),
      );
      await pumpScreen(
        tester,
        const PastEventsScreen(),
        overrides: _override(fake),
      );
      expect(find.byIcon(Icons.shield), findsOneWidget);
      expect(find.byIcon(Icons.play_circle_outline), findsNothing);
    });

    testWidgets('simulated log has play_circle_outline icon', (
      WidgetTester tester,
    ) async {
      // Navigate to Simulated tab.
      final fake = _FakePastEventsController(
        _state(logs: <PastEventsLog>[_log(isSimulation: true)]),
      );
      await pumpScreen(
        tester,
        const PastEventsScreen(),
        overrides: _override(fake),
      );
      // Tap the "Simulated" tab to switch.
      final l10n = await loadL10n(const Locale('en'));
      await tester.tap(find.text(l10n.pastEventsTabSimulated));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.shield), findsNothing);
    });

    testWidgets('Simulated tab shows only simulated logs', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final logs = <PastEventsLog>[
        _log(id: 'r1', modeName: 'Real Session'),
        _log(id: 's1', modeName: 'Sim Session', isSimulation: true),
      ];
      final fake = _FakePastEventsController(_state(logs: logs));
      await pumpScreen(
        tester,
        const PastEventsScreen(),
        overrides: _override(fake),
      );
      // Switch to Simulated tab.
      await tester.tap(find.text(l10n.pastEventsTabSimulated));
      await tester.pumpAndSettle();
      expect(find.text('Sim Session'), findsOneWidget);
      expect(find.text('Real Session'), findsNothing);
    });

    testWidgets('Real tab does not show simulated logs', (
      WidgetTester tester,
    ) async {
      final logs = <PastEventsLog>[
        _log(id: 's1', modeName: 'Sim Only', isSimulation: true),
      ];
      final fake = _FakePastEventsController(_state(logs: logs));
      await pumpScreen(
        tester,
        const PastEventsScreen(),
        overrides: _override(fake),
      );
      // Real tab is the default — simulated log must not appear.
      expect(find.text('Sim Only'), findsNothing);
    });

    testWidgets('each real row is wrapped in a Dismissible', (
      WidgetTester tester,
    ) async {
      final logs = <PastEventsLog>[
        _log(id: 'r1', modeName: 'Walk'),
        _log(id: 'r2', modeName: 'Date'),
      ];
      final fake = _FakePastEventsController(_state(logs: logs));
      await pumpScreen(
        tester,
        const PastEventsScreen(),
        overrides: _override(fake),
      );
      expect(find.byType(Dismissible), findsNWidgets(2));
    });
  });

  // ── Soft-delete (swipe) ───────────────────────────────────────────────────

  group('PastEventsScreen — swipe soft-delete', () {
    testWidgets('swiping a row calls softDelete with correct id', (
      WidgetTester tester,
    ) async {
      final fake = _FakePastEventsController(
        _state(
          logs: <PastEventsLog>[_log(id: 'log-42', modeName: 'Walk')],
        ),
      );
      await pumpScreen(
        tester,
        const PastEventsScreen(),
        overrides: _override(fake),
      );
      await tester.drag(find.byType(Dismissible).first, const Offset(-600, 0));
      await tester.pumpAndSettle();
      check(fake.softDeleteCalls).equals(1);
      check(fake.lastSoftDeletedId).equals('log-42');
    });

    testWidgets('after swipe SnackBar with "Moved to trash" appears', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakePastEventsController(
        _state(
          logs: <PastEventsLog>[_log(id: 'r1', modeName: 'Walk')],
        ),
      );
      await pumpScreen(
        tester,
        const PastEventsScreen(),
        overrides: _override(fake),
      );
      await tester.drag(find.byType(Dismissible).first, const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(find.text(l10n.pastEventsSoftDeleted), findsOneWidget);
    });

    testWidgets('SnackBar UNDO action is visible after swipe', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakePastEventsController(
        _state(
          logs: <PastEventsLog>[_log(id: 'r1', modeName: 'Walk')],
        ),
      );
      await pumpScreen(
        tester,
        const PastEventsScreen(),
        overrides: _override(fake),
      );
      await tester.drag(find.byType(Dismissible).first, const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(find.text(l10n.pastEventsUndo), findsOneWidget);
    });

    testWidgets('tapping UNDO calls undoSoftDelete with correct id', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakePastEventsController(
        _state(
          logs: <PastEventsLog>[_log(id: 'r1', modeName: 'Walk')],
        ),
      );
      await pumpScreen(
        tester,
        const PastEventsScreen(),
        overrides: _override(fake),
      );
      await tester.drag(find.byType(Dismissible).first, const Offset(-600, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.pastEventsUndo));
      await tester.pumpAndSettle();
      check(fake.undoCalls).equals(1);
      check(fake.lastUndoId).equals('r1');
    });

    testWidgets('dismiss background shows delete icon', (
      WidgetTester tester,
    ) async {
      final fake = _FakePastEventsController(
        _state(
          logs: <PastEventsLog>[_log(id: 'r1', modeName: 'Walk')],
        ),
      );
      await pumpScreen(
        tester,
        const PastEventsScreen(),
        overrides: _override(fake),
      );
      // Partial drag reveals the background.
      await tester.drag(find.byType(Dismissible).first, const Offset(-120, 0));
      await tester.pump();
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });
  });

  // ── Navigation: Trash icon ────────────────────────────────────────────────

  group('PastEventsScreen — Trash navigation', () {
    testWidgets('tapping Trash icon navigates to /past-events/trash', (
      WidgetTester tester,
    ) async {
      final observer = _FakeNavigatorObserver();
      final fake = _FakePastEventsController(_state());
      await _pumpWithRouter(tester, fake: fake, observer: observer);
      final countBefore = observer.pushed.length;
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      check(observer.pushed.length).isGreaterThan(countBefore);
    });
  });

  // ── Navigation: row tap → detail ─────────────────────────────────────────

  group('PastEventsScreen — row tap navigation', () {
    testWidgets('tapping a log row navigates to past-events detail', (
      WidgetTester tester,
    ) async {
      final observer = _FakeNavigatorObserver();
      final fake = _FakePastEventsController(
        _state(logs: <PastEventsLog>[_log(modeName: 'Walk Mode')]),
      );
      await _pumpWithRouter(tester, fake: fake, observer: observer);
      final countBefore = observer.pushed.length;
      await tester.tap(find.text('Walk Mode'));
      await tester.pumpAndSettle();
      check(observer.pushed.length).isGreaterThan(countBefore);
    });
  });

  // ── RTL smoke ─────────────────────────────────────────────────────────────

  group('PastEventsScreen — RTL', () {
    testWidgets('renders in Arabic (RTL) without overflow or exception', (
      WidgetTester tester,
    ) async {
      final fake = _FakePastEventsController(
        _state(logs: <PastEventsLog>[_log(modeName: 'Walk Mode')]),
      );
      await pumpScreen(
        tester,
        const PastEventsScreen(),
        overrides: _override(fake),
        locale: const Locale('ar'),
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty state renders in Arabic without overflow', (
      WidgetTester tester,
    ) async {
      final fake = _FakePastEventsController(_state());
      await pumpScreen(
        tester,
        const PastEventsScreen(),
        overrides: _override(fake),
        locale: const Locale('ar'),
      );
      expect(tester.takeException(), isNull);
    });
  });

  // ── Dark mode smoke ───────────────────────────────────────────────────────

  group('PastEventsScreen — dark mode', () {
    testWidgets('renders without exception in dark mode (empty)', (
      WidgetTester tester,
    ) async {
      final fake = _FakePastEventsController(_state());
      await pumpScreen(
        tester,
        const PastEventsScreen(),
        overrides: _override(fake),
        themeMode: ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without exception in dark mode (with logs)', (
      WidgetTester tester,
    ) async {
      final fake = _FakePastEventsController(
        _state(logs: <PastEventsLog>[_log(modeName: 'Walk Mode')]),
      );
      await pumpScreen(
        tester,
        const PastEventsScreen(),
        overrides: _override(fake),
        themeMode: ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
    });
  });

  // ── Accessibility ─────────────────────────────────────────────────────────

  group('PastEventsScreen — accessibility', () {
    testWidgets('trash icon button exposes tooltip for screen readers', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakePastEventsController(_state());
      await pumpScreen(
        tester,
        const PastEventsScreen(),
        overrides: _override(fake),
      );
      expect(find.byTooltip(l10n.pastEventsTrash), findsOneWidget);
    });

    testWidgets('mode names are visible text nodes for a11y', (
      WidgetTester tester,
    ) async {
      final fake = _FakePastEventsController(
        _state(
          logs: <PastEventsLog>[
            _log(id: 'r1', modeName: 'Walk Mode'),
            _log(id: 'r2', modeName: 'Date Mode'),
          ],
        ),
      );
      await pumpScreen(
        tester,
        const PastEventsScreen(),
        overrides: _override(fake),
      );
      expect(find.text('Walk Mode'), findsOneWidget);
      expect(find.text('Date Mode'), findsOneWidget);
    });
  });
}

// ---------------------------------------------------------------------------
// Error-state fake
// ---------------------------------------------------------------------------

/// Controller whose build always throws to exercise the error widget path.
class _ErrorPastEventsController extends PastEventsController {
  @override
  Future<PastEventsState> build() async =>
      Future.error(Exception('db failure'));
}
