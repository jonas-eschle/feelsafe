/// Widget tests for [SessionScreen].
///
/// Mirrors the structure from `test/features/home/home_screen_test.dart`:
/// a `_FakeSessionController` subclasses the real controller and overrides
/// `build()` to return a canned [SessionState]. Method calls are tracked
/// via counters and last-arg fields so tests can assert wiring.
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/button_type.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/enums/press_pattern.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/features/session/session_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/sim/quick_exit_service_sim.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Test fakes
// ---------------------------------------------------------------------------

/// Fake controller that returns [_initial] from [build] and records calls.
class _FakeSessionController extends SessionController {
  _FakeSessionController(this._initial);

  final SessionState _initial;

  int endSessionCalls = 0;
  int disarmCalls = 0;
  int cancelDistressCalls = 0;
  int holdPressedCalls = 0;
  int holdReleasedCalls = 0;
  int acknowledgeInterruptedCalls = 0;
  int setGpsDestinationCalls = 0;
  double? lastSetGpsLat;
  double? lastSetGpsLng;
  int skipGpsDestinationCalls = 0;
  int triggerQuickExitCalls = 0;
  int setSimulationSilentCalls = 0;
  bool? lastSimulationSilentValue;
  int setSimulationSpeedCalls = 0;
  double? lastSimulationSpeedValue;
  int leapCalls = 0;

  @override
  Future<SessionState> build() async => _initial;

  @override
  Future<void> endSession({EndReason reason = EndReason.userQuit}) async {
    endSessionCalls++;
    final s = state.value ?? const SessionState.initial();
    state = AsyncData(s.copyWith(phase: SessionPhase.ended));
  }

  @override
  void disarm() => disarmCalls++;

  @override
  void cancelDistress() {
    cancelDistressCalls++;
    final s = state.value;
    if (s == null) return;
    state = AsyncData(s.copyWith(clearDistressConfirm: true));
  }

  @override
  void holdPressed() => holdPressedCalls++;

  @override
  void holdReleased() => holdReleasedCalls++;

  @override
  void acknowledgeInterruptedPrompt() {
    acknowledgeInterruptedCalls++;
    final s = state.value;
    if (s == null) return;
    state = AsyncData(s.copyWith(clearPrior: true));
  }

  @override
  void setGpsDestination({required double lat, required double lng}) {
    setGpsDestinationCalls++;
    lastSetGpsLat = lat;
    lastSetGpsLng = lng;
    final s = state.value;
    if (s == null) return;
    state = AsyncData(s.copyWith(needsGpsDestinationPrompt: false));
  }

  @override
  void skipGpsDestination() {
    skipGpsDestinationCalls++;
    final s = state.value;
    if (s == null) return;
    state = AsyncData(s.copyWith(needsGpsDestinationPrompt: false));
  }

  @override
  Future<void> triggerQuickExit() async => triggerQuickExitCalls++;

  @override
  void setSimulationSilent(bool value) {
    setSimulationSilentCalls++;
    lastSimulationSilentValue = value;
  }

  @override
  void setSimulationSpeed(double value) {
    setSimulationSpeedCalls++;
    lastSimulationSpeedValue = value;
  }

  @override
  void leap() => leapCalls++;
}

// ---------------------------------------------------------------------------
// Data helpers
// ---------------------------------------------------------------------------

/// Builds a minimal [ChainStep] for the given [type] with optional [config].
ChainStep _step(
  ChainStepType type, {
  StepConfig? config,
  int waitSeconds = 0,
  int durationSeconds = 30,
  int gracePeriodSeconds = 5,
}) => ChainStep(
  id: 'test-step-${type.name}',
  type: type,
  order: 0,
  waitSeconds: waitSeconds,
  durationSeconds: durationSeconds,
  gracePeriodSeconds: gracePeriodSeconds,
  retryCount: 0,
  randomize: false,
  config: config,
);

