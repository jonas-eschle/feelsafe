/// Unit tests for [ReminderTemplatesController] against the REAL
/// in-memory Drift DB.
///
/// Mirrors `test/features/modes/modes_controller_test.dart`: a fresh
/// [ProviderContainer] per test whose `databaseProvider` resolves to an
/// isolated [GuardianAngelaDatabase.memory] (no seed). Plain `test()` so
/// `ref.invalidateSelf()` re-runs `build()` without leaking timers.
///
/// Spec ref: `docs/spec/04-screens-navigation.md §Templates Screen`.
library;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/features/reminder_templates/reminder_templates_controller.dart';
import 'package:guardianangela/services/service_providers.dart';

ReminderTemplate _template(String id, String name, {bool isCustom = false}) =>
    ReminderTemplate(
      id: id,
      name: name,
      title: 'Title $name',
      body: 'Body $name',
      confirmationType: ConfirmationType.tapButton,
      isCustom: isCustom,
      displayStyle: ReminderDisplayStyle.fullScreen,
      isGlobal: true,
    );

void main() {
  late GuardianAngelaDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
    container = ProviderContainer(
      overrides: <Override>[databaseProvider.overrideWith((_) async => db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<ReminderTemplatesState> state() =>
      container.read(reminderTemplatesControllerProvider.future);

  ReminderTemplatesController notifier() =>
      container.read(reminderTemplatesControllerProvider.notifier);

  group('ReminderTemplatesController.build', () {
    test('returns all stored templates', () async {
      await db.reminderTemplatesDao.upsert(_template('t1', 'Hydrate'));
      await db.reminderTemplatesDao.upsert(
        _template('t2', 'Meds', isCustom: true),
      );

      final ReminderTemplatesState s = await state();

      check(
        s.templates.map((t) => t.id).toSet(),
      ).deepEquals(<String>{'t1', 't2'});
    });

    test('returns an empty list on an empty database', () async {
      check((await state()).templates).isEmpty();
    });
  });

  group('ReminderTemplatesController.duplicate', () {
    test('clones a built-in under a fresh id as a CUSTOM copy', () async {
      await db.reminderTemplatesDao.upsert(_template('t1', 'Hydrate'));
      await state();

      final String newId = await notifier().duplicate('t1');

      check(newId).not((it) => it.equals('t1'));
      final ReminderTemplatesState s = await state();
      final ReminderTemplate copy = s.templates.singleWhere(
        (t) => t.id == newId,
      );
      check(copy.name).equals('Hydrate (Copy)');
      check(copy.isCustom).isTrue();
      check(copy.title).equals('Title Hydrate');
      // Source untouched (still built-in).
      final ReminderTemplate src = s.templates.singleWhere((t) => t.id == 't1');
      check(src.isCustom).isFalse();
      check(src.name).equals('Hydrate');
    });

    test('throws for an unknown source id', () async {
      await state();

      await expectLater(
        notifier().duplicate('nope'),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('ReminderTemplatesController.delete', () {
    test('removes the row and republishes the shrunken list', () async {
      await db.reminderTemplatesDao.upsert(
        _template('t1', 'Hydrate', isCustom: true),
      );
      await db.reminderTemplatesDao.upsert(
        _template('t2', 'Meds', isCustom: true),
      );
      await state();

      await notifier().delete('t1');

      check(
        (await state()).templates.map((t) => t.id),
      ).deepEquals(<String>['t2']);
    });
  });
}
