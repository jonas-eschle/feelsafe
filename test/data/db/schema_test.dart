/// Schema-level smoke tests: the in-memory db must compile all
/// tables, expose the expected DAOs, and report the documented
/// schema version.
library;

import 'package:checks/checks.dart';
import 'package:drift/drift.dart' show QueryRow;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/app_database.dart';
import 'dao_test_support.dart';

void main() {
  setUpAll(overrideSqliteOpen);

  late AppDatabase db;

  setUp(() {
    db = makeMemoryDb();
  });

  tearDown(() async {
    await db.close();
  });

  test('schema version is 1', () {
    check(db.schemaVersion).equals(1);
  });

  test('dbFileName is the documented value', () {
    check(AppDatabase.dbFileName).equals('guardian_angela.sqlite');
  });

  test('table accessors compile + return empty on a fresh db', () async {
    // Each `.select().get()` forces schema creation — if a table
    // name / column is missing the driver would throw here.
    check(await db.select(db.modesTable).get()).isEmpty();
    check(await db.select(db.contactsTable).get()).isEmpty();
    check(await db.select(db.templatesTable).get()).isEmpty();
    check(await db.select(db.distressChainsTable).get()).isEmpty();
    check(await db.select(db.sessionLogsTable).get()).isEmpty();
    check(await db.select(db.settingsTable).get()).isEmpty();
    check(await db.select(db.userProfileTable).get()).isEmpty();
    check(await db.select(db.batteryAlertTable).get()).isEmpty();
  });

  test('all 8 expected tables exist in sqlite_master', () async {
    final rows = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table'",
        )
        .get();
    final names = rows.map((QueryRow r) => r.read<String>('name')).toSet();
    check(names.containsAll({
      'modes',
      'contacts',
      'templates',
      'distress_chains',
      'session_logs',
      'settings',
      'user_profile',
      'battery_alert',
    })).isTrue();
  });
}
