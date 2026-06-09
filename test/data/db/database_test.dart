import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'package:checks/checks.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/seed_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GuardianAngelaDatabase', () {
    test(
      'schemaVersion is 4 (Phase 6 fix-b6 — added feedback_history table)',
      () {
        final db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
        try {
          check(db.schemaVersion).equals(4);
        } finally {
          unawaited(db.close());
        }
      },
    );

    test('onCreate invokes the seedCallback exactly once', () async {
      // Arrange — wire a counter into the seed callback. The memory
      // factory triggers migration on first write.
      var calls = 0;
      final db = GuardianAngelaDatabase.memory(
        seedCallback: (_) async {
          calls += 1;
        },
      );
      try {
        // Act — issue any query so the migrator fires.
        await db.contactsDao.getAll();
        // Assert
        check(calls).equals(1);
      } finally {
        await db.close();
      }
    });

    test('open() rejects an empty encryption key', () async {
      await check(
        GuardianAngelaDatabase.open(encryptionKey: ''),
      ).throws<ArgumentError>();
    });

    test('open() creates an encrypted on-disk DB under documents and the '
        'PRAGMA-key path works (escapes embedded quotes)', () async {
      final docsDir = await Directory.systemTemp.createTemp('ga_db_open_');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (call) async => call.method == 'getApplicationDocumentsDirectory'
                ? docsDir.path
                : null,
          );
      // A key containing a single quote forces the _escapePragma path.
      const key = "abc'def-key-with-quote";
      GuardianAngelaDatabase? db;
      try {
        db = await GuardianAngelaDatabase.open(encryptionKey: key);
        // Force the lazy connection to open + run the PRAGMA + seed.
        final modes = await db.sessionModesDao.getAll();
        check(modes).isNotEmpty();
        // The file was created (under the mocked documents dir) using the
        // canonical filename.
        check(
          File(
            '${docsDir.path}/${GuardianAngelaDatabase.fileName}',
          ).existsSync(),
        ).isTrue();
      } finally {
        await db?.close();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('plugins.flutter.io/path_provider'),
              null,
            );
        await docsDir.delete(recursive: true);
      }
    });

    test(
      'default seedCallback populates the built-in modes and templates',
      () async {
        // Arrange — default constructor uses SeedData.seedInto.
        final db = GuardianAngelaDatabase(NativeDatabase.memory());
        try {
          // Act
          final modes = await db.sessionModesDao.getAll();
          final templates = await db.reminderTemplatesDao.getAll();
          // Assert
          final modeIds = modes.map((m) => m.id).toSet();
          check(modeIds).contains(SeedData.walkModeId);
          check(modeIds).contains(SeedData.dateModeId);
          check(modeIds).contains(SeedData.defaultDistressModeId);
          check(templates.length).equals(8);
        } finally {
          await db.close();
        }
      },
    );
  });
}
