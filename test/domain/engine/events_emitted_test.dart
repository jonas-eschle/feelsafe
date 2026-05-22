import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/engine/chain_event.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/enums/pause_reason.dart';
import 'engine_test_helpers.dart';

void main() {
  group('Events emitted', () {
    test('sessionStarted emitted on start()', () {
      fakeAsync((async) {
        final events = <ChainEvent>[];
        final engine = buildEngine(
          sessionMode: mode(),
          random: const FixedRandom(),
        );
        engine.events.listen((e) => events.add(e.event));
        engine.start();
        async.flushMicrotasks();
        check(events).contains(ChainEvent.sessionStarted);
        engine.endSession();
      });
    });

    test('stepStarted emitted at beginning of each step', () {
      fakeAsync((async) {
        final events = <ChainEventData>[];
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
        engine.events.listen(events.add);
        engine.start();
        async.flushMicrotasks();

        final stepStarted = events
            .where((e) => e.event == ChainEvent.stepStarted)
            .toList();
        check(stepStarted).isNotEmpty();
        check(stepStarted.first.stepIndex).equals(0);

        async.elapse(const Duration(seconds: 1));
        final stepStarted2 = events
            .where((e) => e.event == ChainEvent.stepStarted)
            .toList();
        check(stepStarted2.length).isGreaterOrEqual(2);

        engine.endSession();
      });
    });

    test('reminderFired emitted when disguised-reminder enters duration', () {
      fakeAsync((async) {
        final events = <ChainEvent>[];
        // Spec 01 §Events Emitted: reminderFired is emitted only when a
        // disguisedReminder step enters its duration phase (overlay
        // visible). Other step types do not emit a per-phase-transition
        // event.
        final engine = buildEngine(
          sessionMode: mode(
            chainSteps: [
              step(type: ChainStepType.disguisedReminder, durationSeconds: 5),
            ],
          ),
          random: const FixedRandom(),
        );
        engine.events.listen((e) => events.add(e.event));
        engine.start();
        async.flushMicrotasks();
        check(events).contains(ChainEvent.reminderFired);
        engine.endSession();
      });
    });

    test('graceExpired emitted when grace expires without disarm', () {
      fakeAsync((async) {
        final events = <ChainEventData>[];
        final m = mode(
          chainSteps: [step(durationSeconds: 1, gracePeriodSeconds: 1)],
        );
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.events.listen(events.add);
        engine.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 3));

        final missed = events.where((e) => e.event == ChainEvent.graceExpired);
        check(missed).isNotEmpty();
        check(missed.first.metadata['missCount']).equals(1);
        engine.endSession(); // Already ended (chain exhausted) — no-op.
      });
    });

    test('repeatMissed emitted on disguised-reminder retry (spec 01 '
        '§Events Emitted, §Disguised Reminder State Machine)', () {
      fakeAsync((async) {
        final events = <ChainEventData>[];
        // disguisedReminder with retryCount=1 means: first grace expiry
        // is a retry (graceExpired + repeatMissed), second grace expiry
        // advances out of the step (graceExpired + stepAdvancing). Only
        // disguisedReminder emits repeatMissed per spec 01 §Events
        // Emitted line 712-713.
        final m = mode(
          chainSteps: [
            step(
              type: ChainStepType.disguisedReminder,
              durationSeconds: 1,
              gracePeriodSeconds: 1,
              retryCount: 1,
            ),
            step(type: ChainStepType.callEmergency),
          ],
        );
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.events.listen(events.add);
        engine.start();
        async.flushMicrotasks();

        // Elapse through duration(1s) + grace(1s) = 2s → first miss
        // triggers a retry (repeatMissed) because missCount (1) ≤
        // retryCount (1).
        async.elapse(const Duration(seconds: 2));
        final retryMisses = events
            .where((e) => e.event == ChainEvent.repeatMissed)
            .toList();
        check(retryMisses).isNotEmpty();
        check(retryMisses.first.metadata['missCount']).equals(1);
        check(
          retryMisses.first.stepType,
        ).equals(ChainStepType.disguisedReminder);

        // Elapse through one more duration+grace; second grace expiry
        // does NOT emit repeatMissed (missCount > retryCount → advance).
        // Still must have exactly one repeatMissed in total.
        async.elapse(const Duration(seconds: 2));
        final allRetry = events
            .where((e) => e.event == ChainEvent.repeatMissed)
            .toList();
        check(allRetry.length).equals(1);

        engine.endSession();
      });
    });

    test('repeatMissed is NOT emitted for non-disguised-reminder steps', () {
      fakeAsync((async) {
        final events = <ChainEventData>[];
        // loudAlarm with retryCount=1 retries on grace expiry but never
        // emits repeatMissed (spec narrows that event to
        // disguisedReminder).
        final m = mode(
          chainSteps: [
            step(durationSeconds: 1, gracePeriodSeconds: 1, retryCount: 1),
            step(type: ChainStepType.callEmergency),
          ],
        );
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.events.listen(events.add);
        engine.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 5)); // enough to retry once

        // graceExpired must fire; repeatMissed must NOT.
        check(
          events.where((e) => e.event == ChainEvent.graceExpired),
        ).isNotEmpty();
        check(
          events.where((e) => e.event == ChainEvent.repeatMissed),
        ).isEmpty();

        engine.endSession();
      });
    });

    test('userDisarmed emitted with fromStepIndex metadata', () {
      fakeAsync((async) {
        final events = <ChainEventData>[];
        final m = mode(
          chainSteps: [
            step(durationSeconds: 1),
            step(type: ChainStepType.callEmergency),
          ],
        );
        final engine = buildEngine(sessionMode: m, random: const FixedRandom());
        engine.events.listen(events.add);
        engine.start();
        async.flushMicrotasks();

        // Advance to step 1.
        async.elapse(const Duration(seconds: 7));
        engine.disarm();
        async.flushMicrotasks();

        final disarmed = events.where(
          (e) => e.event == ChainEvent.userDisarmed,
        );
        check(disarmed).isNotEmpty();
        // fromStepIndex should be 1 (where we disarmed from).
        check(disarmed.first.metadata['fromStepIndex']).equals(1);

        engine.endSession();
      });
    });

    test('stepAdvancing + sessionEnded(chainExhausted) when last step '
        'completes', () {
      fakeAsync((async) {
        final events = <ChainEventData>[];
        final m = mode(
          chainSteps: [step(durationSeconds: 1, gracePeriodSeconds: 0)],
        );
        final eng = buildEngine(sessionMode: m, random: const FixedRandom());
        eng.events.listen(events.add);
        eng.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 2));
        // stepAdvancing fires when the engine attempts to move past the
        // last step; immediately followed by sessionEnded with reason
        // chainExhausted (spec 01 §EndReason).
        final advancing = events.where(
          (e) => e.event == ChainEvent.stepAdvancing,
        );
        check(advancing).isNotEmpty();
        final ended = events.where((e) => e.event == ChainEvent.sessionEnded);
        check(ended).isNotEmpty();
        check(
          ended.first.metadata['reason'],
        ).equals(EndReason.chainExhausted.name);
      });
    });

    test('replaceWithDistress emitted with triggerReason metadata', () {
      fakeAsync((async) {
        final events = <ChainEventData>[];
        final engine = buildEngine(
          sessionMode: mode(),
          random: const FixedRandom(),
        );
        engine.events.listen(events.add);
        engine.start();
        async.flushMicrotasks();

        engine.replaceWithDistressChain(
          chain: [step()],
          triggerReason: EndReason.duressPin,
        );

        final distress = events.where(
          (e) => e.event == ChainEvent.distressTriggered,
        );
        check(distress).isNotEmpty();
        check(
          distress.first.metadata['triggerReason'],
        ).equals(EndReason.duressPin.name);
        engine.endSession();
      });
    });

    test('pausedRequested emitted with reason metadata', () {
      fakeAsync((async) {
        final events = <ChainEventData>[];
        final engine = buildEngine(
          sessionMode: mode(),
          random: const FixedRandom(),
        );
        engine.events.listen(events.add);
        engine.start();
        async.flushMicrotasks();

        engine.pause();

        final paused = events.where((e) => e.event == ChainEvent.sessionPaused);
        check(paused).isNotEmpty();
        check(
          paused.first.metadata['reason'],
        ).equals(PauseReason.userRequested.name);
        engine.endSession();
      });
    });

    test('resumed emitted after resume()', () {
      fakeAsync((async) {
        final events = <ChainEvent>[];
        final engine = buildEngine(
          sessionMode: mode(),
          random: const FixedRandom(),
        );
        engine.events.listen((e) => events.add(e.event));
        engine.start();
        async.flushMicrotasks();
        engine.pause();
        engine.resume();
        check(events).contains(ChainEvent.sessionResumed);
        engine.endSession();
      });
    });

    test('pauseExpired emitted when maxPauseDuration exceeded', () {
      fakeAsync((async) {
        final events = <ChainEvent>[];
        final engine = buildEngine(
          sessionMode: mode(),
          maxPauseDuration: const Duration(seconds: 3),
          random: const FixedRandom(),
        );
        engine.events.listen((e) => events.add(e.event));
        engine.start();
        async.flushMicrotasks();
        engine.pause();
        async.elapse(const Duration(seconds: 4));
        check(events).contains(ChainEvent.pauseExpired);
        engine.endSession();
      });
    });

    test('sessionEnded emitted with reason metadata', () {
      fakeAsync((async) {
        final events = <ChainEventData>[];
        final engine = buildEngine(
          sessionMode: mode(),
          random: const FixedRandom(),
        );
        engine.events.listen(events.add);
        engine.start();
        async.flushMicrotasks();
        engine.endSession();

        final ended = events.where((e) => e.event == ChainEvent.sessionEnded);
        check(ended).isNotEmpty();
        check(ended.first.metadata['reason']).equals(EndReason.userQuit.name);
      });
    });

    test('deceptiveOldPinShown emitted by notifyWrongPin', () {
      fakeAsync((async) {
        final events = <ChainEventData>[];
        final engine = buildEngine(
          sessionMode: mode(),
          random: const FixedRandom(),
        );
        engine.events.listen(events.add);
        engine.start();
        async.flushMicrotasks();

        engine.notifyWrongPin(3);

        final pinEvents = events.where(
          (e) => e.event == ChainEvent.deceptiveOldPinShown,
        );
        check(pinEvents).isNotEmpty();
        check(pinEvents.first.metadata['attemptCount']).equals(3);

        engine.endSession();
      });
    });

    test('notifyWrongPin carries correct attemptCount', () {
      fakeAsync((async) {
        final events = <ChainEventData>[];
        final engine = buildEngine(
          sessionMode: mode(),
          random: const FixedRandom(),
        );
        engine.events.listen(events.add);
        engine.start();
        async.flushMicrotasks();

        for (var i = 1; i <= 5; i++) {
          engine.notifyWrongPin(i);
        }

        final pinEvents = events
            .where((e) => e.event == ChainEvent.deceptiveOldPinShown)
            .toList();
        check(pinEvents.length).equals(5);
        for (var i = 0; i < 5; i++) {
          check(pinEvents[i].metadata['attemptCount']).equals(i + 1);
        }

        engine.endSession();
      });
    });

    test('notifyWrongPin no-op after endSession', () {
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
        engine.notifyWrongPin(1);
        async.flushMicrotasks();
        check(count).equals(0);
      });
    });

    test('all 15 ChainEvent values are declared (spec 01 §Events Emitted)', () {
      // Verify the enum is exhaustive against spec 01 §Events Emitted. A
      // separate test asserts that each event is actually emitted by the
      // engine under its triggering condition (rather than just being
      // declared).
      const allEvents = ChainEvent.values;
      check(allEvents).contains(ChainEvent.sessionStarted);
      check(allEvents).contains(ChainEvent.stepStarted);
      check(allEvents).contains(ChainEvent.stepAdvancing);
      check(allEvents).contains(ChainEvent.graceExpired);
      check(allEvents).contains(ChainEvent.repeatMissed);
      check(allEvents).contains(ChainEvent.reminderFired);
      check(allEvents).contains(ChainEvent.pauseExpired);
      check(allEvents).contains(ChainEvent.stepExecutionFailed);
      check(allEvents).contains(ChainEvent.distressTriggered);
      check(allEvents).contains(ChainEvent.distressCompleted);
      check(allEvents).contains(ChainEvent.sessionPaused);
      check(allEvents).contains(ChainEvent.sessionResumed);
      check(allEvents).contains(ChainEvent.userDisarmed);
      check(allEvents).contains(ChainEvent.deceptiveOldPinShown);
      check(allEvents).contains(ChainEvent.sessionEnded);
      check(allEvents.length).equals(15);
    });
  });
}
