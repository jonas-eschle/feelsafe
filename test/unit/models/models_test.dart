import 'package:flutter_test/flutter_test.dart';
import 'package:safewayhome/data/models/app_settings.dart';
import 'package:safewayhome/data/models/emergency_contact.dart';
import 'package:safewayhome/data/models/escalation_chain.dart';
import 'package:safewayhome/data/models/escalation_step.dart';
import 'package:safewayhome/data/models/fake_call_config.dart';
import 'package:safewayhome/data/models/reminder_template.dart';
import 'package:safewayhome/data/models/session_mode.dart';
import 'package:safewayhome/data/models/walk_session.dart';

void main() {
  group('AppSettings', () {
    test('has correct defaults', () {
      final settings = AppSettings();
      expect(settings.isDarkTheme, isTrue);
      expect(settings.languageCode, 'en');
      expect(settings.isFirstLaunch, isTrue);
      expect(settings.selectedModeId, isNull);
      expect(settings.emergencyNumber, '112');
    });

    test('copyWith preserves unchanged fields', () {
      final settings = AppSettings(languageCode: 'de', emergencyNumber: '911');
      final copy = settings.copyWith(isDarkTheme: false);
      expect(copy.isDarkTheme, isFalse);
      expect(copy.languageCode, 'de');
      expect(copy.emergencyNumber, '911');
    });

    test('copyWith overrides specified fields', () {
      final settings = AppSettings();
      final copy = settings.copyWith(
        isDarkTheme: false,
        languageCode: 'ru',
        isFirstLaunch: false,
        selectedModeId: 'walk_mode',
        emergencyNumber: '911',
      );
      expect(copy.isDarkTheme, isFalse);
      expect(copy.languageCode, 'ru');
      expect(copy.isFirstLaunch, isFalse);
      expect(copy.selectedModeId, 'walk_mode');
      expect(copy.emergencyNumber, '911');
    });
  });

  group('EmergencyContact', () {
    test('creates with required fields', () {
      final contact = EmergencyContact(
        id: 'c1',
        name: 'Alice',
        phoneNumber: '+49123456',
      );
      expect(contact.name, 'Alice');
      expect(contact.phoneNumber, '+49123456');
      expect(contact.relationship, isNull);
      expect(contact.sortOrder, 0);
      expect(contact.preferredChannel, MessageChannel.sms);
    });

    test('copyWith overrides specified fields', () {
      final contact = EmergencyContact(
        id: 'c1',
        name: 'Alice',
        phoneNumber: '+49123456',
      );
      final copy = contact.copyWith(
        name: 'Bob',
        preferredChannel: MessageChannel.whatsapp,
      );
      expect(copy.id, 'c1'); // id is immutable
      expect(copy.name, 'Bob');
      expect(copy.phoneNumber, '+49123456');
      expect(copy.preferredChannel, MessageChannel.whatsapp);
    });
  });

  group('EscalationStep', () {
    test('creates with required fields and default enabled', () {
      final step = EscalationStep(
        type: EscalationStepType.fakeCall,
        timeoutSeconds: 30,
        order: 1,
      );
      expect(step.type, EscalationStepType.fakeCall);
      expect(step.timeoutSeconds, 30);
      expect(step.enabled, isTrue);
      expect(step.order, 1);
      expect(step.timeout, const Duration(seconds: 30));
    });

    test('copyWith overrides specified fields', () {
      final step = EscalationStep(
        type: EscalationStepType.fakeCall,
        timeoutSeconds: 30,
        order: 1,
      );
      final copy = step.copyWith(enabled: false, timeoutSeconds: 60);
      expect(copy.type, EscalationStepType.fakeCall); // type is immutable
      expect(copy.enabled, isFalse);
      expect(copy.timeoutSeconds, 60);
      expect(copy.order, 1);
    });
  });

  group('EscalationChain', () {
    test('activeSteps returns only enabled steps sorted by order', () {
      final chain = EscalationChain(steps: [
        EscalationStep(
          type: EscalationStepType.fakeCall,
          timeoutSeconds: 30,
          order: 2,
        ),
        EscalationStep(
          type: EscalationStepType.loudAlarm,
          timeoutSeconds: 30,
          order: 1,
          enabled: false,
        ),
        EscalationStep(
          type: EscalationStepType.countdownWarning,
          timeoutSeconds: 10,
          order: 0,
        ),
      ]);

      final active = chain.activeSteps;
      expect(active.length, 2);
      expect(active[0].type, EscalationStepType.countdownWarning);
      expect(active[1].type, EscalationStepType.fakeCall);
    });

    test('walkDefaults has alarm disabled', () {
      final chain = EscalationChain.walkDefaults();
      expect(chain.steps.length, 5);

      final alarm = chain.steps.firstWhere(
        (s) => s.type == EscalationStepType.loudAlarm,
      );
      expect(alarm.enabled, isFalse);

      final active = chain.activeSteps;
      expect(active.length, 4); // 5 - 1 disabled alarm
      expect(
        active.map((s) => s.type).toList(),
        [
          EscalationStepType.countdownWarning,
          EscalationStepType.fakeCall,
          EscalationStepType.smsContacts,
          EscalationStepType.callEmergencyServices,
        ],
      );
    });

    test('dateDefaults has alarm disabled', () {
      final chain = EscalationChain.dateDefaults();
      expect(chain.steps.length, 5);

      final alarm = chain.steps.firstWhere(
        (s) => s.type == EscalationStepType.loudAlarm,
      );
      expect(alarm.enabled, isFalse);

      final active = chain.activeSteps;
      expect(active.length, 4);
      expect(active[0].type, EscalationStepType.disguisedReminder);
    });

    test('empty chain has no active steps', () {
      final chain = EscalationChain(steps: []);
      expect(chain.activeSteps, isEmpty);
    });
  });

  group('FakeCallConfig', () {
    test('has correct defaults', () {
      final config = FakeCallConfig();
      expect(config.callerName, 'Mom');
      expect(config.photoPath, isNull);
      expect(config.voiceRecordingPath, isNull);
      expect(config.ringDurationSeconds, 30);
      expect(config.ringDuration, const Duration(seconds: 30));
    });

    test('copyWith overrides specified fields', () {
      final config = FakeCallConfig();
      final copy = config.copyWith(
        callerName: 'Dad',
        ringDurationSeconds: 15,
      );
      expect(copy.callerName, 'Dad');
      expect(copy.ringDurationSeconds, 15);
    });
  });

  group('ReminderTemplate', () {
    test('creates with required fields', () {
      final template = ReminderTemplate(
        id: 'tpl_1',
        name: 'Test',
        title: 'Title',
        body: 'Body',
        confirmationType: ConfirmationType.tapButton,
      );
      expect(template.isCustom, isFalse);
      expect(template.keyword, isNull);
      expect(template.buttonLabel, isNull);
    });

    test('copyWith preserves id and isCustom', () {
      final template = ReminderTemplate(
        id: 'tpl_1',
        name: 'Test',
        title: 'Title',
        body: 'Body',
        confirmationType: ConfirmationType.tapButton,
        isCustom: true,
      );
      final copy = template.copyWith(name: 'Updated');
      expect(copy.id, 'tpl_1');
      expect(copy.isCustom, isTrue);
      expect(copy.name, 'Updated');
    });

    test('all confirmation types are distinct', () {
      expect(ConfirmationType.values.length, 4);
      expect(
        ConfirmationType.values.toSet().length,
        ConfirmationType.values.length,
      );
    });
  });

  group('SessionMode', () {
    test('creates with required fields', () {
      final mode = SessionMode(
        id: 'walk',
        name: 'Walk Mode',
        checkInMechanism: CheckInMechanism.holdButton,
        checkInIntervalSeconds: 10,
        escalationSteps: [],
      );
      expect(mode.isBuiltIn, isFalse);
      expect(mode.missedTolerance, 0);
      expect(mode.reminderTemplateIds, isEmpty);
      expect(mode.checkInInterval, const Duration(seconds: 10));
    });

    test('copyWith preserves id and isBuiltIn', () {
      final mode = SessionMode(
        id: 'walk',
        name: 'Walk Mode',
        checkInMechanism: CheckInMechanism.holdButton,
        checkInIntervalSeconds: 10,
        escalationSteps: [],
        isBuiltIn: true,
      );
      final copy = mode.copyWith(name: 'Fast Walk');
      expect(copy.id, 'walk');
      expect(copy.isBuiltIn, isTrue);
      expect(copy.name, 'Fast Walk');
    });

    test('checkInMechanism has two values', () {
      expect(CheckInMechanism.values.length, 2);
    });
  });

  group('WalkSession', () {
    test('creates with defaults', () {
      final session = WalkSession(
        startTime: DateTime(2026, 1, 1),
        modeId: 'walk_mode',
      );
      expect(session.state, SessionState.active);
      expect(session.currentEscalationIndex, -1);
      expect(session.lastCheckIn, isNull);
      expect(session.missedCheckIns, 0);
      expect(session.locationHistory, isEmpty);
    });

    test('copyWith overrides specified fields', () {
      final session = WalkSession(
        startTime: DateTime(2026, 1, 1),
        modeId: 'walk_mode',
      );
      final copy = session.copyWith(
        state: SessionState.warning,
        missedCheckIns: 3,
        currentEscalationIndex: 1,
      );
      expect(copy.state, SessionState.warning);
      expect(copy.missedCheckIns, 3);
      expect(copy.currentEscalationIndex, 1);
      expect(copy.startTime, session.startTime); // immutable
      expect(copy.modeId, 'walk_mode'); // immutable
    });

    test('all session states exist', () {
      expect(SessionState.values.length, 9);
    });
  });

  group('LocationPoint', () {
    test('generates correct maps URL', () {
      final point = LocationPoint(
        latitude: 52.52,
        longitude: 13.405,
        timestamp: DateTime(2026, 1, 1),
      );
      expect(point.toMapsUrl(), 'https://maps.google.com/?q=52.52,13.405');
    });
  });

  group('EscalationStepType', () {
    test('has all 6 types', () {
      expect(EscalationStepType.values.length, 6);
      expect(EscalationStepType.values, contains(EscalationStepType.countdownWarning));
      expect(EscalationStepType.values, contains(EscalationStepType.disguisedReminder));
      expect(EscalationStepType.values, contains(EscalationStepType.fakeCall));
      expect(EscalationStepType.values, contains(EscalationStepType.smsContacts));
      expect(EscalationStepType.values, contains(EscalationStepType.loudAlarm));
      expect(EscalationStepType.values, contains(EscalationStepType.callEmergencyServices));
    });
  });
}