/// Base [SessionState] for a running session at step index 0.
SessionState _runningState({
  ChainStepType type = ChainStepType.holdButton,
  StepConfig? config,
  SessionPhase phase = SessionPhase.holding,
  bool isSimulation = false,
  bool isHolding = false,
  int? distressConfirmRemaining,
  bool priorInterrupted = false,
  String? priorModeName,
  DateTime? priorStartedAt,
  bool needsGpsDestinationPrompt = false,
  String? lastError,
  int missCount = 0,
  int elapsedSeconds = 42,
}) {
  final step = _step(type, config: config);
  return SessionState(
    isSimulation: isSimulation,
    elapsedSeconds: elapsedSeconds,
    phase: phase,
    activeChain: <ChainStep>[step],
    currentStepIndex: 0,
    missCount: missCount,
    isHolding: isHolding,
    isPaused: false,
    isDistressChain: false,
    remainingSeconds: 15,
    distressConfirmRemaining: distressConfirmRemaining,
    priorInterrupted: priorInterrupted,
    priorModeName: priorModeName,
    priorStartedAt: priorStartedAt,
    lastError: lastError,
    needsGpsDestinationPrompt: needsGpsDestinationPrompt,
  );
}

/// Pumps [SessionScreen] with the given [fake] controller and optional
/// [extraOverrides].
Future<void> _pump(
  WidgetTester tester,
  _FakeSessionController fake, {
  List<Override> extraOverrides = const <Override>[],
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  bool settle = true,
}) async {
  await pumpScreen(
    tester,
    const SessionScreen(),
    overrides: <Override>[
      sessionControllerProvider.overrideWith(() => fake),
      quickExitServiceProvider.overrideWith(
        (_) => SimulationQuickExitService(),
      ),
      ...extraOverrides,
    ],
    locale: locale,
    themeMode: themeMode,
    settle: settle,
  );
}

/// Pumps [SessionScreen] inside a minimal [MaterialApp.router] with a
/// stub GoRouter so tests that invoke [context.goNamed] do not throw.
///
/// Uses a two-route GoRouter: the session screen is the initial route; a
/// blank placeholder absorbs any navigation away from it. This lets tests
/// assert controller calls that happen *before* the navigation.
Future<void> _pumpWithRouter(
  WidgetTester tester,
  _FakeSessionController fake, {
  bool settle = true,
}) async {
  final router = GoRouter(
    initialLocation: '/session',
    routes: <GoRoute>[
      GoRoute(
        path: '/session',
        name: RouteNames.session,
        builder: (_, state) => const SessionScreen(),
        routes: <GoRoute>[
          GoRoute(
            path: 'completed',
            name: RouteNames.sessionCompleted,
            builder: (_, state) => const _Blank(),
          ),
        ],
      ),
      GoRoute(
        path: '/',
        name: RouteNames.home,
        builder: (_, state) => const _Blank(),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        sessionControllerProvider.overrideWith(() => fake),
        quickExitServiceProvider.overrideWith(
          (_) => SimulationQuickExitService(),
        ),
      ],
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
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF131118)),
          useMaterial3: true,
        ),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  }
}

class _Blank extends StatelessWidget {
  const _Blank();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ── AppBar / title ────────────────────────────────────────────────────────
  group('SessionScreen — AppBar', () {
    testWidgets('renders the "Session" title in the app bar', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState());
      await _pump(tester, fake);
      expect(find.text(l10n.sessionTitle), findsOneWidget);
    });

