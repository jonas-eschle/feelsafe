import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/seed_data.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/enums/sms_contact_selection.dart';

void main() {
  group('SeedData.walkMode', () {
    final walk = SeedData.walkMode();

    test('has stable id walk_mode_seed', () {
      check(walk.id).equals(SeedData.walkModeId);
    });

    test('has 5 chain steps in the spec 03 §Walk Mode order', () {
      // Arrange/Act
      final types = walk.chainSteps.map((s) => s.type).toList();
      // Assert — exact step types per spec 03 §Walk Mode.
      check(types).deepEquals([
        ChainStepType.holdButton,
        ChainStepType.fakeCall,
        ChainStepType.smsContact,
        ChainStepType.phoneCallContact,
        ChainStepType.callEmergency,
      ]);
    });

    test('holdButton step has 10s duration / 1s grace per spec', () {
      final hold = walk.chainSteps[0];
      check(hold.durationSeconds).equals(10);
      check(hold.gracePeriodSeconds).equals(1);
      check(hold.retryCount).equals(0);
    });

    test('fakeCall step has 30s duration / 5s grace per spec', () {
      final fc = walk.chainSteps[1];
      check(fc.durationSeconds).equals(30);
      check(fc.gracePeriodSeconds).equals(5);
      check(fc.retryCount).equals(0);
    });

    test('callEmergency step has 5s duration / 0s grace per spec', () {
      final ce = walk.chainSteps[4];
      check(ce.durationSeconds).equals(5);
      check(ce.gracePeriodSeconds).equals(0);
    });

    test('is not a distress mode', () {
      check(walk.isDistressMode).isFalse();
    });
  });

  group('SeedData.dateMode', () {
    final date = SeedData.dateMode();

    test('has stable id date_mode_seed', () {
      check(date.id).equals(SeedData.dateModeId);
    });

    test('has 5 chain steps in the spec 03 §Date Mode order', () {
      check(date.chainSteps.map((s) => s.type).toList()).deepEquals([
        ChainStepType.disguisedReminder,
        ChainStepType.fakeCall,
        ChainStepType.smsContact,
        ChainStepType.phoneCallContact,
        ChainStepType.callEmergency,
      ]);
    });

    test(
      'disguisedReminder step has 30-min interval / 2 total attempts (B2)',
      () {
        final reminder = date.chainSteps[0];
        check(reminder.waitSeconds).equals(1800);
        check(reminder.durationSeconds).equals(60);
        check(reminder.gracePeriodSeconds).equals(120);
        // B2: retryCount=1 → 2 total attempts.
        check(reminder.retryCount).equals(1);
      },
    );

    test('callEmergency step has 10s duration per spec', () {
      final ce = date.chainSteps[4];
      check(ce.durationSeconds).equals(10);
      check(ce.gracePeriodSeconds).equals(0);
    });
  });

  group('SeedData.defaultDistressMode', () {
    final distress = SeedData.defaultDistressMode();

    test('has stable id default_distress_seed', () {
      check(distress.id).equals(SeedData.defaultDistressModeId);
    });

    test('isDistressMode = true', () {
      check(distress.isDistressMode).isTrue();
    });

    test('has 2 chain steps per spec 03 §Default Distress Mode', () {
      check(distress.chainSteps.length).equals(2);
      check(distress.chainSteps[0].type).equals(ChainStepType.smsContact);
      check(distress.chainSteps[1].type).equals(ChainStepType.callEmergency);
    });

    test('step 0 uses contactSelection=firstContact (ITEM 6)', () {
      final sms = distress.chainSteps[0];
      final config = sms.config;
      check(config).isA<SmsContactConfig>();
      final sc = config! as SmsContactConfig;
      check(sc.contactSelection).equals(SmsContactSelection.firstContact);
    });

    test('step 1 waits 10s before calling emergency (ITEM 6)', () {
      final ce = distress.chainSteps[1];
      check(ce.waitSeconds).equals(10);
      check(ce.durationSeconds).equals(5);
    });

    test('step 1 has showConfirmation=false (no countdown in distress)', () {
      final config = distress.chainSteps[1].config;
      check(config).isA<CallEmergencyConfig>();
      final cc = config! as CallEmergencyConfig;
      check(cc.showConfirmation).isFalse();
    });
  });

  group('SeedData.reminderTemplates', () {
    final templates = SeedData.reminderTemplates();

    test('returns exactly 8 templates', () {
      check(templates.length).equals(8);
    });

    test('all built-in templates have isCustom=false and isGlobal=true', () {
      for (final t in templates) {
        check(t.isCustom).isFalse();
        check(t.isGlobal).isTrue();
      }
    });

    test('contains the 8 spec-named templates', () {
      final names = templates.map((t) => t.name).toSet();
      check(names).deepEquals({
        'Calendar Event',
        'Duolingo Lesson',
        'Delivery Update',
        'Weather Alert',
        'Fitness Reminder',
        'Message Preview',
        'App Update',
        'Battery Warning',
      });
    });

    test('all template ids are unique', () {
      final ids = templates.map((t) => t.id).toList();
      check(ids.toSet().length).equals(ids.length);
    });

    test('Duolingo Lesson uses tapWord with STREAK keyword per spec', () {
      final duo = templates.firstWhere((t) => t.name == 'Duolingo Lesson');
      check(duo.confirmationType).equals(ConfirmationType.tapWord);
      check(duo.keyword).equals('STREAK');
      check(duo.displayStyle).equals(ReminderDisplayStyle.subtle);
    });

    test('Calendar Event uses tapButton with fullScreen per spec', () {
      final cal = templates.firstWhere((t) => t.name == 'Calendar Event');
      check(cal.confirmationType).equals(ConfirmationType.tapButton);
      check(cal.displayStyle).equals(ReminderDisplayStyle.fullScreen);
    });

    test('Weather Alert uses dismiss confirmation per spec', () {
      final w = templates.firstWhere((t) => t.name == 'Weather Alert');
      check(w.confirmationType).equals(ConfirmationType.dismiss);
    });
  });

  group('SeedData.defaultAppSettings', () {
    test('wires defaultDistressModeId to the seeded distress mode id', () {
      final settings = SeedData.defaultAppSettings();
      check(
        settings.defaults.defaultDistressModeId,
      ).equals(SeedData.defaultDistressModeId);
    });

    test('embeds all 8 reminder templates', () {
      final settings = SeedData.defaultAppSettings();
      check(settings.defaults.templates.length).equals(8);
    });

    test('accepts an override for the distress mode id', () {
      final settings = SeedData.defaultAppSettings(
        seedDistressModeId: 'custom-distress',
      );
      check(settings.defaults.defaultDistressModeId).equals('custom-distress');
    });
  });

  group('SeedData.defaultUserProfile', () {
    test('returns an empty profile', () {
      final profile = SeedData.defaultUserProfile();
      check(profile.name).isNull();
      check(profile.age).isNull();
      check(profile.phoneNumber).isNull();
      check(profile.hasMedicalInfo).isFalse();
    });
  });

  group('SeedData.defaultBatteryAlertConfig', () {
    final config = SeedData.defaultBatteryAlertConfig();

    test('is disabled by default (Q22)', () {
      check(config.enabled).isFalse();
    });

    test('uses 10% threshold per spec', () {
      check(config.thresholdPercent).equals(10);
    });

    test('chain contains a single smsContact step', () {
      check(config.chain.length).equals(1);
      check(config.chain.single.type).equals(ChainStepType.smsContact);
    });
  });
}
