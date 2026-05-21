/// A single event in a [SessionLog] timeline.
///
/// Serialised as JSON inside the parent [SessionLog.events] Drift column —
/// no dedicated table. See spec 03 §SessionLogEvent.
final class SessionLogEvent {
  /// Creates a session log event.
  const SessionLogEvent({
    required this.timestamp,
    required this.eventType,
    this.stepType,
    required this.stepIndex,
    required this.description,
    this.latitude,
    this.longitude,
    this.deliveryStatus,
  });

  /// UTC timestamp when the event occurred.
  final DateTime timestamp;

  /// Machine-readable event kind.
  ///
  /// Known values: `'started'`, `'step_fired'`, `'disarmed'`, `'missed'`,
  /// `'escalated'`, `'completed'`, `'error'`.
  final String eventType;

  /// [ChainStepType.name] if this event is tied to a specific step.
  final String? stepType;

  /// 0-based index in the chain at the time of this event.
  final int stepIndex;

  /// Human-readable summary for display in the history screen.
  final String description;

  /// GPS latitude when the event fired (if GPS logging was enabled).
  final double? latitude;

  /// GPS longitude when the event fired (if GPS logging was enabled).
  final double? longitude;

  /// Delivery status for message-based steps.
  ///
  /// Known values: `'sent'`, `'queued'`, `'failed'`, `'simBlocked'`.
  final String? deliveryStatus;

  /// Returns a copy with the specified fields replaced.
  SessionLogEvent copyWith({
    DateTime? timestamp,
    String? eventType,
    String? stepType,
    int? stepIndex,
    String? description,
    double? latitude,
    double? longitude,
    String? deliveryStatus,
  }) => SessionLogEvent(
    timestamp: timestamp ?? this.timestamp,
    eventType: eventType ?? this.eventType,
    stepType: stepType ?? this.stepType,
    stepIndex: stepIndex ?? this.stepIndex,
    description: description ?? this.description,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    deliveryStatus: deliveryStatus ?? this.deliveryStatus,
  );

  /// Serialises this event to a JSON map.
  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toUtc().toIso8601String(),
    'eventType': eventType,
    if (stepType != null) 'stepType': stepType,
    'stepIndex': stepIndex,
    'description': description,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    if (deliveryStatus != null) 'deliveryStatus': deliveryStatus,
  };

  /// Deserialises a [SessionLogEvent] from [json].
  factory SessionLogEvent.fromJson(Map<String, dynamic> json) =>
      SessionLogEvent(
        timestamp: DateTime.parse(json['timestamp'] as String).toUtc(),
        eventType: json['eventType'] as String,
        stepType: json['stepType'] as String?,
        stepIndex: (json['stepIndex'] as num).toInt(),
        description: json['description'] as String,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        deliveryStatus: json['deliveryStatus'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionLogEvent &&
          timestamp == other.timestamp &&
          eventType == other.eventType &&
          stepType == other.stepType &&
          stepIndex == other.stepIndex &&
          description == other.description &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          deliveryStatus == other.deliveryStatus);

  @override
  int get hashCode => Object.hash(
    timestamp,
    eventType,
    stepType,
    stepIndex,
    description,
    latitude,
    longitude,
    deliveryStatus,
  );
}
