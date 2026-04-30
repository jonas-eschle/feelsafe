/// Hold-button state machine tests — spec §2.2.
library;

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/engine/timer_phase.dart';
import 'package:guardianangela/domain/models/chain_event.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import '../../helpers/test_helpers.dart';

SessionEngine _holdEngine({
  int durationSeconds = 10,
  int gracePeriodSeconds = 5,
  double releaseSensitivity = 1.0,
}) => SessionEngine(
  chainSteps: [
    holdStep(
      durationSeconds: durationSeconds,
      gracePeriodSeconds: gracePeriodSeconds,
      releaseSensitivity: releaseSensitivity,
    ),
    smsStep(order: 1, durationSeconds: 1, gracePeriodSeconds: 0),
  ],
  random: FixedRandom(),
);

void main() {
  group('holdStart / holdRelease no-ops', () {
    test('holdStart before start is a no-op', () {
      final e = _holdEngine();
      e.holdStart();
      check(e.state).isA<EngineIdle>();
      e.dispose();
    });

    test('holdRelease before start is a no-op', () {
      final e = _holdEngine();
      e.holdRelease();
      check(e.state).isA<EngineIdle>();
      e.dispose();
    });

    test('holdStart on non-hold step is a no-op', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [smsStep(durationSeconds: 10)],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        final s0 = e.state as EngineRunning;
        e.holdStart();
        final s1 = e.state as EngineRunning;
        check(s1.phase).equals(s0.phase);
        e.dispose();
      });
    });

    test('holdRelease without holdStart is a no-op', () {
      fakeAsync((async) {
        final e = _holdEngine();
        e.start();
        async.flushMicrotasks();
        final s0 = e.state as EngineRunning;
        e.holdRelease();
        final s1 = e.state as EngineRunning;
        check(s1.phase).equals(s0.phase);
        check(s1.isHolding).isFalse();
        e.dispose();
      });
    });

    test('double holdStart no-op on second call', () {
      fakeAsync((async) {
        final e = _holdEngine();
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        final s1 = e.state as EngineRunning;
        check(s1.isHolding).isTrue();
        e.holdStart();
        final s2 = e.state as EngineRunning;
        check(s2.isHolding).isTrue();
        check(s2.phase).equals(s1.phase);
        check(s2.remaining).equals(s1.remaining);
        e.dispose();
      });
    });
  });

  group('hold lifecycle', () {
    test('holdStart transitions to duration phase', () {
      fakeAsync((async) {
        final e = _holdEngine(durationSeconds: 10);
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.duration);
        check(s.remaining).equals(const Duration(seconds: 10));
        check(s.isHolding).isTrue();
        e.dispose();
      });
    });

    test('holdRelease starts sensitivity window', () {
      fakeAsync((async) {
        final e = _holdEngine(releaseSensitivity: 1.0);
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.holdRelease();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.sensitivity);
        check(s.remaining).equals(const Duration(seconds: 1));
        check(s.isHolding).isFalse();
        e.dispose();
      });
    });

    test('re-hold inside sensitivity cancels and resumes duration', () {
      fakeAsync((async) {
        final e = _holdEngine(durationSeconds: 10, releaseSensitivity: 1.0);
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.holdRelease();
        // Still in sensitivity window.
        async.elapse(const Duration(milliseconds: 500));
        e.holdStart();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.duration);
        check(s.isHolding).isTrue();
        e.dispose();
      });
    });

    test('sensitivity expires → duration countdown begins', () {
      fakeAsync((async) {
        final e = _holdEngine(durationSeconds: 10, releaseSensitivity: 1.0);
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.holdRelease();
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.duration);
        check(s.isHolding).isFalse();
        e.dispose();
      });
    });

    test('duration expires without re-hold → enter grace', () {
      fakeAsync((async) {
        final e = _holdEngine(
          durationSeconds: 3,
          gracePeriodSeconds: 5,
          releaseSensitivity: 1.0,
        );
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.holdRelease();
        // Wait sensitivity → duration → grace entry.
        async.elapse(const Duration(seconds: 1));
        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.grace);
        e.dispose();
      });
    });

    test('re-hold during grace fires disarm (resets to step 0)', () {
      // Spec 01 §Disarm/Check-in: re-hold during grace == disarm,
      // and disarm is now a re-arm to step 0 (not a session end).
      fakeAsync((async) {
        final e = _holdEngine(
          durationSeconds: 3,
          gracePeriodSeconds: 5,
          releaseSensitivity: 1.0,
        );
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.holdRelease();
        async.elapse(const Duration(seconds: 1)); // sensitivity → duration.
        async.elapse(const Duration(seconds: 3)); // duration → grace.
        async.flushMicrotasks();
        e.holdStart();
        async.flushMicrotasks();
        check(e.state).isA<EngineRunning>();
        check((e.state as EngineRunning).stepIndex).equals(0);
        e.dispose();
      });
    });

    test('grace expires without re-hold → advance to next step', () {
      fakeAsync((async) {
        final e = _holdEngine(
          durationSeconds: 3,
          gracePeriodSeconds: 2,
          releaseSensitivity: 1.0,
        );
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.holdRelease();
        async.elapse(const Duration(seconds: 1)); // sensitivity.
        async.elapse(const Duration(seconds: 3)); // duration.
        async.elapse(const Duration(seconds: 2)); // grace.
        async.flushMicrotasks();
        // After grace expires with no retries, step advances to sms.
        // smsStep durationSeconds=1, gracePeriodSeconds=0.
        final state = e.state;
        if (state is EngineRunning) {
          check(state.stepIndex).equals(1);
        } else {
          // SMS step may have already exhausted (duration=1, grace=0)
          // if enough time elapsed in a single tick.
          check(state).isA<EngineEnded>();
        }
        e.dispose();
      });
    });
  });

  group('holdStart emits no stepStarted (still first step)', () {
    test('no repeated stepStarted on hold', () {
      fakeAsync((async) {
        final e = _holdEngine();
        final events = <ChainEvent>[];
        e.events.listen((ev) => events.add(ev.event));
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.holdRelease();
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        final stepCount = events
            .where((ev) => ev == ChainEvent.stepStarted)
            .length;
        check(stepCount).equals(1);
        e.dispose();
      });
    });
  });

  group('default releaseSensitivity', () {
    test('step with no config uses HoldButtonConfig default', () {
      fakeAsync((async) {
        // Spec 02 §1.holdButton: no explicit config → engine falls
        // back to releaseSensitivity 1.0s default.
        final e = SessionEngine(
          chainSteps: [
            step(
              type: ChainStepType.holdButton,
              durationSeconds: 5,
              gracePeriodSeconds: 1,
            ),
          ],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.holdRelease();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.sensitivity);
        check(s.remaining).equals(const Duration(milliseconds: 1000));
        e.dispose();
      });
    });

    test('custom HoldButtonConfig overrides sensitivity', () {
      fakeAsync((async) {
        final e = SessionEngine(
          chainSteps: [
            step(
              type: ChainStepType.holdButton,
              durationSeconds: 5,
              gracePeriodSeconds: 1,
              config: const HoldButtonConfig(releaseSensitivity: 2.5),
            ),
          ],
          random: FixedRandom(),
        );
        e.start();
        async.flushMicrotasks();
        e.holdStart();
        e.holdRelease();
        final s = e.state as EngineRunning;
        check(s.remaining).equals(const Duration(milliseconds: 2500));
        e.dispose();
      });
    });
  });
}
