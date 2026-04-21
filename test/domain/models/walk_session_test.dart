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

    test('fromJson unknown currentStepType throws', () {
      check(
        () => WalkSession.fromJson({
          'id': 'x',
          'modeId': 'm',
          'isSimulation': false,
          'startedAt': startedAt.toIso8601String(),
          'phase': 'active',
          'currentStepType': 'bogus',
        }),
      ).throws<ArgumentError>();
    });

    test('every ChainStepType round-trips on currentStepType', () {
      for (final st in ChainStepType.values) {
        final s = WalkSession(
          id: 'w1',
          modeId: 'm1',
          isSimulation: false,
          startedAt: startedAt,
          phase: const SessionPhaseActive(),
          currentStepType: st,
        );
        check(WalkSession.fromJson(s.toJson())).equals(s);
      }
    });

    test('copyWith replaces every field', () {
      final s = WalkSession(
        id: 'w1',
        modeId: 'm1',
        isSimulation: false,
        startedAt: startedAt,
        phase: const SessionPhaseIdle(),
      );
      final later = startedAt.add(const Duration(hours: 1));
      final s2 = s.copyWith(
        id: 'w2',
        modeId: 'm2',
        isSimulation: true,
        startedAt: later,
        simulationSpeed: 3.0,
        phase: const SessionPhaseActive(),
        currentStepIndex: 4,
        currentStepType: ChainStepType.fakeCall,
        missCount: 2,
        remainingSeconds: 9,
        simulatedElapsed: const Duration(seconds: 5),
        firedStepDescriptions: const ['a'],
        lastSimulationDescription: 'desc',
        isBackgroundAlert: true,
      );
      check(s2.id).equals('w2');
      check(s2.modeId).equals('m2');
      check(s2.isSimulation).isTrue();
      check(s2.startedAt).equals(later);
      check(s2.simulationSpeed).equals(3.0);
      check(s2.phase).equals(const SessionPhaseActive());
      check(s2.currentStepIndex).equals(4);
      check(s2.currentStepType).equals(ChainStepType.fakeCall);
      check(s2.missCount).equals(2);
      check(s2.remainingSeconds).equals(9);
      check(s2.simulatedElapsed).equals(const Duration(seconds: 5));
      check(s2.firedStepDescriptions).deepEquals(const ['a']);
      check(s2.lastSimulationDescription).equals('desc');
      check(s2.isBackgroundAlert).isTrue();
    });
  });

  group('SessionPhase toString / hashCode', () {
    test('idle toString', () {
      check(const SessionPhaseIdle().toString()).equals('SessionPhase.idle');
    });

    test('active toString', () {
      check(const SessionPhaseActive().toString())
          .equals('SessionPhase.active');
    });

    test('paused toString', () {
      check(const SessionPhasePaused().toString())
          .equals('SessionPhase.paused');
    });

    test('ended toString', () {
      check(const SessionPhaseEnded().toString()).equals('SessionPhase.ended');
    });

    test('hashCode stable for same phase', () {
      check(const SessionPhaseIdle().hashCode)
          .equals(const SessionPhaseIdle().hashCode);
      check(const SessionPhaseActive().hashCode)
          .equals(const SessionPhaseActive().hashCode);
      check(const SessionPhasePaused().hashCode)
          .equals(const SessionPhasePaused().hashCode);
      check(const SessionPhaseEnded().hashCode)
          .equals(const SessionPhaseEnded().hashCode);
    });

    test('cross-type inequality', () {
      // ignore: unrelated_type_equality_checks
      check(const SessionPhaseIdle() == 'idle').isFalse();
      check(const SessionPhaseActive() == const SessionPhasePaused()).isFalse();
      check(const SessionPhasePaused() == const SessionPhaseEnded()).isFalse();
    });
  });

  group('WalkSession equality', () {
    final startedAt = DateTime.utc(2026, 4, 1);

    WalkSession base() => WalkSession(
          id: 'w1',
          modeId: 'm1',
          isSimulation: false,
          startedAt: startedAt,
          phase: const SessionPhaseActive(),
        );

    test('identical equals', () {
      final s = base();
      check(s == s).isTrue();
    });

    test('cross type unequal', () {
      // ignore: unrelated_type_equality_checks
      check(base() == 'x').isFalse();
    });

    test('different id unequal', () {
      check(base() == base().copyWith(id: 'w2')).isFalse();
    });

    test('different modeId unequal', () {
      check(base() == base().copyWith(modeId: 'm2')).isFalse();
    });

    test('different isSimulation unequal', () {
      check(base() == base().copyWith(isSimulation: true)).isFalse();
    });

    test('different startedAt unequal', () {
      check(
        base() == base().copyWith(startedAt: startedAt.add(
          const Duration(seconds: 1),
        )),
      ).isFalse();
    });

    test('different simulationSpeed unequal', () {
      check(base() == base().copyWith(simulationSpeed: 2.0)).isFalse();
    });

    test('different phase unequal', () {
      check(base() == base().copyWith(phase: const SessionPhaseIdle()))
          .isFalse();
    });

    test('different currentStepIndex unequal', () {
      check(base() == base().copyWith(currentStepIndex: 1)).isFalse();
    });

    test('different currentStepType unequal', () {
      check(
        base() == base().copyWith(currentStepType: ChainStepType.smsContact),
      ).isFalse();
    });

    test('different missCount unequal', () {
      check(base() == base().copyWith(missCount: 1)).isFalse();
    });

    test('different remainingSeconds unequal', () {
      check(base() == base().copyWith(remainingSeconds: 5)).isFalse();
    });

    test('different simulatedElapsed unequal', () {
      check(
        base() == base().copyWith(
          simulatedElapsed: const Duration(seconds: 1),
        ),
      ).isFalse();
    });

    test('different lastSimulationDescription unequal', () {
      check(
        base() == base().copyWith(lastSimulationDescription: 'x'),
      ).isFalse();
    });

    test('different isBackgroundAlert unequal', () {
      check(base() == base().copyWith(isBackgroundAlert: true)).isFalse();
    });

    test('different firedStepDescriptions length unequal', () {
      check(
        base() == base().copyWith(firedStepDescriptions: const ['x']),
      ).isFalse();
    });

    test('different firedStepDescriptions at index unequal', () {
      final a = base().copyWith(firedStepDescriptions: const ['a']);
      final b = base().copyWith(firedStepDescriptions: const ['b']);
      check(a == b).isFalse();
    });

    test('hashCode stable', () {
      check(base().hashCode).equals(base().hashCode);
    });

    test('toString exposes id/modeId/phase/step', () {
      final str = base().toString();
      check(str).contains('w1');
      check(str).contains('m1');
    });
  });
}
