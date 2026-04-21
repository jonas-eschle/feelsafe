/// Drift-backed `AppDatabase` for Guardian Angela.
///
/// Schema v1 is the baseline — per the pre-alpha policy, any
/// mismatch (opened with a newer schema than we ship) throws so the
/// caller layer can nuke-and-reseed.
///
/// The underlying database is encrypted with SQLCipher. The
/// passphrase is loaded via [EncryptionKey.load] from platform
/// secure storage and is applied through `PRAGMA key` in the drift
/// `setup` hook before any schema migrations run.
library;

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';

import 'package:guardianangela/core/platform/platform_info.dart';
import 'package:guardianangela/data/db/encryption.dart';
import 'package:guardianangela/data/db/schema/tables.dart';

part 'app_database.g.dart';

/// Top-level Drift database for Guardian Angela.
@DriftDatabase(
  tables: [
    ModesTable,
    ContactsTable,
    TemplatesTable,
    DistressChainsTable,
    SessionLogsTable,
    SettingsTable,
    UserProfileTable,
    BatteryAlertTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Creates an app database using [executor].
  ///
  /// When [executor] is null the default lazy SQLCipher connection
  /// (file in the application documents directory) is used.
  ///
  /// [platform] injects host-platform detection. Defaults to
  /// `const PlatformInfo()` (reads `dart:io` `Platform.isAndroid`).
  /// Tests can pass a [FakePlatformInfo] to force either branch of
  /// [_openConnection].
  AppDatabase({
    QueryExecutor? executor,
    PlatformInfo platform = const PlatformInfo(),
  }) : super(executor ?? _openConnection(platform));

  /// Creates an in-memory test instance. Not used by production code.
  @visibleForTesting
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // Pre-alpha: schema v1 is the only supported version. Any
      // upgrade attempt indicates a schema mismatch the caller
      // layer must resolve with a nuke-and-reseed (see the
      // `AppDatabase` doc).
      throw StateError(
        'Schema mismatch: expected v$to but opened v$from. '
        'Pre-alpha policy requires a nuke-and-reseed.',
      );
    },
  );

  /// Database filename (without path). Exposed for tests that want
  /// to delete the file as part of a nuke-and-reseed.
  static const String dbFileName = 'guardian_angela.sqlite';

  static LazyDatabase _openConnection(PlatformInfo platform) {
    return LazyDatabase(() async {
      // On Android, `sqlite3` opens the system sqlite by default.
      // Route it to the bundled SQLCipher binary instead.
      if (platform.isAndroid) {
        await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
        open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, dbFileName));
      final passphrase = await EncryptionKey.load();

      return NativeDatabase(
        file,
        setup: (db) {
          // Verify we actually loaded SQLCipher (not plaintext
          // sqlite3 masquerading), then apply the key.
          final cipherRows = db.select('PRAGMA cipher_version;');
          if (cipherRows.isEmpty) {
            throw StateError(
              'SQLCipher library is not available — check '
              'sqlcipher_flutter_libs / iOS pod setup.',
            );
          }
          // `PRAGMA key` must be run before any data read/write.
          db.execute("PRAGMA key = '$passphrase';");
        },
      );
    });
  }
}
