import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';

void main() {
  late GuardianAngelaDatabase db;

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
  });

  tearDown(() async {
    await db.close();
  });

  group('ReminderTemplatesDao', () {
    test('getAll returns empty list on a fresh database', () async {
      check(await db.reminderTemplatesDao.getAll()).isEmpty();
    });

    for (final confirmationType in ConfirmationType.values) {
      for (final displayStyle in ReminderDisplayStyle.values) {
        test(
          'round-trips a template with confirmation=${confirmationType.name} '
          'displayStyle=${displayStyle.name}',
          () async {
            // Arrange
            final template = ReminderTemplate(
              id: 't-${confirmationType.name}-${displayStyle.name}',
              name: 'Test Template',
              title: 'Test Title',
              body: 'Test Body',
              iconAsset: 'assets/icon.png',
              confirmationType: confirmationType,
              keyword: confirmationType == ConfirmationType.tapWord
                  ? 'SAFE'
                  : null,
              buttonLabel: confirmationType == ConfirmationType.tapButton
                  ? 'OK'
                  : null,
              isCustom: true,
              imagePath: 'app/img.png',
              subtitle: 'Subtitle',
              displayStyle: displayStyle,
              isGlobal: false,
            );
            // Act
            await db.reminderTemplatesDao.upsert(template);
            final fetched = await db.reminderTemplatesDao.getById(template.id);
            // Assert
            check(fetched).isNotNull().equals(template);
          },
        );
      }
    }

    test('upsert replaces an existing template with the same id', () async {
      // Arrange
      final original = ReminderTemplate(
        id: 't-1',
        name: 'Original',
        title: 'Title',
        body: 'Body',
        confirmationType: ConfirmationType.dismiss,
        isCustom: false,
        displayStyle: ReminderDisplayStyle.subtle,
        isGlobal: true,
      );
      await db.reminderTemplatesDao.upsert(original);
      // Act
      final replacement = original.copyWith(name: 'Renamed');
      await db.reminderTemplatesDao.upsert(replacement);
      // Assert
      final fetched = await db.reminderTemplatesDao.getById('t-1');
      check(fetched).isNotNull();
      check(fetched!.name).equals('Renamed');
    });

    test('deleteById removes the template', () async {
      // Arrange
      await db.reminderTemplatesDao.upsert(
        ReminderTemplate(
          id: 't-1',
          name: 'X',
          title: 'X',
          body: 'X',
          confirmationType: ConfirmationType.dismiss,
          isCustom: false,
          displayStyle: ReminderDisplayStyle.subtle,
          isGlobal: true,
        ),
      );
      // Act
      await db.reminderTemplatesDao.deleteById('t-1');
      // Assert
      check(await db.reminderTemplatesDao.getById('t-1')).isNull();
    });

    test('watchAll emits the current list on subscription', () async {
      // Arrange
      await db.reminderTemplatesDao.upsert(
        ReminderTemplate(
          id: 't-1',
          name: 'X',
          title: 'X',
          body: 'X',
          confirmationType: ConfirmationType.dismiss,
          isCustom: false,
          displayStyle: ReminderDisplayStyle.subtle,
          isGlobal: true,
        ),
      );
      // Act
      final first = await db.reminderTemplatesDao.watchAll().first;
      // Assert
      check(first.length).equals(1);
      check(first.single.id).equals('t-1');
    });
  });
}
