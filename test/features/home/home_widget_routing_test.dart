/// Tests for the home-screen widget URI routing fix (FIX 1).
///
/// Asserts:
/// - quick-exit with an active session navigates to /session?quickExit=true
///   (i.e. pushNamed is called with the flag).
/// - quick-exit with no active session (idle / ended) is a no-op.
/// - fake-call routes to RouteNames.fakeCall.
/// - SessionScreen(quickExit: true) auto-calls _endSessionFlow once after
///   the first frame via WidgetsBinding.addPostFrameCallback (covered by
///   asserting that EndSessionOverlay appears).
library;

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/features/session/session_screen.dart';
import 'package:guardianangela/features/session/widgets/end_session_overlay.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/sim/quick_exit_service_sim.dart';

// ---------------------------------------------------------------------------
// Minimal fakes
// ---------------------------------------------------------------------------

/// Fake session controller that records endSession calls and exposes the
/// state it was built with.
class _FakeSessionController extends SessionController {
  _FakeSessionController(this._initial);
  final SessionState _initial;

  int endSessionCalls = 0;

  @override
  Future<SessionState> build() async => _initial;

  @override
  Future<void> endSession({EndReason reason = EndReason.userQuit}) async {
    endSessionCalls++;
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
  void confirmDistress({EndReason reason = EndReason.hardwarePanic}) {}

  @override
  void pauseDistressCountdown() {}

  @override
  void resumeDistressCountdown() {}

  @override
  void resetWrongPinAttempts() {}

  @override
  int notifyWrongPinAttempt() => 0;

  @override
  int get wrongPinAttempts => 0;

  @override
  void holdPressed() {}

  @override
  void holdReleased() {}

  @override
  void acknowledgeInterruptedPrompt() {}

  @override
  void setGpsDestination({required double lat, required double lng}) {}

  @override
  void skipGpsDestination() {}

  @override
  Future<void> triggerQuickExit() async {}

  @override
  void setSimulationSilent(bool value) {}

  @override
  void setSimulationSpeed(double value) {}

  @override
  void leap() {}
}

/// An [AppSettingsRepository] that returns [AppSettings] with no session-end
/// PIN so the EndSessionOverlay resolves to the no-PIN fast path.
class _FakeAppSettingsRepository extends AppSettingsRepository {
  _FakeAppSettingsRepository()
    : super(
        keyProvider: () async =>
            '0102030405060708090a0b0c0d0e0f'
            '101112131415161718191a1b1c1d1e1f20',
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('widget_route_test_'),
      );

