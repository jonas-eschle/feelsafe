import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';

/// One escalation step in a safety chain.
///
/// Drives [SessionEngine] timing and escalation logic. Persisted as JSON
/// inside the parent [SessionMode.chainSteps] column — no dedicated table.
/// See spec 03 §ChainStep.
///
/// Three-phase timing per step:
/// 1. **Wait** ([waitSeconds]): delay before the event fires.
/// 2. **Active** ([durationSeconds]): how long the event runs.
/// 3. **Grace** ([gracePeriodSeconds]): dead time after the event ends.
///
/// Repeat semantics: [retryCount] = N means the step fires N + 1 times
/// total (initial + N retries). After all fires, the chain escalates.
final class ChainStep {
  /// Creates a chain step.
  ///
  /// [id] must be non-empty (UUID). [order] must be ≥ 0. All time fields
  /// must be ≥ 0. [retryCount] must be ≥ 0.
  ChainStep({
    required this.id,
    required this.type,
    required this.order,
    required this.waitSeconds,
    required this.durationSeconds,
    required this.gracePeriodSeconds,
    required this.retryCount,
    required this.randomize,
    this.config,
  }) : assert(id.isNotEmpty, 'ChainStep.id must be non-empty'),
       assert(order >= 0, 'ChainStep.order must be >= 0'),
       assert(waitSeconds >= 0, 'ChainStep.waitSeconds must be >= 0'),
       assert(durationSeconds >= 0, 'ChainStep.durationSeconds must be >= 0'),
       assert(
         gracePeriodSeconds >= 0,
         'ChainStep.gracePeriodSeconds must be >= 0',
       ),
       assert(retryCount >= 0, 'ChainStep.retryCount must be >= 0');

  /// Deserialises a [ChainStep] from [json].
  factory ChainStep.fromJson(Map<String, dynamic> json) {
    final type = ChainStepType.values.byName(json['type'] as String);
    final configJson = json['config'] as Map<String, dynamic>?;
    return ChainStep(
      id: json['id'] as String,
      type: type,
      order: (json['order'] as num).toInt(),
      waitSeconds: (json['waitSeconds'] as num).toInt(),
      durationSeconds: (json['durationSeconds'] as num).toInt(),
      gracePeriodSeconds: (json['gracePeriodSeconds'] as num).toInt(),
      retryCount: (json['retryCount'] as num).toInt(),
      randomize: json['randomize'] as bool,
      config: configJson != null ? StepConfig.fromJson(type, configJson) : null,
    );
  }

  /// UUID identifying this step within its mode.
  final String id;

  /// The step type determines which [EventStrategy] handles it.
  final ChainStepType type;

  /// 0-based position in the chain.
  final int order;

  /// Delay before the event fires (the wait phase).
  final int waitSeconds;

  /// How long the event is active (the active phase).
  final int durationSeconds;

  /// Dead time after the event before escalating (the grace phase).
  final int gracePeriodSeconds;

  /// Number of additional retries after the initial fire.
  ///
  /// 0 = fire once, N = fire up to N + 1 times total.
  final int retryCount;

  /// Whether to apply ±20% jitter to all timing values.
  final bool randomize;

  /// Typed per-step-type config. Null = use [EventDefaults.forType].
  final StepConfig? config;

  /// Duration of the wait phase.
  Duration get waitDuration => Duration(seconds: waitSeconds);

  /// Duration of the active phase.
  Duration get activeDuration => Duration(seconds: durationSeconds);

  /// Duration of the grace phase.
  Duration get gracePeriod => Duration(seconds: gracePeriodSeconds);

  /// Total duration of one full cycle (wait + active + grace).
  int get totalCycleSeconds =>
      waitSeconds + durationSeconds + gracePeriodSeconds;

  /// Returns a copy with the specified fields replaced.
  ChainStep copyWith({
    String? id,
    ChainStepType? type,
    int? order,
    int? waitSeconds,
    int? durationSeconds,
    int? gracePeriodSeconds,
    int? retryCount,
    bool? randomize,
    StepConfig? config,
  }) => ChainStep(
    id: id ?? this.id,
    type: type ?? this.type,
    order: order ?? this.order,
    waitSeconds: waitSeconds ?? this.waitSeconds,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    gracePeriodSeconds: gracePeriodSeconds ?? this.gracePeriodSeconds,
    retryCount: retryCount ?? this.retryCount,
    randomize: randomize ?? this.randomize,
    config: config ?? this.config,
  );

  /// Serialises this step to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'order': order,
    'waitSeconds': waitSeconds,
    'durationSeconds': durationSeconds,
    'gracePeriodSeconds': gracePeriodSeconds,
    'retryCount': retryCount,
    'randomize': randomize,
    if (config != null) 'config': config!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChainStep &&
          id == other.id &&
          type == other.type &&
          order == other.order &&
          waitSeconds == other.waitSeconds &&
          durationSeconds == other.durationSeconds &&
          gracePeriodSeconds == other.gracePeriodSeconds &&
          retryCount == other.retryCount &&
          randomize == other.randomize &&
          config == other.config);

  @override
  int get hashCode => Object.hash(
    id,
    type,
    order,
    waitSeconds,
    durationSeconds,
    gracePeriodSeconds,
    retryCount,
    randomize,
    config,
  );
}
