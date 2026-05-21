import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/engine/chain_event.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/pause_reason.dart';
import 'engine_test_helpers.dart';

void main() {
  group('Pause / resume', () {
    test('remaining time is preserved across pause/resume', () {
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

        // 4 seconds into duration (6s remain).
        async.elapse(const Duration(seconds: 4));
        check(engine.currentStepIndex).equals(0);

        engine.pause();
        check(engine.isPaused).isTrue();

        // Long pause — timer shouldn't fire.
        async.elapse(const Duration(seconds: 100));
        check(engine.currentStepIndex).equals(0); // Step unchanged.

        engine.resume();
        check(engine.isPaused).isFalse();

        // 5 more seconds passes — still step 0 (6s total needed).
        async.elapse(const Duration(seconds: 5));
        check(engine.currentStepIndex).equals(0);

        // Final second.
        async.elapse(const Duration(seconds: 1));
        check(engine.currentStepIndex).equals(1);

        engine.endSession();
      });
    });

    test('maxPauseDuration auto-resumes and emits pauseExpired', () {
      fakeAsync((async) {
        final events = <ChainEvent>[];
        final m = mode(
          chainSteps: [step(durationSeconds: 100, gracePeriodSeconds: 0)],
        );
        final engine = buildEngine(sessionMode: 
          m,
          maxPauseDuration: const Duration(seconds: 5),
          random: const FixedRandom(),
        );
        engine.events.listen((e) => events.add(e.event));
        engine.start();
        async.flushMicrotasks();

        engine.pause();
        check(engine.isPaused).isTrue();

        // Expire max pause duration.
        async.elapse(const Duration(seconds: 5));

        // Engine should have auto-resumed.
        check(engine.isPaused).isFalse();
        check(events).contains(ChainEvent.pauseExpired);
        check(events).contains(ChainEvent.sessionResumed);

        engine.endSession();
      });
    });

    test('maxPauseDuration null = unlimited pause', () {
      fakeAsync((async) {
        final engine = buildEngine(sessionMode: mode(), random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();
        engine.pause();

        async.elapse(const Duration(hours: 24));
        check(engine.isPaused).isTrue(); // Still paused — no expiry.

        engine.endSession();
      });
    });

    test('PauseReason.incomingCall emitted correctly', () {
      fakeAsync((async) {
        final events = <ChainEventData>[];
        final engine = buildEngine(sessionMode: mode(), random: const FixedRandom());
        engine.events.listen(events.add);
        engine.start();
        async.flushMicrotasks();

        engine.pause(reason: PauseReason.incomingCall);

        final paused = events.where(
          (e) => e.event == ChainEvent.sessionPaused,
        );
        check(paused).isNotEmpty();
        check(
          paused.first.metadata['reason'],
        ).equals(PauseReason.incomingCall.name);

        engine.endSession();
      });
    });

    test('resume() emits resumed event', () {
      fakeAsync((async) {
        final events = <ChainEvent>[];
        final engine = buildEngine(sessionMode: mode(), random: const FixedRandom());
        engine.events.listen((e) => events.add(e.event));
        engine.start();
        async.flushMicrotasks();
        engine.pause();
        engine.resume();
        check(events).contains(ChainEvent.sessionResumed);
        engine.endSession();
      });
    });

    test('pause() no-op when already paused', () {
      fakeAsync((async) {
        int pauseCount = 0;
        final engine = buildEngine(sessionMode: mode(), random: const FixedRandom());
        engine.events.listen((e) {
          if (e.event == ChainEvent.sessionPaused) {
            pauseCount++;
          }
        });
        engine.start();
        async.flushMicrotasks();
        engine.pause();
        engine.pause(); // Second pause — no-op.
        check(pauseCount).equals(1);
        engine.endSession();
      });
    });

    test('grace phase remaining preserved across pause/resume', () {
      fakeAsync((async) {
        final m = mode(
          chainSteps: [
            step(durationSeconds: 1, gracePeriodSeconds: 10),
            step(type: ChainStepType.callEmergency),
          ],
        );
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();

        // Elapse duration to enter grace.
        async.elapse(const Duration(seconds: 1));
        check(engine.currentStepIndex).equals(0);

        // 3s into grace (7s remain).
        async.elapse(const Duration(seconds: 3));
        engine.pause();

        // Long pause.
        async.elapse(const Duration(seconds: 100));
        check(engine.currentStepIndex).equals(0);

        engine.resume();

        // 6 more seconds: step should advance after 7s total.
        async.elapse(const Duration(seconds: 6));
        check(
          engine.currentStepIndex,
        ).equals(0); // Not yet (7s needed from resume).

        async.elapse(const Duration(seconds: 1));
        check(engine.currentStepIndex).equals(1);

        engine.endSession();
      });
    });

    test('pause during wait phase preserves remaining wait time', () {
      fakeAsync((async) {
        final m = mode(
          chainSteps: [
            step(waitSeconds: 20, durationSeconds: 1, gracePeriodSeconds: 0),
            step(type: ChainStepType.callEmergency),
          ],
        );
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();

        // 5s into wait (15s remain).
        async.elapse(const Duration(seconds: 5));
        engine.pause();

        async.elapse(const Duration(seconds: 100));

        engine.resume();

        // 14s after resume: still waiting.
        async.elapse(const Duration(seconds: 14));
        check(engine.currentStepIndex).equals(0);

        // 15s after resume: fires.
        async.elapse(const Duration(seconds: 2));
        check(engine.currentStepIndex).equals(1);

        engine.endSession();
      });
    });

    test('multiple pause/resume cycles deterministic', () {
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

        // Pause at 2s (8s remain).
        async.elapse(const Duration(seconds: 2));
        engine.pause();
        async.elapse(const Duration(seconds: 50));
        engine.resume();

        // Pause at 2s after resume (6s remain).
        async.elapse(const Duration(seconds: 2));
        engine.pause();
        async.elapse(const Duration(seconds: 50));
        engine.resume();

        // 5 more seconds: still step 0 (6s needed).
        async.elapse(const Duration(seconds: 5));
        check(engine.currentStepIndex).equals(0);

        // 1 more second: advance.
        async.elapse(const Duration(seconds: 1));
        check(engine.currentStepIndex).equals(1);

        engine.endSession();
      });
    });
  });
}
