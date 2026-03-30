import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safewayhome/data/models/escalation_chain.dart';
import 'package:safewayhome/data/models/escalation_step.dart';
import 'package:safewayhome/data/models/session_mode.dart';
import 'package:safewayhome/features/session/session_engine.dart';

void main() {
  group('Full walk mode escalation flow', () {
    test(
        'start → miss check-in → warning → fakeCall → SMS → emergency call, events in correct order with correct timing',
        () {
      fakeAsync((async) {
        final chain = EscalationChain.walkDefaults();
        final engine = SessionEngine(
          escalationChain: chain,
          mechanism: CheckInMechanism.holdButton,
          checkInInterval: const Duration(seconds: 10),
          missedTolerance: 0,
        );

        final events = <SessionEvent>[];
        engine.events.listen(events.add);

        // Record start time
        engine.start();
        expect(engine.isEscalating, isFalse);

        // Miss check-in after 10s
        async.elapse(const Duration(seconds: 10));
        expect(events, contains(SessionEvent.checkInRequired));
        expect(events, contains(SessionEvent.warningStarted));
        expect(engine.isEscalating, isTrue);
        expect(engine.currentStepIndex, 0);

        // Warning step (10s) → fake call
        async.elapse(const Duration(seconds: 10));
        expect(events, contains(SessionEvent.fakeCallStarted));
        expect(engine.currentStepIndex, 1);

        // Fake call step (30s) → SMS
        async.elapse(const Duration(seconds: 30));
        expect(events, contains(SessionEvent.smsSending));
        expect(engine.currentStepIndex, 2);

        // SMS step (15s) → emergency call (alarm is disabled)
        async.elapse(const Duration(seconds: 15));
        expect(events, contains(SessionEvent.emergencyCallStarted));

        // Alarm was NOT triggered (disabled in walk defaults)
        expect(events, isNot(contains(SessionEvent.alarmStarted)));

        // Verify event order
        final eventOrder = [
          SessionEvent.checkInRequired,
          SessionEvent.warningStarted,
          SessionEvent.fakeCallStarted,
          SessionEvent.smsSending,
          SessionEvent.emergencyCallStarted,
        ];
        final filteredEvents = events
            .where((e) => eventOrder.contains(e))
            .toList();
        expect(filteredEvents, eventOrder);

        engine.endSession();
      });
    });
  });

  group('Full date mode escalation flow', () {
    test(
        'start → miss tolerance → disguisedReminder → fakeCall → SMS → emergency',
        () {
      fakeAsync((async) {
        final chain = EscalationChain.dateDefaults();
        final engine = SessionEngine(
          escalationChain: chain,
          mechanism: CheckInMechanism.disguisedReminder,
          checkInInterval: const Duration(seconds: 10),
          missedTolerance: 1,
        );

        final events = <SessionEvent>[];
        engine.events.listen(events.add);

        engine.start();

        // First miss at 10s — within tolerance
        async.elapse(const Duration(seconds: 10));
        expect(engine.missedCheckIns, 1);
        expect(engine.isEscalating, isFalse);

        // Second miss at 20s — exceeds tolerance, escalation starts
        async.elapse(const Duration(seconds: 10));
        expect(engine.missedCheckIns, 2);
        expect(engine.isEscalating, isTrue);
        expect(events, contains(SessionEvent.disguisedReminderFired));

        // Disguised reminder step (60s) → fake call
        async.elapse(const Duration(seconds: 60));
        expect(events, contains(SessionEvent.fakeCallStarted));

        // Fake call step (30s) → SMS
        async.elapse(const Duration(seconds: 30));
        expect(events, contains(SessionEvent.smsSending));

        // SMS step (15s) → emergency call
        async.elapse(const Duration(seconds: 15));
        expect(events, contains(SessionEvent.emergencyCallStarted));

        engine.endSession();
      });
    });
  });

  group('Check-in resets mid-escalation', () {
    test('check-in during warning step resets everything and restarts timer',
        () {
      fakeAsync((async) {
        final engine = SessionEngine(
          escalationChain: EscalationChain.walkDefaults(),
          mechanism: CheckInMechanism.holdButton,
          checkInInterval: const Duration(seconds: 10),
          missedTolerance: 0,
        );

        final events = <SessionEvent>[];
        engine.events.listen(events.add);

        engine.start();

        // Miss → escalation
        async.elapse(const Duration(seconds: 10));
        expect(engine.isEscalating, isTrue);

        // Check in during warning step
        engine.holdStart();
        async.flushMicrotasks();
        expect(engine.isEscalating, isFalse);
        expect(engine.currentStepIndex, -1);
        expect(events, contains(SessionEvent.userCheckedIn));

        // Release — timer restarts
        engine.holdRelease();
        events.clear();

        // Should not escalate if we hold again within interval
        async.elapse(const Duration(seconds: 8));
        engine.holdStart();
        async.elapse(const Duration(seconds: 5));
        expect(engine.isEscalating, isFalse);

        engine.endSession();
      });
    });

    test('date mode check-in mid-escalation resets missed count', () {
      fakeAsync((async) {
        final engine = SessionEngine(
          escalationChain: EscalationChain.dateDefaults(),
          mechanism: CheckInMechanism.disguisedReminder,
          checkInInterval: const Duration(seconds: 10),
          missedTolerance: 0,
        );

        final events = <SessionEvent>[];
        engine.events.listen(events.add);

        engine.start();

        // Miss → escalation
        async.elapse(const Duration(seconds: 10));
        expect(engine.isEscalating, isTrue);

        // Check in
        engine.checkIn();
        async.flushMicrotasks();
        expect(engine.isEscalating, isFalse);
        expect(engine.missedCheckIns, 0);
        expect(events, contains(SessionEvent.userCheckedIn));

        engine.endSession();
      });
    });
  });

  group('Custom escalation chain', () {
    test('only enabled steps fire in correct order', () {
      fakeAsync((async) {
        final chain = EscalationChain(steps: [
          EscalationStep(
            type: EscalationStepType.countdownWarning,
            timeoutSeconds: 5,
            order: 0,
            enabled: false, // disabled
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
        ]);

        final engine = SessionEngine(
          escalationChain: chain,
          mechanism: CheckInMechanism.holdButton,
          checkInInterval: const Duration(seconds: 5),
          missedTolerance: 0,
        );

        final events = <SessionEvent>[];
        engine.events.listen(events.add);

        engine.start();

        // Miss check-in → escalation begins
        async.elapse(const Duration(seconds: 5));
        expect(engine.isEscalating, isTrue);

        // Warning is disabled, so first active step is fakeCall
        expect(events, isNot(contains(SessionEvent.warningStarted)));
        expect(events, contains(SessionEvent.fakeCallStarted));

        // Fake call timeout (10s) → SMS
        async.elapse(const Duration(seconds: 10));
        expect(events, contains(SessionEvent.smsSending));

        engine.endSession();
      });
    });

    test('all steps disabled means escalation flag set but no step events', () {
      fakeAsync((async) {
        final chain = EscalationChain(steps: [
          EscalationStep(
            type: EscalationStepType.countdownWarning,
            timeoutSeconds: 5,
            order: 0,
            enabled: false,
          ),
          EscalationStep(
            type: EscalationStepType.fakeCall,
            timeoutSeconds: 5,
            order: 1,
            enabled: false,
          ),
        ]);

        final engine = SessionEngine(
          escalationChain: chain,
          mechanism: CheckInMechanism.holdButton,
          checkInInterval: const Duration(seconds: 5),
          missedTolerance: 0,
        );

        final events = <SessionEvent>[];
        engine.events.listen(events.add);

        engine.start();
        async.elapse(const Duration(seconds: 5));

        // Only checkInRequired fires, no step events
        expect(events, [SessionEvent.checkInRequired]);

        engine.endSession();
      });
    });
  });

  group('Tolerance boundary behavior', () {
    test('tolerance=2 escalates on 3rd miss', () {
      fakeAsync((async) {
        final engine = SessionEngine(
          escalationChain: EscalationChain.walkDefaults(),
          mechanism: CheckInMechanism.disguisedReminder,
          checkInInterval: const Duration(seconds: 5),
          missedTolerance: 2,
        );

        engine.start();

        // Miss 1
        async.elapse(const Duration(seconds: 5));
        expect(engine.missedCheckIns, 1);
        expect(engine.isEscalating, isFalse);

        // Miss 2
        async.elapse(const Duration(seconds: 5));
        expect(engine.missedCheckIns, 2);
        expect(engine.isEscalating, isFalse);

        // Miss 3 — exceeds tolerance
        async.elapse(const Duration(seconds: 5));
        expect(engine.missedCheckIns, 3);
        expect(engine.isEscalating, isTrue);

        engine.endSession();
      });
    });

    test('check-in at boundary resets count', () {
      fakeAsync((async) {
        final engine = SessionEngine(
          escalationChain: EscalationChain.walkDefaults(),
          mechanism: CheckInMechanism.disguisedReminder,
          checkInInterval: const Duration(seconds: 5),
          missedTolerance: 2,
        );

        engine.start();

        // Miss 1 and 2
        async.elapse(const Duration(seconds: 10));
        expect(engine.missedCheckIns, 2);
        expect(engine.isEscalating, isFalse);

        // Check in at boundary
        engine.checkIn();
        async.flushMicrotasks();
        expect(engine.missedCheckIns, 0);

        // Miss 1 again — should NOT escalate
        async.elapse(const Duration(seconds: 5));
        expect(engine.missedCheckIns, 1);
        expect(engine.isEscalating, isFalse);

        engine.endSession();
      });
    });
  });
}
