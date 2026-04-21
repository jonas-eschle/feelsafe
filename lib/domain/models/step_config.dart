/// Sealed `StepConfig` hierarchy and its nine concrete subtypes.
///
/// Every `ChainStep` in a chain may carry a `StepConfig`; a `null`
/// config means "inherit the matching default from
/// `EventDefaults.forType`". The nine subtypes — one per
/// `ChainStepType` — are tagged by a `type` discriminator in JSON
/// so `fromJson` can dispatch via a sealed switch.
library;

import 'package:guardianangela/data/models/enums.dart';

/// Hardware button target for a `HardwareButtonConfig` step.
///
/// Used both on the step config and on distress triggers (via
/// `HardwareButtonDistressTrigger`).
enum ButtonType {
  /// Physical volume-up rocker press.
  volumeUp,

  /// Physical volume-down rocker press.
  volumeDown,

  /// Power / side button press.
  power,
}

/// Pattern a hardware button must satisfy to fire its associated
/// action (step or distress trigger).
enum HardwarePattern {
  /// Multiple quick presses within a time window.
  repeatPress,

  /// A single continuous long press.
  longPress,
}

/// How an `SmsContactConfig` step chooses target contacts.
enum SmsContactSelection {
  /// Every channel-capable contact is messaged (dynamic set).
  allContacts,

  /// Only the first-sorted channel-capable contact is messaged.
  ///
  /// Retained for legacy stored configs (notably the seeded default
  /// distress chain). Not reachable from the redesigned editor UI.
  firstContact,

  /// Only the contacts whose IDs appear in `contactIds` (static set).
  specificIds,
}

/// Root of the typed `StepConfig` hierarchy.
///
/// Subclasses are hand-rolled immutable values. Each subtype knows
/// how to emit a `type`-tagged JSON map; [StepConfig.fromJson]
/// dispatches on the tag.
sealed class StepConfig {
  /// Const base constructor — no fields on the root.
  const StepConfig();

  /// Serializes this config to a JSON map including a `type`
  /// discriminator so `fromJson` can pick the correct subclass.
  Map<String, Object?> toJson();

  /// Deserializes [json] into the correct subclass by reading its
  /// `type` field. Throws [ArgumentError] on unknown / missing tag.
  static StepConfig fromJson(Map<String, Object?> json) {
    final tag = json['type'];
    if (tag is! String) {
      throw ArgumentError.value(tag, 'type', 'missing/invalid StepConfig tag');
    }
    return switch (tag) {
      'holdButton' => HoldButtonConfig.fromJson(json),
      'disguisedReminder' => DisguisedReminderConfig.fromJson(json),
      'hardwareButton' => HardwareButtonConfig.fromJson(json),
      'countdownWarning' => CountdownWarningConfig.fromJson(json),
      'fakeCall' => FakeCallConfig.fromJson(json),
      'smsContact' => SmsContactConfig.fromJson(json),
      'phoneCallContact' => PhoneCallContactConfig.fromJson(json),
      'loudAlarm' => LoudAlarmConfig.fromJson(json),
      'callEmergency' => CallEmergencyConfig.fromJson(json),
      _ => throw ArgumentError.value(tag, 'type', 'unknown StepConfig tag'),
    };
  }
}

/// Visual style for a `HoldButtonConfig` step.
///
/// Spec 02 §1.holdButton Config Keys.
enum HoldStyle {
  /// Standard large button.
  largeButton,

  /// Full-screen press surface.
  fullScreen,

  /// Fake-lock-screen press surface (disguised).
  fakeLockScreen,
}

/// Configuration for a `holdButton` step.
///
/// Spec 02 §1.holdButton + spec 03 §HoldButtonConfig.
final class HoldButtonConfig extends StepConfig {
  /// Creates a hold-button config.
  ///
  /// [releaseSensitivity] — seconds the engine waits after a release
  /// to confirm the user actually let go; defaults to 1.0 per spec.
  /// [holdStyle] — visual style; defaults to [HoldStyle.largeButton].
  /// [vibrateOnRelease] — buzz on release; defaults to true.
  /// [soundOnRelease] — play a sound on release; defaults to false.
  /// [blackScreenMode] — render on a black overlay; defaults to false.
  const HoldButtonConfig({
    this.releaseSensitivity = 1.0,
    this.holdStyle = HoldStyle.largeButton,
    this.vibrateOnRelease = true,
    this.soundOnRelease = false,
    this.blackScreenMode = false,
  });

  /// Deserializes a `HoldButtonConfig` from JSON.
  factory HoldButtonConfig.fromJson(Map<String, Object?> json) =>
      HoldButtonConfig(
        releaseSensitivity:
            (json['releaseSensitivity'] as num?)?.toDouble() ?? 1.0,
        holdStyle: _holdStyleFromJson(json['holdStyle']),
        vibrateOnRelease: json['vibrateOnRelease'] as bool? ?? true,
        soundOnRelease: json['soundOnRelease'] as bool? ?? false,
        blackScreenMode: json['blackScreenMode'] as bool? ?? false,
      );

  /// Seconds the engine waits after a release to confirm the user
  /// actually let go. Defaults to 1.0 per spec.
  final double releaseSensitivity;

  /// Visual press-surface style. Defaults to [HoldStyle.largeButton].
  final HoldStyle holdStyle;

  /// Whether to vibrate on release. Defaults to true.
  final bool vibrateOnRelease;

  /// Whether to play a sound on release. Defaults to false.
  final bool soundOnRelease;

  /// Whether the step renders on a black screen. Defaults to false.
  final bool blackScreenMode;

  /// Returns a new config with the given fields replaced.
  HoldButtonConfig copyWith({
    double? releaseSensitivity,
    HoldStyle? holdStyle,
    bool? vibrateOnRelease,
    bool? soundOnRelease,
    bool? blackScreenMode,
  }) => HoldButtonConfig(
    releaseSensitivity: releaseSensitivity ?? this.releaseSensitivity,
    holdStyle: holdStyle ?? this.holdStyle,
    vibrateOnRelease: vibrateOnRelease ?? this.vibrateOnRelease,
    soundOnRelease: soundOnRelease ?? this.soundOnRelease,
    blackScreenMode: blackScreenMode ?? this.blackScreenMode,
  );

