import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/chain_step.dart';

/// Configuration for the low-battery one-shot alert.
///
/// JSON-backed singleton (`battery_alert.json`). When [enabled] and
/// battery drops below [thresholdPercent] during an active session, the
/// [chain] fires once as a side-action — the main session continues
/// uninterrupted. See spec 03 §BatteryAlertConfig.
///
/// Forbidden step types in [chain]: [ChainStepType.holdButton],
/// [ChainStepType.disguisedReminder], [ChainStepType.hardwareButton]
/// (interactive types are not permitted — the alert is OS-triggered,
/// not user-driven).
final class BatteryAlertConfig {
  /// Creates a [BatteryAlertConfig] instance.
  ///
  /// Defaults: [enabled] = false (Q22 — opt-in), [thresholdPercent] = 10,
  /// [chain] = empty.
  BatteryAlertConfig({
    this.enabled = false,
    this.thresholdPercent = 10,
    this.chain = const [],
  }) : assert(
         thresholdPercent >= 1 && thresholdPercent <= 99,
         'BatteryAlertConfig.thresholdPercent must be 1–99',
       ) {
    validateChain(chain);
  }

  /// Forbidden step types in a battery-alert chain.
  ///
  /// Interactive types cannot be used because the alert fires
  /// automatically without user interaction.
  static const forbiddenStepTypes = {
    ChainStepType.holdButton,
    ChainStepType.disguisedReminder,
    ChainStepType.hardwareButton,
  };

  /// Whether the battery alert is enabled. Default false per Q22 (opt-in).
  ///
  /// A safety app must not surprise users with automatic alerts.
  final bool enabled;

  /// Battery percentage at which the alert fires. Default 10.
  final int thresholdPercent;

  /// The chain executed as a side-action when the alert fires.
  ///
  /// Empty list = no-op. Must not contain [forbiddenStepTypes].
  final List<ChainStep> chain;

  /// Throws [ArgumentError] if [steps] contains a forbidden step type.
  static void validateChain(List<ChainStep> steps) {
    for (final step in steps) {
      if (forbiddenStepTypes.contains(step.type)) {
        throw ArgumentError(
          'BatteryAlertConfig.chain may not contain '
          '${step.type.name} steps (interactive types are forbidden)',
        );
      }
    }
  }

  /// Returns a copy with the specified fields replaced.
  BatteryAlertConfig copyWith({
    bool? enabled,
    int? thresholdPercent,
    List<ChainStep>? chain,
  }) => BatteryAlertConfig(
    enabled: enabled ?? this.enabled,
    thresholdPercent: thresholdPercent ?? this.thresholdPercent,
    chain: chain ?? this.chain,
  );

  /// Serialises this config to a JSON map.
  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'thresholdPercent': thresholdPercent,
    'chain': chain.map((s) => s.toJson()).toList(),
  };

  /// Deserialises a [BatteryAlertConfig] from [json].
  factory BatteryAlertConfig.fromJson(Map<String, dynamic> json) =>
      BatteryAlertConfig(
        enabled: (json['enabled'] as bool?) ?? false,
        thresholdPercent: (json['thresholdPercent'] as num?)?.toInt() ?? 10,
        chain:
            (json['chain'] as List<dynamic>?)
                ?.map((e) => ChainStep.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! BatteryAlertConfig) {
      return false;
    }
    if (chain.length != other.chain.length) {
      return false;
    }
    for (var i = 0; i < chain.length; i++) {
      if (chain[i] != other.chain[i]) {
        return false;
      }
    }
    return enabled == other.enabled &&
        thresholdPercent == other.thresholdPercent;
  }

  @override
  int get hashCode =>
      Object.hash(enabled, thresholdPercent, Object.hashAll(chain));
}
