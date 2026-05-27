import 'dart:async';

import 'package:checks/checks.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/seed_data.dart';

void main() {
  group('GuardianAngelaDatabase', () {
    test(
      'schemaVersion is 2 (Phase 6c — added session_logs.deleted_at_ms)',
      () {
        final db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
        try {
          check(db.schemaVersion).equals(2);
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
