/// Distress-chain replacement tests — D-SAFETY-17.
library;

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/models/chain_event.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import '../../helpers/test_helpers.dart';

ChainStep _mainHold() => holdStep(durationSeconds: 20, gracePeriodSeconds: 5);
ChainStep _mainSms() =>
    smsStep(order: 1, durationSeconds: 5, gracePeriodSeconds: 0);
ChainStep _distressSms({int order = 0}) => smsStep(
  id: 'distress-sms-$order',
  order: order,
  durationSeconds: 2,
  gracePeriodSeconds: 0,
);
ChainStep _distressAlarm({int order = 1}) => step(
  id: 'distress-alarm-$order',
  type: ChainStepType.loudAlarm,
  order: order,
  durationSeconds: 1,
  gracePeriodSeconds: 0,
);

void main() {
  group('replaceWithDistressChain basic', () {
    test('swaps chain and emits distressTriggered', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [_mainHold(), _mainSms()],
          random: FixedRandom(),
        );
        final events = <ChainEvent>[];
        e.events.listen((ev) => events.add(ev.event));
        e.start();
        async.flushMicrotasks();
        e.replaceWithDistressChain([_distressSms()]);
        async.flushMicrotasks();
        check(events).contains(ChainEvent.distressTriggered);
        check(e.isDistressChain).isTrue();
        check(e.steps.length).equals(1);
        e.dispose();
      });
    });

    test('starts from step 0 of the distress chain', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [_mainHold(), _mainSms()],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        e.replaceWithDistressChain([_distressSms(), _distressAlarm()]);
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.stepIndex).equals(0);
        check(s.isHolding).isFalse();
        check(s.missCount).equals(0);
        e.dispose();
      });
    });

    test('distress chain completion ends with chainExhausted', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [_mainHold(), _mainSms()],
          random: FixedRandom(),
        );
        final events = <ChainEvent>[];
        e.events.listen((ev) => events.add(ev.event));
        e.start();
        async.flushMicrotasks();
        e.replaceWithDistressChain([_distressSms(order: 0)]);
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        check((e.state as EngineEnded).reason).equals(EndReason.chainExhausted);
        check(events).contains(ChainEvent.distressCompleted);
        e.dispose();
      });
    });

    test('distressCompleted precedes sessionEnded', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [_mainHold()],
          random: FixedRandom(),
        );
        final names = <ChainEvent>[];
        e.events.listen((ev) => names.add(ev.event));
        e.start();
        async.flushMicrotasks();
        e.replaceWithDistressChain([_distressSms()]);
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        final dc = names.indexOf(ChainEvent.distressCompleted);
        final se = names.indexOf(ChainEvent.sessionEnded);
        check(dc).isGreaterOrEqual(0);
        check(se).isGreaterThan(dc);
        e.dispose();
      });
    });
  });

  group('distress chain non-interruption (D-SAFETY-17)', () {
    test('replaceWithDistressChain while already distress = no-op', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [_mainHold()],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        e.replaceWithDistressChain([_distressSms(), _distressAlarm()]);
        async.flushMicrotasks();
        final firstSteps = e.steps;
        e.replaceWithDistressChain([
          _distressSms(order: 5).copyWith(durationSeconds: 99),
        ]);
        check(e.steps).deepEquals(firstSteps);
        e.dispose();
      });
    });

    test('isDistressChain stays true across re-entry attempts', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [_mainHold()],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        e.replaceWithDistressChain([_distressSms()]);
        async.flushMicrotasks();
        check(e.isDistressChain).isTrue();
        e.replaceWithDistressChain([_distressAlarm()]);
        check(e.isDistressChain).isTrue();
        e.dispose();
      });
    });
  });

  group('distress chain validation', () {
    test('empty distress chain throws ArgumentError', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [_mainHold()],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        check(
          () => e.replaceWithDistressChain(const []),
        ).throws<ArgumentError>();
        e.dispose();
      });
    });

    test('replace after end is a no-op', () {
      final e = SessionEngine(chainSteps: [_mainHold()], random: FixedRandom());
      e.endSession(reason: EndReason.userQuit);
      e.replaceWithDistressChain([_distressSms()]);
      check(e.isDistressChain).isFalse();
      e.dispose();
    });

    test('replace before start also works (engine was Idle)', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [_mainHold()],
          random: FixedRandom(),
        );
        e.replaceWithDistressChain([_distressSms()]);
        async.flushMicrotasks();
        check(e.isDistressChain).isTrue();
        check(e.state).isA<EngineRunning>();
        e.dispose();
      });
    });
  });

  group('distress chain cancels main timers', () {
    test('main timer does not fire after replacement', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            smsStep(durationSeconds: 60, gracePeriodSeconds: 60),
            smsStep(order: 1, durationSeconds: 1, gracePeriodSeconds: 0),
          ],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        e.replaceWithDistressChain([_distressSms()]);
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        // Chain has advanced only through the distress chain.
        check(e.state).isA<EngineEnded>();
        e.dispose();
      });
    });
  });

  group('distress chain stepStarted events', () {
    test('stepStarted fires for every distress step', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [_mainHold()],
          random: FixedRandom(),
        );
        final stepIndices = <int?>[];
        e.events.listen((ev) {
          if (ev.event == ChainEvent.stepStarted) {
            stepIndices.add(ev.stepIndex);
          }
        });
        e.start();
        async.flushMicrotasks();
        e.replaceWithDistressChain([_distressSms(), _distressAlarm()]);
        async.elapse(const Duration(seconds: 10));
        async.flushMicrotasks();
        // One for the main chain's holdStep + two for distress steps.
        check(stepIndices).contains(0);
        check(stepIndices).contains(1);
        e.dispose();
      });
    });
  });
}
