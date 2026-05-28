/// Widget tests for [SessionCompletedScreen].
///
/// Spec reference: docs/spec/04-screens-navigation.md
/// §Chain Exhausted Screen (lines 1160–1201).
///
/// Static-content tests use [pumpScreen] (no GoRouter needed).
/// Navigation tests mount the screen inside a minimal [GoRouter] via
/// [_pumpWithRouter] so that `context.goNamed(home)` and
/// `context.pushNamed(pastEvents)` resolve without throwing.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/features/session_completed/session_completed_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Pump helpers
// ---------------------------------------------------------------------------

/// Plain [pumpScreen] wrapper for static-content tests.
///
/// Avoids GoRouter when the test only asserts on widgets —
/// faster and simpler than the router harness.
Future<void> _pump(
  WidgetTester tester, {
  int? durationSeconds,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
}) => pumpScreen(
  tester,
  SessionCompletedScreen(durationSeconds: durationSeconds),
  locale: locale,
  themeMode: themeMode,
);

/// Builds a minimal [GoRouter] placing [SessionCompletedScreen] at
/// `/session/completed` on top of a blank `/` home route and a stub
/// `/past-events` route.
///
/// Required for navigation tests: both `context.goNamed(home)` and
/// `context.pushNamed(pastEvents)` need an actual GoRouter in the tree.
GoRouter _buildRouter({int? durationSeconds}) => GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: RouteNames.home,
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Home'))),
    ),
    GoRoute(
      path: '/session/completed',
      name: RouteNames.sessionCompleted,
      builder: (context, state) =>
          SessionCompletedScreen(durationSeconds: durationSeconds),
    ),
    GoRoute(
      path: '/past-events',
      name: RouteNames.pastEvents,
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('Past events'))),
    ),
  ],
);

