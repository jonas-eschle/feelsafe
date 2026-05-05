/// `SessionMode` — a named safety mode with a check-in type, an
/// escalation chain, an optional distress-chain reference, triggers,
/// and optional `ModeOverrides`.
library;

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/mode_overrides.dart';
import 'package:guardianangela/domain/models/trigger.dart';

/// A configurable session mode (e.g., Walk Mode, Date Mode).
final class SessionMode {
  /// Creates a session mode.
  ///
  /// [id] — stable UUID.
  /// [name] — display name.
  /// [checkInType] — which step type is the mode's check-in
  /// (holdButton / disguisedReminder).
  /// [chainSteps] — main escalation chain; first step determines
  /// check-in behaviour. Defaults to empty.
  /// [distressModeId] — id of a chain in the distress repository;
  /// null = use default (first in repo).
  /// [distressTriggers] — triggers that switch to the distress
  /// chain. Defaults to empty.
  /// [disarmTriggers] — triggers that auto-disarm the session.
  /// Defaults to empty.
  /// [overrides] — optional per-mode overrides of `AppDefaults`.
  /// [trackingEnabled] — spec 11 §DE-3 (interval-based GPS recording).
  /// When true, the engine starts a periodic GPS sampler at
  /// [trackingIntervalSeconds] cadence and retains the last
  /// [trackingBufferSize] fixes in memory. Default `false` (off; saves
  /// battery for users that don't need background GPS). *Why off by
  /// default:* sub-minute GPS sampling is a noticeable battery drain
  /// — users opt in per mode.
  /// [trackingIntervalSeconds] — spec 11 §DE-3. Sampling cadence in
  /// seconds when [trackingEnabled]. Default 300 (5 min).
  /// [trackingBufferSize] — spec 11 §DE-3. Maximum number of points
  /// retained in the in-memory buffer. Default 50.
  /// [iconName] — optional symbolic name of the Material icon to
  /// use when rendering this mode (e.g. on the Home tile or in the
  /// modes list). Resolved via `kModeIconLibrary` on the UI side.
  /// `null` = the UI falls back to its name-based heuristic.
  /// [isDistressMode] — when true, this mode is a distress mode that
  /// other modes can reference via [distressModeId]. Distress modes
  /// are managed separately in the UI from regular session modes.
  /// Default `false`.
  const SessionMode({
    required this.id,
    required this.name,
    required this.checkInType,
    this.chainSteps = const [],
    this.distressModeId,
    this.distressTriggers = const [],
    this.disarmTriggers = const [],
    this.overrides,
    this.trackingEnabled = false,
    this.trackingIntervalSeconds = 300,
    this.trackingBufferSize = 50,
    this.iconName,
    this.pauseAllowed = true,
    this.maxPauseMinutes,
    this.isDistressMode = false,
  });

  /// Deserializes a `SessionMode` from JSON.
  factory SessionMode.fromJson(Map<String, Object?> json) {
    final rawChain = json['chainSteps'];
    final rawDistress = json['distressTriggers'];
    final rawDisarm = json['disarmTriggers'];
    final rawOverrides = json['overrides'];
    return SessionMode(
      id: json['id']! as String,
      name: json['name']! as String,
      checkInType: _checkInTypeFromJson(json['checkInType']),
      chainSteps: rawChain is List
          ? List<ChainStep>.unmodifiable(
              rawChain.map(
                (e) => ChainStep.fromJson(e as Map<String, Object?>),
              ),
            )
          : const [],
      distressModeId: json['distressModeId'] as String?,
      distressTriggers: rawDistress is List
          ? List<DistressTrigger>.unmodifiable(
              rawDistress.map(
                (e) => DistressTrigger.fromJson(e as Map<String, Object?>),
              ),
            )
          : const [],
      disarmTriggers: rawDisarm is List
          ? List<DisarmTrigger>.unmodifiable(
              rawDisarm.map(
                (e) => DisarmTrigger.fromJson(e as Map<String, Object?>),
              ),
            )
          : const [],
      overrides: rawOverrides is Map<String, Object?>
          ? ModeOverrides.fromJson(rawOverrides)
          : null,
      trackingEnabled: json['trackingEnabled'] as bool? ?? false,
      trackingIntervalSeconds:
          (json['trackingIntervalSeconds'] as num?)?.toInt() ?? 300,
      trackingBufferSize:
          (json['trackingBufferSize'] as num?)?.toInt() ?? 50,
      iconName: json['iconName'] as String?,
      pauseAllowed: json['pauseAllowed'] as bool? ?? true,
      maxPauseMinutes: (json['maxPauseMinutes'] as num?)?.toInt(),
      isDistressMode: json['isDistressMode'] as bool? ?? false,
    );
  }

