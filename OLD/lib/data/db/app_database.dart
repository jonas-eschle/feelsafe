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
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  AppDatabase({QueryExecutor? executor}) : super(executor ?? _openConnection());

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

  /// Verifies the on-disk database (if any) is compatible with the
  /// current schema and encryption key.
  ///
  /// Per the pre-alpha nuke-and-reseed policy: if opening the
  /// existing file fails for any reason — schema mismatch
  /// ([MigrationStrategy.onUpgrade] throws), cipher-key mismatch,
  /// or file corruption — the file is deleted and the stored
  /// passphrase reset so the next [AppDatabase] open creates a
  /// fresh database via [MigrationStrategy.onCreate].
  ///
  /// Returns `true` when the existing DB had to be reseeded.
  ///
  /// Production callers pass no arguments. Tests inject
  /// [fileOverride] to control the file path and [storage] to
  /// control the secure-storage backend.
  static Future<bool> ensureCompatible({
    File? fileOverride,
    FlutterSecureStorage? storage,
  }) async {
    _ensureDesktopSqlite3mcLoaded();
    final file = fileOverride ?? await resolveDbFile();
    if (!file.existsSync()) return false;

    try {
      final passphrase = await EncryptionKey.load(storage: storage);
      final probe = AppDatabase(
        executor: NativeDatabase(
          file,
          setup: (db) {
            // PRAGMA key first — sqlite cannot prepare any other
            // statement on an encrypted-but-locked file. The
            // cipher-build sanity check is intentionally omitted
            // here: this probe's job is just "is the existing file
            // openable with the stored key", and any failure
            // (corruption, wrong key, missing cipher build) means
            // nuke-and-reseed.
            db.execute("PRAGMA key = '$passphrase';");
          },
        ),
      );
      try {
        await probe.customStatement('SELECT 1');
      } finally {
        await probe.close();
      }
      return false;
    } on Object catch (e, s) {
      developer.log(
        'AppDatabase.ensureCompatible: opening existing DB failed, '
        'nuking and reseeding per pre-alpha policy',
        error: e,
        stackTrace: s,
      );
      if (file.existsSync()) {
        await file.delete();
      }
      await EncryptionKey.reset(storage: storage);
      return true;
    }
  }

  /// Resolves the on-disk path for the SQLite file.
  ///
  /// On Linux desktop we deliberately store the DB inside the
  /// `flutter run -d linux` bundle directory (next to the resolved
  /// executable) rather than under `~/Documents`. That makes
  /// `flutter clean` — which wipes the entire `build/` tree — also
  /// wipe the development DB, matching the expectation that "clean"
  /// resets everything for the next run. Mobile (Android / iOS) is
  /// unaffected and keeps using `getApplicationDocumentsDirectory()`.
  static Future<File> resolveDbFile() async {
    if (Platform.isLinux) {
      final exeDir = Directory(p.dirname(Platform.resolvedExecutable));
      final dataDir = Directory(p.join(exeDir.path, 'dev_db'));
      if (!dataDir.existsSync()) {
        dataDir.createSync(recursive: true);
      }
      return File(p.join(dataDir.path, dbFileName));
    }
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, dbFileName));
  }

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      _ensureDesktopSqlite3mcLoaded();
      final file = await resolveDbFile();
      final passphrase = await EncryptionKey.load();

      return NativeDatabase(
        file,
        setup: (db) {
          // `PRAGMA key` MUST run before any other SQL on an
          // encrypted file — sqlite's PREPARE step reads page 1 to
          // validate the header, which on an encrypted-but-locked
          // DB throws `SQLITE_NOTADB` (code 26). Plain sqlite3
          // silently ignores unknown PRAGMAs, so this line is safe
          // on either build.
          db.execute("PRAGMA key = '$passphrase';");
          // Now verify we actually loaded the cipher-capable build
          // (sqlite3mc). The version function exists only in
          // sqlite3mc — plaintext sqlite3 raises "no such function",
          // which is how we detect that the wrong build is linked.
          try {
            db.select('SELECT sqlite3mc_version()');
          } on Object catch (e) {
            throw StateError(
              'Cipher-capable sqlite3 build is not loaded — verify the '
              '`hooks: user_defines: sqlite3: source: sqlite3mc` block '
              'in pubspec.yaml. Underlying error: $e',
            );
          }
        },
      );
    });
  }
}
