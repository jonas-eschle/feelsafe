/// `AppDefaults` — master source for app-wide configurable defaults
/// that modes can inherit and override.
///
/// Per the D-DATA-21 decision, distress chains no longer live inside
/// `AppDefaults`; they live in their own top-level repository. This
/// class therefore intentionally has no `distressChains` field.
library;

import 'package:guardianangela/domain/models/event_defaults.dart';
import 'package:guardianangela/domain/models/gps_logging_config.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/domain/models/stealth_config.dart';

/// App-wide defaults inherited by modes.
final class AppDefaults {
  /// Creates app defaults.
  ///
  /// [gpsLogging] — global GPS logging config.
  /// [stealth] — global stealth config.
  /// [templates] — global reminder templates; defaults to empty.
  /// [eventDefaults] — global per-step-type event defaults.
  const AppDefaults({
    this.gpsLogging = const GpsLoggingConfig(),
    this.stealth = const StealthConfig(),
    this.templates = const [],
    this.eventDefaults = const EventDefaults(),
  });

  /// Deserializes `AppDefaults` from JSON.
  factory AppDefaults.fromJson(Map<String, Object?> json) {
    final rawTemplates = json['templates'];
    return AppDefaults(
      gpsLogging: json['gpsLogging'] is Map<String, Object?>
          ? GpsLoggingConfig.fromJson(
              json['gpsLogging']! as Map<String, Object?>,
            )
          : const GpsLoggingConfig(),
      stealth: json['stealth'] is Map<String, Object?>
          ? StealthConfig.fromJson(json['stealth']! as Map<String, Object?>)
          : const StealthConfig(),
      templates: rawTemplates is List
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
          : const EventDefaults(),
    );
  }

  /// Global GPS logging defaults.
  final GpsLoggingConfig gpsLogging;

  /// Global stealth defaults.
  final StealthConfig stealth;

  /// Global reminder templates available to every mode.
  final List<ReminderTemplate> templates;

  /// Global per-step-type event defaults.
  final EventDefaults eventDefaults;

  /// Returns a new `AppDefaults` with the given fields replaced.
  AppDefaults copyWith({
    GpsLoggingConfig? gpsLogging,
    StealthConfig? stealth,
    List<ReminderTemplate>? templates,
    EventDefaults? eventDefaults,
  }) => AppDefaults(
    gpsLogging: gpsLogging ?? this.gpsLogging,
    stealth: stealth ?? this.stealth,
    templates: templates ?? this.templates,
    eventDefaults: eventDefaults ?? this.eventDefaults,
  );

  /// Serializes to JSON.
  Map<String, Object?> toJson() => {
    'gpsLogging': gpsLogging.toJson(),
    'stealth': stealth.toJson(),
    'templates': templates.map((t) => t.toJson()).toList(growable: false),
    'eventDefaults': eventDefaults.toJson(),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AppDefaults) return false;
    if (other.gpsLogging != gpsLogging) return false;
    if (other.stealth != stealth) return false;
    if (other.eventDefaults != eventDefaults) return false;
    if (other.templates.length != templates.length) return false;
    for (var i = 0; i < templates.length; i++) {
      if (other.templates[i] != templates[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    gpsLogging,
    stealth,
    Object.hashAll(templates),
    eventDefaults,
  );

  @override
  String toString() => 'AppDefaults(templates: ${templates.length})';
}
