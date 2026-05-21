import 'package:guardianangela/domain/enums/button_type.dart';
import 'package:guardianangela/domain/enums/call_style.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/countdown_style.dart';
import 'package:guardianangela/domain/enums/hold_style.dart';
import 'package:guardianangela/domain/enums/log_gps_override.dart';
import 'package:guardianangela/domain/enums/loud_alarm_sound.dart';
import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/enums/press_pattern.dart';
import 'package:guardianangela/domain/enums/sms_contact_selection.dart';
import 'package:guardianangela/domain/enums/voice_output_mode.dart';

/// Per-step typed configuration sealed class hierarchy.
///
/// Provides compile-time type safety, IDE autocomplete, and constructor
/// validation for each [ChainStepType]. When a [ChainStep.config] is null,
/// the engine falls back to [EventDefaults.forType]. See spec 03
/// §StepConfig.
///
/// All subclasses must implement [toJson] and the dispatcher
/// [fromJson(ChainStepType, Map)] selects the correct subclass.
sealed class StepConfig {
  /// Constant constructor for subclasses.
  const StepConfig();

  /// Whether the session screen shows a black screen mimicking a locked
  /// phone during this step.
  bool get blackScreenMode;

  /// Serialises this config to a JSON map.
  Map<String, dynamic> toJson();

  /// Deserialises a [StepConfig] subclass from [json] using [type] as the
  /// discriminator to select the correct subclass.
  factory StepConfig.fromJson(ChainStepType type, Map<String, dynamic> json) =>
      switch (type) {
        ChainStepType.holdButton => HoldButtonConfig.fromJson(json),
        ChainStepType.disguisedReminder => DisguisedReminderConfig.fromJson(
          json,
        ),
        ChainStepType.countdownWarning => CountdownWarningConfig.fromJson(json),
        ChainStepType.fakeCall => FakeCallConfig.fromJson(json),
        ChainStepType.smsContact => SmsContactConfig.fromJson(json),
        ChainStepType.phoneCallContact => PhoneCallContactConfig.fromJson(json),
        ChainStepType.loudAlarm => LoudAlarmConfig.fromJson(json),
        ChainStepType.callEmergency => CallEmergencyConfig.fromJson(json),
        ChainStepType.hardwareButton => HardwareButtonConfig.fromJson(json),
      };
}

// ─── HoldButtonConfig ─────────────────────────────────────────────────────

/// Configuration for a [ChainStepType.holdButton] step.
final class HoldButtonConfig extends StepConfig {
  /// Creates a hold-button config with the given values.
  ///
  /// Defaults: [holdStyle] = [HoldStyle.largeButton],
  /// [releaseSensitivity] = 1.0, [vibrateOnRelease] = true,
  /// [soundOnRelease] = false, [blackScreenMode] = false.
  const HoldButtonConfig({
    this.holdStyle = HoldStyle.largeButton,
    this.releaseSensitivity = 1.0,
    this.vibrateOnRelease = true,
    this.soundOnRelease = false,
    this.blackScreenMode = false,
  });

  /// Deserialises from a JSON map produced by [toJson].
  factory HoldButtonConfig.fromJson(Map<String, dynamic> json) =>
      HoldButtonConfig(
        holdStyle: HoldStyle.values.byName(
          (json['holdStyle'] as String?) ?? HoldStyle.largeButton.name,
        ),
        releaseSensitivity:
            (json['releaseSensitivity'] as num?)?.toDouble() ?? 1.0,
        vibrateOnRelease: (json['vibrateOnRelease'] as bool?) ?? true,
        soundOnRelease: (json['soundOnRelease'] as bool?) ?? false,
        blackScreenMode: (json['blackScreenMode'] as bool?) ?? false,
      );

  /// Visual presentation of the hold target.
  final HoldStyle holdStyle;

  /// Sensitivity multiplier for accidental-release detection (0.3–3.0).
  ///
  /// Lower values are more forgiving of brief releases.
  final double releaseSensitivity;

  /// Whether to vibrate when the user releases the hold button.
  final bool vibrateOnRelease;

  /// Whether to play an audio cue when the user releases the hold button.
  final bool soundOnRelease;

  @override
  final bool blackScreenMode;

