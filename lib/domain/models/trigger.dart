/// Sealed `Trigger` hierarchy — `DistressTrigger` and
/// `DisarmTrigger` subtrees.
///
/// Triggers are stored inline on `SessionMode`. They are serialized
/// with a `kind` (distress/disarm) plus a subtype `type`
/// discriminator so `fromJson` dispatches via sealed switch.
library;

import 'package:guardianangela/domain/models/step_config.dart';

/// Root of the trigger hierarchy.
sealed class Trigger {
  /// Const base constructor — no fields on the root.
  const Trigger();

  /// Serializes this trigger to JSON with both `kind` and sub-`type`
  /// tags.
  Map<String, Object?> toJson();

  /// Deserializes a `Trigger` by inspecting the `kind` tag.
  static Trigger fromJson(Map<String, Object?> json) {
    final kind = json['kind'];
    if (kind is! String) {
      throw ArgumentError.value(kind, 'kind', 'missing Trigger kind');
    }
    return switch (kind) {
      'distress' => DistressTrigger.fromJson(json),
      'disarm' => DisarmTrigger.fromJson(json),
      _ => throw ArgumentError.value(kind, 'kind', 'unknown Trigger kind'),
    };
  }
}

// ---------------------------------------------------------------------
// Distress triggers
// ---------------------------------------------------------------------

/// Root of hardware-pattern distress-subtypes.
sealed class HardwareTrigger {
  /// Const base constructor — no fields on the root.
  const HardwareTrigger();

  /// Serializes with a `type` tag.
  Map<String, Object?> toJson();

  /// Deserializes a `HardwareTrigger` by inspecting the `type` tag.
  static HardwareTrigger fromJson(Map<String, Object?> json) {
    final tag = json['type'];
    if (tag is! String) {
      throw ArgumentError.value(tag, 'type', 'missing HardwareTrigger tag');
    }
    return switch (tag) {
      'repeatPress' => RepeatPressTrigger.fromJson(json),
      'longPress' => LongPressTrigger.fromJson(json),
      _ => throw ArgumentError.value(
        tag,
        'type',
        'unknown HardwareTrigger tag',
      ),
    };
  }
}

/// Requires N presses of a hardware button within a short window.
final class RepeatPressTrigger extends HardwareTrigger {
  /// Creates a repeat-press trigger.
  ///
  /// [pressCount] — required press count; defaults to 5.
  /// [pressWindowMs] — max window in milliseconds; defaults to 500.
  const RepeatPressTrigger({this.pressCount = 5, this.pressWindowMs = 500});

  /// Deserializes from JSON.
  factory RepeatPressTrigger.fromJson(Map<String, Object?> json) =>
      RepeatPressTrigger(
        pressCount: (json['pressCount'] as num?)?.toInt() ?? 5,
        pressWindowMs: (json['pressWindowMs'] as num?)?.toInt() ?? 500,
      );

  /// Required presses. Defaults to 5.
  final int pressCount;

  /// Max window in milliseconds. Defaults to 500.
  final int pressWindowMs;

  /// Returns a new trigger with the given fields replaced.
  RepeatPressTrigger copyWith({int? pressCount, int? pressWindowMs}) =>
      RepeatPressTrigger(
        pressCount: pressCount ?? this.pressCount,
        pressWindowMs: pressWindowMs ?? this.pressWindowMs,
      );

  @override
  Map<String, Object?> toJson() => {
    'type': 'repeatPress',
    'pressCount': pressCount,
    'pressWindowMs': pressWindowMs,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepeatPressTrigger &&
          other.pressCount == pressCount &&
          other.pressWindowMs == pressWindowMs;

  @override
  int get hashCode => Object.hash(pressCount, pressWindowMs);

  @override
  String toString() =>
      'RepeatPressTrigger($pressCount presses / ${pressWindowMs}ms)';
}

/// Requires a hardware button to be held for a duration.
final class LongPressTrigger extends HardwareTrigger {
  /// Creates a long-press trigger.
  ///
  /// [durationSeconds] — required hold; defaults to 2.0.
  const LongPressTrigger({this.durationSeconds = 2.0});

  /// Deserializes from JSON.
  factory LongPressTrigger.fromJson(Map<String, Object?> json) =>
      LongPressTrigger(
        durationSeconds: (json['durationSeconds'] as num?)?.toDouble() ?? 2.0,
      );

