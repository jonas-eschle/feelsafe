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
import 'package:shared_preferences/shared_preferences.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/core/widgets/deceptive_old_pin_dialog.dart';
import 'package:guardianangela/core/widgets/pin_keypad.dart';
import 'package:guardianangela/core/widgets/swipe_slider.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/button_type.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/enums/pause_reason.dart';
import 'package:guardianangela/domain/enums/press_pattern.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/enums/stealth_timer_display.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/features/feedback_form/feedback_prompt_repository.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/features/session/session_screen.dart';
import 'package:guardianangela/features/session/widgets/end_session_overlay.dart';
import 'package:guardianangela/features/session/widgets/fake_music_player.dart';
import 'package:guardianangela/features/session/widgets/session_elapsed_clock.dart';
import 'package:guardianangela/features/session_completed/session_completed_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/sim/biometric_service_sim.dart';
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
  int earlyCheckInCalls = 0;
  int cancelDistressCalls = 0;
  int confirmDistressCalls = 0;
  EndReason? lastConfirmDistressReason;
  int holdPressedCalls = 0;
  int holdReleasedCalls = 0;
  int acknowledgeInterruptedCalls = 0;
  int startInterruptedModeAgainCalls = 0;

  /// Configurable result for [startInterruptedModeAgain]: true mimics an
  /// existing mode (a session started → route to /session); false mimics a
  /// deleted mode (route home).
  bool startInterruptedModeAgainResult = true;
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
  int pauseCalls = 0;
  int resumeCalls = 0;
  int resetWrongPinAttemptsCalls = 0;
  int notifyWrongPinAttemptCalls = 0;
  int pauseDistressCountdownCalls = 0;
  int resumeDistressCountdownCalls = 0;
  int _fakeWrongAttempts = 0;

  /// Configurable result for [currentSessionLogId] (the real getter reads
  /// the live recorder, which the fake never creates). Defaults to null.
  String? fakeSessionLogId;

  @override
  String? get currentSessionLogId => fakeSessionLogId;

  @override
  Future<SessionState> build() async => _initial;

  /// Test hook: pushes a new [SessionState] so the widget-under-test's
  /// `ref.listen` callbacks fire (used to drive nonce-based auto-appear).
  void emit(SessionState next) => state = AsyncData(next);

  @override
  Future<void> endSession({EndReason reason = EndReason.userQuit}) async {
    endSessionCalls++;
    final s = state.value ?? const SessionState.initial();
    state = AsyncData(s.copyWith(phase: SessionPhase.ended));
  }

  @override
  void disarm() => disarmCalls++;

  @override
  void earlyCheckIn() => earlyCheckInCalls++;

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
  Future<bool> startInterruptedModeAgain() async {
    startInterruptedModeAgainCalls++;
    final s = state.value;
    if (s != null) {
      state = AsyncData(s.copyWith(clearPrior: true));
    }
    return startInterruptedModeAgainResult;
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

  @override
  void pause({PauseReason reason = PauseReason.userRequested}) => pauseCalls++;

  @override
  void resume() => resumeCalls++;
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

/// An [AppSettingsRepository] whose [load] resolves only after [delay] —
/// used to race user input against the in-flight settings fetch.
class _SlowAppSettingsRepository extends _FakeAppSettingsRepository {
  _SlowAppSettingsRepository({super.initial, required this.delay});

  final Duration delay;

  /// Number of [load] calls observed (proves the single-flight guard).
  int loadCalls = 0;

  @override
  Future<AppSettings> load() async {
    loadCalls++;
    await Future<void>.delayed(delay);
    return super.load();
  }
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

/// A subtle tapButton disguise used by the disguised-reminder UI tests.
final ReminderTemplate _tapButtonTemplate = ReminderTemplate(
  id: 'test_calendar',
  name: 'Calendar Event',
  title: 'You have an appointment',
  body: 'Meeting with Alex at 3 PM',
  confirmationType: ConfirmationType.tapButton,
  buttonLabel: 'Acknowledge',
  isCustom: false,
  displayStyle: ReminderDisplayStyle.subtle,
  isGlobal: true,
);

/// A fullScreen disguise used by the auto-appear (#18) route-push test.
final ReminderTemplate _fullScreenTemplate = ReminderTemplate(
  id: 'test_fullscreen',
  name: 'Full Screen Reminder',
  title: 'You have an appointment',
  body: 'Meeting with Alex at 3 PM',
  confirmationType: ConfirmationType.tapButton,
  buttonLabel: 'Acknowledge',
  isCustom: false,
  displayStyle: ReminderDisplayStyle.fullScreen,
  isGlobal: true,
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
  String? priorModeId,
  String? priorModeName,
  DateTime? priorStartedAt,
  bool needsGpsDestinationPrompt = false,
  String? lastError,
  int missCount = 0,
  int elapsedSeconds = 42,
  bool stealthEnabled = false,
  StealthTimerDisplay timerDisplay = StealthTimerDisplay.normal,
  bool sessionScreenStealth = true,
  String fakeName = 'Music',
  bool isPaused = false,
  ReminderTemplate? activeReminderTemplate,
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
    isPaused: isPaused,
    isDistressChain: false,
    remainingSeconds: 15,
    distressConfirmRemaining: distressConfirmRemaining,
    priorInterrupted: priorInterrupted,
    priorModeId: priorModeId,
    priorModeName: priorModeName,
    priorStartedAt: priorStartedAt,
    lastError: lastError,
    needsGpsDestinationPrompt: needsGpsDestinationPrompt,
    stealthEnabled: stealthEnabled,
    timerDisplay: timerDisplay,
    sessionScreenStealth: sessionScreenStealth,
    fakeName: fakeName,
    activeReminderTemplate: activeReminderTemplate,
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
      // Keyed stub destinations so the auto-appear (#17/#18) tests can assert
      // that SessionScreen pushed the named route on a nonce bump.
      GoRoute(
        path: '/fake-call',
        name: RouteNames.fakeCall,
        builder: (_, state) => const _Blank(key: Key('stub-fakecall')),
      ),
      GoRoute(
        path: '/disguised-reminder',
        name: RouteNames.disguisedReminder,
        builder: (_, state) => const _Blank(key: Key('stub-reminder')),
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
  const _Blank({super.key});

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
      final l10n = await loadL10n(const Locale('en'));
      expect(
        find.text(l10n.commonErrorWithDetail('Bad state: injected test error')),
        findsOneWidget,
      );
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

    testWidgets('wait phase shows the early-check-in hint', (tester) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(
          type: ChainStepType.disguisedReminder,
          phase: SessionPhase.wait,
        ),
      );
      await _pump(tester, fake);
      expect(find.text(l10n.sessionReminderEarlyCheckInHint), findsOneWidget);
    });

    testWidgets('tapping the waiting reminder calls earlyCheckIn', (
      tester,
    ) async {
      final fake = _FakeSessionController(
        _runningState(
          type: ChainStepType.disguisedReminder,
          phase: SessionPhase.wait,
        ),
      );
      await _pump(tester, fake);
      await tester.tap(find.byIcon(Icons.shield_outlined));
      await tester.pump();
      expect(fake.earlyCheckInCalls, 1);
    });

    testWidgets('duration phase renders the selected template disguise', (
      tester,
    ) async {
      final fake = _FakeSessionController(
        _runningState(
          type: ChainStepType.disguisedReminder,
          phase: SessionPhase.duration,
          activeReminderTemplate: _tapButtonTemplate,
        ),
      );
      await _pump(tester, fake);
      expect(find.text('You have an appointment'), findsOneWidget);
      expect(find.text('Meeting with Alex at 3 PM'), findsOneWidget);
      expect(find.text('Acknowledge'), findsOneWidget);
    });

    testWidgets('tapping the template confirmation button checks in', (
      tester,
    ) async {
      final fake = _FakeSessionController(
        _runningState(
          type: ChainStepType.disguisedReminder,
          phase: SessionPhase.duration,
          activeReminderTemplate: _tapButtonTemplate,
        ),
      );
      await _pump(tester, fake);
      await tester.tap(find.text('Acknowledge'));
      await tester.pump();
      expect(fake.disarmCalls, 1);
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

  // ── Distress-cancel biometric (#9) ───────────────────────────────────────
  group('SessionScreen — distress-cancel biometric (#9)', () {
    testWidgets(
      'biometric success → cancelDistress without showing the keypad',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeSessionController(
          _runningState(distressConfirmRemaining: 5),
        );
        final repo = _FakeAppSettingsRepository(
          initial: AppSettings(
            sessionEndPinHash: _hashDigits('1234'),
            distressCancelBiometricEnabled: true,
          ),
        );
        final bio = SimulationBiometricService(
          available: true,
          authenticateResult: true,
        );
        await _pump(
          tester,
          fake,
          extraOverrides: <Override>[
            appSettingsRepositoryProvider.overrideWithValue(repo),
            biometricServiceProvider.overrideWithValue(bio),
          ],
        );
        await tester.tap(find.text(l10n.distressConfirmCancel));
        await tester.pumpAndSettle();
        // Biometric was consulted in order, distress cancelled, no PIN typed.
        check(bio.calls).deepEquals(<String>['isAvailable', 'authenticate']);
        check(fake.cancelDistressCalls).equals(1);
        check(fake.resetWrongPinAttemptsCalls).isGreaterThan(0);
        check(fake.pauseDistressCountdownCalls).equals(1);
      },
    );

    testWidgets('biometric off → no biometric call, keypad shown', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(distressConfirmRemaining: 5),
      );
      final repo = _FakeAppSettingsRepository(
        initial: AppSettings(sessionEndPinHash: _hashDigits('1234')),
      );
      final bio = SimulationBiometricService(
        available: true,
        authenticateResult: true,
      );
      await _pump(
        tester,
        fake,
        extraOverrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(repo),
          biometricServiceProvider.overrideWithValue(bio),
        ],
      );
      await tester.tap(find.text(l10n.distressConfirmCancel));
      await tester.pumpAndSettle();
      // The toggle is off → the biometric service is never consulted.
      check(bio.calls).isEmpty();
      expect(find.text(l10n.distressCancelPinPromptTitle), findsOneWidget);
      expect(find.byType(PinKeypad), findsOneWidget);
      check(fake.cancelDistressCalls).equals(0);
    });

    testWidgets('biometric failure → keypad shown and PIN still cancels', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(distressConfirmRemaining: 5),
      );
      final repo = _FakeAppSettingsRepository(
        initial: AppSettings(
          sessionEndPinHash: _hashDigits('1234'),
          distressCancelBiometricEnabled: true,
        ),
      );
      // available but the user cancels / mismatches → authenticate == false.
      final bio = SimulationBiometricService()..available = true;
      await _pump(
        tester,
        fake,
        extraOverrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(repo),
          biometricServiceProvider.overrideWithValue(bio),
        ],
      );
      await tester.tap(find.text(l10n.distressConfirmCancel));
      await tester.pumpAndSettle();
      check(bio.calls).deepEquals(<String>['isAvailable', 'authenticate']);
      // Fell back to the keypad; distress not yet cancelled.
      expect(find.byType(PinKeypad), findsOneWidget);
      check(fake.cancelDistressCalls).equals(0);
      // The PIN keypad still works after the failed biometric.
      await _typeDigits(tester, '1234');
      await tester.pumpAndSettle();
      check(fake.cancelDistressCalls).equals(1);
    });

    testWidgets(
      'biometric failure does NOT reset the 15s window — timeout still fires',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeSessionController(
          _runningState(distressConfirmRemaining: 5),
        );
        final repo = _FakeAppSettingsRepository(
          initial: AppSettings(
            sessionEndPinHash: _hashDigits('1234'),
            distressCancelBiometricEnabled: true,
          ),
        );
        final bio = SimulationBiometricService()..available = true;
        await _pump(
          tester,
          fake,
          extraOverrides: <Override>[
            appSettingsRepositoryProvider.overrideWithValue(repo),
            biometricServiceProvider.overrideWithValue(bio),
          ],
        );
        await tester.tap(find.text(l10n.distressConfirmCancel));
        await tester.pumpAndSettle();
        // The biometric attempt ran at t=0 and the window is untouched: the
        // keypad shows the FULL remaining time (15s default), proving the
        // deadline was neither reset nor extended by the biometric prompt.
        check(bio.calls).deepEquals(<String>['isAvailable', 'authenticate']);
        expect(
          find.text(l10n.distressCancelPinTimeoutLabel(15)),
          findsOneWidget,
        );
        // Advancing the SAME 16 one-second ticks still fires the timeout — if
        // the biometric attempt had restarted the timer this would not fire.
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
          priorModeId: 'mode-1',
          priorModeName: 'Walk Mode',
          priorStartedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      );
      await _pump(tester, fake);
      expect(find.text(l10n.sessionInterruptedTitle), findsOneWidget);
      expect(
        find.text(l10n.sessionInterruptedMode('Walk Mode')),
        findsOneWidget,
      );
    });

    testWidgets('renders priorStartedAt as a relative-time phrase', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      // 5 minutes ago → the "5 minutes ago" relative phrase, NOT a raw
      // timestamp.
      final priorAt = DateTime.now().subtract(const Duration(minutes: 5));
      final fake = _FakeSessionController(
        _runningState(
          priorInterrupted: true,
          priorModeId: 'mode-1',
          priorModeName: 'Date Mode',
          priorStartedAt: priorAt,
        ),
      );
      await _pump(tester, fake);
      expect(
        find.text(
          l10n.sessionInterruptedStarted(l10n.sessionInterruptedMinutesAgo(5)),
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows Start same mode button when the mode still exists', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(
          priorInterrupted: true,
          priorModeId: 'mode-1',
          priorModeName: 'Walk Mode',
          priorStartedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      );
      await _pump(tester, fake);
      expect(find.text(l10n.sessionInterruptedStartSameMode), findsOneWidget);
    });

    testWidgets('hides Start same mode button when the mode was deleted', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(
          priorInterrupted: true,
          // No priorModeId → the mode no longer exists.
          priorModeName: 'Walk Mode',
          priorStartedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      );
      await _pump(tester, fake);
      // The snapshotted mode name still renders, but no restart button.
      expect(
        find.text(l10n.sessionInterruptedMode('Walk Mode')),
        findsOneWidget,
      );
      expect(find.text(l10n.sessionInterruptedStartSameMode), findsNothing);
      expect(find.text(l10n.sessionInterruptedAcknowledge), findsOneWidget);
    });

    testWidgets('tapping Acknowledge calls acknowledgeInterruptedPrompt', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(
          priorInterrupted: true,
          priorModeId: 'mode-1',
          priorModeName: 'Walk Mode',
          priorStartedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      );
      // Route away requires GoRouter in the tree.
      await _pumpWithRouter(tester, fake);
      await tester.tap(find.text(l10n.sessionInterruptedAcknowledge));
      await tester.pumpAndSettle();
      check(fake.acknowledgeInterruptedCalls).equals(1);
    });

    testWidgets('tapping Start same mode calls startInterruptedModeAgain', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(
          priorInterrupted: true,
          priorModeId: 'mode-1',
          priorModeName: 'Walk Mode',
          priorStartedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      )..startInterruptedModeAgainResult = true;
      await _pumpWithRouter(tester, fake);
      await tester.tap(find.text(l10n.sessionInterruptedStartSameMode));
      await tester.pumpAndSettle();
      check(fake.startInterruptedModeAgainCalls).equals(1);
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

    // ── Biometric-first (#9) ───────────────────────────────────────────────
    testWidgets(
      'biometric success → swipe ends the session without the keypad',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeSessionController(_runningState());
        final repo = _FakeAppSettingsRepository(
          initial: AppSettings(
            sessionEndPinHash: _hashDigits('1234'),
            sessionEndPinBiometricEnabled: true,
          ),
        );
        final bio = SimulationBiometricService(
          available: true,
          authenticateResult: true,
        );
        await _pumpWithRouter(
          tester,
          fake,
          extraOverrides: <Override>[
            appSettingsRepositoryProvider.overrideWithValue(repo),
            biometricServiceProvider.overrideWithValue(bio),
          ],
        );
        await tester.tap(find.byTooltip(l10n.commonClose));
        await tester.pumpAndSettle();
        await _swipeToConfirm(tester);
        await tester.pumpAndSettle();
        // Biometric consulted in order; session ended with no PIN typed.
        check(bio.calls).deepEquals(<String>['isAvailable', 'authenticate']);
        check(fake.endSessionCalls).equals(1);
        expect(find.text(l10n.sessionEndPinPromptTitle), findsNothing);
      },
    );

    testWidgets('biometric off → swipe shows the keypad, no biometric call', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState());
      final repo = _FakeAppSettingsRepository(
        initial: AppSettings(sessionEndPinHash: _hashDigits('1234')),
      );
      final bio = SimulationBiometricService(
        available: true,
        authenticateResult: true,
      );
      await _pump(
        tester,
        fake,
        extraOverrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(repo),
          biometricServiceProvider.overrideWithValue(bio),
        ],
      );
      await tester.tap(find.byTooltip(l10n.commonClose));
      await tester.pumpAndSettle();
      await _swipeToConfirm(tester);
      await tester.pumpAndSettle();
      // Toggle off → the biometric service is never consulted; keypad shown.
      check(bio.calls).isEmpty();
      expect(find.text(l10n.sessionEndPinPromptTitle), findsOneWidget);
      check(fake.endSessionCalls).equals(0);
    });

    testWidgets('biometric failure → keypad shown and PIN still ends', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState());
      final repo = _FakeAppSettingsRepository(
        initial: AppSettings(
          sessionEndPinHash: _hashDigits('1234'),
          sessionEndPinBiometricEnabled: true,
        ),
      );
      final bio = SimulationBiometricService()..available = true;
      await _pumpWithRouter(
        tester,
        fake,
        extraOverrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(repo),
          biometricServiceProvider.overrideWithValue(bio),
        ],
      );
      await tester.tap(find.byTooltip(l10n.commonClose));
      await tester.pumpAndSettle();
      await _swipeToConfirm(tester);
      await tester.pumpAndSettle();
      check(bio.calls).deepEquals(<String>['isAvailable', 'authenticate']);
      // Fell back to the keypad; session not yet ended.
      expect(find.text(l10n.sessionEndPinPromptTitle), findsOneWidget);
      check(fake.endSessionCalls).equals(0);
      // PIN still works after the failed biometric.
      await _typeDigits(tester, '1234');
      await tester.pumpAndSettle();
      check(fake.endSessionCalls).equals(1);
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
      // Elapsed 65 s → "1:05" (SessionElapsedClock normal mode: non-padded
      // leading minutes, spec 04 §Timer Display Options).
      expect(find.text('1:05'), findsOneWidget);
      expect(find.byKey(sessionElapsedClockKey), findsOneWidget);
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

  group('SessionScreen — auto-appear on nonce bump (#17/#18)', () {
    testWidgets(
      'fakeCallShowNonce bump pushes the full-screen FakeCallScreen route',
      (tester) async {
        final initial = _runningState(
          type: ChainStepType.fakeCall,
          config: const FakeCallConfig(),
          phase: SessionPhase.duration,
        );
        final fake = _FakeSessionController(initial);
        await _pumpWithRouter(tester, fake);

        // Nothing pushed on load (nonce starts at 0).
        check(find.byKey(const Key('stub-fakecall')).evaluate()).isEmpty();

        // The engine bumping the nonce must drive the screen to auto-appear —
        // the same wire whose absence was the original #17 bug.
        fake.emit(initial.copyWith(fakeCallShowNonce: 1));
        await tester.pumpAndSettle();

        check(find.byKey(const Key('stub-fakecall')).evaluate()).isNotEmpty();
      },
    );

    testWidgets(
      'reminderShowNonce bump pushes DisguisedReminderScreen for a fullScreen '
      'template',
      (tester) async {
        final initial = _runningState(
          type: ChainStepType.disguisedReminder,
          phase: SessionPhase.duration,
          activeReminderTemplate: _fullScreenTemplate,
        );
        final fake = _FakeSessionController(initial);
        await _pumpWithRouter(tester, fake);

        check(find.byKey(const Key('stub-reminder')).evaluate()).isEmpty();

        fake.emit(initial.copyWith(reminderShowNonce: 1));
        await tester.pumpAndSettle();

        check(find.byKey(const Key('stub-reminder')).evaluate()).isNotEmpty();
      },
    );

    testWidgets(
      'reminderShowNonce bump does NOT push a route for a subtle template '
      '(it renders inline instead)',
      (tester) async {
        final initial = _runningState(
          type: ChainStepType.disguisedReminder,
          phase: SessionPhase.duration,
          activeReminderTemplate: _tapButtonTemplate,
        );
        final fake = _FakeSessionController(initial);
        await _pumpWithRouter(tester, fake);

        fake.emit(initial.copyWith(reminderShowNonce: 1));
        await tester.pumpAndSettle();

        // subtle disguises stay inline; no full-screen route is pushed.
        check(find.byKey(const Key('stub-reminder')).evaluate()).isEmpty();
      },
    );
  });

  group('SessionScreen — paused badge reason (#11)', () {
    testWidgets('shows the incoming-call label when pauseReason is '
        'incomingCall', (WidgetTester tester) async {
      final fake = _FakeSessionController(
        _runningState().copyWith(
          isPaused: true,
          pauseReason: PauseReason.incomingCall,
        ),
      );
      await _pump(tester, fake);

      final l10n = await loadL10n(const Locale('en'));
      expect(find.text(l10n.sessionPausedIncomingCall), findsOneWidget);
      expect(find.text(l10n.sessionPausedBadge), findsNothing);
    });

    testWidgets('shows the generic Paused label for a user-requested pause', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSessionController(
        _runningState().copyWith(isPaused: true),
      );
      await _pump(tester, fake);

      final l10n = await loadL10n(const Locale('en'));
      expect(find.text(l10n.sessionPausedBadge), findsOneWidget);
    });
  });

  // ── Stealth: fake music player + timer display + branding (C1, #15) ───────
  group('SessionScreen — stealth fake music player (#15)', () {
    testWidgets('stealth ON renders the fake music player, not the step UI', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState(stealthEnabled: true));
      await _pump(tester, fake);
      // The disguise chrome is present…
      expect(find.byType(FakeMusicPlayer), findsOneWidget);
      // The header brand line shows the resolved fakeName (default 'Music').
      expect(find.text('Music'), findsOneWidget);
      expect(find.text(l10n.sessionStealthTrackTitle), findsOneWidget);
      // …and the normal hold-button step prompt is NOT shown underneath.
      expect(find.text(l10n.sessionHoldPrompt), findsNothing);
      // The standard header step counter does not render in the disguise.
      expect(find.text(l10n.sessionStepLabel('1', '1')), findsNothing);
    });

    testWidgets('header brand line shows the resolved fakeName (#15 C3)', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(stealthEnabled: true, fakeName: 'Spotify'),
      );
      await _pump(tester, fake);
      // The configured disguise app name occupies the player's app/brand line…
      expect(find.text('Spotify'), findsOneWidget);
      // …and the neutral "Now playing" fallback is NOT shown when a name is set.
      expect(find.text(l10n.sessionStealthNowPlaying), findsNothing);
    });

    testWidgets('blank fakeName falls back to the neutral header label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(stealthEnabled: true, fakeName: '   '),
      );
      await _pump(tester, fake);
      expect(find.text(l10n.sessionStealthNowPlaying), findsOneWidget);
    });

    testWidgets('non-stealth session does NOT render the music player', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSessionController(_runningState());
      await _pump(tester, fake);
      expect(find.byType(FakeMusicPlayer), findsNothing);
    });

    testWidgets('play/pause button calls pause() while the session runs', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState(stealthEnabled: true));
      await _pump(tester, fake);
      // Running → the control is a "pause" button wired to pause().
      await tester.tap(find.byTooltip(l10n.sessionStealthPause));
      await tester.pump();
      expect(fake.pauseCalls, 1);
      expect(fake.resumeCalls, 0);
    });

    testWidgets(
      'play/pause button calls resume() while the session is paused',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeSessionController(
          _runningState(stealthEnabled: true, isPaused: true),
        );
        await _pump(tester, fake);
        // Paused → the control is a "play" button wired to resume().
        await tester.tap(find.byTooltip(l10n.sessionStealthPlay));
        await tester.pump();
        expect(fake.resumeCalls, 1);
        expect(fake.pauseCalls, 0);
      },
    );

    testWidgets('swiping the music-player progress track calls disarm()', (
      WidgetTester tester,
    ) async {
      // Use a tall phone-shaped surface so the music player fits without the
      // overflow-safe scroll view becoming scrollable (a scrollable view
      // would otherwise compete with the swipe gesture's pan recogniser).
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final fake = _FakeSessionController(_runningState(stealthEnabled: true));
      await _pump(tester, fake);
      // Drag the only knob across the track with an incremental horizontal
      // gesture (a real swipe), crossing the 0.85 threshold.
      final gesture = await tester.startGesture(
        tester.getCenter(find.byIcon(Icons.arrow_forward_rounded)),
      );
      for (int i = 0; i < 40; i++) {
        await gesture.moveBy(const Offset(20, 0));
        await tester.pump();
      }
      await gesture.up();
      await tester.pumpAndSettle();
      expect(fake.disarmCalls, 1);
    });

    testWidgets('timerDisplay.normal shows the full clock string', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSessionController(
        _runningState(stealthEnabled: true, elapsedSeconds: 65),
      );
      await _pump(tester, fake);
      expect(find.byKey(sessionElapsedClockKey), findsOneWidget);
      // 65 s → "1:05".
      expect(find.text('1:05'), findsOneWidget);
    });

    testWidgets('timerDisplay.small shows the corner M:SS clock', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSessionController(
        _runningState(
          stealthEnabled: true,
          timerDisplay: StealthTimerDisplay.small,
          elapsedSeconds: 65,
        ),
      );
      await _pump(tester, fake);
      expect(find.byKey(sessionElapsedClockKey), findsOneWidget);
      expect(find.text('1:05'), findsOneWidget);
    });

    testWidgets('timerDisplay.none hides the clock value', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSessionController(
        _runningState(
          stealthEnabled: true,
          timerDisplay: StealthTimerDisplay.none,
          elapsedSeconds: 65,
        ),
      );
      await _pump(tester, fake);
      // The widget is still in the tree (carries the key) but renders no text.
      expect(find.byKey(sessionElapsedClockKey), findsOneWidget);
      expect(find.text('1:05'), findsNothing);
    });

    testWidgets('sessionScreenStealth strips the app-bar title', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState(stealthEnabled: true));
      await _pump(tester, fake);
      // Brand-free: the "Session" title is gone from the app bar.
      expect(find.text(l10n.sessionTitle), findsNothing);
    });

    testWidgets(
      'sessionScreenStealth=false keeps the app-bar title even in stealth',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeSessionController(
          _runningState(stealthEnabled: true, sessionScreenStealth: false),
        );
        await _pump(tester, fake);
        expect(find.text(l10n.sessionTitle), findsOneWidget);
      },
    );

    testWidgets('end-session overlay renders brand-free in stealth', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState(stealthEnabled: true));
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
      // The overlay is up and the swipe gate works, but the brand title is
      // stripped (spec 04 §Stealth Mode and PIN). The body text — which only
      // the non-stealth swipe stage renders — is absent.
      expect(find.byType(EndSessionOverlay), findsOneWidget);
      expect(find.text(l10n.sessionEndOverlaySwipeLabel), findsOneWidget);
      expect(find.text(l10n.sessionEndOverlayTitle), findsNothing);
      expect(find.text(l10n.sessionEndOverlayBody), findsNothing);
    });
  });

  // ── Post-session feedback prompt path (Tier-F F5) ───────────────────────
  //
  // Drives the REAL SessionController._confirmedEnd flow (End-Session swipe,
  // no PIN) through the REAL FeedbackPromptRepository, then asserts the real
  // SessionCompletedScreen surfaces (or suppresses) the feedback prompt. The
  // completion route renders the actual screen reading the `feedback` query
  // param so the whole chain is exercised end-to-end.
  group('SessionScreen — post-session feedback prompt (F5)', () {
    testWidgets(
      'clean REAL end at the threshold surfaces the feedback prompt',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        // Two prior completions seeded → this clean end is the 3rd, crossing
        // FeedbackPromptRepository.promptThreshold.
        SharedPreferences.setMockInitialValues(<String, Object>{
          FeedbackPromptRepository.completedCountKey: 2,
        });
        final promptRepo = FeedbackPromptRepository();
        final fake = _FakeSessionController(_runningState());
        await _pumpFeedbackPath(tester, fake, promptRepo);
        await tester.tap(find.byTooltip(l10n.commonClose));
        await tester.pumpAndSettle();
        await _swipeToConfirm(tester);
        await tester.pumpAndSettle();
        // Counter advanced to 3 and the real completed screen shows the prompt.
        check(await promptRepo.completedCount()).equals(3);
        expect(find.text(l10n.sessionCompletedFeedbackPrompt), findsOneWidget);
        expect(find.text(l10n.sessionCompletedFeedbackSend), findsOneWidget);
      },
    );

    testWidgets(
      'clean REAL end below the threshold counts but shows no prompt',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        SharedPreferences.setMockInitialValues(<String, Object>{});
        final promptRepo = FeedbackPromptRepository();
        final fake = _FakeSessionController(_runningState());
        await _pumpFeedbackPath(tester, fake, promptRepo);
        await tester.tap(find.byTooltip(l10n.commonClose));
        await tester.pumpAndSettle();
        await _swipeToConfirm(tester);
        await tester.pumpAndSettle();
        // First completion is recorded, but the prompt stays hidden (< 3).
        check(await promptRepo.completedCount()).equals(1);
        expect(find.text(l10n.sessionCompletedFeedbackPrompt), findsNothing);
      },
    );

    testWidgets('a SIMULATION clean end never counts or prompts', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      // Pre-seed AT the threshold to prove a simulation still never prompts.
      SharedPreferences.setMockInitialValues(<String, Object>{
        FeedbackPromptRepository.completedCountKey: 3,
      });
      final promptRepo = FeedbackPromptRepository();
      final fake = _FakeSessionController(_runningState(isSimulation: true));
      await _pumpFeedbackPath(tester, fake, promptRepo);
      await tester.tap(find.byTooltip(l10n.commonClose));
      await tester.pumpAndSettle();
      await _swipeToConfirm(tester);
      await tester.pumpAndSettle();
      // Simulation must not bump the real-session counter…
      check(await promptRepo.completedCount()).equals(3);
      // …and the prompt never appears for a simulation completion.
      expect(find.text(l10n.sessionCompletedFeedbackPrompt), findsNothing);
    });

    testWidgets('a STEALTH clean end never counts or prompts', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      SharedPreferences.setMockInitialValues(<String, Object>{
        FeedbackPromptRepository.completedCountKey: 3,
      });
      final promptRepo = FeedbackPromptRepository();
      final fake = _FakeSessionController(_runningState(stealthEnabled: true));
      await _pumpFeedbackPath(tester, fake, promptRepo);
      await tester.tap(find.byTooltip(l10n.commonClose));
      await tester.pumpAndSettle();
      await _swipeToConfirm(tester);
      await tester.pumpAndSettle();
      // Stealth completion is silent: no count bump, no prompt
      // (spec 04:1247/1250).
      check(await promptRepo.completedCount()).equals(3);
      expect(find.text(l10n.sessionCompletedFeedbackPrompt), findsNothing);
    });
  });

  // ── Route pop resets the auto-appear flags (#17/#18) ──────────────────────
  group('SessionScreen — auto-appear flag resets on route pop', () {
    testWidgets('fake call can re-appear after the pushed route pops', (
      WidgetTester tester,
    ) async {
      final initial = _runningState(
        type: ChainStepType.fakeCall,
        config: const FakeCallConfig(),
        phase: SessionPhase.duration,
      );
      final fake = _FakeSessionController(initial);
      await _pumpWithRouter(tester, fake);

      fake.emit(initial.copyWith(fakeCallShowNonce: 1));
      await tester.pumpAndSettle();
      check(find.byKey(const Key('stub-fakecall')).evaluate()).isNotEmpty();

      // Pop the fake-call route (user declined / engine moved on).
      Navigator.of(
        tester.element(find.byKey(const Key('stub-fakecall'))),
      ).pop();
      await tester.pumpAndSettle();
      check(find.byKey(const Key('stub-fakecall')).evaluate()).isEmpty();

      // The guard flag must be cleared — a retry re-fire must re-appear.
      fake.emit(initial.copyWith(fakeCallShowNonce: 2));
      await tester.pumpAndSettle();
      check(find.byKey(const Key('stub-fakecall')).evaluate()).isNotEmpty();
    });

    testWidgets('full-screen reminder can re-appear after its route pops', (
      WidgetTester tester,
    ) async {
      final initial = _runningState(
        type: ChainStepType.disguisedReminder,
        phase: SessionPhase.duration,
        activeReminderTemplate: _fullScreenTemplate,
      );
      final fake = _FakeSessionController(initial);
      await _pumpWithRouter(tester, fake);

      fake.emit(initial.copyWith(reminderShowNonce: 1));
      await tester.pumpAndSettle();
      check(find.byKey(const Key('stub-reminder')).evaluate()).isNotEmpty();

      Navigator.of(
        tester.element(find.byKey(const Key('stub-reminder'))),
      ).pop();
      await tester.pumpAndSettle();
      check(find.byKey(const Key('stub-reminder')).evaluate()).isEmpty();

      fake.emit(initial.copyWith(reminderShowNonce: 2));
      await tester.pumpAndSettle();
      check(find.byKey(const Key('stub-reminder')).evaluate()).isNotEmpty();
    });
  });

  // ── End-session flow details (C7a) ────────────────────────────────────────
  group('SessionScreen — end-session flow details', () {
    testWidgets('the session log id is forwarded to the completed screen', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final promptRepo = FeedbackPromptRepository();
      final fake = _FakeSessionController(_runningState())
        ..fakeSessionLogId = 'log-123';
      await _pumpFeedbackPath(tester, fake, promptRepo);
      await tester.tap(find.byTooltip(l10n.commonClose));
      await tester.pumpAndSettle();
      await _swipeToConfirm(tester);
      await tester.pumpAndSettle();

      final completed = tester.widget<SessionCompletedScreen>(
        find.byType(SessionCompletedScreen),
      );
      check(completed.logId).equals('log-123');
    });

    testWidgets('cancelling the quick-exit dialog does not quick-exit', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState());
      await _pump(tester, fake);
      await tester.tap(find.byTooltip(l10n.sessionQuickExitTitle));
      await tester.pumpAndSettle();
      expect(find.text(l10n.sessionQuickExitBody), findsOneWidget);

      await tester.tap(find.text(l10n.commonCancel));
      await tester.pumpAndSettle();

      expect(find.text(l10n.sessionQuickExitBody), findsNothing);
      check(fake.triggerQuickExitCalls).equals(0);
    });

    testWidgets(
      'a swipe before the settings load lands still resolves the PIN gate',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeSessionController(_runningState());
        final repo = _SlowAppSettingsRepository(
          initial: AppSettings(sessionEndPinHash: _hashDigits('1234')),
          delay: const Duration(seconds: 1),
        );
        await _pump(
          tester,
          fake,
          extraOverrides: <Override>[
            appSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        );
        await tester.tap(find.byTooltip(l10n.commonClose));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        // Swipe while the overlay's settings load is still in flight.
        await _swipeToConfirm(tester);
        await tester.pump();
        // The swipe handler must NOT bypass the PIN: nothing ended yet.
        check(fake.endSessionCalls).equals(0);
        // Once the load lands, the gate resolves to the PIN keypad.
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();
        expect(find.text(l10n.sessionEndPinPromptTitle), findsOneWidget);
        check(fake.endSessionCalls).equals(0);
      },
    );

    testWidgets('backspace edits the end-session PIN entry', (
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

      // Mistype two digits, erase them (plus one no-op on empty), then
      // type the correct PIN — only possible if backspace really edits.
      await _typeDigits(tester, '99');
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();
      await _typeDigits(tester, '1234');
      await tester.pumpAndSettle();

      check(fake.endSessionCalls).equals(1);
      check(fake.notifyWrongPinAttemptCalls).equals(0);
    });

    test('endReasonFor maps every overlay outcome to its EndReason', () {
      check(
        endReasonFor(EndSessionOutcome.dismissed),
      ).equals(EndReason.userQuit);
      check(
        endReasonFor(EndSessionOutcome.endConfirmed),
      ).equals(EndReason.userQuit);
      check(
        endReasonFor(EndSessionOutcome.duressPinEntered),
      ).equals(EndReason.duressPin);
      check(
        endReasonFor(EndSessionOutcome.wrongPinExhausted),
      ).equals(EndReason.wrongPinExhausted);
    });
  });

  // ── Distress overlay settings races (C7a) ─────────────────────────────────
  group('SessionScreen — distress overlay settings races', () {
    testWidgets(
      'cancel during the in-flight settings load waits (no double fetch) '
      'and still reaches the PIN stage',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeSessionController(
          _runningState(distressConfirmRemaining: 5),
        );
        final repo = _SlowAppSettingsRepository(
          initial: AppSettings(sessionEndPinHash: _hashDigits('1234')),
          delay: const Duration(milliseconds: 400),
        );
        await _pump(
          tester,
          fake,
          extraOverrides: <Override>[
            appSettingsRepositoryProvider.overrideWithValue(repo),
          ],
          settle: false,
        );
        await tester.pump();
        // initState's load is still in flight — tap cancel NOW.
        await tester.tap(find.text(l10n.distressConfirmCancel));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // The handler yielded for the in-flight load instead of refetching.
        check(repo.loadCalls).equals(1);
        expect(find.byType(PinKeypad), findsOneWidget);
        check(fake.pauseDistressCountdownCalls).equals(1);
      },
    );

    testWidgets(
      'overlay dismissed before the settings load lands does not crash',
      (WidgetTester tester) async {
        final initial = _runningState(distressConfirmRemaining: 5);
        final fake = _FakeSessionController(initial);
        final repo = _SlowAppSettingsRepository(
          initial: const AppSettings(),
          delay: const Duration(milliseconds: 400),
        );
        await _pump(
          tester,
          fake,
          extraOverrides: <Override>[
            appSettingsRepositoryProvider.overrideWithValue(repo),
          ],
          settle: false,
        );
        await tester.pump();
        // The countdown resolves (cancel elsewhere) → the overlay unmounts
        // while its settings load is still pending.
        fake.emit(initial.copyWith(clearDistressConfirm: true));
        await tester.pump();
        // Now the load lands against the unmounted state.
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(PinKeypad), findsNothing);
      },
    );

    testWidgets('backspace edits the distress-cancel PIN entry', (
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

      await _typeDigits(tester, '99');
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();
      // Extra backspace on an empty entry is a guarded no-op.
      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();
      await _typeDigits(tester, '1234');
      await tester.pumpAndSettle();

      check(fake.cancelDistressCalls).equals(1);
      check(fake.confirmDistressCalls).equals(0);
      check(fake.notifyWrongPinAttemptCalls).equals(0);
    });
  });

  // ── Step-UI branches (C7a) ────────────────────────────────────────────────
  group('SessionScreen — step-UI branches', () {
    testWidgets('the stealth surface never shows the branded disarm label', (
      WidgetTester tester,
    ) async {
      // stealthEnabled swaps the whole body for the fake music player —
      // its disarm affordance must use the neutral wording only.
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(
          phase: SessionPhase.holdWait,
          stealthEnabled: true,
          sessionScreenStealth: false,
        ),
      );
      await _pump(tester, fake);
      expect(find.text(l10n.sessionDisarmStealth), findsOneWidget);
      expect(find.text(l10n.sessionDisarm), findsNothing);
    });

    testWidgets('missCount > 0 renders the miss-count chip', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(_runningState(missCount: 2));
      await _pump(tester, fake);
      expect(find.text(l10n.sessionMissCount('2')), findsOneWidget);
    });

    testWidgets('grace phase shows the red last-chance countdown label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(phase: SessionPhase.grace),
      );
      await _pump(tester, fake);
      expect(find.text(l10n.sessionHoldGraceCountdown('15')), findsOneWidget);
    });

    testWidgets('sensitivity phase shows the release countdown label', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(phase: SessionPhase.sensitivity),
      );
      await _pump(tester, fake);
      expect(find.text(l10n.sessionHoldReleaseCountdown('15')), findsOneWidget);
    });

    testWidgets('hold button press/release reaches the controller', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(phase: SessionPhase.holdWait),
      );
      await _pump(tester, fake);

      final target = find.text(l10n.sessionHoldTouchToBegin);
      final gesture = await tester.startGesture(tester.getCenter(target));
      await tester.pump(const Duration(milliseconds: 200));
      check(fake.holdPressedCalls).equals(1);

      await gesture.up();
      await tester.pump();
      check(fake.holdReleasedCalls).equals(1);

      // A cancelled tap (pointer dragged away) must also release the hold —
      // otherwise a slipped finger would keep the engine in holding state.
      final cancelGesture = await tester.startGesture(tester.getCenter(target));
      await tester.pump(const Duration(milliseconds: 200));
      check(fake.holdPressedCalls).equals(2);
      await cancelGesture.moveBy(const Offset(300, 0));
      await tester.pump();
      check(fake.holdReleasedCalls).equals(2);
      await cancelGesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('blackScreenMode renders the black hold surface and wires '
        'press/release', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(
          phase: SessionPhase.holdWait,
          config: const HoldButtonConfig(blackScreenMode: true),
        ),
      );
      await _pump(tester, fake);

      final target = find.text(l10n.sessionHoldTouchToBegin);
      expect(target, findsOneWidget);
      final gesture = await tester.startGesture(tester.getCenter(target));
      await tester.pump(const Duration(milliseconds: 200));
      check(fake.holdPressedCalls).equals(1);
      await gesture.up();
      await tester.pump();
      check(fake.holdReleasedCalls).equals(1);

      // A slipped finger (tap cancel) must release the hold too.
      final cancelGesture = await tester.startGesture(tester.getCenter(target));
      await tester.pump(const Duration(milliseconds: 200));
      check(fake.holdPressedCalls).equals(2);
      await cancelGesture.moveBy(const Offset(300, 0));
      await tester.pump();
      check(fake.holdReleasedCalls).equals(2);
      await cancelGesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('blackScreenMode shows the hold prompt while holding', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(
          phase: SessionPhase.duration,
          isHolding: true,
          config: const HoldButtonConfig(blackScreenMode: true),
        ),
      );
      await _pump(tester, fake);
      expect(find.text(l10n.sessionHoldPrompt), findsOneWidget);
    });

    testWidgets('reminder wait UI formats minutes and shows the miss count', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(
          type: ChainStepType.disguisedReminder,
          phase: SessionPhase.wait,
          missCount: 3,
        ).copyWith(remainingSeconds: 90),
      );
      await _pump(tester, fake);
      expect(find.text(l10n.sessionStepNextCheckIn('1m 30s')), findsOneWidget);
      expect(find.text(l10n.sessionMissCount('3')), findsWidgets);
    });

    testWidgets('reminder wait UI formats whole minutes without seconds', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(
          type: ChainStepType.disguisedReminder,
          phase: SessionPhase.wait,
        ).copyWith(remainingSeconds: 120),
      );
      await _pump(tester, fake);
      expect(find.text(l10n.sessionStepNextCheckIn('2m')), findsOneWidget);
    });

    testWidgets('GPS prompt confirm forwards the parsed destination', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(needsGpsDestinationPrompt: true),
      );
      await _pump(tester, fake);

      await tester.enterText(find.byType(TextField).at(0), '46.5');
      await tester.enterText(find.byType(TextField).at(1), '6.6');
      await tester.tap(find.text(l10n.sessionGpsDestinationConfirm));
      await tester.pumpAndSettle();

      check(fake.setGpsDestinationCalls).equals(1);
      check(fake.lastSetGpsLat).equals(46.5);
      check(fake.lastSetGpsLng).equals(6.6);
    });

    testWidgets('GPS prompt confirm rejects unparseable coordinates', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(needsGpsDestinationPrompt: true),
      );
      await _pump(tester, fake);

      await tester.enterText(find.byType(TextField).at(0), 'abc');
      await tester.enterText(find.byType(TextField).at(1), '6.6');
      await tester.tap(find.text(l10n.sessionGpsDestinationConfirm));
      await tester.pumpAndSettle();

      // No destination forwarded; the prompt stays up.
      check(fake.setGpsDestinationCalls).equals(0);
      expect(find.text(l10n.sessionGpsDestinationTitle), findsOneWidget);
    });

    testWidgets('simulation controls drive speed, leap and silent toggles', (
      WidgetTester tester,
    ) async {
      final fake = _FakeSessionController(_runningState(isSimulation: true));
      await _pump(tester, fake);

      await tester.drag(find.byType(Slider), const Offset(80, 0));
      await tester.pumpAndSettle();
      check(fake.setSimulationSpeedCalls).isGreaterOrEqual(1);
      check(fake.lastSimulationSpeedValue).isNotNull();
      check(fake.lastSimulationSpeedValue!).isGreaterThan(1.0);

      await tester.tap(find.byIcon(Icons.fast_forward));
      await tester.pump();
      check(fake.leapCalls).equals(1);

      // simulationSilent defaults true → toggling requests false.
      await tester.tap(find.byType(Switch));
      await tester.pump();
      check(fake.setSimulationSilentCalls).equals(1);
      check(fake.lastSimulationSilentValue).equals(false);
    });

    testWidgets('fakeCall step exposes a manual re-open button', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(
          type: ChainStepType.fakeCall,
          config: const FakeCallConfig(callerName: 'Zoe'),
          phase: SessionPhase.duration,
        ),
      );
      await _pumpWithRouter(tester, fake);

      await tester.tap(find.text(l10n.sessionStepFakeCallOpen));
      await tester.pumpAndSettle();

      check(find.byKey(const Key('stub-fakecall')).evaluate()).isNotEmpty();
    });

    testWidgets('callEmergency wait UI renders the configured number', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(
          type: ChainStepType.callEmergency,
          config: const CallEmergencyConfig(emergencyNumber: '999'),
          phase: SessionPhase.wait,
        ),
      );
      await _pump(tester, fake);
      expect(
        find.text(l10n.sessionStepCallEmergencyNumber('999')),
        findsOneWidget,
      );
    });

    testWidgets('callEmergency wait UI falls back to 112 and flags the '
        'simulation block', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeSessionController(
        _runningState(
          type: ChainStepType.callEmergency,
          config: const CallEmergencyConfig(),
          phase: SessionPhase.wait,
          isSimulation: true,
        ),
      );
      await _pump(tester, fake);
      expect(
        find.text(l10n.sessionStepCallEmergencyNumber('112')),
        findsOneWidget,
      );
      expect(find.text(l10n.sessionStepSimBlockedEmergency), findsOneWidget);
    });

    testWidgets('a NEW emergency step re-arms a previously dismissed overlay', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final s1 = _runningState(
        type: ChainStepType.callEmergency,
        phase: SessionPhase.duration,
      );
      final fake = _FakeSessionController(s1);
      await _pump(tester, fake);
      expect(find.text(l10n.sessionEmergencyConfirmKeep), findsOneWidget);

      // Dismiss for THIS step.
      await tester.tap(find.text(l10n.sessionEmergencyConfirmKeep));
      await tester.pumpAndSettle();
      expect(find.text(l10n.sessionEmergencyConfirmKeep), findsNothing);

      // A different emergency step starts → the stale dismissal must clear
      // and the overlay must re-arm (each emergency gets its own veto).
      final step2 = ChainStep(
        id: 'em-step-2',
        type: ChainStepType.callEmergency,
        order: 0,
        waitSeconds: 0,
        durationSeconds: 30,
        gracePeriodSeconds: 5,
        retryCount: 0,
        randomize: false,
      );
      fake.emit(s1.copyWith(activeChain: <ChainStep>[step2]));
      await tester.pumpAndSettle();

      expect(find.text(l10n.sessionEmergencyConfirmKeep), findsOneWidget);
    });
  });
}

