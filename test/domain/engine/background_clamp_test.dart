import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'engine_test_helpers.dart';

void main() {
  group('Background clamp (G-013)', () {
    test(
      'setBackgroundClamp(true) engages 60x cap on effectiveSpeedMultiplier',
      () {
        final engine = buildEngine(
          sessionMode: mode(),
          isSimulation: true,
          speedMultiplier: 200.0,
          random: const FixedRandom(),
        );
        check(engine.isBackgroundClamped).isFalse();
        check(engine.effectiveSpeedMultiplier).isCloseTo(200.0, 1e-9);

        engine.setBackgroundClamp(true);
        check(engine.isBackgroundClamped).isTrue();
        check(engine.effectiveSpeedMultiplier).isCloseTo(60.0, 1e-9);
      },
    );

    test('setBackgroundClamp(false) releases the cap', () {
      final engine = buildEngine(
        sessionMode: mode(),
        isSimulation: true,
        speedMultiplier: 200.0,
        random: const FixedRandom(),
      );
      engine.setBackgroundClamp(true);
      check(engine.effectiveSpeedMultiplier).isCloseTo(60.0, 1e-9);

      engine.setBackgroundClamp(false);
      check(engine.isBackgroundClamped).isFalse();
      check(engine.effectiveSpeedMultiplier).isCloseTo(200.0, 1e-9);
    });

    test('speedMultiplier below 60 is unaffected by background clamp', () {
      final engine = buildEngine(
        sessionMode: mode(),
        isSimulation: true,
        speedMultiplier: 30.0,
        random: const FixedRandom(),
      );
      engine.setBackgroundClamp(true);
      // min(30, 60) = 30 — no cap applied.
      check(engine.effectiveSpeedMultiplier).isCloseTo(30.0, 1e-9);
    });

    test('storedSpeedMultiplier is untouched by setBackgroundClamp', () {
      final engine = buildEngine(
        sessionMode: mode(),
        isSimulation: true,
        speedMultiplier: 500.0,
        random: const FixedRandom(),
      );
      engine.setBackgroundClamp(true);
      // Stored multiplier preserved; effective capped.
      check(engine.speedMultiplier).isCloseTo(500.0, 1e-9);
      check(engine.effectiveSpeedMultiplier).isCloseTo(60.0, 1e-9);
    });

    test('real session setBackgroundClamp is no-op (no-throw)', () {
      fakeAsync((async) {
        final engine = buildEngine(
          sessionMode: mode(),
          random: const FixedRandom(),
        );
        engine.start();
        async.flushMicrotasks();
        check(() => engine.setBackgroundClamp(true)).returnsNormally();
        check(() => engine.setBackgroundClamp(false)).returnsNormally();
        engine.endSession();
      });
    });

    test('background clamp caps effective to 60x in timing', () {
      fakeAsync((async) {
        // duration = 60s, speedMultiplier = 200x.
        // Without clamp: fires at 0.3s.
        // With clamp (60x): fires at 1s.
        final m = mode(
          chainSteps: [
            step(durationSeconds: 60, gracePeriodSeconds: 0),
            step(type: ChainStepType.callEmergency),
          ],
        );
        final engine = buildEngine(
          sessionMode: m,
          isSimulation: true,
          speedMultiplier: 200.0,
          random: const FixedRandom(),
        );
        engine.setBackgroundClamp(true); // Cap to 60x.
        engine.start();
        async.flushMicrotasks();

        // At 0.5s: still step 0 (would have fired at 0.3s without clamp,
        // but with clamp fires at 1s).
        async.elapse(const Duration(milliseconds: 500));
        check(engine.currentStepIndex).equals(0);

        // At 1s: fires.
        async.elapse(const Duration(milliseconds: 500));
        check(engine.currentStepIndex).equals(1);

        engine.endSession();
      });
    });
  });
}
