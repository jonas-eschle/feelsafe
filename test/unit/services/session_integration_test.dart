import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safewayhome/data/models/escalation_chain.dart';
import 'package:safewayhome/data/models/escalation_step.dart';
import 'package:safewayhome/data/models/session_mode.dart';
import 'package:safewayhome/features/session/session_engine.dart';

void main() {
  group('Walk mode integration flow', () {
    test('start → hold → release → countdown → hold (check-in) → end', () {
      fakeAsync((async) {
        final engine = SessionEngine(
          escalationChain: EscalationChain.walkDefaults(),
          mechanism: CheckInMechanism.holdButton,
          checkInInterval: const Duration(seconds: 10),
          missedTolerance: 0,
        );

        final events = <SessionEvent>[];
        engine.events.listen(events.add);

        // 1. Start session
        engine.start();
        expect(engine.isEscalating, isFalse);

        // 2. User holds the button (safe state)
        engine.holdStart();
        expect(engine.isHolding, isTrue);
        async.elapse(const Duration(seconds: 30));
        expect(events, isEmpty); // No events while holding

        // 3. User releases — 10s countdown starts
        engine.holdRelease();
        expect(engine.isHolding, isFalse);
        async.elapse(const Duration(seconds: 5));
        expect(events, isEmpty); // Not yet

        // 4. User re-holds within countdown (check-in)
        engine.holdStart();
        async.elapse(const Duration(seconds: 20));
        expect(events, isEmpty); // Timer was cancelled by hold

        // 5. Release again
        engine.holdRelease();
        async.elapse(const Duration(seconds: 10));
        // Now countdown expired → escalation starts
        expect(events, contains(SessionEvent.checkInRequired));
        expect(events, contains(SessionEvent.warningStarted));
        expect(engine.isEscalating, isTrue);

        // 6. User holds during escalation → check-in resets everything
        engine.holdStart();
        async.flushMicrotasks();
        expect(events, contains(SessionEvent.userCheckedIn));
        expect(engine.isEscalating, isFalse);

        // 7. End session
        engine.endSession();
        async.flushMicrotasks();
        expect(events.last, SessionEvent.sessionEnded);
      });
    });

    test('full escalation: miss → warning → fakeCall → SMS → emergency', () {
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

        // Miss the check-in → escalation begins
        async.elapse(const Duration(seconds: 10));
        expect(events, contains(SessionEvent.checkInRequired));
        expect(events, contains(SessionEvent.warningStarted));
        expect(engine.currentStepIndex, 0);

        // Warning step timeout (10s) → fake call
        async.elapse(const Duration(seconds: 10));
        expect(events, contains(SessionEvent.fakeCallStarted));

        // Fake call timeout (30s) → SMS
        async.elapse(const Duration(seconds: 30));
        expect(events, contains(SessionEvent.smsSending));

        // SMS timeout (15s) → emergency call (alarm is disabled)
        async.elapse(const Duration(seconds: 15));
        expect(events, contains(SessionEvent.emergencyCallStarted));

        // Alarm was NOT triggered (disabled in walk defaults)
        expect(events, isNot(contains(SessionEvent.alarmStarted)));

        engine.endSession();
      });
    });

    test('multiple hold/release cycles without escalation', () {
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

        // Cycle 1: hold 5s, release, re-hold within 10s
        engine.holdStart();
        async.elapse(const Duration(seconds: 5));
        engine.holdRelease();
        async.elapse(const Duration(seconds: 8));
        engine.holdStart();
        async.elapse(const Duration(seconds: 3));
        expect(events, isEmpty);

        // Cycle 2
        engine.holdRelease();
        async.elapse(const Duration(seconds: 9));
        engine.holdStart();
        async.elapse(const Duration(seconds: 2));
        expect(events, isEmpty);

        // Cycle 3
        engine.holdRelease();
        async.elapse(const Duration(seconds: 7));
        engine.holdStart();
        expect(events, isEmpty);

        // No escalation occurred
        expect(engine.isEscalating, isFalse);

        engine.endSession();
      });
    });
  });

  group('Date mode integration flow', () {
    test('start → reminder → confirm → reminder → miss → miss → escalation',
        () {
      fakeAsync((async) {
        final engine = SessionEngine(
          escalationChain: EscalationChain.dateDefaults(),
          mechanism: CheckInMechanism.disguisedReminder,
          checkInInterval: const Duration(seconds: 30),
          missedTolerance: 2,
        );

        final events = <SessionEvent>[];
        engine.events.listen(events.add);

        engine.start();

        // 1. First reminder fires after 30s
        async.elapse(const Duration(seconds: 30));
        expect(events.last, SessionEvent.checkInRequired);
        expect(engine.missedCheckIns, 1);

        // 2. User checks in
        engine.checkIn();
        async.flushMicrotasks();
        expect(engine.missedCheckIns, 0);
        expect(events.last, SessionEvent.userCheckedIn);

        // 3. Second reminder fires
        events.clear();
        async.elapse(const Duration(seconds: 30));
        expect(events.last, SessionEvent.checkInRequired);
        expect(engine.missedCheckIns, 1);

        // 4. User misses again
        async.elapse(const Duration(seconds: 30));
        expect(engine.missedCheckIns, 2);

        // 5. Third miss → exceeds tolerance (2), escalation starts
        async.elapse(const Duration(seconds: 30));
        expect(engine.missedCheckIns, 3);
        expect(engine.isEscalating, isTrue);
        expect(events, contains(SessionEvent.disguisedReminderFired));

        engine.endSession();
      });
    });

    test('check-in during escalation resets everything', () {
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

        // Check in during escalation
        engine.checkIn();
        async.flushMicrotasks();
        expect(engine.isEscalating, isFalse);
        expect(engine.missedCheckIns, 0);
        expect(engine.currentStepIndex, -1);
        expect(events, contains(SessionEvent.userCheckedIn));

        // Session continues normally
        events.clear();
        async.elapse(const Duration(seconds: 10));
        expect(events, contains(SessionEvent.checkInRequired));

        engine.endSession();
      });
    });

    test('date mode full escalation chain walks through all steps', () {
      fakeAsync((async) {
        final engine = SessionEngine(
          escalationChain: EscalationChain.dateDefaults(),
          mechanism: CheckInMechanism.disguisedReminder,
          checkInInterval: const Duration(seconds: 5),
          missedTolerance: 0,
        );

        final events = <SessionEvent>[];
        engine.events.listen(events.add);

        engine.start();

        // Trigger escalation
        async.elapse(const Duration(seconds: 5));
        expect(engine.isEscalating, isTrue);

        // Date defaults active steps: disguised(60s) → fakeCall(30s) → sms(15s) → emergency(10s)
        expect(events, contains(SessionEvent.disguisedReminderFired));

        async.elapse(const Duration(seconds: 60));
        expect(events, contains(SessionEvent.fakeCallStarted));

        async.elapse(const Duration(seconds: 30));
        expect(events, contains(SessionEvent.smsSending));

        async.elapse(const Duration(seconds: 15));
        expect(events, contains(SessionEvent.emergencyCallStarted));

        engine.endSession();
      });
    });
  });

  group('Edge cases', () {
    test('multiple rapid check-ins are safe', () {
      fakeAsync((async) {
        final engine = SessionEngine(
          escalationChain: EscalationChain.walkDefaults(),
          mechanism: CheckInMechanism.disguisedReminder,
          checkInInterval: const Duration(seconds: 10),
          missedTolerance: 2,
        );

        engine.start();

        // Rapid check-ins should not throw
        engine.checkIn();
        engine.checkIn();
        engine.checkIn();
        async.flushMicrotasks();

        expect(engine.missedCheckIns, 0);
        expect(engine.isEscalating, isFalse);

        engine.endSession();
      });
    });

    test('endSession during escalation prevents further events', () {
      fakeAsync((async) {
        final engine = SessionEngine(
          escalationChain: EscalationChain.walkDefaults(),
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

        // End mid-escalation
        engine.endSession();
        async.flushMicrotasks();
        final eventCount = events.length;

        // No more events should appear
        async.elapse(const Duration(minutes: 10));
        expect(events.length, eventCount);
      });
    });

    test('all escalation steps disabled means no step events during escalation',
        () {
      fakeAsync((async) {
        final chain = EscalationChain(steps: [
          EscalationStep(
            type: EscalationStepType.countdownWarning,
            timeoutSeconds: 10,
            order: 0,
            enabled: false,
          ),
          EscalationStep(
            type: EscalationStepType.fakeCall,
            timeoutSeconds: 10,
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

        // Only checkInRequired, no step events
        expect(events, [SessionEvent.checkInRequired]);

        engine.endSession();
      });
    });

    test('tolerance exactly at boundary', () {
      fakeAsync((async) {
        final engine = SessionEngine(
          escalationChain: EscalationChain.walkDefaults(),
          mechanism: CheckInMechanism.disguisedReminder,
          checkInInterval: const Duration(seconds: 5),
          missedTolerance: 1,
        );

        final events = <SessionEvent>[];
        engine.events.listen(events.add);

        engine.start();

        // Miss 1: within tolerance
        async.elapse(const Duration(seconds: 5));
        expect(engine.missedCheckIns, 1);
        expect(engine.isEscalating, isFalse);

        // Miss 2: exceeds tolerance → escalation
        async.elapse(const Duration(seconds: 5));
        expect(engine.missedCheckIns, 2);
        expect(engine.isEscalating, isTrue);

        engine.endSession();
      });
    });
  });
}
