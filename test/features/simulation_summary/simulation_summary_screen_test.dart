/// Widget tests for [SimulationSummaryScreen].
///
/// Covers the empty fallback when logId is null, the controller-driven
/// PIN gate, timeline rendering, badge counts, the share AppBar action,
/// and navigation back to home. Uses a fake controller subclass so
/// tests can inject any [SimulationSummaryState] without touching the
/// repository, settings repo, or `share_plus`.
///
/// Spec reference: docs/spec/04-screens-navigation.md §Simulation
/// Summary Screen (lines 1202–1288).
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/core/widgets/pin_keypad.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/models/session_log.dart';
import 'package:guardianangela/domain/models/session_log_event.dart';
import 'package:guardianangela/features/simulation_summary/simulation_summary_controller.dart';
import 'package:guardianangela/features/simulation_summary/simulation_summary_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Test fakes
// ---------------------------------------------------------------------------

/// Subclass of the real controller that emits a canned state and
/// records calls to [submitPin] / [skipPin] / [loadFor].
class _FakeSimSummaryController extends SimulationSummaryController {
  _FakeSimSummaryController(this._initial);

  final SimulationSummaryState _initial;

  int loadForCalls = 0;
  int submitPinCalls = 0;
  int skipPinCalls = 0;
  String? lastSubmittedPin;

  @override
  Future<SimulationSummaryState> build() async => _initial;

  @override
  void loadFor(String? id) {
    loadForCalls++;
  }

  @override
  Future<void> submitPin(String pin) async {
    submitPinCalls++;
    lastSubmittedPin = pin;
    final current = state.value;
    if (current == null) return;
    // Match: pin "0000" succeeds, anything else fails.
    if (pin == '0000') {
      state = AsyncData(current.copyWith(pinUnlocked: true, pinError: false));
    } else {
      state = AsyncData(current.copyWith(pinError: true));
    }
  }

  @override
  void skipPin() {
    skipPinCalls++;
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(pinUnlocked: true, pinError: false));
  }
}

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

SessionLog _log({
  List<SessionLogEvent>? events,
  Duration duration = const Duration(minutes: 5, seconds: 23),
}) {
  final start = DateTime.utc(2026, 1, 1, 12);
  return SessionLog(
    id: 'log-1',
    modeId: 'walk',
    modeName: 'Walk Mode',
    startedAt: start,
    endedAt: start.add(duration),
    endReason: EndReason.chainExhausted,
    isSimulation: true,
    events:
        events ??
        <SessionLogEvent>[
          SessionLogEvent(
            timestamp: start,
            eventType: 'started',
            stepIndex: 0,
            description: 'Session started',
          ),
        ],
  );
}

SimulationSummaryState _state({
  SessionLog? log,
  bool pinRequired = false,
  bool pinUnlocked = true,
  bool pinError = false,
}) {
  return SimulationSummaryState(
    log: log ?? _log(),
    pinRequired: pinRequired,
    pinUnlocked: pinUnlocked,
    pinError: pinError,
  );
}

List<Override> _overrideWith(_FakeSimSummaryController fake) => <Override>[
  simulationSummaryControllerProvider.overrideWith(() => fake),
];

// ---------------------------------------------------------------------------
// Pump helpers
// ---------------------------------------------------------------------------

Future<void> _pump(
  WidgetTester tester, {
  String? logId = 'log-1',
  _FakeSimSummaryController? controller,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  bool settle = true,
}) {
  final fake = controller ?? _FakeSimSummaryController(_state());
  return pumpScreen(
    tester,
    SimulationSummaryScreen(logId: logId),
    overrides: _overrideWith(fake),
    locale: locale,
    themeMode: themeMode,
    settle: settle,
  );
}

