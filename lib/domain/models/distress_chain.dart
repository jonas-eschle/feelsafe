/// `DistressChain` — a globally-managed named distress chain.
///
/// All distress triggers for a mode fire the same selected
/// `DistressChain`. Chains live in a dedicated top-level repository;
/// the first entry is the default used when
/// `SessionMode.distressChainId` is null.
library;

import 'package:guardianangela/domain/models/chain_step.dart';

/// A named distress chain consisting of an ordered list of
/// `ChainStep`s.
final class DistressChain {
  /// Creates a distress chain.
  ///
  /// [id] — stable UUID.
  /// [name] — human-readable name (e.g., "Default Distress Chain").
  /// [steps] — ordered escalation steps; may be empty.
  const DistressChain({
    required this.id,
    required this.name,
    this.steps = const [],
  });

  /// Deserializes a `DistressChain` from JSON.
  factory DistressChain.fromJson(Map<String, Object?> json) {
    final raw = json['steps'];
    return DistressChain(
      id: json['id']! as String,
      name: json['name']! as String,
      steps: raw is List
          ? List<ChainStep>.unmodifiable(
              raw.map((e) => ChainStep.fromJson(e as Map<String, Object?>)),
            )
          : const [],
    );
  }

  /// Stable identifier (UUID).
  final String id;

  /// Display name of the chain.
  final String name;

  /// Ordered escalation steps. Defaults to the empty list.
  final List<ChainStep> steps;

  /// Returns a new chain with the given fields replaced.
  DistressChain copyWith({String? id, String? name, List<ChainStep>? steps}) =>
      DistressChain(
        id: id ?? this.id,
        name: name ?? this.name,
        steps: steps ?? this.steps,
      );

  /// Serializes to JSON.
  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'steps': steps.map((s) => s.toJson()).toList(growable: false),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DistressChain) return false;
    if (other.id != id || other.name != name) return false;
    if (other.steps.length != steps.length) return false;
    for (var i = 0; i < steps.length; i++) {
      if (other.steps[i] != steps[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(id, name, Object.hashAll(steps));

  @override
  String toString() =>
      'DistressChain(id: $id, name: $name, steps: ${steps.length})';
}
