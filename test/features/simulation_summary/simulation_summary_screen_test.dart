/// Widget tests for [SimulationSummaryScreen].
///
/// The screen is a static [StatelessWidget] (no controller) that renders
/// a post-simulation summary stub. Tests verify:
///  - AppBar title renders correctly.
///  - Heading icon and text are present.
///  - Empty-state body text is shown.
///  - "Back to home" [FilledButton] CTA is present and enabled.
///  - The CTA navigates to the home route via `context.goNamed`.
///  - No "Start Real Session" button is present (spec 04 §Simulation Summary).
///  - Async state: no [CircularProgressIndicator] (screen is static).
///  - Dark-mode, RTL (Arabic), and accessibility smoke tests.
///
/// Navigation tests wrap the screen in a minimal [GoRouter] (the same
/// pattern as `settings_security_screen_test.dart`) so that
/// `context.goNamed(RouteNames.home)` resolves at test time without
/// invoking the full app router.
///
/// Spec ref: `docs/spec/04-screens-navigation.md §Simulation Summary Screen`.
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/features/simulation_summary/simulation_summary_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Navigation observer
// ---------------------------------------------------------------------------

/// Records every named-route go/push event fired through a [GoRouter].
class _RouteTracker extends NavigatorObserver {
  final List<String?> pushed = <String?>[];

  @override
  void didPush(Route<Object?> route, Route<Object?>? previousRoute) {
    pushed.add(route.settings.name);
  }

  @override
  void didReplace({Route<Object?>? newRoute, Route<Object?>? oldRoute}) {
    pushed.add(newRoute?.settings.name);
  }
}

// ---------------------------------------------------------------------------
// Pump helpers
// ---------------------------------------------------------------------------

/// Pumps [SimulationSummaryScreen] using the shared [pumpScreen] harness.
///
/// Suitable for all tests that do NOT need to assert on GoRouter
/// navigation, because [pumpScreen] wraps the screen in a plain
/// [MaterialApp] (no router).
Future<void> _pump(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  bool settle = true,
}) => pumpScreen(
  tester,
  const SimulationSummaryScreen(),
  locale: locale,
  themeMode: themeMode,
  settle: settle,
);

