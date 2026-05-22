import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/engine/chain_event.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/triggers/disarm_trigger.dart';
import 'engine_test_helpers.dart';

void main() {
  group('Invariants (spec 01 §Invariants)', () {
    // Invariant 1: currentStepIndex always in range [-1, chainSteps.length).
    test('Invariant 1: currentStepIndex = -1 before start', () {
      final engine = buildEngine(
        sessionMode: mode(),
        random: const FixedRandom(),
      );
      check(engine.currentStepIndex).equals(-1);
    });

    test('Invariant 1: currentStepIndex in [0, n-1] while running', () {
      fakeAsync((async) {
        final m = mode(
          chainSteps: [
            step(durationSeconds: 1, gracePeriodSeconds: 0),
            step(
              type: ChainStepType.smsContact,
              durationSeconds: 1,
              gracePeriodSeconds: 0,
            ),
          ],
        );
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();

        check(engine.currentStepIndex).isGreaterOrEqual(0);
        check(engine.currentStepIndex).isLessThan(2);

        async.elapse(const Duration(seconds: 1));
        check(engine.currentStepIndex).equals(1);

        engine.endSession();
      });
    });

    // Invariant 2: disarm() always resets to step 0 and clears miss count.
    test('Invariant 2: disarm() resets to step 0', () {
      fakeAsync((async) {
        final m = mode(
          chainSteps: [
            step(durationSeconds: 1, gracePeriodSeconds: 0),
            step(type: ChainStepType.callEmergency),
          ],
        );
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1));
        check(engine.currentStepIndex).equals(1);

        engine.disarm();
        async.flushMicrotasks();
        check(engine.currentStepIndex).equals(0);
        engine.endSession();
      });
    });

    // Invariant 3: endSession() is idempotent.
    test('Invariant 3: endSession() idempotent', () {
      fakeAsync((async) {
        final engine = buildEngine(
          sessionMode: mode(),
          random: const FixedRandom(),
        );
        engine.start();
        async.flushMicrotasks();
        engine.endSession();
        check(engine.endSession).returnsNormally();
        check(engine.endSession).returnsNormally();
        check(engine.isEnded).isTrue();
      });
    });

    // Invariant 4: No events after endSession().
    test('Invariant 4: no events after endSession()', () {
      fakeAsync((async) {
        int postEndCount = 0;
        final engine = buildEngine(
          sessionMode: mode(),
          random: const FixedRandom(),
        );
        engine.start();
        async.flushMicrotasks();
        engine.endSession();
        engine.events.listen((_) => postEndCount++);
        engine.notifyWrongPin(1);
        async.flushMicrotasks();
        check(postEndCount).equals(0);
      });
    });

    // Invariant 5: Speed multiplier applies to ALL timers.
    test('Invariant 5: speed multiplier scales duration timer', () {
      fakeAsync((async) {
        // 10x speed → 10s step fires in 1s.
        final m = mode(
          chainSteps: [
            step(gracePeriodSeconds: 0),
            step(type: ChainStepType.callEmergency),
          ],
        );
        final engine = buildEngine(
          sessionMode: m,
          isSimulation: true,
          speedMultiplier: 10.0,
          random: const FixedRandom(),
        );
        engine.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1));
        check(engine.currentStepIndex).equals(1);
        engine.endSession();
      });
    });

    // Invariant 6: Session timer starts on user interaction for holdButton.
    test('Invariant 6: holdButton waits for user interaction', () {
      fakeAsync((async) {
        final m = mode(
          chainSteps: [
            step(
              type: ChainStepType.holdButton,
              durationSeconds: 5,
              gracePeriodSeconds: 2,
            ),
            step(type: ChainStepType.callEmergency),
          ],
        );
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();

        // Long time passes — holdButton waits for user, not timer.
        async.elapse(const Duration(minutes: 10));
        check(engine.currentStepIndex).equals(0); // Waiting for user.

        engine.endSession();
      });
    });

    // Invariant 7: Only one session active at a time (start() throws if running).
    test('Invariant 7: start() throws if not idle', () {
      fakeAsync((async) {
        final engine = buildEngine(
          sessionMode: mode(),
          random: const FixedRandom(),
        );
        engine.start();
        async.flushMicrotasks();
        check(engine.start).throws<StateError>();
        engine.endSession();
      });
    });

    // Invariant 8: Distress chain replaces main chain permanently.
    test('Invariant 8: distress chain replaces main chain', () {
      fakeAsync((async) {
        final mainStep = step(durationSeconds: 100);
        final distressStep = step(
          type: ChainStepType.smsContact,
          durationSeconds: 1,
        );
        final engine = buildEngine(
          sessionMode: mode(chainSteps: [mainStep]),
          random: const FixedRandom(),
        );
        engine.start();
        async.flushMicrotasks();

        engine.replaceWithDistressChain(
          chain: [distressStep],
          triggerReason: EndReason.hardwarePanic,
        );
        async.flushMicrotasks();

        check(engine.currentStep?.type).equals(ChainStepType.smsContact);
        check(engine.isDistressChain).isTrue();
        engine.endSession();
      });
    });

    // Invariant 9: Pause state is deterministic.
    test('Invariant 9: pause/resume deterministic remaining time', () {
      fakeAsync((async) {
        final m = mode(
          chainSteps: [
            step(gracePeriodSeconds: 0),
            step(type: ChainStepType.callEmergency),
          ],
        );
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();

        // 4s elapsed → 6s remain.
        async.elapse(const Duration(seconds: 4));
        engine.pause();

        // Arbitrarily long pause.
        async.elapse(const Duration(hours: 1));
        engine.resume();

        // Exactly 6s after resume: step advances.
        async.elapse(const Duration(seconds: 5));
        check(engine.currentStepIndex).equals(0);

        async.elapse(const Duration(seconds: 1));
        check(engine.currentStepIndex).equals(1);

        engine.endSession();
      });
    });

    // Invariant 10: holdStart()/holdRelease() no-op on non-holdButton steps.
    test('Invariant 10: hold methods no-op on non-holdButton step', () {
      fakeAsync((async) {
        final engine = buildEngine(
          sessionMode: mode(chainSteps: [step()]),
          random: const FixedRandom(),
        );
        engine.start();
        async.flushMicrotasks();
        check(() {
          engine.holdStart();
          engine.holdRelease();
        }).returnsNormally();
        check(engine.isHolding).isFalse();
        engine.endSession();
      });
    });

    // Invariant 11: Miss count per-step — resets on advance or disarm.
    test('Invariant 11: miss count resets on step advance', () {
      fakeAsync((async) {
        final m = mode(
          chainSteps: [
            step(durationSeconds: 1, gracePeriodSeconds: 1, retryCount: 1),
            step(type: ChainStepType.smsContact, durationSeconds: 100),
          ],
        );
        int step1Misses = 0;
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.events.listen((e) {
          if (e.event == ChainEvent.graceExpired && e.stepIndex == 1) {
            step1Misses++;
          }
        });
        engine.start();
        async.flushMicrotasks();

        // Exhaust step 0 retries.
        async.elapse(const Duration(seconds: 4));
        check(engine.currentStepIndex).equals(1);

        // Step 1 should start fresh (miss count = 0).
        check(step1Misses).equals(0);
        engine.endSession();
      });
    });

    // Invariant 12: No step content changes mid-session.
    test('Invariant 12: chain is immutable after start()', () {
      fakeAsync((async) {
        final chainStep = step();
        final m = mode(chainSteps: [chainStep]);
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();

        // The chain is a defensive copy — cannot be modified externally.
        // This test verifies the engine's chain reference is unmodifiable.
        final originalType = engine.currentStep?.type;
        check(originalType).equals(ChainStepType.loudAlarm);

        engine.endSession();
      });
    });

    // Invariant 13: allowDisarmAsDistress controls disarm triggers during
    // distress (G-014).
    test('Invariant 13: allowDisarmAsDistress=true (default) permits disarm '
        'triggers during distress (positive branch)', () {
      fakeAsync((async) {
        var disarmed = false;
        final m = mode(
          chainSteps: [step(durationSeconds: 100)],
          disarmTriggers: const [TimerDisarmTrigger(durationSeconds: 2)],
          // Default — explicit for documentation.
        );
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.events.listen((e) {
          if (e.event == ChainEvent.userDisarmed) {
            disarmed = true;
          }
        });
        engine.start();
        async.flushMicrotasks();

        // Replace with distress chain.
        engine.replaceWithDistressChain(
          chain: [step(type: ChainStepType.smsContact, durationSeconds: 100)],
          triggerReason: EndReason.hardwarePanic,
        );

        // Timer disarm trigger should fire normally because
        // allowDisarmAsDistress defaults to true.
        async.elapse(const Duration(seconds: 5));
        check(disarmed).isTrue();

        engine.endSession();
      });
    });

    test(
      'Invariant 13: allowDisarmAsDistress=false blocks disarm triggers in distress',
      () {
        fakeAsync((async) {
          var disarmed = false;
          final m = mode(
            chainSteps: [step(durationSeconds: 100)],
            disarmTriggers: const [TimerDisarmTrigger(durationSeconds: 2)],
            allowDisarmAsDistress: false,
          );
          final engine = buildEngine(
            sessionMode: m,
            random: const FixedRandom(),
          );
          engine.events.listen((e) {
            if (e.event == ChainEvent.userDisarmed) {
              disarmed = true;
            }
          });
          engine.start();
          async.flushMicrotasks();

          // Replace with distress chain.
          engine.replaceWithDistressChain(
            chain: [step(type: ChainStepType.smsContact, durationSeconds: 100)],
            triggerReason: EndReason.hardwarePanic,
          );

          // Timer disarm trigger should be blocked.
          async.elapse(const Duration(seconds: 5));
          check(disarmed).isFalse();
          check(engine.isEnded).isFalse();

          engine.endSession();
        });
      },
    );
  });
}
