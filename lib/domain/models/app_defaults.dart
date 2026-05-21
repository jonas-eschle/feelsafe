import 'package:guardianangela/domain/models/event_defaults.dart';
import 'package:guardianangela/domain/models/gps_logging_config.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/domain/models/stealth_config.dart';

/// Master source for configurable defaults that all modes inherit.
///
/// Embedded inside [AppSettings]. Modes inherit from [AppDefaults] unless
/// they specify a [ModeOverrides]. The [defaultDistressModeId] is the
/// runtime resolution target when [SessionMode.distressModeId] is null.
/// See spec 03 §AppDefaults.
final class AppDefaults {
  /// Creates an [AppDefaults] instance.
  const AppDefaults({
    this.gpsLogging = const GpsLoggingConfig(),
    this.stealth = const StealthConfig(),
    this.templates = const [],
    this.eventDefaults = const EventDefaults(),
    this.defaultDistressModeId,
  });

  /// Deserialises an [AppDefaults] from [json].
  factory AppDefaults.fromJson(Map<String, dynamic> json) => AppDefaults(
    gpsLogging: json['gpsLogging'] != null
        ? GpsLoggingConfig.fromJson(json['gpsLogging'] as Map<String, dynamic>)
        : const GpsLoggingConfig(),
    stealth: json['stealth'] != null
        ? StealthConfig.fromJson(json['stealth'] as Map<String, dynamic>)
        : const StealthConfig(),
    templates:
        (json['templates'] as List<dynamic>?)
            ?.map((e) => ReminderTemplate.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [],
    eventDefaults: json['eventDefaults'] != null
        ? EventDefaults.fromJson(json['eventDefaults'] as Map<String, dynamic>)
        : const EventDefaults(),
    defaultDistressModeId: json['defaultDistressModeId'] as String?,
  );

  /// Global GPS logging configuration.
  final GpsLoggingConfig gpsLogging;

  /// Global stealth configuration.
  final StealthConfig stealth;

  /// Global reminder templates (built-in + user-created global templates).
  ///
  /// Seeded with 8 built-in templates on first launch (Phase 4).
  final List<ReminderTemplate> templates;

  /// Global per-step-type default configurations.
  final EventDefaults eventDefaults;

  /// ID of the default distress [SessionMode] (one with [isDistressMode] =
  /// true). Null = no global default; modes without their own
  /// [distressModeId] block at session start.
  final String? defaultDistressModeId;

  /// Returns a copy with the specified fields replaced.
  AppDefaults copyWith({
    GpsLoggingConfig? gpsLogging,
    StealthConfig? stealth,
    List<ReminderTemplate>? templates,
    EventDefaults? eventDefaults,
    String? defaultDistressModeId,
  }) => AppDefaults(
    gpsLogging: gpsLogging ?? this.gpsLogging,
    stealth: stealth ?? this.stealth,
    templates: templates ?? this.templates,
    eventDefaults: eventDefaults ?? this.eventDefaults,
    defaultDistressModeId: defaultDistressModeId ?? this.defaultDistressModeId,
  );

  /// Serialises this instance to a JSON map.
  Map<String, dynamic> toJson() => {
    'gpsLogging': gpsLogging.toJson(),
    'stealth': stealth.toJson(),
    'templates': templates.map((t) => t.toJson()).toList(),
    'eventDefaults': eventDefaults.toJson(),
    if (defaultDistressModeId != null)
      'defaultDistressModeId': defaultDistressModeId,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! AppDefaults) {
      return false;
    }
    if (templates.length != other.templates.length) {
      return false;
    }
    for (var i = 0; i < templates.length; i++) {
      if (templates[i] != other.templates[i]) {
        return false;
      }
    }
    return gpsLogging == other.gpsLogging &&
        stealth == other.stealth &&
        eventDefaults == other.eventDefaults &&
        defaultDistressModeId == other.defaultDistressModeId;
  }

  @override
  int get hashCode => Object.hash(
    gpsLogging,
    stealth,
    Object.hashAll(templates),
    eventDefaults,
    defaultDistressModeId,
  );
}