  /// Required hold duration in seconds. Defaults to 2.0.
  final double durationSeconds;

  /// Returns a new trigger with the given fields replaced.
  LongPressTrigger copyWith({double? durationSeconds}) => LongPressTrigger(
    durationSeconds: durationSeconds ?? this.durationSeconds,
  );

  @override
  Map<String, Object?> toJson() => {
    'type': 'longPress',
    'durationSeconds': durationSeconds,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LongPressTrigger && other.durationSeconds == durationSeconds;

  @override
  int get hashCode => durationSeconds.hashCode;

  @override
  String toString() => 'LongPressTrigger(${durationSeconds}s)';
}

/// Root of distress triggers.
sealed class DistressTrigger extends Trigger {
  /// Const base constructor.
  const DistressTrigger();

  /// Deserializes a `DistressTrigger` by inspecting its `type` tag.
  static DistressTrigger fromJson(Map<String, Object?> json) {
    final tag = json['type'];
    if (tag is! String) {
      throw ArgumentError.value(tag, 'type', 'missing DistressTrigger tag');
    }
    return switch (tag) {
      'hardwareButton' => HardwareButtonDistressTrigger.fromJson(json),
      _ => throw ArgumentError.value(
        tag,
        'type',
        'unknown DistressTrigger tag',
      ),
    };
  }
}

/// A distress trigger fired by a hardware button pattern.
final class HardwareButtonDistressTrigger extends DistressTrigger {
  /// Creates a hardware-button distress trigger.
  ///
  /// [buttonType] — which physical button to watch.
  /// [trigger] — the required press pattern.
  const HardwareButtonDistressTrigger({
    required this.buttonType,
    required this.trigger,
  });

  /// Deserializes from JSON.
  factory HardwareButtonDistressTrigger.fromJson(Map<String, Object?> json) =>
      HardwareButtonDistressTrigger(
        buttonType: _buttonTypeFromJson(json['buttonType']),
        trigger: HardwareTrigger.fromJson(
          json['trigger']! as Map<String, Object?>,
        ),
      );

  /// Which physical button.
  final ButtonType buttonType;

  /// The pattern that must be satisfied.
  final HardwareTrigger trigger;

  /// Returns a new trigger with the given fields replaced.
  HardwareButtonDistressTrigger copyWith({
    ButtonType? buttonType,
    HardwareTrigger? trigger,
  }) => HardwareButtonDistressTrigger(
    buttonType: buttonType ?? this.buttonType,
    trigger: trigger ?? this.trigger,
  );

  @override
  Map<String, Object?> toJson() => {
    'kind': 'distress',
    'type': 'hardwareButton',
    'buttonType': buttonType.name,
    'trigger': trigger.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HardwareButtonDistressTrigger &&
          other.buttonType == buttonType &&
          other.trigger == trigger;

  @override
  int get hashCode => Object.hash(buttonType, trigger);

  @override
  String toString() => 'HardwareButtonDistressTrigger($buttonType, $trigger)';
}

// ---------------------------------------------------------------------
// Disarm triggers
// ---------------------------------------------------------------------

/// Root of disarm triggers.
sealed class DisarmTrigger extends Trigger {
  /// Const base constructor.
  const DisarmTrigger();

  /// Deserializes a `DisarmTrigger` by inspecting its `type` tag.
  static DisarmTrigger fromJson(Map<String, Object?> json) {
    final tag = json['type'];
    if (tag is! String) {
      throw ArgumentError.value(tag, 'type', 'missing DisarmTrigger tag');
    }
    return switch (tag) {
      'gpsArrival' => GpsArrivalDisarmTrigger.fromJson(json),
      'timer' => TimerDisarmTrigger.fromJson(json),
      'wrongPinThreshold' => WrongPinThresholdDisarmTrigger.fromJson(json),
      _ => throw ArgumentError.value(tag, 'type', 'unknown DisarmTrigger tag'),
    };
  }
}

/// Disarm when the user arrives at a configured location.
final class GpsArrivalDisarmTrigger extends DisarmTrigger {
  /// Creates a GPS-arrival disarm trigger.
  ///
  /// [latitude] — WGS84 latitude.
  /// [longitude] — WGS84 longitude.
  /// [radiusMeters] — arrival radius; defaults to 100.
  const GpsArrivalDisarmTrigger({
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 100,
  });