  /// Stable identifier (UUID).
  final String id;

  /// Display name.
  final String name;

  /// Which check-in mechanism this mode uses.
  final ChainStepType checkInType;

  /// Main escalation chain; first step drives check-in.
  final List<ChainStep> chainSteps;

  /// Id of the distress chain to use. Null = use the default (first
  /// entry in the distress-chain repository).
  final String? distressModeId;

  /// Triggers that switch to the distress chain.
  final List<DistressTrigger> distressTriggers;

  /// Triggers that auto-disarm the session.
  final List<DisarmTrigger> disarmTriggers;

  /// Optional per-mode overrides of `AppDefaults`.
  final ModeOverrides? overrides;

  /// Spec 11 §DE-3 — when true, the engine runs a periodic GPS
  /// sampler during the session. Default `false`.
  final bool trackingEnabled;

  /// Spec 11 §DE-3 — sampling cadence in seconds when
  /// [trackingEnabled]. Default 300 (5 min). Values below 10s are
  /// not enforced at the model layer; the UI snaps to the spec
  /// snap-stops list (10s, 30s, 1m, 2m, 5m, 10m, 15m, 30m, 1h).
  final int trackingIntervalSeconds;

  /// Spec 11 §DE-3 — maximum number of points kept in the ephemeral
  /// in-memory tracking buffer. Default 50.
  final int trackingBufferSize;

  /// Optional symbolic icon name (e.g. `directions_walk`). Resolved
  /// to a Material `IconData` by `kModeIconLibrary` on the UI side.
  /// `null` = no preference; the UI falls back to its name-based
  /// heuristic.
  final String? iconName;

  /// Q11 — whether the user can pause an active session via the
  /// session screen's "Pause" button. Defaults to true.
  final bool pauseAllowed;

  /// Q11 — when [pauseAllowed], the maximum allowed pause duration
  /// in minutes. `null` = unlimited. Defaults to null.
  final int? maxPauseMinutes;

  /// Whether this mode is a distress mode. Distress modes are the
  /// targets of `distressModeId` references on regular modes and are
  /// managed separately in the UI. Default `false`.
  final bool isDistressMode;

  /// Returns a new mode with the given fields replaced.
  SessionMode copyWith({
    String? id,
    String? name,
    ChainStepType? checkInType,
    List<ChainStep>? chainSteps,
    String? distressModeId,
    List<DistressTrigger>? distressTriggers,
    List<DisarmTrigger>? disarmTriggers,
    ModeOverrides? overrides,
    bool? trackingEnabled,
    int? trackingIntervalSeconds,
    int? trackingBufferSize,
    String? iconName,
    bool clearIconName = false,
    bool? pauseAllowed,
    int? maxPauseMinutes,
    bool clearMaxPauseMinutes = false,
    bool? isDistressMode,
  }) => SessionMode(
    id: id ?? this.id,
    name: name ?? this.name,
    checkInType: checkInType ?? this.checkInType,
    chainSteps: chainSteps ?? this.chainSteps,
    distressModeId: distressModeId ?? this.distressModeId,
    distressTriggers: distressTriggers ?? this.distressTriggers,
    disarmTriggers: disarmTriggers ?? this.disarmTriggers,
    overrides: overrides ?? this.overrides,
    trackingEnabled: trackingEnabled ?? this.trackingEnabled,
    trackingIntervalSeconds:
        trackingIntervalSeconds ?? this.trackingIntervalSeconds,
    trackingBufferSize: trackingBufferSize ?? this.trackingBufferSize,
    iconName: clearIconName ? null : (iconName ?? this.iconName),
    pauseAllowed: pauseAllowed ?? this.pauseAllowed,
    maxPauseMinutes: clearMaxPauseMinutes
        ? null
        : (maxPauseMinutes ?? this.maxPauseMinutes),
    isDistressMode: isDistressMode ?? this.isDistressMode,
  );

