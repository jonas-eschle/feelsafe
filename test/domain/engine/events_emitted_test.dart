import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardianangela/domain/engine/chain_event.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/enums/pause_reason.dart';

import 'engine_test_helpers.dart';

void main() {
  group('Events emitted', () {
    test('sessionStarted emitted on start()', () {
      fakeAsync((async) {
        final events = <ChainEvent>[];
        final engine = SessionEngine(mode(), random: const FixedRandom());
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
        final engine = SessionEngine(m, random: const FixedRandom());
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

    test('stepFired emitted when step enters duration phase', () {
      fakeAsync((async) {
        final events = <ChainEvent>[];
        final engine = SessionEngine(
          mode(chainSteps: [step(durationSeconds: 5)]),
          random: const FixedRandom(),
        );
        engine.events.listen((e) => events.add(e.event));
        engine.start();
        async.flushMicrotasks();
        check(events).contains(ChainEvent.stepFired);
        engine.endSession();
      });
    });

    test('stepMissed emitted when grace expires without disarm', () {
      fakeAsync((async) {
        final events = <ChainEventData>[];
        final m = mode(
          chainSteps: [step(durationSeconds: 1, gracePeriodSeconds: 1)],
        );
        final engine = SessionEngine(m, random: const FixedRandom());
        engine.events.listen(events.add);
        engine.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 3));

        final missed = events.where((e) => e.event == ChainEvent.stepMissed);
        check(missed).isNotEmpty();
        check(missed.first.metadata['missCount']).equals(1);
        engine.endSession(); // Already ended (chain exhausted) — no-op.
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
        final engine = SessionEngine(m, random: const FixedRandom());
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

    test('chainExhausted emitted when last step completes', () {
      fakeAsync((async) {
        final events = <ChainEvent>[];
        final m = mode(
          chainSteps: [step(durationSeconds: 1, gracePeriodSeconds: 0)],
        );
        final engine = SessionEngine(m, random: const FixedRandom());
        engine.events.listen((e) => events.add(e.event));
        engine.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 2));
        check(events).contains(ChainEvent.chainExhausted);
      });
    });

    test('replaceWithDistress emitted with triggerReason metadata', () {
      fakeAsync((async) {
        final events = <ChainEventData>[];
        final engine = SessionEngine(mode(), random: const FixedRandom());
        engine.events.listen(events.add);
        engine.start();
        async.flushMicrotasks();

        engine.replaceWithDistressChain(
          chain: [step()],
          triggerReason: EndReason.duressPin,
        );

        final distress = events.where(
          (e) => e.event == ChainEvent.replaceWithDistress,
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
        final engine = SessionEngine(mode(), random: const FixedRandom());
        engine.events.listen(events.add);
        engine.start();
        async.flushMicrotasks();

        engine.pause();

        final paused = events.where(
          (e) => e.event == ChainEvent.pausedRequested,
        );
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
        final engine = SessionEngine(mode(), random: const FixedRandom());
        engine.events.listen((e) => events.add(e.event));
        engine.start();
        async.flushMicrotasks();
        engine.pause();
        engine.resume();
        check(events).contains(ChainEvent.resumed);
        engine.endSession();
      });
    });

    test('pauseExpired emitted when maxPauseDuration exceeded', () {
      fakeAsync((async) {
        final events = <ChainEvent>[];
        final engine = SessionEngine(
          mode(),
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
        final engine = SessionEngine(mode(), random: const FixedRandom());
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
        final engine = SessionEngine(mode(), random: const FixedRandom());
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
        final engine = SessionEngine(mode(), random: const FixedRandom());
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
        final engine = SessionEngine(mode(), random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();
        engine.endSession();
        engine.events.listen((_) => count++);
        engine.notifyWrongPin(1);
        async.flushMicrotasks();
        check(count).equals(0);
      });
    });

    test('all 14 ChainEvent values are exercised', () {
      // Verify the enum has exactly the values we expect.
      const allEvents = ChainEvent.values;
      check(allEvents).contains(ChainEvent.sessionStarted);
      check(allEvents).contains(ChainEvent.stepStarted);
      check(allEvents).contains(ChainEvent.stepFired);
      check(allEvents).contains(ChainEvent.stepMissed);
      check(allEvents).contains(ChainEvent.stepDisarmed);
      check(allEvents).contains(ChainEvent.userDisarmed);
      check(allEvents).contains(ChainEvent.chainExhausted);
      check(allEvents).contains(ChainEvent.replaceWithDistress);
      check(allEvents).contains(ChainEvent.pausedRequested);
      check(allEvents).contains(ChainEvent.resumed);
      check(allEvents).contains(ChainEvent.pauseExpired);
      check(allEvents).contains(ChainEvent.stepExecutionFailed);
      check(allEvents).contains(ChainEvent.deceptiveOldPinShown);
      check(allEvents).contains(ChainEvent.sessionEnded);
      check(allEvents.length).equals(14);
    });
  });
}
