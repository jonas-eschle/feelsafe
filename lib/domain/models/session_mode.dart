import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/mode_overrides.dart';
import 'package:guardianangela/domain/triggers/disarm_trigger.dart';
import 'package:guardianangela/domain/triggers/distress_trigger.dart';

/// A named safety session configuration containing an escalation chain
/// and triggers.
///
/// Persisted as one row in the Drift `session_modes` table. Every step in
/// [chainSteps] is on equal footing; the first step simply runs first.
/// Distress modes are [SessionMode]s with [isDistressMode] = true. See
/// spec 03 §SessionMode and lessons §5.1 (distress is a mode).
///
/// Must have at least 1 chain step ([chainSteps] non-empty).
final class SessionMode {
  /// Creates a session mode.
  ///
  /// [id] must be non-empty. [name] must be non-empty. [chainSteps] must
  /// be non-empty. [trackingIntervalSeconds] must be > 0.
  /// [trackingBufferSize] must be > 0.
  SessionMode({
    required this.id,
    required this.name,
    this.iconName,
    required this.chainSteps,
    this.distressModeId,
    this.distressTriggers = const [],
    this.disarmTriggers = const [],
    this.overrides,
    this.trackingEnabled = false,
    this.trackingIntervalSeconds = 300,
    this.trackingBufferSize = 50,
    this.pauseAllowed = true,
    this.maxPauseMinutes,
    this.isDistressMode = false,
    this.allowDisarmAsDistress = true,
  }) : assert(id.isNotEmpty, 'SessionMode.id must be non-empty'),
       assert(name.isNotEmpty, 'SessionMode.name must be non-empty'),
       assert(
         chainSteps.isNotEmpty,
         'SessionMode.chainSteps must contain at least one step',
       ),
       assert(
         trackingIntervalSeconds > 0,
         'SessionMode.trackingIntervalSeconds must be > 0',
       ),
       assert(
         trackingBufferSize > 0,
         'SessionMode.trackingBufferSize must be > 0',
       );

