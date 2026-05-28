/// Alchemist golden tests for [SessionScreen] with the distress-confirmation
/// overlay active.
///
/// Six scenarios covering light / dark theme and RTL locale, each at two
/// countdown values (10 s — start of window, 3 s — near expiry).
///
/// Run to regenerate snapshots:
///   flutter test \
///     test/features/session/session_screen_distress_confirmation_golden_test.dart \
///     --update-goldens
///
/// Run to verify:
///   flutter test \
///     test/features/session/session_screen_distress_confirmation_golden_test.dart
library;

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/features/session/session_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/sim/quick_exit_service_sim.dart';

// ---------------------------------------------------------------------------
// Fake controller — mirrors the one in session_screen_test.dart.
// ---------------------------------------------------------------------------

/// Fake [SessionController] that returns [_initial] from [build] and records
/// calls. The distress path is exercised by constructing the state with a
/// non-null [SessionState.distressConfirmRemaining] — no real engine needed.
class _FakeSessionController extends SessionController {
  _FakeSessionController(this._initial);

  final SessionState _initial;

  @override
  Future<SessionState> build() async => _initial;

  @override
  Future<void> endSession({EndReason reason = EndReason.userQuit}) async {
    final s = state.value ?? const SessionState.initial();
    state = AsyncData(s.copyWith(phase: SessionPhase.ended));
  }

  @override
  void disarm() {}

  @override
  void cancelDistress() {
    final s = state.value;
    if (s == null) return;
    state = AsyncData(s.copyWith(clearDistressConfirm: true));
  }

  @override
  void holdPressed() {}

  @override
  void holdReleased() {}

  @override
  void acknowledgeInterruptedPrompt() {
    final s = state.value;
    if (s == null) return;
    state = AsyncData(s.copyWith(clearPrior: true));
  }

  @override
  void setGpsDestination({required double lat, required double lng}) {
    final s = state.value;
    if (s == null) return;
    state = AsyncData(s.copyWith(needsGpsDestinationPrompt: false));
  }

  @override
  void skipGpsDestination() {
    final s = state.value;
    if (s == null) return;
    state = AsyncData(s.copyWith(needsGpsDestinationPrompt: false));
  }

  @override
  Future<void> triggerQuickExit() async {}

  @override
  void setSimulationSilent(bool value) {}

  @override
  void setSimulationSpeed(double value) {}

  @override
  void leap() {}
}

// ---------------------------------------------------------------------------
// State factory
// ---------------------------------------------------------------------------

/// Builds a [SessionState] whose distress-confirmation overlay is visible.
///
/// [distressConfirmRemaining] must be non-null; the overlay renders when it
/// is non-null (spec 04 §Distress Confirmation Window).
SessionState _distressState({required int distressConfirmRemaining}) {
  final step = ChainStep(
    id: 'golden-step',
    type: ChainStepType.holdButton,
    order: 0,
    waitSeconds: 0,
    durationSeconds: 30,
    gracePeriodSeconds: 5,
    retryCount: 0,
    randomize: false,
  );
  return SessionState(
    isSimulation: false,
    elapsedSeconds: 42,
    phase: SessionPhase.holding,
    activeChain: <ChainStep>[step],
    currentStepIndex: 0,
    missCount: 0,
    isHolding: false,
    isPaused: false,
    isDistressChain: false,
    remainingSeconds: 15,
    distressConfirmRemaining: distressConfirmRemaining,
  );
}

// ---------------------------------------------------------------------------
// Harness helpers
// ---------------------------------------------------------------------------

/// Returns a [ThemeData] suitable for the given [brightness].
ThemeData _theme(Brightness brightness) => ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF131118),
    brightness: brightness,
  ),
  useMaterial3: true,
);

/// Builds the [ProviderScope] + [MaterialApp] wrapper used as the
/// [pumpWidget] callback for every [goldenTest] call.
///
/// Alchemist calls [pumpWidget] with the already-wrapped [widget] (i.e. the
/// [FlutterGoldenTestWrapper] subtree). We re-wrap it in [ProviderScope] and
/// [MaterialApp] so Riverpod providers and localization delegates resolve.
PumpWidget _harness({
  required _FakeSessionController fake,
  required Locale locale,
  required Brightness brightness,
}) =>
    (WidgetTester tester, Widget widget) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionControllerProvider.overrideWith(() => fake),
            quickExitServiceProvider.overrideWith(
              (_) => SimulationQuickExitService(),
            ),
          ],
          child: MaterialApp(
            locale: locale,
            localizationsDelegates: const <LocalizationsDelegate<Object>>[
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            theme: _theme(Brightness.light),
            darkTheme: _theme(Brightness.dark),
            themeMode: brightness == Brightness.dark
                ? ThemeMode.dark
                : ThemeMode.light,
            home: widget,
          ),
        ),
      );
    };

// ---------------------------------------------------------------------------
// Golden tests
// ---------------------------------------------------------------------------

