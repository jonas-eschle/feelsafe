/// `ChainEventData` — the event envelope emitted by
/// `SessionEngine` on its broadcast stream.
///
/// Also exports the `ChainEvent` enum tagging each event type and
/// the sealed `ActionDeliveryStatus` hierarchy that action strategies
/// use to report delivery results.
library;

import 'package:guardianangela/data/models/enums.dart';

/// The kind of engine event. Used as the `event` field of
/// `ChainEventData`.
///
/// Spec 01 §Events Emitted defines the full event set.
enum ChainEvent {
  /// A new session just started.
  sessionStarted,

  /// A step became active (entered its `duration` phase).
  stepStarted,

  /// A step's grace phase expired and the engine is advancing.
  stepAdvancing,

  /// A step's grace phase expired before the user responded.
  graceExpired,

  /// A disguised-reminder retry fired with no response.
  repeatMissed,

  /// A disguised-reminder step entered its `duration` phase — the
  /// reminder overlay is now visible to the user. Spec 01 §Disguised
  /// Reminder State Machine.
  reminderFired,

  /// A pause exceeded `AppSettings.maxPauseDuration` and the engine
  /// auto-resumed. Reserved by spec 01 §Events Emitted; not yet
  /// emitted — wiring requires maxPauseDuration plumbing through
  /// settings which is out of scope for this alignment pass.
  pauseExpired,

  /// A strategy's `executeReal` threw. Emitted by the orchestrator's
  /// error-isolation catch (D-STRATEGY-2). Spec 01 §Events Emitted.
  stepExecutionFailed,

  /// A distress trigger fired; the engine replaced the main chain
  /// with the distress chain.
  distressTriggered,

  /// The distress chain finished.
  distressCompleted,

  /// The session was paused.
  sessionPaused,

  /// The session was resumed from pause.
  sessionResumed,

  /// The session ended (any reason).
  sessionEnded,
}

/// Result of an action-strategy attempt (SMS / call / alarm, …).
///
/// Used in `SessionLogEvent.deliveryStatus` to record whether the
/// action actually reached its destination.
sealed class ActionDeliveryStatus {
  /// Const base constructor.
  const ActionDeliveryStatus();

  /// Tag string for JSON.
  String get tag;

  /// Serializes to its tag.
  Object toJson() => tag;

  /// Deserializes an `ActionDeliveryStatus` from its string tag.
  static ActionDeliveryStatus fromJson(Object? raw) => switch (raw) {
    'queued' => const ActionDeliveryStatus.queued(),
    'sent' => const ActionDeliveryStatus.sent(),
    'failed' => const ActionDeliveryStatus.failed(),
    'simBlocked' => const ActionDeliveryStatus.simBlocked(),
    _ => throw ArgumentError.value(
      raw,
      'deliveryStatus',
      'unknown ActionDeliveryStatus',
    ),
  };

  /// The action was queued but not yet confirmed delivered.
  const factory ActionDeliveryStatus.queued() = _QueuedStatus;

  /// The action was delivered.
  const factory ActionDeliveryStatus.sent() = _SentStatus;

  /// The action failed at runtime.
  const factory ActionDeliveryStatus.failed() = _FailedStatus;

  /// The action was blocked by the SIM / telephony layer.
  const factory ActionDeliveryStatus.simBlocked() = _SimBlockedStatus;
}

final class _QueuedStatus extends ActionDeliveryStatus {
  const _QueuedStatus();

  @override
  String get tag => 'queued';

  @override
  bool operator ==(Object other) => other is _QueuedStatus;

  @override
  int get hashCode => 'queued'.hashCode;

  @override
  String toString() => 'ActionDeliveryStatus.queued';
}

final class _SentStatus extends ActionDeliveryStatus {
  const _SentStatus();

  @override
  String get tag => 'sent';

  @override
  bool operator ==(Object other) => other is _SentStatus;

  @override
  int get hashCode => 'sent'.hashCode;

  @override
  String toString() => 'ActionDeliveryStatus.sent';
}

final class _FailedStatus extends ActionDeliveryStatus {
  const _FailedStatus();

  @override
  String get tag => 'failed';

  @override
  bool operator ==(Object other) => other is _FailedStatus;

  @override
  int get hashCode => 'failed'.hashCode;

  @override
  String toString() => 'ActionDeliveryStatus.failed';
}