  /// Deserializes from JSON.
  factory GpsArrivalDisarmTrigger.fromJson(Map<String, Object?> json) =>
      GpsArrivalDisarmTrigger(
        latitude: (json['latitude']! as num).toDouble(),
        longitude: (json['longitude']! as num).toDouble(),
        radiusMeters: (json['radiusMeters'] as num?)?.toDouble() ?? 100,
      );

  /// Target latitude (WGS84).
  final double latitude;

  /// Target longitude (WGS84).
  final double longitude;

  /// Arrival radius in meters. Defaults to 100.
  final double radiusMeters;

  /// Returns a new trigger with the given fields replaced.
  GpsArrivalDisarmTrigger copyWith({
    double? latitude,
    double? longitude,
    double? radiusMeters,
  }) => GpsArrivalDisarmTrigger(
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    radiusMeters: radiusMeters ?? this.radiusMeters,
  );

  @override
  Map<String, Object?> toJson() => {
    'kind': 'disarm',
    'type': 'gpsArrival',
    'latitude': latitude,
    'longitude': longitude,
    'radiusMeters': radiusMeters,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GpsArrivalDisarmTrigger &&
          other.latitude == latitude &&
          other.longitude == longitude &&
          other.radiusMeters == radiusMeters;

  @override
  int get hashCode => Object.hash(latitude, longitude, radiusMeters);

  @override
  String toString() =>
      'GpsArrivalDisarmTrigger($latitude,$longitude / ${radiusMeters}m)';
}

/// Disarm after a fixed duration.
final class TimerDisarmTrigger extends DisarmTrigger {
  /// Creates a timer disarm trigger.
  ///
  /// [durationSeconds] — how long the session should run before
  /// auto-disarm.
  const TimerDisarmTrigger({required this.durationSeconds});

  /// Deserializes from JSON.
  factory TimerDisarmTrigger.fromJson(Map<String, Object?> json) =>
      TimerDisarmTrigger(
        durationSeconds: (json['durationSeconds']! as num).toInt(),
      );

  /// Duration in seconds.
  final int durationSeconds;

  /// Returns a new trigger with the given fields replaced.
  TimerDisarmTrigger copyWith({int? durationSeconds}) => TimerDisarmTrigger(
    durationSeconds: durationSeconds ?? this.durationSeconds,
  );

  @override
  Map<String, Object?> toJson() => {
    'kind': 'disarm',
    'type': 'timer',
    'durationSeconds': durationSeconds,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimerDisarmTrigger && other.durationSeconds == durationSeconds;

  @override
  int get hashCode => durationSeconds.hashCode;

  @override
  String toString() => 'TimerDisarmTrigger(${durationSeconds}s)';
}

/// Disarm once the user has entered the wrong PIN enough times.
final class WrongPinThresholdDisarmTrigger extends DisarmTrigger {
  /// Creates a wrong-PIN-threshold trigger.
  ///
  /// [threshold] — number of wrong attempts before auto-disarm;
  /// defaults to 5.
  const WrongPinThresholdDisarmTrigger({this.threshold = 5});

  /// Deserializes from JSON.
  factory WrongPinThresholdDisarmTrigger.fromJson(Map<String, Object?> json) =>
      WrongPinThresholdDisarmTrigger(
        threshold: (json['threshold'] as num?)?.toInt() ?? 5,
      );

  /// Wrong-attempt threshold. Defaults to 5.
  final int threshold;

  /// Returns a new trigger with the given fields replaced.
  WrongPinThresholdDisarmTrigger copyWith({int? threshold}) =>
      WrongPinThresholdDisarmTrigger(threshold: threshold ?? this.threshold);

  @override
  Map<String, Object?> toJson() => {
    'kind': 'disarm',
    'type': 'wrongPinThreshold',
    'threshold': threshold,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WrongPinThresholdDisarmTrigger && other.threshold == threshold;

  @override
  int get hashCode => threshold.hashCode;

  @override
  String toString() => 'WrongPinThresholdDisarmTrigger($threshold)';
}

ButtonType _buttonTypeFromJson(Object? raw) => switch (raw) {
  'volumeUp' => ButtonType.volumeUp,
  'volumeDown' => ButtonType.volumeDown,
  'power' => ButtonType.power,
  _ => throw ArgumentError.value(raw, 'buttonType', 'unknown ButtonType'),
};
