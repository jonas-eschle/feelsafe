import 'package:checks/checks.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/seed_data.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';

void main() {
  group('schema mismatch nuke-and-reseed', () {
    test('onUpgrade drops user data and re-installs the seed', () async {
      // Arrange — start with the real seed installed.
      final db = GuardianAngelaDatabase(NativeDatabase.memory());
      try {
        // Wait for onCreate to seed.
        await db.contactsDao.getAll();
        // Add a user contact so we can prove it gets nuked.
        await db.contactsDao.upsert(
          EmergencyContact(
            id: 'user-contact-1',
            name: 'Mom',
            phoneNumber: '+15551234567',
            sortOrder: 0,
          ),
        );
        check(await db.contactsDao.getById('user-contact-1')).isNotNull();
        // Delete one of the seeded templates to prove the migration
        // restores it.
        await db.reminderTemplatesDao.deleteById(
          '${SeedData.reminderTemplatePrefix}calendar_event',
        );

        // Act — invoke the migration callback as if a real schema
        // version bump had happened. The MigrationStrategy reads
        // its callbacks from the database, so we route through
        // `db.migration` directly.
        final strategy = db.migration;
        await strategy.onUpgrade(Migrator(db), 1, 2);

        // Assert — user contact gone, seed re-installed.
        check(await db.contactsDao.getById('user-contact-1')).isNull();
        final modeIds = (await db.sessionModesDao.getAll())
            .map((m) => m.id)
            .toSet();
        check(modeIds).contains(SeedData.walkModeId);
        check(modeIds).contains(SeedData.dateModeId);
        check(modeIds).contains(SeedData.defaultDistressModeId);
        final templateIds = (await db.reminderTemplatesDao.getAll())
            .map((t) => t.id)
            .toSet();
        check(
          templateIds,
        ).contains('${SeedData.reminderTemplatePrefix}calendar_event');
        check(templateIds.length).equals(8);
      } finally {
        await db.close();
      }
    });
  });
}
