/// Alchemist golden tests for [SessionScreen].
///
/// Six scenarios cover the main rendering paths: light + dark hold-button,
/// fake-call active, loud-alarm active, dark disguised-reminder (stealth),
/// and Arabic RTL. Each [goldenTest] call has its own [pumpWidget] that
/// wraps the scenario widget in a [ProviderScope] + [MaterialApp] shell
/// with a [_FakeSessionController] injecting a canned [SessionState].
///
/// [SessionScreen] is a full-screen widget containing a [Scaffold]; it
/// must be given tight dimensions to avoid unbounded-height layout
/// errors inside the alchemist [Table]. Each scenario wraps the screen
/// in a [SizedBox] sized to a standard phone viewport (390 × 844).
///
/// Golden images are stored under `goldens/ci/<fileName>.png` (CI) and
/// `goldens/goldens/<fileName>.png` (platform) relative to this file.
library;

import 'package:flutter/material.dart';

import 'package:alchemist/alchemist.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/features/session/session_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/sim/quick_exit_service_sim.dart';

// ---------------------------------------------------------------------------
// Phone-sized viewport used by every scenario.
// ---------------------------------------------------------------------------

/// Standard phone viewport: 390 × 844 logical pixels.
const Size _kPhoneSize = Size(390, 844);

// ---------------------------------------------------------------------------
// Fake controller — identical pattern to session_screen_test.dart.
// ---------------------------------------------------------------------------

/// Subclass of [SessionController] that returns [_initial] from [build]
/// without reaching the real engine or data layer.
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
// Data helpers.
// ---------------------------------------------------------------------------

ChainStep _step(ChainStepType type, {StepConfig? config}) => ChainStep(
  id: 'golden-${type.name}',
  type: type,
  order: 0,
  waitSeconds: 0,
  durationSeconds: 30,
  gracePeriodSeconds: 5,
  retryCount: 0,
  randomize: false,
  config: config,
);

SessionState _state({
  ChainStepType type = ChainStepType.holdButton,
  StepConfig? config,
  SessionPhase phase = SessionPhase.holding,
  bool isSimulation = false,
  bool isPaused = false,
  int elapsedSeconds = 42,
  int remainingSeconds = 15,
}) => SessionState(
  isSimulation: isSimulation,
  elapsedSeconds: elapsedSeconds,
  phase: phase,
  activeChain: <ChainStep>[_step(type, config: config)],
  currentStepIndex: 0,
  missCount: 0,
  isHolding: false,
  isPaused: isPaused,
  isDistressChain: false,
  remainingSeconds: remainingSeconds,
);

// ---------------------------------------------------------------------------
// Harness helpers.
// ---------------------------------------------------------------------------

/// Default provider overrides: fake session controller + sim quick-exit.
List<Override> _overrides(_FakeSessionController fake) => <Override>[
  sessionControllerProvider.overrideWith(() => fake),
  quickExitServiceProvider.overrideWith((_) => SimulationQuickExitService()),
];

/// Builds a [GoldenTestScenario] that renders [screen] at phone dimensions.
///
/// [SessionScreen] contains a [Scaffold] and must be given tight
/// dimensions — a [SizedBox] enforces [_kPhoneSize] regardless of the
/// intrinsic-width constraints imposed by the alchemist [Table] layout.
GoldenTestScenario _scenario({required String name, required Widget screen}) =>
    GoldenTestScenario(
      name: name,
      child: SizedBox(
        width: _kPhoneSize.width,
        height: _kPhoneSize.height,
        child: screen,
      ),
    );

/// Returns a [PumpWidget] callback for [goldenTest].
///
/// Wraps the alchemist widget in [ProviderScope] + [MaterialApp] using
/// [overrides], [locale] and [themeMode].
///
/// [locale] defaults to `Locale('en')`.
/// [themeMode] defaults to [ThemeMode.light].
PumpWidget _harness({
  required List<Override> overrides,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
}) => (WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
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
        home: widget,
      ),
    ),
  );
  await tester.pumpAndSettle();
};