  /// Returns a copy with the specified fields replaced.
  HoldButtonConfig copyWith({
    HoldStyle? holdStyle,
    double? releaseSensitivity,
    bool? vibrateOnRelease,
    bool? soundOnRelease,
    bool? blackScreenMode,
  }) => HoldButtonConfig(
    holdStyle: holdStyle ?? this.holdStyle,
    releaseSensitivity: releaseSensitivity ?? this.releaseSensitivity,
    vibrateOnRelease: vibrateOnRelease ?? this.vibrateOnRelease,
    soundOnRelease: soundOnRelease ?? this.soundOnRelease,
    blackScreenMode: blackScreenMode ?? this.blackScreenMode,
  );

  @override
  Map<String, dynamic> toJson() => {
    'holdStyle': holdStyle.name,
    'releaseSensitivity': releaseSensitivity,
    'vibrateOnRelease': vibrateOnRelease,
    'soundOnRelease': soundOnRelease,
    'blackScreenMode': blackScreenMode,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HoldButtonConfig &&
          holdStyle == other.holdStyle &&
          releaseSensitivity == other.releaseSensitivity &&
          vibrateOnRelease == other.vibrateOnRelease &&
          soundOnRelease == other.soundOnRelease &&
          blackScreenMode == other.blackScreenMode);

  @override
  int get hashCode => Object.hash(
    holdStyle,
    releaseSensitivity,
    vibrateOnRelease,
    soundOnRelease,
    blackScreenMode,
  );
}

// ─── DisguisedReminderConfig ───────────────────────────────────────────────

/// Configuration for a [ChainStepType.disguisedReminder] step.
final class DisguisedReminderConfig extends StepConfig {
  /// Creates a disguised-reminder config with the given values.
  ///
  /// Defaults: [randomizeInterval] = true, [randomizeTemplateOrder] = true,
  /// [resetOnEarlyCheckIn] = true, [blackScreenMode] = false.
  const DisguisedReminderConfig({
    this.randomizeInterval = true,
    this.randomizeTemplateOrder = true,
    this.resetOnEarlyCheckIn = true,
    this.blackScreenMode = false,
  });

  /// Deserialises from a JSON map produced by [toJson].
  factory DisguisedReminderConfig.fromJson(Map<String, dynamic> json) =>
      DisguisedReminderConfig(
        randomizeInterval: (json['randomizeInterval'] as bool?) ?? true,
        randomizeTemplateOrder:
            (json['randomizeTemplateOrder'] as bool?) ?? true,
        resetOnEarlyCheckIn: (json['resetOnEarlyCheckIn'] as bool?) ?? true,
        blackScreenMode: (json['blackScreenMode'] as bool?) ?? false,
      );

  /// Whether to apply ±20% jitter to the reminder interval.
  final bool randomizeInterval;

  /// Whether to randomize which template is shown each time.
  final bool randomizeTemplateOrder;

  /// Whether an early check-in resets the timer to the full interval (D4).
  final bool resetOnEarlyCheckIn;

  @override
  final bool blackScreenMode;

  /// Returns a copy with the specified fields replaced.
  DisguisedReminderConfig copyWith({
    bool? randomizeInterval,
    bool? randomizeTemplateOrder,
    bool? resetOnEarlyCheckIn,
    bool? blackScreenMode,
  }) => DisguisedReminderConfig(
    randomizeInterval: randomizeInterval ?? this.randomizeInterval,
    randomizeTemplateOrder:
        randomizeTemplateOrder ?? this.randomizeTemplateOrder,
    resetOnEarlyCheckIn: resetOnEarlyCheckIn ?? this.resetOnEarlyCheckIn,
    blackScreenMode: blackScreenMode ?? this.blackScreenMode,
  );

  @override
  Map<String, dynamic> toJson() => {
    'randomizeInterval': randomizeInterval,
    'randomizeTemplateOrder': randomizeTemplateOrder,
    'resetOnEarlyCheckIn': resetOnEarlyCheckIn,
    'blackScreenMode': blackScreenMode,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DisguisedReminderConfig &&
          randomizeInterval == other.randomizeInterval &&
          randomizeTemplateOrder == other.randomizeTemplateOrder &&
          resetOnEarlyCheckIn == other.resetOnEarlyCheckIn &&
          blackScreenMode == other.blackScreenMode);

  @override
  int get hashCode => Object.hash(
    randomizeInterval,
    randomizeTemplateOrder,
    resetOnEarlyCheckIn,
    blackScreenMode,
  );
}

// ─── CountdownWarningConfig ────────────────────────────────────────────────

