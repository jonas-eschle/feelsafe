import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:safewayhome/data/models/emergency_contact.dart';
import 'package:safewayhome/data/repositories/contacts_repository.dart';

void main() {
  late Directory tempDir;
  late ContactsRepository repository;

  setUpAll(() {
    Hive.registerAdapter(EmergencyContactAdapter());
    Hive.registerAdapter(MessageChannelAdapter());
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('contacts_repo_test_');
    Hive.init(tempDir.path);
    repository = ContactsRepository();
  });

  tearDown(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  group('ContactsRepository', () {
    test('getAll returns empty list initially', () async {
      final contacts = await repository.getAll();
      expect(contacts, isEmpty);
    });

    test('save and getAll returns saved contact', () async {
      final contact = EmergencyContact(
        id: 'c1',
        name: 'Alice',
        phoneNumber: '+49123456',
      );

      await repository.save(contact);
      final contacts = await repository.getAll();

      expect(contacts.length, 1);
      expect(contacts[0].id, 'c1');
      expect(contacts[0].name, 'Alice');
      expect(contacts[0].phoneNumber, '+49123456');
    });

    test('getById returns saved contact', () async {
      final contact = EmergencyContact(
        id: 'c1',
        name: 'Alice',
        phoneNumber: '+49123456',
      );

      await repository.save(contact);
      final found = await repository.getById('c1');

      expect(found, isNotNull);
      expect(found!.name, 'Alice');
    });

    test('getById returns null for missing id', () async {
      final found = await repository.getById('nonexistent');
      expect(found, isNull);
    });

    test('save overwrites existing contact with same id', () async {
      final contact = EmergencyContact(
        id: 'c1',
        name: 'Alice',
        phoneNumber: '+49123456',
      );

      await repository.save(contact);

      final updated = EmergencyContact(
        id: 'c1',
        name: 'Alice Updated',
        phoneNumber: '+49999999',
      );

      await repository.save(updated);
      final contacts = await repository.getAll();

      expect(contacts.length, 1);
      expect(contacts[0].name, 'Alice Updated');
      expect(contacts[0].phoneNumber, '+49999999');
    });

    test('delete removes contact', () async {
      final contact = EmergencyContact(
        id: 'c1',
        name: 'Alice',
        phoneNumber: '+49123456',
      );

      await repository.save(contact);
      await repository.delete('c1');

      final contacts = await repository.getAll();
      expect(contacts, isEmpty);
    });

    test('delete non-existent id is a no-op', () async {
      await repository.delete('nonexistent');
      final contacts = await repository.getAll();
      expect(contacts, isEmpty);
    });

    test('deleteAll clears all contacts', () async {
      await repository.save(EmergencyContact(
        id: 'c1',
        name: 'Alice',
        phoneNumber: '+49111',
      ));
      await repository.save(EmergencyContact(
        id: 'c2',
        name: 'Bob',
        phoneNumber: '+49222',
      ));

      await repository.deleteAll();
      final contacts = await repository.getAll();
      expect(contacts, isEmpty);
    });

    test('getAll returns contacts sorted by sortOrder', () async {
      await repository.save(EmergencyContact(
        id: 'c3',
        name: 'Charlie',
        phoneNumber: '+49333',
        sortOrder: 2,
      ));
      await repository.save(EmergencyContact(
        id: 'c1',
        name: 'Alice',
        phoneNumber: '+49111',
        sortOrder: 0,
      ));
      await repository.save(EmergencyContact(
        id: 'c2',
        name: 'Bob',
        phoneNumber: '+49222',
        sortOrder: 1,
      ));

      final contacts = await repository.getAll();
      expect(contacts[0].name, 'Alice');
      expect(contacts[1].name, 'Bob');
      expect(contacts[2].name, 'Charlie');
    });

    test('multiple saves and deletes maintain consistency', () async {
      await repository.save(EmergencyContact(
        id: 'c1',
        name: 'Alice',
        phoneNumber: '+49111',
      ));
      await repository.save(EmergencyContact(
        id: 'c2',
        name: 'Bob',
        phoneNumber: '+49222',
      ));
      await repository.save(EmergencyContact(
        id: 'c3',
        name: 'Charlie',
        phoneNumber: '+49333',
      ));

      await repository.delete('c2');

      final contacts = await repository.getAll();
      expect(contacts.length, 2);
      expect(contacts.map((c) => c.id).toList(), containsAll(['c1', 'c3']));
    });

    test('preserves all fields through save and load', () async {
      final contact = EmergencyContact(
        id: 'c1',
        name: 'Alice',
        phoneNumber: '+49123456',
        relationship: 'Sister',
        sortOrder: 5,
        preferredChannel: MessageChannel.whatsapp,
      );

      await repository.save(contact);
      final loaded = await repository.getById('c1');

      expect(loaded, isNotNull);
      expect(loaded!.id, 'c1');
      expect(loaded.name, 'Alice');
      expect(loaded.phoneNumber, '+49123456');
      expect(loaded.relationship, 'Sister');
      expect(loaded.sortOrder, 5);
      expect(loaded.preferredChannel, MessageChannel.whatsapp);
    });
  });
}
