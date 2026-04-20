/// Tests for the sealed [EngineState] hierarchy — constructors,
/// copyWith, and exhaustive pattern matching.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/timer_phase.dart';

String _describe(EngineState s) => switch (s) {
  EngineIdle() => 'idle',
  EngineRunning(:final stepIndex) => 'running:$stepIndex',
  EnginePaused(:final reason) => 'paused:${reason.name}',
  EngineEnded(:final reason) => 'ended:${reason.name}',
};

void main() {
  group('EngineIdle', () {
    test('is a const EngineState', () {
      const s = EngineIdle();
      check(s).isA<EngineState>();
    });

    test('exhaustive match returns idle label', () {
      check(_describe(const EngineIdle())).equals('idle');
    });
  });

  group('EngineRunning', () {
    test('stores every field', () {
      final s = EngineRunning(
        stepIndex: 3,
        phase: TimerPhase.grace,
        remaining: const Duration(seconds: 7),
        missCount: 2,
        isHolding: true,
      );
      check(s.stepIndex).equals(3);
      check(s.phase).equals(TimerPhase.grace);
      check(s.remaining).equals(const Duration(seconds: 7));
      check(s.missCount).equals(2);
      check(s.isHolding).isTrue();
    });

    test('copyWith replaces targeted fields', () {
      final s = EngineRunning(
        stepIndex: 0,
        phase: TimerPhase.wait,
        remaining: const Duration(seconds: 1),
        missCount: 0,
        isHolding: false,
      );
      final s2 = s.copyWith(missCount: 3, isHolding: true);
      check(s2.missCount).equals(3);
      check(s2.isHolding).isTrue();
      check(s2.phase).equals(TimerPhase.wait);
    });

    test('exhaustive match returns running label', () {
      check(
        _describe(
          EngineRunning(
            stepIndex: 1,
            phase: TimerPhase.duration,
            remaining: Duration.zero,
            missCount: 0,
            isHolding: false,
          ),
        ),
      ).equals('running:1');
    });
  });

  group('EnginePaused', () {
    test('snapshot is an EngineRunning', () {
      final snap = EngineRunning(
        stepIndex: 2,
        phase: TimerPhase.grace,
        remaining: const Duration(seconds: 3),
        missCount: 1,
        isHolding: false,
      );
      final p = EnginePaused(snapshot: snap, reason: PauseReason.userRequested);
      check(p.snapshot).equals(snap);
      check(p.reason).equals(PauseReason.userRequested);
    });

    test('exhaustive match returns paused label', () {
      final snap = EngineRunning(
        stepIndex: 0,
        phase: TimerPhase.grace,
        remaining: Duration.zero,
        missCount: 0,
        isHolding: false,
      );
      check(
        _describe(
          EnginePaused(snapshot: snap, reason: PauseReason.incomingCall),
        ),
      ).equals('paused:incomingCall');
    });

    test('all pause reasons', () {
      for (final r in PauseReason.values) {
        final snap = EngineRunning(
          stepIndex: 0,
          phase: TimerPhase.wait,
          remaining: Duration.zero,
          missCount: 0,
          isHolding: false,
        );
        check(EnginePaused(snapshot: snap, reason: r).reason).equals(r);
      }
    });
  });

  group('EngineEnded', () {
    test('carries reason', () {
      final s = EngineEnded(reason: EndReason.disarm);
      check(s.reason).equals(EndReason.disarm);
    });

    test('all EndReason values construct ended state', () {
      for (final r in EndReason.values) {
        check(EngineEnded(reason: r).reason).equals(r);
      }
    });

    test('exhaustive match returns ended label', () {
      check(
        _describe(const EngineEnded(reason: EndReason.chainExhausted)),
      ).equals('ended:chainExhausted');
    });
  });

  group('exhaustive switch', () {
    test('covers every sealed subtype', () {
      final labels = <String>[
        _describe(const EngineIdle()),
        _describe(
          EngineRunning(
            stepIndex: 0,
            phase: TimerPhase.wait,
            remaining: Duration.zero,
            missCount: 0,
            isHolding: false,
          ),
        ),
        _describe(
          EnginePaused(
            snapshot: EngineRunning(
              stepIndex: 0,
              phase: TimerPhase.wait,
              remaining: Duration.zero,
              missCount: 0,
              isHolding: false,
            ),
            reason: PauseReason.userRequested,
          ),
        ),
        _describe(const EngineEnded(reason: EndReason.userQuit)),
      ];
      check(labels).deepEquals([
        'idle',
        'running:0',
        'paused:userRequested',
        'ended:userQuit',
      ]);
    });
  });

  group('TimerPhase enum', () {
    test('all five phases', () {
      check(TimerPhase.values.map((p) => p.name).toList()).unorderedEquals([
        'wait',
        'duration',
        'grace',
        'sensitivity',
        'holdWait',
      ]);
    });
  });

  group('PauseReason enum', () {
    test('all four reasons', () {
      check(PauseReason.values.map((r) => r.name).toList()).unorderedEquals([
        'userRequested',
        'incomingCall',
        'fakeCallAnswered',
        'bootRestart',
      ]);
    });
  });

  group('EndReason enum', () {
    test('contains disarm + chainExhausted + distress variants', () {
      final names = EndReason.values.map((r) => r.name).toList();
      check(names).contains('disarm');
      check(names).contains('chainExhausted');
      check(names).contains('hardwarePanic');
      check(names).contains('duressPin');
      check(names).contains('wrongPinExhausted');
      check(names).contains('userQuit');
      check(names).contains('appTermination');
    });
  });
}
