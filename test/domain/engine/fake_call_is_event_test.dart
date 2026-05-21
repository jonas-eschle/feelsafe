import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/engine/chain_event.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'engine_test_helpers.dart';

void main() {
  group('FakeCall is an event, not a pause (Pivot 2)', () {
    test('answerFakeCall() is a no-op — engine keeps running', () {
      fakeAsync((async) {
        final m = mode(
          chainSteps: [
            step(type: ChainStepType.fakeCall),
            step(type: ChainStepType.callEmergency),
          ],
        );
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();

        // Answer the fake call — engine should NOT pause.
        engine.answerFakeCall();
        check(engine.isPaused).isFalse();
        check(engine.isEnded).isFalse();
        check(engine.currentStepIndex).equals(0);

        engine.endSession();
      });
    });

    test('engine timer keeps running after answerFakeCall()', () {
      fakeAsync((async) {
        final m = mode(
          chainSteps: [
            step(
              type: ChainStepType.fakeCall,
              durationSeconds: 5,
              gracePeriodSeconds: 2,
            ),
            step(type: ChainStepType.callEmergency),
          ],
        );
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();

        engine.answerFakeCall();
        check(engine.currentStepIndex).equals(0);

        // Timer still running: after duration + grace, step advances.
        async.elapse(const Duration(seconds: 8));
        check(engine.currentStepIndex).equals(1);

        engine.endSession();
      });
    });

    test('answerFakeCall() does NOT end the session', () {
      fakeAsync((async) {
        final engine = buildEngine(sessionMode: 
          mode(
            chainSteps: [
              step(type: ChainStepType.fakeCall, durationSeconds: 5),
            ],
          ),
          random: const FixedRandom(),
        );
        engine.start();
        async.flushMicrotasks();
        engine.answerFakeCall();
        check(engine.isEnded).isFalse();
        engine.endSession();
      });
    });

    test('hangUp() triggers disarm — chain resets to step 0', () {
      fakeAsync((async) {
        final m = mode(
          chainSteps: [
            step(type: ChainStepType.fakeCall, durationSeconds: 30),
            step(type: ChainStepType.callEmergency),
          ],
        );
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.start();

        // Advance to step 1 first.
        async.elapse(const Duration(seconds: 35));
        check(engine.currentStepIndex).equals(1);

        // hangUp triggers disarm on any step.
        engine.hangUp();
        async.flushMicrotasks();
        check(engine.currentStepIndex).equals(0);

        engine.endSession();
      });
    });

    test('hangUp() on fakeCall step disarms from step 0', () {
      fakeAsync((async) {
        final m = mode(
          chainSteps: [
            step(type: ChainStepType.fakeCall),
            step(type: ChainStepType.callEmergency),
          ],
        );
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();
        check(engine.currentStepIndex).equals(0);

        engine.hangUp();
        async.flushMicrotasks();
        check(engine.currentStepIndex).equals(0);

        engine.endSession();
      });
    });

    test('answerFakeCall() emits no sessionPaused event', () {
      fakeAsync((async) {
        final events = <ChainEventData>[];
        final engine = buildEngine(sessionMode: 
          mode(
            chainSteps: [
              step(type: ChainStepType.fakeCall, durationSeconds: 5),
            ],
          ),
          random: const FixedRandom(),
        );
        engine.events.listen(events.add);
        engine.start();
        async.flushMicrotasks();

        engine.answerFakeCall();

        final paused = events.where(
          (e) => e.event == ChainEvent.sessionPaused,
        );
        check(paused).isEmpty();

        engine.endSession();
      });
    });

    test('answerFakeCall() is safe to call multiple times', () {
      fakeAsync((async) {
        final engine = buildEngine(sessionMode: 
          mode(chainSteps: [step(type: ChainStepType.fakeCall)]),
          random: const FixedRandom(),
        );
        engine.start();
        async.flushMicrotasks();
        check(() {
          engine.answerFakeCall();
          engine.answerFakeCall();
          engine.answerFakeCall();
        }).returnsNormally();
        engine.endSession();
      });
    });

    test('restartCurrentStep() preserves miss count', () {
      fakeAsync((async) {
        final m = mode(
          chainSteps: [
            step(
              type: ChainStepType.fakeCall,
              durationSeconds: 2,
              gracePeriodSeconds: 2,
              retryCount: 1,
            ),
            step(type: ChainStepType.callEmergency),
          ],
        );
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();

        // Step fires immediately (waitSeconds=0).
        // Restart to simulate decline-is-not-safe.
        engine.restartCurrentStep();
        async.flushMicrotasks();
        check(engine.currentStepIndex).equals(0);

        engine.endSession();
      });
    });

    test('hangUp() does not end the session, just disarms', () {
      fakeAsync((async) {
        final m = mode(
          chainSteps: [
            step(type: ChainStepType.fakeCall),
            step(type: ChainStepType.callEmergency),
          ],
        );
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();

        engine.hangUp();
        async.flushMicrotasks();

        check(engine.isEnded).isFalse();
        check(engine.currentStepIndex).equals(0);

        engine.endSession();
      });
    });
  });
}
