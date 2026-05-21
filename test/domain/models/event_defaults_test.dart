// Unit tests for [EventDefaults].
//
// Verifies that [EventDefaults] is seeded with one default-constructed
// [StepConfig] instance per [ChainStepType] (spec 03 §EventDefaults),
// that [forType] returns the correct subclass for each of the nine
// step types, JSON round-trip stability, copyWith semantics, and the
// equality / hashCode contract.

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/countdown_style.dart';
import 'package:guardianangela/domain/enums/hold_style.dart';
import 'package:guardianangela/domain/enums/loud_alarm_sound.dart';
import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/enums/sms_contact_selection.dart';
import 'package:guardianangela/domain/enums/voice_output_mode.dart';
import 'package:guardianangela/domain/models/event_defaults.dart';

void main() {
  group('EventDefaults', () {
    group('defaults', () {
      test('default holdButton matches HoldButtonConfig() defaults', () {
        const eventDefaults = EventDefaults();

        check(eventDefaults.holdButton).equals(const HoldButtonConfig());
        check(eventDefaults.holdButton.holdStyle).equals(HoldStyle.largeButton);
        check(eventDefaults.holdButton.releaseSensitivity).equals(1.0);
        check(eventDefaults.holdButton.vibrateOnRelease).isTrue();
        check(eventDefaults.holdButton.soundOnRelease).isFalse();
      });

      test('default disguisedReminder matches DisguisedReminderConfig() '
          'defaults (D4 = true)', () {
        const eventDefaults = EventDefaults();

        check(
          eventDefaults.disguisedReminder,
        ).equals(const DisguisedReminderConfig());
        check(eventDefaults.disguisedReminder.randomizeInterval).isTrue();
        check(eventDefaults.disguisedReminder.randomizeTemplateOrder).isTrue();
        check(eventDefaults.disguisedReminder.resetOnEarlyCheckIn).isTrue();
      });

      test('default countdownWarning matches CountdownWarningConfig() '
          'defaults', () {
        const eventDefaults = EventDefaults();

        check(
          eventDefaults.countdownWarning,
        ).equals(const CountdownWarningConfig());
        check(
          eventDefaults.countdownWarning.style,
        ).equals(CountdownStyle.fullScreen);
        check(eventDefaults.countdownWarning.vibrate).isTrue();
      });

      test('default fakeCall matches FakeCallConfig() defaults', () {
        const eventDefaults = EventDefaults();

        check(eventDefaults.fakeCall).equals(const FakeCallConfig());
        check(eventDefaults.fakeCall.callerName).equals('Angela');
        check(
          eventDefaults.fakeCall.voiceOutputMode,
        ).equals(VoiceOutputMode.earpiece);
        check(eventDefaults.fakeCall.ringDurationSeconds).equals(30);
        check(eventDefaults.fakeCall.declineIsSafe).isTrue();
      });

      test('default smsContact matches SmsContactConfig() defaults '
          '(allContacts, sms)', () {
        const eventDefaults = EventDefaults();

        check(eventDefaults.smsContact).equals(const SmsContactConfig());
        check(
          eventDefaults.smsContact.contactSelection,
        ).equals(SmsContactSelection.allContacts);
        check(eventDefaults.smsContact.channel).equals(MessageChannel.sms);
        check(eventDefaults.smsContact.includeLocation).isTrue();
        check(eventDefaults.smsContact.includeMedicalInfo).isFalse();
      });

      test('default phoneCallContact matches PhoneCallContactConfig() '
          'defaults', () {
        const eventDefaults = EventDefaults();

        check(
          eventDefaults.phoneCallContact,
        ).equals(const PhoneCallContactConfig());
        check(eventDefaults.phoneCallContact.contactId).isNull();
        check(eventDefaults.phoneCallContact.alternativeContactIds).isEmpty();
      });

      test('default loudAlarm matches LoudAlarmConfig() defaults', () {
        const eventDefaults = EventDefaults();

        check(eventDefaults.loudAlarm).equals(const LoudAlarmConfig());
        check(eventDefaults.loudAlarm.flashScreen).isFalse();
        check(eventDefaults.loudAlarm.flashSpeedMs).equals(500);
        check(eventDefaults.loudAlarm.volume).equals(1.0);
        check(eventDefaults.loudAlarm.soundChoice).equals(LoudAlarmSound.siren);
        check(eventDefaults.loudAlarm.flashLight).isTrue();
      });

      test('default callEmergency matches CallEmergencyConfig() defaults', () {
        const eventDefaults = EventDefaults();

        check(eventDefaults.callEmergency).equals(const CallEmergencyConfig());
        check(eventDefaults.callEmergency.emergencyNumber).isNull();
        check(eventDefaults.callEmergency.sendLocationSmsFirst).isTrue();
        check(eventDefaults.callEmergency.showConfirmation).isTrue();
        check(
          eventDefaults.callEmergency.confirmationDurationSeconds,
        ).equals(5);
      });

      test('default hardwareButton matches HardwareButtonConfig() '
          'defaults (B1 = 5 presses)', () {
        const eventDefaults = EventDefaults();

        check(
          eventDefaults.hardwareButton,
        ).equals(const HardwareButtonConfig());
        check(eventDefaults.hardwareButton.pressCount).equals(5);
      });
    });

    group('forType — returns the correct StepConfig subclass for each '
        'of the 9 step types', () {
      test('forType(holdButton) returns a HoldButtonConfig', () {
        const eventDefaults = EventDefaults();

        check(
          eventDefaults.forType(ChainStepType.holdButton),
        ).isA<HoldButtonConfig>();
      });

      test('forType(disguisedReminder) returns a DisguisedReminderConfig', () {
        const eventDefaults = EventDefaults();

        check(
          eventDefaults.forType(ChainStepType.disguisedReminder),
        ).isA<DisguisedReminderConfig>();
      });

      test('forType(countdownWarning) returns a CountdownWarningConfig', () {
        const eventDefaults = EventDefaults();

        check(
          eventDefaults.forType(ChainStepType.countdownWarning),
        ).isA<CountdownWarningConfig>();
      });

      test('forType(fakeCall) returns a FakeCallConfig', () {
        const eventDefaults = EventDefaults();

        check(
          eventDefaults.forType(ChainStepType.fakeCall),
        ).isA<FakeCallConfig>();
      });

      test('forType(smsContact) returns an SmsContactConfig', () {
        const eventDefaults = EventDefaults();

        check(
          eventDefaults.forType(ChainStepType.smsContact),
        ).isA<SmsContactConfig>();
      });

      test('forType(phoneCallContact) returns a PhoneCallContactConfig', () {
        const eventDefaults = EventDefaults();

        check(
          eventDefaults.forType(ChainStepType.phoneCallContact),
        ).isA<PhoneCallContactConfig>();
      });

      test('forType(loudAlarm) returns a LoudAlarmConfig', () {
        const eventDefaults = EventDefaults();

        check(
          eventDefaults.forType(ChainStepType.loudAlarm),
        ).isA<LoudAlarmConfig>();
      });

      test('forType(callEmergency) returns a CallEmergencyConfig', () {
        const eventDefaults = EventDefaults();

        check(
          eventDefaults.forType(ChainStepType.callEmergency),
        ).isA<CallEmergencyConfig>();
      });

      test('forType(hardwareButton) returns a HardwareButtonConfig', () {
        const eventDefaults = EventDefaults();

        check(
          eventDefaults.forType(ChainStepType.hardwareButton),
        ).isA<HardwareButtonConfig>();
      });

      test('forType returns the same instance stored on the field '
          '(no copy)', () {
        // Arrange — a non-default loudAlarm config we can identify.
        const custom = LoudAlarmConfig(volume: 0.42);
        const eventDefaults = EventDefaults(loudAlarm: custom);

        // Act
        final fetched = eventDefaults.forType(ChainStepType.loudAlarm);

        // Assert
        check(identical(fetched, custom)).isTrue();
      });

      test('forType covers all nine ChainStepType values', () {
        // Sanity check that no enum value is missing from the switch.
        const eventDefaults = EventDefaults();

        for (final type in ChainStepType.values) {
          check(eventDefaults.forType(type)).isA<StepConfig>();
        }
      });
    });

    group('JSON round-trip', () {
      test('default instance round-trips', () {
        const original = EventDefaults();

        final restored = EventDefaults.fromJson(original.toJson());

        check(restored).equals(original);
      });

      test('non-default holdButton round-trips', () {
        const eventDefaults = EventDefaults(
          holdButton: HoldButtonConfig(
            holdStyle: HoldStyle.fakeLockScreen,
            releaseSensitivity: 2.0,
          ),
        );

        final restored = EventDefaults.fromJson(eventDefaults.toJson());

        check(restored.holdButton.holdStyle).equals(HoldStyle.fakeLockScreen);
        check(restored.holdButton.releaseSensitivity).equals(2.0);
      });

      test('non-default disguisedReminder round-trips', () {
        const eventDefaults = EventDefaults(
          disguisedReminder: DisguisedReminderConfig(
            randomizeInterval: false,
            resetOnEarlyCheckIn: false,
          ),
        );

        final restored = EventDefaults.fromJson(eventDefaults.toJson());

        check(restored.disguisedReminder.randomizeInterval).isFalse();
        check(restored.disguisedReminder.resetOnEarlyCheckIn).isFalse();
      });

      test('non-default fakeCall round-trips caller fields', () {
        const eventDefaults = EventDefaults(
          fakeCall: FakeCallConfig(
            callerName: 'Mom',
            ringDurationSeconds: 60,
            declineIsSafe: false,
          ),
        );

        final restored = EventDefaults.fromJson(eventDefaults.toJson());

        check(restored.fakeCall.callerName).equals('Mom');
        check(restored.fakeCall.ringDurationSeconds).equals(60);
        check(restored.fakeCall.declineIsSafe).isFalse();
      });

      test('non-default loudAlarm round-trips volume + sound', () {
        const eventDefaults = EventDefaults(
          loudAlarm: LoudAlarmConfig(
            volume: 0.5,
            soundChoice: LoudAlarmSound.custom,
          ),
        );

        final restored = EventDefaults.fromJson(eventDefaults.toJson());

        check(restored.loudAlarm.volume).equals(0.5);
        check(restored.loudAlarm.soundChoice).equals(LoudAlarmSound.custom);
      });

      test('toJson emits every per-type config as its own key', () {
        // Arrange
        const eventDefaults = EventDefaults();

        // Act
        final json = eventDefaults.toJson();

        // Assert — one entry per ChainStepType.
        check(json.keys.toSet()).deepEquals({
          'holdButton',
          'disguisedReminder',
          'countdownWarning',
          'fakeCall',
          'smsContact',
          'phoneCallContact',
          'loudAlarm',
          'callEmergency',
          'hardwareButton',
        });
      });

      test('fromJson on empty map fills in all defaults', () {
        final Map<String, dynamic> json = {};

        final restored = EventDefaults.fromJson(json);

        check(restored).equals(const EventDefaults());
      });
    });

    group('copyWith', () {
      test('copyWith() with no args returns an equivalent instance', () {
        const original = EventDefaults();

        final copy = original.copyWith();

        check(copy).equals(original);
      });

      test('copyWith can replace holdButton', () {
        const original = EventDefaults();
        const newCfg = HoldButtonConfig(releaseSensitivity: 2.5);

        final copy = original.copyWith(holdButton: newCfg);

        check(copy.holdButton).equals(newCfg);
        check(copy.disguisedReminder).equals(original.disguisedReminder);
      });

      test('copyWith can replace each of the 9 fields independently', () {
        // Arrange
        const original = EventDefaults();

        // Act + Assert — every per-type slot must be replaceable.
        check(
          original
              .copyWith(
                disguisedReminder: const DisguisedReminderConfig(
                  randomizeInterval: false,
                ),
              )
              .disguisedReminder
              .randomizeInterval,
        ).isFalse();
        check(
          original
              .copyWith(
                countdownWarning: const CountdownWarningConfig(
                  style: CountdownStyle.minimal,
                ),
              )
              .countdownWarning
              .style,
        ).equals(CountdownStyle.minimal);
        check(
          original
              .copyWith(fakeCall: const FakeCallConfig(callerName: 'Bob'))
              .fakeCall
              .callerName,
        ).equals('Bob');
        check(
          original
              .copyWith(
                smsContact: const SmsContactConfig(includeMedicalInfo: true),
              )
              .smsContact
              .includeMedicalInfo,
        ).isTrue();
        check(
          original
              .copyWith(
                phoneCallContact: const PhoneCallContactConfig(
                  contactId: 'c-1',
                ),
              )
              .phoneCallContact
              .contactId,
        ).equals('c-1');
        check(
          original
              .copyWith(loudAlarm: const LoudAlarmConfig(volume: 0.25))
              .loudAlarm
              .volume,
        ).equals(0.25);
        check(
          original
              .copyWith(
                callEmergency: const CallEmergencyConfig(
                  emergencyNumber: '911',
                ),
              )
              .callEmergency
              .emergencyNumber,
        ).equals('911');
        check(
          original
              .copyWith(
                hardwareButton: const HardwareButtonConfig(pressCount: 3),
              )
              .hardwareButton
              .pressCount,
        ).equals(3);
      });

      test('copyWith preserves nested HoldButtonConfig identity when not '
          'replaced', () {
        // Arrange
        const custom = HoldButtonConfig(releaseSensitivity: 1.5);
        const original = EventDefaults(holdButton: custom);

        // Act
        final copy = original.copyWith(
          fakeCall: const FakeCallConfig(callerName: 'X'),
        );

        // Assert
        check(identical(copy.holdButton, custom)).isTrue();
      });
    });

    group('equality and hashCode', () {
      test('two default instances are equal', () {
        const a = EventDefaults();
        const b = EventDefaults();

        check(a).equals(b);
        check(a.hashCode).equals(b.hashCode);
      });

      test('reflexive: equals itself', () {
        const eventDefaults = EventDefaults();

        check(eventDefaults).equals(eventDefaults);
      });

      test('symmetric: a == b implies b == a', () {
        const a = EventDefaults(fakeCall: FakeCallConfig(callerName: 'Mom'));
        const b = EventDefaults(fakeCall: FakeCallConfig(callerName: 'Mom'));

        check(a == b).isTrue();
        check(b == a).isTrue();
      });

      test('inequality on differing holdButton', () {
        const a = EventDefaults();
        const b = EventDefaults(
          holdButton: HoldButtonConfig(releaseSensitivity: 2.0),
        );

        check(a == b).isFalse();
      });

      test('inequality on differing fakeCall callerName', () {
        const a = EventDefaults();
        const b = EventDefaults(fakeCall: FakeCallConfig(callerName: 'Mom'));

        check(a == b).isFalse();
      });

      test('inequality on differing loudAlarm volume', () {
        const a = EventDefaults();
        const b = EventDefaults(loudAlarm: LoudAlarmConfig(volume: 0.5));

        check(a == b).isFalse();
      });

      test('inequality on differing hardwareButton pressCount', () {
        const a = EventDefaults();
        const b = EventDefaults(
          hardwareButton: HardwareButtonConfig(pressCount: 3),
        );

        check(a == b).isFalse();
      });

      test('hashCode is stable across calls', () {
        const eventDefaults = EventDefaults(
          smsContact: SmsContactConfig(includeMedicalInfo: true),
        );

        check(eventDefaults.hashCode).equals(eventDefaults.hashCode);
      });

      test('hashCode equal for equal instances with non-default fields', () {
        const a = EventDefaults(
          loudAlarm: LoudAlarmConfig(volume: 0.42, flashLight: false),
        );
        const b = EventDefaults(
          loudAlarm: LoudAlarmConfig(volume: 0.42, flashLight: false),
        );

        check(a.hashCode).equals(b.hashCode);
      });
    });
  });
}
