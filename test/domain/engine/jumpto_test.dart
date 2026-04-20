/// [SessionEngine.jumpToStep] tests — simulation-only, bounds-checked.
library;

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import '../../helpers/test_helpers.dart';

SessionEngine _sim() => SessionEngine(
  chainSteps: [
    smsStep(order: 0, durationSeconds: 10, gracePeriodSeconds: 5),
    smsStep(order: 1, durationSeconds: 10, gracePeriodSeconds: 5),
    smsStep(order: 2, durationSeconds: 10, gracePeriodSeconds: 5),
  ],
  isSimulation: true,
  random: FixedRandom(),
);

SessionEngine _real() => SessionEngine(
  chainSteps: [
    smsStep(order: 0, durationSeconds: 10, gracePeriodSeconds: 5),
    smsStep(order: 1, durationSeconds: 10, gracePeriodSeconds: 5),
  ],
  random: FixedRandom(),
);

void main() {
  group('jumpToStep simulation guard', () {
    test('real session rejects jumpToStep', () {
      fakeAsync((async) {
        final e = _real();
        e.start();
        async.flushMicrotasks();
        check(() => e.jumpToStep(1)).throws<StateError>();
        e.dispose();
      });
    });

    test('simulation allows jumpToStep', () {
      fakeAsync((async) {
        final e = _sim();
        e.start();
        async.flushMicrotasks();
        e.jumpToStep(1);
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.stepIndex).equals(1);
        e.dispose();
      });
    });
  });

  group('jumpToStep bounds', () {
    test('negative index throws RangeError', () {
      fakeAsync((async) {
        final e = _sim();
        e.start();
        async.flushMicrotasks();
        check(() => e.jumpToStep(-1)).throws<RangeError>();
        e.dispose();
      });
    });

    test('index == length throws RangeError', () {
      fakeAsync((async) {
        final e = _sim();
        e.start();
        async.flushMicrotasks();
        check(() => e.jumpToStep(3)).throws<RangeError>();
        e.dispose();
      });
    });

    test('index > length throws RangeError', () {
      fakeAsync((async) {
        final e = _sim();
        e.start();
        async.flushMicrotasks();
        check(() => e.jumpToStep(100)).throws<RangeError>();
        e.dispose();
      });
    });
  });

  group('jumpToStep state requirements', () {
    test('throws from Idle', () {
      final e = _sim();
      check(() => e.jumpToStep(0)).throws<StateError>();
      e.dispose();
    });

    test('throws from Paused', () {
      fakeAsync((async) {
        final e = _sim();
        e.start();
        async.flushMicrotasks();
        e.pause();
        check(() => e.jumpToStep(1)).throws<StateError>();
        e.dispose();
      });
    });

    test('throws from Ended', () {
      final e = _sim();
      e.endSession(reason: EndReason.userQuit);
      check(() => e.jumpToStep(0)).throws<StateError>();
      e.dispose();
    });
  });

  group('jumpToStep re-enters target step', () {
    test('jumping mid-phase resets miss count', () {
      fakeAsync((async) {
        final e = _sim();
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 20));
        async.flushMicrotasks();
        // By now step 0 has been advancing; jump to step 2.
        e.jumpToStep(2);
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.stepIndex).equals(2);
        check(s.missCount).equals(0);
        e.dispose();
      });
    });
  });
}
