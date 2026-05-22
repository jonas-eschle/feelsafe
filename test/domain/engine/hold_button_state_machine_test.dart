// Closes qa-expert finding G3 (Phase 2 verification): exercise the full
// hold-button state machine described in spec 01 §Hold Button State
// Machine. Pre-existing tests only covered Invariant 6 (engine waits on
// step 0 indefinitely without user interaction) and Invariant 10
// (hold-methods no-op off-step). This file walks through every documented
// transition with `fake_async` timing assertions.

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/engine/chain_event.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'engine_test_helpers.dart';

void main() {
  group('Hold-button state machine (spec 01 §Hold Button State Machine)', () {
    test('holdRelease() starts the sensitivity timer; sensitivity expiry '
        'starts the duration countdown', () {
      fakeAsync((async) {
        // Default releaseSensitivity is 1.0s (HoldButtonConfig); we don't
        // attach an explicit config here, so the engine uses the spec
        // default of 1.0s.
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

        // holdStart begins; holdRelease starts the 1.0s sensitivity timer.
        engine.holdStart();
        engine.holdRelease();
        check(engine.isHolding).isFalse();

        // Less than 1s after release → no advance yet.
        async.elapse(const Duration(milliseconds: 800));
        check(engine.currentStepIndex).equals(0);

        // After 1s sensitivity + 5s duration + 2s grace → advance to step 1.
        async.elapse(const Duration(seconds: 8));
        check(engine.currentStepIndex).equals(1);

        engine.endSession();
      });
    });

    test('re-hold within the sensitivity window cancels the impending '
        'duration countdown', () {
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

        engine.holdStart();
        engine.holdRelease(); // Sensitivity timer starts (1s).
        async.elapse(const Duration(milliseconds: 500));

        // User re-holds before sensitivity expires → countdown is cancelled.
        engine.holdStart();
        check(engine.isHolding).isTrue();

        // Even after 10s nothing advances because the user keeps holding.
        async.elapse(const Duration(seconds: 10));
        check(engine.currentStepIndex).equals(0);

        engine.endSession();
      });
    });

    test('D1: holdRelease during duration countdown cancels and restarts '
        'the countdown', () {
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

        // First release: sensitivity (1s) then duration (5s) → would
        // advance at t=8 (1 + 5 + 2 grace).
        engine.holdStart();
        engine.holdRelease();
        async.elapse(const Duration(seconds: 3)); // 1s sens + 2s of 5s dur
        check(engine.currentStepIndex).equals(0);

        // Mid-duration: user re-holds → countdown cancels.
        engine.holdStart();
        async.elapse(const Duration(seconds: 10));
        check(engine.currentStepIndex).equals(0);

        // Release again → sensitivity (1s) + full duration (5s) + grace
        // (2s) starts fresh.
        engine.holdRelease();
        async.elapse(const Duration(seconds: 7)); // sens + dur — not advanced
        check(engine.currentStepIndex).equals(0);
        async.elapse(const Duration(seconds: 2)); // + grace → advance
        check(engine.currentStepIndex).equals(1);

        engine.endSession();
      });
    });

    test('holdStart during grace phase triggers disarm and resets to '
        'step 0', () {
      fakeAsync((async) {
        final events = <ChainEvent>[];
        final m = mode(
          chainSteps: [
            // gracePeriodSeconds defaults to 5s — long enough that
            // sensitivity (1s) + duration (2s) leaves the engine in
            // grace phase when holdStart() is called below.
            step(type: ChainStepType.holdButton, durationSeconds: 2),
            step(type: ChainStepType.callEmergency),
          ],
        );
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.events.listen((e) => events.add(e.event));
        engine.start();
        async.flushMicrotasks();

        // Move the step into the grace phase by completing
        // sensitivity (1s) + duration (2s) = 3s after holdRelease.
        engine.holdStart();
        engine.holdRelease();
        async.elapse(const Duration(seconds: 3));
        check(engine.currentStepIndex).equals(0);

        // Now in grace: holdStart should fire disarm (Invariant 10c).
        engine.holdStart();
        async.flushMicrotasks();
        check(events).contains(ChainEvent.userDisarmed);
        check(engine.currentStepIndex).equals(0); // Reset to step 0.

        engine.endSession();
      });
    });

    test('brief release (<sensitivity) is ignored — engine stays held', () {
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

        engine.holdStart();

        // Release for 0.5s then re-hold — the sensitivity (1.0s) hasn't
        // elapsed so the release is brief-release-tolerated.
        engine.holdRelease();
        async.elapse(const Duration(milliseconds: 500));
        engine.holdStart();
        check(engine.isHolding).isTrue();

        // Even after a long subsequent hold the chain doesn't advance.
        async.elapse(const Duration(seconds: 30));
        check(engine.currentStepIndex).equals(0);

        engine.endSession();
      });
    });
  });
}
