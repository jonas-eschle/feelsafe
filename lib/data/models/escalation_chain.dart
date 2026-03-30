import 'escalation_step.dart';

class EscalationChain {
  final List<EscalationStep> steps;

  EscalationChain({required this.steps});

  /// Returns only enabled steps, sorted by order.
  List<EscalationStep> get activeSteps =>
      steps.where((s) => s.enabled).toList()
        ..sort((a, b) => a.order.compareTo(b.order));

  /// Default walk mode chain. Alarm is disabled by default.
  factory EscalationChain.walkDefaults() => EscalationChain(steps: [
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
        EscalationStep(
          type: EscalationStepType.smsContacts,
          timeoutSeconds: 15,
          order: 2,
        ),
        EscalationStep(
          type: EscalationStepType.loudAlarm,
          timeoutSeconds: 30,
          order: 3,
          enabled: false,
        ),
        EscalationStep(
          type: EscalationStepType.callEmergencyServices,
          timeoutSeconds: 10,
          order: 4,
        ),
      ]);

  /// Default date mode chain.
  factory EscalationChain.dateDefaults() => EscalationChain(steps: [
        EscalationStep(
          type: EscalationStepType.disguisedReminder,
          timeoutSeconds: 60,
          order: 0,
        ),
        EscalationStep(
          type: EscalationStepType.fakeCall,
          timeoutSeconds: 30,
          order: 1,
        ),
        EscalationStep(
          type: EscalationStepType.smsContacts,
          timeoutSeconds: 15,
          order: 2,
        ),
        EscalationStep(
          type: EscalationStepType.loudAlarm,
          timeoutSeconds: 30,
          order: 3,
          enabled: false,
        ),
        EscalationStep(
          type: EscalationStepType.callEmergencyServices,
          timeoutSeconds: 10,
          order: 4,
        ),
      ]);
}
