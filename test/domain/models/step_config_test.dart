/// Unit tests for every [StepConfig] subtype — defaults, copyWith,
/// toJson discriminator, fromJson dispatch, and unknown-type error.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/models.dart';

void main() {
  group('StepConfig.fromJson', () {
    test('missing type throws ArgumentError', () {
      check(
        () => StepConfig.fromJson(const <String, Object?>{}),
      ).throws<ArgumentError>();
    });

    test('non-string type throws ArgumentError', () {
      check(
        () => StepConfig.fromJson(const {'type': 42}),
      ).throws<ArgumentError>();
    });

    test('unknown type throws ArgumentError', () {
      check(
        () => StepConfig.fromJson(const {'type': 'bogus'}),
      ).throws<ArgumentError>();
    });

    test('dispatches holdButton', () {
      final c = StepConfig.fromJson(const {'type': 'holdButton'});
      check(c).isA<HoldButtonConfig>();
    });

    test('dispatches disguisedReminder', () {
      final c = StepConfig.fromJson(const {'type': 'disguisedReminder'});
      check(c).isA<DisguisedReminderConfig>();
    });

    test('dispatches hardwareButton', () {
      final c = StepConfig.fromJson(const {'type': 'hardwareButton'});
      check(c).isA<HardwareButtonConfig>();
    });

    test('dispatches countdownWarning', () {
      final c = StepConfig.fromJson(const {'type': 'countdownWarning'});
      check(c).isA<CountdownWarningConfig>();
    });

    test('dispatches fakeCall', () {
      final c = StepConfig.fromJson(const {'type': 'fakeCall'});
      check(c).isA<FakeCallConfig>();
    });

    test('dispatches smsContact', () {
      final c = StepConfig.fromJson(const {'type': 'smsContact'});
      check(c).isA<SmsContactConfig>();
    });

    test('dispatches phoneCallContact', () {
      final c = StepConfig.fromJson(const {'type': 'phoneCallContact'});
      check(c).isA<PhoneCallContactConfig>();
    });

    test('dispatches loudAlarm', () {
      final c = StepConfig.fromJson(const {'type': 'loudAlarm'});
      check(c).isA<LoudAlarmConfig>();
    });

    test('dispatches callEmergency', () {
      final c = StepConfig.fromJson(const {'type': 'callEmergency'});
      check(c).isA<CallEmergencyConfig>();
    });
  });

  group('HoldButtonConfig', () {
    test('defaults', () {
      const c = HoldButtonConfig();
      // Spec 02 §1.holdButton default 1.0.
      check(c.releaseSensitivity).equals(1.0);
      check(c.holdStyle).equals(HoldStyle.largeButton);
      check(c.vibrateOnRelease).isTrue();
      check(c.soundOnRelease).isFalse();
      check(c.blackScreenMode).isFalse();
    });

    test('copyWith', () {
      const c = HoldButtonConfig();
      check(c.copyWith(releaseSensitivity: 0.5).releaseSensitivity).equals(0.5);
    });

    test('toJson discriminator', () {
      check(const HoldButtonConfig().toJson()['type']).equals('holdButton');
    });

    test('round-trip', () {
      const c = HoldButtonConfig(
        releaseSensitivity: 0.9,
        holdStyle: HoldStyle.fullScreen,
        vibrateOnRelease: false,
        soundOnRelease: true,
        blackScreenMode: true,
      );
      check(StepConfig.fromJson(c.toJson())).equals(c);
    });

    test('equality', () {
      check(const HoldButtonConfig()).equals(const HoldButtonConfig());
    });
  });

  group('DisguisedReminderConfig', () {
    test('defaults', () {
      const c = DisguisedReminderConfig();
      check(c.templateId).isNull();
      check(c.intervalSeconds).equals(60);
      check(c.randomizeInterval).isFalse();
      check(c.randomizeTemplateOrder).isFalse();
      check(c.resetOnEarlyCheckIn).isTrue();
      check(c.blackScreenMode).isFalse();
    });

    test('copyWith', () {
      const c = DisguisedReminderConfig();
      final c2 = c.copyWith(templateId: 't1', intervalSeconds: 30);
      check(c2.templateId).equals('t1');
      check(c2.intervalSeconds).equals(30);
    });

    test('toJson discriminator', () {
      check(
        const DisguisedReminderConfig().toJson()['type'],
      ).equals('disguisedReminder');
    });

    test('round-trip', () {
      const c = DisguisedReminderConfig(templateId: 't1', intervalSeconds: 30);
      check(StepConfig.fromJson(c.toJson())).equals(c);
    });
  });

  group('HardwareButtonConfig', () {
    test('defaults', () {
      const c = HardwareButtonConfig();
      check(c.buttonType).equals(ButtonType.volumeUp);
      check(c.pattern).equals(HardwarePattern.repeatPress);
      check(c.pressCount).equals(5);
      check(c.pressWindowMs).equals(500);
      check(c.longPressDurationSeconds).equals(2.0);
    });

    test('copyWith', () {
      const c = HardwareButtonConfig();
      final c2 = c.copyWith(
        buttonType: ButtonType.power,
        pattern: HardwarePattern.longPress,
        pressCount: 10,
        pressWindowMs: 1000,
        longPressDurationSeconds: 5.0,
      );
      check(c2.buttonType).equals(ButtonType.power);
      check(c2.pattern).equals(HardwarePattern.longPress);
      check(c2.pressCount).equals(10);
      check(c2.pressWindowMs).equals(1000);
      check(c2.longPressDurationSeconds).equals(5.0);
    });

    test('toJson discriminator', () {
      check(
        const HardwareButtonConfig().toJson()['type'],
      ).equals('hardwareButton');
    });

    test('round-trip', () {
      const c = HardwareButtonConfig(
        buttonType: ButtonType.volumeDown,
        pattern: HardwarePattern.longPress,
        pressCount: 7,
        pressWindowMs: 600,
        longPressDurationSeconds: 4.0,
      );
      check(StepConfig.fromJson(c.toJson())).equals(c);
    });

    test('unknown buttonType throws', () {
      check(
        () => HardwareButtonConfig.fromJson(const {
          'type': 'hardwareButton',
          'buttonType': 'moon',
        }),
      ).throws<ArgumentError>();
    });

    test('unknown pattern throws', () {
      check(
        () => HardwareButtonConfig.fromJson(const {
          'type': 'hardwareButton',
          'pattern': 'x',
        }),
      ).throws<ArgumentError>();
    });
  });

  group('CountdownWarningConfig', () {
    test('defaults', () {
      const c = CountdownWarningConfig();
      check(c.vibrate).isTrue();
      check(c.playTone).isFalse();
    });

    test('copyWith', () {
      const c = CountdownWarningConfig();
      final c2 = c.copyWith(vibrate: false, playTone: true);
      check(c2.vibrate).isFalse();
      check(c2.playTone).isTrue();
    });

    test('round-trip', () {
      const c = CountdownWarningConfig(vibrate: false, playTone: true);
      check(StepConfig.fromJson(c.toJson())).equals(c);
    });
  });

  group('FakeCallConfig', () {
    test('defaults', () {
      const c = FakeCallConfig();
      // Default "Angela" per Guardian Angela product brand + "Ask
      // for Angela" safety campaign. declineIsSafe defaults to TRUE
      // per D-SAFETY-7 (minimize false positives).
      check(c.callerName).equals('Angela');
      check(c.ringtoneAsset).isNull();
      check(c.voiceRecordingAsset).isNull();
      check(c.declineIsSafe).isTrue();
      check(c.callStyle).equals(CallStyle.android);
      check(c.callerPhotoPath).isNull();
      check(c.voiceSource).equals(VoiceSource.tts);
      check(c.voiceRoute).equals(VoiceRoute.earpiece);
      check(c.ringDurationSeconds).equals(30);
      check(c.declineWithDistressHoldSeconds).equals(5.0);
      check(c.blackScreenMode).isFalse();
    });

    test('copyWith', () {
      const c = FakeCallConfig();
      final c2 = c.copyWith(callerName: 'Dad', ringDurationSeconds: 45);
      check(c2.callerName).equals('Dad');
      check(c2.ringDurationSeconds).equals(45);
    });

    test('round-trip', () {
      const c = FakeCallConfig(
        callerName: 'Dad',
        ringtoneAsset: 'a.mp3',
        voiceRecordingAsset: 'v.mp3',
        declineIsSafe: false,
        callStyle: CallStyle.ios,
        callerPhotoPath: 'photo.png',
        voiceSource: VoiceSource.recording,
        voiceRoute: VoiceRoute.speaker,
        ringDurationSeconds: 15,
        declineWithDistressHoldSeconds: 3.0,
        blackScreenMode: true,
      );
      check(StepConfig.fromJson(c.toJson())).equals(c);
    });
  });

  group('SmsContactConfig', () {
    test('defaults', () {
      const c = SmsContactConfig();
      check(c.contactIds).isNull();
      check(c.contactSelection).equals(SmsContactSelection.allContacts);
      check(c.channel).equals(MessageChannel.sms);
      check(c.includeLocation).isTrue();
      check(c.includeMedicalInfo).isFalse();
      check(c.autoRecordAudio).isFalse();
      check(c.autoRecordVideo).isFalse();
      check(c.recordDurationSeconds).equals(15);
      check(c.messageTemplate).isNull();
      check(c.blackScreenMode).isFalse();
    });

    test('copyWith', () {
      const c = SmsContactConfig();
      final c2 = c.copyWith(
        contactIds: const ['x'],
        contactSelection: SmsContactSelection.specificIds,
        channel: MessageChannel.whatsapp,
      );
      check(c2.contactIds).isNotNull().deepEquals(['x']);
      check(c2.contactSelection).equals(SmsContactSelection.specificIds);
      check(c2.channel).equals(MessageChannel.whatsapp);
    });

    test('round-trip preserves contactIds list', () {
      const c = SmsContactConfig(
        contactIds: ['a', 'b', 'c'],
        contactSelection: SmsContactSelection.specificIds,
        channel: MessageChannel.telegram,
        includeLocation: false,
        includeMedicalInfo: true,
        autoRecordAudio: true,
        autoRecordVideo: true,
        recordDurationSeconds: 30,
        messageTemplate: 'Help',
        blackScreenMode: true,
      );
      check(StepConfig.fromJson(c.toJson())).equals(c);
    });

    test('unknown selection throws', () {
      check(
        () => SmsContactConfig.fromJson(const {
          'type': 'smsContact',
          'contactSelection': 'bogus',
        }),
      ).throws<ArgumentError>();
    });

    test('unknown channel throws', () {
      check(
        () => SmsContactConfig.fromJson(const {
          'type': 'smsContact',
          'channel': 'smoke',
        }),
      ).throws<ArgumentError>();
    });
  });

  group('PhoneCallContactConfig', () {
    test('defaults', () {
      const c = PhoneCallContactConfig();
      check(c.contactId).isNull();
      check(c.alternativeContactIds).isEmpty();
      // Q12: preSendSms / preSmsIncludeLocation / preSmsMessage removed.
    });

    test('copyWith', () {
      const c = PhoneCallContactConfig();
      final c2 = c.copyWith(
        contactId: 'c1',
        alternativeContactIds: const ['c2'],
      );
      check(c2.contactId).equals('c1');
      check(c2.alternativeContactIds).deepEquals(['c2']);
    });

    test('round-trip with alternatives', () {
      const c = PhoneCallContactConfig(
        contactId: 'c1',
        alternativeContactIds: ['c2', 'c3'],
      );
      check(StepConfig.fromJson(c.toJson())).equals(c);
    });
  });

  group('LoudAlarmConfig', () {
    test('defaults', () {
      const c = LoudAlarmConfig();
      // Spec 02 §8.loudAlarm flashScreen default false.
      check(c.flashScreen).isFalse();
      check(c.flashSpeed).equals(0.5);
      check(c.maxVolume).isTrue();
      check(c.volume).equals(1.0);
      check(c.soundChoice).equals(LoudAlarmSound.siren);
      check(c.gradualVolume).isFalse();
      check(c.flashLight).isTrue();
      check(c.flashSpeedMs).equals(500);
      check(c.blackScreenMode).isFalse();
    });

    test('copyWith', () {
      const c = LoudAlarmConfig();
      final c2 = c.copyWith(
        flashScreen: true,
        flashSpeed: 0.1,
        maxVolume: false,
        volume: 0.5,
        soundChoice: LoudAlarmSound.custom,
        gradualVolume: true,
        flashLight: false,
        flashSpeedMs: 250,
        blackScreenMode: true,
      );
      check(c2.flashScreen).isTrue();
      check(c2.flashSpeed).equals(0.1);
      check(c2.maxVolume).isFalse();
      check(c2.volume).equals(0.5);
      check(c2.soundChoice).equals(LoudAlarmSound.custom);
      check(c2.gradualVolume).isTrue();
      check(c2.flashLight).isFalse();
      check(c2.flashSpeedMs).equals(250);
      check(c2.blackScreenMode).isTrue();
    });

    test('round-trip', () {
      const c = LoudAlarmConfig(
        flashScreen: true,
        flashSpeed: 1.0,
        volume: 0.8,
        soundChoice: LoudAlarmSound.custom,
        gradualVolume: true,
        flashLight: false,
        flashSpeedMs: 300,
        blackScreenMode: true,
      );
      check(StepConfig.fromJson(c.toJson())).equals(c);
    });
  });

  group('CallEmergencyConfig', () {
    test('defaults', () {
      const c = CallEmergencyConfig();
      check(c.emergencyNumber).isNull();
      // Spec 02 §9 / D-UX-8: showConfirmation defaults to true.
      check(c.showConfirmation).isTrue();
      check(c.sendLocationSmsFirst).isTrue();
      check(c.confirmationDurationSeconds).equals(5);
      check(c.blackScreenMode).isFalse();
    });

    test('copyWith', () {
      const c = CallEmergencyConfig();
      final c2 = c.copyWith(emergencyNumber: '999', showConfirmation: false);
      check(c2.emergencyNumber).equals('999');
      check(c2.showConfirmation).isFalse();
    });

    test('copyWith clearEmergencyNumber', () {
      const c = CallEmergencyConfig(emergencyNumber: '999');
      final c2 = c.copyWith(clearEmergencyNumber: true);
      check(c2.emergencyNumber).isNull();
    });

    test('round-trip', () {
      const c = CallEmergencyConfig(
        emergencyNumber: '911',
        showConfirmation: false,
        sendLocationSmsFirst: false,
        confirmationDurationSeconds: 10,
        blackScreenMode: true,
      );
      check(StepConfig.fromJson(c.toJson())).equals(c);
    });
  });

  group('StepConfig toString coverage', () {
    test('HoldButtonConfig toString', () {
      check(
        const HoldButtonConfig(releaseSensitivity: 0.5).toString(),
      ).contains('0.5');
    });

    test('DisguisedReminderConfig toString', () {
      final str = const DisguisedReminderConfig(
        templateId: 'calendar',
        intervalSeconds: 20,
      ).toString();
      check(str).contains('calendar');
      check(str).contains('20');
    });

    test('HardwareButtonConfig toString', () {
      final str = const HardwareButtonConfig(
        buttonType: ButtonType.power,
        pattern: HardwarePattern.longPress,
        pressCount: 6,
        pressWindowMs: 300,
        longPressDurationSeconds: 3.0,
      ).toString();
      check(str).contains('power');
      check(str).contains('longPress');
      check(str).contains('6');
      check(str).contains('300');
      check(str).contains('3.0');
    });

    test('CountdownWarningConfig toString', () {
      final str = const CountdownWarningConfig(
        vibrate: false,
        playTone: true,
      ).toString();
      check(str).contains('vibrate: false');
      check(str).contains('playTone: true');
    });

    test('FakeCallConfig toString', () {
      final str = const FakeCallConfig(
        callerName: 'Dad',
        ringtoneAsset: 'a.mp3',
        voiceRecordingAsset: 'v.mp3',
        declineIsSafe: false,
        ringDurationSeconds: 15,
      ).toString();
      check(str).contains('Dad');
      check(str).contains('a.mp3');
      check(str).contains('v.mp3');
      check(str).contains('declineIsSafe: false');
      check(str).contains('ringDurationSeconds: 15');
    });

    test('SmsContactConfig toString', () {
      final str = const SmsContactConfig(
        contactIds: ['x'],
        contactSelection: SmsContactSelection.specificIds,
        channel: MessageChannel.whatsapp,
        includeLocation: false,
        includeMedicalInfo: true,
      ).toString();
      check(str).contains('[x]');
      check(str).contains('specificIds');
      check(str).contains('whatsapp');
      check(str).contains('includeLocation: false');
      check(str).contains('includeMedicalInfo: true');
    });

    test('PhoneCallContactConfig toString', () {
      final str = const PhoneCallContactConfig(
        contactId: 'c1',
        alternativeContactIds: ['c2'],
      ).toString();
      check(str).contains('c1');
      check(str).contains('[c2]');
    });

    test('LoudAlarmConfig toString', () {
      final str = const LoudAlarmConfig(
        flashScreen: false,
        flashSpeed: 0.2,
        maxVolume: false,
      ).toString();
      check(str).contains('flashScreen: false');
      check(str).contains('flashSpeed: 0.2');
      check(str).contains('maxVolume: false');
    });

    test('CallEmergencyConfig toString', () {
      final str = const CallEmergencyConfig(
        emergencyNumber: '911',
        showConfirmation: false,
      ).toString();
      check(str).contains('911');
      check(str).contains('showConfirmation: false');
    });
  });

  group('StepConfig equality / hashCode', () {
    test('HoldButtonConfig identical', () {
      const c = HoldButtonConfig();
      check(c == c).isTrue();
    });

    test('HoldButtonConfig cross-type unequal', () {
      // ignore: unrelated_type_equality_checks
      check(const HoldButtonConfig() == 'x').isFalse();
    });

    test('HoldButtonConfig differ releaseSensitivity unequal', () {
      check(
        const HoldButtonConfig(releaseSensitivity: 0.1) ==
            const HoldButtonConfig(releaseSensitivity: 0.2),
      ).isFalse();
    });

    test('DisguisedReminderConfig equal values equal', () {
      check(const DisguisedReminderConfig(templateId: 't'))
          .equals(const DisguisedReminderConfig(templateId: 't'));
      check(const DisguisedReminderConfig(templateId: 't').hashCode)
          .equals(const DisguisedReminderConfig(templateId: 't').hashCode);
    });

    test('DisguisedReminderConfig differ unequal', () {
      check(
        const DisguisedReminderConfig() ==
            const DisguisedReminderConfig(intervalSeconds: 1),
      ).isFalse();
      check(
        const DisguisedReminderConfig(templateId: 'a') ==
            const DisguisedReminderConfig(templateId: 'b'),
      ).isFalse();
    });

    test('HardwareButtonConfig identical', () {
      const c = HardwareButtonConfig();
      check(c == c).isTrue();
    });

    test('HardwareButtonConfig cross-type unequal', () {
      // ignore: unrelated_type_equality_checks
      check(const HardwareButtonConfig() == 'x').isFalse();
    });

    test('HardwareButtonConfig equal hashCode', () {
      check(const HardwareButtonConfig().hashCode)
          .equals(const HardwareButtonConfig().hashCode);
    });

    test('HardwareButtonConfig differ fields unequal', () {
      check(
        const HardwareButtonConfig() ==
            const HardwareButtonConfig(buttonType: ButtonType.power),
      ).isFalse();
      check(
        const HardwareButtonConfig() ==
            const HardwareButtonConfig(pattern: HardwarePattern.longPress),
      ).isFalse();
      check(
        const HardwareButtonConfig() ==
            const HardwareButtonConfig(pressCount: 10),
      ).isFalse();
      check(
        const HardwareButtonConfig() ==
            const HardwareButtonConfig(pressWindowMs: 100),
      ).isFalse();
      check(
        const HardwareButtonConfig() ==
            const HardwareButtonConfig(longPressDurationSeconds: 9.0),
      ).isFalse();
    });

    test('CountdownWarningConfig equality', () {
      check(const CountdownWarningConfig())
          .equals(const CountdownWarningConfig());
      check(const CountdownWarningConfig(vibrate: false) ==
              const CountdownWarningConfig())
          .isFalse();
      check(const CountdownWarningConfig(playTone: true) ==
              const CountdownWarningConfig())
          .isFalse();
    });

    test('FakeCallConfig identical', () {
      const c = FakeCallConfig();
      check(c == c).isTrue();
    });

    test('FakeCallConfig cross-type unequal', () {
      // ignore: unrelated_type_equality_checks
      check(const FakeCallConfig() == 'x').isFalse();
    });

    test('FakeCallConfig differ unequal', () {
      check(
        const FakeCallConfig() == const FakeCallConfig(callerName: 'Dad'),
      ).isFalse();
      check(
        const FakeCallConfig() == const FakeCallConfig(ringtoneAsset: 'a'),
      ).isFalse();
      check(
        const FakeCallConfig() ==
            const FakeCallConfig(voiceRecordingAsset: 'v'),
      ).isFalse();
      check(
        const FakeCallConfig() == const FakeCallConfig(declineIsSafe: false),
      ).isFalse();
      check(
        const FakeCallConfig() ==
            const FakeCallConfig(ringDurationSeconds: 45),
      ).isFalse();
      check(
        const FakeCallConfig() ==
            const FakeCallConfig(callStyle: CallStyle.ios),
      ).isFalse();
      check(
        const FakeCallConfig() ==
            const FakeCallConfig(voiceSource: VoiceSource.none),
      ).isFalse();
      check(
        const FakeCallConfig() ==
            const FakeCallConfig(voiceRoute: VoiceRoute.speaker),
      ).isFalse();
      check(
        const FakeCallConfig() ==
            const FakeCallConfig(declineWithDistressHoldSeconds: 3.0),
      ).isFalse();
      check(
        const FakeCallConfig() == const FakeCallConfig(blackScreenMode: true),
      ).isFalse();
    });

    test('FakeCallConfig hashCode stable', () {
      check(const FakeCallConfig().hashCode).equals(
        const FakeCallConfig().hashCode,
      );
    });

    test('FakeCallConfig copyWith clearCallerName', () {
      const c = FakeCallConfig(callerName: 'Dad');
      check(c.copyWith(clearCallerName: true).callerName).isNull();
    });

    test('SmsContactConfig copyWith clearContactIds', () {
      const c = SmsContactConfig(contactIds: ['a']);
      check(c.copyWith(clearContactIds: true).contactIds).isNull();
    });

    test('SmsContactConfig copyWith full', () {
      const c = SmsContactConfig();
      final c2 = c.copyWith(
        includeLocation: false,
        includeMedicalInfo: true,
        autoRecordAudio: true,
        autoRecordVideo: true,
        recordDurationSeconds: 30,
        messageTemplate: 'hi',
        blackScreenMode: true,
      );
      check(c2.includeLocation).isFalse();
      check(c2.includeMedicalInfo).isTrue();
      check(c2.autoRecordAudio).isTrue();
      check(c2.autoRecordVideo).isTrue();
      check(c2.recordDurationSeconds).equals(30);
      check(c2.messageTemplate).equals('hi');
      check(c2.blackScreenMode).isTrue();
    });

    test('SmsContactConfig identical equals', () {
      const c = SmsContactConfig();
      check(c == c).isTrue();
    });

    test('SmsContactConfig differ unequal', () {
      check(
        const SmsContactConfig() ==
            const SmsContactConfig(contactIds: ['a']),
      ).isFalse();
      check(
        const SmsContactConfig(contactIds: ['a']) ==
            const SmsContactConfig(contactIds: ['b']),
      ).isFalse();
      check(
        const SmsContactConfig() ==
            const SmsContactConfig(
              contactSelection: SmsContactSelection.firstContact,
            ),
      ).isFalse();
      check(
        const SmsContactConfig() ==
            const SmsContactConfig(channel: MessageChannel.whatsapp),
      ).isFalse();
      check(
        const SmsContactConfig() ==
            const SmsContactConfig(includeLocation: false),
      ).isFalse();
      check(
        const SmsContactConfig() ==
            const SmsContactConfig(includeMedicalInfo: true),
      ).isFalse();
      check(
        const SmsContactConfig() ==
            const SmsContactConfig(autoRecordAudio: true),
      ).isFalse();
      check(
        const SmsContactConfig() ==
            const SmsContactConfig(autoRecordVideo: true),
      ).isFalse();
      check(
        const SmsContactConfig() ==
            const SmsContactConfig(recordDurationSeconds: 30),
      ).isFalse();
      check(
        const SmsContactConfig() ==
            const SmsContactConfig(messageTemplate: 'hi'),
      ).isFalse();
      check(
        const SmsContactConfig() ==
            const SmsContactConfig(blackScreenMode: true),
      ).isFalse();
    });

    test('SmsContactConfig hashCode stable', () {
      check(const SmsContactConfig().hashCode)
          .equals(const SmsContactConfig().hashCode);
    });

    test('PhoneCallContactConfig identical', () {
      const c = PhoneCallContactConfig();
      check(c == c).isTrue();
    });

    test('PhoneCallContactConfig cross-type unequal', () {
      // ignore: unrelated_type_equality_checks
      check(const PhoneCallContactConfig() == 'x').isFalse();
    });

    test('PhoneCallContactConfig differ unequal', () {
      check(
        const PhoneCallContactConfig() ==
            const PhoneCallContactConfig(contactId: 'a'),
      ).isFalse();
      check(
        const PhoneCallContactConfig(alternativeContactIds: ['a']) ==
            const PhoneCallContactConfig(alternativeContactIds: ['b']),
      ).isFalse();
      // Q12: preSendSms / preSmsIncludeLocation / preSmsMessage removed.
    });

    test('PhoneCallContactConfig hashCode stable', () {
      check(const PhoneCallContactConfig().hashCode)
          .equals(const PhoneCallContactConfig().hashCode);
    });

    test('LoudAlarmConfig identical', () {
      const c = LoudAlarmConfig();
      check(c == c).isTrue();
    });

    test('LoudAlarmConfig cross-type unequal', () {
      // ignore: unrelated_type_equality_checks
      check(const LoudAlarmConfig() == 'x').isFalse();
    });

    test('LoudAlarmConfig differ unequal', () {
      check(
        const LoudAlarmConfig() == const LoudAlarmConfig(flashScreen: true),
      ).isFalse();
      check(
        const LoudAlarmConfig() == const LoudAlarmConfig(flashSpeed: 1.0),
      ).isFalse();
      check(
        const LoudAlarmConfig() == const LoudAlarmConfig(maxVolume: false),
      ).isFalse();
      check(
        const LoudAlarmConfig() == const LoudAlarmConfig(volume: 0.5),
      ).isFalse();
      check(
        const LoudAlarmConfig() ==
            const LoudAlarmConfig(soundChoice: LoudAlarmSound.custom),
      ).isFalse();
      check(
        const LoudAlarmConfig() == const LoudAlarmConfig(gradualVolume: true),
      ).isFalse();
      check(
        const LoudAlarmConfig() == const LoudAlarmConfig(flashLight: false),
      ).isFalse();
      check(
        const LoudAlarmConfig() == const LoudAlarmConfig(flashSpeedMs: 1000),
      ).isFalse();
      check(
        const LoudAlarmConfig() == const LoudAlarmConfig(blackScreenMode: true),
      ).isFalse();
    });

    test('CallEmergencyConfig identical', () {
      const c = CallEmergencyConfig();
      check(c == c).isTrue();
    });

    test('CallEmergencyConfig cross-type unequal', () {
      // ignore: unrelated_type_equality_checks
      check(const CallEmergencyConfig() == 'x').isFalse();
    });

    test('CallEmergencyConfig differ unequal', () {
      check(
        const CallEmergencyConfig() ==
            const CallEmergencyConfig(emergencyNumber: '911'),
      ).isFalse();
      check(
        const CallEmergencyConfig() ==
            const CallEmergencyConfig(showConfirmation: false),
      ).isFalse();
      check(
        const CallEmergencyConfig() ==
            const CallEmergencyConfig(sendLocationSmsFirst: false),
      ).isFalse();
      check(
        const CallEmergencyConfig() ==
            const CallEmergencyConfig(confirmationDurationSeconds: 10),
      ).isFalse();
      check(
        const CallEmergencyConfig() ==
            const CallEmergencyConfig(blackScreenMode: true),
      ).isFalse();
    });

    test('CallEmergencyConfig hashCode stable', () {
      check(const CallEmergencyConfig().hashCode)
          .equals(const CallEmergencyConfig().hashCode);
    });
  });

  group('StepConfig null copyWith preserves every field', () {
    test('HoldButtonConfig', () {
      const c = HoldButtonConfig(releaseSensitivity: 0.7);
      check(c.copyWith()).equals(c);
    });

    test('DisguisedReminderConfig', () {
      const c = DisguisedReminderConfig(
        templateId: 't1',
        intervalSeconds: 15,
      );
      check(c.copyWith()).equals(c);
    });

    test('HardwareButtonConfig', () {
      const c = HardwareButtonConfig(
        buttonType: ButtonType.power,
        pattern: HardwarePattern.longPress,
        pressCount: 9,
        pressWindowMs: 200,
        longPressDurationSeconds: 4.0,
      );
      check(c.copyWith()).equals(c);
    });

    test('CountdownWarningConfig', () {
      const c = CountdownWarningConfig(vibrate: false, playTone: true);
      check(c.copyWith()).equals(c);
    });

    test('FakeCallConfig', () {
      const c = FakeCallConfig(
        callerName: 'X',
        ringtoneAsset: 'a',
        voiceRecordingAsset: 'v',
        declineIsSafe: false,
        callStyle: CallStyle.whatsapp,
        callerPhotoPath: 'p.png',
        voiceSource: VoiceSource.recording,
        voiceRoute: VoiceRoute.speaker,
        ringDurationSeconds: 20,
        declineWithDistressHoldSeconds: 1.5,
        blackScreenMode: true,
      );
      check(c.copyWith()).equals(c);
    });

    test('SmsContactConfig', () {
      const c = SmsContactConfig(
        contactIds: ['a'],
        contactSelection: SmsContactSelection.specificIds,
        channel: MessageChannel.telegram,
        includeLocation: false,
        includeMedicalInfo: true,
        autoRecordAudio: true,
        autoRecordVideo: true,
        recordDurationSeconds: 20,
        messageTemplate: 'hi',
        blackScreenMode: true,
      );
      check(c.copyWith()).equals(c);
    });

    test('PhoneCallContactConfig', () {
      const c = PhoneCallContactConfig(
        contactId: 'c1',
        alternativeContactIds: ['c2'],
      );
      check(c.copyWith()).equals(c);
    });

    test('LoudAlarmConfig', () {
      const c = LoudAlarmConfig(
        flashScreen: false,
        flashSpeed: 0.2,
        maxVolume: false,
      );
      check(c.copyWith()).equals(c);
    });

    test('CallEmergencyConfig', () {
      const c = CallEmergencyConfig(
        emergencyNumber: '999',
        showConfirmation: false,
        sendLocationSmsFirst: false,
        confirmationDurationSeconds: 12,
        blackScreenMode: true,
      );
      check(c.copyWith()).equals(c);
    });
  });
}
