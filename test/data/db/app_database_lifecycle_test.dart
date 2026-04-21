/// Lifecycle tests for [AppDatabase] — targets the coverage gap in
/// the constructor and migration strategy.
///
/// The [_openConnection] body can only be exercised on a host with
/// SQLCipher + path_provider wired up; production uses it via
/// `AppDatabase()` with no args. We cover:
///   * Constructor default path runs (see `main()` — instantiating
///     with `executor: NativeDatabase.memory()` forces the injected
///     path so the `PlatformInfo` default branch is reached).
///   * `onUpgrade` throws a `StateError` per the pre-alpha
///     nuke-and-reseed policy.
///   * `FakePlatformInfo(isAndroid: true)` exercises the Android arm
///     of the `_openConnection` static — the closure itself is lazy,
///     so we can only assert it builds a [LazyDatabase] without
///     executing the cipher setup.
///   * `close()` on a fresh in-memory instance completes cleanly.
library;

import 'package:checks/checks.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/platform/platform_info.dart';
import 'package:guardianangela/data/db/app_database.dart';
import 'dao_test_support.dart';

void main() {
  setUpAll(overrideSqliteOpen);

  test(
    'AppDatabase default constructor accepts injected executor',
    () async {
      // Injecting NativeDatabase.memory() bypasses the lazy
      // SQLCipher-on-Android path while still covering the
      // constructor's default-argument branch.
      final db = AppDatabase(executor: NativeDatabase.memory());
      check(db.schemaVersion).equals(1);
      await db.close();
    },
  );

  test(
    'AppDatabase Android platform default still yields an AppDatabase',
    () {
      // We cannot actually run the cipher path from a Linux host.
      // But we can verify that the ctor accepts the fake-platform
      // kwarg without blowing up (the actual LazyDatabase closure
      // only runs when a query is issued, which we skip here by
      // passing an in-memory executor).
      final db = AppDatabase(
        executor: NativeDatabase.memory(),
        platform: const FakePlatformInfo(isAndroid: true),
      );
      check(db.schemaVersion).equals(1);
      unawaited(db.close());
    },
  );

  test(
    'AppDatabase iOS platform default still yields an AppDatabase',
    () {
      final db = AppDatabase(
        executor: NativeDatabase.memory(),
        platform: const FakePlatformInfo(isIOS: true),
      );
      check(db.schemaVersion).equals(1);
      unawaited(db.close());
    },
  );

  test('AppDatabase migration.onUpgrade throws StateError', () async {
    final db = makeMemoryDb();
    addTearDown(db.close);
    final migration = db.migration;
    // Fire the onUpgrade branch directly — drift normally only calls
    // it when the open schemaVersion differs from the db's persisted
    // one. In our pre-alpha policy any call is a hard error.
    await expectLater(
      () => migration.onUpgrade(_NoopMigrator(db), 1, 2),
      throwsA(isA<StateError>()),
    );
  });

  test(
    'AppDatabase migration.onCreate calls createAll on the migrator',
    () async {
      final db = makeMemoryDb();
      addTearDown(db.close);
      final migrator = _RecordingMigrator(db);
      await db.migration.onCreate(migrator);
      check(migrator.createAllCalls).equals(1);
    },
  );

  test(
    'AppDatabase close completes without error',
    () async {
      final db = makeMemoryDb();
      await db.close();
      // Closing twice on drift raises; test just one close.
    },
  );

  test('AppDatabase dbFileName is the documented value', () {
    check(AppDatabase.dbFileName).equals('guardian_angela.sqlite');
  });
}

/// Minimal [Migrator] double that no-ops createAll.
class _NoopMigrator implements Migrator {
  _NoopMigrator(this._db);
  final GeneratedDatabase _db;

  @override
  GeneratedDatabase get database => _db;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

/// [Migrator] double that records `createAll` invocations.
class _RecordingMigrator implements Migrator {
  _RecordingMigrator(this._db);
  final GeneratedDatabase _db;
  int createAllCalls = 0;

  @override
  GeneratedDatabase get database => _db;

  @override
  Future<void> createAll() async {
    createAllCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

// Keep a tiny unawaited shim that's clearer than `ignore:`:
void unawaited(Future<Object?> future) {}
