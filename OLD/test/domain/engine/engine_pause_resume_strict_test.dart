/// Strict pause/resume tests — exact remaining preservation,
/// pause-expiry auto-end, pauseAllowed=false, and long-duration pauses.
///
/// These assert SPEC-CORRECT behaviour; failures indicate real bugs.
library;

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/engine/timer_phase.dart';
import 'package:guardianangela/domain/models/chain_event.dart';
import '../../helpers/test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Engine with a 60-second-wait, 30-second-duration, 10-second-grace step.
SessionEngine _mk({int wait = 60, int dur = 30, int grace = 10}) =>
    SessionEngine(
      chainSteps: [
        smsStep(
          durationSeconds: dur,
          gracePeriodSeconds: grace,
        ).copyWith(waitSeconds: wait, randomize: 0.0),
      ],
      random: FixedRandom(),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Exact remaining preservation
  // -------------------------------------------------------------------------
  group('exact remaining preservation on pause', () {
    test('pause after 1s in 60s wait: remaining = 59s exactly', () {
      fakeAsync((async) {
        final e = _mk();
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1));
        e.pause();
        final p = e.state as EnginePaused;
        check(p.snapshot.remaining).equals(const Duration(seconds: 59));
        e.dispose();
      });
    });

    test('pause after 1ms in 60s wait: remaining = 59999ms', () {
      fakeAsync((async) {
        final e = _mk();
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(milliseconds: 1));
        e.pause();
        final p = e.state as EnginePaused;
        check(p.snapshot.remaining).equals(const Duration(milliseconds: 59999));
        e.dispose();
      });
    });

    test('pause after exactly 0s (no elapsed): remaining = full wait', () {
      fakeAsync((async) {
        final e = _mk(wait: 60, dur: 30);
        e.start();
        async.flushMicrotasks();
        e.pause();
        final p = e.state as EnginePaused;
        check(p.snapshot.remaining).equals(const Duration(seconds: 60));
        e.dispose();
      });
    });

    test('pause in duration phase preserves exact duration remaining', () {
      fakeAsync((async) {
        final e = _mk(wait: 0, dur: 60);
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 7));
        e.pause();
        final p = e.state as EnginePaused;
        check(p.snapshot.phase).equals(TimerPhase.duration);
        check(p.snapshot.remaining).equals(const Duration(seconds: 53));
        e.dispose();
      });
    });

    test('pause in grace phase preserves exact grace remaining', () {
      fakeAsync((async) {
        final e = _mk(wait: 0, dur: 10, grace: 20);
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 10)); // dur → grace.
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 3)); // 3s into grace.
        e.pause();
        final p = e.state as EnginePaused;
        check(p.snapshot.phase).equals(TimerPhase.grace);
        check(p.snapshot.remaining).equals(const Duration(seconds: 17));
        e.dispose();
      });
    });

    test('resume from pause fires timer from exact remaining', () {
      fakeAsync((async) {
        final e = _mk(wait: 0, dur: 20, grace: 0);
        e.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 5));
        e.pause();
        // 15s should remain.
        async.elapse(const Duration(hours: 1)); // paused — no advance.
        e.resume();
        // Elapse only 14s → not ended yet.
        async.elapse(const Duration(seconds: 14));
        async.flushMicrotasks();
        check(e.state).isA<EngineRunning>();
        // Elapse the final 1s → ends.
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Long-duration pauses: 1s, 60s, 1ms, 1h
  // -------------------------------------------------------------------------
  group('pause duration does not affect remaining after resume', () {
    for (final pauseDur in [
      const Duration(seconds: 1),
      const Duration(seconds: 60),
      const Duration(milliseconds: 1),
      const Duration(hours: 1),
    ]) {
      test(
        'pause for ${pauseDur.inMicroseconds}µs still resumes correctly',
        () {
          fakeAsync((async) {
            final e = _mk(wait: 0, dur: 60, grace: 0);
            e.start();
            async.flushMicrotasks();
            async.elapse(const Duration(seconds: 10));
            e.pause();
            final remaining = (e.state as EnginePaused).snapshot.remaining;
            async.elapse(pauseDur);
            e.resume();
            final s = e.state as EngineRunning;
            check(s.remaining).equals(remaining);
            e.dispose();
          });
        },
      );
    }
  });

  // -------------------------------------------------------------------------
  // Pause during various step types
  // -------------------------------------------------------------------------
  group('pause in holdWait phase', () {
    test('pause from holdWait preserves phase and does not start a timer', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [holdStep(durationSeconds: 30)],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        e.pause();
        final p = e.state as EnginePaused;
        check(p.snapshot.phase).equals(TimerPhase.holdWait);
        e.resume();
        final r = e.state as EngineRunning;
        check(r.phase).equals(TimerPhase.holdWait);
        // No timer running — no advance after 10s.
        async.elapse(const Duration(seconds: 10));
        check((e.state as EngineRunning).phase).equals(TimerPhase.holdWait);
        e.dispose();
      });
    });
  });

  group('pause in sensitivity phase', () {
    test('pause during sensitivity preserves exact ms remaining', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [holdStep(releaseSensitivity: 2.0, durationSeconds: 10)],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.holdRelease();
        // 2s sensitivity window; pause after 500ms.
        async.elapse(const Duration(milliseconds: 500));
        e.pause();
        final p = e.state as EnginePaused;
        check(p.snapshot.phase).equals(TimerPhase.sensitivity);
        check(p.snapshot.remaining).equals(const Duration(milliseconds: 1500));
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Multiple pause/resume cycles
  // -------------------------------------------------------------------------
  group('multiple pause/resume cycles', () {
    test('3 pause/resume cycles accumulate only active elapsed time', () {
      fakeAsync((async) {
        final e = _mk(wait: 0, dur: 60, grace: 0);
        e.start();
        async.flushMicrotasks();
        // Cycle 1: elapse 10s, pause 100s, resume.
        async.elapse(const Duration(seconds: 10));
        e.pause();
        async.elapse(const Duration(seconds: 100));
        e.resume();
        // Cycle 2: elapse 10s, pause 100s, resume.
        async.elapse(const Duration(seconds: 10));
        e.pause();
        async.elapse(const Duration(seconds: 100));
        e.resume();
        // Cycle 3: elapse 10s, pause 100s, resume.
        async.elapse(const Duration(seconds: 10));
        e.pause();
        async.elapse(const Duration(seconds: 100));
        e.resume();
        // Total active elapsed: 30s. Remaining: 30s.
        final s = e.state as EngineRunning;
        check(s.remaining).equals(const Duration(seconds: 30));
        e.dispose();
      });
    });

    test('sessionResumed event emitted for each resume', () {
      fakeAsync((async) {
        final e = _mk();
        var resumeCount = 0;
        e.events.listen((ev) {
          if (ev.event == ChainEvent.sessionResumed) resumeCount++;
        });
        e.start();
        async.flushMicrotasks();
        e.pause();
        e.resume();
        e.pause();
        e.resume();
        e.pause();
        e.resume();
        check(resumeCount).equals(3);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Pause is no-op from wrong states
  // -------------------------------------------------------------------------
  group('pause no-op states', () {
    test('pause from Idle is a no-op', () {
      final e = _mk();
      e.pause();
      check(e.state).isA<EngineIdle>();
      e.dispose();
    });

    test('pause from Ended is a no-op', () {
      final e = _mk();
      e.endSession(reason: EndReason.userQuit);
      e.pause();
      check(e.state).isA<EngineEnded>();
      e.dispose();
    });

    test('pause from already-Paused returns without change', () {
      fakeAsync((async) {
        final e = _mk();
        e.start();
        async.flushMicrotasks();
        e.pause();
        final snap1 = (e.state as EnginePaused).snapshot;
        e.pause();
        final snap2 = (e.state as EnginePaused).snapshot;
        check(snap1.remaining).equals(snap2.remaining);
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Resume no-op states
  // -------------------------------------------------------------------------
  group('resume no-op states', () {
    test('resume from Idle is a no-op', () {
      final e = _mk();
      e.resume();
      check(e.state).isA<EngineIdle>();
      e.dispose();
    });

    test('resume from Running is a no-op', () {
      fakeAsync((async) {
        final e = _mk();
        e.start();
        async.flushMicrotasks();
        final before = e.state;
        e.resume();
        check(e.state).equals(before);
        e.dispose();
      });
    });

    test('resume from Ended is a no-op', () {
      final e = _mk();
      e.endSession(reason: EndReason.userQuit);
      e.resume();
      check(e.state).isA<EngineEnded>();
      e.dispose();
    });
  });

  // -------------------------------------------------------------------------
  // Pause with reason PauseReason values
  // -------------------------------------------------------------------------
  group('PauseReason variants', () {
    test('pause with userRequested sets reason correctly', () {
      fakeAsync((async) {
        final e = _mk();
        e.start();
        async.flushMicrotasks();
        e.pause(reason: PauseReason.userRequested);
        check(
          (e.state as EnginePaused).reason,
        ).equals(PauseReason.userRequested);
        e.dispose();
      });
    });

    test('pause with incomingCall sets reason correctly', () {
      fakeAsync((async) {
        final e = _mk();
        e.start();
        async.flushMicrotasks();
        e.pause(reason: PauseReason.incomingCall);
        check(
          (e.state as EnginePaused).reason,
        ).equals(PauseReason.incomingCall);
        e.dispose();
      });
    });

    test('sessionPaused metadata contains reason', () {
      fakeAsync((async) {
        final e = _mk();
        final evs = <ChainEventData>[];
        e.events.listen(evs.add);
        e.start();
        async.flushMicrotasks();
        e.pause(reason: PauseReason.incomingCall);
        async.flushMicrotasks();
        final ev = evs.firstWhere((ev) => ev.event == ChainEvent.sessionPaused);
        check(ev.metadata['reason']).equals('incomingCall');
        e.dispose();
      });
    });
  });

  // -------------------------------------------------------------------------
  // Timer cancelled during pause
  // -------------------------------------------------------------------------
  group('timer cancellation on pause', () {
    test(
      'paused engine does not advance even after 10x the phase duration',
      () {
        fakeAsync((async) {
          final e = _mk(wait: 0, dur: 10, grace: 5);
          e.start();
          async.flushMicrotasks();
          e.pause();
          async.elapse(const Duration(seconds: 500));
          check(e.state).isA<EnginePaused>();
          e.dispose();
        });
      },
    );
  });

  // -------------------------------------------------------------------------
  // Disarm from paused state
  // -------------------------------------------------------------------------
  group('disarm from Paused', () {
    // Q1: disarm while paused is a no-op — the engine remains in
    // EnginePaused. Callers must resume() first if they want disarm
    // to take effect (which now resets the chain to step 0 rather
    // than ending the session).
    test('disarm while paused is a no-op (state preserved)', () {
      fakeAsync((async) {
        final e = _mk();
        e.start();
        async.flushMicrotasks();
        e.pause();
        async.flushMicrotasks();
        final before = e.state;
        e.disarm();
        async.flushMicrotasks();
        check(e.state).equals(before);
        check(e.state).isA<EnginePaused>();
        e.dispose();
      });
    });
  });
}
