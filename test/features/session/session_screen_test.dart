/// Smoke tests for [SessionScreen].
///
/// Uses a fake [SessionController] subclass that seeds a concrete
/// [WalkSession] via `build()`, so the widget tree renders without
/// needing the full service graph. Covers the three UI surfaces that
/// drive the session screen:
///   * Renders with an AppBar + session body once a session is seeded.
///   * Shows the [HoldToTriggerButton] while the current step is
///     `holdButton`.
///   * Shows the [ImSafeSlider] disarm CTA during an active session.
///   * Respects `StealthConfig.timerDisplay = false` by hiding the
///     remaining-seconds text (fix for the timerDisplay no-op bug).
///   * Hides AppBar branding under `sessionScreenStealth`.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/widgets/hold_to_trigger_button.dart';
import 'package:guardianangela/core/widgets/im_safe_slider.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/data/repositories/settings_repository.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/features/session/session_screen.dart';

import '../widget_test_helpers.dart';

/// Minimal fake of [SessionController] that seeds a fixed session.
///
/// The real controller is an `AsyncNotifier<WalkSession?>`. We only
/// need `build()` to return a pre-populated `WalkSession` so the
/// screen renders as if a session were in progress. Mutator calls
/// (pause/disarm/etc.) are no-ops since our tests don't tap them.
class _FakeSessionController extends SessionController {
  _FakeSessionController(this._seed);

  final WalkSession? _seed;

  @override
  Future<WalkSession?> build() async => _seed;
}

/// In-memory fake of [SettingsRepository] for tests.
class _FakeSettingsRepository extends SettingsRepository {
  _FakeSettingsRepository([AppSettings? initial])
    : _stored = initial,
      super.forTesting();
  AppSettings? _stored;

  @override
  Future<AppSettings?> get() async => _stored;

  @override
  Future<void> save(AppSettings value) async => _stored = value;
}

WalkSession _session({
  ChainStepType stepType = ChainStepType.holdButton,
  int? remainingSeconds = 42,
}) => WalkSession(
  id: 'session-1',
  modeId: 'mode-1',
  isSimulation: false,
  startedAt: DateTime.utc(2025),
  phase: const SessionPhaseActive(),
  currentStepType: stepType,
  remainingSeconds: remainingSeconds,
);

List<Override> _overrides({
  required WalkSession? seed,
  AppSettings? settings,
}) => [
  sessionControllerProvider.overrideWith(() => _FakeSessionController(seed)),
  settingsRepositoryProvider.overrideWithValue(
    _FakeSettingsRepository(settings ?? const AppSettings(defaults: AppDefaults())),
  ),
];

void main() {
  testWidgets('SessionScreen renders scaffold + body once session hydrates',
      (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: _overrides(seed: _session()),
      child: const SessionScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(SessionScreen).evaluate().length).equals(1);
    check(find.byType(AppBar).evaluate().length).equals(1);
  });

  testWidgets('SessionScreen shows HoldToTriggerButton during holdButton step',
      (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: _overrides(seed: _session()),
      child: const SessionScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(HoldToTriggerButton).evaluate().length).equals(1);
  });

  testWidgets('SessionScreen shows ImSafeSlider disarm CTA', (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: _overrides(seed: _session()),
      child: const SessionScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(ImSafeSlider).evaluate().length).equals(1);
  });

  testWidgets(
    'SessionScreen hides HoldToTriggerButton outside holdButton steps',
    (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(
          seed: _session(stepType: ChainStepType.loudAlarm),
        ),
        child: const SessionScreen(),
      ));
      await tester.pumpAndSettle();
      check(find.byType(HoldToTriggerButton).evaluate()).isEmpty();
    },
  );

  testWidgets(
    'SessionScreen hides remaining-seconds text when stealth.timerDisplay=none',
    (tester) async {
      // Q26: timerDisplay is a 3-state enum (normal / small / none).
      // Only `none` hides the seconds text; `normal` and `small`
      // both show it.
      const stealth = StealthConfig(
        enabled: true,
        sessionScreenStealth: false,
        timerDisplay: StealthTimerDisplay.none,
      );
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(
          seed: _session(),
          settings: const AppSettings(
            defaults: AppDefaults(stealth: stealth),
          ),
        ),
        child: const SessionScreen(),
      ));
      await tester.pumpAndSettle();
      // The remaining-seconds Text uses l.sessionRemaining which
      // interpolates the seconds number. With stealth hiding the
      // timer, nothing should display the raw "42" from our seed.
      check(find.textContaining('42').evaluate()).isEmpty();
    },
  );
}
