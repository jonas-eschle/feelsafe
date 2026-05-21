/// Supplemental engine tests covering uncovered lines in [SessionEngine]:
///
///   - line 123: `distressTriggerReason` getter.
///   - lines 675–676: `_endReasonForDistress` switch arms for
///     `TriggerReason.duressPin` and `TriggerReason.wrongPinExhausted`.
///   - line 677: `null` arm — when distress chain is triggered but
///     `_distressTriggerReason` is somehow null (defensive).
///
/// Note: lines 711, 741–742 are defensive dead-code arms
/// (`TimerPhase.holdWait` in `_onTimerFired` and `_scaledPhaseDuration`)
/// that cannot be reached from any current call site.
library;

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/models/chain_step.dart';

import '../../helpers/test_helpers.dart';

// Helper: one-step SMS distress chain that runs for ~2s.
ChainStep _distressSms() => smsStep(
  id: 'distress-sms',
  order: 0,
  durationSeconds: 2,
  gracePeriodSeconds: 0,
);

void main() {
  group('SessionEngine — distressTriggerReason getter (line 123)', () {
    test('distressTriggerReason is null before replaceWithDistressChain',
        () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [holdStep(durationSeconds: 10, gracePeriodSeconds: 5)],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        // Before distress chain: getter returns null.
        check(e.distressTriggerReason).isNull();
        e.dispose();
      });
    });

    test(
      'distressTriggerReason reflects TriggerReason.duressPin (line 675)',
      () {
        fakeAsync((async) {
          final e = SessionEngine(
            chainSteps: [
              holdStep(durationSeconds: 10, gracePeriodSeconds: 5),
            ],
            random: FixedRandom(),
          );
          e.start();
          async.flushMicrotasks();

          e.replaceWithDistressChain(
            [_distressSms()],
            triggerReason: TriggerReason.duressPin,
          );
          async.flushMicrotasks();

          // Getter (line 123) should reflect the duressPin reason.
          check(e.distressTriggerReason).equals(TriggerReason.duressPin);

          // Let the distress chain run to completion — this forces
          // _endReasonForDistress(TriggerReason.duressPin) at line 675.
          async.elapse(const Duration(seconds: 5));
          async.flushMicrotasks();

          check(e.state).isA<EngineEnded>();
          check((e.state as EngineEnded).reason).equals(EndReason.duressPin);
          e.dispose();
        });
      },
    );

    test(
      'distressTriggerReason reflects TriggerReason.wrongPinExhausted '
      '(line 676)',
      () {
        fakeAsync((async) {
          final e = SessionEngine(
            chainSteps: [
              holdStep(durationSeconds: 10, gracePeriodSeconds: 5),
            ],
            random: FixedRandom(),
          );
          e.start();
          async.flushMicrotasks();

          e.replaceWithDistressChain(
            [_distressSms()],
            triggerReason: TriggerReason.wrongPinExhausted,
          );
          async.flushMicrotasks();

          check(e.distressTriggerReason)
              .equals(TriggerReason.wrongPinExhausted);

          // Complete the distress chain to exercise line 676.
          async.elapse(const Duration(seconds: 5));
          async.flushMicrotasks();

          check(e.state).isA<EngineEnded>();
          check((e.state as EngineEnded).reason)
              .equals(EndReason.wrongPinExhausted);
          e.dispose();
        });
      },
    );
  });
}