  @override
  Map<String, Object?> toJson() => {
    'type': 'holdButton',
    'releaseSensitivity': releaseSensitivity,
    'holdStyle': holdStyle.name,
    'vibrateOnRelease': vibrateOnRelease,
    'soundOnRelease': soundOnRelease,
    'blackScreenMode': blackScreenMode,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HoldButtonConfig &&
          other.releaseSensitivity == releaseSensitivity &&
          other.holdStyle == holdStyle &&
          other.vibrateOnRelease == vibrateOnRelease &&
          other.soundOnRelease == soundOnRelease &&
          other.blackScreenMode == blackScreenMode;

  @override
  int get hashCode => Object.hash(
    releaseSensitivity,
    holdStyle,
    vibrateOnRelease,
    soundOnRelease,
    blackScreenMode,
  );

  @override
  String toString() =>
      'HoldButtonConfig(releaseSensitivity: $releaseSensitivity, '
      'holdStyle: $holdStyle, '
      'vibrateOnRelease: $vibrateOnRelease, '
      'soundOnRelease: $soundOnRelease, '
      'blackScreenMode: $blackScreenMode)';
}

HoldStyle _holdStyleFromJson(Object? raw) => switch (raw) {
  'largeButton' => HoldStyle.largeButton,
  'fullScreen' => HoldStyle.fullScreen,
  'fakeLockScreen' => HoldStyle.fakeLockScreen,
  null => HoldStyle.largeButton,
  _ => throw ArgumentError.value(raw, 'holdStyle', 'unknown HoldStyle'),
};

/// Configuration for a `disguisedReminder` step.
///
/// Spec 02 §2.disguisedReminder + spec 03 §DisguisedReminderConfig.
/// Interval between reminders is encoded on [ChainStep.waitSeconds];
/// this config retains [templateId] for per-step template selection
/// and [intervalSeconds] for legacy per-config override.
final class DisguisedReminderConfig extends StepConfig {
  /// Creates a disguised-reminder config.
  ///
  /// [templateId] — id of the `ReminderTemplate` to display. `null`
  /// means "pick one of the effective templates at runtime".
  /// [intervalSeconds] — per-config interval override (seconds).
  /// Defaults to 60. Prefer [ChainStep.waitSeconds] where possible.
  /// [randomizeInterval] — jitter the interval; defaults to false.
  /// [randomizeTemplateOrder] — shuffle effective templates on each
  /// fire; defaults to false.
  /// [resetOnEarlyCheckIn] — treat an early check-in as resetting
  /// the current retry cycle; defaults to true per D-UX-4.
  /// [blackScreenMode] — render the notification on a black overlay;
  /// defaults to false.
  const DisguisedReminderConfig({
    this.templateId,
    this.intervalSeconds = 60,
    this.randomizeInterval = false,
    this.randomizeTemplateOrder = false,
    this.resetOnEarlyCheckIn = true,
    this.blackScreenMode = false,
  });

  /// Deserializes a `DisguisedReminderConfig` from JSON.
  factory DisguisedReminderConfig.fromJson(Map<String, Object?> json) =>
      DisguisedReminderConfig(
        templateId: json['templateId'] as String?,
        intervalSeconds:
            (json['intervalSeconds'] as num?)?.toInt() ?? 60,
        randomizeInterval: json['randomizeInterval'] as bool? ?? false,
        randomizeTemplateOrder:
            json['randomizeTemplateOrder'] as bool? ?? false,
        resetOnEarlyCheckIn:
            json['resetOnEarlyCheckIn'] as bool? ?? true,
        blackScreenMode: json['blackScreenMode'] as bool? ?? false,
      );

  /// Optional id of a specific `ReminderTemplate` to fire for this
  /// step. Defaults to null (engine picks from effective templates).
  final String? templateId;

  /// Seconds between consecutive reminders. Defaults to 60.
  final int intervalSeconds;

  /// Whether to jitter the interval. Defaults to false.
  final bool randomizeInterval;

  /// Whether to shuffle effective templates on each fire. Defaults
  /// to false.
  final bool randomizeTemplateOrder;

  /// Whether an early check-in resets the current retry cycle.
  /// Defaults to true per D-UX-4.
  final bool resetOnEarlyCheckIn;

  /// Whether the reminder renders on a black overlay. Defaults to
  /// false.
  final bool blackScreenMode;

  /// Returns a new config with the given fields replaced.
  DisguisedReminderConfig copyWith({
    String? templateId,
    int? intervalSeconds,
    bool? randomizeInterval,
    bool? randomizeTemplateOrder,
    bool? resetOnEarlyCheckIn,
    bool? blackScreenMode,
  }) => DisguisedReminderConfig(
    templateId: templateId ?? this.templateId,
    intervalSeconds: intervalSeconds ?? this.intervalSeconds,
    randomizeInterval: randomizeInterval ?? this.randomizeInterval,
    randomizeTemplateOrder:
        randomizeTemplateOrder ?? this.randomizeTemplateOrder,
    resetOnEarlyCheckIn:
        resetOnEarlyCheckIn ?? this.resetOnEarlyCheckIn,
    blackScreenMode: blackScreenMode ?? this.blackScreenMode,
  );