/// Configuration for a [ChainStepType.countdownWarning] step.
final class CountdownWarningConfig extends StepConfig {
  /// Creates a countdown-warning config with the given values.
  ///
  /// Defaults: [style] = [CountdownStyle.fullScreen], [vibrate] = true,
  /// [sound] = false, [blackScreenMode] = false.
  const CountdownWarningConfig({
    this.style = CountdownStyle.fullScreen,
    this.vibrate = true,
    this.sound = false,
    this.blackScreenMode = false,
  });

  /// Deserialises from a JSON map produced by [toJson].
  factory CountdownWarningConfig.fromJson(Map<String, dynamic> json) =>
      CountdownWarningConfig(
        style: CountdownStyle.values.byName(
          (json['style'] as String?) ?? CountdownStyle.fullScreen.name,
        ),
        vibrate: (json['vibrate'] as bool?) ?? true,
        sound: (json['sound'] as bool?) ?? false,
        blackScreenMode: (json['blackScreenMode'] as bool?) ?? false,
      );

  /// How the countdown is presented visually.
  final CountdownStyle style;

  /// Whether the device vibrates during the countdown.
  final bool vibrate;

  /// Whether an audio alert plays during the countdown.
  final bool sound;

  @override
  final bool blackScreenMode;

  /// Returns a copy with the specified fields replaced.
  CountdownWarningConfig copyWith({
    CountdownStyle? style,
    bool? vibrate,
    bool? sound,
    bool? blackScreenMode,
  }) => CountdownWarningConfig(
    style: style ?? this.style,
    vibrate: vibrate ?? this.vibrate,
    sound: sound ?? this.sound,
    blackScreenMode: blackScreenMode ?? this.blackScreenMode,
  );

  @override
  Map<String, dynamic> toJson() => {
    'style': style.name,
    'vibrate': vibrate,
    'sound': sound,
    'blackScreenMode': blackScreenMode,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CountdownWarningConfig &&
          style == other.style &&
          vibrate == other.vibrate &&
          sound == other.sound &&
          blackScreenMode == other.blackScreenMode);

  @override
  int get hashCode => Object.hash(style, vibrate, sound, blackScreenMode);
}

// ─── FakeCallConfig ────────────────────────────────────────────────────────

/// Configuration for a [ChainStepType.fakeCall] step.
final class FakeCallConfig extends StepConfig {
  /// Creates a fake-call config with the given values.
  ///
  /// Defaults: [callStyle] = [CallStyle.androidNative],
  /// [callerName] = 'Angela', [voiceOutputMode] = [VoiceOutputMode.earpiece],
  /// [ringDurationSeconds] = 30, [declineIsSafe] = true,
  /// [declineWithDistressHoldSeconds] = 5, [blackScreenMode] = false.
  const FakeCallConfig({
    this.callStyle = CallStyle.androidNative,
    this.callerName = 'Angela',
    this.callerPhotoPath,
    this.voiceRecordingPath,
    this.voiceOutputMode = VoiceOutputMode.earpiece,
    this.ringDurationSeconds = 30,
    this.declineIsSafe = true,
    this.declineWithDistressHoldSeconds = 5,
    this.blackScreenMode = false,
  });

  /// Deserialises from a JSON map produced by [toJson].
  factory FakeCallConfig.fromJson(Map<String, dynamic> json) => FakeCallConfig(
    callStyle: CallStyle.values.byName(
      (json['callStyle'] as String?) ?? CallStyle.androidNative.name,
    ),
    callerName: (json['callerName'] as String?) ?? 'Angela',
    callerPhotoPath: json['callerPhotoPath'] as String?,
    voiceRecordingPath: json['voiceRecordingPath'] as String?,
    voiceOutputMode: VoiceOutputMode.values.byName(
      (json['voiceOutputMode'] as String?) ?? VoiceOutputMode.earpiece.name,
    ),
    ringDurationSeconds: (json['ringDurationSeconds'] as num?)?.toInt() ?? 30,
    declineIsSafe: (json['declineIsSafe'] as bool?) ?? true,
    declineWithDistressHoldSeconds:
        (json['declineWithDistressHoldSeconds'] as num?)?.toInt() ?? 5,
    blackScreenMode: (json['blackScreenMode'] as bool?) ?? false,
  );

  /// Which platform call-sheet appearance the fake-call screen imitates.
  final CallStyle callStyle;

  /// The name shown as the caller.
  final String callerName;

  /// Optional path to a caller photo (app-internal or asset).
  final String? callerPhotoPath;

  /// Optional path to a voice recording played during the call.
  ///
  /// Null = use the built-in per-language recording (C2/32);
  /// max 2 minutes (spec 39).
  final String? voiceRecordingPath;

