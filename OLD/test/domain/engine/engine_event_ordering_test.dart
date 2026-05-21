/// Event ordering and stream correctness tests.
///
/// Verifies the exact sequence of events emitted by [SessionEngine]
/// for various scenarios, stepIndex/stepType on events, metadata
/// contents, and stream cleanup on dispose.
library;

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/models/chain_event.dart';
import '../../helpers/test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

SessionEngine _mk(List<Object?> stepList, {bool isSimulation = false}) =>
    SessionEngine(
      chainSteps: stepList.cast(),
      isSimulation: isSimulation,
      random: FixedRandom(),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // sessionStarted always first
  // -------------------------------------------------------------------------
  group('sessionStarted first', () {
    test('sessionStarted is the very first event on start()', () {
      fakeAsync((async) {
        final e = _mk([smsStep(durationSeconds: 30)]);
        final evs = <ChainEvent>[];
        e.events.listen((ev) => evs.add(ev.event));
        e.start();
        async.flushMicrotasks();
        check(evs.first).equals(ChainEvent.sessionStarted);
        e.dispose();
      });
    });

    test('sessionStarted precedes all stepStarted events', () {
      fakeAsync((async) {
        final e = _mk([
          smsStep(durationSeconds: 1, gracePeriodSeconds: 0),
          smsStep(order: 1, durationSeconds: 1, gracePeriodSeconds: 0),
        ]);
        final evs = <ChainEvent>[];
        e.events.listen((ev) => evs.add(ev.event));
        e.start();
        async.elapse(const Duration(seconds: 10));
        async.flushMicrotasks();
        final startedIdx = evs.indexOf(ChainEvent.sessionStarted);
        final stepStartedIdx = evs.indexOf(ChainEvent.stepStarted);
        check(startedIdx).equals(0);
        check(stepStartedIdx).isGreaterThan(startedIdx);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // sessionEnded always last
  // -------------------------------------------------------------------------
  group('sessionEnded last', () {
    test('sessionEnded is the last event', () {
      fakeAsync((async) {
        final e = _mk([smsStep(durationSeconds: 1, gracePeriodSeconds: 0)]);
        final evs = <ChainEvent>[];
        e.events.listen((ev) => evs.add(ev.event));
        e.start();
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        check(evs.last).equals(ChainEvent.sessionEnded);
        e.dispose();
      });
    });

    test('sessionEnded is last even after distressCompleted', () {
      fakeAsync((async) {
        final e = _mk([smsStep(durationSeconds: 30)]);
        final evs = <ChainEvent>[];
        e.events.listen((ev) => evs.add(ev.event));
        e.start();
        async.flushMicrotasks();
        e.replaceWithDistressChain([
          smsStep(id: 'ds', durationSeconds: 1, gracePeriodSeconds: 0),
        ], triggerReason: TriggerReason.hardwarePanic);
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        check(evs.last).equals(ChainEvent.sessionEnded);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Event ordering for single-step chain
  // -------------------------------------------------------------------------
  group('single smsStep: event sequence', () {
    test(
      'smsStep(dur=5, grace=0) → [started,stepStarted,stepAdvancing,ended]',
      () {
        fakeAsync((async) {
          final e = _mk([smsStep(durationSeconds: 5, gracePeriodSeconds: 0)]);
          final evs = <ChainEvent>[];
          e.events.listen((ev) => evs.add(ev.event));
          e.start();
          async.elapse(const Duration(seconds: 6));
          async.flushMicrotasks();
          // Verify the subsequence: started < stepStarted < stepAdvancing < ended.
          final si = evs.indexOf(ChainEvent.sessionStarted);
          final ssi = evs.indexOf(ChainEvent.stepStarted);
          final sai = evs.indexOf(ChainEvent.stepAdvancing);
          final sei = evs.indexOf(ChainEvent.sessionEnded);
          check(si).isGreaterOrEqual(0);
          check(ssi).isGreaterThan(si);
          check(sai).isGreaterThan(ssi);
          check(sei).isGreaterThan(sai);
          e.dispose();
        });
      },
    );

    test('graceExpired precedes stepAdvancing', () {
      fakeAsync((async) {
        final e = _mk([
          smsStep(durationSeconds: 2, gracePeriodSeconds: 2),
          smsStep(order: 1, durationSeconds: 30),
        ]);
        final evs = <ChainEvent>[];
        e.events.listen((ev) => evs.add(ev.event));
        e.start();
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        final geIdx = evs.indexOf(ChainEvent.graceExpired);
        final saIdx = evs.indexOf(ChainEvent.stepAdvancing);
        check(geIdx).isGreaterOrEqual(0);
        check(saIdx).isGreaterThan(geIdx);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // stepIndex correctness on events
  // -------------------------------------------------------------------------
  group('stepIndex on events', () {
    test('stepStarted events carry correct stepIndex in order', () {
      fakeAsync((async) {
        final e = _mk([
          smsStep(durationSeconds: 1, gracePeriodSeconds: 0),
          smsStep(order: 1, durationSeconds: 1, gracePeriodSeconds: 0),
          smsStep(order: 2, durationSeconds: 1, gracePeriodSeconds: 0),
        ]);
        final indices = <int>[];
        e.events.listen((ev) {
          if (ev.event == ChainEvent.stepStarted && ev.stepIndex != null) {
            indices.add(ev.stepIndex!);
          }
        });
        e.start();
        async.elapse(const Duration(seconds: 10));
        async.flushMicrotasks();
        check(indices).deepEquals([0, 1, 2]);
        e.dispose();
      });
    });

    test('graceExpired carries correct stepIndex', () {
      fakeAsync((async) {
        final e = _mk([smsStep(durationSeconds: 2, gracePeriodSeconds: 1)]);
        int? graceIdx;
        e.events.listen((ev) {
          if (ev.event == ChainEvent.graceExpired) graceIdx = ev.stepIndex;
        });
        e.start();
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        check(graceIdx).equals(0);
        e.dispose();
      });
    });

    test('stepAdvancing carries fromIndex (current step)', () {
      fakeAsync((async) {
        final e = _mk([
          smsStep(durationSeconds: 1, gracePeriodSeconds: 0),
          smsStep(order: 1, durationSeconds: 30),
        ]);
        int? advIdx;
        e.events.listen((ev) {
          if (ev.event == ChainEvent.stepAdvancing) advIdx = ev.stepIndex;
        });
        e.start();
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        check(advIdx).equals(0);
        e.dispose();
      });
    });

    test('userDisarmed carries last stepIndex when stopped mid-step', () {
      // Q1: disarm now emits ChainEvent.userDisarmed (not
      // sessionEnded). The event still carries the stepIndex of
      // the step the user was on at the time of the disarm.
      fakeAsync((async) {
        final e = _mk([
          smsStep(durationSeconds: 30),
          smsStep(order: 1, durationSeconds: 30),
        ]);
        int? endIdx;
        e.events.listen((ev) {
          if (ev.event == ChainEvent.userDisarmed) endIdx = ev.stepIndex;
        });
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 5));
        e.disarm();
        check(endIdx).equals(0);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // stepType on events
  // -------------------------------------------------------------------------
  group('stepType on events', () {
    test('stepStarted carries correct stepType', () {
      fakeAsync((async) {
        final e = _mk([
          step(type: ChainStepType.countdownWarning, durationSeconds: 5),
        ]);
        ChainStepType? captured;
        e.events.listen((ev) {
          if (ev.event == ChainEvent.stepStarted) captured = ev.stepType;
        });
        e.start();
        async.flushMicrotasks();
        check(captured).equals(ChainStepType.countdownWarning);
        e.dispose();
      });
    });

    test('sessionPaused carries stepType', () {
      fakeAsync((async) {
        final e = _mk([smsStep(durationSeconds: 30)]);
        ChainStepType? pt;
        e.events.listen((ev) {
          if (ev.event == ChainEvent.sessionPaused) pt = ev.stepType;
        });
        e.start();
        async.flushMicrotasks();
        e.pause();
        check(pt).equals(ChainStepType.smsContact);
        e.dispose();
      });
    });

    test('sessionResumed carries stepType', () {
      fakeAsync((async) {
        final e = _mk([smsStep(durationSeconds: 30)]);
        ChainStepType? rt;
        e.events.listen((ev) {
          if (ev.event == ChainEvent.sessionResumed) rt = ev.stepType;
        });
        e.start();
        async.flushMicrotasks();
        e.pause();
        e.resume();
        check(rt).equals(ChainStepType.smsContact);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Metadata contents
  // -------------------------------------------------------------------------
  group('event metadata', () {
    test('sessionPaused metadata.reason = userRequested', () {
      fakeAsync((async) {
        final e = _mk([smsStep(durationSeconds: 30)]);
        final evs = <ChainEventData>[];
        e.events.listen(evs.add);
        e.start();
        async.flushMicrotasks();
        e.pause();
        final ev = evs.firstWhere((ev) => ev.event == ChainEvent.sessionPaused);
        check(ev.metadata['reason']).equals('userRequested');
        e.dispose();
      });
    });

    test('disarm emits userDisarmed (not sessionEnded)', () {
      // Q1: disarm now emits ChainEvent.userDisarmed and resets the
      // chain to step 0. There is no `disarm` EndReason any more —
      // the only sessionEnded event you would see from a disarm
      // path comes from a follow-up endSession call.
      fakeAsync((async) {
        final e = _mk([smsStep(durationSeconds: 30)]);
        final evs = <ChainEventData>[];
        e.events.listen(evs.add);
        e.start();
        async.flushMicrotasks();
        e.disarm();
        async.flushMicrotasks();
        check(evs.any((ev) => ev.event == ChainEvent.userDisarmed)).isTrue();
        check(evs.any((ev) => ev.event == ChainEvent.sessionEnded)).isFalse();
        e.dispose();
      });
    });

    test('graceExpired metadata.missCount increments per retry', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            step(
              type: ChainStepType.smsContact,
              durationSeconds: 1,
              gracePeriodSeconds: 1,
              retryCount: 2,
            ),
          ],
          random: FixedRandom(),
        );
        final misses = <int>[];
        e.events.listen((ev) {
          if (ev.event == ChainEvent.graceExpired) {
            misses.add(ev.metadata['missCount'] as int);
          }
        });
        e.start();
        async.elapse(const Duration(seconds: 10));
        async.flushMicrotasks();
        check(misses).deepEquals([1, 2, 3]);
        e.dispose();
      });
    });

    test('stepAdvancing metadata.nextStepType present when not last', () {
      fakeAsync((async) {
        final e = _mk([
          smsStep(durationSeconds: 1, gracePeriodSeconds: 0),
          step(type: ChainStepType.loudAlarm, order: 1, durationSeconds: 30),
        ]);
        final evs = <ChainEventData>[];
        e.events.listen(evs.add);
        e.start();
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        final adv = evs.firstWhere(
          (ev) => ev.event == ChainEvent.stepAdvancing,
        );
        check(adv.metadata['nextStepType']).equals('loudAlarm');
        e.dispose();
      });
    });

    test('reminderFired metadata.missCount = 0 on first fire', () {
      fakeAsync((async) {
        final e = _mk([
          step(
            type: ChainStepType.disguisedReminder,
            durationSeconds: 5,
            gracePeriodSeconds: 5,
          ),
        ]);
        final evs = <ChainEventData>[];
        e.events.listen(evs.add);
        e.start();
        async.flushMicrotasks();
        final rf = evs.firstWhere((ev) => ev.event == ChainEvent.reminderFired);
        check(rf.metadata['missCount']).equals(0);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Broadcast stream: multiple listeners
  // -------------------------------------------------------------------------
  group('broadcast stream', () {
    test('two listeners receive identical event sequences', () {
      fakeAsync((async) {
        final e = _mk([smsStep(durationSeconds: 2, gracePeriodSeconds: 0)]);
        final a = <ChainEvent>[];
        final b = <ChainEvent>[];
        e.events.listen((ev) => a.add(ev.event));
        e.events.listen((ev) => b.add(ev.event));
        e.start();
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        check(a).deepEquals(b);
        e.dispose();
      });
    });

    test('listener added after start receives subsequent events', () {
      fakeAsync((async) {
        final e = _mk([smsStep(durationSeconds: 5, gracePeriodSeconds: 0)]);
        e.start();
        async.flushMicrotasks();
        final late = <ChainEvent>[];
        e.events.listen((ev) => late.add(ev.event));
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        // Should have received stepAdvancing and sessionEnded.
        check(late.contains(ChainEvent.sessionEnded)).isTrue();
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // No events after dispose
  // -------------------------------------------------------------------------
  group('no events after dispose', () {
    test('events stream is closed after dispose', () {
      fakeAsync((async) {
        final e = _mk([smsStep(durationSeconds: 30)]);
        e.start();
        async.flushMicrotasks();
        var afterDispose = 0;
        e.dispose();
        // Listen after dispose — stream is closed, no events expected.
        e.events.listen((_) => afterDispose++).onDone(() {});
        async.elapse(const Duration(seconds: 60));
        check(afterDispose).equals(0);
      });
    });

    test('engine emits no events after endSession', () {
      fakeAsync((async) {
        final e = _mk([smsStep(durationSeconds: 30)]);
        e.start();
        async.flushMicrotasks();
        e.endSession(reason: EndReason.userQuit);
        var after = 0;
        e.events.listen((_) => after++);
        async.elapse(const Duration(seconds: 60));
        check(after).equals(0);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Synchronous stream: events fired synchronously per sync:true
  // -------------------------------------------------------------------------
  group('synchronous event delivery', () {
    test('events present before flushMicrotasks', () {
      fakeAsync((async) {
        final e = _mk([smsStep(durationSeconds: 30)]);
        final evs = <ChainEvent>[];
        e.events.listen((ev) => evs.add(ev.event));
        e.start();
        // No flush — sync:true means events delivered inline.
        check(evs).contains(ChainEvent.sessionStarted);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Double start
  // -------------------------------------------------------------------------
  group('double start throws', () {
    test('second start throws StateError', () {
      final e = _mk([holdStep()]);
      e.start();
      check(e.start).throws<StateError>();
      e.dispose();
    });
  });
}