  /// Serializes to JSON.
  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'checkInType': checkInType.name,
    'chainSteps': chainSteps.map((s) => s.toJson()).toList(growable: false),
    'distressModeId': distressModeId,
    'distressTriggers': distressTriggers
        .map((t) => t.toJson())
        .toList(growable: false),
    'disarmTriggers': disarmTriggers
        .map((t) => t.toJson())
        .toList(growable: false),
    'overrides': overrides?.toJson(),
    'trackingEnabled': trackingEnabled,
    'trackingIntervalSeconds': trackingIntervalSeconds,
    'trackingBufferSize': trackingBufferSize,
    if (iconName != null) 'iconName': iconName,
    'pauseAllowed': pauseAllowed,
    'maxPauseMinutes': maxPauseMinutes,
    'isDistressMode': isDistressMode,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SessionMode) return false;
    if (other.id != id) return false;
    if (other.name != name) return false;
    if (other.checkInType != checkInType) return false;
    if (other.distressModeId != distressModeId) return false;
    if (other.overrides != overrides) return false;
    if (other.trackingEnabled != trackingEnabled) return false;
    if (other.trackingIntervalSeconds != trackingIntervalSeconds) {
      return false;
    }
    if (other.trackingBufferSize != trackingBufferSize) return false;
    if (other.iconName != iconName) return false;
    if (other.pauseAllowed != pauseAllowed) return false;
    if (other.maxPauseMinutes != maxPauseMinutes) return false;
    if (other.isDistressMode != isDistressMode) return false;
    if (!_listEquals(other.chainSteps, chainSteps)) return false;
    if (!_listEquals(other.distressTriggers, distressTriggers)) return false;
    if (!_listEquals(other.disarmTriggers, disarmTriggers)) return false;
    return true;
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    checkInType,
    Object.hashAll(chainSteps),
    distressModeId,
    Object.hashAll(distressTriggers),
    Object.hashAll(disarmTriggers),
    overrides,
    trackingEnabled,
    trackingIntervalSeconds,
    trackingBufferSize,
    iconName,
    pauseAllowed,
    maxPauseMinutes,
    isDistressMode,
  );

  @override
  String toString() =>
      'SessionMode(id: $id, name: $name, '
      'checkInType: $checkInType, steps: ${chainSteps.length})';
}

ChainStepType _checkInTypeFromJson(Object? raw) => switch (raw) {
  'holdButton' => ChainStepType.holdButton,
  'disguisedReminder' => ChainStepType.disguisedReminder,
  'countdownWarning' => ChainStepType.countdownWarning,
  'fakeCall' => ChainStepType.fakeCall,
  'smsContact' => ChainStepType.smsContact,
  'phoneCallContact' => ChainStepType.phoneCallContact,
  'loudAlarm' => ChainStepType.loudAlarm,
  'callEmergency' => ChainStepType.callEmergency,
  'hardwareButton' => ChainStepType.hardwareButton,
  _ => throw ArgumentError.value(raw, 'checkInType', 'unknown ChainStepType'),
};

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
