/// [SessionEngine.leap] tests — simulation-only fast-forward.
library;

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/engine/timer_phase.dart';
import '../../helpers/test_helpers.dart';

SessionEngine _sim() => SessionEngine(
  chainSteps: [
    smsStep(durationSeconds: 30, gracePeriodSeconds: 10)
        .copyWith(waitSeconds: 60),
    smsStep(order: 1, durationSeconds: 1, gracePeriodSeconds: 0),
  ],
  isSimulation: true,
  random: FixedRandom(),
);

SessionEngine _real() => SessionEngine(
  chainSteps: [smsStep(durationSeconds: 30)],
  random: FixedRandom(),
);

void main() {
  group('leap simulation guard', () {
    test('real session rejects leap', () {
      final e = _real();
      check(e.leap).throws<StateError>();
      e.dispose();
    });

    test('simulation allows leap', () {
      fakeAsync((async) {
        final e = _sim();
        e.start();
        async.flushMicrotasks();
        e.leap();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.duration);
        e.dispose();
      });
    });
  });

  group('leap advances to next phase', () {
    test('leap from wait enters duration', () {
      fakeAsync((async) {
        final e = _sim();
        e.start();
        async.flushMicrotasks();
        check((e.state as EngineRunning).phase).equals(TimerPhase.wait);
        e.leap();
        async.flushMicrotasks();
        check((e.state as EngineRunning).phase).equals(TimerPhase.duration);
        e.dispose();
      });
    });

    test('leap from duration enters grace', () {
      fakeAsync((async) {
        final e = _sim();
        e.start();
        async.flushMicrotasks();
        e.leap(); // wait → duration.
        async.flushMicrotasks();
        e.leap(); // duration → grace.
        async.flushMicrotasks();
        check((e.state as EngineRunning).phase).equals(TimerPhase.grace);
        e.dispose();
      });
    });

    test('leap from grace advances to next step', () {
      fakeAsync((async) {
        final e = _sim();
        e.start();
        async.flushMicrotasks();
        e.leap(); // wait → duration.
        async.flushMicrotasks();
        e.leap(); // duration → grace.
        async.flushMicrotasks();
        e.leap(); // grace → next step.
        async.flushMicrotasks();
        final s = e.state;
        if (s is EngineRunning) {
          check(s.stepIndex).equals(1);
        } else {
          check(s).isA<EngineEnded>();
        }
        e.dispose();
      });
    });
  });

  group('leap no-op from non-Running states', () {
    test('leap from Idle is a no-op', () {
      final e = _sim();
      e.leap();
      check(e.state).isA<EngineIdle>();
      e.dispose();
    });

    test('leap from Paused is a no-op', () {
      fakeAsync((async) {
        final e = _sim();
        e.start();
        async.flushMicrotasks();
        e.pause();
        e.leap();
        check(e.state).isA<EnginePaused>();
        e.dispose();
      });
    });

    test('leap from Ended is a no-op', () {
      final e = _sim();
      e.endSession(reason: EndReason.userQuit);
      e.leap();
      check(e.state).isA<EngineEnded>();
      e.dispose();
    });
  });
}
