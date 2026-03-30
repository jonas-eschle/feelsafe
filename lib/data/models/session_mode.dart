import 'package:hive/hive.dart';
import 'escalation_step.dart';

part 'session_mode.g.dart';

@HiveType(typeId: 7)
enum CheckInMechanism {
  @HiveField(0)
  holdButton,

  @HiveField(1)
  disguisedReminder,
}

@HiveType(typeId: 8)
class SessionMode extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? iconName;

  @HiveField(3)
  CheckInMechanism checkInMechanism;

  /// Interval in seconds between check-ins.
  /// For holdButton mode: countdown after release (default 10s).
  /// For disguisedReminder mode: interval between reminders (default 1800s = 30min).
  @HiveField(4)
  int checkInIntervalSeconds;

  /// How many missed check-ins before escalation starts.
  @HiveField(5)
  int missedTolerance;

  @HiveField(6)
  List<EscalationStep> escalationSteps;

  /// IDs of reminder templates to use (for disguisedReminder mode).
  @HiveField(7)
  List<String> reminderTemplateIds;

  /// Whether this is a built-in mode (cannot be deleted).
  @HiveField(8)
  bool isBuiltIn;

  SessionMode({
    required this.id,
    required this.name,
    this.iconName,
    required this.checkInMechanism,
    required this.checkInIntervalSeconds,
    this.missedTolerance = 0,
    required this.escalationSteps,
    this.reminderTemplateIds = const [],
    this.isBuiltIn = false,
  });

  Duration get checkInInterval => Duration(seconds: checkInIntervalSeconds);

  SessionMode copyWith({
    String? name,
    String? iconName,
    CheckInMechanism? checkInMechanism,
    int? checkInIntervalSeconds,
    int? missedTolerance,
    List<EscalationStep>? escalationSteps,
    List<String>? reminderTemplateIds,
  }) {
    return SessionMode(
      id: id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      checkInMechanism: checkInMechanism ?? this.checkInMechanism,
      checkInIntervalSeconds:
          checkInIntervalSeconds ?? this.checkInIntervalSeconds,
      missedTolerance: missedTolerance ?? this.missedTolerance,
      escalationSteps: escalationSteps ?? this.escalationSteps,
      reminderTemplateIds: reminderTemplateIds ?? this.reminderTemplateIds,
      isBuiltIn: isBuiltIn,
    );
  }
}