  @override
  Map<String, Object?> toJson() => {
    'type': 'disguisedReminder',
    'templateId': templateId,
    'intervalSeconds': intervalSeconds,
    'randomizeInterval': randomizeInterval,
    'randomizeTemplateOrder': randomizeTemplateOrder,
    'resetOnEarlyCheckIn': resetOnEarlyCheckIn,
    'blackScreenMode': blackScreenMode,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DisguisedReminderConfig &&
          other.templateId == templateId &&
          other.intervalSeconds == intervalSeconds &&
          other.randomizeInterval == randomizeInterval &&
          other.randomizeTemplateOrder == randomizeTemplateOrder &&
          other.resetOnEarlyCheckIn == resetOnEarlyCheckIn &&
          other.blackScreenMode == blackScreenMode;

  @override
  int get hashCode => Object.hash(
    templateId,
    intervalSeconds,
    randomizeInterval,
    randomizeTemplateOrder,
    resetOnEarlyCheckIn,
    blackScreenMode,
  );

  @override
  String toString() =>
      'DisguisedReminderConfig(templateId: $templateId, '
      'intervalSeconds: $intervalSeconds, '
      'randomizeInterval: $randomizeInterval, '
      'randomizeTemplateOrder: $randomizeTemplateOrder, '
      'resetOnEarlyCheckIn: $resetOnEarlyCheckIn, '
      'blackScreenMode: $blackScreenMode)';
}

/// Configuration for a `hardwareButton` step (and companion for
/// `HardwareButtonDistressTrigger`).
final class HardwareButtonConfig extends StepConfig {
  /// Creates a hardware-button config.
  ///
  /// [buttonType] — which physical button; defaults to volumeUp.
  /// [pattern] — repeat-press or long-press; defaults to repeatPress.
  /// [pressCount] — required repeat-press count; defaults to 5.
  /// [pressWindowMs] — window for repeat presses; defaults to 500.
  /// [longPressDurationSeconds] — threshold for long-press pattern;
  /// defaults to 2.0.
  const HardwareButtonConfig({
    this.buttonType = ButtonType.volumeUp,
    this.pattern = HardwarePattern.repeatPress,
    this.pressCount = 5,
    this.pressWindowMs = 500,
    this.longPressDurationSeconds = 2.0,
  });

  /// Deserializes a `HardwareButtonConfig` from JSON.
  factory HardwareButtonConfig.fromJson(Map<String, Object?> json) =>
      HardwareButtonConfig(
        buttonType: _buttonTypeFromJson(json['buttonType']),
        pattern: _patternFromJson(json['pattern']),
        pressCount: (json['pressCount'] as num?)?.toInt() ?? 5,
        pressWindowMs: (json['pressWindowMs'] as num?)?.toInt() ?? 500,
        longPressDurationSeconds:
            (json['longPressDurationSeconds'] as num?)?.toDouble() ?? 2.0,
      );

  /// The physical button to watch. Defaults to `ButtonType.volumeUp`.
  final ButtonType buttonType;

  /// The required press pattern. Defaults to
  /// `HardwarePattern.repeatPress`.
  final HardwarePattern pattern;

  /// Number of presses for repeat-press pattern. Defaults to 5.
  final int pressCount;

  /// Time window in milliseconds for repeat-press pattern. Defaults
  /// to 500.
  final int pressWindowMs;

  /// Long-press duration threshold in seconds. Defaults to 2.0.
  final double longPressDurationSeconds;

  /// Returns a new config with the given fields replaced.
  HardwareButtonConfig copyWith({
    ButtonType? buttonType,
    HardwarePattern? pattern,
    int? pressCount,
    int? pressWindowMs,
    double? longPressDurationSeconds,
  }) => HardwareButtonConfig(
    buttonType: buttonType ?? this.buttonType,
    pattern: pattern ?? this.pattern,
    pressCount: pressCount ?? this.pressCount,
    pressWindowMs: pressWindowMs ?? this.pressWindowMs,
    longPressDurationSeconds:
        longPressDurationSeconds ?? this.longPressDurationSeconds,
  );

  @override
  Map<String, Object?> toJson() => {
    'type': 'hardwareButton',
    'buttonType': buttonType.name,
    'pattern': pattern.name,
    'pressCount': pressCount,
    'pressWindowMs': pressWindowMs,
    'longPressDurationSeconds': longPressDurationSeconds,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HardwareButtonConfig &&
          other.buttonType == buttonType &&
          other.pattern == pattern &&
          other.pressCount == pressCount &&
          other.pressWindowMs == pressWindowMs &&
          other.longPressDurationSeconds == longPressDurationSeconds;

  @override
  int get hashCode => Object.hash(
    buttonType,
    pattern,
    pressCount,
    pressWindowMs,
    longPressDurationSeconds,
  );

  @override
  String toString() =>
      'HardwareButtonConfig(buttonType: $buttonType, '
      'pattern: $pattern, pressCount: $pressCount, '
      'pressWindowMs: $pressWindowMs, '
      'longPressDurationSeconds: $longPressDurationSeconds)';
}

ButtonType _buttonTypeFromJson(Object? raw) => switch (raw) {
  'volumeUp' => ButtonType.volumeUp,
  'volumeDown' => ButtonType.volumeDown,
  'power' => ButtonType.power,
  null => ButtonType.volumeUp,
  _ => throw ArgumentError.value(raw, 'buttonType', 'unknown ButtonType'),
};

HardwarePattern _patternFromJson(Object? raw) => switch (raw) {
  'repeatPress' => HardwarePattern.repeatPress,
  'longPress' => HardwarePattern.longPress,
  null => HardwarePattern.repeatPress,
  _ => throw ArgumentError.value(raw, 'pattern', 'unknown HardwarePattern'),
};

/// Configuration for a `countdownWarning` step.
final class CountdownWarningConfig extends StepConfig {
  /// Creates a countdown-warning config.
  ///
  /// [vibrate] — buzz during the countdown; defaults to true.
  /// [playTone] — play a warning tone; defaults to false.
  const CountdownWarningConfig({this.vibrate = true, this.playTone = false});

  /// Deserializes a `CountdownWarningConfig` from JSON.
  factory CountdownWarningConfig.fromJson(Map<String, Object?> json) =>
      CountdownWarningConfig(
        vibrate: json['vibrate'] as bool? ?? true,
        playTone: json['playTone'] as bool? ?? false,
      );

  /// Whether to vibrate during the countdown. Defaults to true.
  final bool vibrate;

  /// Whether to play a warning tone during the countdown. Defaults
  /// to false.
  final bool playTone;

  /// Returns a new config with the given fields replaced.
  CountdownWarningConfig copyWith({bool? vibrate, bool? playTone}) =>
      CountdownWarningConfig(
        vibrate: vibrate ?? this.vibrate,
        playTone: playTone ?? this.playTone,
      );

  @override
  Map<String, Object?> toJson() => {
    'type': 'countdownWarning',
    'vibrate': vibrate,
    'playTone': playTone,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountdownWarningConfig &&
          other.vibrate == vibrate &&
          other.playTone == playTone;

  @override
  int get hashCode => Object.hash(vibrate, playTone);

  @override
  String toString() =>
      'CountdownWarningConfig(vibrate: $vibrate, playTone: $playTone)';
}

/// Visual style for a `FakeCallConfig` step.
///
/// Spec 03 §FakeCallConfig.
enum CallStyle {
  /// Standard phone-call UI.
  standard,

