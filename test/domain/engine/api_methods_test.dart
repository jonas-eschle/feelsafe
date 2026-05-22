// Closes qa-expert findings G2, G4, G5, G6 (Phase 2 verification): direct
// behavioural coverage for the SessionEngine API methods that previously
// had zero dedicated tests:
//   * earlyCheckIn() — disguised-reminder D4 path (G4)
//   * advanceFromHardwarePanic() — production hardware-panic advance (G5)
//   * checkIn() — disarm alias used by disguised-reminder UI (G6)
//   * notifyStepExecutionFailed() — strategy-error isolation emission (G2)
// See spec 01 §Engine API for the contracts.

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/engine/chain_event.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'engine_test_helpers.dart';

void main() {
  group('earlyCheckIn (spec 01 §Early Check-in D4)', () {
    test('disarms during wait phase of a disguised-reminder step '
        '(resetOnEarlyCheckIn=true)', () {
      fakeAsync((async) {
        final events = <ChainEvent>[];
        final m = mode(
          chainSteps: [
            step(
              type: ChainStepType.disguisedReminder,
              waitSeconds: 30,
              durationSeconds: 5,
            ),
            step(type: ChainStepType.callEmergency),
          ],
        );
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.events.listen((e) => events.add(e.event));
        engine.start();
        async.flushMicrotasks();

        // Engine is in wait phase (waitSeconds=30); user taps reminder.
        async.elapse(const Duration(seconds: 5));
        engine.earlyCheckIn();
        async.flushMicrotasks();

        check(events).contains(ChainEvent.userDisarmed);
        check(engine.currentStepIndex).equals(0); // Reset to step 0.

        engine.endSession();
      });
    });

    test('no-op when step is not disguisedReminder', () {
      fakeAsync((async) {
        final events = <ChainEvent>[];
        final m = mode(
          chainSteps: [
            step(
              type: ChainStepType.smsContact,
              waitSeconds: 30,
              durationSeconds: 5,
            ),
            step(type: ChainStepType.callEmergency),
          ],
        );
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.events.listen((e) => events.add(e.event));
        engine.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 5));

        engine.earlyCheckIn();
        async.flushMicrotasks();

        check(events.where((e) => e == ChainEvent.userDisarmed)).isEmpty();
        engine.endSession();
      });
    });

    test('no-op outside the wait phase', () {
      fakeAsync((async) {
        final events = <ChainEvent>[];
        final m = mode(
          chainSteps: [
            step(
              type: ChainStepType.disguisedReminder,
              waitSeconds: 5,
              durationSeconds: 30, // long duration so we land in it
            ),
            step(type: ChainStepType.callEmergency),
          ],
        );
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.events.listen((e) => events.add(e.event));
        engine.start();
        async.flushMicrotasks();

        // Wait elapses → engine is now in duration phase.
        async.elapse(const Duration(seconds: 6));

        engine.earlyCheckIn();
        async.flushMicrotasks();

        // Should not disarm — phase != wait.
        check(events.where((e) => e == ChainEvent.userDisarmed)).isEmpty();

        engine.endSession();
      });
    });

    test('resetOnEarlyCheckIn=false is a deliberate no-op (D4 rationale)', () {
      fakeAsync((async) {
        final events = <ChainEvent>[];
        final m = mode(
          chainSteps: [
            step(
              type: ChainStepType.disguisedReminder,
              waitSeconds: 30,
              durationSeconds: 5,
            ),
            step(type: ChainStepType.callEmergency),
          ],
        );
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.events.listen((e) => events.add(e.event));
        engine.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 5));

        engine.earlyCheckIn(resetOnEarlyCheckIn: false);
        async.flushMicrotasks();

        check(events.where((e) => e == ChainEvent.userDisarmed)).isEmpty();
        check(engine.currentStepIndex).equals(0); // unchanged

        engine.endSession();
      });
    });
  });

  group('checkIn (spec 01 §Disarm / Check-in)', () {
    test('is an alias for disarm() and resets the chain to step 0', () {
      fakeAsync((async) {
        final events = <ChainEvent>[];
        final m = mode(
          chainSteps: [
            step(durationSeconds: 1, gracePeriodSeconds: 0),
            step(type: ChainStepType.callEmergency, durationSeconds: 30),
          ],
        );
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.events.listen((e) => events.add(e.event));
        engine.start();
        async.flushMicrotasks();

        // Advance to step 1.
        async.elapse(const Duration(seconds: 2));
        check(engine.currentStepIndex).equals(1);

        // checkIn should disarm.
        engine.checkIn();
        async.flushMicrotasks();
        check(events).contains(ChainEvent.userDisarmed);
        check(engine.currentStepIndex).equals(0);

        engine.endSession();
      });
    });
  });

  group('advanceFromHardwarePanic (spec 01 §Hardware Panic)', () {
    test('advances by one step', () {
      fakeAsync((async) {
        final m = mode(
          chainSteps: [
            step(durationSeconds: 30, gracePeriodSeconds: 30),
            step(type: ChainStepType.callEmergency, durationSeconds: 30),
            step(durationSeconds: 30),
          ],
        );
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();
        check(engine.currentStepIndex).equals(0);

        engine.advanceFromHardwarePanic();
        async.flushMicrotasks();
        check(engine.currentStepIndex).equals(1);

        engine.advanceFromHardwarePanic();
        async.flushMicrotasks();
        check(engine.currentStepIndex).equals(2);

        engine.endSession();
      });
    });

    test('no-op when engine is not running', () {
      fakeAsync((async) {
        final engine = buildEngine(
          sessionMode: mode(),
          random: const FixedRandom(),
        );
        // Not started yet.
        check(engine.advanceFromHardwarePanic).returnsNormally();
        check(engine.currentStepIndex).equals(-1);
      });
    });

    test('does not emit userDisarmed (escalation, not disarm)', () {
      fakeAsync((async) {
        final events = <ChainEvent>[];
        final m = mode(
          chainSteps: [
            step(durationSeconds: 30, gracePeriodSeconds: 30),
            step(type: ChainStepType.callEmergency, durationSeconds: 30),
          ],
        );
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.events.listen((e) => events.add(e.event));
        engine.start();
        async.flushMicrotasks();

        engine.advanceFromHardwarePanic();
        async.flushMicrotasks();

        check(events.where((e) => e == ChainEvent.userDisarmed)).isEmpty();
        engine.endSession();
      });
    });
  });

  group(
    'notifyStepExecutionFailed (spec 01 §Non-Blocking Event Execution)',
    () {
      test('emits stepExecutionFailed with metadata; chain keeps running', () {
        fakeAsync((async) {
          final events = <ChainEventData>[];
          final m = mode(
            chainSteps: [
              step(durationSeconds: 5),
              step(type: ChainStepType.callEmergency),
            ],
          );
          final engine = buildEngine(
            sessionMode: m,
            random: const FixedRandom(),
          );
          engine.events.listen(events.add);
          engine.start();
          async.flushMicrotasks();

          engine.notifyStepExecutionFailed(0, StateError('SMS gateway 503'));

          final failed = events.where(
            (e) => e.event == ChainEvent.stepExecutionFailed,
          );
          check(failed).isNotEmpty();
          check(failed.first.metadata['stepIndex']).equals(0);
          check(
            failed.first.metadata['error'].toString(),
          ).contains('SMS gateway 503');

          // Chain itself must keep running — no transition to ended.
          check(engine.isEnded).isFalse();

          engine.endSession();
        });
      });

      test('no-op after endSession()', () {
        fakeAsync((async) {
          int count = 0;
          final engine = buildEngine(
            sessionMode: mode(),
            random: const FixedRandom(),
          );
          engine.start();
          async.flushMicrotasks();
          engine.endSession();
          engine.events.listen((_) => count++);
          engine.notifyStepExecutionFailed(0, 'boom');
          async.flushMicrotasks();
          check(count).equals(0);
        });
      });
    },
  );
}
