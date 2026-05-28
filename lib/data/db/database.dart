import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:guardianangela/data/db/dao/contacts_dao.dart';
import 'package:guardianangela/data/db/dao/reminder_templates_dao.dart';
import 'package:guardianangela/data/db/dao/session_logs_dao.dart';
import 'package:guardianangela/data/db/dao/session_modes_dao.dart';
import 'package:guardianangela/data/db/dao/sms_retry_jobs_dao.dart';
import 'package:guardianangela/data/db/tables/contacts_table.dart';
import 'package:guardianangela/data/db/tables/reminder_templates_table.dart';
import 'package:guardianangela/data/db/tables/session_logs_table.dart';
import 'package:guardianangela/data/db/tables/session_modes_table.dart';
import 'package:guardianangela/data/db/tables/sms_retry_jobs_table.dart';
import 'package:guardianangela/data/seed_data.dart';

part 'database.g.dart';

/// Callback invoked by [GuardianAngelaDatabase] after schema creation (or
/// after a nuke-and-reseed migration) to populate seed data.
///
/// Defaults to `SeedData.seedInto`; tests inject a no-op to keep the
/// database empty.
typedef SeedCallback = Future<void> Function(GuardianAngelaDatabase db);

/// The Guardian Angela Drift database.
///
/// Backed by `sqlite3mc` for at-rest AES-256 encryption (see spec 03
/// §Storage Architecture). Schema version is bumped only via a
/// nuke-and-reseed migration — pre-alpha policy forbids true schema
/// migrations (see `docs/rewrite/lessons-learned.md` §4.10).
@DriftDatabase(
  tables: [
    Contacts,
    ReminderTemplates,
    SessionModes,
    SessionLogs,
    SmsRetryJobs,
  ],
  daos: [
    ContactsDao,
    ReminderTemplatesDao,
    SessionModesDao,
    SessionLogsDao,
    SmsRetryJobsDao,
  ],
)
class GuardianAngelaDatabase extends _$GuardianAngelaDatabase {
  /// Wraps [executor] with the standard nuke-and-reseed migration strategy.
  ///
  /// [seedCallback] runs on initial creation and after every nuke-and-reseed
  /// upgrade. Defaults to [SeedData.seedInto].
  GuardianAngelaDatabase(super.executor, {SeedCallback? seedCallback})
    : _seed = seedCallback ?? SeedData.seedInto;

  /// Constructs an in-memory database for tests.
  ///
  /// Pass `seedCallback: (_) async {}` to skip seeding when individual
  /// tests want to set up their own fixtures.
  factory GuardianAngelaDatabase.memory({SeedCallback? seedCallback}) =>
      GuardianAngelaDatabase(
        NativeDatabase.memory(),
        seedCallback: seedCallback,
      );

  final SeedCallback _seed;

  /// Filename used for the on-disk database under the application
  /// documents directory.
  static const String fileName = 'guardian_angela.db';

  /// Drift schema version. Bumping triggers a nuke-and-reseed via
  /// [MigrationStrategy.onUpgrade] (pre-alpha policy — no real
  /// migrations).
  ///
  /// History:
  /// - v1 (Phase 4): initial schema.
  /// - v2 (Phase 6c): added [SessionLogs.deletedAtMs] for the spec
  ///   04:2455–2459 trash retention flow.
  /// - v3 (Phase 6 gap-5): added [SessionModes.isBuiltIn] for the spec
  ///   04 §Modes Screen built-in protection.
  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seed(this);
    },
    onUpgrade: (m, from, to) async {
      // Pre-alpha nuke-and-reseed (see lessons-learned.md §4.10): drop
      // every table, recreate them, and re-install the seed. No
      // backwards compatibility is maintained.
      for (final entity in allSchemaEntities) {
        if (entity is TableInfo) {
          await m.deleteTable(entity.actualTableName);
        }
      }
      await m.createAll();
      await _seed(this);
    },
  );

  /// Opens (or creates) the encrypted database at the standard application
  /// documents location.
  ///
  /// [encryptionKey] must be a non-empty hex/base64 string (32 raw bytes
  /// = 64 hex chars). The key is applied via `PRAGMA key` before any
  /// other SQL through the sqlite3mc cipher (configured at the build-hook
  /// level — see `pubspec.yaml` §hooks.user_defines.sqlite3.source).
  static Future<GuardianAngelaDatabase> open({
    required String encryptionKey,
    SeedCallback? seedCallback,
  }) async {
    if (encryptionKey.isEmpty) {
      throw ArgumentError.value(
        encryptionKey,
        'encryptionKey',
        'must be a non-empty key — see spec 03 §Storage Architecture.',
      );
    }
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, fileName));
    final executor = NativeDatabase.createInBackground(
      file,
      setup: (db) =>
          db.execute("PRAGMA key = '${_escapePragma(encryptionKey)}';"),
    );
    return GuardianAngelaDatabase(executor, seedCallback: seedCallback);
  }

  /// Escapes single quotes inside the key for `PRAGMA key = '...'`. The
  /// canonical key is a base64 or hex blob and will not contain quotes,
  /// but a defensive escape keeps malformed input from breaking the
  /// pragma statement.
  static String _escapePragma(String value) => value.replaceAll("'", "''");
}
