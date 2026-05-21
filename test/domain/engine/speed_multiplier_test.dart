import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';

import 'engine_test_helpers.dart';

void main() {
  group('Speed multiplier', () {
    test('default speedMultiplier is 1.0', () {
      final engine = SessionEngine(mode(), random: const FixedRandom());
      check(engine.speedMultiplier).isCloseTo(1.0, 1e-9);
    });

    test('real session rejects speedMultiplier != 1.0', () {
      check(
        () => SessionEngine(
          mode(),
          speedMultiplier: 2.0,
          random: const FixedRandom(),
        ),
      ).throws<ArgumentError>();
    });

    test('simulation allows speedMultiplier 10.0', () {
      final engine = SessionEngine(
        mode(),
        isSimulation: true,
        speedMultiplier: 10.0,
        random: const FixedRandom(),
      );
      check(engine.speedMultiplier).isCloseTo(10.0, 1e-9);
    });

    test('speedMultiplier NaN throws ArgumentError', () {
      check(
        () => SessionEngine(
          mode(),
          isSimulation: true,
          speedMultiplier: double.nan,
          random: const FixedRandom(),
        ),
      ).throws<ArgumentError>();
    });

    test('speedMultiplier infinity throws ArgumentError', () {
      check(
        () => SessionEngine(
          mode(),
          isSimulation: true,
          speedMultiplier: double.infinity,
          random: const FixedRandom(),
        ),
      ).throws<ArgumentError>();
    });

    test('speedMultiplier negative throws ArgumentError', () {
      check(
        () => SessionEngine(
          mode(),
          isSimulation: true,
          speedMultiplier: -1.0,
          random: const FixedRandom(),
        ),
      ).throws<ArgumentError>();
    });

    test('speedMultiplier zero throws ArgumentError', () {
      check(
        () => SessionEngine(
          mode(),
          isSimulation: true,
          speedMultiplier: 0.0,
          random: const FixedRandom(),
        ),
      ).throws<ArgumentError>();
    });

    test('speedMultiplier below 0.01 throws ArgumentError', () {
      check(
        () => SessionEngine(
          mode(),
          isSimulation: true,
          speedMultiplier: 0.001,
          random: const FixedRandom(),
        ),
      ).throws<ArgumentError>();
    });

    test('speedMultiplier above 1000.0 throws ArgumentError', () {
      check(
        () => SessionEngine(
          mode(),
          isSimulation: true,
          speedMultiplier: 1001.0,
          random: const FixedRandom(),
        ),
      ).throws<ArgumentError>();
    });

    test('speedMultiplier at boundary 0.01 is valid', () {
      check(
        () => SessionEngine(
          mode(),
          isSimulation: true,
          speedMultiplier: 0.01,
          random: const FixedRandom(),
        ),
      ).returnsNormally();
    });

    test('speedMultiplier at boundary 1000.0 is valid', () {
      check(
        () => SessionEngine(
          mode(),
          isSimulation: true,
          speedMultiplier: 1000.0,
          random: const FixedRandom(),
        ),
      ).returnsNormally();
    });

    test('10x speedMultiplier halves elapsed time proportionally', () {
      fakeAsync((async) {
        // duration = 10s → with 10x multiplier → fires after 1s.
        final m = mode(
          chainSteps: [
            step(gracePeriodSeconds: 0),
            step(type: ChainStepType.callEmergency),
          ],
        );
        final engine = SessionEngine(
          m,
          isSimulation: true,
          speedMultiplier: 10.0,
          random: const FixedRandom(),
        );
        engine.start();
        async.flushMicrotasks();

        // At 0.9s: still step 0.
        async.elapse(const Duration(milliseconds: 900));
        check(engine.currentStepIndex).equals(0);

        // At 1.0s: step 1.
        async.elapse(const Duration(milliseconds: 100));
        check(engine.currentStepIndex).equals(1);

        engine.endSession();
      });
    });

    test('setSpeedMultiplier() throws on real session', () {
      fakeAsync((async) {
        final engine = SessionEngine(mode(), random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();
        check(() => engine.setSpeedMultiplier(2.0)).throws<StateError>();
        engine.endSession();
      });
    });

    test('setSpeedMultiplier() changes multiplier mid-session', () {
      fakeAsync((async) {
        final engine = SessionEngine(
          mode(),
          isSimulation: true,
          random: const FixedRandom(),
        );
        engine.start();
        async.flushMicrotasks();
        engine.setSpeedMultiplier(100.0);
        check(engine.speedMultiplier).isCloseTo(100.0, 1e-9);
        engine.endSession();
      });
    });

    test(
      'effectiveSpeedMultiplier equals speedMultiplier when not clamped',
      () {
        final engine = SessionEngine(
          mode(),
          isSimulation: true,
          speedMultiplier: 200.0,
          random: const FixedRandom(),
        );
        check(engine.effectiveSpeedMultiplier).isCloseTo(200.0, 1e-9);
      },
    );
  });
}
