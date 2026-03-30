import 'package:flutter_test/flutter_test.dart';
import 'package:safewayhome/data/models/escalation_chain.dart';
import 'package:safewayhome/data/models/escalation_step.dart';

void main() {
  group('EscalationChain.walkDefaults()', () {
    late EscalationChain chain;

    setUp(() {
      chain = EscalationChain.walkDefaults();
    });

    test('has exactly 5 steps', () {
      expect(chain.steps.length, 5);
    });

    test('steps are in correct order by type', () {
      expect(chain.steps[0].type, EscalationStepType.countdownWarning);
      expect(chain.steps[1].type, EscalationStepType.fakeCall);
      expect(chain.steps[2].type, EscalationStepType.smsContacts);
      expect(chain.steps[3].type, EscalationStepType.loudAlarm);
      expect(chain.steps[4].type, EscalationStepType.callEmergencyServices);
    });

    test('steps have correct order values', () {
      for (var i = 0; i < chain.steps.length; i++) {
        expect(chain.steps[i].order, i);
      }
    });

    test('alarm step is disabled', () {
      final alarm = chain.steps.firstWhere(
        (s) => s.type == EscalationStepType.loudAlarm,
      );
      expect(alarm.enabled, isFalse);
    });

    test('all non-alarm steps are enabled', () {
      for (final step in chain.steps) {
        if (step.type != EscalationStepType.loudAlarm) {
          expect(step.enabled, isTrue,
              reason: '${step.type} should be enabled');
        }
      }
    });

    test('activeSteps has 4 steps (alarm excluded)', () {
      expect(chain.activeSteps.length, 4);
    });

    test('activeSteps are in correct order', () {
      final active = chain.activeSteps;
      expect(active[0].type, EscalationStepType.countdownWarning);
      expect(active[1].type, EscalationStepType.fakeCall);
      expect(active[2].type, EscalationStepType.smsContacts);
      expect(active[3].type, EscalationStepType.callEmergencyServices);
    });

    test('steps have expected timeouts', () {
      expect(chain.steps[0].timeoutSeconds, 10); // countdown warning
      expect(chain.steps[1].timeoutSeconds, 30); // fake call
      expect(chain.steps[2].timeoutSeconds, 15); // sms
      expect(chain.steps[3].timeoutSeconds, 30); // alarm
      expect(chain.steps[4].timeoutSeconds, 10); // emergency call
    });
  });

  group('EscalationChain.dateDefaults()', () {
    late EscalationChain chain;

    setUp(() {
      chain = EscalationChain.dateDefaults();
    });

    test('has exactly 5 steps', () {
      expect(chain.steps.length, 5);
    });

    test('first step is disguisedReminder', () {
      expect(chain.steps[0].type, EscalationStepType.disguisedReminder);
    });

    test('steps are in correct order by type', () {
      expect(chain.steps[0].type, EscalationStepType.disguisedReminder);
      expect(chain.steps[1].type, EscalationStepType.fakeCall);
      expect(chain.steps[2].type, EscalationStepType.smsContacts);
      expect(chain.steps[3].type, EscalationStepType.loudAlarm);
      expect(chain.steps[4].type, EscalationStepType.callEmergencyServices);
    });

    test('alarm is disabled', () {
      final alarm = chain.steps.firstWhere(
        (s) => s.type == EscalationStepType.loudAlarm,
      );
      expect(alarm.enabled, isFalse);
    });

    test('activeSteps has 4 steps', () {
      expect(chain.activeSteps.length, 4);
    });

    test('activeSteps starts with disguisedReminder', () {
      expect(chain.activeSteps[0].type, EscalationStepType.disguisedReminder);
    });

    test('disguisedReminder has 60s timeout', () {
      expect(chain.steps[0].timeoutSeconds, 60);
    });
  });

  group('EscalationChain.activeSteps', () {
    test('filters out disabled steps', () {
      final chain = EscalationChain(steps: [
        EscalationStep(
          type: EscalationStepType.fakeCall,
          timeoutSeconds: 30,
          order: 0,
          enabled: true,
        ),
        EscalationStep(
          type: EscalationStepType.loudAlarm,
          timeoutSeconds: 30,
          order: 1,
          enabled: false,
        ),
        EscalationStep(
          type: EscalationStepType.smsContacts,
          timeoutSeconds: 15,
          order: 2,
          enabled: true,
        ),
      ]);

      expect(chain.activeSteps.length, 2);
      expect(
        chain.activeSteps.map((s) => s.type).toList(),
        [EscalationStepType.fakeCall, EscalationStepType.smsContacts],
      );
    });

    test('sorts by order regardless of insertion order', () {
      final chain = EscalationChain(steps: [
        EscalationStep(
          type: EscalationStepType.smsContacts,
          timeoutSeconds: 15,
          order: 2,
        ),
        EscalationStep(
          type: EscalationStepType.countdownWarning,
          timeoutSeconds: 10,
          order: 0,
        ),
        EscalationStep(
          type: EscalationStepType.fakeCall,
          timeoutSeconds: 30,
          order: 1,
        ),
      ]);

      final active = chain.activeSteps;
      expect(active[0].order, 0);
      expect(active[1].order, 1);
      expect(active[2].order, 2);
    });

    test('returns empty list when all steps are disabled', () {
      final chain = EscalationChain(steps: [
        EscalationStep(
          type: EscalationStepType.fakeCall,
          timeoutSeconds: 30,
          order: 0,
          enabled: false,
        ),
        EscalationStep(
          type: EscalationStepType.loudAlarm,
          timeoutSeconds: 30,
          order: 1,
          enabled: false,
        ),
      ]);

      expect(chain.activeSteps, isEmpty);
    });

    test('returns empty list for empty chain', () {
      final chain = EscalationChain(steps: []);
      expect(chain.activeSteps, isEmpty);
    });
  });
}
