/// Widget tests for [EmergencyConfirmOverlay].
///
/// Verifies:
///   * the overlay renders the correct emergency number + countdown;
///   * tapping `[Keep calling]` invokes the supplied dismiss callback;
///   * a successful swipe-to-cancel in *real* mode calls
///     `controller.endSession`;
///   * a successful swipe-to-cancel in *simulation* mode does NOT end
///     the session and surfaces a SnackBar instead;
///   * the [SIM] badge is rendered only in simulation mode.
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/widgets/swipe_slider.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/features/session/widgets/emergency_confirm_overlay.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

/// Fake controller that records [endSession] invocations.
class _FakeSessionController extends SessionController {
  _FakeSessionController(this._initial);

  final SessionState _initial;

  int endSessionCalls = 0;
  EndReason? lastEndReason;

  @override
  Future<SessionState> build() async => _initial;

  @override
  Future<void> endSession({EndReason reason = EndReason.userQuit}) async {
    endSessionCalls++;
    lastEndReason = reason;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ChainStep _emergencyStep({String? number, int confirmationDuration = 5}) =>
    ChainStep(
      id: 'step-em',
      type: ChainStepType.callEmergency,
      order: 0,
      waitSeconds: 0,
      durationSeconds: confirmationDuration,
      gracePeriodSeconds: 0,
      retryCount: 0,
      randomize: false,
      config: CallEmergencyConfig(
        emergencyNumber: number,
        confirmationDurationSeconds: confirmationDuration,
      ),
    );

SessionState _state({
  required bool isSimulation,
  required ChainStep step,
  int remainingSeconds = 5,
}) => SessionState(
  isSimulation: isSimulation,
  elapsedSeconds: 10,
  phase: SessionPhase.duration,
  activeChain: <ChainStep>[step],
  currentStepIndex: 0,
  missCount: 0,
  isHolding: false,
  isPaused: false,
  isDistressChain: false,
  remainingSeconds: remainingSeconds,
);

Future<void> _pump(
  WidgetTester tester, {
  required SessionState state,
  required ChainStep step,
  required _FakeSessionController fake,
  VoidCallback? onKeepCalling,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[sessionControllerProvider.overrideWith(() => fake)],
      child: MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Stack(
            children: <Widget>[
              EmergencyConfirmOverlay(
                state: state,
                step: step,
                onKeepCalling: onKeepCalling ?? () {},
              ),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<AppLocalizations> _loadL10n() =>
    AppLocalizations.delegate.load(const Locale('en'));

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('EmergencyConfirmOverlay — basic render', () {
    testWidgets('renders title with configured emergency number', (
      WidgetTester tester,
    ) async {
      final l10n = await _loadL10n();
      final step = _emergencyStep(number: '999');
      final fake = _FakeSessionController(
        _state(isSimulation: false, step: step),
      );
      await _pump(
        tester,
        state: _state(isSimulation: false, step: step, remainingSeconds: 4),
        step: step,
        fake: fake,
      );
      expect(
        find.text(l10n.sessionEmergencyConfirmTitle('999', 4)),
        findsOneWidget,
      );
    });

    testWidgets('falls back to 112 when no per-step or global number', (
      WidgetTester tester,
    ) async {
      final l10n = await _loadL10n();
      final step = _emergencyStep();
      final fake = _FakeSessionController(
        _state(isSimulation: false, step: step),
      );
      await _pump(
        tester,
        state: _state(isSimulation: false, step: step),
        step: step,
        fake: fake,
      );
      expect(
        find.text(l10n.sessionEmergencyConfirmTitle('112', 5)),
        findsOneWidget,
      );
    });

    testWidgets('renders Keep calling button and SwipeSlider', (
      WidgetTester tester,
    ) async {
      final l10n = await _loadL10n();
      final step = _emergencyStep();
      final fake = _FakeSessionController(
        _state(isSimulation: false, step: step),
      );
      await _pump(
        tester,
        state: _state(isSimulation: false, step: step),
        step: step,
        fake: fake,
      );
      expect(find.text(l10n.sessionEmergencyConfirmKeep), findsOneWidget);
      expect(find.byType(SwipeSlider), findsOneWidget);
      expect(find.byIcon(Icons.emergency), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });

  group('EmergencyConfirmOverlay — Keep calling', () {
    testWidgets('tapping Keep calling invokes onKeepCalling', (
      WidgetTester tester,
    ) async {
      final l10n = await _loadL10n();
      final step = _emergencyStep();
      final fake = _FakeSessionController(
        _state(isSimulation: false, step: step),
      );
      var dismissCount = 0;
      await _pump(
        tester,
        state: _state(isSimulation: false, step: step),
        step: step,
        fake: fake,
        onKeepCalling: () => dismissCount++,
      );
      await tester.tap(find.text(l10n.sessionEmergencyConfirmKeep));
      await tester.pumpAndSettle();
      check(dismissCount).equals(1);
      check(fake.endSessionCalls).equals(0);
    });
  });

  group('EmergencyConfirmOverlay — Swipe to cancel (real mode)', () {
    testWidgets('swipe past threshold calls endSession', (
      WidgetTester tester,
    ) async {
      final step = _emergencyStep();
      final fake = _FakeSessionController(
        _state(isSimulation: false, step: step),
      );
      await _pump(
        tester,
        state: _state(isSimulation: false, step: step),
        step: step,
        fake: fake,
      );
      final slider = find.byType(SwipeSlider);
      final start = tester.getCenter(slider);
      final gesture = await tester.startGesture(start);
      await gesture.moveBy(const Offset(400, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      check(fake.endSessionCalls).equals(1);
      check(fake.lastEndReason).equals(EndReason.userQuit);
    });
  });

  group('EmergencyConfirmOverlay — Swipe to cancel (simulation)', () {
    testWidgets('shows SnackBar and does NOT call endSession', (
      WidgetTester tester,
    ) async {
      final l10n = await _loadL10n();
      final step = _emergencyStep();
      final fake = _FakeSessionController(
        _state(isSimulation: true, step: step),
      );
      var dismissCount = 0;
      await _pump(
        tester,
        state: _state(isSimulation: true, step: step),
        step: step,
        fake: fake,
        onKeepCalling: () => dismissCount++,
      );
      final slider = find.byType(SwipeSlider);
      final start = tester.getCenter(slider);
      final gesture = await tester.startGesture(start);
      await gesture.moveBy(const Offset(400, 0));
      await tester.pump();
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 100));
      // SnackBar visible.
      expect(
        find.text(l10n.sessionEmergencyConfirmSimCancelled),
        findsOneWidget,
      );
      check(fake.endSessionCalls).equals(0);
      check(dismissCount).equals(1);
      // Settle to ensure SnackBar's timer completes cleanly.
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('renders [SIM] badge when in simulation', (
      WidgetTester tester,
    ) async {
      final l10n = await _loadL10n();
      final step = _emergencyStep();
      final fake = _FakeSessionController(
        _state(isSimulation: true, step: step),
      );
      await _pump(
        tester,
        state: _state(isSimulation: true, step: step),
        step: step,
        fake: fake,
      );
      expect(find.text(l10n.sessionEmergencyConfirmSimBadge), findsOneWidget);
    });

    testWidgets('does NOT render [SIM] badge in real mode', (
      WidgetTester tester,
    ) async {
      final l10n = await _loadL10n();
      final step = _emergencyStep();
      final fake = _FakeSessionController(
        _state(isSimulation: false, step: step),
      );
      await _pump(
        tester,
        state: _state(isSimulation: false, step: step),
        step: step,
        fake: fake,
      );
      expect(find.text(l10n.sessionEmergencyConfirmSimBadge), findsNothing);
    });
  });

  group('EmergencyConfirmOverlay — global number fallback', () {
    testWidgets('uses globalEmergencyNumber when per-step is null', (
      WidgetTester tester,
    ) async {
      final l10n = await _loadL10n();
      final step = _emergencyStep();
      final fake = _FakeSessionController(
        _state(isSimulation: false, step: step),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            sessionControllerProvider.overrideWith(() => fake),
          ],
          child: MaterialApp(
            localizationsDelegates: const <LocalizationsDelegate<Object>>[
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Stack(
                children: <Widget>[
                  EmergencyConfirmOverlay(
                    state: _state(isSimulation: false, step: step),
                    step: step,
                    onKeepCalling: () {},
                    globalEmergencyNumber: '911',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(l10n.sessionEmergencyConfirmTitle('911', 5)),
        findsOneWidget,
      );
    });
  });
}
