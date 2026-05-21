/// Repository + DB round-trip tests using an in-memory Drift database.
///
/// Exercises the full persistence path: write via repository →
/// JSON-serialize → Drift row → read back → JSON-deserialize →
/// reconstructed domain object.
library;

import 'package:checks/checks.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/app_database.dart';
import 'package:guardianangela/data/db/daos/battery_alert_dao.dart';
import 'package:guardianangela/data/db/daos/contacts_dao.dart';
import 'package:guardianangela/data/db/daos/modes_dao.dart';
import 'package:guardianangela/data/db/daos/session_logs_dao.dart';
import 'package:guardianangela/data/db/daos/settings_dao.dart';
import 'package:guardianangela/data/db/daos/templates_dao.dart';
import 'package:guardianangela/data/db/daos/user_profile_dao.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/data/repositories/battery_alert_repository.dart';
import 'package:guardianangela/data/repositories/contacts_repository.dart';
import 'package:guardianangela/data/repositories/modes_repository.dart';
import 'package:guardianangela/data/repositories/session_logs_repository.dart';
import 'package:guardianangela/data/repositories/settings_repository.dart';
import 'package:guardianangela/data/repositories/templates_repository.dart';
import 'package:guardianangela/data/repositories/user_profile_repository.dart';
import 'package:guardianangela/domain/models/models.dart';
import '../helpers/test_helpers.dart';

