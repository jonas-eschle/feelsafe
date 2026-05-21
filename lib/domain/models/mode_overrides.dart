import 'package:guardianangela/domain/models/event_defaults.dart';
import 'package:guardianangela/domain/models/gps_logging_config.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/domain/models/stealth_config.dart';

/// Per-mode optional overrides of [AppDefaults].
///
/// When set on a [SessionMode], any non-null field replaces the
/// corresponding [AppDefaults] value for that mode only.
/// [localTemplates] are APPENDED to [AppDefaults.templates] — the
/// effective template list = global templates + local templates.
/// See spec 03 §ModeOverrides.
final class ModeOverrides {
  /// Creates a [ModeOverrides] instance.
  ///
  /// All fields are nullable — null means "inherit from [AppDefaults]".
  const ModeOverrides({
    this.gpsLogging,
    this.stealth,
    this.localTemplates,
    this.eventDefaults,
  });

  /// Deserialises a [ModeOverrides] from [json].
  factory ModeOverrides.fromJson(Map<String, dynamic> json) => ModeOverrides(
    gpsLogging: json['gpsLogging'] != null
        ? GpsLoggingConfig.fromJson(json['gpsLogging'] as Map<String, dynamic>)
        : null,
    stealth: json['stealth'] != null
        ? StealthConfig.fromJson(json['stealth'] as Map<String, dynamic>)
        : null,
    localTemplates: (json['localTemplates'] as List<dynamic>?)
        ?.map((e) => ReminderTemplate.fromJson(e as Map<String, dynamic>))
        .toList(),
    eventDefaults: json['eventDefaults'] != null
        ? EventDefaults.fromJson(json['eventDefaults'] as Map<String, dynamic>)
        : null,
  );

  /// Per-mode GPS logging config. Null = inherit [AppDefaults.gpsLogging].
  final GpsLoggingConfig? gpsLogging;

  /// Per-mode stealth config. Null = inherit [AppDefaults.stealth].
  final StealthConfig? stealth;

  /// Templates appended to [AppDefaults.templates] for this mode only.
  final List<ReminderTemplate>? localTemplates;

  /// Per-mode event defaults. Null = inherit [AppDefaults.eventDefaults].
  final EventDefaults? eventDefaults;

  /// Returns a copy with the specified fields replaced.
  ModeOverrides copyWith({
    GpsLoggingConfig? gpsLogging,
    StealthConfig? stealth,
    List<ReminderTemplate>? localTemplates,
    EventDefaults? eventDefaults,
  }) => ModeOverrides(
    gpsLogging: gpsLogging ?? this.gpsLogging,
    stealth: stealth ?? this.stealth,
    localTemplates: localTemplates ?? this.localTemplates,
    eventDefaults: eventDefaults ?? this.eventDefaults,
  );

  /// Serialises this instance to a JSON map.
  Map<String, dynamic> toJson() => {
    if (gpsLogging != null) 'gpsLogging': gpsLogging!.toJson(),
    if (stealth != null) 'stealth': stealth!.toJson(),
    if (localTemplates != null)
      'localTemplates': localTemplates!.map((t) => t.toJson()).toList(),
    if (eventDefaults != null) 'eventDefaults': eventDefaults!.toJson(),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! ModeOverrides) {
      return false;
    }
    if (localTemplates?.length != other.localTemplates?.length) {
      return false;
    }
    if (localTemplates != null && other.localTemplates != null) {
      for (var i = 0; i < localTemplates!.length; i++) {
        if (localTemplates![i] != other.localTemplates![i]) {
          return false;
        }
      }
    }
    return gpsLogging == other.gpsLogging &&
        stealth == other.stealth &&
        eventDefaults == other.eventDefaults;
  }

  @override
  int get hashCode => Object.hash(
    gpsLogging,
    stealth,
    Object.hashAll(localTemplates ?? const []),
    eventDefaults,
  );
}
