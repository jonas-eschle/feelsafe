/// `SessionLog` + `SessionLogEvent` — persisted history of completed
/// sessions.
///
/// One log is produced per session; events are appended as the
/// engine emits them. The log is shareable as text / JSON via the
/// evidence-export flow.
library;

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/engine/engine_state.dart';
import 'package:guardianangela/domain/models/chain_event.dart';

/// A single event stored inside a `SessionLog`.
final class SessionLogEvent {
  /// Creates a session log event.
  ///
  /// [timestamp] — when the event fired.
  /// [event] — the kind of event.
  /// [stepIndex] — step index in the active chain, if any.
  /// [stepType] — step type the event concerns, if any.
  /// [deliveryStatus] — action delivery outcome (for action steps).
  /// [message] — free-form human-readable description.
  const SessionLogEvent({
    required this.timestamp,
    required this.event,
    this.stepIndex,
    this.stepType,
    this.deliveryStatus,
    this.message,
  });

  /// Deserializes a `SessionLogEvent` from JSON.
  factory SessionLogEvent.fromJson(Map<String, Object?> json) =>
      SessionLogEvent(
        timestamp: DateTime.parse(json['timestamp']! as String),
        event: _eventFromJson(json['event']),
        stepIndex: (json['stepIndex'] as num?)?.toInt(),
        stepType: json['stepType'] == null
            ? null
            : _stepTypeFromJson(json['stepType']! as String),
        deliveryStatus: json['deliveryStatus'] == null
            ? null
            : ActionDeliveryStatus.fromJson(json['deliveryStatus']),
        message: json['message'] as String?,
      );

  /// When the event fired.
  final DateTime timestamp;

  /// Which event.
  final ChainEvent event;

  /// Step index in the active chain. Defaults to null.
  final int? stepIndex;

  /// Step type the event concerns. Defaults to null.
  final ChainStepType? stepType;

  /// Action delivery outcome. Defaults to null (non-action events).
  final ActionDeliveryStatus? deliveryStatus;

  /// Optional human-readable description.
  final String? message;

  /// Returns a new event with the given fields replaced.
  SessionLogEvent copyWith({
    DateTime? timestamp,
    ChainEvent? event,
    int? stepIndex,
    ChainStepType? stepType,
    ActionDeliveryStatus? deliveryStatus,
    String? message,
  }) => SessionLogEvent(
    timestamp: timestamp ?? this.timestamp,
    event: event ?? this.event,
    stepIndex: stepIndex ?? this.stepIndex,
    stepType: stepType ?? this.stepType,
    deliveryStatus: deliveryStatus ?? this.deliveryStatus,
    message: message ?? this.message,
  );

  /// Serializes to JSON.
  Map<String, Object?> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'event': event.name,
    'stepIndex': stepIndex,
    'stepType': stepType?.name,
    'deliveryStatus': deliveryStatus?.toJson(),
    'message': message,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionLogEvent &&
          other.timestamp == timestamp &&
          other.event == event &&
          other.stepIndex == stepIndex &&
          other.stepType == stepType &&
          other.deliveryStatus == deliveryStatus &&
          other.message == message;

  @override
  int get hashCode => Object.hash(
    timestamp,
    event,
    stepIndex,
    stepType,
    deliveryStatus,
    message,
  );

  @override
  String toString() =>
      'SessionLogEvent(event: $event, '
      'stepIndex: $stepIndex, stepType: $stepType)';
}

/// A completed-session record.
final class SessionLog {
  /// Creates a session log.
  ///
  /// [id] — UUID of the log.
  /// [modeId] — id of the mode that ran.
  /// [modeName] — mode name at the time of the session (cached so
  /// later renames do not corrupt history).
  /// [startedAt] — when the session started.
  /// [isSimulation] — true if this was a practice session.
  /// [endedAt] — when the session ended; null if still running.
  /// [endReason] — why the session ended; null if still running.
  /// [events] — ordered list of events; defaults to empty.
  const SessionLog({
    required this.id,
    required this.modeId,
    required this.modeName,
    required this.startedAt,
    required this.isSimulation,
    this.endedAt,
    this.endReason,
    this.events = const [],
  });

