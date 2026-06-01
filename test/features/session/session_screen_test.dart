/// Widget tests for [SessionScreen].
///
/// Mirrors the structure from `test/features/home/home_screen_test.dart`:
/// a `_FakeSessionController` subclasses the real controller and overrides
/// `build()` to return a canned [SessionState]. Method calls are tracked
/// via counters and last-arg fields so tests can assert wiring.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/core/widgets/deceptive_old_pin_dialog.dart';
import 'package:guardianangela/core/widgets/pin_keypad.dart';
import 'package:guardianangela/core/widgets/swipe_slider.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/button_type.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/enums/press_pattern.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/features/session/session_screen.dart';
import 'package:guardianangela/features/session/widgets/end_session_overlay.dart';
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
  int confirmDistressCalls = 0;
  EndReason? lastConfirmDistressReason;
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
  int resetWrongPinAttemptsCalls = 0;
  int notifyWrongPinAttemptCalls = 0;
  int pauseDistressCountdownCalls = 0;
  int resumeDistressCountdownCalls = 0;
  int _fakeWrongAttempts = 0;

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
  void confirmDistress({EndReason reason = EndReason.hardwarePanic}) {
    confirmDistressCalls++;
    lastConfirmDistressReason = reason;
  }

  @override
  void pauseDistressCountdown() {
    pauseDistressCountdownCalls++;
  }

  @override
  void resumeDistressCountdown() {
    resumeDistressCountdownCalls++;
  }

  @override
  void resetWrongPinAttempts() {
    resetWrongPinAttemptsCalls++;
    _fakeWrongAttempts = 0;
  }

  @override
  int notifyWrongPinAttempt() {
    notifyWrongPinAttemptCalls++;
    return _fakeWrongAttempts += 1;
  }

  @override
  int get wrongPinAttempts => _fakeWrongAttempts;

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

/// In-memory [AppSettingsRepository] for end-session PIN flow tests.
///
/// The base class constructor requires a [keyProvider] / [resolveDir];
/// we supply a no-op key and a temp dir because [load] / [save] are
/// overridden to never touch disk.
class _FakeAppSettingsRepository extends AppSettingsRepository {
  _FakeAppSettingsRepository({AppSettings? initial})
    : _current = initial ?? const AppSettings(),
      super(
        keyProvider: () async =>
            '0102030405060708090a0b0c0d0e0f'
            '101112131415161718191a1b1c1d1e1f20',
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('session_end_test_'),
      );

  AppSettings _current;

  @override
  Future<AppSettings> load() async => _current;

  @override
  Future<void> save(AppSettings value) async => _current = value;
}

/// Returns a SHA-256 hex digest of [digits] using the same UTF-8 encoding
/// the production PIN-setup screen uses.
String _hashDigits(String digits) =>
    sha256.convert(utf8.encode(digits)).toString();

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
  bool stealthEnabled = false,
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
    stealthEnabled: stealthEnabled,
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
  List<Override> extraOverrides = const <Override>[],
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
        ...extraOverrides,
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

/// Drags the [EndSessionOverlay] swipe slider knob past the 0.7
/// threshold so [SwipeSlider.onConfirm] fires.
///
/// The session screen now also renders a grace-period disarm
/// [SwipeSlider] under the active step, so we scope the find to the
/// overlay's subtree to avoid an ambiguous match against the disarm
/// slider's arrow knob.
Future<void> _swipeToConfirm(WidgetTester tester) async {
  expect(find.byType(EndSessionOverlay), findsOneWidget);
  await tester.drag(
    find.descendant(
      of: find.byType(EndSessionOverlay),
      matching: find.byIcon(Icons.arrow_forward_rounded),
    ),
    const Offset(800, 0),
  );
}

