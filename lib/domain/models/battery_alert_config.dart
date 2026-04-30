/// `BatteryAlertConfig` — one-shot side-action that fires once per
/// session when the battery drops below a threshold.
library;

import 'package:guardianangela/domain/models/chain_step.dart';

/// Configuration for the per-session low-battery alert.
final class BatteryAlertConfig {
  /// Creates a battery-alert config.
  ///
  /// [enabled] — master toggle; defaults to **false** (Q34: opt-in,
  /// privacy-first since the alert auto-fires SMS).
  /// [thresholdPercent] — battery percentage at which the alert
  /// fires, 0–100; defaults to **10** (Q35: closer to actual
  /// emergency, fewer false fires).
  /// [chain] — configurable escalation chain executed when the
  /// threshold is reached; defaults to empty.
  const BatteryAlertConfig({
    this.enabled = false,
    this.thresholdPercent = 10,
    this.chain = const [],
  });

  /// Deserializes a `BatteryAlertConfig` from JSON.
  factory BatteryAlertConfig.fromJson(Map<String, Object?> json) {
    final raw = json['chain'];
    return BatteryAlertConfig(
      enabled: json['enabled'] as bool? ?? false,
      thresholdPercent: (json['thresholdPercent'] as num?)?.toInt() ?? 10,
      chain: raw is List
          ? List<ChainStep>.unmodifiable(
              raw.map((e) => ChainStep.fromJson(e as Map<String, Object?>)),
            )
          : const [],
    );
  }

  /// Master toggle. Defaults to true.
  final bool enabled;

  /// Battery percentage that triggers the alert (0–100). Defaults
  /// to 15.
  final int thresholdPercent;

  /// Escalation chain executed on trigger. Defaults to the empty
  /// list (no-op).
  final List<ChainStep> chain;

  /// Returns a new config with the given fields replaced.
  BatteryAlertConfig copyWith({
    bool? enabled,
    int? thresholdPercent,
    List<ChainStep>? chain,
  }) => BatteryAlertConfig(
    enabled: enabled ?? this.enabled,
    thresholdPercent: thresholdPercent ?? this.thresholdPercent,
    chain: chain ?? this.chain,
  );

  /// Serializes to JSON.
  Map<String, Object?> toJson() => {
    'enabled': enabled,
    'thresholdPercent': thresholdPercent,
    'chain': chain.map((s) => s.toJson()).toList(growable: false),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BatteryAlertConfig) return false;
    if (other.enabled != enabled) return false;
    if (other.thresholdPercent != thresholdPercent) return false;
    if (other.chain.length != chain.length) return false;
    for (var i = 0; i < chain.length; i++) {
      if (other.chain[i] != chain[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      Object.hash(enabled, thresholdPercent, Object.hashAll(chain));

  @override
  String toString() =>
      'BatteryAlertConfig(enabled: $enabled, '
      'thresholdPercent: $thresholdPercent, steps: ${chain.length})';
}
