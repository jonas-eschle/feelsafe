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
      check(c.releaseSensitivity).equals(0.3);
    });

    test('copyWith', () {
      const c = HoldButtonConfig();
      check(c.copyWith(releaseSensitivity: 0.5).releaseSensitivity).equals(0.5);
    });

    test('toJson discriminator', () {
      check(const HoldButtonConfig().toJson()['type']).equals('holdButton');
    });

    test('round-trip', () {
      const c = HoldButtonConfig(releaseSensitivity: 0.9);
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
      // Default changed from "Mom" to "Angela" per fixer brief item #4
      // (Guardian Angela product brand + "Ask for Angela" safety
      // campaign).
      check(c.callerName).equals('Angela');
      check(c.ringtoneAsset).isNull();
      check(c.voiceRecordingAsset).isNull();
      check(c.declineIsSafe).isFalse();
      check(c.retryCount).equals(0);
    });

    test('copyWith', () {
      const c = FakeCallConfig();
      final c2 = c.copyWith(callerName: 'Dad', retryCount: 3);
      check(c2.callerName).equals('Dad');
      check(c2.retryCount).equals(3);
    });

    test('round-trip', () {
      const c = FakeCallConfig(
        callerName: 'Dad',
        ringtoneAsset: 'a.mp3',
        voiceRecordingAsset: 'v.mp3',
        declineIsSafe: true,
        retryCount: 2,
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
      check(c.preSendSms).isFalse();
      check(c.preSmsIncludeLocation).isTrue();
      check(c.preSmsMessage).isNull();
    });

    test('copyWith', () {
      const c = PhoneCallContactConfig();
      final c2 = c.copyWith(
        contactId: 'c1',
        alternativeContactIds: const ['c2'],
        preSendSms: true,
      );
      check(c2.contactId).equals('c1');
      check(c2.alternativeContactIds).deepEquals(['c2']);
      check(c2.preSendSms).isTrue();
    });

    test('round-trip with alternatives', () {
      const c = PhoneCallContactConfig(
        contactId: 'c1',
        alternativeContactIds: ['c2', 'c3'],
        preSendSms: true,
        preSmsIncludeLocation: false,
        preSmsMessage: 'hey',
      );
      check(StepConfig.fromJson(c.toJson())).equals(c);
    });
  });

  group('LoudAlarmConfig', () {
    test('defaults', () {
      const c = LoudAlarmConfig();
      check(c.flashScreen).isTrue();
      check(c.flashSpeed).equals(0.5);
      check(c.maxVolume).isTrue();
    });

    test('copyWith', () {
      const c = LoudAlarmConfig();
      final c2 = c.copyWith(
        flashScreen: false,
        flashSpeed: 0.1,
        maxVolume: false,
      );
      check(c2.flashScreen).isFalse();
      check(c2.flashSpeed).equals(0.1);
      check(c2.maxVolume).isFalse();
    });

    test('round-trip', () {
      const c = LoudAlarmConfig(flashScreen: false, flashSpeed: 1.0);
      check(StepConfig.fromJson(c.toJson())).equals(c);
    });
  });

  group('CallEmergencyConfig', () {
    test('defaults', () {
      const c = CallEmergencyConfig();
      check(c.emergencyNumber).isNull();
      check(c.confirmBeforeCalling).isFalse();
    });

    test('copyWith', () {
      const c = CallEmergencyConfig();
      final c2 = c.copyWith(emergencyNumber: '999', confirmBeforeCalling: true);
      check(c2.emergencyNumber).equals('999');
      check(c2.confirmBeforeCalling).isTrue();
    });

    test('copyWith clearEmergencyNumber', () {
      const c = CallEmergencyConfig(emergencyNumber: '999');
      final c2 = c.copyWith(clearEmergencyNumber: true);
      check(c2.emergencyNumber).isNull();
    });

    test('round-trip', () {
      const c = CallEmergencyConfig(
        emergencyNumber: '911',
        confirmBeforeCalling: true,
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
        declineIsSafe: true,
        retryCount: 2,
      ).toString();
      check(str).contains('Dad');
      check(str).contains('a.mp3');
      check(str).contains('v.mp3');
      check(str).contains('declineIsSafe: true');
      check(str).contains('retryCount: 2');
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
        preSendSms: true,
      ).toString();
      check(str).contains('c1');
      check(str).contains('[c2]');
      check(str).contains('preSendSms: true');
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
        confirmBeforeCalling: true,
      ).toString();
      check(str).contains('911');
      check(str).contains('confirmBeforeCalling: true');
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
        const FakeCallConfig() == const FakeCallConfig(declineIsSafe: true),
      ).isFalse();
      check(
        const FakeCallConfig() == const FakeCallConfig(retryCount: 1),
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
      check(
        const PhoneCallContactConfig() ==
            const PhoneCallContactConfig(preSendSms: true),
      ).isFalse();
      check(
        const PhoneCallContactConfig() ==
            const PhoneCallContactConfig(preSmsIncludeLocation: false),
      ).isFalse();
      check(
        const PhoneCallContactConfig() ==
            const PhoneCallContactConfig(preSmsMessage: 'x'),
      ).isFalse();
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
        const LoudAlarmConfig() == const LoudAlarmConfig(flashScreen: false),
      ).isFalse();
      check(
        const LoudAlarmConfig() == const LoudAlarmConfig(flashSpeed: 1.0),
      ).isFalse();
      check(
        const LoudAlarmConfig() == const LoudAlarmConfig(maxVolume: false),
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
            const CallEmergencyConfig(confirmBeforeCalling: true),
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
        declineIsSafe: true,
        retryCount: 3,
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
        preSendSms: true,
        preSmsIncludeLocation: false,
        preSmsMessage: 'x',
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
        confirmBeforeCalling: true,
      );
      check(c.copyWith()).equals(c);
    });
  });
}