  /// Video-call UI (camera-style full-screen).
  videoCall,

  /// Simple ring-only (no UI, just ringtone).
  ring,
}

/// Voice output behavior when the user answers a fake call.
///
/// Spec 03 §FakeCallConfig.
enum VoiceOutputMode {
  /// Speak a dynamic TTS phrase.
  tts,

  /// Play a pre-recorded audio asset.
  recording,

  /// Silent — ring only.
  none,
}

/// Configuration for a `fakeCall` step.
///
/// Spec 03 §FakeCallConfig + spec 02 §5.fakeCall. Retry count lives
/// on [ChainStep.retryCount]; this config covers ONLY fake-call
/// presentation details.
final class FakeCallConfig extends StepConfig {
  /// Creates a fake-call config.
  ///
  /// [callerName] — displayed caller name; defaults to "Angela"
  /// (Guardian Angela product brand + "Ask for Angela" campaign).
  /// [ringtoneAsset] — optional asset path for the ringtone.
  /// [voiceRecordingAsset] — optional asset path for the voice
  /// recording played on answer.
  /// [declineIsSafe] — whether declining counts as disarm; defaults
  /// to TRUE per D-SAFETY-7 (minimize false positives).
  /// [callStyle] — visual style; defaults to [CallStyle.standard].
  /// [callerPhotoPath] — optional asset path for the caller photo.
  /// [voiceOutputMode] — voice behavior on answer; defaults to
  /// [VoiceOutputMode.tts].
  /// [ringDurationSeconds] — how long the ringtone plays; defaults
  /// to 30.
  /// [declineWithDistressHoldSeconds] — holding the decline button N
  /// seconds fires distress chain; defaults to 2.0.
  /// [blackScreenMode] — renders UI under a black overlay;
  /// defaults to false.
  const FakeCallConfig({
    this.callerName = 'Angela',
    this.ringtoneAsset,
    this.voiceRecordingAsset,
    this.declineIsSafe = true,
    this.callStyle = CallStyle.standard,
    this.callerPhotoPath,
    this.voiceOutputMode = VoiceOutputMode.tts,
    this.ringDurationSeconds = 30,
    this.declineWithDistressHoldSeconds = 2.0,
    this.blackScreenMode = false,
  });

  /// Deserializes a `FakeCallConfig` from JSON.
  ///
  /// `callerName` supports explicit `null` round-trip: when the key
  /// is present in JSON, the value is passed through as-is. When the
  /// key is missing, the constructor default ('Angela') applies.
  factory FakeCallConfig.fromJson(Map<String, Object?> json) => FakeCallConfig(
    callerName: json.containsKey('callerName')
        ? json['callerName'] as String?
        : 'Angela',
    ringtoneAsset: json['ringtoneAsset'] as String?,
    voiceRecordingAsset: json['voiceRecordingAsset'] as String?,
    declineIsSafe: json['declineIsSafe'] as bool? ?? true,
    callStyle: _callStyleFromJson(json['callStyle']),
    callerPhotoPath: json['callerPhotoPath'] as String?,
    voiceOutputMode: _voiceOutputModeFromJson(json['voiceOutputMode']),
    ringDurationSeconds:
        (json['ringDurationSeconds'] as num?)?.toInt() ?? 30,
    declineWithDistressHoldSeconds:
        (json['declineWithDistressHoldSeconds'] as num?)?.toDouble() ??
        2.0,
    blackScreenMode: json['blackScreenMode'] as bool? ?? false,
  );

  /// Name shown as the incoming caller. Defaults to "Angela". May be
  /// null if explicitly cleared; UI layers are expected to fall back
  /// to "Angela" via `callerName ?? 'Angela'`.
  final String? callerName;

  /// Optional asset path for a custom ringtone. Defaults to null.
  final String? ringtoneAsset;

  /// Optional asset path for the voice recording played after answer.
  /// Defaults to null.
  final String? voiceRecordingAsset;

  /// Whether the user declining the call counts as a successful
  /// disarm. Defaults to true per D-SAFETY-7.
  final bool declineIsSafe;

  /// Visual presentation style. Defaults to [CallStyle.standard].
  final CallStyle callStyle;

  /// Optional asset path for the caller photo. Defaults to null.
  final String? callerPhotoPath;

  /// Voice output behavior on answer. Defaults to
  /// [VoiceOutputMode.tts].
  final VoiceOutputMode voiceOutputMode;

  /// How long the ringtone plays, in seconds. Defaults to 30.
  final int ringDurationSeconds;

  /// Hold the decline button this many seconds to silently trigger
  /// the distress chain. Defaults to 2.0.
  final double declineWithDistressHoldSeconds;

  /// Render the fake-call UI beneath a black overlay (stealth
  /// surface). Defaults to false.
  final bool blackScreenMode;

  /// Returns a new config with the given fields replaced.
  FakeCallConfig copyWith({
    String? callerName,
    bool clearCallerName = false,
    String? ringtoneAsset,
    String? voiceRecordingAsset,
    bool? declineIsSafe,
    CallStyle? callStyle,
    String? callerPhotoPath,
    bool clearCallerPhotoPath = false,
    VoiceOutputMode? voiceOutputMode,
    int? ringDurationSeconds,
    double? declineWithDistressHoldSeconds,
    bool? blackScreenMode,
  }) => FakeCallConfig(
    callerName: clearCallerName ? null : (callerName ?? this.callerName),
    ringtoneAsset: ringtoneAsset ?? this.ringtoneAsset,
    voiceRecordingAsset: voiceRecordingAsset ?? this.voiceRecordingAsset,
    declineIsSafe: declineIsSafe ?? this.declineIsSafe,
    callStyle: callStyle ?? this.callStyle,
    callerPhotoPath: clearCallerPhotoPath
        ? null
        : (callerPhotoPath ?? this.callerPhotoPath),
    voiceOutputMode: voiceOutputMode ?? this.voiceOutputMode,
    ringDurationSeconds: ringDurationSeconds ?? this.ringDurationSeconds,
    declineWithDistressHoldSeconds:
        declineWithDistressHoldSeconds ??
        this.declineWithDistressHoldSeconds,
    blackScreenMode: blackScreenMode ?? this.blackScreenMode,
  );