/// Taps the PinKeypad digit buttons for each character of [digits].
Future<void> _typeDigits(WidgetTester tester, String digits) async {
  for (final code in digits.codeUnits) {
    final digit = code - 0x30; // ASCII '0' == 0x30
    await tester.tap(find.widgetWithText(InkWell, '$digit').last);
    await tester.pump();
  }
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
      final repo = _FakeAppSettingsRepository();
      await _pump(
        tester,
        fake,
        extraOverrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      expect(find.text(l10n.distressConfirmTitle), findsOneWidget);
    });

    testWidgets('countdown text shows remaining seconds', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(distressConfirmRemaining: 3),
      );
      final repo = _FakeAppSettingsRepository();
      await _pump(
        tester,
        fake,
        extraOverrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      expect(find.text(l10n.distressConfirmCountdown(3)), findsOneWidget);
    });

    testWidgets(
      'no PIN configured → tapping cancel calls cancelDistress immediately',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeSessionController(
          _runningState(distressConfirmRemaining: 5),
        );
        final repo = _FakeAppSettingsRepository();
        await _pump(
          tester,
          fake,
          extraOverrides: <Override>[
            appSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        );
        await tester.tap(find.text(l10n.distressConfirmCancel));
        await tester.pumpAndSettle();
        check(fake.cancelDistressCalls).equals(1);
        check(fake.pauseDistressCountdownCalls).equals(0);
      },
    );

    testWidgets('shows footer text explaining imminent distress', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(distressConfirmRemaining: 5),
      );
      final repo = _FakeAppSettingsRepository();
      await _pump(
        tester,
        fake,
        extraOverrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      expect(find.text(l10n.distressConfirmFooter), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator in overlay', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSessionController(
        _runningState(distressConfirmRemaining: 5),
      );
      final repo = _FakeAppSettingsRepository();
      await _pump(
        tester,
        fake,
        extraOverrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  // ── Distress-cancel PIN gate (C3) ────────────────────────────────────────
  group('SessionScreen — distress-cancel PIN gate', () {
    testWidgets(
      'PIN configured → tap cancel shows PIN keypad and pauses countdown',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeSessionController(
          _runningState(distressConfirmRemaining: 5),
        );
        final repo = _FakeAppSettingsRepository(
          initial: AppSettings(sessionEndPinHash: _hashDigits('1234')),
        );
        await _pump(
          tester,
          fake,
          extraOverrides: <Override>[
            appSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        );
        await tester.tap(find.text(l10n.distressConfirmCancel));
        await tester.pumpAndSettle();
        // PIN keypad replaces confirmation panel.
        expect(find.text(l10n.distressCancelPinPromptTitle), findsOneWidget);
        expect(find.byType(PinKeypad), findsOneWidget);
        // 5-second countdown is paused; not cancelled.
        check(fake.pauseDistressCountdownCalls).equals(1);
        check(fake.cancelDistressCalls).equals(0);
        check(fake.confirmDistressCalls).equals(0);
      },
    );

    testWidgets('correct Session End PIN → cancelDistress + counter reset', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(distressConfirmRemaining: 5),
      );
      final repo = _FakeAppSettingsRepository(
        initial: AppSettings(sessionEndPinHash: _hashDigits('1234')),
      );
      await _pump(
        tester,
        fake,
        extraOverrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      await tester.tap(find.text(l10n.distressConfirmCancel));
      await tester.pumpAndSettle();
      await _typeDigits(tester, '1234');
      await tester.pumpAndSettle();
      check(fake.cancelDistressCalls).equals(1);
      check(fake.resetWrongPinAttemptsCalls).isGreaterThan(0);
      check(fake.confirmDistressCalls).equals(0);
    });

    testWidgets('Duress PIN → confirmDistress(reason: duressPin)', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(distressConfirmRemaining: 5),
      );
      final repo = _FakeAppSettingsRepository(
        initial: AppSettings(
          duressPinHash: _hashDigits('7777'),
          sessionEndPinHash: _hashDigits('1234'),
        ),
      );
      await _pump(
        tester,
        fake,
        extraOverrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      await tester.tap(find.text(l10n.distressConfirmCancel));
      await tester.pumpAndSettle();
      await _typeDigits(tester, '7777');
      await tester.pumpAndSettle();
      check(fake.confirmDistressCalls).equals(1);
      check(fake.lastConfirmDistressReason).equals(EndReason.duressPin);
      check(fake.cancelDistressCalls).equals(0);
    });

    testWidgets(
      'App PIN → mismatch hint shown, no wrong-PIN counter increment',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeSessionController(
          _runningState(distressConfirmRemaining: 5),
        );
        final repo = _FakeAppSettingsRepository(
          initial: AppSettings(
            appPinHash: _hashDigits('9999'),
            sessionEndPinHash: _hashDigits('1234'),
          ),
        );
        await _pump(
          tester,
          fake,
          extraOverrides: <Override>[
            appSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        );
        await tester.tap(find.text(l10n.distressConfirmCancel));
        await tester.pumpAndSettle();
        await _typeDigits(tester, '9999');
        await tester.pumpAndSettle();
        expect(find.text(l10n.distressCancelPinAppPinMismatch), findsOneWidget);
        check(fake.cancelDistressCalls).equals(0);
        check(fake.confirmDistressCalls).equals(0);
        check(fake.notifyWrongPinAttemptCalls).equals(0);
      },
    );

    testWidgets(
      'wrong PIN (deceptive disabled) → shake + inline error + engine notify',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeSessionController(
          _runningState(distressConfirmRemaining: 5),
        );
        final repo = _FakeAppSettingsRepository(
          initial: AppSettings(
            sessionEndPinHash: _hashDigits('1234'),
            deceptivePinDialogEnabled: false,
          ),
        );
        await _pump(
          tester,
          fake,
          extraOverrides: <Override>[
            appSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        );
        await tester.tap(find.text(l10n.distressConfirmCancel));
        await tester.pumpAndSettle();
        await _typeDigits(tester, '00000000');
        await tester.pumpAndSettle();
        check(fake.notifyWrongPinAttemptCalls).equals(1);
        expect(find.text(l10n.distressCancelPinIncorrect), findsOneWidget);
        expect(find.byType(DeceptiveOldPinDialog), findsNothing);
      },
    );

    testWidgets('wrong PIN (deceptive enabled) → deceptive dialog shown', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(distressConfirmRemaining: 5),
      );
      final repo = _FakeAppSettingsRepository(
        initial: AppSettings(sessionEndPinHash: _hashDigits('1234')),
      );
      await _pump(
        tester,
        fake,
        extraOverrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      await tester.tap(find.text(l10n.distressConfirmCancel));
      await tester.pumpAndSettle();
      await _typeDigits(tester, '00000000');
      await tester.pump();
      expect(find.byType(DeceptiveOldPinDialog), findsOneWidget);
    });

    testWidgets(
      '5 wrong PINs (real) → confirmDistress(reason: wrongPinExhausted)',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeSessionController(
          _runningState(distressConfirmRemaining: 5),
        );
        final repo = _FakeAppSettingsRepository(
          initial: AppSettings(
            sessionEndPinHash: _hashDigits('1234'),
            deceptivePinDialogEnabled: false,
          ),
        );
        await _pump(
          tester,
          fake,
          extraOverrides: <Override>[
            appSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        );
        await tester.tap(find.text(l10n.distressConfirmCancel));
        await tester.pumpAndSettle();
        for (int i = 0; i < 5; i++) {
          await _typeDigits(tester, '00000000');
          await tester.pumpAndSettle();
        }
        check(fake.notifyWrongPinAttemptCalls).equals(5);
        check(fake.confirmDistressCalls).equals(1);
        check(
          fake.lastConfirmDistressReason,
        ).equals(EndReason.wrongPinExhausted);
      },
    );

    testWidgets(
      '5 wrong PINs (sim) → SnackBar shown, no controller increment, no distress',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeSessionController(
          _runningState(distressConfirmRemaining: 5, isSimulation: true),
        );
        final repo = _FakeAppSettingsRepository(
          initial: AppSettings(
            sessionEndPinHash: _hashDigits('1234'),
            deceptivePinDialogEnabled: false,
          ),
        );
        await _pump(
          tester,
          fake,
          extraOverrides: <Override>[
            appSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        );
        await tester.tap(find.text(l10n.distressConfirmCancel));
        await tester.pumpAndSettle();
        for (int i = 0; i < 5; i++) {
          await _typeDigits(tester, '00000000');
          await tester.pumpAndSettle();
        }
        check(fake.notifyWrongPinAttemptCalls).equals(0);
        check(fake.confirmDistressCalls).equals(0);
        expect(
          find.text(l10n.distressCancelSimDistressWouldFire),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'simulation → [Skip] visible and cancels distress without PIN',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeSessionController(
          _runningState(distressConfirmRemaining: 5, isSimulation: true),
        );
        final repo = _FakeAppSettingsRepository(
          initial: AppSettings(sessionEndPinHash: _hashDigits('1234')),
        );
        await _pump(
          tester,
          fake,
          extraOverrides: <Override>[
            appSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        );
        await tester.tap(find.text(l10n.distressConfirmCancel));
        await tester.pumpAndSettle();
        expect(find.text(l10n.distressCancelPinSimSkip), findsOneWidget);
        await tester.tap(find.text(l10n.distressCancelPinSimSkip));
        await tester.pumpAndSettle();
        check(fake.cancelDistressCalls).equals(1);
      },
    );

    testWidgets(
      'Cancel button on PIN stage returns to confirmation and resumes countdown',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeSessionController(
          _runningState(distressConfirmRemaining: 5),
        );
        final repo = _FakeAppSettingsRepository(
          initial: AppSettings(sessionEndPinHash: _hashDigits('1234')),
        );
        await _pump(
          tester,
          fake,
          extraOverrides: <Override>[
            appSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        );
        await tester.tap(find.text(l10n.distressConfirmCancel));
        await tester.pumpAndSettle();
        check(fake.pauseDistressCountdownCalls).equals(1);
        // Use the Cancel TextButton inside the PIN stage. The label is
        // [distressCancelPinBack] = "Cancel".
        await tester.tap(find.text(l10n.distressCancelPinBack));
        await tester.pumpAndSettle();
        // Back at the confirmation stage — the cancel countdown button
        // is visible again, and the controller's resume was invoked.
        expect(find.text(l10n.distressConfirmCancel), findsOneWidget);
        check(fake.resumeDistressCountdownCalls).equals(1);
        check(fake.cancelDistressCalls).equals(0);
        check(fake.confirmDistressCalls).equals(0);
      },
    );

    testWidgets(
      '15s timeout → confirmDistress(reason: distressConfirmTimeout)',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeSessionController(
          _runningState(distressConfirmRemaining: 5),
        );
        final repo = _FakeAppSettingsRepository(
          initial: AppSettings(sessionEndPinHash: _hashDigits('1234')),
        );
        await _pump(
          tester,
          fake,
          extraOverrides: <Override>[
            appSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        );
        await tester.tap(find.text(l10n.distressConfirmCancel));
        await tester.pumpAndSettle();
        // Advance 16 one-second ticks; the timer fires at 0.
        for (int i = 0; i < 16; i++) {
          await tester.pump(const Duration(seconds: 1));
        }
        check(fake.confirmDistressCalls).equals(1);
        check(
          fake.lastConfirmDistressReason,
        ).equals(EndReason.distressConfirmTimeout);
      },
    );
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

  // ── End session overlay (C2) ──────────────────────────────────────────────
  group('SessionScreen — end session overlay', () {
    testWidgets('tapping end-session icon shows the swipe overlay', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState());
      final repo = _FakeAppSettingsRepository();
      await _pump(
        tester,
        fake,
        extraOverrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      await tester.tap(find.byTooltip(l10n.commonClose));
      await tester.pumpAndSettle();
      // The overlay's heading replaces the legacy AlertDialog title.
      expect(find.text(l10n.sessionEndOverlayTitle), findsOneWidget);
      expect(find.text(l10n.sessionEndOverlaySwipeLabel), findsOneWidget);
      // A SwipeSlider is now in the tree.
      expect(find.byType(EndSessionOverlay), findsOneWidget);
    });

    testWidgets('no PIN configured → swipe ends the session and navigates', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState());
      final repo = _FakeAppSettingsRepository();
      await _pumpWithRouter(
        tester,
        fake,
        extraOverrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      await tester.tap(find.byTooltip(l10n.commonClose));
      await tester.pumpAndSettle();
      await _swipeToConfirm(tester);
      await tester.pumpAndSettle();
      check(fake.endSessionCalls).equals(1);
    });

    testWidgets('PIN configured → swipe shows the PIN keypad', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState());
      final repo = _FakeAppSettingsRepository(
        initial: AppSettings(sessionEndPinHash: _hashDigits('1234')),
      );
      await _pump(
        tester,
        fake,
        extraOverrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      await tester.tap(find.byTooltip(l10n.commonClose));
      await tester.pumpAndSettle();
      await _swipeToConfirm(tester);
      await tester.pumpAndSettle();
      // PIN stage rendered, end-session NOT called yet.
      expect(find.text(l10n.sessionEndPinPromptTitle), findsOneWidget);
      check(fake.endSessionCalls).equals(0);
    });

    testWidgets('correct PIN ends the session', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState());
      final repo = _FakeAppSettingsRepository(
        initial: AppSettings(sessionEndPinHash: _hashDigits('1234')),
      );
      await _pumpWithRouter(
        tester,
        fake,
        extraOverrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      await tester.tap(find.byTooltip(l10n.commonClose));
      await tester.pumpAndSettle();
      await _swipeToConfirm(tester);
      await tester.pumpAndSettle();
      await _typeDigits(tester, '1234');
      await tester.pumpAndSettle();
      check(fake.endSessionCalls).equals(1);
      check(fake.resetWrongPinAttemptsCalls).isGreaterThan(0);
    });

    testWidgets('app-PIN entered → shows mismatch hint, no end', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState());
      final repo = _FakeAppSettingsRepository(
        initial: AppSettings(
          appPinHash: _hashDigits('9999'),
          sessionEndPinHash: _hashDigits('1234'),
        ),
      );
      await _pumpWithRouter(
        tester,
        fake,
        extraOverrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      await tester.tap(find.byTooltip(l10n.commonClose));
      await tester.pumpAndSettle();
      await _swipeToConfirm(tester);
      await tester.pumpAndSettle();
      await _typeDigits(tester, '9999');
      await tester.pumpAndSettle();
      expect(find.text(l10n.sessionEndPinAppPinMismatch), findsOneWidget);
      check(fake.endSessionCalls).equals(0);
      check(fake.confirmDistressCalls).equals(0);
      check(fake.notifyWrongPinAttemptCalls).equals(0);
    });

    testWidgets('duress PIN entered → confirmDistress(duressPin)', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState());
      final repo = _FakeAppSettingsRepository(
        initial: AppSettings(
          duressPinHash: _hashDigits('7777'),
          sessionEndPinHash: _hashDigits('1234'),
        ),
      );
      await _pumpWithRouter(
        tester,
        fake,
        extraOverrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      await tester.tap(find.byTooltip(l10n.commonClose));
      await tester.pumpAndSettle();
      await _swipeToConfirm(tester);
      await tester.pumpAndSettle();
      await _typeDigits(tester, '7777');
      await tester.pumpAndSettle();
      check(fake.confirmDistressCalls).equals(1);
      check(fake.lastConfirmDistressReason).equals(EndReason.duressPin);
      check(fake.endSessionCalls).equals(0);
    });

    testWidgets('wrong PIN (deceptive disabled) → shake + incorrect feedback', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState());
      final repo = _FakeAppSettingsRepository(
        initial: AppSettings(
          sessionEndPinHash: _hashDigits('1234'),
          deceptivePinDialogEnabled: false,
        ),
      );
      await _pumpWithRouter(
        tester,
        fake,
        extraOverrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      await tester.tap(find.byTooltip(l10n.commonClose));
      await tester.pumpAndSettle();
      await _swipeToConfirm(tester);
      await tester.pumpAndSettle();
      await _typeDigits(tester, '00000000');
      await tester.pumpAndSettle();
      // Counter incremented, engine notified, inline error rendered.
      check(fake.notifyWrongPinAttemptCalls).equals(1);
      expect(find.text(l10n.sessionEndPinIncorrect), findsOneWidget);
      // No deceptive dialog.
      expect(find.byType(DeceptiveOldPinDialog), findsNothing);
    });

    testWidgets('wrong PIN (deceptive enabled) → deceptive dialog shown', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState());
      final repo = _FakeAppSettingsRepository(
        initial: AppSettings(sessionEndPinHash: _hashDigits('1234')),
      );
      await _pumpWithRouter(
        tester,
        fake,
        extraOverrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      await tester.tap(find.byTooltip(l10n.commonClose));
      await tester.pumpAndSettle();
      await _swipeToConfirm(tester);
      await tester.pumpAndSettle();
      await _typeDigits(tester, '00000000');
      await tester.pump();
      // Deceptive dialog is in the tree (modal, awaiting user action).
      expect(find.byType(DeceptiveOldPinDialog), findsOneWidget);
    });

    testWidgets('5 wrong PINs (real) → confirmDistress(wrongPinExhausted)', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState());
      final repo = _FakeAppSettingsRepository(
        initial: AppSettings(
          sessionEndPinHash: _hashDigits('1234'),
          deceptivePinDialogEnabled: false,
          // wrongPinThreshold defaults to 5 — see test name.
        ),
      );
      await _pumpWithRouter(
        tester,
        fake,
        extraOverrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      await tester.tap(find.byTooltip(l10n.commonClose));
      await tester.pumpAndSettle();
      await _swipeToConfirm(tester);
      await tester.pumpAndSettle();
      for (int i = 0; i < 5; i++) {
        await _typeDigits(tester, '00000000');
        await tester.pumpAndSettle();
      }
      check(fake.notifyWrongPinAttemptCalls).equals(5);
      check(fake.confirmDistressCalls).equals(1);
      check(fake.lastConfirmDistressReason).equals(EndReason.wrongPinExhausted);
    });

    testWidgets('5 wrong PINs (sim) → SnackBar, no distress', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState(isSimulation: true));
      final repo = _FakeAppSettingsRepository(
        initial: AppSettings(
          sessionEndPinHash: _hashDigits('1234'),
          deceptivePinDialogEnabled: false,
          // wrongPinThreshold defaults to 5 — see test name.
        ),
      );
      await _pumpWithRouter(
        tester,
        fake,
        extraOverrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      await tester.tap(find.byTooltip(l10n.commonClose));
      await tester.pumpAndSettle();
      await _swipeToConfirm(tester);
      await tester.pumpAndSettle();
      for (int i = 0; i < 5; i++) {
        await _typeDigits(tester, '00000000');
        await tester.pumpAndSettle();
      }
      // Simulation never invokes the controller's real counter or the
      // distress chain.
      check(fake.notifyWrongPinAttemptCalls).equals(0);
      check(fake.confirmDistressCalls).equals(0);
      // The educational SnackBar is on-screen.
      expect(find.text(l10n.sessionEndSimDistressWouldFire), findsOneWidget);
    });

    testWidgets('simulation → [Skip] visible and ends the session', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState(isSimulation: true));
      final repo = _FakeAppSettingsRepository(
        initial: AppSettings(sessionEndPinHash: _hashDigits('1234')),
      );
      await _pumpWithRouter(
        tester,
        fake,
        extraOverrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      await tester.tap(find.byTooltip(l10n.commonClose));
      await tester.pumpAndSettle();
      await _swipeToConfirm(tester);
      await tester.pumpAndSettle();
      expect(find.text(l10n.sessionEndPinSimSkip), findsOneWidget);
      await tester.tap(find.text(l10n.sessionEndPinSimSkip));
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

  // ── Grace-period disarm slider ────────────────────────────────────────────
  group('SessionScreen — grace-period disarm slider', () {
    testWidgets('renders SwipeSlider (not a FilledButton) for the disarm CTA', (
      WidgetTester tester,
    ) async {
      // Spec 04 §Grace Period Slider mandates an 85 %-swipe gate so a
      // stray tap cannot disarm the chain.
      final fake = _FakeSessionController(_runningState());
      await _pump(tester, fake);
      expect(find.byType(SwipeSlider), findsOneWidget);
    });

    testWidgets('disarm slider uses the 0.85 spec threshold', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSessionController(_runningState());
      await _pump(tester, fake);
      final slider = tester.widget<SwipeSlider>(find.byType(SwipeSlider));
      expect(slider.threshold, 0.85);
    });

    testWidgets('shows "I\'m safe" label when stealth is disabled', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState());
      await _pump(tester, fake);
      expect(find.text(l10n.sessionDisarm), findsOneWidget);
      expect(find.text(l10n.sessionDisarmStealth), findsNothing);
    });

    testWidgets(
      'shows the stealth-variant "No Angela needed" label when stealth is on',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeSessionController(
          _runningState(stealthEnabled: true),
        );
        await _pump(tester, fake);
        expect(find.text(l10n.sessionDisarmStealth), findsOneWidget);
        expect(find.text(l10n.sessionDisarm), findsNothing);
      },
    );

    testWidgets('completing a full swipe past 0.85 calls controller.disarm()', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSessionController(_runningState());
      await _pump(tester, fake);
      // Drag by an offset larger than any reasonable track so the
      // 0.85 threshold is guaranteed crossed regardless of layout width.
      await tester.drag(
        find.byIcon(Icons.arrow_forward_rounded),
        const Offset(2000, 0),
      );
      await tester.pumpAndSettle();
      expect(fake.disarmCalls, 1);
    });

    testWidgets('a too-short drag below the 0.85 threshold does NOT disarm', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSessionController(_runningState());
      await _pump(tester, fake);
      // Drag by a tiny offset — well under 85 % of the track width.
      await tester.drag(
        find.byIcon(Icons.arrow_forward_rounded),
        const Offset(40, 0),
      );
      await tester.pumpAndSettle();
      expect(fake.disarmCalls, 0);
    });

    testWidgets('disarm slider disappears once the session ends', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSessionController(
        _runningState(phase: SessionPhase.ended),
      );
      await _pump(tester, fake);
      expect(find.byType(SwipeSlider), findsNothing);
    });
  });

  // ── Shared wrong-PIN counter (R-27 cross-overlay) ─────────────────────────
  group('SessionScreen — shared wrong-PIN counter across overlays', () {
    testWidgets(
      'EndSessionOverlay (2 wrong) + distress-cancel (3 wrong) shares one '
      'controller counter and fires distress on the combined 5th attempt',
      (WidgetTester tester) async {
        // Spec 06 §Wrong PIN Behavior (R-27) — "Counter scope": the
        // 5-attempt wrong-PIN budget is shared across every PIN gate in
        // the same session. A future regression where one overlay owns a
        // local counter would silently double the user's effective budget
        // and break the safety contract. This test exercises the cross-
        // overlay accumulation explicitly.
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeSessionController(_runningState());
        final repo = _FakeAppSettingsRepository(
          initial: AppSettings(
            sessionEndPinHash: _hashDigits('1234'),
            deceptivePinDialogEnabled: false,
            // wrongPinThreshold defaults to 5.
          ),
        );
        await _pumpWithRouter(
          tester,
          fake,
          extraOverrides: <Override>[
            appSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        );

        // ── Stage 1 — EndSessionOverlay: 2 wrong PINs, then Cancel ───────
        await tester.tap(find.byTooltip(l10n.commonClose));
        await tester.pumpAndSettle();
        await _swipeToConfirm(tester);
        await tester.pumpAndSettle();
        await _typeDigits(tester, '00000000');
        await tester.pumpAndSettle();
        await _typeDigits(tester, '00000000');
        await tester.pumpAndSettle();
        check(fake.notifyWrongPinAttemptCalls).equals(2);
        check(fake.confirmDistressCalls).equals(0);

        // Dismiss the overlay (counter must persist on the controller).
        await tester.tap(find.text(l10n.commonCancel));
        await tester.pumpAndSettle();
        expect(find.byType(EndSessionOverlay), findsNothing);

        // ── Stage 2 — push state into distress confirmation ──────────────
        fake.state = AsyncData(_runningState(distressConfirmRemaining: 5));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.distressConfirmCancel));
        await tester.pumpAndSettle();

        // ── Stage 3 — distress-cancel PIN gate: 3 wrong PINs ─────────────
        await _typeDigits(tester, '00000000');
        await tester.pumpAndSettle();
        await _typeDigits(tester, '00000000');
        await tester.pumpAndSettle();
        await _typeDigits(tester, '00000000');
        await tester.pumpAndSettle();

        // ── Stage 4 — assertions ─────────────────────────────────────────
        // Combined 5 increments on the controller counter.
        check(fake.notifyWrongPinAttemptCalls).equals(5);
        // Crossing the 5-attempt threshold fired the distress chain
        // exactly once with the wrong-PIN-exhausted reason — confirming
        // both overlays consult the same counter.
        check(fake.confirmDistressCalls).equals(1);
        check(
          fake.lastConfirmDistressReason,
        ).equals(EndReason.wrongPinExhausted);
      },
    );
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