void main() {
  group('SessionScreen — distress confirmation overlay', () {
    // ── Scenario 1: light, 10 s ─────────────────────────────────────────────
    goldenTest(
      'light theme — countdown 10 s (start of window)',
      fileName: 'distress_confirmation_light_10s',
      constraints: const BoxConstraints(maxWidth: 390, maxHeight: 844),
      pumpWidget: _harness(
        fake: _FakeSessionController(_distressState(distressConfirmRemaining: 10)),
        locale: const Locale('en'),
        brightness: Brightness.light,
      ),
      builder: () => GoldenTestGroup(
        columns: 1,
        scenarioConstraints: BoxConstraints.tight(const Size(390, 844)),
        children: <Widget>[
          GoldenTestScenario(
            name: 'light / 10 s',
            child: const SessionScreen(),
          ),
        ],
      ),
    );

    // ── Scenario 2: light, 3 s ──────────────────────────────────────────────
    goldenTest(
      'light theme — countdown 3 s (near expiry)',
      fileName: 'distress_confirmation_light_3s',
      constraints: const BoxConstraints(maxWidth: 390, maxHeight: 844),
      pumpWidget: _harness(
        fake: _FakeSessionController(_distressState(distressConfirmRemaining: 3)),
        locale: const Locale('en'),
        brightness: Brightness.light,
      ),
      builder: () => GoldenTestGroup(
        columns: 1,
        scenarioConstraints: BoxConstraints.tight(const Size(390, 844)),
        children: <Widget>[
          GoldenTestScenario(
            name: 'light / 3 s',
            child: const SessionScreen(),
          ),
        ],
      ),
    );

    // ── Scenario 3: dark, 10 s ──────────────────────────────────────────────
    goldenTest(
      'dark theme — countdown 10 s (start of window)',
      fileName: 'distress_confirmation_dark_10s',
      constraints: const BoxConstraints(maxWidth: 390, maxHeight: 844),
      pumpWidget: _harness(
        fake: _FakeSessionController(_distressState(distressConfirmRemaining: 10)),
        locale: const Locale('en'),
        brightness: Brightness.dark,
      ),
      builder: () => GoldenTestGroup(
        columns: 1,
        scenarioConstraints: BoxConstraints.tight(const Size(390, 844)),
        children: <Widget>[
          GoldenTestScenario(
            name: 'dark / 10 s',
            child: const SessionScreen(),
          ),
        ],
      ),
    );

    // ── Scenario 4: dark, 3 s ───────────────────────────────────────────────
    goldenTest(
      'dark theme — countdown 3 s (near expiry)',
      fileName: 'distress_confirmation_dark_3s',
      constraints: const BoxConstraints(maxWidth: 390, maxHeight: 844),
      pumpWidget: _harness(
        fake: _FakeSessionController(_distressState(distressConfirmRemaining: 3)),
        locale: const Locale('en'),
        brightness: Brightness.dark,
      ),
      builder: () => GoldenTestGroup(
        columns: 1,
        scenarioConstraints: BoxConstraints.tight(const Size(390, 844)),
        children: <Widget>[
          GoldenTestScenario(
            name: 'dark / 3 s',
            child: const SessionScreen(),
          ),
        ],
      ),
    );

    // ── Scenario 5: RTL, 10 s ───────────────────────────────────────────────
    goldenTest(
      'RTL (Arabic) — countdown 10 s (start of window)',
      fileName: 'distress_confirmation_rtl_10s',
      constraints: const BoxConstraints(maxWidth: 390, maxHeight: 844),
      pumpWidget: _harness(
        fake: _FakeSessionController(_distressState(distressConfirmRemaining: 10)),
        locale: const Locale('ar'),
        brightness: Brightness.light,
      ),
      builder: () => GoldenTestGroup(
        columns: 1,
        scenarioConstraints: BoxConstraints.tight(const Size(390, 844)),
        children: <Widget>[
          GoldenTestScenario(
            name: 'RTL / 10 s',
            child: const SessionScreen(),
          ),
        ],
      ),
    );

    // ── Scenario 6: RTL, 3 s ────────────────────────────────────────────────
    goldenTest(
      'RTL (Arabic) — countdown 3 s (near expiry)',
      fileName: 'distress_confirmation_rtl_3s',
      constraints: const BoxConstraints(maxWidth: 390, maxHeight: 844),
      pumpWidget: _harness(
        fake: _FakeSessionController(_distressState(distressConfirmRemaining: 3)),
        locale: const Locale('ar'),
        brightness: Brightness.light,
      ),
      builder: () => GoldenTestGroup(
        columns: 1,
        scenarioConstraints: BoxConstraints.tight(const Size(390, 844)),
        children: <Widget>[
          GoldenTestScenario(
            name: 'RTL / 3 s',
            child: const SessionScreen(),
          ),
        ],
      ),
    );
  });
}
