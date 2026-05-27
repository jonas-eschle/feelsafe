/// Widget tests for [FakeCallScreen].
///
/// Covers incoming state, answered state, navigation behaviour, dark
/// mode, RTL, and accessibility. The screen currently has no external
/// controller — all state is internal to [_FakeCallScreenState].
///
/// Spec reference: docs/spec/04-screens-navigation.md §Fake Call Screen
/// (lines 1044–1159).
library;

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/features/fake_call/fake_call_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Harness helpers
// ---------------------------------------------------------------------------

/// Plain [pumpScreen] wrapper for tests that do not tap Decline / Hang Up.
///
/// Avoids GoRouter when the test only asserts on static UI — faster and
/// simpler.
Future<void> _pump(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
}) => pumpScreen(
  tester,
  const FakeCallScreen(),
  locale: locale,
  themeMode: themeMode,
);

/// Builds a minimal [GoRouter] that places [FakeCallScreen] at
/// `/fake-call` on top of a blank `/` home route.
///
/// Needed because [FakeCallScreen] calls `context.pop()` (GoRouter
/// extension) for both Decline and Hang Up, which throws when no
/// GoRouter is present in the widget tree.
///
/// [initialLocation] starts at `/` so there is a history entry to pop
/// to. Tests must navigate to `/fake-call` before asserting.
GoRouter _buildRouter() => GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Home')),
      ),
    ),
    GoRoute(
      path: '/fake-call',
      builder: (context, state) => const FakeCallScreen(),
    ),
  ],
);