/// Pumps [SessionScreen] inside a router whose `completed` route renders the
/// REAL [SessionCompletedScreen] (reading the `feedback` query param) so the
/// F5 end-to-end path can be asserted. Overrides the real
/// [feedbackPromptRepositoryProvider] with [promptRepo].
Future<void> _pumpFeedbackPath(
  WidgetTester tester,
  _FakeSessionController fake,
  FeedbackPromptRepository promptRepo, {
  List<Override> extraOverrides = const <Override>[],
}) async {
  final router = GoRouter(
    initialLocation: '/session',
    routes: <GoRoute>[
      GoRoute(
        path: '/session',
        name: RouteNames.session,
        builder: (_, _) => const SessionScreen(),
        routes: <GoRoute>[
          GoRoute(
            path: 'completed',
            name: RouteNames.sessionCompleted,
            builder: (_, GoRouterState state) => SessionCompletedScreen(
              durationSeconds: int.tryParse(
                state.uri.queryParameters['duration'] ?? '',
              ),
              logId: state.uri.queryParameters['id'],
              isSimulation: state.uri.queryParameters['simulation'] == 'true',
              showFeedbackPrompt:
                  state.uri.queryParameters['feedback'] == 'true',
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/settings/feedback',
        name: RouteNames.settingsFeedback,
        builder: (_, _) => const _Blank(),
      ),
      GoRoute(
        path: '/',
        name: RouteNames.home,
        builder: (_, _) => const _Blank(),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        sessionControllerProvider.overrideWith(() => fake),
        feedbackPromptRepositoryProvider.overrideWithValue(promptRepo),
        // No PIN configured → the End-Session swipe completes immediately,
        // driving _confirmedEnd. Without this the overlay cannot read
        // settings and the swipe path stalls.
        appSettingsRepositoryProvider.overrideWithValue(
          _FakeAppSettingsRepository(),
        ),
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
  await tester.pumpAndSettle();
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