final class _SimBlockedStatus extends ActionDeliveryStatus {
  const _SimBlockedStatus();

  @override
  String get tag => 'simBlocked';

  @override
  bool operator ==(Object other) => other is _SimBlockedStatus;

  @override
  int get hashCode => 'simBlocked'.hashCode;

  @override
  String toString() => 'ActionDeliveryStatus.simBlocked';
}

/// A single chain event emitted by the `SessionEngine`.
final class ChainEventData {
  /// Creates a chain event.
  ///
  /// [event] — which event this is.
  /// [timestamp] — when the event was emitted.
  /// [stepIndex] — index into the active chain; optional.
  /// [stepType] — step type the event refers to; optional.
  /// [metadata] — free-form key/value data; defaults to empty.
  const ChainEventData({
    required this.event,
    required this.timestamp,
    this.stepIndex,
    this.stepType,
    this.metadata = const {},
  });

  /// Deserializes a `ChainEventData` from JSON.
  factory ChainEventData.fromJson(Map<String, Object?> json) {
    final raw = json['metadata'];
    return ChainEventData(
      event: _eventFromJson(json['event']),
      timestamp: DateTime.parse(json['timestamp']! as String),
      stepIndex: (json['stepIndex'] as num?)?.toInt(),
      stepType: json['stepType'] == null
          ? null
          : _stepTypeFromJson(json['stepType']),
      metadata: raw is Map
          ? Map<String, Object?>.unmodifiable(
              raw.map((k, v) => MapEntry(k as String, v)),
            )
          : const {},
    );
  }

  /// Which event this is.
  final ChainEvent event;

  /// When the event was emitted.
  final DateTime timestamp;

  /// Zero-based index into the active chain. Defaults to null.
  final int? stepIndex;

  /// Step type the event refers to. Defaults to null.
  final ChainStepType? stepType;

  /// Free-form event payload. Defaults to empty.
  final Map<String, Object?> metadata;

  /// Returns a new event with the given fields replaced.
  ChainEventData copyWith({
    ChainEvent? event,
    DateTime? timestamp,
    int? stepIndex,
    ChainStepType? stepType,
    Map<String, Object?>? metadata,
  }) => ChainEventData(
    event: event ?? this.event,
    timestamp: timestamp ?? this.timestamp,
    stepIndex: stepIndex ?? this.stepIndex,
    stepType: stepType ?? this.stepType,
    metadata: metadata ?? this.metadata,
  );

  /// Serializes to JSON.
  Map<String, Object?> toJson() => {
    'event': event.name,
    'timestamp': timestamp.toIso8601String(),
    'stepIndex': stepIndex,
    'stepType': stepType?.name,
    'metadata': metadata,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChainEventData) return false;
    if (other.event != event) return false;
    if (other.timestamp != timestamp) return false;
    if (other.stepIndex != stepIndex) return false;
    if (other.stepType != stepType) return false;
    if (other.metadata.length != metadata.length) return false;
    for (final entry in metadata.entries) {
      if (other.metadata[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    event,
    timestamp,
    stepIndex,
    stepType,
    Object.hashAll(metadata.entries.map((e) => Object.hash(e.key, e.value))),
  );

  @override
  String toString() =>
      'ChainEventData(event: $event, stepIndex: $stepIndex, '
      'stepType: $stepType)';
}

ChainEvent _eventFromJson(Object? raw) => switch (raw) {
  'sessionStarted' => ChainEvent.sessionStarted,
  'stepStarted' => ChainEvent.stepStarted,
  'stepAdvancing' => ChainEvent.stepAdvancing,
  'graceExpired' => ChainEvent.graceExpired,
  'repeatMissed' => ChainEvent.repeatMissed,
  'reminderFired' => ChainEvent.reminderFired,
  'pauseExpired' => ChainEvent.pauseExpired,
  'stepExecutionFailed' => ChainEvent.stepExecutionFailed,
  'distressTriggered' => ChainEvent.distressTriggered,
  'distressCompleted' => ChainEvent.distressCompleted,
  'sessionPaused' => ChainEvent.sessionPaused,
  'sessionResumed' => ChainEvent.sessionResumed,
  'sessionEnded' => ChainEvent.sessionEnded,
  _ => throw ArgumentError.value(raw, 'event', 'unknown ChainEvent'),
};

ChainStepType _stepTypeFromJson(Object? raw) => switch (raw) {
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
