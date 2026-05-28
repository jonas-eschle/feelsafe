/// Widget tests for [FakeCallScreen].
///
/// Covers all 5 call styles (Android-native, iOS-native, WhatsApp,
/// Telegram, Signal), slide-to-answer mechanics, declineIsSafe label
/// variants, voice/vibration indicators, and the hold-5s distress
/// trigger. Each scenario gives the screen a [FakeCallConfig] which it
/// renders directly.
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

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/call_style.dart';
import 'package:guardianangela/features/fake_call/fake_call_controller.dart';
import 'package:guardianangela/features/fake_call/fake_call_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Harness helpers
// ---------------------------------------------------------------------------

/// Plain [pumpScreen] wrapper used for tests that do not pop navigation.
Future<void> _pump(
  WidgetTester tester, {
  FakeCallConfig config = const FakeCallConfig(),
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
}) => pumpScreen(
  tester,
  FakeCallScreen(config: config),
  locale: locale,
  themeMode: themeMode,
);

/// Builds a minimal [GoRouter] that places [FakeCallScreen] at
/// `/fake-call` on top of a blank `/` home route.
GoRouter _buildRouter({FakeCallConfig config = const FakeCallConfig()}) =>
    GoRouter(
      initialLocation: '/',
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const Scaffold(body: Center(child: Text('Home'))),
        ),
        GoRoute(
          path: '/fake-call',
          builder: (BuildContext context, GoRouterState state) =>
              FakeCallScreen(config: config),
        ),
      ],
    );

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
  group('FakeCallScreen — scaffold & background', () {
    testWidgets('renders a Scaffold with PopScope blocking back', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      final popScope = tester.widget<PopScope<Object?>>(find.byType(PopScope));
      check(popScope.canPop).isFalse();
    });

    testWidgets('renders default caller name "Angela"', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      expect(find.text('Angela'), findsOneWidget);
    });

    testWidgets('renders unknown-caller label when callerName is empty', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, config: const FakeCallConfig(callerName: ''));
      expect(find.text(l10n.fakeCallUnknownCaller), findsOneWidget);
    });

    testWidgets('renders caller avatar', (WidgetTester tester) async {
      await _pump(tester);
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(CircleAvatar),
          matching: find.byIcon(Icons.person),
        ),
        findsOneWidget,
      );
    });
  });

  // -------------------------------------------------------------------------
  group('FakeCallScreen — 5 call styles', () {
    testWidgets('Android-native style renders Phone brand badge', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        config: const FakeCallConfig(callStyle: CallStyle.androidNative),
      );
      expect(find.text(l10n.fakeCallBrandAndroid), findsOneWidget);
    });

    testWidgets('iOS-native style renders Phone brand badge', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        config: const FakeCallConfig(callStyle: CallStyle.iosNative),
      );
      expect(find.text(l10n.fakeCallBrandIos), findsOneWidget);
    });

    testWidgets('WhatsApp style renders WhatsApp incoming header + brand', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        config: const FakeCallConfig(callStyle: CallStyle.whatsapp),
      );
      expect(find.text(l10n.fakeCallIncomingWhatsapp), findsOneWidget);
      expect(find.text(l10n.fakeCallBrandWhatsapp), findsOneWidget);
    });

    testWidgets('Telegram style renders Telegram incoming header + brand', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        config: const FakeCallConfig(callStyle: CallStyle.telegram),
      );
      expect(find.text(l10n.fakeCallIncomingTelegram), findsOneWidget);
      expect(find.text(l10n.fakeCallBrandTelegram), findsOneWidget);
    });

    testWidgets('Signal style renders Signal incoming header + brand', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        config: const FakeCallConfig(callStyle: CallStyle.signal),
      );
      expect(find.text(l10n.fakeCallIncomingSignal), findsOneWidget);
      expect(find.text(l10n.fakeCallBrandSignal), findsOneWidget);
    });

    testWidgets('WhatsApp style uses green background tint', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        config: const FakeCallConfig(callStyle: CallStyle.whatsapp),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      check(scaffold.backgroundColor).equals(const Color(0xFF075E54));
    });

    testWidgets('Minimal style renders generic CALL badge', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        config: const FakeCallConfig(callStyle: CallStyle.minimal),
      );
      expect(find.text(l10n.fakeCallBrandMinimal), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  group('FakeCallScreen — decline button label', () {
    testWidgets("declineIsSafe = true shows \"I'm Safe\" label", (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(find.text(l10n.fakeCallDeclineSafeLabel), findsOneWidget);
    });

    testWidgets('declineIsSafe = false shows "Stay on alert" label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, config: const FakeCallConfig(declineIsSafe: false));
      expect(find.text(l10n.fakeCallDeclineUnsafeLabel), findsOneWidget);
    });

    testWidgets('decline button uses red background', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      final btn = tester.widget<FilledButton>(find.byType(FilledButton));
      check(
        btn.style?.backgroundColor?.resolve(<WidgetState>{}),
      ).equals(Colors.red);
    });
  });

  // -------------------------------------------------------------------------
  group('FakeCallScreen — indicators', () {
    testWidgets('renders vibration indicator chip by default', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      expect(find.byType(Chip), findsAtLeastNWidgets(1));
    });

    testWidgets('voice prompt chip appears when voiceRecordingPath set', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        config: const FakeCallConfig(voiceRecordingPath: 'angela_en'),
      );
      expect(find.text(l10n.fakeCallVoicePrompt('angela_en')), findsOneWidget);
    });

    testWidgets('voice prompt chip omitted when path null', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(
        find.textContaining(l10n.fakeCallVoicePrompt('').split(':').first),
        findsNothing,
      );
    });
  });

  // -------------------------------------------------------------------------
  group('FakeCallScreen — slide-to-answer', () {
    testWidgets('shows slide-to-answer track in incoming state', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(find.text(l10n.fakeCallSlideToAnswerHint), findsOneWidget);
      expect(find.text(l10n.fakeCallSlideToAnswer), findsOneWidget);
    });

    testWidgets('slide ≥ threshold transitions to active state', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      // Drag the slider knob far to the right — well above 0.85.
      await tester.drag(find.byIcon(Icons.call), const Offset(1200, 0));
      await tester.pumpAndSettle();
      // Active state shows the Hang Up label.
      expect(find.text(l10n.fakeCallHangUp), findsOneWidget);
      // And drops the decline button.
      expect(find.text(l10n.fakeCallDeclineSafeLabel), findsNothing);
    });

    testWidgets('partial drag below threshold stays in incoming state', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      await tester.drag(find.byIcon(Icons.call), const Offset(20, 0));
      await tester.pumpAndSettle();
      // Still incoming.
      expect(find.text(l10n.fakeCallDeclineSafeLabel), findsOneWidget);
      expect(find.text(l10n.fakeCallHangUp), findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  group('FakeCallScreen — Decline interaction', () {
    testWidgets('tapping decline pops the route', (WidgetTester tester) async {
      final router = _buildRouter();
      await _pumpWithRouter(tester, router: router);
      unawaited(router.push<void>('/fake-call'));
      await tester.pumpAndSettle();
      final l10n = await loadL10n(const Locale('en'));
      expect(find.text(l10n.fakeCallDeclineSafeLabel), findsOneWidget);
      await tester.tap(find.text(l10n.fakeCallDeclineSafeLabel));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  group('FakeCallScreen — hold-for-distress', () {
    testWidgets('hold-progress hint label is rendered', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      expect(find.text(l10n.fakeCallHoldForDistress), findsOneWidget);
    });

    testWidgets('LinearProgressIndicator absent before hold begins', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('hold gesture surfaces the progress indicator after delay', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      // Trigger long-press start by holding pointer for >500ms.
      final declineFinder = find.byType(FilledButton);
      final gesture = await tester.startGesture(
        tester.getCenter(declineFinder),
      );
      await tester.pump(const Duration(milliseconds: 700));
      // Allow the hold-ticker to surface the LinearProgressIndicator.
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      await gesture.up();
      await tester.pumpAndSettle();
    });
  });

  // -------------------------------------------------------------------------
  group('FakeCallScreen — active state', () {
    testWidgets('answered state shows Hang Up button', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      // Force the slide into active state via gesture.
      await tester.drag(find.byIcon(Icons.call), const Offset(1200, 0));
      await tester.pumpAndSettle();
      expect(find.text(l10n.fakeCallHangUp), findsOneWidget);
    });

    testWidgets('answered state still renders avatar', (
      WidgetTester tester,
    ) async {
      await _pump(tester);
      await tester.drag(find.byIcon(Icons.call), const Offset(1200, 0));
      await tester.pumpAndSettle();
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('answered state shows caller name', (
      WidgetTester tester,
    ) async {
      await _pump(tester, config: const FakeCallConfig(callerName: 'Alex'));
      await tester.drag(find.byIcon(Icons.call), const Offset(1200, 0));
      await tester.pumpAndSettle();
      expect(find.text('Alex'), findsOneWidget);
    });

    testWidgets('answered state shows 00:00 elapsed timer initially', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      await tester.drag(find.byIcon(Icons.call), const Offset(1200, 0));
      await tester.pumpAndSettle();
      expect(
        find.text(l10n.fakeCallActiveDuration('00', '00')),
        findsOneWidget,
      );
    });
  });

  // -------------------------------------------------------------------------
  group('FakeCallScreen — RTL', () {
    testWidgets('renders in Arabic (RTL) without overflow', (
      WidgetTester tester,
    ) async {
      await _pump(tester, locale: const Locale('ar'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in Hebrew (RTL) without overflow', (
      WidgetTester tester,
    ) async {
      await _pump(tester, locale: const Locale('he'));
      expect(tester.takeException(), isNull);
    });
  });

  // -------------------------------------------------------------------------
  group('FakeCallScreen — dark mode', () {
    testWidgets('renders without exception in dark mode (incoming)', (
      WidgetTester tester,
    ) async {
      await _pump(tester, themeMode: ThemeMode.dark);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without exception in dark mode (active)', (
      WidgetTester tester,
    ) async {
      await _pump(tester, themeMode: ThemeMode.dark);
      await tester.drag(find.byIcon(Icons.call), const Offset(1200, 0));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  // -------------------------------------------------------------------------
  group('FakeCallController — unit', () {
    test('initial phase is incoming', () {
      final controller = FakeCallController(const FakeCallConfig());
      addTearDown(controller.dispose);
      expect(controller.value.phase, FakeCallPhase.incoming);
      expect(controller.value.slideProgress, 0.0);
    });

    test('updateSlide above threshold transitions to active', () {
      final controller = FakeCallController(const FakeCallConfig());
      addTearDown(controller.dispose);
      controller.updateSlide(0.9);
      expect(controller.value.phase, FakeCallPhase.active);
    });

    test('releaseSlide before threshold resets progress', () {
      final controller = FakeCallController(const FakeCallConfig());
      addTearDown(controller.dispose);
      controller.updateSlide(0.5);
      controller.releaseSlide();
      expect(controller.value.slideProgress, 0.0);
      expect(controller.value.phase, FakeCallPhase.incoming);
    });
  });
}