/// Pumps [FakeCallScreen] inside a GoRouter-aware harness.
///
/// Necessary for tests that exercise Decline and Hang Up (both call
/// `context.pop()`).
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
  // -------------------------------------------------------------------------
  group('FakeCallScreen — scaffold & background', () {
    testWidgets('renders a Scaffold with a black background', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      check(scaffold.backgroundColor).equals(Colors.black);
    });

    testWidgets('renders the incoming-call title string', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(find.text(l10n.fakeCallTitle), findsOneWidget);
    });

    testWidgets('shows the unknown-caller label by default', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(find.text(l10n.fakeCallUnknownCaller), findsOneWidget);
    });

    testWidgets(
      'shows a CircleAvatar with fallback person icon (no photo)',
      (WidgetTester tester) async {
        await _pump(tester);
        expect(find.byType(CircleAvatar), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(CircleAvatar),
            matching: find.byIcon(Icons.person),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('wraps the body in a PopScope', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      expect(find.byType(PopScope), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  group('FakeCallScreen — incoming state', () {
    testWidgets('shows both Decline and Answer text labels', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(find.text(l10n.fakeCallDecline), findsOneWidget);
      expect(find.text(l10n.fakeCallAnswer), findsOneWidget);
    });

    testWidgets(
      'shows both call icons (call and call_end) in incoming state',
      (WidgetTester tester) async {
        await _pump(tester);
        expect(find.byIcon(Icons.call), findsOneWidget);
        expect(find.byIcon(Icons.call_end), findsOneWidget);
      },
    );

    testWidgets(
      'does NOT show the Hang Up button in the incoming state',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await _pump(tester);
        expect(find.text(l10n.fakeCallHangUp), findsNothing);
      },
    );

    testWidgets(
      'renders exactly two FloatingActionButtons in incoming state',
      (WidgetTester tester) async {
        await _pump(tester);
        // _CallActionButton uses FloatingActionButton.large.
        expect(find.byType(FloatingActionButton), findsNWidgets(2));
      },
    );

    testWidgets(
      'Decline FAB (index 0 in Row) has a red background',
      (WidgetTester tester) async {
        await _pump(tester);
        // The Row children are: Decline (index 0), Answer (index 1).
        final fabs = tester.widgetList<FloatingActionButton>(
          find.byType(FloatingActionButton),
        ).toList();
        expect(fabs.length, 2);
        check(fabs[0].backgroundColor).equals(Colors.red);
      },
    );

    testWidgets(
      'Answer FAB (index 1 in Row) has a green background',
      (WidgetTester tester) async {
        await _pump(tester);
        final fabs = tester.widgetList<FloatingActionButton>(
          find.byType(FloatingActionButton),
        ).toList();
        expect(fabs.length, 2);
        check(fabs[1].backgroundColor).equals(Colors.green);
      },
    );
  });

  // -------------------------------------------------------------------------
  group('FakeCallScreen — Answer interaction (answered state)', () {
    testWidgets(
      'tapping the answer icon transitions to answered state',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await _pump(tester);

        // Tap the green call icon (answer).
        await tester.tap(find.byIcon(Icons.call));
        await tester.pumpAndSettle();

        // Answered state: Hang Up visible; Answer/Decline gone.
        expect(find.text(l10n.fakeCallHangUp), findsOneWidget);
        expect(find.text(l10n.fakeCallAnswer), findsNothing);
        expect(find.text(l10n.fakeCallDecline), findsNothing);
      },
    );

    testWidgets(
      'answered state renders exactly one FilledButton (Hang Up)',
      (WidgetTester tester) async {
        await _pump(tester);
        await tester.tap(find.byIcon(Icons.call));
        await tester.pumpAndSettle();

        expect(find.byType(FilledButton), findsOneWidget);
      },
    );

    testWidgets(
      'answered state still shows the caller avatar',
      (WidgetTester tester) async {
        await _pump(tester);
        await tester.tap(find.byIcon(Icons.call));
        await tester.pumpAndSettle();

        expect(find.byType(CircleAvatar), findsOneWidget);
      },
    );

    testWidgets(
      'answered state has no FloatingActionButtons',
      (WidgetTester tester) async {
        await _pump(tester);
        await tester.tap(find.byIcon(Icons.call));
        await tester.pumpAndSettle();

        expect(find.byType(FloatingActionButton), findsNothing);
      },
    );

    testWidgets(
      'answered state Hang Up button carries a call_end icon',
      (WidgetTester tester) async {
        await _pump(tester);
        await tester.tap(find.byIcon(Icons.call));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.call_end), findsOneWidget);
      },
    );
  });

  // -------------------------------------------------------------------------
  group('FakeCallScreen — Decline interaction', () {
    testWidgets(
      'tapping Decline pops the GoRouter stack back to home',
      (WidgetTester tester) async {
        final router = _buildRouter();
        await _pumpWithRouter(tester, router: router);
        // Start at '/', push '/fake-call' so there is history to pop.
        // router.push returns a Future that only resolves when the route
        // is popped — do NOT await it or the test deadlocks.
        unawaited(router.push<void>('/fake-call'));
        await tester.pumpAndSettle();

        final l10n = await loadL10n(const Locale('en'));
        expect(find.text(l10n.fakeCallDecline), findsOneWidget);

        // Tap the red call_end icon (Decline).
        await tester.tap(find.byIcon(Icons.call_end));
        await tester.pumpAndSettle();

        // After pop, FakeCallScreen is gone; home scaffold is shown.
        expect(find.text('Home'), findsOneWidget);
        expect(find.text(l10n.fakeCallDecline), findsNothing);
      },
    );
  });

  // -------------------------------------------------------------------------
  group('FakeCallScreen — Hang Up interaction', () {
    testWidgets(
      'tapping Hang Up pops the GoRouter stack back to home',
      (WidgetTester tester) async {
        final router = _buildRouter();
        await _pumpWithRouter(tester, router: router);
        // Push '/fake-call' on top of '/' so there is history to pop.
        // router.push returns a Future that only resolves when the route
        // is popped — do NOT await it or the test deadlocks.
        unawaited(router.push<void>('/fake-call'));
        await tester.pumpAndSettle();

        final l10n = await loadL10n(const Locale('en'));

        // Answer the call first.
        await tester.tap(find.byIcon(Icons.call));
        await tester.pumpAndSettle();
        expect(find.text(l10n.fakeCallHangUp), findsOneWidget);

        // Hang up.
        await tester.tap(find.text(l10n.fakeCallHangUp));
        await tester.pumpAndSettle();

        expect(find.text('Home'), findsOneWidget);
        expect(find.text(l10n.fakeCallHangUp), findsNothing);
      },
    );
  });

  // -------------------------------------------------------------------------
  group('FakeCallScreen — PopScope (back blocked)', () {
    testWidgets(
      'PopScope has canPop = false so system back is blocked',
      (WidgetTester tester) async {
        await _pump(tester);
        final popScope = tester.widget<PopScope>(find.byType(PopScope));
        check(popScope.canPop).isFalse();
      },
    );
  });

  // -------------------------------------------------------------------------
  group('FakeCallScreen — RTL', () {
    testWidgets(
      'renders in Arabic (RTL) without overflow or exception',
      (WidgetTester tester) async {
        await _pump(tester, locale: const Locale('ar'));
        expect(tester.takeException(), isNull);
        final l10n = await loadL10n(const Locale('ar'));
        expect(find.text(l10n.fakeCallDecline), findsOneWidget);
        expect(find.text(l10n.fakeCallAnswer), findsOneWidget);
      },
    );
  });

  // -------------------------------------------------------------------------
  group('FakeCallScreen — dark mode', () {
    testWidgets(
      'renders without exception in dark mode (incoming state)',
      (WidgetTester tester) async {
        await _pump(tester, themeMode: ThemeMode.dark);
        expect(tester.takeException(), isNull);
        final l10n = await loadL10n(const Locale('en'));
        expect(find.text(l10n.fakeCallTitle), findsOneWidget);
      },
    );

    testWidgets(
      'renders without exception in dark mode (answered state)',
      (WidgetTester tester) async {
        await _pump(tester, themeMode: ThemeMode.dark);
        await tester.tap(find.byIcon(Icons.call));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final l10n = await loadL10n(const Locale('en'));
        expect(find.text(l10n.fakeCallHangUp), findsOneWidget);
      },
    );
  });

  // -------------------------------------------------------------------------
  group('FakeCallScreen — accessibility', () {
    testWidgets(
      'Decline label is visible in the widget tree',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await _pump(tester);
        expect(find.text(l10n.fakeCallDecline), findsOneWidget);
      },
    );

    testWidgets(
      'Answer label is visible in the widget tree',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await _pump(tester);
        expect(find.text(l10n.fakeCallAnswer), findsOneWidget);
      },
    );

    testWidgets(
      'Hang Up label is visible after answering',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await _pump(tester);
        await tester.tap(find.byIcon(Icons.call));
        await tester.pumpAndSettle();
        expect(find.text(l10n.fakeCallHangUp), findsOneWidget);
      },
    );

    testWidgets(
      'Decline FAB is reachable by semantics label',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await _pump(tester);
        // FloatingActionButton.large uses heroTag as the Tooltip/
        // Semantics label when no explicit tooltip is set.
        expect(
          find.bySemanticsLabel(l10n.fakeCallDecline),
          findsWidgets,
        );
      },
    );

    testWidgets(
      'Answer FAB is reachable by semantics label',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await _pump(tester);
        expect(
          find.bySemanticsLabel(l10n.fakeCallAnswer),
          findsWidgets,
        );
      },
    );
  });

  // -------------------------------------------------------------------------
  group('FakeCallScreen — caller avatar', () {
    testWidgets(
      'CircleAvatar radius is 48',
      (WidgetTester tester) async {
        await _pump(tester);
        final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
        check(avatar.radius).equals(48);
      },
    );

    testWidgets(
      'fallback person icon inside CircleAvatar has size 48',
      (WidgetTester tester) async {
        await _pump(tester);
        final icon = tester.widget<Icon>(
          find.descendant(
            of: find.byType(CircleAvatar),
            matching: find.byIcon(Icons.person),
          ),
        );
        check(icon.size).equals(48);
      },
    );
  });

  // -------------------------------------------------------------------------
  group('FakeCallScreen — l10n brand keys (future CallStyle)', () {
    // The current screen does not yet render per-style brand strings;
    // these tests verify that the l10n keys resolve without throwing,
    // future-proofing when CallStyle is wired up (spec §1048-1054).
    testWidgets(
      'fakeCallIncomingWhatsapp l10n key resolves without error',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        check(l10n.fakeCallIncomingWhatsapp).isNotEmpty();
      },
    );

    testWidgets(
      'fakeCallIncomingTelegram l10n key resolves without error',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        check(l10n.fakeCallIncomingTelegram).isNotEmpty();
      },
    );

    testWidgets(
      'fakeCallIncomingSignal l10n key resolves without error',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        check(l10n.fakeCallIncomingSignal).isNotEmpty();
      },
    );

    testWidgets(
      'fakeCallBrandWhatsapp l10n key resolves without error',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        check(l10n.fakeCallBrandWhatsapp).isNotEmpty();
      },
    );

    testWidgets(
      'fakeCallBrandTelegram l10n key resolves without error',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        check(l10n.fakeCallBrandTelegram).isNotEmpty();
      },
    );
  });
}