AppDatabase _makeDb() => AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  late AppDatabase db;

  setUp(() {
    db = _makeDb();
  });

  tearDown(() async {
    await db.close();
  });

  group('Modes round-trip', () {
    test('save and read back a simple mode', () async {
      final repo = ModesRepository(ModesDao(db));
      final mode = makeMode(
        id: 'my-mode',
        name: 'My Mode',
        steps: [holdStep()],
      );
      await repo.save(mode);
      final read = await repo.getById('my-mode');
      check(read).isNotNull();
      check(read!.id).equals('my-mode');
      check(read.name).equals('My Mode');
    });

    test('getAll returns all saved modes', () async {
      final repo = ModesRepository(ModesDao(db));
      await repo.saveAll([
        makeMode(id: 'a', name: 'A'),
        makeMode(id: 'b', name: 'B'),
        makeMode(id: 'c', name: 'C'),
      ]);
      final all = await repo.getAll();
      check(all.length).equals(3);
      check(all.map((m) => m.id).toSet()).deepEquals({'a', 'b', 'c'});
    });

    test('update via save overwrites existing row', () async {
      final repo = ModesRepository(ModesDao(db));
      await repo.save(makeMode(id: 'same', name: 'v1'));
      await repo.save(makeMode(id: 'same', name: 'v2'));
      final read = await repo.getById('same');
      check(read!.name).equals('v2');
    });

    test('delete removes the row', () async {
      final repo = ModesRepository(ModesDao(db));
      await repo.save(makeMode(id: 'del'));
      await repo.delete('del');
      check(await repo.getById('del')).isNull();
    });

    test('deleteAll wipes everything', () async {
      final repo = ModesRepository(ModesDao(db));
      await repo.saveAll([makeMode(id: 'a'), makeMode(id: 'b')]);
      await repo.deleteAll();
      check(await repo.getAll()).isEmpty();
    });
  });

  group('Contacts round-trip', () {
    test('save / get / delete contact', () async {
      final repo = ContactsRepository(ContactsDao(db));
      final c = makeContact(id: 'x', name: 'Xena');
      await repo.save(c);
      final read = await repo.getById('x');
      check(read!.name).equals('Xena');
      await repo.delete('x');
      check(await repo.getById('x')).isNull();
    });
  });

  group('Distress modes round-trip (Phase 2.5: in modes table)', () {
    test(
      'distress-flagged mode round-trips with isDistressMode=true',
      () async {
        final repo = ModesRepository(ModesDao(db));
        final mode = makeDistressMode(id: 'd1', steps: [smsStep(order: 0)]);
        await repo.save(mode);
        final read = await repo.getById('d1');
        check(read!.chainSteps.length).equals(1);
        check(read.isDistressMode).isTrue();
      },
    );

    test('multi-step distress mode round-trips', () async {
      final repo = ModesRepository(ModesDao(db));
      final mode = makeDistressMode(
        id: 'big',
        name: 'Big',
        steps: [
          smsStep(order: 0),
          step(type: ChainStepType.loudAlarm, order: 1, durationSeconds: 5),
          step(type: ChainStepType.callEmergency, order: 2, durationSeconds: 5),
        ],
      );
      await repo.save(mode);
      final read = await repo.getById('big');
      check(read!.chainSteps.length).equals(3);
      check(read.chainSteps[2].type).equals(ChainStepType.callEmergency);
    });
  });

  group('Session logs round-trip', () {
    test('preserves event order', () async {
      final repo = SessionLogsRepository(SessionLogsDao(db));
      final now = DateTime.utc(2026, 4, 20);
      final log = SessionLog(
        id: 'log-1',
        modeId: 'mode-1',
        modeName: 'Walk',
        startedAt: now,
        isSimulation: false,
        events: [
          SessionLogEvent(event: ChainEvent.sessionStarted, timestamp: now),
          SessionLogEvent(
            event: ChainEvent.stepStarted,
            timestamp: now.add(const Duration(seconds: 1)),
            stepIndex: 0,
            stepType: ChainStepType.holdButton,
          ),
          SessionLogEvent(
            event: ChainEvent.sessionEnded,
            timestamp: now.add(const Duration(seconds: 2)),
          ),
        ],
      );
      await repo.save(log);
      final read = await repo.getById('log-1');
      check(read).isNotNull();
      check(read!.events.length).equals(3);
      check(read.events.first.event).equals(ChainEvent.sessionStarted);
      check(read.events.last.event).equals(ChainEvent.sessionEnded);
    });
  });

  group('Settings + profile round-trip', () {
    test('AppSettings round-trip through settings repo', () async {
      final repo = SettingsRepository(SettingsDao(db));
      const s = AppSettings(
        defaults: AppDefaults(),
        emergencyCallNumber: '911',
        pinTimeoutSeconds: 20,
      );
      await repo.save(s);
      final read = await repo.get();
      check(read!.emergencyCallNumber).equals('911');
      check(read.pinTimeoutSeconds).equals(20);
    });

    test('UserProfile round-trip', () async {
      final repo = UserProfileRepository(UserProfileDao(db));
      const profile = UserProfile(
        name: 'Alice',
        allergies: 'penicillin',
        medications: 'metformin',
      );
      await repo.save(profile);
      final read = await repo.get();
      check(read).isNotNull();
      check(read!.name).equals('Alice');
      check(read.allergies).equals('penicillin');
      check(read.medications).equals('metformin');
    });
  });

  group('Templates + battery alert round-trip', () {
    test('reminder template persistence', () async {
      final repo = TemplatesRepository(TemplatesDao(db));
      const t = ReminderTemplate(
        id: 'tmpl-1',
        name: 'Test',
        title: 'Did you check?',
        body: 'Please confirm you are safe.',
        confirmationType: ConfirmationType.tapButton,
        displayStyle: ReminderDisplayStyle.subtle,
        isGlobal: true,
      );
      await repo.save(t);
      final read = await repo.getById('tmpl-1');
      check(read).isNotNull();
      check(read!.name).equals('Test');
    });

    test('battery alert config round-trip', () async {
      final repo = BatteryAlertRepository(BatteryAlertDao(db));
      final cfg = BatteryAlertConfig(
        enabled: true,
        thresholdPercent: 15,
        chain: [smsStep(order: 0)],
      );
      await repo.save(cfg);
      final read = await repo.get();
      check(read).isNotNull();
      check(read!.enabled).isTrue();
      check(read.thresholdPercent).equals(15);
      check(read.chain.length).equals(1);
    });
  });
}
