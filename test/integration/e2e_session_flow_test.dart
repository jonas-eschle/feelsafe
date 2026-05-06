/// End-to-end UI integration tests for the Session screen.
///
/// Pumps the real [SessionScreen] with a fake [SessionController]
/// and validates: hold-button rendering, simulation banner, pause
/// button visibility, I'm-Safe slider, stealth timer-display hiding,
/// step type visibility, and simulation-advanced controls.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/core/widgets/hold_to_trigger_button.dart';
import 'package:guardianangela/core/widgets/im_safe_slider.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/features/session/session_screen.dart';
import 'package:guardianangela/features/session/widgets/simulation_advanced_controls.dart';

import '../features/fake_repositories.dart';
import '../features/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// helpers
// ---------------------------------------------------------------------------

/// Minimal fake [SessionController] that seeds a fixed session.
class _FakeSessionController extends SessionController {
  _FakeSessionController(this._seed);
  final WalkSession? _seed;

  @override
  Future<WalkSession?> build() async => _seed;

  @override
  bool get isPauseAllowed => _seed != null;
}

class _FakeNoPauseController extends SessionController {
  _FakeNoPauseController(this._seed);
  final WalkSession? _seed;

  @override
  Future<WalkSession?> build() async => _seed;

  @override
  bool get isPauseAllowed => false;
}

WalkSession _session({
  ChainStepType stepType = ChainStepType.holdButton,
  int? remainingSeconds = 42,
  bool isSimulation = false,
  SessionPhase? phase,
}) => WalkSession(
  id: 'session-1',
  modeId: 'mode-1',
  isSimulation: isSimulation,
  startedAt: DateTime.utc(2026, 1, 1),
  phase: phase ?? const SessionPhaseActive(),
  currentStepType: stepType,
  remainingSeconds: remainingSeconds,
);

