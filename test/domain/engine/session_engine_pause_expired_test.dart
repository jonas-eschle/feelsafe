/// Tests for the `pauseExpired` event and auto-resume behaviour.
///
/// Asserts that when `maxPauseDuration` is set and a paused engine
/// exceeds that duration, the engine emits `pauseExpired` followed by
/// `sessionResumed`, and then continues running. Also verifies that
/// disposing the engine before the pause timer fires does NOT emit
/// `pauseExpired` (no ghost events after dispose).
library;

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/models/chain_event.dart';
import '../../helpers/test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Engine with a single SMS step (no jitter) and a configurable
/// maxPauseDuration.
SessionEngine _mk({Duration maxPauseDuration = const Duration(minutes: 5)}) =>
    SessionEngine(
      chainSteps: [
        smsStep(durationSeconds: 60, gracePeriodSeconds: 0).copyWith(
          waitSeconds: 0,
          randomize: 0.0,
        ),
      ],
      random: FixedRandom(),
      maxPauseDuration: maxPauseDuration,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('pauseExpired — basic emission', () {
    test(
        'emits sessionPaused, pauseExpired, sessionResumed in order '
        'when pause exceeds maxPauseDuration', () {
      fakeAsync((async) {
        final engine = _mk(maxPauseDuration: const Duration(minutes: 5));
        final events = <ChainEvent>[];
        engine.events.listen((e) => events.add(e.event));
        engine.start();
        async.flushMicrotasks();
        engine.pause();
        async.flushMicrotasks();

        // Advance time past the 5-minute limit.
        async.elapse(const Duration(minutes: 5));
        async.flushMicrotasks();

        check(events).contains(ChainEvent.sessionPaused);
        check(events).contains(ChainEvent.pauseExpired);
        check(events).contains(ChainEvent.sessionResumed);

        // Order must be paused < expired < resumed.
        final pausedIdx = events.indexOf(ChainEvent.sessionPaused);
        final expiredIdx = events.indexOf(ChainEvent.pauseExpired);
        final resumedIdx = events.indexOf(ChainEvent.sessionResumed);
        check(pausedIdx).isLessThan(expiredIdx);
        check(expiredIdx).isLessThan(resumedIdx);

        engine.dispose();
      });
    });

    test('engine transitions back to EngineRunning after pauseExpired', () {
      fakeAsync((async) {
        final engine = _mk(maxPauseDuration: const Duration(minutes: 5));
        engine.start();
        async.flushMicrotasks();
        engine.pause();
        async.flushMicrotasks();
        check(engine.state).isA<EnginePaused>();

        async.elapse(const Duration(minutes: 5));
        async.flushMicrotasks();

        check(engine.state).isA<EngineRunning>();
        engine.dispose();
      });
    });

    test('pauseExpired is not emitted before maxPauseDuration elapses', () {
      fakeAsync((async) {
        final engine = _mk(maxPauseDuration: const Duration(minutes: 5));
        final events = <ChainEvent>[];
        engine.events.listen((e) => events.add(e.event));
        engine.start();
        async.flushMicrotasks();
        engine.pause();
        async.flushMicrotasks();

        // Just under the threshold.
        async.elapse(const Duration(minutes: 4, seconds: 59));
        async.flushMicrotasks();
        check(events.contains(ChainEvent.pauseExpired)).isFalse();
        check(engine.state).isA<EnginePaused>();

        engine.dispose();
      });
    });
  });

  group('pauseExpired — dispose cancels the timer', () {
    test(
        'disposing before maxPauseDuration fires does NOT emit pauseExpired',
        () {
      fakeAsync((async) {
        final engine = _mk(maxPauseDuration: const Duration(minutes: 5));
        final events = <ChainEvent>[];
        engine.events.listen((e) => events.add(e.event));
        engine.start();
        async.flushMicrotasks();
        engine.pause();
        async.flushMicrotasks();

        // Dispose while still within the pause window.
        async.elapse(const Duration(minutes: 2));
        engine.dispose();

        // Advance past where pauseExpired would have fired.
        async.elapse(const Duration(minutes: 10));
        async.flushMicrotasks();

        check(events.contains(ChainEvent.pauseExpired)).isFalse();
      });
    });
  });

  group('pauseExpired — manual resume cancels pending timer', () {
    test(
        'manually resuming before maxPauseDuration fires prevents later '
        'pauseExpired emission', () {
      fakeAsync((async) {
        final engine = _mk(maxPauseDuration: const Duration(minutes: 5));
        final events = <ChainEvent>[];
        engine.events.listen((e) => events.add(e.event));
        engine.start();
        async.flushMicrotasks();
        engine.pause();
        async.flushMicrotasks();

        // Resume manually before expiry.
        async.elapse(const Duration(minutes: 1));
        engine.resume();
        async.flushMicrotasks();
        check(events.contains(ChainEvent.sessionResumed)).isTrue();

        // No extra pauseExpired should fire even after the original timeout.
        async.elapse(const Duration(minutes: 10));
        async.flushMicrotasks();
        final expiredCount =
            events.where((e) => e == ChainEvent.pauseExpired).length;
        check(expiredCount).equals(0);

        engine.dispose();
      });
    });
  });

  group('pauseExpired — endSession before expiry', () {
    test('endSession cancels the pause timer — no pauseExpired emitted', () {
      fakeAsync((async) {
        final engine = _mk(maxPauseDuration: const Duration(minutes: 5));
        final events = <ChainEvent>[];
        engine.events.listen((e) => events.add(e.event));
        engine.start();
        async.flushMicrotasks();
        engine.pause();
        async.flushMicrotasks();

        engine.endSession(reason: EndReason.userQuit);
        async.elapse(const Duration(minutes: 10));
        async.flushMicrotasks();

        check(events.contains(ChainEvent.pauseExpired)).isFalse();
        check(engine.state).isA<EngineEnded>();
        engine.dispose();
      });
    });
  });
}
