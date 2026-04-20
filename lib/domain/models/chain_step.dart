/// The `ChainStep` model — the unit of escalation in a chain.
///
/// Each step carries a `type`, a three-phase timing spec
/// (wait → duration → grace), a `retryCount`, a ±20% randomize
/// factor, and an optional typed [StepConfig]. When `config` is
/// null the engine uses the matching default from `EventDefaults`.
library;

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/step_config.dart';

/// A single escalation step in a safety chain.
final class ChainStep {
  /// Creates a chain step.
  ///
  /// [id] — stable UUID for the step.
  /// [type] — which of the nine step types this is.
  /// [order] — zero-based position in the parent chain.
  /// [durationSeconds] — duration of the active phase, in seconds.
  /// [gracePeriodSeconds] — grace window after the active phase, in
  /// seconds.
  /// [waitSeconds] — delay before the active phase begins; defaults
  /// to 0.
  /// [retryCount] — number of retries after the initial fire;
  /// defaults to 0.
  /// [randomize] — jitter factor in `[0, 1]` applied to timing;
  /// defaults to 0.0.
  /// [config] — optional typed step config; `null` = inherit from
  /// `EventDefaults`.
  const ChainStep({
    required this.id,
    required this.type,
    required this.order,
    required this.durationSeconds,
    required this.gracePeriodSeconds,
    this.waitSeconds = 0,
    this.retryCount = 0,
    this.randomize = 0.0,
    this.config,
  });

  /// Deserializes a `ChainStep` from JSON.
  factory ChainStep.fromJson(Map<String, Object?> json) {
    final rawConfig = json['config'];
    return ChainStep(
      id: json['id']! as String,
      type: _chainStepTypeFromJson(json['type']),
      order: (json['order']! as num).toInt(),
      durationSeconds: (json['durationSeconds']! as num).toInt(),
      gracePeriodSeconds: (json['gracePeriodSeconds']! as num).toInt(),
      waitSeconds: (json['waitSeconds'] as num?)?.toInt() ?? 0,
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
      randomize: (json['randomize'] as num?)?.toDouble() ?? 0.0,
      config: rawConfig is Map<String, Object?>
          ? StepConfig.fromJson(rawConfig)
          : null,
    );
  }

  /// Stable identifier (UUID).
  final String id;

  /// The type of step.
  final ChainStepType type;

  /// Zero-based position in the parent chain.
  final int order;

  /// Active-phase duration, in seconds.
  final int durationSeconds;

  /// Grace-window duration, in seconds.
  final int gracePeriodSeconds;

  /// Delay before the active phase starts, in seconds. Defaults to 0.
  final int waitSeconds;

  /// Retries after the initial fire. Defaults to 0 (no retry).
  final int retryCount;

  /// Jitter factor applied to timing. 0.0 disables jitter; 1.0 means
  /// ±20% full-range randomization. Defaults to 0.0.
  final double randomize;

  /// Optional per-step config. `null` means "inherit from
  /// `EventDefaults.forType(type)`".
  final StepConfig? config;

  /// `waitSeconds` as a [Duration].
  Duration get waitDuration => Duration(seconds: waitSeconds);

  /// `durationSeconds` as a [Duration].
  Duration get activeDuration => Duration(seconds: durationSeconds);

  /// `gracePeriodSeconds` as a [Duration].
  Duration get graceDuration => Duration(seconds: gracePeriodSeconds);

  /// Sum of all three phases, in seconds.
  int get totalCycleSeconds =>
      waitSeconds + durationSeconds + gracePeriodSeconds;

  /// Returns a new step with the given fields replaced. Passing
  /// `config: null` does NOT clear the config — to clear it, build a
  /// new `ChainStep` directly.
  ChainStep copyWith({
    String? id,
    ChainStepType? type,
    int? order,
    int? durationSeconds,
    int? gracePeriodSeconds,
    int? waitSeconds,
    int? retryCount,
    double? randomize,
    StepConfig? config,
  }) => ChainStep(
    id: id ?? this.id,
    type: type ?? this.type,
    order: order ?? this.order,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    gracePeriodSeconds: gracePeriodSeconds ?? this.gracePeriodSeconds,
    waitSeconds: waitSeconds ?? this.waitSeconds,
    retryCount: retryCount ?? this.retryCount,
    randomize: randomize ?? this.randomize,
    config: config ?? this.config,
  );

  /// Serializes the step to JSON.
  Map<String, Object?> toJson() => {
    'id': id,
    'type': type.name,
    'order': order,
    'durationSeconds': durationSeconds,
    'gracePeriodSeconds': gracePeriodSeconds,
    'waitSeconds': waitSeconds,
    'retryCount': retryCount,
    'randomize': randomize,
    'config': config?.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChainStep &&
          other.id == id &&
          other.type == type &&
          other.order == order &&
          other.durationSeconds == durationSeconds &&
          other.gracePeriodSeconds == gracePeriodSeconds &&
          other.waitSeconds == waitSeconds &&
          other.retryCount == retryCount &&
          other.randomize == randomize &&
          other.config == config;

  @override
  int get hashCode => Object.hash(
    id,
    type,
    order,
    durationSeconds,
    gracePeriodSeconds,
    waitSeconds,
    retryCount,
    randomize,
    config,
  );

  @override
  String toString() =>
      'ChainStep(id: $id, type: $type, order: $order, '
      'waitSeconds: $waitSeconds, durationSeconds: $durationSeconds, '
      'gracePeriodSeconds: $gracePeriodSeconds, '
      'retryCount: $retryCount, randomize: $randomize, config: $config)';
}

ChainStepType _chainStepTypeFromJson(Object? raw) => switch (raw) {
  'holdButton' => ChainStepType.holdButton,
  'disguisedReminder' => ChainStepType.disguisedReminder,
  'countdownWarning' => ChainStepType.countdownWarning,
  'fakeCall' => ChainStepType.fakeCall,
  'smsContact' => ChainStepType.smsContact,
  'phoneCallContact' => ChainStepType.phoneCallContact,
  'loudAlarm' => ChainStepType.loudAlarm,
  'callEmergency' => ChainStepType.callEmergency,
  'hardwareButton' => ChainStepType.hardwareButton,
  _ => throw ArgumentError.value(raw, 'type', 'unknown ChainStepType'),
};