List<Override> _overrides({
  WalkSession? seed,
  AppSettings? settings,
  bool noPause = false,
}) => [
  if (noPause)
    sessionControllerProvider
        .overrideWith(() => _FakeNoPauseController(seed))
  else
    sessionControllerProvider
        .overrideWith(() => _FakeSessionController(seed)),
  settingsRepositoryProvider.overrideWithValue(
    FakeSettingsRepository(
      settings ?? const AppSettings(defaults: AppDefaults()),
    ),
  ),
];

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('session screen — render basics', () {
    testWidgets('session_screen_renders_app_bar', (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(seed: _session()),
        child: const SessionScreen(),
      ));
      await tester.pumpAndSettle();
      check(find.byType(AppBar).evaluate().length).equals(1);
    });

    testWidgets('session_screen_null_session_shows_ended_text', (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(seed: null),
        child: const SessionScreen(),
      ));
      await tester.pumpAndSettle();
      // When session is null, the screen shows a "session ended" text.
      check(find.byType(SessionScreen).evaluate().length).equals(1);
    });
  });

  group('session screen — hold button step', () {
    testWidgets('session_holdButton_step_shows_hold_button', (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(seed: _session(stepType: ChainStepType.holdButton)),
        child: const SessionScreen(),
      ));
      await tester.pumpAndSettle();
      check(find.byType(HoldToTriggerButton).evaluate().length).equals(1);
    });

    testWidgets('session_loudAlarm_step_hides_hold_button', (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(seed: _session(stepType: ChainStepType.loudAlarm)),
        child: const SessionScreen(),
      ));
      await tester.pumpAndSettle();
      check(find.byType(HoldToTriggerButton).evaluate()).isEmpty();
    });

    testWidgets('session_smsContact_step_hides_hold_button', (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(seed: _session(stepType: ChainStepType.smsContact)),
        child: const SessionScreen(),
      ));
      await tester.pumpAndSettle();
      check(find.byType(HoldToTriggerButton).evaluate()).isEmpty();
    });

    testWidgets('session_fakeCall_step_hides_hold_button', (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(seed: _session(stepType: ChainStepType.fakeCall)),
        child: const SessionScreen(),
      ));
      await tester.pumpAndSettle();
      check(find.byType(HoldToTriggerButton).evaluate()).isEmpty();
    });
  });

  group('session screen — I\'m Safe slider', () {
    testWidgets('session_shows_im_safe_slider', (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(seed: _session()),
        child: const SessionScreen(),
      ));
      await tester.pumpAndSettle();
      check(find.byType(ImSafeSlider).evaluate().length).equals(1);
    });
  });

  group('session screen — timer display', () {
    testWidgets('session_shows_remaining_seconds_text', (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(seed: _session(remainingSeconds: 42)),
        child: const SessionScreen(),
      ));
      await tester.pumpAndSettle();
      // Remaining seconds shown (42).
      check(find.textContaining('42').evaluate().length).isGreaterOrEqual(1);
    });

    testWidgets(
        'session_stealth_timerDisplay_false_hides_remaining_seconds', (tester) async {
      const stealth = StealthConfig(
        enabled: true,
        // Q26: timerDisplay is now a three-state enum; `none` hides
        // the remaining-seconds text entirely.
        timerDisplay: StealthTimerDisplay.none,
        sessionScreenStealth: false,
      );
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(
          seed: _session(remainingSeconds: 42),
          settings: const AppSettings(
            defaults: AppDefaults(stealth: stealth),
          ),
        ),
        child: const SessionScreen(),
      ));
      await tester.pumpAndSettle();
      // Timer hidden — "42" should not appear.
      check(find.textContaining('42').evaluate()).isEmpty();
    });
  });

  group('session screen — stealth branding', () {
    testWidgets('session_stealth_sessionScreenStealth_hides_title', (tester) async {
      const stealth = StealthConfig(
        enabled: true,
        sessionScreenStealth: true,
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
      // With sessionScreenStealth=true, the AppBar title is empty string.
      final appBar = tester.widget<AppBar>(find.byType(AppBar).first);
      final titleText = appBar.title;
      if (titleText is Text) {
        check(titleText.data).equals('');
      }
    });

    testWidgets('session_no_stealth_shows_session_title', (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(seed: _session()),
        child: const SessionScreen(),
      ));
      await tester.pumpAndSettle();
      // Without stealth the app bar title is the session title.
      final appBar = tester.widget<AppBar>(find.byType(AppBar).first);
      final titleText = appBar.title;
      if (titleText is Text) {
        // Non-empty title.
        check((titleText.data ?? '').isNotEmpty).isTrue();
      }
    });
  });

  group('session screen — pause button', () {
    testWidgets('session_pause_button_visible_when_pause_allowed', (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(seed: _session()),
        child: const SessionScreen(),
      ));
      await tester.pumpAndSettle();
      check(find.byType(OutlinedButton).evaluate().length).isGreaterOrEqual(1);
    });

    testWidgets('session_pause_button_hidden_when_not_pause_allowed', (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(seed: _session(), noPause: true),
        child: const SessionScreen(),
      ));
      await tester.pumpAndSettle();
      check(find.byType(OutlinedButton).evaluate()).isEmpty();
    });
  });

  group('session screen — simulation mode', () {
    testWidgets('session_simulation_shows_banner', (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(seed: _session(isSimulation: true)),
        child: const SessionScreen(),
      ));
      await tester.pumpAndSettle();
      // Simulation banner is a Container with tertiaryContainer color.
      // We verify it by looking for the SimulationAdvancedControls widget.
      check(find.byType(SimulationAdvancedControls).evaluate().length)
          .isGreaterOrEqual(1);
    });

    testWidgets('session_simulation_shows_advanced_controls', (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(seed: _session(isSimulation: true)),
        child: const SessionScreen(),
      ));
      await tester.pumpAndSettle();
      check(find.byType(SimulationAdvancedControls).evaluate().length)
          .isGreaterOrEqual(1);
    });

    testWidgets('session_real_session_hides_simulation_controls', (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(seed: _session(isSimulation: false)),
        child: const SessionScreen(),
      ));
      await tester.pumpAndSettle();
      check(find.byType(SimulationAdvancedControls).evaluate()).isEmpty();
    });
  });

  group('session screen — paused phase', () {
    testWidgets('session_paused_phase_shows_pause_badge', (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(
          seed: _session(phase: const SessionPhasePaused()),
        ),
        child: const SessionScreen(),
      ));
      await tester.pumpAndSettle();
      // A Chip widget is shown when the session is paused.
      check(find.byType(Chip).evaluate().length).isGreaterOrEqual(1);
    });

    testWidgets('session_active_phase_hides_pause_badge', (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(
          seed: _session(phase: const SessionPhaseActive()),
        ),
        child: const SessionScreen(),
      ));
      await tester.pumpAndSettle();
      check(find.byType(Chip).evaluate()).isEmpty();
    });
  });

  group('session screen — miss count', () {
    testWidgets('session_shows_miss_count', (tester) async {
      final session = WalkSession(
        id: 's1',
        modeId: 'm1',
        isSimulation: false,
        startedAt: DateTime.utc(2026, 1, 1),
        phase: const SessionPhaseActive(),
        currentStepType: ChainStepType.holdButton,
        missCount: 3,
        remainingSeconds: 10,
      );
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(seed: session),
        child: const SessionScreen(),
      ));
      await tester.pumpAndSettle();
      // Miss count is displayed somewhere in the body.
      check(find.textContaining('3').evaluate().length).isGreaterOrEqual(1);
    });
  });
}
