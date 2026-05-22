import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'engine_test_helpers.dart';

void main() {
  group('jumpToStep() — simulation only', () {
    test('jumpToStep() throws on real session', () {
      fakeAsync((async) {
        final engine = buildEngine(
          sessionMode: mode(),
          random: const FixedRandom(),
        );
        engine.start();
        async.flushMicrotasks();
        check(() => engine.jumpToStep(0)).throws<StateError>();
        engine.endSession();
      });
    });

    test('jumpToStep() throws when not running', () {
      final engine = buildEngine(
        sessionMode: mode(),
        isSimulation: true,
        random: const FixedRandom(),
      );
      check(() => engine.jumpToStep(0)).throws<StateError>();
    });

    test('jumpToStep() throws for out-of-range index', () {
      fakeAsync((async) {
        final engine = buildEngine(
          sessionMode: mode(),
          isSimulation: true,
          random: const FixedRandom(),
        );
        engine.start();
        async.flushMicrotasks();
        check(() => engine.jumpToStep(99)).throws<RangeError>();
        check(() => engine.jumpToStep(-1)).throws<RangeError>();
        engine.endSession();
      });
    });

    test('jumpToStep() jumps directly to target index', () {
      fakeAsync((async) {
        final m = mode(
          chainSteps: [
            step(durationSeconds: 100),
            step(type: ChainStepType.smsContact, durationSeconds: 100),
            step(type: ChainStepType.callEmergency, durationSeconds: 100),
          ],
        );
        final engine = buildEngine(
          sessionMode: m,
          isSimulation: true,
          random: const FixedRandom(),
        );
        engine.start();
        async.flushMicrotasks();
        check(engine.currentStepIndex).equals(0);

        engine.jumpToStep(2);
        async.flushMicrotasks();
        check(engine.currentStepIndex).equals(2);

        engine.endSession();
      });
    });

    test('jumpToStep() resets miss count to 0', () {
      fakeAsync((async) {
        final m = mode(
          chainSteps: [
            step(durationSeconds: 1, gracePeriodSeconds: 1, retryCount: 2),
            step(type: ChainStepType.callEmergency),
          ],
        );
        final engine = buildEngine(
          sessionMode: m,
          isSimulation: true,
          random: const FixedRandom(),
        );
        engine.start();
        async.flushMicrotasks();

        // Trigger a miss.
        async.elapse(const Duration(seconds: 2));
        check(engine.currentStepIndex).equals(0); // Retry.

        // Jump resets miss count.
        engine.jumpToStep(0);
        async.flushMicrotasks();
        check(engine.currentStepIndex).equals(0);

        engine.endSession();
      });
    });

    test('jumpToStep(0) jumps back to first step', () {
      fakeAsync((async) {
        final m = mode(
          chainSteps: [
            step(durationSeconds: 1, gracePeriodSeconds: 0),
            step(type: ChainStepType.smsContact, durationSeconds: 100),
          ],
        );
        final engine = buildEngine(
          sessionMode: m,
          isSimulation: true,
          random: const FixedRandom(),
        );
        engine.start();
        async.flushMicrotasks();

        // Advance to step 1.
        async.elapse(const Duration(seconds: 1));
        check(engine.currentStepIndex).equals(1);

        // Jump back to step 0.
        engine.jumpToStep(0);
        async.flushMicrotasks();
        check(engine.currentStepIndex).equals(0);

        engine.endSession();
      });
    });
  });
}
