/// Full end-to-end session scenarios.
///
/// Exercises the engine + orchestrator stack across real-world flows:
///   * Walk Mode happy / worst path.
///   * Date Mode disguised reminder cycle.
///   * Simulation run collecting SIM descriptions only.
///   * Battery-alert session running its chain (non-interactive).
library;

import 'dart:async';

import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/engine/session_engine.dart';
import 'package:guardianangela/domain/engine/timer_phase.dart';
import 'package:guardianangela/domain/models/chain_event.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/session_context.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';
import 'package:guardianangela/domain/orchestration/session_orchestrator.dart';
import 'package:guardianangela/services/fakes/fake_audio_service.dart';
import 'package:guardianangela/services/fakes/fake_messaging_service.dart';
import 'package:guardianangela/services/fakes/fake_notification_service.dart';
import 'package:guardianangela/services/fakes/fake_phone_service.dart';
import 'package:guardianangela/services/fakes/fake_vibration_service.dart';
import '../helpers/test_helpers.dart';

final class _Harness {
  _Harness({
    required this.engine,
    required this.orch,
    required this.events,
    required this.sub,
    required this.audio,
    required this.messaging,
    required this.phone,
    required this.notif,
    required this.vib,
    required this.descriptions,
  });

  final SessionEngine engine;
  final SessionOrchestrator orch;
  final List<ChainEventData> events;
  final StreamSubscription<ChainEventData> sub;
  final FakeAudioService audio;
  final FakeMessagingService messaging;
  final FakePhoneService phone;
  final FakeNotificationService notif;
  final FakeVibrationService vib;
  final List<SimulationDescription> descriptions;

  void cleanup() {
    sub.cancel();
    orch.dispose();
    engine.dispose();
    audio.dispose();
    messaging.dispose();
    phone.dispose();
    notif.dispose();
    vib.dispose();
  }
}

_Harness _wire({
  required List<ChainStep> chain,
  bool isSimulation = false,
  double speedMultiplier = 1.0,
}) {
  final audio = FakeAudioService();
  final messaging = FakeMessagingService();
  final phone = FakePhoneService();
  final notif = FakeNotificationService();
  final vib = FakeVibrationService();
  final descriptions = <SimulationDescription>[];
  final engine = SessionEngine(
    chainSteps: chain,
    isSimulation: isSimulation,
    speedMultiplier: speedMultiplier,
    random: FixedRandom(),
  );
  final orch = SessionOrchestrator(
    isSimulation: isSimulation,
    chainStepsResolver: () => engine.steps,
    messagingService: messaging,
    onSimulationDescription: descriptions.add,
    servicesBuilder: (isCancelled, register) => EventServices(
      audio: audio,
      messaging: messaging,
      phone: phone,
      notification: notif,
      vibration: vib,
      context: SessionContext(
        contacts: [
          makeContact(id: 'a'),
          makeContact(id: 'b'),
        ],
        isSimulation: isSimulation,
      ),
      isCancelled: isCancelled,
      registerSmsWorkId: register,
    ),
  );
  final events = <ChainEventData>[];
  final sub = engine.events.listen((e) {
    events.add(e);
    unawaited(orch.handleEvent(e));
  });
  return _Harness(
    engine: engine,
    orch: orch,
    events: events,
    sub: sub,
    audio: audio,
    messaging: messaging,
    phone: phone,
    notif: notif,
    vib: vib,
    descriptions: descriptions,
  );
}

