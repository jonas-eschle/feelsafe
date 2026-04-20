/// Unit tests for `WalkSession` — SessionPhase hierarchy, phaseFromEngine
/// mapping, round-trip.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/timer_phase.dart';
import 'package:guardianangela/domain/models/models.dart';

void main() {
  group('SessionPhase', () {
    test('idle tag', () {
      check(const SessionPhaseIdle().tag).equals('idle');
    });

    test('active tag', () {
      check(const SessionPhaseActive().tag).equals('active');
    });

    test('paused tag', () {
      check(const SessionPhasePaused().tag).equals('paused');
    });

    test('ended tag', () {
      check(const SessionPhaseEnded().tag).equals('ended');
    });

    test('equality by type', () {
      check(const SessionPhaseIdle()).equals(const SessionPhaseIdle());
      check(const SessionPhaseActive()).equals(const SessionPhaseActive());
    });

    test('inequality across phases', () {
      check(const SessionPhaseIdle() == const SessionPhaseActive()).isFalse();
    });
  });

  group('WalkSession.phaseFromEngine', () {
    test('idle engine maps to idle phase', () {
      check(
        WalkSession.phaseFromEngine(const EngineIdle()),
      ).equals(const SessionPhaseIdle());
    });

    test('running engine maps to active phase', () {
      const state = EngineRunning(
        stepIndex: 0,
        phase: TimerPhase.duration,
        remaining: Duration(seconds: 10),
        missCount: 0,
        isHolding: false,
      );
      check(
        WalkSession.phaseFromEngine(state),
      ).equals(const SessionPhaseActive());
    });

    test('paused engine maps to paused phase', () {
      const state = EnginePaused(
        snapshot: EngineRunning(
          stepIndex: 0,
          phase: TimerPhase.duration,
          remaining: Duration(seconds: 10),
          missCount: 0,
          isHolding: false,
        ),
        reason: PauseReason.userRequested,
      );
      check(
        WalkSession.phaseFromEngine(state),
      ).equals(const SessionPhasePaused());
    });

    test('ended engine maps to ended phase', () {
      const state = EngineEnded(reason: EndReason.disarm);
      check(
        WalkSession.phaseFromEngine(state),
      ).equals(const SessionPhaseEnded());
    });
  });

  group('WalkSession', () {
    final startedAt = DateTime.utc(2026, 4, 1);

    test('minimal round-trip', () {
      final s = WalkSession(
        id: 'w1',
        modeId: 'm1',
        isSimulation: false,
        startedAt: startedAt,
        phase: const SessionPhaseActive(),
      );
      check(WalkSession.fromJson(s.toJson())).equals(s);
    });

    test('full round-trip', () {
      final s = WalkSession(
        id: 'w1',
        modeId: 'm1',
        isSimulation: true,
        startedAt: startedAt,
        phase: const SessionPhasePaused(),
        simulationSpeed: 4.0,
        currentStepIndex: 2,
        currentStepType: ChainStepType.smsContact,
        missCount: 1,
        remainingSeconds: 12,
        simulatedElapsed: const Duration(seconds: 30),
        firedStepDescriptions: const ['one', 'two'],
        lastSimulationDescription: 'sms sent',
        isBackgroundAlert: true,
      );
      check(WalkSession.fromJson(s.toJson())).equals(s);
    });

    test('copyWith replaces phase', () {
      final s = WalkSession(
        id: 'w1',
        modeId: 'm1',
        isSimulation: false,
        startedAt: startedAt,
        phase: const SessionPhaseIdle(),
      );
      check(
        s.copyWith(phase: const SessionPhaseActive()).phase,
      ).equals(const SessionPhaseActive());
    });

    test('fromJson unknown phase throws', () {
      check(
        () => WalkSession.fromJson({
          'id': 'x',
          'modeId': 'm',
          'isSimulation': false,
          'startedAt': startedAt.toIso8601String(),
          'phase': 'bogus',
        }),
      ).throws<ArgumentError>();
    });
  });
}
