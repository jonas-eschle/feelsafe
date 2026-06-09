// Coverage for a few SessionEngine edges not hit by the larger suites:
// the empty-chain guards on the constructor + replaceWithDistressChain, the
// grace-retry re-execution path (retryCount > 0), and the holdWait
// phase-restart no-op on resume. Drives the REAL engine via fakeAsync.

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/engine/chain_event.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/engine/triggers.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/enums/pause_reason.dart';
import 'engine_test_helpers.dart';

void main() {
  group('SessionEngine — empty-chain guards', () {
    test('constructor rejects an empty chain', () {
      check(
        () => SessionEngine(
          chainSteps: const [],
          triggers: const Triggers(),
          allowDisarmAsDistress: true,
          random: const FixedRandom(),
        ),
      ).throws<ArgumentError>();
    });

    test('replaceWithDistressChain rejects an empty distress chain', () {
      final engine = buildEngine();
      engine.start();
      check(
        () => engine.replaceWithDistressChain(
          chain: const [],
          triggerReason: EndReason.hardwarePanic,
        ),
      ).throws<ArgumentError>();
      engine.endSession();
    });
  });

  group('SessionEngine — grace-retry re-execution', () {
    test('a step with retryCount > 0 re-executes after grace expiry '
        '(skipping the wait)', () {
      fakeAsync((async) {
        // Single step, retryCount = 1, short phases.
        final engine = buildEngine(
          sessionMode: mode(
            chainSteps: [step(durationSeconds: 5, retryCount: 1)],
          ),
        );
        final events = <ChainEvent>[];
        final sub = engine.events.listen((e) => events.add(e.event));
        engine.start();
        async.flushMicrotasks();

        // Elapse duration (5s) → grace (5s) → grace expiry retries the step.
        async.elapse(const Duration(seconds: 11));
        async.flushMicrotasks();

        // A second stepStarted means the retry re-executed the step.
        check(
          events.where((e) => e == ChainEvent.stepStarted).length,
        ).isGreaterOrEqual(2);
        sub.cancel();
        engine.endSession();
      });
    });
  });

  group('SessionEngine — holdWait pause/resume', () {
    test('pausing and resuming during a holdButton holdWait phase does not '
        'advance the chain (the holdWait phase-restart is a no-op)', () {
      fakeAsync((async) {
        final engine = buildEngine(
          sessionMode: mode(
            chainSteps: [
              step(type: ChainStepType.holdButton),
              step(type: ChainStepType.callEmergency),
            ],
          ),
        );
        engine.start();
        async.flushMicrotasks();
        // The first step is holdButton → engine sits in holdWait, no timer.
        check(engine.currentStepIndex).equals(0);

        // Pause + resume during holdWait. Resume restarts the current phase;
        // for holdWait that restart is a no-op (user-driven, no timer).
        engine.pause(reason: PauseReason.incomingCall);
        async.elapse(const Duration(seconds: 30));
        engine.resume();
        async.elapse(const Duration(seconds: 30));
        async.flushMicrotasks();

        // Still parked on the holdButton step — never auto-advanced.
        check(engine.currentStepIndex).equals(0);
        check(engine.isEnded).isFalse();
        engine.endSession();
      });
    });
  });
}