  /// Where the voice audio plays.
  final VoiceOutputMode voiceOutputMode;

  /// How long the phone rings before the call expires.
  ///
  /// Range: 5–120 seconds.
  final int ringDurationSeconds;

  /// Whether declining the call resets the chain to step 0 (A1).
  final bool declineIsSafe;

  /// Seconds the user must hold "Decline" to trigger the distress chain.
  final int declineWithDistressHoldSeconds;

  @override
  final bool blackScreenMode;

  /// Returns a copy with the specified fields replaced.
  FakeCallConfig copyWith({
    CallStyle? callStyle,
    String? callerName,
    String? callerPhotoPath,
    String? voiceRecordingPath,
    VoiceOutputMode? voiceOutputMode,
    int? ringDurationSeconds,
    bool? declineIsSafe,
    int? declineWithDistressHoldSeconds,
    bool? blackScreenMode,
  }) => FakeCallConfig(
    callStyle: callStyle ?? this.callStyle,
    callerName: callerName ?? this.callerName,
    callerPhotoPath: callerPhotoPath ?? this.callerPhotoPath,
    voiceRecordingPath: voiceRecordingPath ?? this.voiceRecordingPath,
    voiceOutputMode: voiceOutputMode ?? this.voiceOutputMode,
    ringDurationSeconds: ringDurationSeconds ?? this.ringDurationSeconds,
    declineIsSafe: declineIsSafe ?? this.declineIsSafe,
    declineWithDistressHoldSeconds:
        declineWithDistressHoldSeconds ?? this.declineWithDistressHoldSeconds,
    blackScreenMode: blackScreenMode ?? this.blackScreenMode,
  );

  @override
  Map<String, dynamic> toJson() => {
    'callStyle': callStyle.name,
    'callerName': callerName,
    if (callerPhotoPath != null) 'callerPhotoPath': callerPhotoPath,
    if (voiceRecordingPath != null) 'voiceRecordingPath': voiceRecordingPath,
    'voiceOutputMode': voiceOutputMode.name,
    'ringDurationSeconds': ringDurationSeconds,
    'declineIsSafe': declineIsSafe,
    'declineWithDistressHoldSeconds': declineWithDistressHoldSeconds,
    'blackScreenMode': blackScreenMode,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FakeCallConfig &&
          callStyle == other.callStyle &&
          callerName == other.callerName &&
          callerPhotoPath == other.callerPhotoPath &&
          voiceRecordingPath == other.voiceRecordingPath &&
          voiceOutputMode == other.voiceOutputMode &&
          ringDurationSeconds == other.ringDurationSeconds &&
          declineIsSafe == other.declineIsSafe &&
          declineWithDistressHoldSeconds ==
              other.declineWithDistressHoldSeconds &&
          blackScreenMode == other.blackScreenMode);

  @override
  int get hashCode => Object.hash(
    callStyle,
    callerName,
    callerPhotoPath,
    voiceRecordingPath,
    voiceOutputMode,
    ringDurationSeconds,
    declineIsSafe,
    declineWithDistressHoldSeconds,
    blackScreenMode,
  );
}

// ─── SmsContactConfig ─────────────────────────────────────────────────────

/// Configuration for a [ChainStepType.smsContact] step.
///
/// Each SMS/messaging step uses ONE [channel]. Contacts without the
/// selected channel are greyed out in the contact picker (spec 03
/// §SmsContactConfig, decision 15/15b).
final class SmsContactConfig extends StepConfig {
  /// Creates an SMS-contact config with the given values.
  ///
  /// Defaults: [contactSelection] = [SmsContactSelection.allContacts],
  /// [channel] = [MessageChannel.sms], [includeLocation] = true,
  /// [includeMedicalInfo] = false, [autoRecordAudio] = false,
  /// [autoRecordVideo] = false, [recordDurationSeconds] = 30,
  /// [blackScreenMode] = false.
  const SmsContactConfig({
    this.contactIds,
    this.contactSelection = SmsContactSelection.allContacts,
    this.channel = MessageChannel.sms,
    this.includeLocation = true,
    this.includeMedicalInfo = false,
    this.autoRecordAudio = false,
    this.autoRecordVideo = false,
    this.recordDurationSeconds = 30,
    this.messageTemplate,
    this.blackScreenMode = false,
  });