  /// Deserializes a `SessionLog` from JSON.
  factory SessionLog.fromJson(Map<String, Object?> json) {
    final raw = json['events'];
    return SessionLog(
      id: json['id']! as String,
      modeId: json['modeId']! as String,
      modeName: json['modeName']! as String,
      startedAt: DateTime.parse(json['startedAt']! as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt']! as String),
      endReason: json['endReason'] == null
          ? null
          : _endReasonFromJson(json['endReason']),
      isSimulation: json['isSimulation'] as bool? ?? false,
      events: raw is List
          ? List<SessionLogEvent>.unmodifiable(
              raw.map(
                (e) => SessionLogEvent.fromJson(e as Map<String, Object?>),
              ),
            )
          : const [],
    );
  }

  /// UUID of the log.
  final String id;

  /// Mode id.
  final String modeId;

  /// Mode name captured at session start.
  final String modeName;

  /// When the session started.
  final DateTime startedAt;

  /// When the session ended. Null if still running.
  final DateTime? endedAt;

  /// Why the session ended. Null if still running.
  final EndReason? endReason;

  /// True if this was a simulation.
  final bool isSimulation;

  /// Ordered event list.
  final List<SessionLogEvent> events;

  /// Returns a new log with the given fields replaced.
  SessionLog copyWith({
    String? id,
    String? modeId,
    String? modeName,
    DateTime? startedAt,
    DateTime? endedAt,
    EndReason? endReason,
    bool? isSimulation,
    List<SessionLogEvent>? events,
  }) => SessionLog(
    id: id ?? this.id,
    modeId: modeId ?? this.modeId,
    modeName: modeName ?? this.modeName,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt ?? this.endedAt,
    endReason: endReason ?? this.endReason,
    isSimulation: isSimulation ?? this.isSimulation,
    events: events ?? this.events,
  );

  /// Serializes to JSON.
  Map<String, Object?> toJson() => {
    'id': id,
    'modeId': modeId,
    'modeName': modeName,
    'startedAt': startedAt.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
    'endReason': endReason?.name,
    'isSimulation': isSimulation,
    'events': events.map((e) => e.toJson()).toList(growable: false),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SessionLog) return false;
    if (other.id != id) return false;
    if (other.modeId != modeId) return false;
    if (other.modeName != modeName) return false;
    if (other.startedAt != startedAt) return false;
    if (other.endedAt != endedAt) return false;
    if (other.endReason != endReason) return false;
    if (other.isSimulation != isSimulation) return false;
    if (other.events.length != events.length) return false;
    for (var i = 0; i < events.length; i++) {
      if (other.events[i] != events[i]) return false;
    }
    return true;
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
    Object.hashAll(events),
  );

  @override
  String toString() =>
      'SessionLog(id: $id, modeId: $modeId, '
      'events: ${events.length})';
}

ChainEvent _eventFromJson(Object? raw) => switch (raw) {
  'sessionStarted' => ChainEvent.sessionStarted,
  'stepStarted' => ChainEvent.stepStarted,
  'stepAdvancing' => ChainEvent.stepAdvancing,
  'graceExpired' => ChainEvent.graceExpired,
  'repeatMissed' => ChainEvent.repeatMissed,
  'distressTriggered' => ChainEvent.distressTriggered,
  'distressCompleted' => ChainEvent.distressCompleted,
  'sessionPaused' => ChainEvent.sessionPaused,
  'sessionResumed' => ChainEvent.sessionResumed,
  'sessionEnded' => ChainEvent.sessionEnded,
  _ => throw ArgumentError.value(raw, 'event', 'unknown ChainEvent'),
};

ChainStepType _stepTypeFromJson(String raw) => switch (raw) {
  'holdButton' => ChainStepType.holdButton,
  'disguisedReminder' => ChainStepType.disguisedReminder,
  'countdownWarning' => ChainStepType.countdownWarning,
  'fakeCall' => ChainStepType.fakeCall,
  'smsContact' => ChainStepType.smsContact,
  'phoneCallContact' => ChainStepType.phoneCallContact,
  'loudAlarm' => ChainStepType.loudAlarm,
  'callEmergency' => ChainStepType.callEmergency,
  'hardwareButton' => ChainStepType.hardwareButton,
  _ => throw ArgumentError.value(raw, 'stepType', 'unknown ChainStepType'),
};

EndReason _endReasonFromJson(Object? raw) => switch (raw) {
  'disarm' => EndReason.disarm,
  'chainExhausted' => EndReason.chainExhausted,
  'hardwarePanic' => EndReason.hardwarePanic,
  'duressPin' => EndReason.duressPin,
  'wrongPinExhausted' => EndReason.wrongPinExhausted,
  'userQuit' => EndReason.userQuit,
  'appTermination' => EndReason.appTermination,
  _ => throw ArgumentError.value(raw, 'endReason', 'unknown EndReason'),
};
