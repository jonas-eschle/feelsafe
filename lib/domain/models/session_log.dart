import 'package:guardianangela/domain/enums/end_reason.dart';
import 'package:guardianangela/domain/models/session_log_event.dart';

/// A persisted record of a completed (or in-progress) safety session.
///
/// Stored in the Drift `session_logs` table (encrypted via sqlite3mc).
/// Events are serialised as a JSON column within the row. See spec 03
/// §SessionLog.
///
/// Smart retention per B8: non-critical logs are soft-deleted after
/// [AppSettings.sessionLogRetentionDays] days; critical logs (those with
/// destructive actions or distress chain events) are kept indefinitely.
final class SessionLog {
  /// Creates a session log.
  const SessionLog({
    required this.id,
    required this.modeId,
    required this.modeName,
    required this.startedAt,
    this.endedAt,
    this.endReason,
    required this.isSimulation,
    this.hadMedicalInfo = false,
    required this.events,
    this.deletedAt,
  });

  /// UUID — primary key.
  final String id;

  /// UUID of the [SessionMode] that ran.
  final String modeId;

  /// Human-readable mode name cached at session start (in case mode is
  /// later deleted).
  final String modeName;

  /// UTC timestamp when the session started.
  final DateTime startedAt;

  /// UTC timestamp when the session ended. Null if session is still active.
  final DateTime? endedAt;

  /// Why the session ended. Null if still running.
  final EndReason? endReason;

  /// Whether this was a simulation session.
  final bool isSimulation;

  /// True iff at least one [smsContact] step in the session had
  /// [SmsContactConfig.includeMedicalInfo] = true AND the user profile had
  /// any medical information at session start (Extra 47).
  final bool hadMedicalInfo;

  /// Ordered timeline of events that occurred during the session.
  final List<SessionLogEvent> events;

  /// UTC timestamp when the log was soft-deleted (moved to the trash).
  ///
  /// Null while the log is "live" (visible in the past-events list).
  /// Set to a non-null timestamp by the trash flow (spec 04:2455–2459 /
  /// spec 03:970); the row stays in the table until
  /// `purgeExpiredLogs` hard-deletes it after the
  /// `AppSettings.trashRetentionDays` (default 7) window elapses.
  final DateTime? deletedAt;

  /// Returns a copy with the specified fields replaced.
  ///
  /// To clear [deletedAt] (restore from trash) pass `clearDeletedAt: true`.
  SessionLog copyWith({
    String? id,
    String? modeId,
    String? modeName,
    DateTime? startedAt,
    DateTime? endedAt,
    EndReason? endReason,
    bool? isSimulation,
    bool? hadMedicalInfo,
    List<SessionLogEvent>? events,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) => SessionLog(
    id: id ?? this.id,
    modeId: modeId ?? this.modeId,
    modeName: modeName ?? this.modeName,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt ?? this.endedAt,
    endReason: endReason ?? this.endReason,
    isSimulation: isSimulation ?? this.isSimulation,
    hadMedicalInfo: hadMedicalInfo ?? this.hadMedicalInfo,
    events: events ?? this.events,
    deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
  );

  /// Serialises this log to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'modeId': modeId,
    'modeName': modeName,
    'startedAt': startedAt.toUtc().toIso8601String(),
    if (endedAt != null) 'endedAt': endedAt!.toUtc().toIso8601String(),
    if (endReason != null) 'endReason': endReason!.name,
    'isSimulation': isSimulation,
    'hadMedicalInfo': hadMedicalInfo,
    'events': events.map((e) => e.toJson()).toList(),
    if (deletedAt != null) 'deletedAt': deletedAt!.toUtc().toIso8601String(),
  };

  /// Deserialises a [SessionLog] from [json].
  factory SessionLog.fromJson(Map<String, dynamic> json) => SessionLog(
    id: json['id'] as String,
    modeId: json['modeId'] as String,
    modeName: json['modeName'] as String,
    startedAt: DateTime.parse(json['startedAt'] as String).toUtc(),
    endedAt: json['endedAt'] != null
        ? DateTime.parse(json['endedAt'] as String).toUtc()
        : null,
    endReason: json['endReason'] != null
        ? EndReason.values.byName(json['endReason'] as String)
        : null,
    isSimulation: json['isSimulation'] as bool,
    hadMedicalInfo: (json['hadMedicalInfo'] as bool?) ?? false,
    events: (json['events'] as List<dynamic>)
        .map((e) => SessionLogEvent.fromJson(e as Map<String, dynamic>))
        .toList(),
    deletedAt: json['deletedAt'] != null
        ? DateTime.parse(json['deletedAt'] as String).toUtc()
        : null,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! SessionLog) {
      return false;
    }
    if (events.length != other.events.length) {
      return false;
    }
    for (var i = 0; i < events.length; i++) {
      if (events[i] != other.events[i]) {
        return false;
      }
    }
    return id == other.id &&
        modeId == other.modeId &&
        modeName == other.modeName &&
        startedAt == other.startedAt &&
        endedAt == other.endedAt &&
        endReason == other.endReason &&
        isSimulation == other.isSimulation &&
        hadMedicalInfo == other.hadMedicalInfo &&
        deletedAt == other.deletedAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    modeId,
    modeName,
    startedAt,
    endedAt,
    endReason,
    isSimulation,
    hadMedicalInfo,
    deletedAt,
    Object.hashAll(events),
  );
}
