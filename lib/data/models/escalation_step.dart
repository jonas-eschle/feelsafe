import 'package:hive/hive.dart';

part 'escalation_step.g.dart';

@HiveType(typeId: 2)
enum EscalationStepType {
  @HiveField(0)
  countdownWarning,

  @HiveField(1)
  disguisedReminder,

  @HiveField(2)
  fakeCall,

  @HiveField(3)
  smsContacts,

  @HiveField(4)
  loudAlarm,

  @HiveField(5)
  callEmergencyServices,
}

@HiveType(typeId: 3)
class EscalationStep extends HiveObject {
  @HiveField(0)
  final EscalationStepType type;

  @HiveField(1)
  int timeoutSeconds;

  @HiveField(2)
  bool enabled;

  @HiveField(3)
  int order;

  EscalationStep({
    required this.type,
    required this.timeoutSeconds,
    this.enabled = true,
    required this.order,
  });

  Duration get timeout => Duration(seconds: timeoutSeconds);

  EscalationStep copyWith({
    int? timeoutSeconds,
    bool? enabled,
    int? order,
  }) {
    return EscalationStep(
      type: type,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
      enabled: enabled ?? this.enabled,
      order: order ?? this.order,
    );
  }
}