  @override
  Map<String, Object?> toJson() => {
    'type': 'fakeCall',
    'callerName': callerName,
    'ringtoneAsset': ringtoneAsset,
    'voiceRecordingAsset': voiceRecordingAsset,
    'declineIsSafe': declineIsSafe,
    'callStyle': callStyle.name,
    'callerPhotoPath': callerPhotoPath,
    'voiceOutputMode': voiceOutputMode.name,
    'ringDurationSeconds': ringDurationSeconds,
    'declineWithDistressHoldSeconds': declineWithDistressHoldSeconds,
    'blackScreenMode': blackScreenMode,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FakeCallConfig &&
          other.callerName == callerName &&
          other.ringtoneAsset == ringtoneAsset &&
          other.voiceRecordingAsset == voiceRecordingAsset &&
          other.declineIsSafe == declineIsSafe &&
          other.callStyle == callStyle &&
          other.callerPhotoPath == callerPhotoPath &&
          other.voiceOutputMode == voiceOutputMode &&
          other.ringDurationSeconds == ringDurationSeconds &&
          other.declineWithDistressHoldSeconds ==
              declineWithDistressHoldSeconds &&
          other.blackScreenMode == blackScreenMode;

  @override
  int get hashCode => Object.hash(
    callerName,
    ringtoneAsset,
    voiceRecordingAsset,
    declineIsSafe,
    callStyle,
    callerPhotoPath,
    voiceOutputMode,
    ringDurationSeconds,
    declineWithDistressHoldSeconds,
    blackScreenMode,
  );

  @override
  String toString() =>
      'FakeCallConfig(callerName: $callerName, '
      'ringtoneAsset: $ringtoneAsset, '
      'voiceRecordingAsset: $voiceRecordingAsset, '
      'declineIsSafe: $declineIsSafe, callStyle: $callStyle, '
      'voiceOutputMode: $voiceOutputMode, '
      'ringDurationSeconds: $ringDurationSeconds, '
      'blackScreenMode: $blackScreenMode)';
}

CallStyle _callStyleFromJson(Object? raw) => switch (raw) {
  'standard' => CallStyle.standard,
  'videoCall' => CallStyle.videoCall,
  'ring' => CallStyle.ring,
  null => CallStyle.standard,
  _ => throw ArgumentError.value(raw, 'callStyle', 'unknown CallStyle'),
};

VoiceOutputMode _voiceOutputModeFromJson(Object? raw) => switch (raw) {
  'tts' => VoiceOutputMode.tts,
  'recording' => VoiceOutputMode.recording,
  'none' => VoiceOutputMode.none,
  null => VoiceOutputMode.tts,
  _ => throw ArgumentError.value(
    raw,
    'voiceOutputMode',
    'unknown VoiceOutputMode',
  ),
};

/// Configuration for an `smsContact` step.
final class SmsContactConfig extends StepConfig {
  /// Creates an SMS-contact config.
  ///
  /// [contactIds] — contacts targeted when [contactSelection] is
  /// `specificIds`; meaningless otherwise.
  /// [contactSelection] — how contacts are chosen; defaults to
  /// allContacts.
  /// [channel] — which messaging channel to use; defaults to sms.
  /// [includeLocation] — append location to the message; defaults
  /// to true.
  /// [includeMedicalInfo] — append medical profile; defaults to
  /// false.
  /// [autoRecordAudio] — start background audio capture; defaults
  /// to false.
  /// [autoRecordVideo] — start background video capture; defaults
  /// to false.
  /// [recordDurationSeconds] — how long to record; defaults to 15.
  /// [messageTemplate] — optional custom message template.
  /// [blackScreenMode] — render the step on a black screen; defaults
  /// to false.
  const SmsContactConfig({
    this.contactIds,
    this.contactSelection = SmsContactSelection.allContacts,
    this.channel = MessageChannel.sms,
    this.includeLocation = true,
    this.includeMedicalInfo = false,
    this.autoRecordAudio = false,
    this.autoRecordVideo = false,
    this.recordDurationSeconds = 15,
    this.messageTemplate,
    this.blackScreenMode = false,
  });

  /// Deserializes an `SmsContactConfig` from JSON.
  factory SmsContactConfig.fromJson(Map<String, Object?> json) {
    final rawIds = json['contactIds'];
    return SmsContactConfig(
      contactIds: rawIds is List
          ? rawIds.map((e) => e as String).toList(growable: false)
          : null,
      contactSelection: _smsContactSelectionFromJson(json['contactSelection']),
      channel: _messageChannelFromJson(json['channel']),
      includeLocation: json['includeLocation'] as bool? ?? true,
      includeMedicalInfo: json['includeMedicalInfo'] as bool? ?? false,
      autoRecordAudio: json['autoRecordAudio'] as bool? ?? false,
      autoRecordVideo: json['autoRecordVideo'] as bool? ?? false,
      recordDurationSeconds:
          (json['recordDurationSeconds'] as num?)?.toInt() ?? 15,
      messageTemplate: json['messageTemplate'] as String?,
      blackScreenMode: json['blackScreenMode'] as bool? ?? false,
    );
  }

  /// Specific contact ids; meaningful only when [contactSelection]
  /// is `specificIds`. Defaults to null.
  final List<String>? contactIds;

  /// How contacts are selected. Defaults to
  /// `SmsContactSelection.allContacts`.
  final SmsContactSelection contactSelection;

  /// The single messaging channel this step uses. Defaults to
  /// `MessageChannel.sms`.
  final MessageChannel channel;

  /// Whether to append current location. Defaults to true.
  final bool includeLocation;

  /// Whether to append the user's medical profile. Defaults to false.
  final bool includeMedicalInfo;

  /// Whether to start background audio recording alongside the send.
  /// Defaults to false.
  final bool autoRecordAudio;

  /// Whether to start background video recording alongside the send.
  /// Defaults to false.
  final bool autoRecordVideo;

  /// Recording duration in seconds when audio/video is auto-recorded.
  /// Defaults to 15.
  final int recordDurationSeconds;

  /// Optional per-step message template; null = use global template.
  final String? messageTemplate;

  /// Whether the step renders on a black screen (stealth). Defaults
  /// to false.
  final bool blackScreenMode;

