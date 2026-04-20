/// `ModeOverrides` — optional per-mode overrides of `AppDefaults`.
///
/// Any non-null field replaces the corresponding `AppDefaults`
/// value for that mode. `localTemplates` are APPENDED to the global
/// templates, not replacing them.
library;

import 'package:guardianangela/domain/models/event_defaults.dart';
import 'package:guardianangela/domain/models/gps_logging_config.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/domain/models/stealth_config.dart';

/// Per-mode optional overrides of app-wide defaults.
final class ModeOverrides {
  /// Creates mode overrides.
  ///
  /// [distressChainId] — override the mode's distress-chain
  /// selection; null = inherit from `SessionMode.distressChainId`
  /// (which itself defaults to the first chain in the repository).
  /// [gpsLogging] — override `AppDefaults.gpsLogging`; null =
  /// inherit.
  /// [stealth] — override `AppDefaults.stealth`; null = inherit.
  /// [localTemplates] — appended to `AppDefaults.templates`;
  /// defaults to empty.
  /// [eventDefaults] — override `AppDefaults.eventDefaults`; null =
  /// inherit.
  const ModeOverrides({
    this.distressChainId,
    this.gpsLogging,
    this.stealth,
    this.localTemplates = const [],
    this.eventDefaults,
  });

  /// Deserializes `ModeOverrides` from JSON.
  factory ModeOverrides.fromJson(Map<String, Object?> json) {
    final rawTemplates = json['localTemplates'];
    return ModeOverrides(
      distressChainId: json['distressChainId'] as String?,
      gpsLogging: json['gpsLogging'] is Map<String, Object?>
          ? GpsLoggingConfig.fromJson(
              json['gpsLogging']! as Map<String, Object?>,
            )
          : null,
      stealth: json['stealth'] is Map<String, Object?>
          ? StealthConfig.fromJson(json['stealth']! as Map<String, Object?>)
          : null,
      localTemplates: rawTemplates is List
          ? List<ReminderTemplate>.unmodifiable(
              rawTemplates.map(
                (e) => ReminderTemplate.fromJson(e as Map<String, Object?>),
              ),
            )
          : const [],
      eventDefaults: json['eventDefaults'] is Map<String, Object?>
          ? EventDefaults.fromJson(
              json['eventDefaults']! as Map<String, Object?>,
            )
          : null,
    );
  }

  /// Override mode's distress-chain id; null = inherit.
  final String? distressChainId;

  /// Per-mode GPS-logging override; null = inherit.
  final GpsLoggingConfig? gpsLogging;

  /// Per-mode stealth override; null = inherit.
  final StealthConfig? stealth;

  /// Mode-local templates appended to the global list. Defaults to
  /// empty.
  final List<ReminderTemplate> localTemplates;

  /// Per-mode event defaults override; null = inherit.
  final EventDefaults? eventDefaults;

  /// Returns a new `ModeOverrides` with the given fields replaced.
  ModeOverrides copyWith({
    String? distressChainId,
    GpsLoggingConfig? gpsLogging,
    StealthConfig? stealth,
    List<ReminderTemplate>? localTemplates,
    EventDefaults? eventDefaults,
  }) => ModeOverrides(
    distressChainId: distressChainId ?? this.distressChainId,
    gpsLogging: gpsLogging ?? this.gpsLogging,
    stealth: stealth ?? this.stealth,
    localTemplates: localTemplates ?? this.localTemplates,
    eventDefaults: eventDefaults ?? this.eventDefaults,
  );

  /// Serializes to JSON.
  Map<String, Object?> toJson() => {
    'distressChainId': distressChainId,
    'gpsLogging': gpsLogging?.toJson(),
    'stealth': stealth?.toJson(),
    'localTemplates': localTemplates
        .map((t) => t.toJson())
        .toList(growable: false),
    'eventDefaults': eventDefaults?.toJson(),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ModeOverrides) return false;
    if (other.distressChainId != distressChainId) return false;
    if (other.gpsLogging != gpsLogging) return false;
    if (other.stealth != stealth) return false;
    if (other.eventDefaults != eventDefaults) return false;
    if (other.localTemplates.length != localTemplates.length) return false;
    for (var i = 0; i < localTemplates.length; i++) {
      if (other.localTemplates[i] != localTemplates[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    distressChainId,
    gpsLogging,
    stealth,
    Object.hashAll(localTemplates),
    eventDefaults,
  );

  @override
  String toString() => 'ModeOverrides(distressChainId: $distressChainId)';
}
