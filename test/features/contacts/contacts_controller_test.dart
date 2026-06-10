/// Unit tests for [ContactsController] against the REAL in-memory Drift DB.
///
/// Mirrors the `modes_controller_test.dart` pattern: each test builds a
/// fresh [ProviderContainer] whose `databaseProvider` resolves to an
/// isolated [GuardianAngelaDatabase.memory] (no seed), drives the real
/// controller methods, and asserts BOTH the emitted state and the
/// persisted rows. Contacts are safety-critical (they feed the distress
/// SMS / call strategies), so every mutation pins the DB round-trip.
///
/// Spec ref: `docs/spec/04-screens-navigation.md §Contacts Screen`
/// (swipe-delete, drag reorder persists sortOrder, delete-all).
library;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/contacts_repository.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/features/contacts/contacts_controller.dart';
import 'package:guardianangela/services/service_providers.dart';

EmergencyContact _contact(String id, String name, {int sortOrder = 0}) =>
    EmergencyContact(
      id: id,
      name: name,
      phoneNumber: '+1555010$id',
      sortOrder: sortOrder,
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

  Future<ContactsState> state() =>
      container.read(contactsControllerProvider.future);

  ContactsController controller() =>
      container.read(contactsControllerProvider.notifier);

  group('ContactsController.build', () {
    test('loads every contact in sortOrder display order', () async {
      await db.contactsDao.upsert(_contact('c2', 'Bob', sortOrder: 1));
      await db.contactsDao.upsert(_contact('c1', 'Alice'));

      final ContactsState s = await state();

      check(s.contacts.map((c) => c.name)).deepEquals(['Alice', 'Bob']);
    });

    test('returns an empty list on an empty database', () async {
      check((await state()).contacts).isEmpty();
    });
  });

  group('ContactsController.delete', () {
    test('removes exactly the given contact from state AND the db', () async {
      await db.contactsDao.upsert(_contact('c1', 'Alice'));
      await db.contactsDao.upsert(_contact('c2', 'Bob', sortOrder: 1));
      await state();

      await controller().delete('c1');

      check((await state()).contacts.map((c) => c.id)).deepEquals(['c2']);
      final persisted = await ContactsRepository(db.contactsDao).getAll();
      check(persisted.map((c) => c.id)).deepEquals(['c2']);
    });
  });

  group('ContactsController.reorder', () {
    Future<void> seedThree() async {
      await db.contactsDao.upsert(_contact('c1', 'Alice'));
      await db.contactsDao.upsert(_contact('c2', 'Bob', sortOrder: 1));
      await db.contactsDao.upsert(_contact('c3', 'Carol', sortOrder: 2));
    }

    test('moving a row DOWN adjusts for ReorderableListView semantics '
        'and persists the rewritten sortOrder', () async {
      await seedThree();
      await state();

      // ReorderableListView reports newIndex INCLUDING the moved row:
      // dragging row 0 below row 1 arrives as (oldIndex: 0, newIndex: 2).
      await controller().reorder(0, 2);

      final ContactsState s = await state();
      check(
        s.contacts.map((c) => c.name),
      ).deepEquals(['Bob', 'Alice', 'Carol']);
      // sortOrder rewritten to the new positions and persisted.
      check(s.contacts.map((c) => c.sortOrder)).deepEquals([0, 1, 2]);
      final persisted = await ContactsRepository(db.contactsDao).getAll();
      check(persisted.map((c) => c.name)).deepEquals(['Bob', 'Alice', 'Carol']);
    });

    test('moving a row UP uses the raw newIndex (no adjustment)', () async {
      await seedThree();
      await state();

      await controller().reorder(2, 0);

      final ContactsState s = await state();
      check(
        s.contacts.map((c) => c.name),
      ).deepEquals(['Carol', 'Alice', 'Bob']);
      final persisted = await ContactsRepository(db.contactsDao).getAll();
      check(persisted.map((c) => c.name)).deepEquals(['Carol', 'Alice', 'Bob']);
    });

    test('is a no-op before the first build resolves (no crash, '
        'no phantom write)', () async {
      await seedThree();

      // No await of the provider future: state.value is still null.
      await controller().reorder(0, 2);

      final persisted = await ContactsRepository(db.contactsDao).getAll();
      check(persisted.map((c) => c.name)).deepEquals(['Alice', 'Bob', 'Carol']);
    });
  });

  group('ContactsController.deleteAll', () {
    test('wipes the table and empties the state', () async {
      await db.contactsDao.upsert(_contact('c1', 'Alice'));
      await db.contactsDao.upsert(_contact('c2', 'Bob', sortOrder: 1));
      await state();

      await controller().deleteAll();

      check((await state()).contacts).isEmpty();
      check(await ContactsRepository(db.contactsDao).getAll()).isEmpty();
    });
  });
}