  /// Returns a new config with the given fields replaced.
  ///
  /// Fix for bugs.json historical Warn (copy-with clear patterns):
  /// pass `clearContactIds: true` to explicitly set `contactIds` to
  /// `null`. This makes "omit the argument" and "clear the list"
  /// distinguishable.
  SmsContactConfig copyWith({
    List<String>? contactIds,
    bool clearContactIds = false,
    SmsContactSelection? contactSelection,
    MessageChannel? channel,
    bool? includeLocation,
    bool? includeMedicalInfo,
    bool? autoRecordAudio,
    bool? autoRecordVideo,
    int? recordDurationSeconds,
    String? messageTemplate,
    bool? blackScreenMode,
  }) => SmsContactConfig(
    contactIds: clearContactIds ? null : (contactIds ?? this.contactIds),
    contactSelection: contactSelection ?? this.contactSelection,
    channel: channel ?? this.channel,
    includeLocation: includeLocation ?? this.includeLocation,
    includeMedicalInfo: includeMedicalInfo ?? this.includeMedicalInfo,
    autoRecordAudio: autoRecordAudio ?? this.autoRecordAudio,
    autoRecordVideo: autoRecordVideo ?? this.autoRecordVideo,
    recordDurationSeconds: recordDurationSeconds ?? this.recordDurationSeconds,
    messageTemplate: messageTemplate ?? this.messageTemplate,
    blackScreenMode: blackScreenMode ?? this.blackScreenMode,
  );

  @override
  Map<String, Object?> toJson() => {
    'type': 'smsContact',
    'contactIds': contactIds,
    'contactSelection': contactSelection.name,
    'channel': channel.name,
    'includeLocation': includeLocation,
    'includeMedicalInfo': includeMedicalInfo,
    'autoRecordAudio': autoRecordAudio,
    'autoRecordVideo': autoRecordVideo,
    'recordDurationSeconds': recordDurationSeconds,
    'messageTemplate': messageTemplate,
    'blackScreenMode': blackScreenMode,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SmsContactConfig &&
        _listEquals(other.contactIds, contactIds) &&
        other.contactSelection == contactSelection &&
        other.channel == channel &&
        other.includeLocation == includeLocation &&
        other.includeMedicalInfo == includeMedicalInfo &&
        other.autoRecordAudio == autoRecordAudio &&
        other.autoRecordVideo == autoRecordVideo &&
        other.recordDurationSeconds == recordDurationSeconds &&
        other.messageTemplate == messageTemplate &&
        other.blackScreenMode == blackScreenMode;
  }

  @override
  int get hashCode => Object.hash(
    contactIds == null ? null : Object.hashAll(contactIds!),
    contactSelection,
    channel,
    includeLocation,
    includeMedicalInfo,
    autoRecordAudio,
    autoRecordVideo,
    recordDurationSeconds,
    messageTemplate,
    blackScreenMode,
  );

  @override
  String toString() =>
      'SmsContactConfig(contactIds: $contactIds, '
      'contactSelection: $contactSelection, channel: $channel, '
      'includeLocation: $includeLocation, '
      'includeMedicalInfo: $includeMedicalInfo)';
}

SmsContactSelection _smsContactSelectionFromJson(Object? raw) => switch (raw) {
  'allContacts' => SmsContactSelection.allContacts,
  'firstContact' => SmsContactSelection.firstContact,
  'specificIds' => SmsContactSelection.specificIds,
  null => SmsContactSelection.allContacts,
  _ => throw ArgumentError.value(
    raw,
    'contactSelection',
    'unknown SmsContactSelection',
  ),
};

MessageChannel _messageChannelFromJson(Object? raw) => switch (raw) {
  'sms' => MessageChannel.sms,
  'whatsapp' => MessageChannel.whatsapp,
  'telegram' => MessageChannel.telegram,
  'phoneCall' => MessageChannel.phoneCall,
  null => MessageChannel.sms,
  _ => throw ArgumentError.value(raw, 'channel', 'unknown MessageChannel'),
};

/// Configuration for a `phoneCallContact` step.
final class PhoneCallContactConfig extends StepConfig {
  /// Creates a phone-call-contact config.
  ///
  /// [contactId] — which contact to call; null = first-sorted.
  /// [alternativeContactIds] — fallbacks if primary fails; defaults
  /// to empty.
  /// [preSendSms] — send a warning SMS before calling; defaults to
  /// false.
  /// [preSmsIncludeLocation] — include location in the pre-SMS;
  /// defaults to true.
  /// [preSmsMessage] — optional custom pre-SMS message.
  const PhoneCallContactConfig({
    this.contactId,
    this.alternativeContactIds = const [],
    this.preSendSms = false,
    this.preSmsIncludeLocation = true,
    this.preSmsMessage,
  });

  /// Deserializes a `PhoneCallContactConfig` from JSON.
  factory PhoneCallContactConfig.fromJson(Map<String, Object?> json) {
    final raw = json['alternativeContactIds'];
    return PhoneCallContactConfig(
      contactId: json['contactId'] as String?,
      alternativeContactIds: raw is List
          ? List<String>.unmodifiable(raw.map((e) => e as String))
          : const [],
      preSendSms: json['preSendSms'] as bool? ?? false,
      preSmsIncludeLocation: json['preSmsIncludeLocation'] as bool? ?? true,
      preSmsMessage: json['preSmsMessage'] as String?,
    );
  }

  /// Primary contact id. Null means "first-sorted contact".
  final String? contactId;

  /// Fallback contact ids tried in order if the primary fails.
  /// Defaults to the empty list.
  final List<String> alternativeContactIds;

  /// Whether to send an SMS just before dialing. Defaults to false.
  final bool preSendSms;

  /// Whether to attach location to the pre-call SMS. Defaults to
  /// true.
  final bool preSmsIncludeLocation;

  /// Optional custom pre-SMS body. Defaults to null.
  final String? preSmsMessage;

  /// Returns a new config with the given fields replaced.
  PhoneCallContactConfig copyWith({
    String? contactId,
    List<String>? alternativeContactIds,
    bool? preSendSms,
    bool? preSmsIncludeLocation,
    String? preSmsMessage,
  }) => PhoneCallContactConfig(
    contactId: contactId ?? this.contactId,
    alternativeContactIds: alternativeContactIds ?? this.alternativeContactIds,
    preSendSms: preSendSms ?? this.preSendSms,
    preSmsIncludeLocation: preSmsIncludeLocation ?? this.preSmsIncludeLocation,
    preSmsMessage: preSmsMessage ?? this.preSmsMessage,
  );