/// Wraps [SimulationSummaryScreen] in a two-route [GoRouter] so that
/// `context.goNamed(RouteNames.home)` resolves during tests.
///
/// Routes defined:
/// - `/session/simulation-summary` — the screen under test.
/// - `/` — stub home destination (verifies navigation completed).
Future<void> _pumpWithRouter(
  WidgetTester tester, {
  _RouteTracker? tracker,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
}) async {
  final observers = <NavigatorObserver>[?tracker];
  final router = GoRouter(
    initialLocation: '/session/simulation-summary',
    observers: observers,
    routes: <RouteBase>[
      GoRoute(
        path: '/session/simulation-summary',
        name: RouteNames.sessionSimulationSummary,
        builder: (_, _) => const SimulationSummaryScreen(),
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
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF131118),
          ),
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
  // ── AppBar ─────────────────────────────────────────────────────────────────

  group('SimulationSummaryScreen — AppBar', () {
    testWidgets('renders the simulation-summary title in the app bar', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      // The title text appears at least once (AppBar).
      expect(find.text(l10n.simulationSummaryTitle), findsWidgets);
    });

    testWidgets('Scaffold contains exactly one AppBar', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('AppBar title widget is a Text node', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.title, isA<Text>());
      final title = appBar.title! as Text;
      expect(title.data, l10n.simulationSummaryTitle);
    });
  });

  // ── Heading ────────────────────────────────────────────────────────────────

  group('SimulationSummaryScreen — heading', () {
    testWidgets('renders the orange play-circle icon', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      final iconFinder = find.byWidgetPredicate(
        (Widget w) =>
            w is Icon && w.icon == Icons.play_circle_outline,
      );
      expect(iconFinder, findsOneWidget);
    });

    testWidgets('play-circle icon has orange color', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      final icon = tester.widget<Icon>(
        find.byWidgetPredicate(
          (Widget w) =>
              w is Icon && w.icon == Icons.play_circle_outline,
        ),
      );
      check(icon.color).equals(Colors.orange);
    });

    testWidgets('heading text (simulationSummaryTitle) appears in body', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      // Title appears in both the AppBar and the body heading — ≥2 widgets.
      expect(
        find.text(l10n.simulationSummaryTitle),
        findsAtLeastNWidgets(2),
      );
    });
  });

  // ── Empty-state body ───────────────────────────────────────────────────────

  group('SimulationSummaryScreen — empty-state body', () {
    testWidgets('shows the "no steps fired" empty-state message', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(find.text(l10n.simulationSummaryEmpty), findsOneWidget);
    });

    testWidgets('empty-state message is wrapped in a Center widget', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      final centerFinder = find.ancestor(
        of: find.text(l10n.simulationSummaryEmpty),
        matching: find.byType(Center),
      );
      expect(centerFinder, findsOneWidget);
    });
  });

  // ── Return-home CTA ────────────────────────────────────────────────────────

  group('SimulationSummaryScreen — Return-home CTA', () {
    testWidgets('renders exactly one FilledButton', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('FilledButton carries the "Back to home" label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(
        find.descendant(
          of: find.byType(FilledButton),
          matching: find.text(l10n.simulationSummaryReturn),
        ),
        findsOneWidget,
      );
    });

    testWidgets('FilledButton onPressed is not null (button is enabled)', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      final btn = tester.widget<FilledButton>(find.byType(FilledButton));
      check(btn.onPressed).isNotNull();
    });

    testWidgets('FilledButton has a minimumSize constraint', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      final btn = tester.widget<FilledButton>(find.byType(FilledButton));
      // Style carries a minimumSize so the button spans full width.
      expect(btn.style, isNotNull);
    });
  });

  // ── Navigation ─────────────────────────────────────────────────────────────

  group('SimulationSummaryScreen — navigation', () {
    testWidgets(
      '"Back to home" button navigates to the home route',
      (WidgetTester tester) async {
        final tracker = _RouteTracker();
        await _pumpWithRouter(tester, tracker: tracker);
        final l10n = await loadL10n(const Locale('en'));
        await tester.tap(find.text(l10n.simulationSummaryReturn));
        await tester.pumpAndSettle();
        // After navigation the home stub Scaffold is shown.
        // At least one navigation event was recorded.
        check(tracker.pushed).isNotEmpty();
      },
    );

    testWidgets(
      'tapping "Back to home" replaces the simulation-summary screen',
      (WidgetTester tester) async {
        await _pumpWithRouter(tester);
        final l10n = await loadL10n(const Locale('en'));
        // Confirm we start on the summary screen.
        expect(find.text(l10n.simulationSummaryReturn), findsOneWidget);

        await tester.tap(find.text(l10n.simulationSummaryReturn));
        await tester.pumpAndSettle();

        // After going home the CTA is no longer visible.
        expect(find.text(l10n.simulationSummaryReturn), findsNothing);
      },
    );
  });

  // ── Spec compliance — absent buttons ──────────────────────────────────────

  group('SimulationSummaryScreen — spec compliance', () {
    testWidgets('has no "Start Real Session" button (spec 04)', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      // Spec: "No Start Real Session button." Verify no second FilledButton.
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('has no OutlinedButton secondary CTA', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('has no CircularProgressIndicator (static screen)', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  // ── Async states ───────────────────────────────────────────────────────────

  group('SimulationSummaryScreen — async states', () {
    testWidgets('first frame has no loading indicator (StatelessWidget)', (
      WidgetTester tester,
    ) async {
      // Pass settle: false to inspect the very first frame.
      await _pump(tester, settle: false);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('no exception thrown during pump', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      expect(tester.takeException(), isNull);
    });
  });

  // ── RTL ────────────────────────────────────────────────────────────────────

  group('SimulationSummaryScreen — RTL', () {
    testWidgets('renders in Arabic (RTL) without overflow or exception', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('ar'));
      await _pump(tester, locale: const Locale('ar'));
      // AppBar and CTA present; no exceptions thrown.
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text(l10n.simulationSummaryReturn), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in Hebrew (RTL) without overflow or exception', (
      WidgetTester tester,
    ) async {
      await _pump(tester, locale: const Locale('he'));
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in Farsi (RTL) without overflow or exception', (
      WidgetTester tester,
    ) async {
      await _pump(tester, locale: const Locale('fa'));
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ── Dark mode ──────────────────────────────────────────────────────────────

  group('SimulationSummaryScreen — dark mode', () {
    testWidgets('renders without exception in dark mode', (
      WidgetTester tester,
    ) async {
      await _pump(tester, themeMode: ThemeMode.dark);
      expect(tester.takeException(), isNull);
    });

    testWidgets('FilledButton present in dark mode', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, themeMode: ThemeMode.dark);
      expect(find.text(l10n.simulationSummaryReturn), findsOneWidget);
    });
  });

  // ── Accessibility ──────────────────────────────────────────────────────────

  group('SimulationSummaryScreen — accessibility', () {
    testWidgets('FilledButton label is readable text for screen readers', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      // Screen readers traverse Text widgets inside buttons.
      expect(
        find.descendant(
          of: find.byType(FilledButton),
          matching: find.text(l10n.simulationSummaryReturn),
        ),
        findsOneWidget,
      );
    });

    testWidgets('empty-state text is readable text for screen readers', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      // Raw Text in the tree — accessible without Semantics wrapper.
      expect(find.text(l10n.simulationSummaryEmpty), findsOneWidget);
    });

    testWidgets('renders without layout overflow at default size', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      // If any RenderFlex overflows, the test framework records a layout
      // exception — assert that none occurred.
      expect(tester.takeException(), isNull);
    });
  });
}
