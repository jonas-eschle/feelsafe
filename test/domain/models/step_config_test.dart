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
      check(c.callerName).equals('Mom');
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

    test('round-trip', () {
      const c = CallEmergencyConfig(
        emergencyNumber: '911',
        confirmBeforeCalling: true,
      );
      check(StepConfig.fromJson(c.toJson())).equals(c);
    });
  });
}