  @override
  Map<String, Object?> toJson() => {
    'type': 'phoneCallContact',
    'contactId': contactId,
    'alternativeContactIds': alternativeContactIds,
    'preSendSms': preSendSms,
    'preSmsIncludeLocation': preSmsIncludeLocation,
    'preSmsMessage': preSmsMessage,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhoneCallContactConfig &&
        other.contactId == contactId &&
        _listEquals(other.alternativeContactIds, alternativeContactIds) &&
        other.preSendSms == preSendSms &&
        other.preSmsIncludeLocation == preSmsIncludeLocation &&
        other.preSmsMessage == preSmsMessage;
  }

  @override
  int get hashCode => Object.hash(
    contactId,
    Object.hashAll(alternativeContactIds),
    preSendSms,
    preSmsIncludeLocation,
    preSmsMessage,
  );

  @override
  String toString() =>
      'PhoneCallContactConfig(contactId: $contactId, '
      'alternativeContactIds: $alternativeContactIds, '
      'preSendSms: $preSendSms)';
}

/// Sound choice for a `LoudAlarmConfig` step.
///
/// Spec 02 §8.loudAlarm Config Keys.
enum LoudAlarmSound {
  /// Continuous siren (default).
  siren,

  /// Two-tone whoop.
  whoop,

  /// Ringing bell.
  bell,

  /// User-supplied asset.
  custom,
}

/// Configuration for a `loudAlarm` step.
///
/// Spec 02 §8.loudAlarm + spec 03 §LoudAlarmConfig.
final class LoudAlarmConfig extends StepConfig {
  /// Creates a loud-alarm config.
  ///
  /// [flashScreen] — strobe the screen; defaults to false per spec.
  /// [flashSpeed] — seconds per flash cycle; defaults to 0.5
  /// (legacy; superseded by [flashSpeedMs]).
  /// [maxVolume] — legacy boolean toggle; retained for backward
  /// compatibility with existing editors; defaults to true.
  /// [volume] — 0.0..1.0 linear volume. Defaults to 1.0.
  /// [soundChoice] — alarm sound; defaults to [LoudAlarmSound.siren].
  /// [gradualVolume] — ramp volume from 0 to [volume]; defaults to
  /// false.
  /// [flashLight] — strobe the camera flashlight; defaults to true.
  /// [flashSpeedMs] — flash cycle length in milliseconds; defaults
  /// to 500.
  /// [blackScreenMode] — render behind a black overlay; defaults to
  /// false.
  const LoudAlarmConfig({
    this.flashScreen = false,
    this.flashSpeed = 0.5,
    this.maxVolume = true,
    this.volume = 1.0,
    this.soundChoice = LoudAlarmSound.siren,
    this.gradualVolume = false,
    this.flashLight = true,
    this.flashSpeedMs = 500,
    this.blackScreenMode = false,
  });

  /// Deserializes a `LoudAlarmConfig` from JSON.
  factory LoudAlarmConfig.fromJson(Map<String, Object?> json) =>
      LoudAlarmConfig(
        flashScreen: json['flashScreen'] as bool? ?? false,
        flashSpeed: (json['flashSpeed'] as num?)?.toDouble() ?? 0.5,
        maxVolume: json['maxVolume'] as bool? ?? true,
        volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
        soundChoice: _loudAlarmSoundFromJson(json['soundChoice']),
        gradualVolume: json['gradualVolume'] as bool? ?? false,
        flashLight: json['flashLight'] as bool? ?? true,
        flashSpeedMs: (json['flashSpeedMs'] as num?)?.toInt() ?? 500,
        blackScreenMode: json['blackScreenMode'] as bool? ?? false,
      );

  /// Whether the screen strobes during the alarm. Defaults to false
  /// per spec.
  final bool flashScreen;

  /// Seconds per flash cycle (on + off). Retained for legacy
  /// editors; prefer [flashSpeedMs]. Defaults to 0.5.
  final double flashSpeed;

  /// Whether to force the system media volume to max. Retained for
  /// legacy editors; new code should use [volume] + [gradualVolume].
  final bool maxVolume;

  /// Linear volume 0.0..1.0. Defaults to 1.0.
  final double volume;

  /// Alarm sound selection. Defaults to [LoudAlarmSound.siren].
  final LoudAlarmSound soundChoice;

  /// Whether to ramp volume from silence to [volume]. Defaults to
  /// false.
  final bool gradualVolume;

  /// Whether to strobe the camera flashlight. Defaults to true.
  final bool flashLight;

  /// Flash cycle length in milliseconds. Defaults to 500.
  final int flashSpeedMs;

  /// Render under a black overlay (stealth alarm). Defaults to false.
  final bool blackScreenMode;

  /// Returns a new config with the given fields replaced.
  LoudAlarmConfig copyWith({
    bool? flashScreen,
    double? flashSpeed,
    bool? maxVolume,
    double? volume,
    LoudAlarmSound? soundChoice,
    bool? gradualVolume,
    bool? flashLight,
    int? flashSpeedMs,
    bool? blackScreenMode,
  }) => LoudAlarmConfig(
    flashScreen: flashScreen ?? this.flashScreen,
    flashSpeed: flashSpeed ?? this.flashSpeed,
    maxVolume: maxVolume ?? this.maxVolume,
    volume: volume ?? this.volume,
    soundChoice: soundChoice ?? this.soundChoice,
    gradualVolume: gradualVolume ?? this.gradualVolume,
    flashLight: flashLight ?? this.flashLight,
    flashSpeedMs: flashSpeedMs ?? this.flashSpeedMs,
    blackScreenMode: blackScreenMode ?? this.blackScreenMode,
  );

