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
  /// [distressChainId] — id of a chain in the distress repository;
  /// null = use default (first in repo).
  /// [distressTriggers] — triggers that switch to the distress
  /// chain. Defaults to empty.
  /// [disarmTriggers] — triggers that auto-disarm the session.
  /// Defaults to empty.
  /// [overrides] — optional per-mode overrides of `AppDefaults`.
  const SessionMode({
    required this.id,
    required this.name,
    required this.checkInType,
    this.chainSteps = const [],
    this.distressChainId,
    this.distressTriggers = const [],
    this.disarmTriggers = const [],
    this.overrides,
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
      distressChainId: json['distressChainId'] as String?,
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
  final String? distressChainId;

  /// Triggers that switch to the distress chain.
  final List<DistressTrigger> distressTriggers;

  /// Triggers that auto-disarm the session.
  final List<DisarmTrigger> disarmTriggers;

  /// Optional per-mode overrides of `AppDefaults`.
  final ModeOverrides? overrides;

  /// Returns a new mode with the given fields replaced.
  SessionMode copyWith({
    String? id,
    String? name,
    ChainStepType? checkInType,
    List<ChainStep>? chainSteps,
    String? distressChainId,
    List<DistressTrigger>? distressTriggers,
    List<DisarmTrigger>? disarmTriggers,
    ModeOverrides? overrides,
  }) => SessionMode(
    id: id ?? this.id,
    name: name ?? this.name,
    checkInType: checkInType ?? this.checkInType,
    chainSteps: chainSteps ?? this.chainSteps,
    distressChainId: distressChainId ?? this.distressChainId,
    distressTriggers: distressTriggers ?? this.distressTriggers,
    disarmTriggers: disarmTriggers ?? this.disarmTriggers,
    overrides: overrides ?? this.overrides,
  );

  /// Serializes to JSON.
  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'checkInType': checkInType.name,
    'chainSteps': chainSteps.map((s) => s.toJson()).toList(growable: false),
    'distressChainId': distressChainId,
    'distressTriggers': distressTriggers
        .map((t) => t.toJson())
        .toList(growable: false),
    'disarmTriggers': disarmTriggers
        .map((t) => t.toJson())
        .toList(growable: false),
    'overrides': overrides?.toJson(),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SessionMode) return false;
    if (other.id != id) return false;
    if (other.name != name) return false;
    if (other.checkInType != checkInType) return false;
    if (other.distressChainId != distressChainId) return false;
    if (other.overrides != overrides) return false;
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
    distressChainId,
    Object.hashAll(distressTriggers),
    Object.hashAll(disarmTriggers),
    overrides,
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
