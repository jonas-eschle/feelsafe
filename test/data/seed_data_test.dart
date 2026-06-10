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
      check(hold.waitSeconds).equals(0);
      check(hold.durationSeconds).equals(10);
      check(hold.gracePeriodSeconds).equals(1);
      check(hold.retryCount).equals(0);
    });

    test('fakeCall step has 30s duration / 5s grace per spec', () {
      final fc = walk.chainSteps[1];
      check(fc.waitSeconds).equals(0);
      check(fc.durationSeconds).equals(30);
      check(fc.gracePeriodSeconds).equals(5);
      check(fc.retryCount).equals(0);
    });

    test('smsContact step has 15s duration / 5s grace per spec', () {
      final sms = walk.chainSteps[2];
      check(sms.waitSeconds).equals(0);
      check(sms.durationSeconds).equals(15);
      check(sms.gracePeriodSeconds).equals(5);
      check(sms.retryCount).equals(0);
    });

    test('phoneCallContact step has 60s duration / 5s grace per spec', () {
      final phone = walk.chainSteps[3];
      check(phone.waitSeconds).equals(0);
      check(phone.durationSeconds).equals(60);
      check(phone.gracePeriodSeconds).equals(5);
      check(phone.retryCount).equals(0);
    });

    test('callEmergency step has 5s duration / 0s grace per spec', () {
      final ce = walk.chainSteps[4];
      check(ce.waitSeconds).equals(0);
      check(ce.durationSeconds).equals(5);
      check(ce.gracePeriodSeconds).equals(0);
      check(ce.retryCount).equals(0);
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

    test('fakeCall step has 30s duration / 5s grace per spec', () {
      final fc = date.chainSteps[1];
      check(fc.waitSeconds).equals(0);
      check(fc.durationSeconds).equals(30);
      check(fc.gracePeriodSeconds).equals(5);
      check(fc.retryCount).equals(0);
    });

    test('smsContact step has 15s duration / 5s grace per spec', () {
      final sms = date.chainSteps[2];
      check(sms.waitSeconds).equals(0);
      check(sms.durationSeconds).equals(15);
      check(sms.gracePeriodSeconds).equals(5);
      check(sms.retryCount).equals(0);
    });

    test('phoneCallContact step has 60s duration / 5s grace per spec', () {
      final phone = date.chainSteps[3];
      check(phone.waitSeconds).equals(0);
      check(phone.durationSeconds).equals(60);
      check(phone.gracePeriodSeconds).equals(5);
      check(phone.retryCount).equals(0);
    });

    test('callEmergency step has 10s duration per spec', () {
      final ce = date.chainSteps[4];
      check(ce.waitSeconds).equals(0);
      check(ce.durationSeconds).equals(10);
      check(ce.gracePeriodSeconds).equals(0);
      check(ce.retryCount).equals(0);
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

    test('step 0 SMS includes location per spec', () {
      // Spec 03 §Default Distress Mode (line 1312):
      // "includeLocation=true" is mandated.
      final config = distress.chainSteps[0].config! as SmsContactConfig;
      check(config.includeLocation).isTrue();
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

    test('step 1 has sendLocationSmsFirst=true per spec', () {
      // Spec 03 §Default Distress Mode (line 1320):
      // "sendLocationSmsFirst=true" is mandated.
      final config = distress.chainSteps[1].config! as CallEmergencyConfig;
      check(config.sendLocationSmsFirst).isTrue();
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

    test('all 8 templates have exact spec-table title/body strings', () {
      // Spec 03 §Eight Built-in Reminder Templates table (line 1334).
      // The verifier flagged that prior tests checked only structural
      // fields; this test asserts every wording cell so any copy edit
      // breaks the suite (also catches future ARB drift).
      final expected = <String, ({String title, String body})>{
        'Calendar Event': (
          title: 'You have an appointment',
          body: 'Meeting with Alex at 3 PM',
        ),
        'Duolingo Lesson': (
          title: 'Time for your lesson!',
          body: 'Keep your 50-day streak going',
        ),
        'Delivery Update': (
          title: 'Your package arrived',
          body: 'Check the front porch',
        ),
        'Weather Alert': (title: 'Rainy tomorrow', body: 'Bring an umbrella'),
        'Fitness Reminder': (
          title: 'Time to exercise',
          body: 'Your workout is due',
        ),
        'Message Preview': (
          title: 'New message from Sarah',
          body: '"Hey, what\'s up?"',
        ),
        'App Update': (title: 'Updates available', body: 'Tap to install'),
        'Battery Warning': (title: 'Battery low', body: 'Plug in soon'),
      };
      for (final entry in expected.entries) {
        final t = templates.firstWhere((t) => t.name == entry.key);
        check(t.title, because: '${entry.key} title').equals(entry.value.title);
        check(t.body, because: '${entry.key} body').equals(entry.value.body);
      }
    });

    test('tapButton templates ship with a non-empty buttonLabel', () {
      // Spec 03 §Eight Built-in Reminder Templates row table is silent
      // on label text, but `tapButton` semantically requires one. The
      // seed picks plausible defaults — if a future refactor drops the
      // label, the corresponding template becomes unusable in the
      // disguised reminder UI.
      final tapButtonTemplates = templates.where(
        (t) => t.confirmationType == ConfirmationType.tapButton,
      );
      check(tapButtonTemplates).isNotEmpty();
      for (final t in tapButtonTemplates) {
        check(
          t.buttonLabel,
          because: '${t.name} (tapButton) needs a buttonLabel',
        ).isNotNull();
        check(
          t.buttonLabel!.isNotEmpty,
          because: '${t.name} buttonLabel is empty',
        ).isTrue();
      }
    });
  });

  group('SeedData.defaultAppSettings', () {
    test('wires defaultDistressModeId to the seeded distress mode id', () {
      final settings = SeedData.defaultAppSettings();
      check(
        settings.defaults.defaultDistressModeId,
      ).equals(SeedData.defaultDistressModeId);
    });

    test('carries NO templates — the Drift DAO seeded by seedInto is the '
        'single template store (bug #14)', () {
      final settings = SeedData.defaultAppSettings();
      // The JSON settings blob must not duplicate the template store; a
      // second copy diverges on the first user edit.
      check(settings.defaults.toJson().containsKey('templates')).isFalse();
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
}
