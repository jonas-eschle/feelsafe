/// Lifecycle tests for [SessionEngine] — construct, start, disarm,
/// endSession, dispose.
library;

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/engine/timer_phase.dart';
import 'package:guardianangela/domain/models/chain_event.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import '../../helpers/test_helpers.dart';

SessionEngine _mk(List<ChainStep> steps, {bool isSimulation = false}) =>
    SessionEngine(
      chainSteps: steps,
      isSimulation: isSimulation,
      random: FixedRandom(),
    );

void main() {
  group('SessionEngine construction', () {
    test('construct with empty steps is allowed (start fails later)', () {
      final e = _mk(const []);
      check(e.state).isA<EngineIdle>();
      e.dispose();
    });

    test('construct with default speed multiplier 1.0', () {
      final e = _mk([holdStep()]);
      check(e.speedMultiplier).equals(1.0);
      check(e.isSimulation).isFalse();
      e.dispose();
    });

    test('isDistressChain starts false', () {
      final e = _mk([holdStep()]);
      check(e.isDistressChain).isFalse();
      e.dispose();
    });

    test('steps getter returns the initial chain', () {
      final chain = [holdStep(), smsStep(order: 1)];
      final e = _mk(chain);
      check(e.steps.length).equals(2);
      check(e.steps[0].type).equals(ChainStepType.holdButton);
      check(e.steps[1].type).equals(ChainStepType.smsContact);
      e.dispose();
    });

    test('currentStep is null while idle', () {
      final e = _mk([holdStep()]);
      check(e.currentStep).isNull();
      e.dispose();
    });

    test('currentStep is null after endSession', () {
      final e = _mk([holdStep()]);
      e.endSession(reason: EndReason.userQuit);
      check(e.currentStep).isNull();
      e.dispose();
    });

    test('engine without injected Random constructs with default Random', () {
      final e = SessionEngine(chainSteps: [holdStep()]);
      check(e.state).isA<EngineIdle>();
      e.dispose();
    });

    test('engine without injected clock uses package:clock default', () {
      final e = SessionEngine(
        chainSteps: [holdStep()],
        random: FixedRandom(),
      );
      check(e.state).isA<EngineIdle>();
      e.dispose();
    });
  });

  group('SessionEngine.start', () {
    test('start with empty steps throws ArgumentError', () {
      final e = _mk(const []);
      check(e.start).throws<ArgumentError>();
      e.dispose();
    });

    test('start emits sessionStarted', () {
      fakeAsync((async) {
        final e = _mk([holdStep()]);
        final events = <ChainEvent>[];
        e.events.listen((ev) => events.add(ev.event));
        e.start();
        async.flushMicrotasks();
        check(events).contains(ChainEvent.sessionStarted);
        e.dispose();
      });
    });

    test('start emits stepStarted for step 0', () {
      fakeAsync((async) {
        final e = _mk([holdStep()]);
        final events = <ChainEvent>[];
        e.events.listen((ev) => events.add(ev.event));
        e.start();
        async.flushMicrotasks();
        check(events).contains(ChainEvent.stepStarted);
        e.dispose();
      });
    });

    test('double start throws StateError', () {
      final e = _mk([holdStep()]);
      e.start();
      check(e.start).throws<StateError>();
      e.dispose();
    });

    test('start transitions state to EngineRunning for non-hold step', () {
      fakeAsync((async) {
        final e = _mk([smsStep()]);
        e.start();
        async.flushMicrotasks();
        check(e.state).isA<EngineRunning>();
        e.dispose();
      });
    });

    test('start on holdButton step sets phase holdWait', () {
      fakeAsync((async) {
        final e = _mk([holdStep()]);
        e.start();
        async.flushMicrotasks();
        check(e.state).isA<EngineRunning>();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.holdWait);
        check(s.stepIndex).equals(0);
        check(s.isHolding).isFalse();
        e.dispose();
      });
    });

    test('currentStep returns the active step after start', () {
      fakeAsync((async) {
        final steps = [holdStep(), smsStep(order: 1)];
        final e = _mk(steps);
        e.start();
        async.flushMicrotasks();
        check(e.currentStep).isNotNull();
        check(e.currentStep!.id).equals(steps[0].id);
        e.dispose();
      });
    });

    test('start on smsStep with zero wait enters duration immediately', () {
      fakeAsync((async) {
        final e = _mk([smsStep(durationSeconds: 5)]);
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.duration);
        e.dispose();
      });
    });

    test('start on step with non-zero wait enters wait phase', () {
      fakeAsync((async) {
        final e = _mk(
          [smsStep(durationSeconds: 1)
              .copyWith(waitSeconds: 10)],
        );
        e.start();
        async.flushMicrotasks();
        final s = e.state as EngineRunning;
        check(s.phase).equals(TimerPhase.wait);
        e.dispose();
      });
    });
  });

  group('SessionEngine.disarm', () {
    test('disarm from Idle transitions to Ended(disarm)', () {
      final e = _mk([holdStep()]);
      e.disarm();
      check(e.state).isA<EngineEnded>();
      check((e.state as EngineEnded).reason).equals(EndReason.disarm);
      e.dispose();
    });

    test('disarm emits sessionEnded', () {
      fakeAsync((async) {
        final e = _mk([holdStep()]);
        final events = <ChainEvent>[];
        e.events.listen((ev) => events.add(ev.event));
        e.start();
        async.flushMicrotasks();
        e.disarm();
        async.flushMicrotasks();
        check(events).contains(ChainEvent.sessionEnded);
        e.dispose();
      });
    });

    test('disarm is idempotent', () {
      final e = _mk([holdStep()]);
      e.disarm();
      e.disarm();
      e.disarm();
      check(e.state).isA<EngineEnded>();
      check((e.state as EngineEnded).reason).equals(EndReason.disarm);
      e.dispose();
    });

    test('disarm from Running transitions to Ended', () {
      fakeAsync((async) {
        final e = _mk([smsStep()]);
        e.start();
        async.flushMicrotasks();
        e.disarm();
        async.flushMicrotasks();
        check(e.state).isA<EngineEnded>();
        e.dispose();
      });
    });

    test('no events emitted after sessionEnded', () {
      fakeAsync((async) {
        final e = _mk([smsStep(durationSeconds: 10)]);
        e.start();
        async.flushMicrotasks();
        e.disarm();
        async.flushMicrotasks();
        var after = 0;
        e.events.listen((ev) => after++);
        async.elapse(const Duration(seconds: 30));
        check(after).equals(0);
        e.dispose();
      });
    });
  });

  group('SessionEngine.endSession', () {
    test('endSession with chainExhausted reason', () {
      final e = _mk([holdStep()]);
      e.endSession(reason: EndReason.chainExhausted);
      check((e.state as EngineEnded).reason).equals(EndReason.chainExhausted);
      e.dispose();
    });

    test('endSession with userQuit reason', () {
      final e = _mk([holdStep()]);
      e.endSession(reason: EndReason.userQuit);
      check((e.state as EngineEnded).reason).equals(EndReason.userQuit);
      e.dispose();
    });

    test('endSession with hardwarePanic reason', () {
      final e = _mk([holdStep()]);
      e.endSession(reason: EndReason.hardwarePanic);
      check((e.state as EngineEnded).reason).equals(EndReason.hardwarePanic);
      e.dispose();
    });

    test('endSession with duressPin reason', () {
      final e = _mk([holdStep()]);
      e.endSession(reason: EndReason.duressPin);
      check((e.state as EngineEnded).reason).equals(EndReason.duressPin);
      e.dispose();
    });

    test('endSession is idempotent — first call wins', () {
      final e = _mk([holdStep()]);
      e.endSession(reason: EndReason.userQuit);
      e.endSession(reason: EndReason.disarm);
      check((e.state as EngineEnded).reason).equals(EndReason.userQuit);
      e.dispose();
    });

    test('endSession cancels timers', () {
      fakeAsync((async) {
        final e = _mk([smsStep(durationSeconds: 10)]);
        e.start();
        async.flushMicrotasks();
        e.endSession(reason: EndReason.userQuit);
        async.elapse(const Duration(seconds: 30));
        check(e.state).isA<EngineEnded>();
        e.dispose();
      });
    });

    test('endSession emits sessionEnded with reason in metadata', () {
      fakeAsync((async) {
        final e = _mk([holdStep()]);
        final evs = <ChainEventData>[];
        e.events.listen(evs.add);
        e.endSession(reason: EndReason.chainExhausted);
        async.flushMicrotasks();
        final ended = evs.firstWhere(
          (ev) => ev.event == ChainEvent.sessionEnded,
        );
        check(ended.metadata['reason']).equals('chainExhausted');
        e.dispose();
      });
    });
  });

  group('SessionEngine.dispose', () {
    test('dispose is idempotent', () {
      final e = _mk([holdStep()]);
      e.dispose();
      e.dispose();
      e.dispose();
    });

    test('dispose cancels timers', () {
      fakeAsync((async) {
        final e = _mk([smsStep(durationSeconds: 60)]);
        e.start();
        async.flushMicrotasks();
        e.dispose();
        async.elapse(const Duration(seconds: 120));
      });
    });
  });

  group('events stream', () {
    test('broadcast stream supports multiple listeners', () {
      fakeAsync((async) {
        final e = _mk([smsStep(durationSeconds: 1)]);
        final a = <ChainEvent>[];
        final b = <ChainEvent>[];
        e.events.listen((ev) => a.add(ev.event));
        e.events.listen((ev) => b.add(ev.event));
        e.start();
        async.flushMicrotasks();
        check(a).deepEquals(b);
        e.dispose();
      });
    });

    test('events include stepIndex for step-related events', () {
      fakeAsync((async) {
        final e = _mk([smsStep(durationSeconds: 1)]);
        final evs = <ChainEventData>[];
        e.events.listen(evs.add);
        e.start();
        async.flushMicrotasks();
        final started = evs.firstWhere(
          (ev) => ev.event == ChainEvent.stepStarted,
        );
        check(started.stepIndex).equals(0);
        check(started.stepType).equals(ChainStepType.smsContact);
        e.dispose();
      });
    });

    test('sessionStarted always precedes stepStarted', () {
      fakeAsync((async) {
        final e = _mk([smsStep()]);
        final names = <ChainEvent>[];
        e.events.listen((ev) => names.add(ev.event));
        e.start();
        async.flushMicrotasks();
        final startedIdx = names.indexOf(ChainEvent.sessionStarted);
        final stepIdx = names.indexOf(ChainEvent.stepStarted);
        check(startedIdx).isGreaterOrEqual(0);
        check(stepIdx).isGreaterThan(startedIdx);
        e.dispose();
      });
    });
  });
}
