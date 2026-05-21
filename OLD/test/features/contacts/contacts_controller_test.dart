/// Tests for [ContactsController] — CRUD happy paths, reorder, and
/// reload semantics against an in-memory fake repository.
library;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/contacts/contacts_controller.dart';

import '../../helpers/test_helpers.dart';
import '../fake_repositories.dart';

ProviderContainer _makeContainer({List<EmergencyContact> seed = const []}) {
  final repo = FakeContactsRepository(seed);
  return ProviderContainer(
    overrides: [contactsRepositoryProvider.overrideWithValue(repo)],
  );
}

void main() {
  group('ContactsController.build', () {
    test('returns empty list when no contacts stored', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final list = await container.read(contactsControllerProvider.future);
      check(list).isEmpty();
    });

    test('hydrates persisted contacts', () async {
      final c1 = makeContact(id: 'c1', name: 'Alice');
      final c2 = makeContact(id: 'c2', name: 'Bob');
      final container = _makeContainer(seed: [c1, c2]);
      addTearDown(container.dispose);
      final list = await container.read(contactsControllerProvider.future);
      check(list.length).equals(2);
    });
  });

  group('ContactsController.save', () {
    test('persists a new contact and refreshes state', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(contactsControllerProvider.notifier);
      await container.read(contactsControllerProvider.future);
      await notifier.save(makeContact(id: 'c-new', name: 'New'));
      final list = container.read(contactsControllerProvider).value!;
      check(list.length).equals(1);
      check(list.single.id).equals('c-new');
    });

    test('overwrites existing contact by id (upsert)', () async {
      final container = _makeContainer(
        seed: [makeContact(id: 'c1', name: 'Alice')],
      );
      addTearDown(container.dispose);
      final notifier = container.read(contactsControllerProvider.notifier);
      await container.read(contactsControllerProvider.future);
      await notifier.save(makeContact(id: 'c1', name: 'Alicia'));
      final list = container.read(contactsControllerProvider).value!;
      check(list.length).equals(1);
      check(list.single.name).equals('Alicia');
    });
  });

  group('ContactsController.delete', () {
    test('removes the contact and refreshes state', () async {
      final container = _makeContainer(
        seed: [
          makeContact(id: 'c1', name: 'Alice'),
          makeContact(id: 'c2', name: 'Bob'),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(contactsControllerProvider.notifier);
      await container.read(contactsControllerProvider.future);
      await notifier.delete('c1');
      final list = container.read(contactsControllerProvider).value!;
      check(list.length).equals(1);
      check(list.single.id).equals('c2');
    });

    test('deleting unknown id is a no-op', () async {
      final container = _makeContainer(
        seed: [makeContact(id: 'c1', name: 'Alice')],
      );
      addTearDown(container.dispose);
      final notifier = container.read(contactsControllerProvider.notifier);
      await container.read(contactsControllerProvider.future);
      await notifier.delete('nope');
      final list = container.read(contactsControllerProvider).value!;
      check(list.length).equals(1);
    });
  });

  group('ContactsController.reorder', () {
    test('moves first to last and renumbers sortOrder', () async {
      final container = _makeContainer(
        seed: [
          makeContact(id: 'a', name: 'A', sortOrder: 0),
          makeContact(id: 'b', name: 'B', sortOrder: 1),
          makeContact(id: 'c', name: 'C', sortOrder: 2),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(contactsControllerProvider.notifier);
      await container.read(contactsControllerProvider.future);
      // Move index 0 to end (beyond length => newIndex = length = 3).
      await notifier.reorder(0, 3);
      final list = container.read(contactsControllerProvider).value!;
      check(list.map((c) => c.id).toList()).deepEquals(['b', 'c', 'a']);
      // Each entry now has sortOrder == index.
      for (var i = 0; i < list.length; i++) {
        check(list[i].sortOrder).equals(i);
      }
    });

    test('moves last to first', () async {
      final container = _makeContainer(
        seed: [
          makeContact(id: 'a', name: 'A', sortOrder: 0),
          makeContact(id: 'b', name: 'B', sortOrder: 1),
          makeContact(id: 'c', name: 'C', sortOrder: 2),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(contactsControllerProvider.notifier);
      await container.read(contactsControllerProvider.future);
      await notifier.reorder(2, 0);
      final list = container.read(contactsControllerProvider).value!;
      check(list.map((c) => c.id).toList()).deepEquals(['c', 'a', 'b']);
    });

    test('throws RangeError on out-of-range oldIndex', () async {
      final container = _makeContainer(
        seed: [makeContact(id: 'a')],
      );
      addTearDown(container.dispose);
      final notifier = container.read(contactsControllerProvider.notifier);
      await container.read(contactsControllerProvider.future);
      await check(notifier.reorder(5, 0)).throws<RangeError>();
    });
  });

  group('ContactsController.reload', () {
    test('resets state and re-reads from repo', () async {
      final repo = FakeContactsRepository([
        makeContact(id: 'a'),
      ]);
      final container = ProviderContainer(
        overrides: [contactsRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      final notifier = container.read(contactsControllerProvider.notifier);
      await container.read(contactsControllerProvider.future);
      // Seed something externally — reload picks it up.
      await repo.save(makeContact(id: 'b'));
      await notifier.reload();
      final list = container.read(contactsControllerProvider).value!;
      check(list.length).equals(2);
    });
  });
}