  /// Deserialises from a JSON map produced by [toJson].
  factory SmsContactConfig.fromJson(Map<String, dynamic> json) =>
      SmsContactConfig(
        contactIds: (json['contactIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        contactSelection: SmsContactSelection.values.byName(
          (json['contactSelection'] as String?) ??
              SmsContactSelection.allContacts.name,
        ),
        channel: MessageChannel.values.byName(
          (json['channel'] as String?) ?? MessageChannel.sms.name,
        ),
        includeLocation: (json['includeLocation'] as bool?) ?? true,
        includeMedicalInfo: (json['includeMedicalInfo'] as bool?) ?? false,
        autoRecordAudio: (json['autoRecordAudio'] as bool?) ?? false,
        autoRecordVideo: (json['autoRecordVideo'] as bool?) ?? false,
        recordDurationSeconds:
            (json['recordDurationSeconds'] as num?)?.toInt() ?? 30,
        messageTemplate: json['messageTemplate'] as String?,
        blackScreenMode: (json['blackScreenMode'] as bool?) ?? false,
      );

  /// Contact IDs targeted when [contactSelection] is
  /// [SmsContactSelection.specificIds].
  final List<String>? contactIds;

  /// Which contacts to message.
  final SmsContactSelection contactSelection;

  /// The single messaging channel used for this step.
  final MessageChannel channel;

  /// Whether to append the current GPS location to the message.
  final bool includeLocation;

  /// Whether to include the user's medical information in the message (C3).
  final bool includeMedicalInfo;

  /// Whether to automatically start an audio recording before sending.
  final bool autoRecordAudio;

  /// Whether to automatically start a video recording before sending.
  final bool autoRecordVideo;

  /// Duration of any automatic recording in seconds.
  final int recordDurationSeconds;

  /// Message template string. Null = use the seeded default template.
  final String? messageTemplate;

  @override
  final bool blackScreenMode;

  /// Returns a copy with the specified fields replaced.
  SmsContactConfig copyWith({
    List<String>? contactIds,
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
    contactIds: contactIds ?? this.contactIds,
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
  Map<String, dynamic> toJson() => {
    if (contactIds != null) 'contactIds': contactIds,
    'contactSelection': contactSelection.name,
    'channel': channel.name,
    'includeLocation': includeLocation,
    'includeMedicalInfo': includeMedicalInfo,
    'autoRecordAudio': autoRecordAudio,
    'autoRecordVideo': autoRecordVideo,
    'recordDurationSeconds': recordDurationSeconds,
    if (messageTemplate != null) 'messageTemplate': messageTemplate,
    'blackScreenMode': blackScreenMode,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! SmsContactConfig) {
      return false;
    }
    if (contactIds?.length != other.contactIds?.length) {
      return false;
    }
    if (contactIds != null && other.contactIds != null) {
      for (var i = 0; i < contactIds!.length; i++) {
        if (contactIds![i] != other.contactIds![i]) {
          return false;
        }
      }
    }
    return contactSelection == other.contactSelection &&
        channel == other.channel &&
        includeLocation == other.includeLocation &&
        includeMedicalInfo == other.includeMedicalInfo &&
        autoRecordAudio == other.autoRecordAudio &&
        autoRecordVideo == other.autoRecordVideo &&
        recordDurationSeconds == other.recordDurationSeconds &&
        messageTemplate == other.messageTemplate &&
        blackScreenMode == other.blackScreenMode;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(contactIds ?? const []),
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
}

// ─── PhoneCallContactConfig ────────────────────────────────────────────────

/// Configuration for a [ChainStepType.phoneCallContact] step.
final class PhoneCallContactConfig extends StepConfig {
  /// Creates a phone-call-contact config with the given values.
  ///
  /// Defaults: [contactId] = null (first-sorted contact),
  /// [alternativeContactIds] = empty, [logGps] = [LogGpsOverride.useDefault],
  /// [blackScreenMode] = false.
  const PhoneCallContactConfig({
    this.contactId,
    this.alternativeContactIds = const [],
    this.logGps = LogGpsOverride.useDefault,
    this.blackScreenMode = false,
  });

  /// Deserialises from a JSON map produced by [toJson].
  factory PhoneCallContactConfig.fromJson(Map<String, dynamic> json) =>
      PhoneCallContactConfig(
        contactId: json['contactId'] as String?,
        alternativeContactIds:
            (json['alternativeContactIds'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        logGps: LogGpsOverride.values.byName(
          (json['logGps'] as String?) ?? LogGpsOverride.useDefault.name,
        ),
        blackScreenMode: (json['blackScreenMode'] as bool?) ?? false,
      );

  /// ID of the primary contact to call. Null = first-sorted contact.
  final String? contactId;

  /// Alternative contacts tried in order if the primary is unreachable.
  final List<String> alternativeContactIds;

  /// Per-step GPS logging override.
  final LogGpsOverride logGps;

  @override
  final bool blackScreenMode;

  /// Returns a copy with the specified fields replaced.
  PhoneCallContactConfig copyWith({
    String? contactId,
    List<String>? alternativeContactIds,
    LogGpsOverride? logGps,
    bool? blackScreenMode,
  }) => PhoneCallContactConfig(
    contactId: contactId ?? this.contactId,
    alternativeContactIds: alternativeContactIds ?? this.alternativeContactIds,
    logGps: logGps ?? this.logGps,
    blackScreenMode: blackScreenMode ?? this.blackScreenMode,
  );

  @override
  Map<String, dynamic> toJson() => {
    if (contactId != null) 'contactId': contactId,
    'alternativeContactIds': alternativeContactIds,
    'logGps': logGps.name,
    'blackScreenMode': blackScreenMode,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! PhoneCallContactConfig) {
      return false;
    }
    if (alternativeContactIds.length != other.alternativeContactIds.length) {
      return false;
    }
    for (var i = 0; i < alternativeContactIds.length; i++) {
      if (alternativeContactIds[i] != other.alternativeContactIds[i]) {
        return false;
      }
    }
    return contactId == other.contactId &&
        logGps == other.logGps &&
        blackScreenMode == other.blackScreenMode;
  }

  @override
  int get hashCode => Object.hash(
    contactId,
    Object.hashAll(alternativeContactIds),
    logGps,
    blackScreenMode,
  );
}

// ─── LoudAlarmConfig ──────────────────────────────────────────────────────

/// Configuration for a [ChainStepType.loudAlarm] step.
final class LoudAlarmConfig extends StepConfig {
  /// Creates a loud-alarm config with the given values.
  ///
  /// Defaults: [flashScreen] = false, [flashSpeedMs] = 500,
  /// [volume] = 1.0, [soundChoice] = [LoudAlarmSound.siren],
  /// [gradualVolume] = false, [flashLight] = true,
  /// [blackScreenMode] = false, [logGps] = [LogGpsOverride.useDefault].
  const LoudAlarmConfig({
    this.flashScreen = false,
    this.flashSpeedMs = 500,
    this.volume = 1.0,
    this.soundChoice = LoudAlarmSound.siren,
    this.gradualVolume = false,
    this.flashLight = true,
    this.blackScreenMode = false,
    this.logGps = LogGpsOverride.useDefault,
  });

  /// Deserialises from a JSON map produced by [toJson].
  factory LoudAlarmConfig.fromJson(Map<String, dynamic> json) =>
      LoudAlarmConfig(
        flashScreen: (json['flashScreen'] as bool?) ?? false,
        flashSpeedMs: (json['flashSpeedMs'] as num?)?.toInt() ?? 500,
        volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
        soundChoice: LoudAlarmSound.values.byName(
          (json['soundChoice'] as String?) ?? LoudAlarmSound.siren.name,
        ),
        gradualVolume: (json['gradualVolume'] as bool?) ?? false,
        flashLight: (json['flashLight'] as bool?) ?? true,
        blackScreenMode: (json['blackScreenMode'] as bool?) ?? false,
        logGps: LogGpsOverride.values.byName(
          (json['logGps'] as String?) ?? LogGpsOverride.useDefault.name,
        ),
      );

  /// Whether the screen flashes during the alarm.
  ///
  /// Disabled by default due to photosensitivity concerns.
  final bool flashScreen;

  /// Flash cycle duration in milliseconds.
  ///
  /// Only relevant when [flashScreen] is true.
  final int flashSpeedMs;

  /// Alarm volume as a linear scale (0.0–1.0).
  final double volume;

  /// The sound played by the alarm.
  final LoudAlarmSound soundChoice;

  /// Whether to ramp volume from 0 → [volume] at the step start.
  final bool gradualVolume;

  /// Whether to strobe the device's camera flash.
  final bool flashLight;

  @override
  final bool blackScreenMode;

  /// Per-step GPS logging override.
  final LogGpsOverride logGps;

  /// Returns a copy with the specified fields replaced.
  LoudAlarmConfig copyWith({
    bool? flashScreen,
    int? flashSpeedMs,
    double? volume,
    LoudAlarmSound? soundChoice,
    bool? gradualVolume,
    bool? flashLight,
    bool? blackScreenMode,
    LogGpsOverride? logGps,
  }) => LoudAlarmConfig(
    flashScreen: flashScreen ?? this.flashScreen,
    flashSpeedMs: flashSpeedMs ?? this.flashSpeedMs,
    volume: volume ?? this.volume,
    soundChoice: soundChoice ?? this.soundChoice,
    gradualVolume: gradualVolume ?? this.gradualVolume,
    flashLight: flashLight ?? this.flashLight,
    blackScreenMode: blackScreenMode ?? this.blackScreenMode,
    logGps: logGps ?? this.logGps,
  );

  @override
  Map<String, dynamic> toJson() => {
    'flashScreen': flashScreen,
    'flashSpeedMs': flashSpeedMs,
    'volume': volume,
    'soundChoice': soundChoice.name,
    'gradualVolume': gradualVolume,
    'flashLight': flashLight,
    'blackScreenMode': blackScreenMode,
    'logGps': logGps.name,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoudAlarmConfig &&
          flashScreen == other.flashScreen &&
          flashSpeedMs == other.flashSpeedMs &&
          volume == other.volume &&
          soundChoice == other.soundChoice &&
          gradualVolume == other.gradualVolume &&
          flashLight == other.flashLight &&
          blackScreenMode == other.blackScreenMode &&
          logGps == other.logGps);

  @override
  int get hashCode => Object.hash(
    flashScreen,
    flashSpeedMs,
    volume,
    soundChoice,
    gradualVolume,
    flashLight,
    blackScreenMode,
    logGps,
  );
}

// ─── CallEmergencyConfig ──────────────────────────────────────────────────

/// Configuration for a [ChainStepType.callEmergency] step.
final class CallEmergencyConfig extends StepConfig {
  /// Creates a call-emergency config with the given values.
  ///
  /// Defaults: [emergencyNumber] = null (inherit app-wide number),
  /// [sendLocationSmsFirst] = true, [showConfirmation] = true,
  /// [confirmationDurationSeconds] = 5, [blackScreenMode] = false.
  const CallEmergencyConfig({
    this.emergencyNumber,
    this.sendLocationSmsFirst = true,
    this.showConfirmation = true,
    this.confirmationDurationSeconds = 5,
    this.blackScreenMode = false,
  });

  /// Deserialises from a JSON map produced by [toJson].
  factory CallEmergencyConfig.fromJson(Map<String, dynamic> json) =>
      CallEmergencyConfig(
        emergencyNumber: json['emergencyNumber'] as String?,
        sendLocationSmsFirst: (json['sendLocationSmsFirst'] as bool?) ?? true,
        showConfirmation: (json['showConfirmation'] as bool?) ?? true,
        confirmationDurationSeconds:
            (json['confirmationDurationSeconds'] as num?)?.toInt() ?? 5,
        blackScreenMode: (json['blackScreenMode'] as bool?) ?? false,
      );

  /// Per-step emergency number override.
  ///
  /// Null = inherit [AppSettings.emergencyCallNumber].
  final String? emergencyNumber;

  /// Whether to send a location SMS to emergency contacts before dialling.
  final bool sendLocationSmsFirst;

  /// Whether to show a confirmation countdown before dialling.
  final bool showConfirmation;

  /// Seconds for the confirmation countdown.
  final int confirmationDurationSeconds;

  @override
  final bool blackScreenMode;

  /// Returns a copy with the specified fields replaced.
  CallEmergencyConfig copyWith({
    String? emergencyNumber,
    bool? sendLocationSmsFirst,
    bool? showConfirmation,
    int? confirmationDurationSeconds,
    bool? blackScreenMode,
  }) => CallEmergencyConfig(
    emergencyNumber: emergencyNumber ?? this.emergencyNumber,
    sendLocationSmsFirst: sendLocationSmsFirst ?? this.sendLocationSmsFirst,
    showConfirmation: showConfirmation ?? this.showConfirmation,
    confirmationDurationSeconds:
        confirmationDurationSeconds ?? this.confirmationDurationSeconds,
    blackScreenMode: blackScreenMode ?? this.blackScreenMode,
  );

  @override
  Map<String, dynamic> toJson() => {
    if (emergencyNumber != null) 'emergencyNumber': emergencyNumber,
    'sendLocationSmsFirst': sendLocationSmsFirst,
    'showConfirmation': showConfirmation,
    'confirmationDurationSeconds': confirmationDurationSeconds,
    'blackScreenMode': blackScreenMode,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CallEmergencyConfig &&
          emergencyNumber == other.emergencyNumber &&
          sendLocationSmsFirst == other.sendLocationSmsFirst &&
          showConfirmation == other.showConfirmation &&
          confirmationDurationSeconds == other.confirmationDurationSeconds &&
          blackScreenMode == other.blackScreenMode);

  @override
  int get hashCode => Object.hash(
    emergencyNumber,
    sendLocationSmsFirst,
    showConfirmation,
    confirmationDurationSeconds,
    blackScreenMode,
  );
}

// ─── HardwareButtonConfig ─────────────────────────────────────────────────

/// Configuration for a [ChainStepType.hardwareButton] step.
///
/// Note: the hardware button can be configured as a step OR as a distress
/// trigger ([HardwareButtonDistressTrigger]), not both.
final class HardwareButtonConfig extends StepConfig {
  /// Creates a hardware-button config with the given values.
  ///
  /// Defaults: [buttonType] = [ButtonType.volumeUp],
  /// [pressPattern] = [PressPattern.repeatPress], [pressCount] = 5,
  /// [longPressDurationSeconds] = 2.0, [targetStepIndex] = -1 (next step),
  /// [blackScreenMode] = false.
  const HardwareButtonConfig({
    this.buttonType = ButtonType.volumeUp,
    this.pressPattern = PressPattern.repeatPress,
    this.pressCount = 5,
    this.longPressDurationSeconds = 2.0,
    this.targetStepIndex = -1,
    this.blackScreenMode = false,
  });

  /// Deserialises from a JSON map produced by [toJson].
  factory HardwareButtonConfig.fromJson(Map<String, dynamic> json) =>
      HardwareButtonConfig(
        buttonType: ButtonType.values.byName(
          (json['buttonType'] as String?) ?? ButtonType.volumeUp.name,
        ),
        pressPattern: PressPattern.values.byName(
          (json['pressPattern'] as String?) ?? PressPattern.repeatPress.name,
        ),
        pressCount: (json['pressCount'] as num?)?.toInt() ?? 5,
        longPressDurationSeconds:
            (json['longPressDurationSeconds'] as num?)?.toDouble() ?? 2.0,
        targetStepIndex: (json['targetStepIndex'] as num?)?.toInt() ?? -1,
        blackScreenMode: (json['blackScreenMode'] as bool?) ?? false,
      );

  /// Which button activates this step.
  final ButtonType buttonType;

  /// The required press pattern.
  final PressPattern pressPattern;

  /// Number of rapid presses required for [PressPattern.repeatPress].
  final int pressCount;

  /// Hold duration in seconds for [PressPattern.longPress].
  final double longPressDurationSeconds;

  /// Index of the chain step to jump to. -1 = advance to the next step.
  final int targetStepIndex;

  @override
  final bool blackScreenMode;

  /// Returns a copy with the specified fields replaced.
  HardwareButtonConfig copyWith({
    ButtonType? buttonType,
    PressPattern? pressPattern,
    int? pressCount,
    double? longPressDurationSeconds,
    int? targetStepIndex,
    bool? blackScreenMode,
  }) => HardwareButtonConfig(
    buttonType: buttonType ?? this.buttonType,
    pressPattern: pressPattern ?? this.pressPattern,
    pressCount: pressCount ?? this.pressCount,
    longPressDurationSeconds:
        longPressDurationSeconds ?? this.longPressDurationSeconds,
    targetStepIndex: targetStepIndex ?? this.targetStepIndex,
    blackScreenMode: blackScreenMode ?? this.blackScreenMode,
  );

  @override
  Map<String, dynamic> toJson() => {
    'buttonType': buttonType.name,
    'pressPattern': pressPattern.name,
    'pressCount': pressCount,
    'longPressDurationSeconds': longPressDurationSeconds,
    'targetStepIndex': targetStepIndex,
    'blackScreenMode': blackScreenMode,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HardwareButtonConfig &&
          buttonType == other.buttonType &&
          pressPattern == other.pressPattern &&
          pressCount == other.pressCount &&
          longPressDurationSeconds == other.longPressDurationSeconds &&
          targetStepIndex == other.targetStepIndex &&
          blackScreenMode == other.blackScreenMode);

  @override
  int get hashCode => Object.hash(
    buttonType,
    pressPattern,
    pressCount,
    longPressDurationSeconds,
    targetStepIndex,
    blackScreenMode,
  );
}