    testWidgets('renders quick-exit and end-session icon buttons', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState());
      await _pump(tester, fake);
      expect(find.byTooltip(l10n.sessionQuickExitTitle), findsOneWidget);
      expect(find.byTooltip(l10n.commonClose), findsOneWidget);
    });

    testWidgets('quick-exit icon button tooltip matches l10n key', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState());
      await _pump(tester, fake);
      expect(find.byTooltip(l10n.sessionQuickExitTitle), findsOneWidget);
    });
  });

  // ── Async states ──────────────────────────────────────────────────────────
  group('SessionScreen — async states', () {
    testWidgets('shows CircularProgressIndicator while loading', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSessionController(_runningState());
      await _pump(tester, fake, settle: false);
      // First frame: AsyncNotifier is still building.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders session body once data resolves', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSessionController(_runningState());
      await _pump(tester, fake);
      // After settle: no loading indicator, the session scaffold is present.
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders error text when controller emits AsyncError', (
      WidgetTester tester,
    ) async {
      // Build a fake that transitions to AsyncError during test setup via
      // the ProviderScope override pattern. We use a subclass that
      // immediately throws in build().
      final fake = _ErrController();
      await pumpScreen(
        tester,
        const SessionScreen(),
        overrides: <Override>[
          sessionControllerProvider.overrideWith(() => fake),
          quickExitServiceProvider.overrideWith(
            (_) => SimulationQuickExitService(),
          ),
        ],
      );
      expect(find.textContaining('Error:'), findsOneWidget);
    });
  });

  // ── Simulation banner ─────────────────────────────────────────────────────
  group('SessionScreen — simulation banner', () {
    testWidgets('shows [SIM] orange border banner when isSimulation', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState(isSimulation: true));
      await _pump(tester, fake);
      expect(find.textContaining('[SIM]'), findsWidgets);
      expect(find.textContaining(l10n.sessionSimulationBanner), findsWidgets);
    });

    testWidgets('no [SIM] banner when isSimulation is false', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSessionController(_runningState());
      await _pump(tester, fake);
      expect(find.textContaining('[SIM]'), findsNothing);
    });
  });

  // ── Step: holdButton ──────────────────────────────────────────────────────
  group('SessionScreen — holdButton step', () {
    testWidgets('renders circular hold button', (WidgetTester tester) async {
      final fake = _FakeSessionController(_runningState(isHolding: true));
      await _pump(tester, fake);
      // Hold UI renders a 200x200 circle container — identified by the
      // "HOLD" label.
      expect(find.text('HOLD'), findsWidgets);
    });

    testWidgets('renders "Touch to begin" prompt when phase is holdWait', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(phase: SessionPhase.holdWait),
      );
      await _pump(tester, fake);
      expect(find.text(l10n.sessionHoldTouchToBegin), findsOneWidget);
    });

    testWidgets('renders "Hold to stay safe" when actively holding', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState(isHolding: true));
      await _pump(tester, fake);
      expect(find.text(l10n.sessionHoldPrompt), findsWidgets);
    });
  });

  // ── Step: disguisedReminder ───────────────────────────────────────────────
  group('SessionScreen — disguisedReminder step', () {
    testWidgets('renders shield icon when waiting', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSessionController(
        _runningState(
          type: ChainStepType.disguisedReminder,
          phase: SessionPhase.wait,
        ),
      );
      await _pump(tester, fake);
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
    });

    testWidgets('renders check-in button when phase is duration', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(
          type: ChainStepType.disguisedReminder,
          phase: SessionPhase.duration,
        ),
      );
      await _pump(tester, fake);
      expect(find.text(l10n.sessionCheckIn), findsOneWidget);
    });
  });

  // ── Step: countdownWarning ────────────────────────────────────────────────
  group('SessionScreen — countdownWarning step', () {
    testWidgets('renders warning icon and countdown title', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(
          type: ChainStepType.countdownWarning,
          phase: SessionPhase.duration,
        ),
      );
      await _pump(tester, fake);
      expect(find.byIcon(Icons.warning_amber), findsWidgets);
      expect(find.text(l10n.sessionStepCountdownTitle), findsOneWidget);
    });

    testWidgets('renders large countdown number', (WidgetTester tester) async {
      final fake = _FakeSessionController(
        _runningState(
          type: ChainStepType.countdownWarning,
          phase: SessionPhase.duration,
        ),
      );
      await _pump(tester, fake);
      // remainingSeconds = 15; rendered as '15' in displayLarge text.
      expect(find.text('15'), findsOneWidget);
    });
  });

  // ── Step: fakeCall ────────────────────────────────────────────────────────
  group('SessionScreen — fakeCall step', () {
    testWidgets('renders phone_in_talk icon and open-call button', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      const config = FakeCallConfig(callerName: 'TestCaller');
      final fake = _FakeSessionController(
        _runningState(
          type: ChainStepType.fakeCall,
          config: config,
          phase: SessionPhase.duration,
        ),
      );
      await _pump(tester, fake);
      expect(find.byIcon(Icons.phone_in_talk), findsOneWidget);
      expect(find.text(l10n.sessionStepFakeCallOpen), findsOneWidget);
    });

    testWidgets('renders caller name from FakeCallConfig', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      const callerName = 'Alice';
      const config = FakeCallConfig(callerName: callerName);
      final fake = _FakeSessionController(
        _runningState(
          type: ChainStepType.fakeCall,
          config: config,
          phase: SessionPhase.duration,
        ),
      );
      await _pump(tester, fake);
      expect(
        find.text(l10n.sessionStepFakeCallActive(callerName)),
        findsOneWidget,
      );
    });
  });

  // ── Step: smsContact ──────────────────────────────────────────────────────
  group('SessionScreen — smsContact step', () {
    testWidgets('renders SMS icon and sending status', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(
          type: ChainStepType.smsContact,
          phase: SessionPhase.duration,
        ),
      );
      await _pump(tester, fake);
      expect(find.byIcon(Icons.sms_outlined), findsOneWidget);
      expect(find.text(l10n.sessionStepSmsStatus), findsOneWidget);
    });

    testWidgets('shows [SIM] blocked SMS card in simulation', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSessionController(
        _runningState(
          type: ChainStepType.smsContact,
          isSimulation: true,
          phase: SessionPhase.duration,
        ),
      );
      await _pump(tester, fake);
      expect(find.textContaining('[SIM]'), findsWidgets);
    });
  });

  // ── Step: phoneCallContact ────────────────────────────────────────────────
  group('SessionScreen — phoneCallContact step', () {
    testWidgets('renders phone_forwarded icon and call status', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(
          type: ChainStepType.phoneCallContact,
          phase: SessionPhase.duration,
        ),
      );
      await _pump(tester, fake);
      expect(find.byIcon(Icons.phone_forwarded), findsOneWidget);
      expect(find.text(l10n.sessionStepPhoneCallStatus), findsOneWidget);
    });

    testWidgets('shows [SIM] blocked phone card in simulation', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(
          type: ChainStepType.phoneCallContact,
          isSimulation: true,
          phase: SessionPhase.duration,
        ),
      );
      await _pump(tester, fake);
      expect(find.text(l10n.sessionStepSimBlockedPhone), findsOneWidget);
    });
  });

  // ── Step: loudAlarm ───────────────────────────────────────────────────────
  group('SessionScreen — loudAlarm step', () {
    testWidgets('renders volume_up icon and alarm title', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(
          type: ChainStepType.loudAlarm,
          phase: SessionPhase.duration,
        ),
      );
      await _pump(tester, fake);
      expect(find.byIcon(Icons.volume_up), findsOneWidget);
      expect(find.text(l10n.sessionStepLoudAlarmTitle), findsOneWidget);
    });

    testWidgets('shows flash warning when LoudAlarmConfig.flashScreen=true', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      const config = LoudAlarmConfig(flashScreen: true);
      final fake = _FakeSessionController(
        _runningState(
          type: ChainStepType.loudAlarm,
          config: config,
          phase: SessionPhase.duration,
        ),
      );
      await _pump(tester, fake);
      expect(find.text(l10n.sessionStepLoudAlarmFlashWarning), findsOneWidget);
    });

    testWidgets('shows [SIM] blocked alarm card in simulation', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(
          type: ChainStepType.loudAlarm,
          isSimulation: true,
          phase: SessionPhase.duration,
        ),
      );
      await _pump(tester, fake);
      expect(find.text(l10n.sessionStepSimBlockedAlarm), findsOneWidget);
    });
  });

  // ── Step: callEmergency ───────────────────────────────────────────────────
  group('SessionScreen — callEmergency step', () {
    testWidgets('wait phase renders the simple status label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(
          type: ChainStepType.callEmergency,
          phase: SessionPhase.wait,
        ),
      );
      await _pump(tester, fake);
      // Pre-duration we still show the underlying status UI.
      expect(find.byIcon(Icons.emergency), findsOneWidget);
      expect(find.text(l10n.sessionStepCallEmergencyStatus), findsOneWidget);
    });

    testWidgets(
      'duration phase replaces the status label with the new overlay',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        const config = CallEmergencyConfig(emergencyNumber: '999');
        final fake = _FakeSessionController(
          _runningState(
            type: ChainStepType.callEmergency,
            config: config,
            phase: SessionPhase.duration,
          ),
        );
        await _pump(tester, fake);
        // The legacy simple status label MUST NOT render under the
        // overlay (C1 PM-FIX: spec 02:458-460 / Extra 56).
        expect(find.text(l10n.sessionStepCallEmergencyStatus), findsNothing);
        // Overlay-specific affordances are present.
        expect(find.text(l10n.sessionEmergencyConfirmKeep), findsOneWidget);
        expect(find.text(l10n.sessionEmergencyConfirmSwipe), findsOneWidget);
      },
    );

    testWidgets('overlay renders the configured emergency number', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      const number = '999';
      const config = CallEmergencyConfig(emergencyNumber: number);
      final fake = _FakeSessionController(
        _runningState(
          type: ChainStepType.callEmergency,
          config: config,
          phase: SessionPhase.duration,
        ),
      );
      await _pump(tester, fake);
      // remainingSeconds in the running state helper is 15, but the
      // overlay caps at the step's confirmationDuration (default 5)
      // via the controller-side remaining-time math. We don't assume
      // the exact seconds here; we assert the number string is present
      // somewhere in the heading.
      expect(
        find.textContaining(number),
        findsAtLeastNWidgets(1),
        reason: 'Overlay title should contain the override number.',
      );
      // l10n key is wired correctly (heading uses combined string).
      expect(l10n.sessionEmergencyConfirmTitle('x', 1), contains('x'));
    });

    testWidgets(
      'tapping Keep calling re-arms the overlay back to the simple status',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeSessionController(
          _runningState(
            type: ChainStepType.callEmergency,
            phase: SessionPhase.duration,
          ),
        );
        await _pump(tester, fake);
        expect(find.text(l10n.sessionEmergencyConfirmKeep), findsOneWidget);
        await tester.tap(find.text(l10n.sessionEmergencyConfirmKeep));
        await tester.pumpAndSettle();
        // After dismissing, the overlay is gone and the underlying
        // status label is shown again.
        expect(find.text(l10n.sessionEmergencyConfirmKeep), findsNothing);
        expect(find.text(l10n.sessionStepCallEmergencyStatus), findsOneWidget);
      },
    );
  });

  // ── Step: hardwareButton ──────────────────────────────────────────────────
  group('SessionScreen — hardwareButton step', () {
    testWidgets('renders touch_app icon', (WidgetTester tester) async {
      final fake = _FakeSessionController(
        _runningState(
          type: ChainStepType.hardwareButton,
          phase: SessionPhase.duration,
        ),
      );
      await _pump(tester, fake);
      expect(find.byIcon(Icons.touch_app), findsOneWidget);
    });

    testWidgets('renders repeat-press instruction with volumeUp', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      const config = HardwareButtonConfig(pressCount: 3);
      final fake = _FakeSessionController(
        _runningState(
          type: ChainStepType.hardwareButton,
          config: config,
          phase: SessionPhase.duration,
        ),
      );
      await _pump(tester, fake);
      expect(
        find.textContaining(l10n.sessionStepHardwareButtonVolumeUp),
        findsOneWidget,
      );
    });

    testWidgets('renders long-press instruction with volumeDown', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      const config = HardwareButtonConfig(
        buttonType: ButtonType.volumeDown,
        pressPattern: PressPattern.longPress,
        longPressDurationSeconds: 3,
      );
      final fake = _FakeSessionController(
        _runningState(
          type: ChainStepType.hardwareButton,
          config: config,
          phase: SessionPhase.duration,
        ),
      );
      await _pump(tester, fake);
      expect(
        find.textContaining(l10n.sessionStepHardwareButtonVolumeDown),
        findsOneWidget,
      );
    });
  });

  // ── Distress confirmation overlay ─────────────────────────────────────────
  group('SessionScreen — distress confirmation overlay', () {
    testWidgets('shows distress title when distressConfirmRemaining > 0', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(distressConfirmRemaining: 4),
      );
      await _pump(tester, fake);
      expect(find.text(l10n.distressConfirmTitle), findsOneWidget);
    });

    testWidgets('countdown text shows remaining seconds', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(distressConfirmRemaining: 3),
      );
      await _pump(tester, fake);
      expect(find.text(l10n.distressConfirmCountdown(3)), findsOneWidget);
    });

    testWidgets('tapping cancel button calls cancelDistress', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(distressConfirmRemaining: 5),
      );
      await _pump(tester, fake);
      await tester.tap(find.text(l10n.distressConfirmCancel));
      await tester.pumpAndSettle();
      check(fake.cancelDistressCalls).equals(1);
    });

    testWidgets('shows footer text explaining imminent distress', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(distressConfirmRemaining: 5),
      );
      await _pump(tester, fake);
      expect(find.text(l10n.distressConfirmFooter), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator in overlay', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSessionController(
        _runningState(distressConfirmRemaining: 5),
      );
      await _pump(tester, fake);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  // ── Session-Interrupted Prompt (Extra 13) ─────────────────────────────────
  group('SessionScreen — interrupted prompt (Extra 13)', () {
    testWidgets('shows interrupted title and body when priorInterrupted', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(
          priorInterrupted: true,
          priorModeName: 'Walk Mode',
          priorStartedAt: DateTime(2026, 5, 1, 10),
        ),
      );
      await _pump(tester, fake);
      expect(find.text(l10n.sessionInterruptedTitle), findsOneWidget);
      expect(
        find.text(l10n.sessionInterruptedMode('Walk Mode')),
        findsOneWidget,
      );
    });

    testWidgets('shows priorStartedAt formatted in prompt', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final priorAt = DateTime(2026, 5, 1, 10);
      final fake = _FakeSessionController(
        _runningState(
          priorInterrupted: true,
          priorModeName: 'Date Mode',
          priorStartedAt: priorAt,
        ),
      );
      await _pump(tester, fake);
      expect(
        find.text(l10n.sessionInterruptedStarted(priorAt.toLocal().toString())),
        findsOneWidget,
      );
    });

    testWidgets('tapping Acknowledge calls acknowledgeInterruptedPrompt', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(
          priorInterrupted: true,
          priorModeName: 'Walk Mode',
          priorStartedAt: DateTime(2026, 5, 1, 10),
        ),
      );
      // Route away requires GoRouter in the tree.
      await _pumpWithRouter(tester, fake);
      await tester.tap(find.text(l10n.sessionInterruptedAcknowledge));
      await tester.pumpAndSettle();
      check(fake.acknowledgeInterruptedCalls).equals(1);
    });
  });

  // ── GPS Destination Prompt (Extra 22) ─────────────────────────────────────
  group('SessionScreen — GPS destination prompt (Extra 22)', () {
    testWidgets('shows GPS destination modal when needsGpsDestinationPrompt', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(needsGpsDestinationPrompt: true),
      );
      await _pump(tester, fake);
      expect(find.text(l10n.sessionGpsDestinationTitle), findsOneWidget);
    });

    testWidgets('skip button calls skipGpsDestination', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(needsGpsDestinationPrompt: true),
      );
      await _pump(tester, fake);
      await tester.tap(find.text(l10n.sessionGpsDestinationSkip));
      await tester.pumpAndSettle();
      check(fake.skipGpsDestinationCalls).equals(1);
    });
  });

  // ── Quick Exit ────────────────────────────────────────────────────────────
  group('SessionScreen — quick exit', () {
    testWidgets('tapping quick-exit button shows confirm dialog', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState());
      await _pump(tester, fake);
      await tester.tap(find.byTooltip(l10n.sessionQuickExitTitle));
      await tester.pumpAndSettle();
      // Dialog with the confirm button appears.
      expect(find.text(l10n.sessionQuickExitConfirm), findsOneWidget);
    });

    testWidgets('confirming quick exit calls triggerQuickExit', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState());
      await _pump(tester, fake);
      await tester.tap(find.byTooltip(l10n.sessionQuickExitTitle));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.sessionQuickExitConfirm));
      await tester.pumpAndSettle();
      check(fake.triggerQuickExitCalls).equals(1);
    });
  });

  // ── End session dialog ────────────────────────────────────────────────────
  group('SessionScreen — end session', () {
    testWidgets('tapping end-session icon shows confirmation dialog', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState());
      await _pump(tester, fake);
      await tester.tap(find.byTooltip(l10n.commonClose));
      await tester.pumpAndSettle();
      expect(find.text(l10n.sessionEndConfirmTitle), findsOneWidget);
    });

    testWidgets('confirming end session calls endSession', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState());
      // Route away requires GoRouter in the tree.
      await _pumpWithRouter(tester, fake);
      await tester.tap(find.byTooltip(l10n.commonClose));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.commonConfirm));
      await tester.pumpAndSettle();
      check(fake.endSessionCalls).equals(1);
    });
  });

  // ── Simulation controls bar ───────────────────────────────────────────────
  group('SessionScreen — simulation controls bar', () {
    testWidgets('simulation controls bar visible when isSimulation', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSessionController(_runningState(isSimulation: true));
      await _pump(tester, fake);
      // The Slider widget is present in the simulation controls bar.
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('simulation controls bar hidden when not simulation', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSessionController(_runningState());
      await _pump(tester, fake);
      expect(find.byType(Slider), findsNothing);
    });

    testWidgets('Switch in sim bar reflects simulationSilent state', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSessionController(_runningState(isSimulation: true));
      await _pump(tester, fake);
      final sw = tester.widget<Switch>(find.byType(Switch));
      // Default simulationSilent is true.
      check(sw.value).isTrue();
    });
  });

  // ── Stealth mode path ─────────────────────────────────────────────────────
  group('SessionScreen — stealth mode smoke', () {
    testWidgets('renders without exception when paused badge shown', (
      WidgetTester tester,
    ) async {
      // Paused badge is a stealth-adjacent display path: confirms the
      // session header renders Chip widgets without overflow.
      final l10n = await loadL10n(const Locale('en'));
      final step = _step(ChainStepType.holdButton);
      final state = SessionState(
        isSimulation: false,
        elapsedSeconds: 0,
        phase: SessionPhase.holding,
        activeChain: <ChainStep>[step],
        currentStepIndex: 0,
        missCount: 0,
        isHolding: false,
        isPaused: true,
        isDistressChain: false,
      );
      final fake = _FakeSessionController(state);
      await _pump(tester, fake);
      expect(find.text(l10n.sessionPausedBadge), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ── Error banner ──────────────────────────────────────────────────────────
  group('SessionScreen — error banner', () {
    testWidgets('shows error banner when lastError is set', (
      WidgetTester tester,
    ) async {
      const errMsg = 'Step execution failed: timeout';
      final fake = _FakeSessionController(_runningState(lastError: errMsg));
      await _pump(tester, fake);
      expect(find.text(errMsg), findsOneWidget);
    });
  });

  // ── RTL smoke ─────────────────────────────────────────────────────────────
  group('SessionScreen — RTL', () {
    testWidgets('renders in Arabic (RTL) without overflow', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSessionController(_runningState());
      await _pump(tester, fake, locale: const Locale('ar'));
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ── Dark mode smoke ───────────────────────────────────────────────────────
  group('SessionScreen — dark mode', () {
    testWidgets('renders without exception in dark mode', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSessionController(_runningState());
      await _pump(tester, fake, themeMode: ThemeMode.dark);
      expect(tester.takeException(), isNull);
    });
  });

  // ── Accessibility ─────────────────────────────────────────────────────────
  group('SessionScreen — accessibility', () {
    testWidgets('app bar icon buttons expose tooltips', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState());
      await _pump(tester, fake);
      expect(find.byTooltip(l10n.sessionQuickExitTitle), findsOneWidget);
      expect(find.byTooltip(l10n.commonClose), findsOneWidget);
    });

    testWidgets('session elapsed clock is present in header', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSessionController(_runningState(elapsedSeconds: 65));
      await _pump(tester, fake);
      // Elapsed 65 s → "01:05"
      expect(find.text('01:05'), findsOneWidget);
    });

    testWidgets('step counter label rendered when step is active', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState());
      await _pump(tester, fake);
      // Step 1 of 1.
      expect(find.text(l10n.sessionStepLabel('1', '1')), findsOneWidget);
    });
  });
}

// ---------------------------------------------------------------------------
// Error-state helper
// ---------------------------------------------------------------------------

/// Controller that immediately emits [AsyncError] so error-path tests
/// can assert the screen renders "Error: …" without depending on an
/// exception inside [build].
class _ErrController extends SessionController {
  @override
  Future<SessionState> build() async => throw StateError('injected test error');
}
