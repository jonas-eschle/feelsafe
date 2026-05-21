import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guardianangela/domain/engine/chain_event.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';

import 'engine_test_helpers.dart';

void main() {
  group('Distress chain replacement finality', () {
    test('replaceWithDistressChain stops main chain', () {
      fakeAsync((async) {
        final m = mode(
          chainSteps: [
            step(durationSeconds: 100, gracePeriodSeconds: 100),
            step(type: ChainStepType.callEmergency),
          ],
        );
        final engine = SessionEngine(m, random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();
        check(engine.currentStepIndex).equals(0);

        engine.replaceWithDistressChain(
          chain: [step(type: ChainStepType.smsContact, durationSeconds: 2)],
          triggerReason: EndReason.hardwarePanic,
        );
        async.flushMicrotasks();

        // Now running distress chain step 0 (smsContact).
        check(engine.isDistressChain).isTrue();
        check(engine.currentStepIndex).equals(0);
        check(engine.currentStep?.type).equals(ChainStepType.smsContact);

        engine.endSession();
      });
    });

    test('distress chain runs from step 0', () {
      fakeAsync((async) {
        final distressChain = [
          step(type: ChainStepType.smsContact, durationSeconds: 2),
          step(type: ChainStepType.callEmergency, durationSeconds: 1),
        ];
        final engine = SessionEngine(mode(), random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();

        engine.replaceWithDistressChain(
          chain: distressChain,
          triggerReason: EndReason.duressPin,
        );
        async.flushMicrotasks();
        check(engine.currentStepIndex).equals(0);

        engine.endSession();
      });
    });

    test('distress chain ends with hardwarePanic EndReason', () {
      fakeAsync((async) {
        final events = <ChainEventData>[];
        final m = mode(chainSteps: [step(durationSeconds: 100)]);
        final engine = SessionEngine(m, random: const FixedRandom());
        engine.events.listen(events.add);
        engine.start();
        async.flushMicrotasks();

        engine.replaceWithDistressChain(
          chain: [
            step(
              type: ChainStepType.smsContact,
              durationSeconds: 1,
              gracePeriodSeconds: 0,
            ),
          ],
          triggerReason: EndReason.hardwarePanic,
        );

        // Run distress chain to exhaustion.
        async.elapse(const Duration(seconds: 5));
        check(engine.isEnded).isTrue();

        final ended = events.where((e) => e.event == ChainEvent.sessionEnded);
        check(ended).isNotEmpty();
        check(
          ended.first.metadata['reason'],
        ).equals(EndReason.hardwarePanic.name);
      });
    });

    test('distress chain ends with duressPin EndReason', () {
      fakeAsync((async) {
        final events = <ChainEventData>[];
        final engine = SessionEngine(mode(), random: const FixedRandom());
        engine.events.listen(events.add);
        engine.start();
        async.flushMicrotasks();

        engine.replaceWithDistressChain(
          chain: [
            step(
              type: ChainStepType.smsContact,
              durationSeconds: 1,
              gracePeriodSeconds: 0,
            ),
          ],
          triggerReason: EndReason.duressPin,
        );

        async.elapse(const Duration(seconds: 5));
        check(engine.isEnded).isTrue();

        final ended = events.where((e) => e.event == ChainEvent.sessionEnded);
        check(ended.first.metadata['reason']).equals(EndReason.duressPin.name);
      });
    });

    test('distress chain ends with wrongPinExhausted EndReason', () {
      fakeAsync((async) {
        final events = <ChainEventData>[];
        final engine = SessionEngine(mode(), random: const FixedRandom());
        engine.events.listen(events.add);
        engine.start();
        async.flushMicrotasks();

        engine.replaceWithDistressChain(
          chain: [
            step(
              type: ChainStepType.smsContact,
              durationSeconds: 1,
              gracePeriodSeconds: 0,
            ),
          ],
          triggerReason: EndReason.wrongPinExhausted,
        );

        async.elapse(const Duration(seconds: 5));
        check(engine.isEnded).isTrue();

        final ended = events.where((e) => e.event == ChainEvent.sessionEnded);
        check(
          ended.first.metadata['reason'],
        ).equals(EndReason.wrongPinExhausted.name);
      });
    });

    test('main chain steps gone after distress replacement', () {
      fakeAsync((async) {
        final mainStep0 = step(durationSeconds: 100);
        final distressStep = step(
          type: ChainStepType.smsContact,
          durationSeconds: 1,
        );
        final m = mode(chainSteps: [mainStep0]);
        final engine = SessionEngine(m, random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();

        engine.replaceWithDistressChain(
          chain: [distressStep],
          triggerReason: EndReason.hardwarePanic,
        );
        async.flushMicrotasks();

        // Active step is now the distress step.
        check(engine.currentStep?.type).equals(ChainStepType.smsContact);

        engine.endSession();
      });
    });

    test('replaceWithDistressChain emits replaceWithDistress event', () {
      fakeAsync((async) {
        final events = <ChainEventData>[];
        final engine = SessionEngine(mode(), random: const FixedRandom());
        engine.events.listen(events.add);
        engine.start();
        async.flushMicrotasks();

        engine.replaceWithDistressChain(
          chain: [step()],
          triggerReason: EndReason.hardwarePanic,
        );

        final distressEvent = events.where(
          (e) => e.event == ChainEvent.replaceWithDistress,
        );
        check(distressEvent).isNotEmpty();
        check(
          distressEvent.first.metadata['triggerReason'],
        ).equals(EndReason.hardwarePanic.name);

        engine.endSession();
      });
    });

    test('no return to main chain after distress replacement', () {
      fakeAsync((async) {
        final engine = SessionEngine(mode(), random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();

        engine.replaceWithDistressChain(
          chain: [
            step(
              type: ChainStepType.smsContact,
              durationSeconds: 2,
              gracePeriodSeconds: 0,
            ),
          ],
          triggerReason: EndReason.hardwarePanic,
        );
        async.flushMicrotasks();

        // distress chain, step 0 is smsContact.
        check(engine.currentStep?.type).equals(ChainStepType.smsContact);

        // Even after running distress step, no main chain steps appear.
        async.elapse(const Duration(seconds: 5));
        check(engine.isEnded).isTrue();

        // Session ended with hardwarePanic, not chainExhausted.
        // (Chain exhaustion of distress chain uses the trigger reason.)
        engine.endSession(); // No-op after isEnded.
      });
    });

    test(
      'replaceWithDistressChain ignored when engine is ended (A4-adjacent)',
      () {
        fakeAsync((async) {
          final engine = SessionEngine(mode(), random: const FixedRandom());
          engine.start();
          async.flushMicrotasks();
          engine.endSession();
          // Should not throw.
          check(
            () => engine.replaceWithDistressChain(
              chain: [step()],
              triggerReason: EndReason.hardwarePanic,
            ),
          ).returnsNormally();
          check(engine.isEnded).isTrue();
        });
      },
    );

    test('second replaceWithDistressChain is no-op (A4)', () {
      fakeAsync((async) {
        int distressCount = 0;
        final engine = SessionEngine(mode(), random: const FixedRandom());
        engine.events.listen((e) {
          if (e.event == ChainEvent.replaceWithDistress) {
            distressCount++;
          }
        });
        engine.start();
        async.flushMicrotasks();

        engine.replaceWithDistressChain(
          chain: [step()],
          triggerReason: EndReason.hardwarePanic,
        );
        engine.replaceWithDistressChain(
          chain: [step()],
          triggerReason: EndReason.duressPin,
        );
        check(distressCount).equals(1);

        engine.endSession();
      });
    });
  });
}
