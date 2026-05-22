import 'dart:math';

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/engine/chain_event.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'engine_test_helpers.dart';

void main() {
  group('Jitter bounds', () {
    test('FixedRandom(0.5) produces factor 1.0 — no jitter', () {
      // factor = 0.8 + 0.5 * 0.4 = 1.0
      const r = FixedRandom();
      final factor = 0.8 + r.nextDouble() * 0.4;
      check(factor).isCloseTo(1.0, 1e-9);
    });

    test('FixedRandom(0.0) produces minimum factor 0.8', () {
      const r = FixedRandom(0.0);
      final factor = 0.8 + r.nextDouble() * 0.4;
      check(factor).isCloseTo(0.8, 1e-9);
    });

    test('FixedRandom(1.0) produces maximum factor 1.2', () {
      const r = FixedRandom(1.0);
      final factor = 0.8 + r.nextDouble() * 0.4;
      check(factor).isCloseTo(1.2, 1e-9);
    });

    test('randomize=false: timing is exact with FixedRandom(0.5)', () {
      fakeAsync((async) {
        final m = mode(
          chainSteps: [
            step(),
            step(type: ChainStepType.callEmergency),
          ],
        );
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();

        // At exactly 14s (duration=10 + grace=5 - 1): still step 0.
        async.elapse(const Duration(seconds: 14));
        check(engine.currentStepIndex).equals(0);

        // At 15s: grace expired → step 1.
        async.elapse(const Duration(seconds: 1));
        check(engine.currentStepIndex).equals(1);

        engine.endSession();
      });
    });

    test('randomize=true with FixedRandom(0.5): factor=1.0, same timing', () {
      fakeAsync((async) {
        // FixedRandom(0.5) → factor = 1.0, so randomized == original.
        final m = mode(
          chainSteps: [
            step(randomize: true),
            step(type: ChainStepType.callEmergency),
          ],
        );
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 15));
        check(engine.currentStepIndex).equals(1);

        engine.endSession();
      });
    });

    test(
      'randomize=true with FixedRandom(0.0): timing shrinks by factor 0.8',
      () {
        fakeAsync((async) {
          // duration = 10s * 0.8 = 8s; grace = 5s * 0.8 = 4s; total = 12s.
          final m = mode(
            chainSteps: [
              step(randomize: true),
              step(type: ChainStepType.callEmergency),
            ],
          );
          final engine = buildEngine(
            sessionMode: m,
            random: const FixedRandom(0.0),
          );
          engine.start();
          async.flushMicrotasks();

          // At 11s: should already have advanced (10*0.8 + 5*0.8 = 12s total,
          // but testing just before boundary).
          async.elapse(const Duration(seconds: 12));
          check(engine.currentStepIndex).equals(1);

          engine.endSession();
        });
      },
    );

    test(
      'randomize=true with FixedRandom(1.0): timing expands by factor 1.2',
      () {
        fakeAsync((async) {
          // duration = 10s * 1.2 = 12s; grace = 5s * 1.2 = 6s; total = 18s.
          final m = mode(
            chainSteps: [
              step(randomize: true),
              step(type: ChainStepType.callEmergency),
            ],
          );
          final engine = buildEngine(
            sessionMode: m,
            random: const FixedRandom(1.0),
          );
          engine.start();
          async.flushMicrotasks();

          // At 17s: not yet advanced (12 + 6 = 18s needed).
          async.elapse(const Duration(seconds: 17));
          check(engine.currentStepIndex).equals(0);

          async.elapse(const Duration(seconds: 1));
          check(engine.currentStepIndex).equals(1);

          engine.endSession();
        });
      },
    );

    test('jitter factor bounds are strictly [0.8, 1.2]', () {
      // Verify the formula produces values in the expected range.
      final random = Random();
      for (var i = 0; i < 1000; i++) {
        final factor = 0.8 + random.nextDouble() * 0.4;
        check(factor).isGreaterOrEqual(0.8);
        check(factor).isLessOrEqual(1.2);
      }
    });

    test('randomize=false with FixedRandom(0.0): no jitter applied', () {
      fakeAsync((async) {
        // Even with FixedRandom(0.0), if randomize=false, factor is 1.0.
        final m = mode(
          chainSteps: [
            step(),
            step(type: ChainStepType.callEmergency),
          ],
        );
        final engine = buildEngine(
          sessionMode: m,
          random: const FixedRandom(0.0),
        );
        engine.start();
        async.flushMicrotasks();

        // Original timing (no jitter): duration=10 + grace=5 = 15s.
        async.elapse(const Duration(seconds: 15));
        check(engine.currentStepIndex).equals(1);

        engine.endSession();
      });
    });

    test('wait seconds also jittered when randomize=true', () {
      fakeAsync((async) {
        final events = <ChainEvent>[];
        // With FixedRandom(0.0): wait = 10 * 0.8 = 8s (fires at 8s).
        // Use disguisedReminder so the wait→duration transition emits
        // ChainEvent.reminderFired (spec 01 §Events Emitted).
        final m = mode(
          chainSteps: [
            step(
              type: ChainStepType.disguisedReminder,
              waitSeconds: 10,
              durationSeconds: 1,
              gracePeriodSeconds: 0,
              randomize: true,
            ),
          ],
        );
        final engine = buildEngine(
          sessionMode: m,
          random: const FixedRandom(0.0),
        );
        engine.events.listen((e) => events.add(e.event));
        engine.start();
        async.flushMicrotasks();

        // At 7s: reminderFired not yet (wait = 8s with factor 0.8).
        async.elapse(const Duration(seconds: 7));
        check(events.where((e) => e == ChainEvent.reminderFired)).isEmpty();

        // At 8s: reminderFired.
        async.elapse(const Duration(seconds: 1));
        check(events.where((e) => e == ChainEvent.reminderFired)).isNotEmpty();

        engine.endSession();
      });
    });
  });
}