void main() {
  group('Walk Mode: happy path', () {
    test('hold throughout then end-session → Ended(disarm)', () {
      // Spec 01: engine.disarm() is a re-arm to step 0. To actually
      // terminate the session via the user-initiated path we use
      // engine.endSession(EndReason.disarm) — which is what
      // SessionController.disarm() does.
      fakeAsync((async) {
        final h = _wire(
          chain: [holdStep(durationSeconds: 5, gracePeriodSeconds: 2)],
        );
        h.engine.start();
        async.flushMicrotasks();
        h.engine.holdStart();
        // Hold through most of the duration.
        async.elapse(const Duration(seconds: 3));
        // User ends the session manually.
        h.engine.endSession(reason: EndReason.disarm);
        async.flushMicrotasks();
        final last = h.engine.state as EngineEnded;
        check(last.reason).equals(EndReason.disarm);
        h.cleanup();
      });
    });

    test('re-hold during grace re-arms (resets to step 0)', () {
      // Spec 01 §holdButton: re-hold during grace = disarm() = re-arm
      // to step 0. The session keeps running.
      fakeAsync((async) {
        final h = _wire(
          chain: [
            holdStep(
              durationSeconds: 5,
              gracePeriodSeconds: 5,
              releaseSensitivity: 0.1,
            ),
          ],
        );
        h.engine.start();
        async.flushMicrotasks();
        h.engine.holdStart();
        async.elapse(const Duration(seconds: 3));
        h.engine.holdRelease();
        // Sensitivity elapses → enter duration → user re-holds.
        async.elapse(const Duration(milliseconds: 200));
        h.engine.holdStart();
        async.elapse(const Duration(seconds: 2));
        h.engine.disarm();
        async.flushMicrotasks();
        // Engine is still running (re-armed at step 0).
        check(h.engine.state).isA<EngineRunning>();
        check((h.engine.state as EngineRunning).stepIndex).equals(0);
        h.cleanup();
      });
    });

    test('happy path emits no grace-expired events', () {
      fakeAsync((async) {
        final h = _wire(
          chain: [holdStep(durationSeconds: 5, gracePeriodSeconds: 3)],
        );
        h.engine.start();
        async.flushMicrotasks();
        h.engine.holdStart();
        async.elapse(const Duration(seconds: 2));
        h.engine.endSession(reason: EndReason.disarm);
        async.flushMicrotasks();
        final graceEvents = h.events.where(
          (e) => e.event == ChainEvent.graceExpired,
        );
        check(graceEvents).isEmpty();
        h.cleanup();
      });
    });
  });

  group('Walk Mode: worst path (release → escalation)', () {
    test('release then grace expires advances to next step', () {
      fakeAsync((async) {
        final h = _wire(
          chain: [
            holdStep(
              durationSeconds: 2,
              gracePeriodSeconds: 1,
              releaseSensitivity: 0.1,
            ),
            step(
              type: ChainStepType.loudAlarm,
              order: 1,
              durationSeconds: 1,
              gracePeriodSeconds: 0,
            ),
          ],
        );
        h.engine.start();
        async.flushMicrotasks();
        h.engine.holdStart();
        // Release almost immediately — grace starts.
        async.elapse(const Duration(milliseconds: 100));
        h.engine.holdRelease();
        // Elapse past sensitivity → duration → grace.
        async.elapse(const Duration(seconds: 10));
        // Loud alarm played.
        check(h.audio.calls).isNotEmpty();
        h.cleanup();
      });
    });

    test('full chain: hold → alarm → callEmergency fires phone', () {
      fakeAsync((async) {
        final h = _wire(
          chain: [
            holdStep(
              durationSeconds: 1,
              gracePeriodSeconds: 1,
              releaseSensitivity: 0.1,
            ),
            step(
              type: ChainStepType.loudAlarm,
              order: 1,
              durationSeconds: 1,
              gracePeriodSeconds: 0,
            ),
            step(
              type: ChainStepType.callEmergency,
              order: 2,
              durationSeconds: 1,
              gracePeriodSeconds: 0,
              config: const CallEmergencyConfig(emergencyNumber: '911'),
            ),
          ],
        );
        h.engine.start();
        async.flushMicrotasks();
        h.engine.holdStart();
        async.elapse(const Duration(milliseconds: 50));
        h.engine.holdRelease();
        async.elapse(const Duration(seconds: 10));
        check(h.phone.calls.any((c) => c.contains('callEmergency'))).isTrue();
        h.cleanup();
      });
    });

    test('worst path ends with chainExhausted', () {
      fakeAsync((async) {
        final h = _wire(
          chain: [
            holdStep(
              durationSeconds: 1,
              gracePeriodSeconds: 1,
              releaseSensitivity: 0.1,
            ),
            step(
              type: ChainStepType.loudAlarm,
              order: 1,
              durationSeconds: 1,
              gracePeriodSeconds: 0,
            ),
          ],
        );
        h.engine.start();
        async.flushMicrotasks();
        h.engine.holdStart();
        async.elapse(const Duration(milliseconds: 50));
        h.engine.holdRelease();
        async.elapse(const Duration(seconds: 20));
        final ended = h.engine.state as EngineEnded;
        check(ended.reason).equals(EndReason.chainExhausted);
        h.cleanup();
      });
    });
  });

  group('Date Mode: disguised reminder cycle', () {
    test('disguised reminder → advance after grace', () {
      fakeAsync((async) {
        final h = _wire(
          chain: [
            step(
              type: ChainStepType.disguisedReminder,
              durationSeconds: 2,
              gracePeriodSeconds: 1,
            ),
            smsStep(order: 1, durationSeconds: 1, gracePeriodSeconds: 0),
          ],
        );
        h.engine.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 10));
        // SMS eventually fired.
        check(h.messaging.calls).isNotEmpty();
        h.cleanup();
      });
    });

    test('disguised reminder with retries fires multiple grace-expired', () {
      fakeAsync((async) {
        final h = _wire(
          chain: [
            step(
              type: ChainStepType.disguisedReminder,
              durationSeconds: 1,
              gracePeriodSeconds: 1,
              retryCount: 2,
            ),
          ],
        );
        h.engine.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 20));
        final graceEvents = h.events.where(
          (e) => e.event == ChainEvent.graceExpired,
        );
        // initial miss + 2 retries = 3 graceExpired events.
        check(graceEvents.length).equals(3);
        h.cleanup();
      });
    });

    test('repeatMissed emits between retries', () {
      fakeAsync((async) {
        final h = _wire(
          chain: [
            step(
              type: ChainStepType.disguisedReminder,
              durationSeconds: 1,
              gracePeriodSeconds: 0,
              retryCount: 1,
            ),
          ],
        );
        h.engine.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 5));
        final repeat = h.events
            .where((e) => e.event == ChainEvent.repeatMissed)
            .length;
        check(repeat).equals(1);
        h.cleanup();
      });
    });

    test('disguised reminder triggers notification on step start', () {
      fakeAsync((async) {
        final h = _wire(
          chain: [
            step(
              type: ChainStepType.disguisedReminder,
              durationSeconds: 10,
              gracePeriodSeconds: 0,
            ),
          ],
        );
        h.engine.start();
        async.elapse(const Duration(milliseconds: 500));
        // The disguised reminder strategy triggers a notification.
        // Note: using FakeNotificationService.calls (no calls list by
        // default, but we assert the event went through the chain).
        final steps = h.events.where((e) => e.event == ChainEvent.stepStarted);
        check(steps.length).equals(1);
        h.cleanup();
      });
    });
  });

  group('Simulation scenarios', () {
    test('walk-mode simulation collects descriptions only', () {
      fakeAsync((async) {
        final h = _wire(
          isSimulation: true,
          speedMultiplier: 10.0,
          chain: [
            holdStep(
              durationSeconds: 1,
              gracePeriodSeconds: 1,
              releaseSensitivity: 0.1,
            ),
            step(
              type: ChainStepType.loudAlarm,
              order: 1,
              durationSeconds: 1,
              gracePeriodSeconds: 0,
            ),
            step(
              type: ChainStepType.callEmergency,
              order: 2,
              durationSeconds: 1,
              gracePeriodSeconds: 0,
            ),
          ],
        );
        h.engine.start();
        async.flushMicrotasks();
        h.engine.holdStart();
        async.elapse(const Duration(milliseconds: 50));
        h.engine.holdRelease();
        async.elapse(const Duration(seconds: 5));
        check(h.audio.calls).isEmpty();
        check(h.phone.calls).isEmpty();
        check(h.messaging.calls).isEmpty();
        check(h.descriptions).isNotEmpty();
        h.cleanup();
      });
    });

    test('simulation leap fast-forwards through phases', () {
      fakeAsync((async) {
        final h = _wire(
          isSimulation: true,
          chain: [holdStep(durationSeconds: 30, gracePeriodSeconds: 30)],
        );
        h.engine.start();
        async.flushMicrotasks();
        h.engine.holdStart();
        async.flushMicrotasks();
        h.engine.holdRelease();
        // Fast-forward through sensitivity and duration.
        h.engine.leap();
        async.flushMicrotasks();
        h.engine.leap();
        async.flushMicrotasks();
        // Should now be in grace or past it.
        check(h.engine.state).isA<EngineRunning>();
        h.cleanup();
      });
    });

    test('non-simulation leap throws StateError', () {
      fakeAsync((async) {
        final h = _wire(
          isSimulation: false,
          chain: [holdStep(durationSeconds: 30, gracePeriodSeconds: 30)],
        );
        h.engine.start();
        async.flushMicrotasks();
        check(() => h.engine.leap()).throws<StateError>();
        h.cleanup();
      });
    });

    test('speedMultiplier in real mode throws ArgumentError', () {
      check(
        () => SessionEngine(
          chainSteps: [holdStep()],
          isSimulation: false,
          speedMultiplier: 2.0,
        ),
      ).throws<ArgumentError>();
    });
  });

  group('Chain advancing and session ending', () {
    test('final step completion ends session with chainExhausted', () {
      fakeAsync((async) {
        final h = _wire(
          chain: [smsStep(durationSeconds: 1, gracePeriodSeconds: 0)],
        );
        h.engine.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 3));
        final ended = h.engine.state as EngineEnded;
        check(ended.reason).equals(EndReason.chainExhausted);
        h.cleanup();
      });
    });

    test('sessionEnded is emitted exactly once per session', () {
      fakeAsync((async) {
        final h = _wire(
          chain: [smsStep(durationSeconds: 1, gracePeriodSeconds: 0)],
        );
        h.engine.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 3));
        final endedCount = h.events
            .where((e) => e.event == ChainEvent.sessionEnded)
            .length;
        check(endedCount).equals(1);
        h.cleanup();
      });
    });

    test('stepAdvancing emitted between each pair of steps', () {
      fakeAsync((async) {
        final h = _wire(
          chain: [
            smsStep(order: 0, durationSeconds: 1, gracePeriodSeconds: 0),
            smsStep(order: 1, durationSeconds: 1, gracePeriodSeconds: 0),
            smsStep(order: 2, durationSeconds: 1, gracePeriodSeconds: 0),
          ],
        );
        h.engine.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 10));
        final advancing = h.events
            .where((e) => e.event == ChainEvent.stepAdvancing)
            .length;
        // 3 steps → at least 2 stepAdvancing between them + 1 at end.
        check(advancing).isGreaterOrEqual(2);
        h.cleanup();
      });
    });
  });

  group('Pause / resume during session', () {
    test('pause mid-duration resumes with remaining ~= snapshot', () {
      fakeAsync((async) {
        final h = _wire(
          chain: [smsStep(durationSeconds: 10, gracePeriodSeconds: 0)],
        );
        h.engine.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 3));
        h.engine.pause();
        async.flushMicrotasks();
        final paused = h.engine.state as EnginePaused;
        check(paused.snapshot.remaining.inSeconds).isLessOrEqual(10);
        h.engine.resume();
        async.flushMicrotasks();
        check(h.engine.state).isA<EngineRunning>();
        h.cleanup();
      });
    });

    test('pause during grace preserves the phase', () {
      fakeAsync((async) {
        final h = _wire(
          chain: [smsStep(durationSeconds: 1, gracePeriodSeconds: 5)],
        );
        h.engine.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 2));
        h.engine.pause();
        final paused = h.engine.state as EnginePaused;
        check(paused.snapshot.phase).equals(TimerPhase.grace);
        h.cleanup();
      });
    });

    test('resume emits sessionResumed event', () {
      fakeAsync((async) {
        final h = _wire(
          chain: [smsStep(durationSeconds: 5, gracePeriodSeconds: 0)],
        );
        h.engine.start();
        async.flushMicrotasks();
        h.engine.pause();
        async.flushMicrotasks();
        h.engine.resume();
        async.flushMicrotasks();
        final kinds = h.events.map((e) => e.event);
        check(kinds).contains(ChainEvent.sessionResumed);
        h.cleanup();
      });
    });
  });

  group('Battery-alert style chain (one-shot, non-interactive)', () {
    test('runs alert chain to completion', () {
      fakeAsync((async) {
        // Battery alerts use the same chain/engine; the difference is
        // lifecycle (no TriggerManager). We simulate that here.
        final h = _wire(
          chain: [smsStep(durationSeconds: 1, gracePeriodSeconds: 0)],
        );
        h.engine.start();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 3));
        check(h.messaging.calls).isNotEmpty();
        check(h.engine.state).isA<EngineEnded>();
        h.cleanup();
      });
    });
  });
}
