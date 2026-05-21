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
  group('State machine transitions', () {
    test('starts in EngineIdle', () {
      final engine = SessionEngine(mode(), random: const FixedRandom());
      check(engine.isEnded).isFalse();
      check(engine.isPaused).isFalse();
      check(engine.currentStepIndex).equals(-1);
      check(engine.currentStep).isNull();
    });

    test('start() transitions to EngineRunning', () {
      fakeAsync((async) {
        final engine = SessionEngine(mode(), random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();
        check(engine.currentStepIndex).equals(0);
        check(engine.isEnded).isFalse();
        check(engine.isPaused).isFalse();
        engine.endSession();
      });
    });

    test('start() throws on second call', () {
      fakeAsync((async) {
        final engine = SessionEngine(mode(), random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();
        check(engine.start).throws<StateError>();
        engine.endSession();
      });
    });

    test('endSession() transitions to EngineEnded', () {
      fakeAsync((async) {
        final engine = SessionEngine(mode(), random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();
        engine.endSession();
        check(engine.isEnded).isTrue();
      });
    });

    test('endSession() is idempotent', () {
      fakeAsync((async) {
        final engine = SessionEngine(mode(), random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();
        engine.endSession();
        check(engine.endSession).returnsNormally();
        check(engine.isEnded).isTrue();
      });
    });

    test('pause() transitions to EnginePaused', () {
      fakeAsync((async) {
        final engine = SessionEngine(mode(), random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();
        engine.pause();
        check(engine.isPaused).isTrue();
        engine.endSession();
      });
    });

    test('resume() transitions back to EngineRunning', () {
      fakeAsync((async) {
        final engine = SessionEngine(mode(), random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();
        engine.pause();
        check(engine.isPaused).isTrue();
        engine.resume();
        check(engine.isPaused).isFalse();
        check(engine.isEnded).isFalse();
        engine.endSession();
      });
    });

    test('disarm() resets to step 0', () {
      fakeAsync((async) {
        final m = mode(
          chainSteps: [
            step(
              type: ChainStepType.countdownWarning,
              durationSeconds: 1,
              gracePeriodSeconds: 0,
            ),
            step(
              type: ChainStepType.callEmergency,
              durationSeconds: 1,
              gracePeriodSeconds: 0,
            ),
          ],
        );
        final engine = SessionEngine(m, random: const FixedRandom());
        engine.start();
        // Step 0: duration=1s, grace=0s → advances to step 1 at t=1s.
        // Elapse 1.5s so we are at step 1 but haven't exhausted it yet.
        async.elapse(const Duration(milliseconds: 1500));
        check(engine.currentStepIndex).equals(1);
        engine.disarm();
        async.flushMicrotasks();
        check(engine.currentStepIndex).equals(0);
        engine.endSession();
      });
    });

    test('chain exhausted ends session with chainExhausted', () {
      fakeAsync((async) {
        final events = <ChainEventData>[];
        final m = mode(
          chainSteps: [step(durationSeconds: 1, gracePeriodSeconds: 1)],
        );
        final engine = SessionEngine(m, random: const FixedRandom());
        engine.events.listen(events.add);
        engine.start();
        async.elapse(const Duration(seconds: 5));
        check(engine.isEnded).isTrue();
        final ended = events.where((e) => e.event == ChainEvent.sessionEnded);
        check(ended).isNotEmpty();
        check(
          ended.first.metadata['reason'],
        ).equals(EndReason.chainExhausted.name);
      });
    });

    test('distress chain replaces main chain', () {
      fakeAsync((async) {
        final engine = SessionEngine(mode(), random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();
        engine.replaceWithDistressChain(
          chain: [step(type: ChainStepType.smsContact, durationSeconds: 1)],
          triggerReason: EndReason.hardwarePanic,
        );
        async.flushMicrotasks();
        check(engine.isDistressChain).isTrue();
        check(engine.currentStepIndex).equals(0);
        engine.endSession();
      });
    });

    test('pause() is no-op when not running', () {
      final engine = SessionEngine(mode(), random: const FixedRandom());
      // Idle state — should not throw.
      check(engine.pause).returnsNormally();
    });

    test('resume() is no-op when not paused', () {
      fakeAsync((async) {
        final engine = SessionEngine(mode(), random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();
        // Not paused — should not throw.
        check(engine.resume).returnsNormally();
        engine.endSession();
      });
    });

    test('pause() records PauseReason.incomingCall', () {
      fakeAsync((async) {
        final events = <ChainEventData>[];
        final engine = SessionEngine(mode(), random: const FixedRandom());
        engine.events.listen(events.add);
        engine.start();
        async.flushMicrotasks();
        engine.pause(reason: PauseReason.incomingCall);
        final paused = events.where(
          (e) => e.event == ChainEvent.pausedRequested,
        );
        check(paused).isNotEmpty();
        check(
          paused.first.metadata['reason'],
        ).equals(PauseReason.incomingCall.name);
        engine.endSession();
      });
    });

    test('no events emitted after endSession()', () {
      fakeAsync((async) {
        int count = 0;
        final engine = SessionEngine(mode(), random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();
        engine.endSession();
        engine.events.listen((_) => count++);
        // Try to trigger more events — should be no-op.
        engine.notifyWrongPin(1);
        async.flushMicrotasks();
        check(count).equals(0);
      });
    });

    test('disarm() is no-op when paused', () {
      fakeAsync((async) {
        final engine = SessionEngine(mode(), random: const FixedRandom());
        engine.start();
        async.flushMicrotasks();
        engine.pause();
        check(engine.isPaused).isTrue();
        // disarm during pause: no-op per spec.
        engine.disarm();
        check(engine.isPaused).isTrue(); // Still paused.
        engine.endSession();
      });
    });

    test('distress chain ignores second replaceWithDistressChain', () {
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
        // Second call should be no-op (A4).
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
