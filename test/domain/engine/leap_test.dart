import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';

import 'engine_test_helpers.dart';

void main() {
  group('leap() — simulation only', () {
    test('leap() throws on real session', () {
      fakeAsync((async) {
        final engine = SessionEngine(mode(), random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();
        check(engine.leap).throws<StateError>();
        engine.endSession();
      });
    });

    test('leap() collapses current timer to zero', () {
      fakeAsync((async) {
        final m = mode(
          chainSteps: [
            step(
              durationSeconds: 1000, // Very long.
              gracePeriodSeconds: 0,
            ),
            step(type: ChainStepType.callEmergency),
          ],
        );
        final engine = SessionEngine(
          m,
          isSimulation: true,
          random: const FixedRandom(),
        );
        engine.start();
        async.flushMicrotasks();
        check(engine.currentStepIndex).equals(0);

        // Without leap: need 1000s to advance.
        engine.leap(); // Collapses duration timer.
        // Timer(Duration.zero) callbacks are not flushed by flushMicrotasks —
        // use elapse(Duration.zero) to drain zero-delay timers too.
        async.elapse(Duration.zero);

        // After duration, grace (0s) expires, step advances.
        check(engine.currentStepIndex).equals(1);

        engine.endSession();
      });
    });

    test('leap() is no-op when not running', () {
      final engine = SessionEngine(
        mode(),
        isSimulation: true,
        random: const FixedRandom(),
      );
      // Idle state — should not throw.
      check(engine.leap).returnsNormally();
    });

    test('leap() is no-op when paused', () {
      fakeAsync((async) {
        final engine = SessionEngine(
          mode(),
          isSimulation: true,
          random: const FixedRandom(),
        );
        engine.start();
        async.flushMicrotasks();
        engine.pause();
        // Paused — leap is no-op (not EngineRunning).
        check(engine.leap).returnsNormally();
        check(engine.isPaused).isTrue(); // Still paused.
        engine.endSession();
      });
    });

    test('leap() during grace advances step', () {
      fakeAsync((async) {
        final m = mode(
          chainSteps: [
            step(
              durationSeconds: 1,
              gracePeriodSeconds: 1000, // Very long grace.
            ),
            step(type: ChainStepType.callEmergency),
          ],
        );
        final engine = SessionEngine(
          m,
          isSimulation: true,
          random: const FixedRandom(),
        );
        engine.start();
        async.flushMicrotasks();

        // Elapse duration to enter grace.
        async.elapse(const Duration(seconds: 1));

        // Leap during grace.
        engine.leap();
        async.flushMicrotasks();
        check(engine.currentStepIndex).equals(1);

        engine.endSession();
      });
    });
  });
}
