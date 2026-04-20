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

/// Configuration for a `holdButton` step.
final class HoldButtonConfig extends StepConfig {
  /// Creates a hold-button config.
  ///
  /// [releaseSensitivity] — how forgiving the release-detection is
  /// in seconds. Defaults to 0.3.
  const HoldButtonConfig({this.releaseSensitivity = 0.3});

  /// Deserializes a `HoldButtonConfig` from JSON.
  factory HoldButtonConfig.fromJson(Map<String, Object?> json) =>
      HoldButtonConfig(
        releaseSensitivity:
            (json['releaseSensitivity'] as num?)?.toDouble() ?? 0.3,
      );

  /// Seconds the engine waits after a release to confirm the user
  /// actually let go (vs. micro-slip). Defaults to 0.3.
  final double releaseSensitivity;

  /// Returns a new config with the given fields replaced.
  HoldButtonConfig copyWith({double? releaseSensitivity}) => HoldButtonConfig(
    releaseSensitivity: releaseSensitivity ?? this.releaseSensitivity,
  );

  @override
  Map<String, Object?> toJson() => {
    'type': 'holdButton',
    'releaseSensitivity': releaseSensitivity,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HoldButtonConfig &&
          other.releaseSensitivity == releaseSensitivity;

  @override
  int get hashCode => releaseSensitivity.hashCode;

  @override
  String toString() =>
      'HoldButtonConfig(releaseSensitivity: $releaseSensitivity)';
}

/// Configuration for a `disguisedReminder` step.
final class DisguisedReminderConfig extends StepConfig {
  /// Creates a disguised-reminder config.
  ///
  /// [templateId] — id of the `ReminderTemplate` to display. `null`
  /// means "pick one of the effective templates at runtime".
  /// [intervalSeconds] — interval between reminders, in seconds.
  /// Defaults to 60.
  const DisguisedReminderConfig({this.templateId, this.intervalSeconds = 60});

  /// Deserializes a `DisguisedReminderConfig` from JSON.
  factory DisguisedReminderConfig.fromJson(Map<String, Object?> json) =>
      DisguisedReminderConfig(
        templateId: json['templateId'] as String?,
        intervalSeconds: (json['intervalSeconds'] as num?)?.toInt() ?? 60,
      );

  /// Optional id of a specific `ReminderTemplate` to fire for this
  /// step. Defaults to null (engine picks from effective templates).
  final String? templateId;

  /// Seconds between consecutive reminders. Defaults to 60.
  final int intervalSeconds;

  /// Returns a new config with the given fields replaced.
  DisguisedReminderConfig copyWith({
    String? templateId,
    int? intervalSeconds,
  }) => DisguisedReminderConfig(
    templateId: templateId ?? this.templateId,
    intervalSeconds: intervalSeconds ?? this.intervalSeconds,
  );

