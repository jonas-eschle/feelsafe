/// `EventDefaults` — one typed `StepConfig` per `ChainStepType`.
///
/// When a `ChainStep.config` is null, the engine uses
/// `EventDefaults.forType(step.type)` instead.
library;

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/step_config.dart';

/// Per-step-type configuration defaults.
final class EventDefaults {
  /// Creates event defaults.
  ///
  /// Every argument has a `const` default constructed from the
  /// matching `StepConfig` subclass.
  /// [holdButton] — default for `holdButton` steps.
  /// [disguisedReminder] — default for `disguisedReminder` steps.
  /// [hardwareButton] — default for `hardwareButton` steps.
  /// [countdownWarning] — default for `countdownWarning` steps.
  /// [fakeCall] — default for `fakeCall` steps.
  /// [smsContact] — default for `smsContact` steps.
  /// [phoneCallContact] — default for `phoneCallContact` steps.
  /// [loudAlarm] — default for `loudAlarm` steps.
  /// [callEmergency] — default for `callEmergency` steps.
  const EventDefaults({
    this.holdButton = const HoldButtonConfig(),
    this.disguisedReminder = const DisguisedReminderConfig(),
    this.hardwareButton = const HardwareButtonConfig(),
    this.countdownWarning = const CountdownWarningConfig(),
    this.fakeCall = const FakeCallConfig(),
    this.smsContact = const SmsContactConfig(),
    this.phoneCallContact = const PhoneCallContactConfig(),
    this.loudAlarm = const LoudAlarmConfig(),
    this.callEmergency = const CallEmergencyConfig(),
  });

  /// Deserializes `EventDefaults` from JSON.
  factory EventDefaults.fromJson(Map<String, Object?> json) => EventDefaults(
    holdButton: _field(
      json,
      'holdButton',
      HoldButtonConfig.fromJson,
      const HoldButtonConfig(),
    ),
    disguisedReminder: _field(
      json,
      'disguisedReminder',
      DisguisedReminderConfig.fromJson,
      const DisguisedReminderConfig(),
    ),
    hardwareButton: _field(
      json,
      'hardwareButton',
      HardwareButtonConfig.fromJson,
      const HardwareButtonConfig(),
    ),
    countdownWarning: _field(
      json,
      'countdownWarning',
      CountdownWarningConfig.fromJson,
      const CountdownWarningConfig(),
    ),
    fakeCall: _field(
      json,
      'fakeCall',
      FakeCallConfig.fromJson,
      const FakeCallConfig(),
    ),
    smsContact: _field(
      json,
      'smsContact',
      SmsContactConfig.fromJson,
      const SmsContactConfig(),
    ),
    phoneCallContact: _field(
      json,
      'phoneCallContact',
      PhoneCallContactConfig.fromJson,
      const PhoneCallContactConfig(),
    ),
    loudAlarm: _field(
      json,
      'loudAlarm',
      LoudAlarmConfig.fromJson,
      const LoudAlarmConfig(),
    ),
    callEmergency: _field(
      json,
      'callEmergency',
      CallEmergencyConfig.fromJson,
      const CallEmergencyConfig(),
    ),
  );

  /// Default for `holdButton` steps.
  final HoldButtonConfig holdButton;

  /// Default for `disguisedReminder` steps.
  final DisguisedReminderConfig disguisedReminder;

  /// Default for `hardwareButton` steps.
  final HardwareButtonConfig hardwareButton;

  /// Default for `countdownWarning` steps.
  final CountdownWarningConfig countdownWarning;

  /// Default for `fakeCall` steps.
  final FakeCallConfig fakeCall;

  /// Default for `smsContact` steps.
  final SmsContactConfig smsContact;

  /// Default for `phoneCallContact` steps.
  final PhoneCallContactConfig phoneCallContact;

  /// Default for `loudAlarm` steps.
  final LoudAlarmConfig loudAlarm;

  /// Default for `callEmergency` steps.
  final CallEmergencyConfig callEmergency;

  /// Returns the default config for [type].
  StepConfig forType(ChainStepType type) => switch (type) {
    ChainStepType.holdButton => holdButton,
    ChainStepType.disguisedReminder => disguisedReminder,
    ChainStepType.hardwareButton => hardwareButton,
    ChainStepType.countdownWarning => countdownWarning,
    ChainStepType.fakeCall => fakeCall,
    ChainStepType.smsContact => smsContact,
    ChainStepType.phoneCallContact => phoneCallContact,
    ChainStepType.loudAlarm => loudAlarm,
    ChainStepType.callEmergency => callEmergency,
  };

  /// Returns a new `EventDefaults` with the given fields replaced.
  EventDefaults copyWith({
    HoldButtonConfig? holdButton,
    DisguisedReminderConfig? disguisedReminder,
    HardwareButtonConfig? hardwareButton,
    CountdownWarningConfig? countdownWarning,
    FakeCallConfig? fakeCall,
    SmsContactConfig? smsContact,
    PhoneCallContactConfig? phoneCallContact,
    LoudAlarmConfig? loudAlarm,
    CallEmergencyConfig? callEmergency,
  }) => EventDefaults(
    holdButton: holdButton ?? this.holdButton,
    disguisedReminder: disguisedReminder ?? this.disguisedReminder,
    hardwareButton: hardwareButton ?? this.hardwareButton,
    countdownWarning: countdownWarning ?? this.countdownWarning,
    fakeCall: fakeCall ?? this.fakeCall,
    smsContact: smsContact ?? this.smsContact,
    phoneCallContact: phoneCallContact ?? this.phoneCallContact,
    loudAlarm: loudAlarm ?? this.loudAlarm,
    callEmergency: callEmergency ?? this.callEmergency,
  );

  /// Serializes to JSON.
  Map<String, Object?> toJson() => {
    'holdButton': holdButton.toJson(),
    'disguisedReminder': disguisedReminder.toJson(),
    'hardwareButton': hardwareButton.toJson(),
    'countdownWarning': countdownWarning.toJson(),
    'fakeCall': fakeCall.toJson(),
    'smsContact': smsContact.toJson(),
    'phoneCallContact': phoneCallContact.toJson(),
    'loudAlarm': loudAlarm.toJson(),
    'callEmergency': callEmergency.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventDefaults &&
          other.holdButton == holdButton &&
          other.disguisedReminder == disguisedReminder &&
          other.hardwareButton == hardwareButton &&
          other.countdownWarning == countdownWarning &&
          other.fakeCall == fakeCall &&
          other.smsContact == smsContact &&
          other.phoneCallContact == phoneCallContact &&
          other.loudAlarm == loudAlarm &&
          other.callEmergency == callEmergency;

  @override
  int get hashCode => Object.hash(
    holdButton,
    disguisedReminder,
    hardwareButton,
    countdownWarning,
    fakeCall,
    smsContact,
    phoneCallContact,
    loudAlarm,
    callEmergency,
  );

  @override
  String toString() => 'EventDefaults(...)';
}

T _field<T>(
  Map<String, Object?> json,
  String key,
  T Function(Map<String, Object?>) parser,
  T fallback,
) {
  final value = json[key];
  if (value is Map<String, Object?>) return parser(value);
  return fallback;
}
