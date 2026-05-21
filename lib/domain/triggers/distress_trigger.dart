import 'package:guardianangela/domain/enums/button_type.dart';
import 'package:guardianangela/domain/enums/press_pattern.dart';

/// Base class for all distress triggers.
///
/// Distress triggers run in parallel with the main chain and fire
/// the mode's resolved distress mode when activated. See spec 03
/// §DistressTrigger. Each subclass serialises to/from JSON via a
/// `type` discriminator field.
sealed class DistressTrigger {
  /// Constant constructor for subclasses.
  const DistressTrigger();

  /// Serialises this trigger to a JSON map with a `type` discriminator.
  Map<String, dynamic> toJson();

  /// Deserialises a [DistressTrigger] from [json].
  ///
  /// Dispatches on the `type` field:
  /// - `'hardware_button'` → [HardwareButtonDistressTrigger]
  factory DistressTrigger.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'hardware_button' => HardwareButtonDistressTrigger.fromJson(json),
      _ => throw ArgumentError('Unknown DistressTrigger type: $type'),
    };
  }
}

/// Hardware-button panic trigger.
///
/// Fires the distress chain when the user presses a physical device button
/// in the configured pattern. Both [PressPattern.repeatPress] and
/// [PressPattern.longPress] ship at v3 GA per D15 and spec 03 §DistressTrigger
/// line 565+.
///
/// - [PressPattern.repeatPress]: [pressCount] rapid presses within the
///   configured window fire the chain; [durationSeconds] is irrelevant and
///   MUST be null.
/// - [PressPattern.longPress]: a single sustained hold of [durationSeconds]
///   fires the chain; [pressCount] is irrelevant and MUST be null.
final class HardwareButtonDistressTrigger extends DistressTrigger {
  /// Creates a hardware-button distress trigger.
  ///
  /// Defaults: [buttonType] = [ButtonType.volumeUp],
  /// [pattern] = [PressPattern.repeatPress], [pressCount] = 5.
  const HardwareButtonDistressTrigger({
    this.buttonType = ButtonType.volumeUp,
    this.pattern = PressPattern.repeatPress,
    this.pressCount = 5,
    this.durationSeconds,
  });

  /// Deserialises from a JSON map produced by [toJson].
  factory HardwareButtonDistressTrigger.fromJson(Map<String, dynamic> json) =>
      HardwareButtonDistressTrigger(
        buttonType: ButtonType.values.byName(json['buttonType'] as String),
        pattern: PressPattern.values.byName(json['pattern'] as String),
        pressCount: (json['pressCount'] as num).toInt(),
        durationSeconds: (json['durationSeconds'] as num?)?.toDouble(),
      );

  /// Which physical button activates the trigger.
  final ButtonType buttonType;

  /// Whether the trigger uses rapid presses or a long hold.
  final PressPattern pattern;

  /// Number of presses required for [PressPattern.repeatPress].
  ///
  /// Default 5 per B1. Ignored (and must be null in strict validation)
  /// when [pattern] is [PressPattern.longPress].
  final int pressCount;

  /// Hold duration in seconds for [PressPattern.longPress].
  ///
  /// Default 2.0 when longPress. Null for repeatPress.
  final double? durationSeconds;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'hardware_button',
    'buttonType': buttonType.name,
    'pattern': pattern.name,
    'pressCount': pressCount,
    if (durationSeconds != null) 'durationSeconds': durationSeconds,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HardwareButtonDistressTrigger &&
          buttonType == other.buttonType &&
          pattern == other.pattern &&
          pressCount == other.pressCount &&
          durationSeconds == other.durationSeconds);

  @override
  int get hashCode =>
      Object.hash(buttonType, pattern, pressCount, durationSeconds);
}
