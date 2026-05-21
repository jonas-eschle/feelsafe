import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';

/// Global per-step-type default configuration.
///
/// Embedded inside [AppDefaults] (which is part of the [AppSettings] JSON
/// singleton). Not a Drift row. When a [ChainStep.config] is null, the
/// engine uses the matching [forType] config. See spec 03 §EventDefaults.
///
/// Seed defaults are populated on first launch with sensible values per the
/// timing table in spec 03 §Default Timing Values by Type.
final class EventDefaults {
  /// Creates an [EventDefaults] instance with the given per-type configs.
  ///
  /// If a config is omitted, the default-constructed instance for that
  /// type is used.
  const EventDefaults({
    this.holdButton = const HoldButtonConfig(),
    this.disguisedReminder = const DisguisedReminderConfig(),
    this.countdownWarning = const CountdownWarningConfig(),
    this.fakeCall = const FakeCallConfig(),
    this.smsContact = const SmsContactConfig(),
    this.phoneCallContact = const PhoneCallContactConfig(),
    this.loudAlarm = const LoudAlarmConfig(),
    this.callEmergency = const CallEmergencyConfig(),
    this.hardwareButton = const HardwareButtonConfig(),
  });

  /// Deserialises an [EventDefaults] from [json].
  factory EventDefaults.fromJson(Map<String, dynamic> json) => EventDefaults(
    holdButton: json['holdButton'] != null
        ? HoldButtonConfig.fromJson(json['holdButton'] as Map<String, dynamic>)
        : const HoldButtonConfig(),
    disguisedReminder: json['disguisedReminder'] != null
        ? DisguisedReminderConfig.fromJson(
            json['disguisedReminder'] as Map<String, dynamic>,
          )
        : const DisguisedReminderConfig(),
    countdownWarning: json['countdownWarning'] != null
        ? CountdownWarningConfig.fromJson(
            json['countdownWarning'] as Map<String, dynamic>,
          )
        : const CountdownWarningConfig(),
    fakeCall: json['fakeCall'] != null
        ? FakeCallConfig.fromJson(json['fakeCall'] as Map<String, dynamic>)
        : const FakeCallConfig(),
    smsContact: json['smsContact'] != null
        ? SmsContactConfig.fromJson(json['smsContact'] as Map<String, dynamic>)
        : const SmsContactConfig(),
    phoneCallContact: json['phoneCallContact'] != null
        ? PhoneCallContactConfig.fromJson(
            json['phoneCallContact'] as Map<String, dynamic>,
          )
        : const PhoneCallContactConfig(),
    loudAlarm: json['loudAlarm'] != null
        ? LoudAlarmConfig.fromJson(json['loudAlarm'] as Map<String, dynamic>)
        : const LoudAlarmConfig(),
    callEmergency: json['callEmergency'] != null
        ? CallEmergencyConfig.fromJson(
            json['callEmergency'] as Map<String, dynamic>,
          )
        : const CallEmergencyConfig(),
    hardwareButton: json['hardwareButton'] != null
        ? HardwareButtonConfig.fromJson(
            json['hardwareButton'] as Map<String, dynamic>,
          )
        : const HardwareButtonConfig(),
  );

  /// Default config for [ChainStepType.holdButton] steps.
  final HoldButtonConfig holdButton;

  /// Default config for [ChainStepType.disguisedReminder] steps.
  final DisguisedReminderConfig disguisedReminder;

  /// Default config for [ChainStepType.countdownWarning] steps.
  final CountdownWarningConfig countdownWarning;

  /// Default config for [ChainStepType.fakeCall] steps.
  final FakeCallConfig fakeCall;

  /// Default config for [ChainStepType.smsContact] steps.
  final SmsContactConfig smsContact;

  /// Default config for [ChainStepType.phoneCallContact] steps.
  final PhoneCallContactConfig phoneCallContact;

  /// Default config for [ChainStepType.loudAlarm] steps.
  final LoudAlarmConfig loudAlarm;

  /// Default config for [ChainStepType.callEmergency] steps.
  final CallEmergencyConfig callEmergency;

  /// Default config for [ChainStepType.hardwareButton] steps.
  final HardwareButtonConfig hardwareButton;

  /// Returns the typed default config for [type].
  StepConfig forType(ChainStepType type) => switch (type) {
    ChainStepType.holdButton => holdButton,
    ChainStepType.disguisedReminder => disguisedReminder,
    ChainStepType.countdownWarning => countdownWarning,
    ChainStepType.fakeCall => fakeCall,
    ChainStepType.smsContact => smsContact,
    ChainStepType.phoneCallContact => phoneCallContact,
    ChainStepType.loudAlarm => loudAlarm,
    ChainStepType.callEmergency => callEmergency,
    ChainStepType.hardwareButton => hardwareButton,
  };

  /// Returns a copy with the specified fields replaced.
  EventDefaults copyWith({
    HoldButtonConfig? holdButton,
    DisguisedReminderConfig? disguisedReminder,
    CountdownWarningConfig? countdownWarning,
    FakeCallConfig? fakeCall,
    SmsContactConfig? smsContact,
    PhoneCallContactConfig? phoneCallContact,
    LoudAlarmConfig? loudAlarm,
    CallEmergencyConfig? callEmergency,
    HardwareButtonConfig? hardwareButton,
  }) => EventDefaults(
    holdButton: holdButton ?? this.holdButton,
    disguisedReminder: disguisedReminder ?? this.disguisedReminder,
    countdownWarning: countdownWarning ?? this.countdownWarning,
    fakeCall: fakeCall ?? this.fakeCall,
    smsContact: smsContact ?? this.smsContact,
    phoneCallContact: phoneCallContact ?? this.phoneCallContact,
    loudAlarm: loudAlarm ?? this.loudAlarm,
    callEmergency: callEmergency ?? this.callEmergency,
    hardwareButton: hardwareButton ?? this.hardwareButton,
  );

  /// Serialises this instance to a JSON map.
  Map<String, dynamic> toJson() => {
    'holdButton': holdButton.toJson(),
    'disguisedReminder': disguisedReminder.toJson(),
    'countdownWarning': countdownWarning.toJson(),
    'fakeCall': fakeCall.toJson(),
    'smsContact': smsContact.toJson(),
    'phoneCallContact': phoneCallContact.toJson(),
    'loudAlarm': loudAlarm.toJson(),
    'callEmergency': callEmergency.toJson(),
    'hardwareButton': hardwareButton.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventDefaults &&
          holdButton == other.holdButton &&
          disguisedReminder == other.disguisedReminder &&
          countdownWarning == other.countdownWarning &&
          fakeCall == other.fakeCall &&
          smsContact == other.smsContact &&
          phoneCallContact == other.phoneCallContact &&
          loudAlarm == other.loudAlarm &&
          callEmergency == other.callEmergency &&
          hardwareButton == other.hardwareButton);

  @override
  int get hashCode => Object.hash(
    holdButton,
    disguisedReminder,
    countdownWarning,
    fakeCall,
    smsContact,
    phoneCallContact,
    loudAlarm,
    callEmergency,
    hardwareButton,
  );
}
