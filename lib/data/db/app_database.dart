/// Drift-backed `AppDatabase` for Guardian Angela.
///
/// Schema v1 is the baseline — per the pre-alpha policy, any
/// mismatch (opened with a newer schema than we ship) throws so the
/// caller layer can nuke-and-reseed.
///
/// The underlying database is encrypted via SQLite3MultipleCiphers
/// (selected through the `hooks` block in `pubspec.yaml`, which
/// instructs `package:sqlite3` to bundle the cipher-capable build for
/// every target platform). The passphrase is loaded via
/// [EncryptionKey.load] from platform secure storage and applied
/// through `PRAGMA key` in the drift `setup` hook before any schema
/// migrations run.
library;

import 'dart:developer' as developer;
import 'dart:ffi';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:guardianangela/data/db/encryption.dart';
import 'package:guardianangela/data/db/schema/tables.dart';

part 'app_database.g.dart';

/// Top-level Drift database for Guardian Angela.
@DriftDatabase(
  tables: [
    ModesTable,
    ContactsTable,
    TemplatesTable,
    SessionLogsTable,
    SettingsTable,
    UserProfileTable,
    BatteryAlertTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Creates an app database using [executor].
  ///
  /// When [executor] is null the default lazy connection (encrypted
  /// file in the application documents directory) is used.
  AppDatabase({QueryExecutor? executor})
    : super(executor ?? _openConnection());

  /// Creates an in-memory test instance. Not used by production code.
  @visibleForTesting
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // Pre-alpha policy: only the current schema version is
      // supported. Any upgrade attempt indicates a schema mismatch
      // the caller layer must resolve with a nuke-and-reseed.
      throw StateError(
        'Schema mismatch: expected v$to but opened v$from. '
        'Pre-alpha policy requires a nuke-and-reseed.',
      );
    },
  );

  /// Database filename (without path). Exposed for tests that want
  /// to delete the file as part of a nuke-and-reseed.
  static const String dbFileName = 'guardian_angela.sqlite';

  /// On desktop platforms (Linux/macOS/Windows) the
  /// `flutter run -d <desktop>` JIT runtime does not honour
  /// `native_assets.json` for the `package:sqlite3` `@Native` symbol
  /// resolution — it falls back to the platform's system
  /// `libsqlite3.so.0` (which is plaintext-only). Pre-loading the
  /// bundled `libsqlite3mc` here puts the cipher-capable symbols into
  /// the process's symbol table BEFORE any `@Native` lookup runs, so
  /// `RTLD_DEFAULT` finds them first. Mobile platforms
  /// (Android/iOS) link the cipher build via `sqlite3_flutter_libs`
  /// at install time and don't need this path.
  static bool _desktopLoaderAttempted = false;

  static void _ensureDesktopSqlite3mcLoaded() {
    if (_desktopLoaderAttempted) return;
    _desktopLoaderAttempted = true;
    if (!Platform.isLinux && !Platform.isMacOS && !Platform.isWindows) {
      return;
    }
    final candidates = <String>[
      if (Platform.isLinux) 'libsqlite3mc.so',
      if (Platform.isLinux) 'lib/libsqlite3mc.so',
      if (Platform.isMacOS) 'libsqlite3mc.dylib',
      if (Platform.isMacOS) 'lib/libsqlite3mc.dylib',
      if (Platform.isWindows) 'sqlite3mc.dll',
      if (Platform.isWindows) 'lib/sqlite3mc.dll',
    ];
    for (final path in candidates) {
      try {
        DynamicLibrary.open(path);
        return;
      } on Object {
        // Try the next candidate.
      }
    }
    developer.log(
      'AppDatabase: could not pre-load libsqlite3mc on desktop. '
      'Cipher detection will fail.',
    );
  }

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      _ensureDesktopSqlite3mcLoaded();
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, dbFileName));
      final passphrase = await EncryptionKey.load();

      return NativeDatabase(
        file,
        setup: (db) {
          // Verify we loaded the cipher-capable build (sqlite3mc).
          // SQLite3MultipleCiphers exposes `sqlite3mc_version()` as a
          // SQL function — plaintext sqlite3 will throw
          // "no such function" instead of returning a row, which is
          // how we detect that the wrong build is linked.
          try {
            db.select('SELECT sqlite3mc_version()');
          } on Object catch (e) {
            throw StateError(
              'Cipher-capable sqlite3 build is not loaded — verify the '
              '`hooks: user_defines: sqlite3: source: sqlite3mc` block '
              'in pubspec.yaml. Underlying error: $e',
            );
          }
          // `PRAGMA key` must be run before any data read/write.
          db.execute("PRAGMA key = '$passphrase';");
        },
      );
    });
  }
}
