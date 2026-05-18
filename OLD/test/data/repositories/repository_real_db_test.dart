/// Tests for the real DAO-backed repositories using an in-memory Drift
/// database. Covers the delegate methods (`getAll`, `getById`, `save`,
/// `delete`, `deleteAll`) that are not reached by fake-repository tests.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/app_database.dart';
import 'package:guardianangela/data/db/daos/contacts_dao.dart';
import 'package:guardianangela/data/db/daos/session_logs_dao.dart';
import 'package:guardianangela/data/db/daos/templates_dao.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/data/repositories/contacts_repository.dart';
import 'package:guardianangela/data/repositories/session_logs_repository.dart';
import 'package:guardianangela/data/repositories/templates_repository.dart';
import 'package:guardianangela/domain/models/models.dart';
import '../db/dao_test_support.dart';

/// Builds a [ContactsRepository] backed by [db].
ContactsRepository _contactsRepo(AppDatabase db) =>
    ContactsRepository(ContactsDao(db));

/// Builds a [TemplatesRepository] backed by [db].
TemplatesRepository _templatesRepo(AppDatabase db) =>
    TemplatesRepository(TemplatesDao(db));

/// Builds a [SessionLogsRepository] backed by [db].
SessionLogsRepository _logsRepo(AppDatabase db) =>
    SessionLogsRepository(SessionLogsDao(db));

EmergencyContact _contact(String id, {String name = 'Alice'}) =>
    EmergencyContact(
      id: id,
      name: name,
      phoneNumber: '+15551234',
      sortOrder: 0,
      channels: const [MessageChannel.sms],
    );

ReminderTemplate _template(String id, {bool isGlobal = true}) =>
    ReminderTemplate(
      id: id,
      name: 'Template $id',
      title: 'T-$id',
      body: 'Body $id',
      confirmationType: ConfirmationType.tapButton,
      displayStyle: ReminderDisplayStyle.subtle,
      isGlobal: isGlobal,
    );

SessionLog _log(String id) => SessionLog(
  id: id,
  modeId: 'mode-1',
  modeName: 'Walk',
  startedAt: DateTime.utc(2024, 1, 1),
  isSimulation: false,
  events: const [],
);

void main() {
  setUpAll(overrideSqliteOpen);

  late AppDatabase db;

  setUp(() => db = makeMemoryDb());
  tearDown(() => db.close());

  // -------------------------------------------------------------------------
  // ContactsRepository
  // -------------------------------------------------------------------------
  group('ContactsRepository (real DB)', () {
    test('getAll returns empty list when nothing saved', () async {
      final repo = _contactsRepo(db);
      check(await repo.getAll()).isEmpty();
    });

    test('save + getAll returns the saved contact', () async {
      final repo = _contactsRepo(db);
      await repo.save(_contact('c1', name: 'Bob'));
      final all = await repo.getAll();
      check(all.length).equals(1);
      check(all.first.name).equals('Bob');
    });

    test('getById returns null when id is missing', () async {
      final repo = _contactsRepo(db);
      check(await repo.getById('missing')).isNull();
    });

    test('delete removes a specific contact', () async {
      final repo = _contactsRepo(db);
      await repo.save(_contact('c1'));
      await repo.save(_contact('c2', name: 'Carol'));
      await repo.delete('c1');
      final all = await repo.getAll();
      check(all.map((c) => c.id).toList()).not((it) => it.contains('c1'));
      check(all.any((c) => c.id == 'c2')).isTrue();
    });

    test('deleteAll wipes every contact', () async {
      final repo = _contactsRepo(db);
      await repo.save(_contact('c1'));
      await repo.save(_contact('c2', name: 'Carol'));
      await repo.deleteAll();
      check(await repo.getAll()).isEmpty();
    });
  });

  // -------------------------------------------------------------------------
  // TemplatesRepository
  // -------------------------------------------------------------------------
  group('TemplatesRepository (real DB)', () {
    test('getAll returns empty list initially', () async {
      final repo = _templatesRepo(db);
      check(await repo.getAll()).isEmpty();
    });

    test('save + getAll returns saved template', () async {
      final repo = _templatesRepo(db);
      await repo.save(_template('t1'));
      final all = await repo.getAll();
      check(all.length).equals(1);
      check(all.first.id).equals('t1');
    });

    test('getAllGlobal filters by isGlobal=true', () async {
      final repo = _templatesRepo(db);
      await repo.save(_template('t1', isGlobal: true));
      await repo.save(_template('t2', isGlobal: false));
      final globals = await repo.getAllGlobal();
      check(globals.length).equals(1);
      check(globals.first.id).equals('t1');
    });

    test('getById returns null for missing id', () async {
      final repo = _templatesRepo(db);
      check(await repo.getById('nope')).isNull();
    });

    test('delete removes only the targeted template', () async {
      final repo = _templatesRepo(db);
      await repo.save(_template('t1'));
      await repo.save(_template('t2', isGlobal: false));
      await repo.delete('t1');
      final all = await repo.getAll();
      check(all.map((t) => t.id).toList()).not((it) => it.contains('t1'));
    });

    test('deleteAll empties the table', () async {
      final repo = _templatesRepo(db);
      await repo.save(_template('t1'));
      await repo.deleteAll();
      check(await repo.getAll()).isEmpty();
    });
  });

  // -------------------------------------------------------------------------
  // SessionLogsRepository
  // -------------------------------------------------------------------------
  group('SessionLogsRepository (real DB)', () {
    test('getAll returns empty list initially', () async {
      final repo = _logsRepo(db);
      check(await repo.getAll()).isEmpty();
    });

    test('save + getAll returns saved log', () async {
      final repo = _logsRepo(db);
      await repo.save(_log('l1'));
      final all = await repo.getAll();
      check(all.length).equals(1);
      check(all.first.id).equals('l1');
    });

    test('getById returns null for missing id', () async {
      final repo = _logsRepo(db);
      check(await repo.getById('ghost')).isNull();
    });

    test('delete removes the targeted log', () async {
      final repo = _logsRepo(db);
      await repo.save(_log('l1'));
      await repo.save(_log('l2'));
      await repo.delete('l1');
      final all = await repo.getAll();
      check(all.map((l) => l.id).toList()).not((it) => it.contains('l1'));
    });

    test('deleteAll wipes all logs', () async {
      final repo = _logsRepo(db);
      await repo.save(_log('l1'));
      await repo.save(_log('l2'));
      await repo.deleteAll();
      check(await repo.getAll()).isEmpty();
    });
  });
}
