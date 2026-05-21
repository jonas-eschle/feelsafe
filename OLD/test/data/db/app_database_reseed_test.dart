/// Tests for [AppDatabase.ensureCompatible] — the pre-alpha
/// nuke-and-reseed recovery path when an on-disk DB cannot be
/// opened (schema mismatch, cipher-key mismatch, file corruption).
///
/// Each test writes to a fresh `Directory.systemTemp` and uses a
/// fake [FlutterSecureStorage] so the host's libsecret / Keychain is
/// never touched.
library;

import 'dart:io';

import 'package:checks/checks.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:guardianangela/data/db/app_database.dart';
import 'package:guardianangela/data/db/encryption.dart';

/// Same storage-key constant used by [EncryptionKey].
const String _storageKey = 'ga_sqlcipher_passphrase';

/// In-memory fake of [FlutterSecureStorage].
class _FakeSecureStorage implements FlutterSecureStorage {
  final Map<String, String> backing = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      backing.remove(key);
    } else {
      backing[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => backing[key];

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    backing.remove(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Opens a fresh encrypted database at [file] with [passphrase],
/// runs a no-op query so the on-disk file is materialised with the
/// current v3 schema, then closes it.
Future<void> _seedValidDb({
  required File file,
  required String passphrase,
}) async {
  final db = AppDatabase(
    executor: NativeDatabase(
      file,
      setup: (db) {
        db.execute("PRAGMA key = '$passphrase';");
      },
    ),
  );
  // Force the schema to materialise on disk.
  await db.customStatement('SELECT 1');
  await db.close();
}

void main() {
  late Directory tmp;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('ga_db_reseed_test_');
  });

  tearDown(() async {
    if (tmp.existsSync()) {
      await tmp.delete(recursive: true);
    }
  });

  test(
    'returns false and is a no-op when the DB file does not exist',
    () async {
      final storage = _FakeSecureStorage()..backing[_storageKey] = 'stale';
      final file = File(p.join(tmp.path, 'guardian_angela.sqlite'));

      final reseeded = await AppDatabase.ensureCompatible(
        fileOverride: file,
        storage: storage,
      );

      check(reseeded).isFalse();
      check(storage.backing[_storageKey]).equals('stale');
      check(file.existsSync()).isFalse();
    },
  );

  test('returns false when the existing DB opens cleanly with the '
      'stored key', () async {
    final storage = _FakeSecureStorage();
    final file = File(p.join(tmp.path, 'guardian_angela.sqlite'));
    final passphrase = await EncryptionKey.load(storage: storage);
    await _seedValidDb(file: file, passphrase: passphrase);
    check(file.existsSync()).isTrue();

    final reseeded = await AppDatabase.ensureCompatible(
      fileOverride: file,
      storage: storage,
    );

    check(reseeded).isFalse();
    check(file.existsSync()).isTrue();
    check(storage.backing[_storageKey]).equals(passphrase);
  });

  test('nukes the file and resets the key when the on-disk DB is '
      'corrupted', () async {
    final storage = _FakeSecureStorage()..backing[_storageKey] = 'anykey';
    final file = File(p.join(tmp.path, 'guardian_angela.sqlite'));
    await file.writeAsBytes(<int>[for (var i = 0; i < 4096; i++) i % 256]);
    check(file.existsSync()).isTrue();

    final reseeded = await AppDatabase.ensureCompatible(
      fileOverride: file,
      storage: storage,
    );

    check(reseeded).isTrue();
    check(file.existsSync()).isFalse();
    check(storage.backing).isEmpty();
  });

  test('an existing encrypted DB can be reopened with the same key '
      '(regression: PRAGMA key must precede any other SQL on an '
      'encrypted file)', () async {
    final storage = _FakeSecureStorage();
    final file = File(p.join(tmp.path, 'guardian_angela.sqlite'));
    final passphrase = await EncryptionKey.load(storage: storage);
    await _seedValidDb(file: file, passphrase: passphrase);

    // Open the file a SECOND time with the same key + the
    // production `_openConnection` cipher-check sequence
    // (sqlite3mc_version validation). Before this regression
    // landed, the cipher-check ran BEFORE PRAGMA key, which
    // failed with `SQLITE_NOTADB` because sqlite cannot prepare
    // any non-pragma statement on an encrypted-but-locked file.
    final reopened = AppDatabase(
      executor: NativeDatabase(
        file,
        setup: (db) {
          db.execute("PRAGMA key = '$passphrase';");
          db.select('SELECT sqlite3mc_version()');
        },
      ),
    );
    await reopened.customStatement('SELECT 1');
    await reopened.close();
  });

  test('nukes the file and resets the key when the stored passphrase '
      'no longer matches the on-disk DB', () async {
    final storage = _FakeSecureStorage();
    final file = File(p.join(tmp.path, 'guardian_angela.sqlite'));
    // 1) Create a DB encrypted with passphrase A.
    final passA = await EncryptionKey.load(storage: storage);
    await _seedValidDb(file: file, passphrase: passA);
    check(file.existsSync()).isTrue();
    // 2) Wipe the stored key. The next ensureCompatible call will
    //    regenerate a brand-new passphrase B that cannot open the
    //    pre-existing file.
    await EncryptionKey.reset(storage: storage);
    check(storage.backing).isEmpty();

    final reseeded = await AppDatabase.ensureCompatible(
      fileOverride: file,
      storage: storage,
    );

    check(reseeded).isTrue();
    check(file.existsSync()).isFalse();
    check(storage.backing).isEmpty();
  });
}