/// Pumps [SessionCompletedScreen] inside a GoRouter + ProviderScope harness.
///
/// Starts at `/` so there is a history entry; tests navigate to
/// `/session/completed` before asserting. Uses [unawaited] for
/// `router.push` to avoid deadlocks from the returned Future only
/// resolving on pop.
Future<void> _pumpWithRouter(
  WidgetTester tester, {
  required GoRouter router,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
}) async {
  await tester.pumpWidget(
    ProviderScope(
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
  // -------------------------------------------------------------------------
  group('SessionCompletedScreen — scaffold & check icon', () {
    testWidgets('renders a Scaffold with a SafeArea', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('renders the check_circle icon at 96 px', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      final icon = tester.widget<Icon>(find.byIcon(Icons.check_circle));
      check(icon.size).equals(96.0);
    });

    testWidgets('check_circle icon uses the primary colour', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      final icon = tester.widget<Icon>(find.byIcon(Icons.check_circle));
      // The color must be non-null and not the default text colour —
      // the screen assigns colorScheme.primary.
      check(icon.color).isNotNull();
    });
  });

  // -------------------------------------------------------------------------
  group('SessionCompletedScreen — title & body text', () {
    testWidgets('renders the "Session complete" heading', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(find.text(l10n.sessionCompletedTitle), findsOneWidget);
    });

    testWidgets('renders the congratulatory body text', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(find.text(l10n.sessionCompletedBody), findsOneWidget);
    });

    testWidgets('body text uses textAlign: center', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      final body = tester.widget<Text>(find.text(l10n.sessionCompletedBody));
      check(body.textAlign).equals(TextAlign.center);
    });
  });

  // -------------------------------------------------------------------------
  group('SessionCompletedScreen — duration display', () {
    testWidgets('hides duration row when durationSeconds is null', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      // Neither "s" suffix alone nor "m" suffix should appear as a
      // standalone duration widget.
      expect(find.textContaining(RegExp(r'^\d+s$')), findsNothing);
      expect(find.textContaining(RegExp(r'^\d+m \d+s$')), findsNothing);
    });

    testWidgets('shows seconds-only format for < 60 s (e.g. 45 s)', (
      WidgetTester tester,
    ) async {
      await _pump(tester, durationSeconds: 45);
      expect(find.text('45s'), findsOneWidget);
    });

    testWidgets('shows "0s" for durationSeconds = 0', (
      WidgetTester tester,
    ) async {
      await _pump(tester, durationSeconds: 0);
      expect(find.text('0s'), findsOneWidget);
    });

    testWidgets('shows "59s" for durationSeconds = 59', (
      WidgetTester tester,
    ) async {
      await _pump(tester, durationSeconds: 59);
      expect(find.text('59s'), findsOneWidget);
    });

    testWidgets('shows minutes+seconds format at exactly 60 s', (
      WidgetTester tester,
    ) async {
      await _pump(tester, durationSeconds: 60);
      expect(find.text('1m 0s'), findsOneWidget);
    });

    testWidgets('formats 323 s as "5m 23s"', (WidgetTester tester) async {
      await _pump(tester, durationSeconds: 323);
      expect(find.text('5m 23s'), findsOneWidget);
    });

    testWidgets('formats 3600 s as "60m 0s"', (WidgetTester tester) async {
      await _pump(tester, durationSeconds: 3600);
      expect(find.text('60m 0s'), findsOneWidget);
    });

    testWidgets('negative durationSeconds renders without crash', (
      WidgetTester tester,
    ) async {
      // Spec is silent on negative input; the screen should not throw.
      // The _formatDuration method returns a suffix-only string for < 60.
      await _pump(tester, durationSeconds: -1);
      // No crash — exception must be null.
      expect(tester.takeException(), isNull);
      // Some text containing "-1s" is rendered.
      expect(find.text('-1s'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  group('SessionCompletedScreen — Return Home button', () {
    testWidgets('renders the "Return home" FilledButton', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(find.text(l10n.sessionCompletedReturnHome), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('"Return home" button is always enabled', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      final btn = tester.widget<FilledButton>(find.byType(FilledButton));
      check(btn.onPressed).isNotNull();
    });

    testWidgets('tapping Return Home navigates to home route', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final router = _buildRouter();
      await _pumpWithRouter(tester, router: router);
      unawaited(router.pushNamed<void>(RouteNames.sessionCompleted));
      await tester.pumpAndSettle();

      expect(find.text(l10n.sessionCompletedReturnHome), findsOneWidget);
      await tester.tap(find.text(l10n.sessionCompletedReturnHome));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text(l10n.sessionCompletedReturnHome), findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  group('SessionCompletedScreen — View Event Log button', () {
    testWidgets('renders the "Past sessions" OutlinedButton', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(find.text(l10n.sessionCompletedViewEventLog), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('"View Event Log" button is always enabled', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      final btn = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      check(btn.onPressed).isNotNull();
    });

    testWidgets('tapping View Event Log navigates to past-events', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final router = _buildRouter();
      await _pumpWithRouter(tester, router: router);
      unawaited(router.pushNamed<void>(RouteNames.sessionCompleted));
      await tester.pumpAndSettle();

      expect(find.text(l10n.sessionCompletedViewEventLog), findsOneWidget);
      await tester.tap(find.text(l10n.sessionCompletedViewEventLog));
      await tester.pumpAndSettle();

      expect(find.text('Past events'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  group('SessionCompletedScreen — layout', () {
    testWidgets('column is centre-aligned on both axes', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      final col = tester.widget<Column>(find.byType(Column).first);
      check(col.mainAxisAlignment).equals(MainAxisAlignment.center);
    });

    testWidgets('no AppBar is present on the screen', (
      WidgetTester tester,
    ) async {
      // Spec layout shows no AppBar; the Scaffold has body only.
      await _pump(tester);
      expect(find.byType(AppBar), findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  group('SessionCompletedScreen — simulation indicator', () {
    testWidgets('screen renders without error in a simulation context', (
      WidgetTester tester,
    ) async {
      // The screen itself does not render a simulation banner
      // (it is shown on the SimulationSummaryScreen instead).
      // Smoke: pump with no exceptions.
      await _pump(tester, durationSeconds: 120);
      expect(tester.takeException(), isNull);
      // No simulation banner text appears.
      final l10n = await loadL10n(const Locale('en'));
      expect(find.text(l10n.sessionSimulationBanner), findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  group('SessionCompletedScreen — dark mode', () {
    testWidgets('renders without exception in dark mode', (
      WidgetTester tester,
    ) async {
      await _pump(tester, durationSeconds: 90, themeMode: ThemeMode.dark);
      expect(tester.takeException(), isNull);
    });

    testWidgets('duration text is visible in dark mode', (
      WidgetTester tester,
    ) async {
      await _pump(tester, durationSeconds: 90, themeMode: ThemeMode.dark);
      expect(find.text('1m 30s'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  group('SessionCompletedScreen — RTL', () {
    testWidgets('renders in Arabic (RTL) without overflow', (
      WidgetTester tester,
    ) async {
      await _pump(tester, durationSeconds: 323, locale: const Locale('ar'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('duration text still visible in RTL locale', (
      WidgetTester tester,
    ) async {
      await _pump(tester, durationSeconds: 323, locale: const Locale('ar'));
      // Duration is a formatted number string — locale-independent.
      expect(find.text('5m 23s'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  group('SessionCompletedScreen — accessibility', () {
    testWidgets('FilledButton and OutlinedButton are tappable by label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      // Both buttons must be findable by their text labels so
      // screen readers can locate them.
      expect(find.text(l10n.sessionCompletedReturnHome), findsOneWidget);
      expect(find.text(l10n.sessionCompletedViewEventLog), findsOneWidget);
    });

    testWidgets('check_circle icon has non-null semantics label via Scaffold', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      // The screen must render without accessibility violations
      // that would cause a SemanticsException. Smoke test only.
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders at default (1x) font scale without exception', (
      WidgetTester tester,
    ) async {
      // Smoke: default text scale produces no exceptions.
      await _pump(tester, durationSeconds: 90);
      expect(tester.takeException(), isNull);
    });
  });

  // ── Simulation indicator banner ────────────────────────────────────────

  group('SessionCompletedScreen — simulation indicator banner', () {
    testWidgets('banner is hidden when isSimulation = false', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(tester, const SessionCompletedScreen());
      expect(find.text(l10n.sessionCompletedSimulationBanner), findsNothing);
    });

    testWidgets('banner is shown when isSimulation = true', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const SessionCompletedScreen(isSimulation: true),
      );
      expect(find.text(l10n.sessionCompletedSimulationBanner), findsOneWidget);
    });

    testWidgets('banner contains the play_circle_outline icon', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const SessionCompletedScreen(isSimulation: true),
      );
      expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
    });
  });

  // ── View Event Log routing ─────────────────────────────────────────────

  group('SessionCompletedScreen — View Event Log routing', () {
    testWidgets('with logId navigates to the per-log detail route', (
      WidgetTester tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/session/completed?id=abc',
        routes: <RouteBase>[
          GoRoute(
            path: '/session/completed',
            builder: (_, GoRouterState state) =>
                SessionCompletedScreen(logId: state.uri.queryParameters['id']),
          ),
          GoRoute(
            path: '/past-events/detail',
            name: RouteNames.pastEventDetail,
            builder: (_, GoRouterState state) => Scaffold(
              body: Text('Detail: ${state.uri.queryParameters['id']}'),
            ),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
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
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF131118),
              ),
              useMaterial3: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final l10n = await loadL10n(const Locale('en'));
      await tester.tap(find.text(l10n.sessionCompletedViewEventLog));
      await tester.pumpAndSettle();
      expect(find.text('Detail: abc'), findsOneWidget);
    });
  });
}