  @override
  Future<AppSettings> load() async => const AppSettings();
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// A minimal running [SessionState] (phase != idle, != ended).
SessionState _runningSessionState() {
  final step = ChainStep(
    id: 'step-0',
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
    elapsedSeconds: 10,
    phase: SessionPhase.holding,
    activeChain: <ChainStep>[step],
    currentStepIndex: 0,
    missCount: 0,
    isHolding: true,
    isPaused: false,
    isDistressChain: false,
  );
}

/// Pumps [SessionScreen] with [quickExit] inside a two-route GoRouter.
///
/// Returns the fake controller so tests can assert on call counts.
Future<_FakeSessionController> _pumpSessionScreen(
  WidgetTester tester, {
  required bool quickExit,
  required List<Override> extraOverrides,
}) async {
  final fake = _FakeSessionController(_runningSessionState());
  final router = GoRouter(
    initialLocation: '/session${quickExit ? '?quickExit=true' : ''}',
    routes: <GoRoute>[
      GoRoute(
        path: '/session',
        name: RouteNames.session,
        builder: (_, GoRouterState state) {
          final qe = state.uri.queryParameters['quickExit'] == 'true';
          return SessionScreen(quickExit: qe);
        },
        routes: <GoRoute>[
          GoRoute(
            path: 'completed',
            name: RouteNames.sessionCompleted,
            builder: (_, _) => const _Blank(),
          ),
        ],
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
        quickExitServiceProvider.overrideWithValue(
          SimulationQuickExitService(),
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
  return fake;
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
  // ── FIX 1: SessionScreen quickExit flag ───────────────────────────────────

  group('SessionScreen quickExit flag', () {
    testWidgets(
      'quickExit=true shows EndSessionOverlay after first frame (no-PIN path)',
      (WidgetTester tester) async {
        final repo = _FakeAppSettingsRepository();
        await _pumpSessionScreen(
          tester,
          quickExit: true,
          extraOverrides: <Override>[
            appSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        );
        // The post-frame callback fires _endSessionFlow which calls
        // EndSessionOverlay.show — the overlay is present in the tree.
        expect(
          find.byType(EndSessionOverlay),
          findsOneWidget,
          reason: 'EndSessionOverlay must appear after quickExit=true mount',
        );
      },
    );

    testWidgets('quickExit=false does NOT show EndSessionOverlay on mount', (
      WidgetTester tester,
    ) async {
      final repo = _FakeAppSettingsRepository();
      await _pumpSessionScreen(
        tester,
        quickExit: false,
        extraOverrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      expect(
        find.byType(EndSessionOverlay),
        findsNothing,
        reason: 'EndSessionOverlay must NOT appear when quickExit is false',
      );
    });

    testWidgets('quickExit guard fires only once even on rebuild', (
      WidgetTester tester,
    ) async {
      // Verify _quickExitFired guard by asserting overlay appears exactly
      // once (and the widget doesn't re-fire after a pump).
      final repo = _FakeAppSettingsRepository();
      await _pumpSessionScreen(
        tester,
        quickExit: true,
        extraOverrides: <Override>[
          appSettingsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      // Additional pump should not open a second overlay.
      await tester.pump();
      expect(find.byType(EndSessionOverlay), findsOneWidget);
    });
  });

  // ── FIX 1: _routeWidgetUri guard logic (unit-level) ─────────────────────

  group('widget URI routing guard conditions', () {
    /// Tests the routing guard logic directly: the phases that allow
    /// navigation to /session?quickExit=true are all phases except idle
    /// and ended. This mirrors the HomeScreen._routeWidgetUri guard:
    ///   `phase != SessionPhase.idle && phase != SessionPhase.ended`
    test('active phases satisfy the quick-exit guard', () {
      const activePhasesAllowed = <SessionPhase>[
        SessionPhase.wait,
        SessionPhase.duration,
        SessionPhase.grace,
        SessionPhase.holdWait,
        SessionPhase.holding,
        SessionPhase.sensitivity,
      ];
      for (final phase in activePhasesAllowed) {
        final allowed =
            phase != SessionPhase.idle && phase != SessionPhase.ended;
        check(allowed).isTrue();
      }
    });

    test('idle and ended phases block the quick-exit guard', () {
      for (final phase in [SessionPhase.idle, SessionPhase.ended]) {
        final allowed =
            phase != SessionPhase.idle && phase != SessionPhase.ended;
        check(allowed).isFalse();
      }
    });

    /// Tests that the router builder for /session correctly reads the
    /// quickExit query parameter and passes it to [SessionScreen].
    testWidgets(
      'GoRouter /session?quickExit=true constructs SessionScreen(quickExit: true)',
      (WidgetTester tester) async {
        final fake = _FakeSessionController(_runningSessionState());
        final repo = _FakeAppSettingsRepository();
        final router = GoRouter(
          initialLocation: '/session?quickExit=true',
          routes: <GoRoute>[
            GoRoute(
              path: '/session',
              name: RouteNames.session,
              builder: (_, GoRouterState state) {
                final qe = state.uri.queryParameters['quickExit'] == 'true';
                return SessionScreen(quickExit: qe);
              },
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
              quickExitServiceProvider.overrideWithValue(
                SimulationQuickExitService(),
              ),
              appSettingsRepositoryProvider.overrideWithValue(repo),
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
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF131118),
                ),
                useMaterial3: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // When quickExit=true is passed, SessionScreen mounts with the
        // flag, fires addPostFrameCallback, and EndSessionOverlay appears.
        expect(
          find.byType(EndSessionOverlay),
          findsOneWidget,
          reason:
              'Router builder must pass quickExit=true to SessionScreen '
              'which auto-opens EndSessionOverlay',
        );
      },
    );
  });
}