// ---------------------------------------------------------------------------
// Golden tests.
// ---------------------------------------------------------------------------

void main() {
  // Scenario 1 — light, hold-button step (default real session).
  goldenTest(
    'SessionScreen — light hold-button step',
    fileName: 'session_screen_s1_light_hold_button',
    builder: () => GoldenTestGroup(
      children: <Widget>[
        _scenario(name: 'light — hold-button', screen: const SessionScreen()),
      ],
    ),
    pumpWidget: _harness(
      overrides: _overrides(_FakeSessionController(_state())),
    ),
  );

  // Scenario 2 — dark, hold-button step.
  goldenTest(
    'SessionScreen — dark hold-button step',
    fileName: 'session_screen_s2_dark_hold_button',
    builder: () => GoldenTestGroup(
      children: <Widget>[
        _scenario(name: 'dark — hold-button', screen: const SessionScreen()),
      ],
    ),
    pumpWidget: _harness(
      overrides: _overrides(_FakeSessionController(_state())),
      themeMode: ThemeMode.dark,
    ),
  );

  // Scenario 3 — light, fake-call step active.
  goldenTest(
    'SessionScreen — light fake-call step',
    fileName: 'session_screen_s3_light_fake_call',
    builder: () => GoldenTestGroup(
      children: <Widget>[
        _scenario(
          name: 'light — fakeCall active',
          screen: const SessionScreen(),
        ),
      ],
    ),
    pumpWidget: _harness(
      overrides: _overrides(
        _FakeSessionController(
          _state(
            type: ChainStepType.fakeCall,
            config: const FakeCallConfig(callerName: 'Alice'),
            phase: SessionPhase.duration,
          ),
        ),
      ),
    ),
  );

  // Scenario 4 — light, loud-alarm step with flash warning.
  goldenTest(
    'SessionScreen — light loud-alarm step',
    fileName: 'session_screen_s4_light_loud_alarm',
    builder: () => GoldenTestGroup(
      children: <Widget>[
        _scenario(
          name: 'light — loudAlarm (flash)',
          screen: const SessionScreen(),
        ),
      ],
    ),
    pumpWidget: _harness(
      overrides: _overrides(
        _FakeSessionController(
          _state(
            type: ChainStepType.loudAlarm,
            config: const LoudAlarmConfig(flashScreen: true),
            phase: SessionPhase.duration,
          ),
        ),
      ),
    ),
  );

  // Scenario 5 — dark, disguised-reminder step (stealth UI).
  goldenTest(
    'SessionScreen — dark disguised-reminder step (stealth)',
    fileName: 'session_screen_s5_dark_disguised_reminder',
    builder: () => GoldenTestGroup(
      children: <Widget>[
        _scenario(
          name: 'dark — disguisedReminder check-in',
          screen: const SessionScreen(),
        ),
      ],
    ),
    pumpWidget: _harness(
      overrides: _overrides(
        _FakeSessionController(
          _state(
            type: ChainStepType.disguisedReminder,
            config: const DisguisedReminderConfig(),
            phase: SessionPhase.duration,
          ),
        ),
      ),
      themeMode: ThemeMode.dark,
    ),
  );

  // Scenario 6 — RTL Arabic, hold-button step.
  goldenTest(
    'SessionScreen — RTL Arabic hold-button step',
    fileName: 'session_screen_s6_rtl_ar_hold_button',
    builder: () => GoldenTestGroup(
      children: <Widget>[
        _scenario(
          name: 'RTL (ar) — hold-button',
          screen: const SessionScreen(),
        ),
      ],
    ),
    pumpWidget: _harness(
      overrides: _overrides(_FakeSessionController(_state())),
      locale: const Locale('ar'),
    ),
  );
}