  @override
  Map<String, Object?> toJson() => {
    'type': 'loudAlarm',
    'flashScreen': flashScreen,
    'flashSpeed': flashSpeed,
    'maxVolume': maxVolume,
    'volume': volume,
    'soundChoice': soundChoice.name,
    'gradualVolume': gradualVolume,
    'flashLight': flashLight,
    'flashSpeedMs': flashSpeedMs,
    'blackScreenMode': blackScreenMode,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoudAlarmConfig &&
          other.flashScreen == flashScreen &&
          other.flashSpeed == flashSpeed &&
          other.maxVolume == maxVolume &&
          other.volume == volume &&
          other.soundChoice == soundChoice &&
          other.gradualVolume == gradualVolume &&
          other.flashLight == flashLight &&
          other.flashSpeedMs == flashSpeedMs &&
          other.blackScreenMode == blackScreenMode;

  @override
  int get hashCode => Object.hash(
    flashScreen,
    flashSpeed,
    maxVolume,
    volume,
    soundChoice,
    gradualVolume,
    flashLight,
    flashSpeedMs,
    blackScreenMode,
  );

  @override
  String toString() =>
      'LoudAlarmConfig(flashScreen: $flashScreen, '
      'flashSpeed: $flashSpeed, maxVolume: $maxVolume, '
      'volume: $volume, soundChoice: $soundChoice, '
      'flashLight: $flashLight, flashSpeedMs: $flashSpeedMs, '
      'blackScreenMode: $blackScreenMode)';
}

LoudAlarmSound _loudAlarmSoundFromJson(Object? raw) => switch (raw) {
  'siren' => LoudAlarmSound.siren,
  'whoop' => LoudAlarmSound.whoop,
  'bell' => LoudAlarmSound.bell,
  'custom' => LoudAlarmSound.custom,
  null => LoudAlarmSound.siren,
  _ => throw ArgumentError.value(
    raw,
    'soundChoice',
    'unknown LoudAlarmSound',
  ),
};

/// Configuration for a `callEmergency` step.
///
/// Spec 02 §9.callEmergency + spec 03 §CallEmergencyConfig;
/// D-UX-8 (swipe-slider confirmation).
///
/// Pre-alpha break-compat: renamed `confirmBeforeCalling`
/// → `showConfirmation` with default `true`.
final class CallEmergencyConfig extends StepConfig {
  /// Creates a call-emergency config.
  ///
  /// [emergencyNumber] — per-step override of the global emergency
  /// number; null = inherit.
  /// [showConfirmation] — render the swipe-to-confirm slider before
  /// dialing; defaults to true per D-UX-8.
  /// [sendLocationSmsFirst] — send a location SMS to contacts before
  /// calling emergency services; defaults to true.
  /// [confirmationDurationSeconds] — seconds the confirmation remains
  /// on screen before auto-advancing; defaults to 5.
  /// [blackScreenMode] — render under a black overlay; defaults to
  /// false.
  const CallEmergencyConfig({
    this.emergencyNumber,
    this.showConfirmation = true,
    this.sendLocationSmsFirst = true,
    this.confirmationDurationSeconds = 5,
    this.blackScreenMode = false,
  });

  /// Deserializes a `CallEmergencyConfig` from JSON.
  factory CallEmergencyConfig.fromJson(Map<String, Object?> json) =>
      CallEmergencyConfig(
        emergencyNumber: json['emergencyNumber'] as String?,
        showConfirmation:
            json['showConfirmation'] as bool? ?? true,
        sendLocationSmsFirst:
            json['sendLocationSmsFirst'] as bool? ?? true,
        confirmationDurationSeconds:
            (json['confirmationDurationSeconds'] as num?)?.toInt() ?? 5,
        blackScreenMode: json['blackScreenMode'] as bool? ?? false,
      );

  /// Per-step override of the global emergency number. Defaults to
  /// null (inherit `AppSettings.emergencyCallNumber`).
  final String? emergencyNumber;

  /// Whether to render the swipe-to-confirm slider before dialing.
  /// Defaults to true per D-UX-8.
  final bool showConfirmation;

  /// Whether to send a location SMS to contacts before calling
  /// emergency services. Defaults to true.
  final bool sendLocationSmsFirst;

  /// Seconds the confirmation remains on screen before auto-advance.
  /// Defaults to 5.
  final int confirmationDurationSeconds;

  /// Whether the step renders under a black overlay. Defaults to
  /// false.
  final bool blackScreenMode;

  /// Returns a new config with the given fields replaced.
  ///
  /// Pass `clearEmergencyNumber: true` to explicitly set
  /// `emergencyNumber` to `null`.
  CallEmergencyConfig copyWith({
    String? emergencyNumber,
    bool clearEmergencyNumber = false,
    bool? showConfirmation,
    bool? sendLocationSmsFirst,
    int? confirmationDurationSeconds,
    bool? blackScreenMode,
  }) => CallEmergencyConfig(
    emergencyNumber: clearEmergencyNumber
        ? null
        : (emergencyNumber ?? this.emergencyNumber),
    showConfirmation: showConfirmation ?? this.showConfirmation,
    sendLocationSmsFirst:
        sendLocationSmsFirst ?? this.sendLocationSmsFirst,
    confirmationDurationSeconds:
        confirmationDurationSeconds ?? this.confirmationDurationSeconds,
    blackScreenMode: blackScreenMode ?? this.blackScreenMode,
  );

  @override
  Map<String, Object?> toJson() => {
    'type': 'callEmergency',
    'emergencyNumber': emergencyNumber,
    'showConfirmation': showConfirmation,
    'sendLocationSmsFirst': sendLocationSmsFirst,
    'confirmationDurationSeconds': confirmationDurationSeconds,
    'blackScreenMode': blackScreenMode,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallEmergencyConfig &&
          other.emergencyNumber == emergencyNumber &&
          other.showConfirmation == showConfirmation &&
          other.sendLocationSmsFirst == sendLocationSmsFirst &&
          other.confirmationDurationSeconds ==
              confirmationDurationSeconds &&
          other.blackScreenMode == blackScreenMode;

  @override
  int get hashCode => Object.hash(
    emergencyNumber,
    showConfirmation,
    sendLocationSmsFirst,
    confirmationDurationSeconds,
    blackScreenMode,
  );

  @override
  String toString() =>
      'CallEmergencyConfig(emergencyNumber: $emergencyNumber, '
      'showConfirmation: $showConfirmation, '
      'sendLocationSmsFirst: $sendLocationSmsFirst, '
      'confirmationDurationSeconds: $confirmationDurationSeconds, '
      'blackScreenMode: $blackScreenMode)';
}

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