  @override
  Map<String, Object?> toJson() => {
    'type': 'disguisedReminder',
    'templateId': templateId,
    'intervalSeconds': intervalSeconds,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DisguisedReminderConfig &&
          other.templateId == templateId &&
          other.intervalSeconds == intervalSeconds;

  @override
  int get hashCode => Object.hash(templateId, intervalSeconds);

  @override
  String toString() =>
      'DisguisedReminderConfig(templateId: $templateId, '
      'intervalSeconds: $intervalSeconds)';
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

/// Configuration for a `fakeCall` step.
final class FakeCallConfig extends StepConfig {
  /// Creates a fake-call config.
  ///
  /// [callerName] — displayed caller name; defaults to "Mom".
  /// [ringtoneAsset] — optional asset path for the ringtone.
  /// [voiceRecordingAsset] — optional asset path for the voice
  /// recording played on answer.
  /// [declineIsSafe] — whether declining counts as disarm; defaults
  /// to false.
  /// [retryCount] — extra attempts after first ring; defaults to 0.
  const FakeCallConfig({
    this.callerName = 'Mom',
    this.ringtoneAsset,
    this.voiceRecordingAsset,
    this.declineIsSafe = false,
    this.retryCount = 0,
  });

  /// Deserializes a `FakeCallConfig` from JSON.
  factory FakeCallConfig.fromJson(Map<String, Object?> json) => FakeCallConfig(
    callerName: json['callerName'] as String? ?? 'Mom',
    ringtoneAsset: json['ringtoneAsset'] as String?,
    voiceRecordingAsset: json['voiceRecordingAsset'] as String?,
    declineIsSafe: json['declineIsSafe'] as bool? ?? false,
    retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
  );

  /// Name shown as the incoming caller. Defaults to "Mom". May be
  /// null if explicitly cleared.
  final String? callerName;

  /// Optional asset path for a custom ringtone. Defaults to null.
  final String? ringtoneAsset;

  /// Optional asset path for the voice recording played after answer.
  /// Defaults to null.
  final String? voiceRecordingAsset;

  /// Whether the user declining the call counts as a successful
  /// disarm. Defaults to false.
  final bool declineIsSafe;

  /// Number of retries after the initial ring. Defaults to 0.
  final int retryCount;

  /// Returns a new config with the given fields replaced.
  FakeCallConfig copyWith({
    String? callerName,
    String? ringtoneAsset,
    String? voiceRecordingAsset,
    bool? declineIsSafe,
    int? retryCount,
  }) => FakeCallConfig(
    callerName: callerName ?? this.callerName,
    ringtoneAsset: ringtoneAsset ?? this.ringtoneAsset,
    voiceRecordingAsset: voiceRecordingAsset ?? this.voiceRecordingAsset,
    declineIsSafe: declineIsSafe ?? this.declineIsSafe,
    retryCount: retryCount ?? this.retryCount,
  );

  @override
  Map<String, Object?> toJson() => {
    'type': 'fakeCall',
    'callerName': callerName,
    'ringtoneAsset': ringtoneAsset,
    'voiceRecordingAsset': voiceRecordingAsset,
    'declineIsSafe': declineIsSafe,
    'retryCount': retryCount,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FakeCallConfig &&
          other.callerName == callerName &&
          other.ringtoneAsset == ringtoneAsset &&
          other.voiceRecordingAsset == voiceRecordingAsset &&
          other.declineIsSafe == declineIsSafe &&
          other.retryCount == retryCount;

  @override
  int get hashCode => Object.hash(
    callerName,
    ringtoneAsset,
    voiceRecordingAsset,
    declineIsSafe,
    retryCount,
  );

  @override
  String toString() =>
      'FakeCallConfig(callerName: $callerName, '
      'ringtoneAsset: $ringtoneAsset, '
      'voiceRecordingAsset: $voiceRecordingAsset, '
      'declineIsSafe: $declineIsSafe, retryCount: $retryCount)';
}

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

/// Configuration for a `loudAlarm` step.
final class LoudAlarmConfig extends StepConfig {
  /// Creates a loud-alarm config.
  ///
  /// [flashScreen] — strobe the screen; defaults to true.
  /// [flashSpeed] — seconds per flash cycle; defaults to 0.5.
  /// [maxVolume] — ramp system media volume to max; defaults to
  /// true.
  const LoudAlarmConfig({
    this.flashScreen = true,
    this.flashSpeed = 0.5,
    this.maxVolume = true,
  });

  /// Deserializes a `LoudAlarmConfig` from JSON.
  factory LoudAlarmConfig.fromJson(Map<String, Object?> json) =>
      LoudAlarmConfig(
        flashScreen: json['flashScreen'] as bool? ?? true,
        flashSpeed: (json['flashSpeed'] as num?)?.toDouble() ?? 0.5,
        maxVolume: json['maxVolume'] as bool? ?? true,
      );

  /// Whether the screen strobes during the alarm. Defaults to true.
  final bool flashScreen;

  /// Seconds per flash cycle (on + off). Defaults to 0.5.
  final double flashSpeed;

  /// Whether to force the system media volume to max. Defaults to
  /// true.
  final bool maxVolume;

  /// Returns a new config with the given fields replaced.
  LoudAlarmConfig copyWith({
    bool? flashScreen,
    double? flashSpeed,
    bool? maxVolume,
  }) => LoudAlarmConfig(
    flashScreen: flashScreen ?? this.flashScreen,
    flashSpeed: flashSpeed ?? this.flashSpeed,
    maxVolume: maxVolume ?? this.maxVolume,
  );

  @override
  Map<String, Object?> toJson() => {
    'type': 'loudAlarm',
    'flashScreen': flashScreen,
    'flashSpeed': flashSpeed,
    'maxVolume': maxVolume,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoudAlarmConfig &&
          other.flashScreen == flashScreen &&
          other.flashSpeed == flashSpeed &&
          other.maxVolume == maxVolume;

  @override
  int get hashCode => Object.hash(flashScreen, flashSpeed, maxVolume);

  @override
  String toString() =>
      'LoudAlarmConfig(flashScreen: $flashScreen, '
      'flashSpeed: $flashSpeed, maxVolume: $maxVolume)';
}

/// Configuration for a `callEmergency` step.
final class CallEmergencyConfig extends StepConfig {
  /// Creates a call-emergency config.
  ///
  /// [emergencyNumber] — per-step override of the global emergency
  /// number; null = inherit.
  /// [confirmBeforeCalling] — show a confirmation dialog first;
  /// defaults to false.
  const CallEmergencyConfig({
    this.emergencyNumber,
    this.confirmBeforeCalling = false,
  });

  /// Deserializes a `CallEmergencyConfig` from JSON.
  factory CallEmergencyConfig.fromJson(Map<String, Object?> json) =>
      CallEmergencyConfig(
        emergencyNumber: json['emergencyNumber'] as String?,
        confirmBeforeCalling: json['confirmBeforeCalling'] as bool? ?? false,
      );

  /// Per-step override of the global emergency number. Defaults to
  /// null (inherit `AppSettings.emergencyCallNumber`).
  final String? emergencyNumber;

  /// Whether to show a confirmation dialog before dialing. Defaults
  /// to false.
  final bool confirmBeforeCalling;

  /// Returns a new config with the given fields replaced.
  CallEmergencyConfig copyWith({
    String? emergencyNumber,
    bool? confirmBeforeCalling,
  }) => CallEmergencyConfig(
    emergencyNumber: emergencyNumber ?? this.emergencyNumber,
    confirmBeforeCalling: confirmBeforeCalling ?? this.confirmBeforeCalling,
  );

  @override
  Map<String, Object?> toJson() => {
    'type': 'callEmergency',
    'emergencyNumber': emergencyNumber,
    'confirmBeforeCalling': confirmBeforeCalling,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallEmergencyConfig &&
          other.emergencyNumber == emergencyNumber &&
          other.confirmBeforeCalling == confirmBeforeCalling;

  @override
  int get hashCode => Object.hash(emergencyNumber, confirmBeforeCalling);

  @override
  String toString() =>
      'CallEmergencyConfig(emergencyNumber: $emergencyNumber, '
      'confirmBeforeCalling: $confirmBeforeCalling)';
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
