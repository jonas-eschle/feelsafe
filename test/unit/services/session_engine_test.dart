import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safewayhome/data/models/escalation_chain.dart';
import 'package:safewayhome/data/models/escalation_step.dart';
import 'package:safewayhome/data/models/session_mode.dart';
import 'package:safewayhome/features/session/session_engine.dart';

void main() {
  group('SessionEngine', () {
    late EscalationChain chain;

    setUp(() {
      chain = EscalationChain(steps: [
        EscalationStep(
          type: EscalationStepType.countdownWarning,
          timeoutSeconds: 5,
          order: 0,
        ),
        EscalationStep(
          type: EscalationStepType.fakeCall,
          timeoutSeconds: 10,
          order: 1,
        ),
        EscalationStep(
          type: EscalationStepType.smsContacts,
          timeoutSeconds: 5,
          order: 2,
        ),
        EscalationStep(
          type: EscalationStepType.callEmergencyServices,
          timeoutSeconds: 5,
          order: 3,
        ),
      ]);
    });

    group('timer fires after interval', () {
      test('emits checkInRequired after check-in interval', () {
        fakeAsync((async) {
          final engine = SessionEngine(
            escalationChain: chain,
            mechanism: CheckInMechanism.holdButton,
            checkInInterval: const Duration(seconds: 10),
            missedTolerance: 0,
          );

          final events = <SessionEvent>[];
          engine.events.listen(events.add);

          engine.start();

          async.elapse(const Duration(seconds: 9));
          expect(events, isEmpty);

          async.elapse(const Duration(seconds: 1));
          expect(events, contains(SessionEvent.checkInRequired));

          engine.endSession();
        });
      });
    });

    group('walk mode — hold/release', () {
      test('holding cancels check-in timer, releasing restarts it', () {
        fakeAsync((async) {
          final engine = SessionEngine(
            escalationChain: chain,
            mechanism: CheckInMechanism.holdButton,
            checkInInterval: const Duration(seconds: 10),
            missedTolerance: 0,
          );

          final events = <SessionEvent>[];
          engine.events.listen(events.add);

          engine.start();

          // Advance 5s, then hold
          async.elapse(const Duration(seconds: 5));
          engine.holdStart();

          // Advance 20s while holding — no timer should fire
          async.elapse(const Duration(seconds: 20));
          expect(events, isEmpty);

          // Release: starts a new 10s countdown
          engine.holdRelease();
          async.elapse(const Duration(seconds: 9));
          expect(events, isEmpty);

          async.elapse(const Duration(seconds: 1));
          expect(events, contains(SessionEvent.checkInRequired));

          engine.endSession();
        });
      });

      test('re-hold during countdown cancels it', () {
        fakeAsync((async) {
          final engine = SessionEngine(
            escalationChain: chain,
            mechanism: CheckInMechanism.holdButton,
            checkInInterval: const Duration(seconds: 10),
            missedTolerance: 0,
          );

          final events = <SessionEvent>[];
          engine.events.listen(events.add);

          engine.start();

          // Let countdown start (release is implicit — engine starts with timer)
          async.elapse(const Duration(seconds: 5));

          // Hold to cancel
          engine.holdStart();
          async.elapse(const Duration(seconds: 20));
          expect(events, isEmpty);

          engine.endSession();
        });
      });

      test('hold during escalation triggers check-in', () {
        fakeAsync((async) {
          final engine = SessionEngine(
            escalationChain: chain,
            mechanism: CheckInMechanism.holdButton,
            checkInInterval: const Duration(seconds: 10),
            missedTolerance: 0,
          );

          final events = <SessionEvent>[];
          engine.events.listen(events.add);

          engine.start();

          // Let timer expire → escalation
          async.elapse(const Duration(seconds: 10));
          expect(events, contains(SessionEvent.checkInRequired));
          expect(events, contains(SessionEvent.warningStarted));
          expect(engine.isEscalating, isTrue);

          // Hold = check-in
          engine.holdStart();
          async.flushMicrotasks();
          expect(events, contains(SessionEvent.userCheckedIn));
          expect(engine.isEscalating, isFalse);

          engine.endSession();
        });
      });
    });

    group('escalation steps advance in order', () {
      test('walks through all active steps with correct timing', () {
        fakeAsync((async) {
          final engine = SessionEngine(
            escalationChain: chain,
            mechanism: CheckInMechanism.holdButton,
            checkInInterval: const Duration(seconds: 3),
            missedTolerance: 0,
          );

          final events = <SessionEvent>[];
          engine.events.listen(events.add);

          engine.start();

          // After 3s: checkInRequired + first step (warning)
          async.elapse(const Duration(seconds: 3));
          expect(events, [
            SessionEvent.checkInRequired,
            SessionEvent.warningStarted,
          ]);

          // After 5s more (warning timeout): fakeCall
          async.elapse(const Duration(seconds: 5));
          expect(events.last, SessionEvent.fakeCallStarted);

          // After 10s more (fakeCall timeout): sms
          async.elapse(const Duration(seconds: 10));
          expect(events.last, SessionEvent.smsSending);

          // After 5s more (sms timeout): emergency call
          async.elapse(const Duration(seconds: 5));
          expect(events.last, SessionEvent.emergencyCallStarted);

          engine.endSession();
        });
      });

      test('disabled steps are skipped', () {
        fakeAsync((async) {
          // Disable fakeCall step
          final chainWithDisabled = EscalationChain(steps: [
            EscalationStep(
              type: EscalationStepType.countdownWarning,
              timeoutSeconds: 5,
              order: 0,
            ),
            EscalationStep(
              type: EscalationStepType.fakeCall,
              timeoutSeconds: 10,
              order: 1,
              enabled: false,
            ),
            EscalationStep(
              type: EscalationStepType.smsContacts,
              timeoutSeconds: 5,
              order: 2,
            ),
          ]);

          final engine = SessionEngine(
            escalationChain: chainWithDisabled,
            mechanism: CheckInMechanism.holdButton,
            checkInInterval: const Duration(seconds: 3),
            missedTolerance: 0,
          );

          final events = <SessionEvent>[];
          engine.events.listen(events.add);

          engine.start();

          // Trigger escalation
          async.elapse(const Duration(seconds: 3));
          expect(events, contains(SessionEvent.warningStarted));

          // After warning timeout, should skip fakeCall and go to SMS
          async.elapse(const Duration(seconds: 5));
          expect(events.last, SessionEvent.smsSending);
          expect(events, isNot(contains(SessionEvent.fakeCallStarted)));

          engine.endSession();
        });
      });
    });

    group('checkIn() resets everything', () {
      test('resets missed count, cancels escalation, restarts timer', () {
        fakeAsync((async) {
          final engine = SessionEngine(
            escalationChain: chain,
            mechanism: CheckInMechanism.disguisedReminder,
            checkInInterval: const Duration(seconds: 10),
            missedTolerance: 1,
          );

          final events = <SessionEvent>[];
          engine.events.listen(events.add);

          engine.start();

          // Miss first check-in
          async.elapse(const Duration(seconds: 10));
          expect(engine.missedCheckIns, 1);

          // Check in before second miss
          engine.checkIn();
          async.flushMicrotasks();
          expect(engine.missedCheckIns, 0);
          expect(engine.isEscalating, isFalse);
          expect(events, contains(SessionEvent.userCheckedIn));

          // Timer restarts — advance 10s again
          events.clear();
          async.elapse(const Duration(seconds: 10));
          expect(events, contains(SessionEvent.checkInRequired));
          expect(engine.missedCheckIns, 1);

          engine.endSession();
        });
      });

      test('checkIn during escalation stops it', () {
        fakeAsync((async) {
          final engine = SessionEngine(
            escalationChain: chain,
            mechanism: CheckInMechanism.holdButton,
            checkInInterval: const Duration(seconds: 5),
            missedTolerance: 0,
          );

          final events = <SessionEvent>[];
          engine.events.listen(events.add);

          engine.start();

          // Trigger escalation
          async.elapse(const Duration(seconds: 5));
          expect(engine.isEscalating, isTrue);

          // Check in
          engine.checkIn();
          async.flushMicrotasks();
          expect(engine.isEscalating, isFalse);
          expect(engine.missedCheckIns, 0);
          expect(engine.currentStepIndex, -1);

          // No more step events should fire (only the check-in timer)
          events.clear();
          async.elapse(const Duration(seconds: 4));
          expect(
            events.where((e) => e != SessionEvent.checkInRequired),
            isEmpty,
          );

          engine.endSession();
        });
      });
    });

    group('endSession() cancels all timers', () {
      test('emits sessionEnded and no further events', () {
        fakeAsync((async) {
          final engine = SessionEngine(
            escalationChain: chain,
            mechanism: CheckInMechanism.holdButton,
            checkInInterval: const Duration(seconds: 10),
            missedTolerance: 0,
          );

          final events = <SessionEvent>[];
          engine.events.listen(events.add);

          engine.start();

          async.elapse(const Duration(seconds: 5));
          engine.endSession();
          async.flushMicrotasks();

          expect(events, [SessionEvent.sessionEnded]);

          // No more events after ending
          async.elapse(const Duration(seconds: 60));
          expect(events, [SessionEvent.sessionEnded]);
        });
      });

      test('endSession during escalation stops everything', () {
        fakeAsync((async) {
          final engine = SessionEngine(
            escalationChain: chain,
            mechanism: CheckInMechanism.holdButton,
            checkInInterval: const Duration(seconds: 3),
            missedTolerance: 0,
          );

          final events = <SessionEvent>[];
          engine.events.listen(events.add);

          engine.start();

          // Trigger escalation
          async.elapse(const Duration(seconds: 3));
          expect(engine.isEscalating, isTrue);

          engine.endSession();
          async.flushMicrotasks();

          // Should have added sessionEnded
          expect(events.last, SessionEvent.sessionEnded);

          final countAfterEnd = events.length;

          // No more step advancement
          async.elapse(const Duration(seconds: 60));
          expect(events.length, countAfterEnd);
        });
      });
    });

    group('date mode tolerance counting', () {
      test('tolerates configured number of misses before escalation', () {
        fakeAsync((async) {
          final engine = SessionEngine(
            escalationChain: chain,
            mechanism: CheckInMechanism.disguisedReminder,
            checkInInterval: const Duration(seconds: 10),
            missedTolerance: 2,
          );

          final events = <SessionEvent>[];
          engine.events.listen(events.add);

          engine.start();

          // Miss 1: should not escalate
          async.elapse(const Duration(seconds: 10));
          expect(engine.missedCheckIns, 1);
          expect(engine.isEscalating, isFalse);
          expect(events, [SessionEvent.checkInRequired]);

          // Miss 2: still within tolerance
          async.elapse(const Duration(seconds: 10));
          expect(engine.missedCheckIns, 2);
          expect(engine.isEscalating, isFalse);

          // Miss 3: exceeds tolerance → escalation starts
          async.elapse(const Duration(seconds: 10));
          expect(engine.missedCheckIns, 3);
          expect(engine.isEscalating, isTrue);
          expect(events, contains(SessionEvent.warningStarted));

          engine.endSession();
        });
      });

      test('tolerance 0 means escalation after first miss', () {
        fakeAsync((async) {
          final engine = SessionEngine(
            escalationChain: chain,
            mechanism: CheckInMechanism.disguisedReminder,
            checkInInterval: const Duration(seconds: 10),
            missedTolerance: 0,
          );

          final events = <SessionEvent>[];
          engine.events.listen(events.add);

          engine.start();

          async.elapse(const Duration(seconds: 10));
          expect(engine.missedCheckIns, 1);
          expect(engine.isEscalating, isTrue);

          engine.endSession();
        });
      });

      test('check-in before tolerance exceeded resets count', () {
        fakeAsync((async) {
          final engine = SessionEngine(
            escalationChain: chain,
            mechanism: CheckInMechanism.disguisedReminder,
            checkInInterval: const Duration(seconds: 10),
            missedTolerance: 2,
          );

          final events = <SessionEvent>[];
          engine.events.listen(events.add);

          engine.start();

          // Miss 1
          async.elapse(const Duration(seconds: 10));
          expect(engine.missedCheckIns, 1);

          // Miss 2
          async.elapse(const Duration(seconds: 10));
          expect(engine.missedCheckIns, 2);

          // Check in before miss 3
          engine.checkIn();
          async.flushMicrotasks();
          expect(engine.missedCheckIns, 0);
          expect(engine.isEscalating, isFalse);

          // Counter restarts from 0
          async.elapse(const Duration(seconds: 10));
          expect(engine.missedCheckIns, 1);
          expect(engine.isEscalating, isFalse);

          engine.endSession();
        });
      });
    });

    group('full escalation walkthrough', () {
      test('walks through all active steps with default walk chain', () {
        fakeAsync((async) {
          final walkChain = EscalationChain.walkDefaults();
          final engine = SessionEngine(
            escalationChain: walkChain,
            mechanism: CheckInMechanism.holdButton,
            checkInInterval: const Duration(seconds: 5),
            missedTolerance: 0,
          );

          final events = <SessionEvent>[];
          engine.events.listen(events.add);

          engine.start();

          // Trigger escalation
          async.elapse(const Duration(seconds: 5));

          // Active steps (alarm disabled): warning(10s) → fakeCall(30s) → sms(15s) → emergency(10s)
          final activeSteps = walkChain.activeSteps;
          expect(activeSteps.length, 4); // alarm is disabled

          expect(events, contains(SessionEvent.warningStarted));

          // Advance through warning timeout (10s)
          async.elapse(const Duration(seconds: 10));
          expect(events, contains(SessionEvent.fakeCallStarted));

          // Advance through fake call timeout (30s)
          async.elapse(const Duration(seconds: 30));
          expect(events, contains(SessionEvent.smsSending));

          // Advance through SMS timeout (15s)
          async.elapse(const Duration(seconds: 15));
          expect(events, contains(SessionEvent.emergencyCallStarted));

          engine.endSession();
        });
      });

      test('walks through date mode chain', () {
        fakeAsync((async) {
          final dateChain = EscalationChain.dateDefaults();
          final engine = SessionEngine(
            escalationChain: dateChain,
            mechanism: CheckInMechanism.disguisedReminder,
            checkInInterval: const Duration(seconds: 5),
            missedTolerance: 2,
          );

          final events = <SessionEvent>[];
          engine.events.listen(events.add);

          engine.start();

          // Miss 3 check-ins (tolerance=2) to trigger escalation
          async.elapse(const Duration(seconds: 15));
          expect(engine.isEscalating, isTrue);

          // Active steps (alarm disabled): disguisedReminder(60s) → fakeCall(30s) → sms(15s) → emergency(10s)
          expect(events, contains(SessionEvent.disguisedReminderFired));

          // Advance through disguised reminder timeout (60s)
          async.elapse(const Duration(seconds: 60));
          expect(events, contains(SessionEvent.fakeCallStarted));

          // Advance through fake call timeout (30s)
          async.elapse(const Duration(seconds: 30));
          expect(events, contains(SessionEvent.smsSending));

          // Advance through SMS timeout (15s)
          async.elapse(const Duration(seconds: 15));
          expect(events, contains(SessionEvent.emergencyCallStarted));

          engine.endSession();
        });
      });
    });

    group('edge cases', () {
      test('cannot start an ended session', () {
        fakeAsync((async) {
          final engine = SessionEngine(
            escalationChain: chain,
            mechanism: CheckInMechanism.holdButton,
            checkInInterval: const Duration(seconds: 10),
            missedTolerance: 0,
          );

          engine.start();
          engine.endSession();

          expect(() => engine.start(), throwsStateError);
        });
      });

      test('holdStart/holdRelease are no-ops after endSession', () {
        fakeAsync((async) {
          final engine = SessionEngine(
            escalationChain: chain,
            mechanism: CheckInMechanism.holdButton,
            checkInInterval: const Duration(seconds: 10),
            missedTolerance: 0,
          );

          engine.start();
          engine.endSession();

          // These should not throw
          engine.holdStart();
          engine.holdRelease();
          engine.checkIn();
        });
      });

      test('empty escalation chain handles gracefully', () {
        fakeAsync((async) {
          final emptyChain = EscalationChain(steps: []);
          final engine = SessionEngine(
            escalationChain: emptyChain,
            mechanism: CheckInMechanism.holdButton,
            checkInInterval: const Duration(seconds: 3),
            missedTolerance: 0,
          );

          final events = <SessionEvent>[];
          engine.events.listen(events.add);

          engine.start();
          async.elapse(const Duration(seconds: 3));

          // Should emit checkInRequired but no step events
          expect(events, [SessionEvent.checkInRequired]);

          engine.endSession();
        });
      });
    });
  });
}
