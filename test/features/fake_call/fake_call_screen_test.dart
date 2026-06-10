/// Widget tests for [FakeCallScreen].
///
/// Covers all 5 call styles (Android-native, iOS-native, WhatsApp,
/// Telegram, Signal), slide-to-answer mechanics, declineIsSafe label
/// variants, voice/vibration indicators, and the hold-to-distress
/// trigger (exercised with a 1-second configured hold). Each scenario
/// gives the screen a [FakeCallConfig] which it renders directly.
///
/// Spec reference: docs/spec/04-screens-navigation.md §Fake Call Screen
/// (lines 1044–1159).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/call_style.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/features/fake_call/fake_call_controller.dart';
import 'package:guardianangela/features/fake_call/fake_call_screen.dart';
import 'package:guardianangela/features/session/session_controller.dart';
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
GoRouter _buildRouter({
  FakeCallConfig config = const FakeCallConfig(),
  DateTime Function() now = DateTime.now,
}) => GoRouter(
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
          FakeCallScreen(config: config, now: now),
    ),
  ],
);

Future<void> _pumpWithRouter(
  WidgetTester tester, {
  required GoRouter router,
  List<Override> overrides = const <Override>[],
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
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

/// A [SessionController] whose state the test can push, to drive the
/// [SessionState.fakeCallCancelNonce] that dismisses the screen when a real
/// call cancels the fake call (spec 01 §Real Phone Call During Fake Call).
class _NonceController extends SessionController {
  _NonceController(this._initial);

  final SessionState _initial;

  int answerCalls = 0;
  int hangUpCalls = 0;
  int confirmDistressCalls = 0;

  @override
  Future<SessionState> build() async => _initial;

  void emit(SessionState next) => state = AsyncData(next);

  @override
  Future<void> answerFakeCall({
    String? voiceRecordingPath,
    bool useSpeaker = false,
  }) async => answerCalls++;

  @override
  void hangUpFakeCall() => hangUpCalls++;

  @override
  void confirmDistress({EndReason reason = EndReason.hardwarePanic}) =>
      confirmDistressCalls++;
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
  group('FakeCallScreen — real-call cancel (#11 / Extra-24/25)', () {
    testWidgets('dismisses itself when a real incoming call bumps '
        'fakeCallCancelNonce', (WidgetTester tester) async {
      final fake = _NonceController(const SessionState.initial());
      final router = _buildRouter();
      await _pumpWithRouter(
        tester,
        router: router,
        overrides: <Override>[
          sessionControllerProvider.overrideWith(() => fake),
        ],
      );
      unawaited(router.push<void>('/fake-call'));
      await tester.pumpAndSettle();
      // Shown, and NOT dismissed on mount (baseline nonce captured).
      expect(find.byType(FakeCallScreen), findsOneWidget);

      // A real call cancels the fake call → the controller bumps the nonce.
      fake.emit(const SessionState.initial().copyWith(fakeCallCancelNonce: 1));
      await tester.pumpAndSettle();

      expect(find.byType(FakeCallScreen), findsNothing);
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
  group('FakeCallScreen — hang up', () {
    testWidgets('tapping Hang Up notifies the controller and pops the route', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _NonceController(const SessionState.initial());
      final router = _buildRouter();
      await _pumpWithRouter(
        tester,
        router: router,
        overrides: <Override>[
          sessionControllerProvider.overrideWith(() => fake),
        ],
      );
      unawaited(router.push<void>('/fake-call'));
      await tester.pumpAndSettle();

      // Answer first (slide), then hang up.
      await tester.drag(find.byIcon(Icons.call), const Offset(1200, 0));
      await tester.pumpAndSettle();
      check(fake.answerCalls).equals(1);

      await tester.tap(find.text(l10n.fakeCallHangUp));
      await tester.pumpAndSettle();

      // Hang-up after answering disarms via the controller and closes the
      // call screen (spec 02 §fakeCall Answer / Hang-up Semantics). It must
      // NOT escalate: no distress confirm (core bias — err toward not
      // escalating).
      check(fake.hangUpCalls).equals(1);
      check(fake.confirmDistressCalls).equals(0);
      expect(find.byType(FakeCallScreen), findsNothing);
      expect(find.text('Home'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  group('FakeCallScreen — hold-to-distress completes', () {
    testWidgets('holding decline for the configured duration fires distress, '
        'haptics at 800 ms, and pops the call', (WidgetTester tester) async {
      var hapticCalls = 0;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'HapticFeedback.vibrate') hapticCalls++;
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      final fake = _NonceController(const SessionState.initial());
      const config = FakeCallConfig(declineWithDistressHoldSeconds: 1);
      // Deterministic clock seam: the hold ticker measures elapsed time via
      // FakeCallScreen.now, which the loop below advances in lockstep with
      // the fake-async timer pumps — no wall-clock dependence.
      var fakeNow = DateTime(2026);
      final router = _buildRouter(config: config, now: () => fakeNow);
      await _pumpWithRouter(
        tester,
        router: router,
        overrides: <Override>[
          sessionControllerProvider.overrideWith(() => fake),
        ],
      );
      unawaited(router.push<void>('/fake-call'));
      await tester.pumpAndSettle();

      // Press and HOLD the decline button: long-press start arms the
      // 80 ms hold ticker (hold start reads the injected clock).
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(FilledButton)),
      );
      await tester.pump(const Duration(milliseconds: 600));

      // Drive the ticker deterministically: each iteration advances the
      // injected clock by 80 ms, then pumps one 80 ms timer tick, so tick k
      // sees elapsed = k*80 ms (haptic at tick 10 = 800 ms, completion at
      // tick 13 = 1040 ms >= 1 s). The stopwatch is only a runaway backstop.
      final sw = Stopwatch()..start();
      while (fake.confirmDistressCalls == 0 &&
          sw.elapsed < const Duration(seconds: 10)) {
        fakeNow = fakeNow.add(const Duration(milliseconds: 80));
        await tester.pump(const Duration(milliseconds: 80));
      }
      await gesture.up();
      await tester.pumpAndSettle();

      // 1.0 progress fired the distress chain exactly once …
      check(fake.confirmDistressCalls).equals(1);
      // … the spec'd mid-hold haptic pulse fired (spec 04:1130) …
      check(hapticCalls).isGreaterOrEqual(1);
      // … and the call screen dismissed itself.
      expect(find.byType(FakeCallScreen), findsNothing);
      expect(find.text('Home'), findsOneWidget);
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

    testWidgets('the active ticker keeps the mm:ss timer rendering', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester);
      await tester.drag(find.byIcon(Icons.call), const Offset(1200, 0));
      await tester.pumpAndSettle();

      // Fire the 1 s active ticker twice; the elapsed label must keep
      // rendering a well-formed duration (wall-clock barely moved).
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
      expect(
        find.text(l10n.fakeCallActiveDuration('00', '00')),
        findsOneWidget,
      );
    });

    testWidgets('answered state shows unknown-caller label for empty name', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, config: const FakeCallConfig(callerName: ''));
      await tester.drag(find.byIcon(Icons.call), const Offset(1200, 0));
      await tester.pumpAndSettle();
      expect(find.text(l10n.fakeCallUnknownCaller), findsOneWidget);
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

    test('answer() forces the active phase with a completed slide', () {
      final controller = FakeCallController(const FakeCallConfig());
      addTearDown(controller.dispose);
      controller.answer();
      expect(controller.value.phase, FakeCallPhase.active);
      expect(controller.value.slideProgress, 1.0);
    });

    test('tickActive publishes the elapsed call duration', () {
      final controller = FakeCallController(const FakeCallConfig());
      addTearDown(controller.dispose);
      controller.answer();
      controller.tickActive(const Duration(seconds: 75));
      expect(controller.value.activeElapsed, const Duration(seconds: 75));
    });
  });
}