  /// Deserialises a [SessionMode] from [json].
  factory SessionMode.fromJson(Map<String, dynamic> json) => SessionMode(
    id: json['id'] as String,
    name: json['name'] as String,
    iconName: json['iconName'] as String?,
    chainSteps: (json['chainSteps'] as List<dynamic>)
        .map((e) => ChainStep.fromJson(e as Map<String, dynamic>))
        .toList(),
    distressModeId: json['distressModeId'] as String?,
    distressTriggers:
        (json['distressTriggers'] as List<dynamic>?)
            ?.map((e) => DistressTrigger.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    disarmTriggers:
        (json['disarmTriggers'] as List<dynamic>?)
            ?.map((e) => DisarmTrigger.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    overrides: json['overrides'] != null
        ? ModeOverrides.fromJson(json['overrides'] as Map<String, dynamic>)
        : null,
    trackingEnabled: (json['trackingEnabled'] as bool?) ?? false,
    trackingIntervalSeconds:
        (json['trackingIntervalSeconds'] as num?)?.toInt() ?? 300,
    trackingBufferSize: (json['trackingBufferSize'] as num?)?.toInt() ?? 50,
    pauseAllowed: (json['pauseAllowed'] as bool?) ?? true,
    maxPauseMinutes: (json['maxPauseMinutes'] as num?)?.toInt(),
    isDistressMode: (json['isDistressMode'] as bool?) ?? false,
    allowDisarmAsDistress: (json['allowDisarmAsDistress'] as bool?) ?? true,
  );

  /// UUID — primary key.
  final String id;

  /// Human-readable name displayed in the UI.
  final String name;

  /// Optional Material icon name (e.g., `'directions_walk'`).
  final String? iconName;

  /// The escalation chain. Must be non-empty. Each step's [order] field
  /// determines execution sequence.
  final List<ChainStep> chainSteps;

  /// ID of the distress [SessionMode] used when distress is triggered.
  ///
  /// Null = inherit [AppDefaults.defaultDistressModeId].
  final String? distressModeId;

  /// Triggers that fire the distress chain when activated.
  final List<DistressTrigger> distressTriggers;

  /// Triggers that automatically end the session when their condition
  /// is met.
  final List<DisarmTrigger> disarmTriggers;

  /// Per-mode overrides of [AppDefaults]. Null = inherit all defaults.
  final ModeOverrides? overrides;

  /// Whether interval GPS tracking is active during this mode.
  final bool trackingEnabled;

  /// GPS tracking interval in seconds.
  final int trackingIntervalSeconds;

  /// Maximum number of GPS positions kept in the in-memory buffer.
  final int trackingBufferSize;

  /// Whether the user may pause this session.
  final bool pauseAllowed;

  /// Maximum pause duration in minutes. Null = unlimited.
  final int? maxPauseMinutes;

  /// Whether this mode IS a distress mode (referenced by other modes via
  /// [distressModeId]).
  final bool isDistressMode;

  /// Whether [disarmTriggers] still fire when this mode runs AS the distress
  /// chain (G-014).
  ///
  /// Default true: user can configure escape conditions (GPS arrival, timer)
  /// even during distress. Set false for stricter coercion resistance —
  /// the chain runs to exhaustion.
  final bool allowDisarmAsDistress;

  /// Returns a copy with the specified fields replaced.
  SessionMode copyWith({
    String? id,
    String? name,
    String? iconName,
    List<ChainStep>? chainSteps,
    String? distressModeId,
    List<DistressTrigger>? distressTriggers,
    List<DisarmTrigger>? disarmTriggers,
    ModeOverrides? overrides,
    bool? trackingEnabled,
    int? trackingIntervalSeconds,
    int? trackingBufferSize,
    bool? pauseAllowed,
    int? maxPauseMinutes,
    bool? isDistressMode,
    bool? allowDisarmAsDistress,
  }) => SessionMode(
    id: id ?? this.id,
    name: name ?? this.name,
    iconName: iconName ?? this.iconName,
    chainSteps: chainSteps ?? this.chainSteps,
    distressModeId: distressModeId ?? this.distressModeId,
    distressTriggers: distressTriggers ?? this.distressTriggers,
    disarmTriggers: disarmTriggers ?? this.disarmTriggers,
    overrides: overrides ?? this.overrides,
    trackingEnabled: trackingEnabled ?? this.trackingEnabled,
    trackingIntervalSeconds:
        trackingIntervalSeconds ?? this.trackingIntervalSeconds,
    trackingBufferSize: trackingBufferSize ?? this.trackingBufferSize,
    pauseAllowed: pauseAllowed ?? this.pauseAllowed,
    maxPauseMinutes: maxPauseMinutes ?? this.maxPauseMinutes,
    isDistressMode: isDistressMode ?? this.isDistressMode,
    allowDisarmAsDistress: allowDisarmAsDistress ?? this.allowDisarmAsDistress,
  );

  /// Serialises this mode to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (iconName != null) 'iconName': iconName,
    'chainSteps': chainSteps.map((s) => s.toJson()).toList(),
    if (distressModeId != null) 'distressModeId': distressModeId,
    'distressTriggers': distressTriggers.map((t) => t.toJson()).toList(),
    'disarmTriggers': disarmTriggers.map((t) => t.toJson()).toList(),
    if (overrides != null) 'overrides': overrides!.toJson(),
    'trackingEnabled': trackingEnabled,
    'trackingIntervalSeconds': trackingIntervalSeconds,
    'trackingBufferSize': trackingBufferSize,
    'pauseAllowed': pauseAllowed,
    if (maxPauseMinutes != null) 'maxPauseMinutes': maxPauseMinutes,
    'isDistressMode': isDistressMode,
    'allowDisarmAsDistress': allowDisarmAsDistress,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! SessionMode) {
      return false;
    }
    if (chainSteps.length != other.chainSteps.length) {
      return false;
    }
    for (var i = 0; i < chainSteps.length; i++) {
      if (chainSteps[i] != other.chainSteps[i]) {
        return false;
      }
    }
    if (distressTriggers.length != other.distressTriggers.length) {
      return false;
    }
    for (var i = 0; i < distressTriggers.length; i++) {
      if (distressTriggers[i] != other.distressTriggers[i]) {
        return false;
      }
    }
    if (disarmTriggers.length != other.disarmTriggers.length) {
      return false;
    }
    for (var i = 0; i < disarmTriggers.length; i++) {
      if (disarmTriggers[i] != other.disarmTriggers[i]) {
        return false;
      }
    }
    return id == other.id &&
        name == other.name &&
        iconName == other.iconName &&
        distressModeId == other.distressModeId &&
        overrides == other.overrides &&
        trackingEnabled == other.trackingEnabled &&
        trackingIntervalSeconds == other.trackingIntervalSeconds &&
        trackingBufferSize == other.trackingBufferSize &&
        pauseAllowed == other.pauseAllowed &&
        maxPauseMinutes == other.maxPauseMinutes &&
        isDistressMode == other.isDistressMode &&
        allowDisarmAsDistress == other.allowDisarmAsDistress;
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    iconName,
    Object.hashAll(chainSteps),
    distressModeId,
    Object.hashAll(distressTriggers),
    Object.hashAll(disarmTriggers),
    overrides,
    trackingEnabled,
    trackingIntervalSeconds,
    trackingBufferSize,
    pauseAllowed,
    maxPauseMinutes,
    isDistressMode,
    allowDisarmAsDistress,
  );
}