Future<void> _pumpWithRouter(
  WidgetTester tester, {
  required _FakeSimSummaryController fake,
  String logId = 'log-1',
}) async {
  final router = GoRouter(
    initialLocation: '/session/simulation-summary?id=$logId',
    routes: <RouteBase>[
      GoRoute(
        path: '/session/simulation-summary',
        name: RouteNames.sessionSimulationSummary,
        builder: (_, GoRouterState state) =>
            SimulationSummaryScreen(logId: state.uri.queryParameters['id']),
      ),
      GoRoute(
        path: '/',
        name: RouteNames.home,
        builder: (_, _) => const Scaffold(body: SizedBox.shrink()),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: _overrideWith(fake),
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF131118)),
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
  // ── Empty / fallback ────────────────────────────────────────────────────

  group('SimulationSummaryScreen — empty fallback', () {
    testWidgets('renders empty body when logId is null', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, logId: null);
      expect(find.text(l10n.simulationSummaryEmpty), findsOneWidget);
    });

    testWidgets('renders empty body when logId is empty', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, logId: '');
      expect(find.text(l10n.simulationSummaryEmpty), findsOneWidget);
    });

    testWidgets('empty body has return-home button', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, logId: null);
      expect(find.text(l10n.simulationSummaryReturn), findsOneWidget);
    });
  });

  // ── AppBar ──────────────────────────────────────────────────────────────

  group('SimulationSummaryScreen — AppBar', () {
    testWidgets('renders title', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(find.text(l10n.simulationSummaryTitle), findsWidgets);
    });

    testWidgets('share icon visible when summary is unlocked', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('share icon hidden behind PIN prompt', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        controller: _FakeSimSummaryController(
          _state(pinRequired: true, pinUnlocked: false),
        ),
      );
      expect(find.byIcon(Icons.share), findsNothing);
    });
  });

  // ── PIN prompt ──────────────────────────────────────────────────────────

  group('SimulationSummaryScreen — PIN prompt', () {
    testWidgets('shows PIN keypad when pin is required & not unlocked', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        controller: _FakeSimSummaryController(
          _state(pinRequired: true, pinUnlocked: false),
        ),
      );
      expect(find.byType(PinKeypad), findsOneWidget);
    });

    testWidgets('PIN prompt title and body strings are present', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        controller: _FakeSimSummaryController(
          _state(pinRequired: true, pinUnlocked: false),
        ),
      );
      expect(find.text(l10n.simulationPinPromptTitle), findsOneWidget);
      expect(find.text(l10n.simulationPinPromptBody), findsOneWidget);
    });

    testWidgets('correct PIN unlocks summary', (WidgetTester tester) async {
      final fake = _FakeSimSummaryController(
        _state(pinRequired: true, pinUnlocked: false),
      );
      await _pump(tester, controller: fake);
      // Enter "0000" — the fake controller treats it as the valid PIN.
      await tester.tap(find.text('0'));
      await tester.tap(find.text('0'));
      await tester.tap(find.text('0'));
      await tester.tap(find.text('0'));
      await tester.pumpAndSettle();
      check(fake.submitPinCalls).isGreaterOrEqual(1);
      // After unlock the timeline header is visible.
      final l10n = await loadL10n(const Locale('en'));
      expect(find.text(l10n.simulationSummaryTimelineHeader), findsOneWidget);
    });

    testWidgets('wrong PIN surfaces the incorrect-PIN label', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSimSummaryController(
        _state(pinRequired: true, pinUnlocked: false),
      );
      await _pump(tester, controller: fake);
      await tester.tap(find.text('1'));
      await tester.tap(find.text('2'));
      await tester.tap(find.text('3'));
      await tester.tap(find.text('4'));
      await tester.pump();
      final l10n = await loadL10n(const Locale('en'));
      expect(find.text(l10n.simulationPinIncorrect), findsOneWidget);
    });

    testWidgets('skip button is reachable on the PIN prompt', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSimSummaryController(
        _state(pinRequired: true, pinUnlocked: false),
      );
      await _pump(tester, controller: fake);
      final l10n = await loadL10n(const Locale('en'));
      expect(
        find.widgetWithText(TextButton, l10n.simulationPinPromptSkip),
        findsOneWidget,
      );
    });

    testWidgets('skipPin() unlocks summary (controller-level)', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSimSummaryController(
        _state(pinRequired: true, pinUnlocked: false),
      );
      await _pump(tester, controller: fake);
      // Drive skipPin directly on the fake — Riverpod's notifier
      // mutation triggers the UI rebuild.
      fake.skipPin();
      await tester.pumpAndSettle();
      final l10n = await loadL10n(const Locale('en'));
      expect(find.text(l10n.simulationSummaryTimelineHeader), findsOneWidget);
    });
  });

  // ── Summary body ────────────────────────────────────────────────────────

  group('SimulationSummaryScreen — summary body', () {
    testWidgets('renders the orange play-circle icon', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      final icons = tester.widgetList<Icon>(
        find.byWidgetPredicate(
          (Widget w) => w is Icon && w.icon == Icons.play_circle_outline,
        ),
      );
      expect(icons, isNotEmpty);
    });

    testWidgets('renders duration row formatted mm:ss for <1h', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(
        find.text(l10n.simulationSummaryDuration('05:23')),
        findsOneWidget,
      );
    });

    testWidgets('renders duration row formatted hh:mm:ss for ≥1h', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        controller: _FakeSimSummaryController(
          _state(log: _log(duration: const Duration(hours: 1, minutes: 5))),
        ),
      );
      expect(
        find.text(l10n.simulationSummaryDuration('01:05:00')),
        findsOneWidget,
      );
    });

    testWidgets('renders timeline header', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(find.text(l10n.simulationSummaryTimelineHeader), findsOneWidget);
    });

    testWidgets('renders one ListTile per event', (WidgetTester tester) async {
      final events = <SessionLogEvent>[
        SessionLogEvent(
          timestamp: DateTime.utc(2026, 1, 1, 12),
          eventType: 'started',
          stepIndex: 0,
          description: 'Session started',
        ),
        SessionLogEvent(
          timestamp: DateTime.utc(2026, 1, 1, 12, 1),
          eventType: 'step_fired',
          stepIndex: 1,
          description: 'Hold Button fired',
        ),
        SessionLogEvent(
          timestamp: DateTime.utc(2026, 1, 1, 12, 2),
          eventType: 'missed',
          stepIndex: 1,
          description: 'Hold Button missed',
        ),
      ];
      await _pump(
        tester,
        controller: _FakeSimSummaryController(
          _state(log: _log(events: events)),
        ),
      );
      expect(find.byType(ListTile), findsNWidgets(3));
    });
  });

  // ── Badges ──────────────────────────────────────────────────────────────

  group('SimulationSummaryScreen — badges', () {
    testWidgets('missed-events badge count is correct', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final events = <SessionLogEvent>[
        for (int i = 0; i < 3; i++)
          SessionLogEvent(
            timestamp: DateTime.utc(2026, 1, 1, 12, i),
            eventType: 'missed',
            stepIndex: i,
            description: 'Missed $i',
          ),
      ];
      await _pump(
        tester,
        controller: _FakeSimSummaryController(
          _state(log: _log(events: events)),
        ),
      );
      expect(
        find.text(l10n.simulationSummaryMissedEventsBadge(3)),
        findsOneWidget,
      );
    });

    testWidgets('steps-fired badge count is correct', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final events = <SessionLogEvent>[
        for (int i = 0; i < 2; i++)
          SessionLogEvent(
            timestamp: DateTime.utc(2026, 1, 1, 12, i),
            eventType: 'step_fired',
            stepIndex: i,
            description: 'Step $i',
          ),
      ];
      await _pump(
        tester,
        controller: _FakeSimSummaryController(
          _state(log: _log(events: events)),
        ),
      );
      expect(
        find.text(l10n.simulationSummaryStepsFiredBadge(2)),
        findsOneWidget,
      );
    });

    testWidgets('distress badge counts step_fired with "distress" tag', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final events = <SessionLogEvent>[
        SessionLogEvent(
          timestamp: DateTime.utc(2026, 1, 1, 12),
          eventType: 'step_fired',
          stepIndex: 0,
          description: 'distress triggered',
        ),
      ];
      await _pump(
        tester,
        controller: _FakeSimSummaryController(
          _state(log: _log(events: events)),
        ),
      );
      expect(find.text(l10n.simulationSummaryDistressBadge(1)), findsOneWidget);
    });
  });

  // ── Navigation ──────────────────────────────────────────────────────────

  group('SimulationSummaryScreen — navigation', () {
    testWidgets('return-home button navigates to /', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSimSummaryController(_state());
      await _pumpWithRouter(tester, fake: fake);
      final l10n = await loadL10n(const Locale('en'));
      await tester.tap(find.text(l10n.simulationSummaryReturn));
      await tester.pumpAndSettle();
      // After navigation summary text is gone.
      expect(find.text(l10n.simulationSummaryReturn), findsNothing);
    });
  });

  // ── Async states ────────────────────────────────────────────────────────

  group('SimulationSummaryScreen — async states', () {
    testWidgets('shows CircularProgressIndicator while loading', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSimSummaryController(_state());
      await pumpScreen(
        tester,
        const SimulationSummaryScreen(logId: 'log-1'),
        overrides: _overrideWith(fake),
        settle: false,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('no CircularProgressIndicator after build resolves', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  // ── RTL & dark mode ─────────────────────────────────────────────────────

  group('SimulationSummaryScreen — RTL', () {
    testWidgets('renders in Arabic without exception', (
      WidgetTester tester,
    ) async {
      await _pump(tester, locale: const Locale('ar'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in Hebrew without exception', (
      WidgetTester tester,
    ) async {
      await _pump(tester, locale: const Locale('he'));
      expect(tester.takeException(), isNull);
    });
  });

  group('SimulationSummaryScreen — dark mode', () {
    testWidgets('renders in dark mode without exception', (
      WidgetTester tester,
    ) async {
      await _pump(tester, themeMode: ThemeMode.dark);
      expect(tester.takeException(), isNull);
    });
  });

  // ── Controller-level unit tests ─────────────────────────────────────────

  group('SimulationSummaryState — derived metrics', () {
    test('missedCount counts missed events', () {
      final state = _state(
        log: _log(
          events: <SessionLogEvent>[
            SessionLogEvent(
              timestamp: DateTime.utc(2026, 1, 1, 12),
              eventType: 'missed',
              stepIndex: 0,
              description: '',
            ),
            SessionLogEvent(
              timestamp: DateTime.utc(2026, 1, 1, 12, 1),
              eventType: 'missed',
              stepIndex: 1,
              description: '',
            ),
          ],
        ),
      );
      expect(state.missedCount, 2);
    });

    test('durationSeconds derives from startedAt/endedAt', () {
      final state = _state(
        log: _log(duration: const Duration(minutes: 2, seconds: 30)),
      );
      expect(state.durationSeconds, 150);
    });

    test('durationSeconds returns 0 when log is null', () {
      const state = SimulationSummaryState(
        log: null,
        pinRequired: false,
        pinUnlocked: true,
      );
      expect(state.durationSeconds, 0);
    });
  });
}
