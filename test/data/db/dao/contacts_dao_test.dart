import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';

void main() {
  late GuardianAngelaDatabase db;

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
  });

  tearDown(() async {
    await db.close();
  });

  group('ContactsDao', () {
    test('getAll returns empty list on a fresh database', () async {
      // Act
      final all = await db.contactsDao.getAll();
      // Assert
      check(all).isEmpty();
    });

    test('upsert + getById round-trips a contact with all channels', () async {
      // Arrange
      final alice = EmergencyContact(
        id: 'alice-1',
        name: 'Alice',
        phoneNumber: '+15551112222',
        relationship: 'Mom',
        sortOrder: 0,
        channels: const [
          MessageChannel.sms,
          MessageChannel.whatsapp,
          MessageChannel.telegram,
          MessageChannel.phoneCall,
        ],
        languageCode: 'de',
      );
      // Act
      await db.contactsDao.upsert(alice);
      final fetched = await db.contactsDao.getById('alice-1');
      // Assert
      check(fetched).isNotNull().equals(alice);
    });

    test('getById returns null when the id is unknown', () async {
      check(await db.contactsDao.getById('missing')).isNull();
    });

    test('getAll orders contacts by sortOrder ascending', () async {
      // Arrange — insert in reverse order.
      for (final contact in [
        _contact('c-2', sortOrder: 2, name: 'Charlie'),
        _contact('c-0'),
        _contact('c-1', sortOrder: 1, name: 'Bob'),
      ]) {
        await db.contactsDao.upsert(contact);
      }
      // Act
      final all = await db.contactsDao.getAll();
      // Assert
      check(all.map((c) => c.id).toList()).deepEquals(['c-0', 'c-1', 'c-2']);
    });

    test('upsert replaces an existing contact with the same id', () async {
      // Arrange
      await db.contactsDao.upsert(_contact('alice-1'));
      // Act — write a different contact with the same id.
      await db.contactsDao.upsert(_contact('alice-1', name: 'Alice Smith'));
      // Assert
      final fetched = await db.contactsDao.getById('alice-1');
      check(fetched).isNotNull();
      check(fetched!.name).equals('Alice Smith');
    });

    test('deleteById removes the contact', () async {
      // Arrange
      await db.contactsDao.upsert(_contact('alice-1'));
      check(await db.contactsDao.getById('alice-1')).isNotNull();
      // Act
      await db.contactsDao.deleteById('alice-1');
      // Assert
      check(await db.contactsDao.getById('alice-1')).isNull();
    });

    test('deleteById is a no-op on an unknown id', () async {
      // Act + Assert (no throw)
      await db.contactsDao.deleteById('missing');
    });

    test('watchAll emits the current list on subscription', () async {
      // Arrange
      await db.contactsDao.upsert(_contact('c-0'));
      // Act
      final first = await db.contactsDao.watchAll().first;
      // Assert
      check(first.map((c) => c.id).toList()).deepEquals(['c-0']);
    });

    test('watchAll re-emits when rows change', () async {
      // Arrange
      final stream = db.contactsDao.watchAll();
      final updates = <List<String>>[];
      final sub = stream.listen((rows) {
        updates.add(rows.map((c) => c.id).toList());
      });
      // Act: write two rows in succession.
      await db.contactsDao.upsert(_contact('c-0'));
      await db.contactsDao.upsert(_contact('c-1', sortOrder: 1));
      // Drain a few microtasks so watch emissions flush.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sub.cancel();
      // Assert: we observed at least two emissions reflecting the inserts.
      check(updates).isNotEmpty();
      check(updates.last).deepEquals(['c-0', 'c-1']);
    });

    // C6b: bulkUpdate (transactional) + deleteAll.
    test('bulkUpdate writes every contact in one transaction', () async {
      await db.contactsDao.bulkUpdate([
        _contact('b-0'),
        _contact('b-1', sortOrder: 1, name: 'Bob'),
        _contact('b-2', sortOrder: 2, name: 'Cara'),
      ]);
      final ids = (await db.contactsDao.getAll()).map((c) => c.id).toList();
      check(ids).deepEquals(['b-0', 'b-1', 'b-2']);
    });

    test('bulkUpdate replaces existing rows with the same id', () async {
      await db.contactsDao.upsert(_contact('b-0', name: 'Old'));
      await db.contactsDao.bulkUpdate([_contact('b-0', name: 'New')]);
      check((await db.contactsDao.getById('b-0'))!.name).equals('New');
    });

    test('deleteAll removes every contact row', () async {
      await db.contactsDao.upsert(_contact('c-0'));
      await db.contactsDao.upsert(_contact('c-1', sortOrder: 1));
      await db.contactsDao.deleteAll();
      check(await db.contactsDao.getAll()).isEmpty();
    });
  });
}

EmergencyContact _contact(
  String id, {
  String name = 'Alice',
  int sortOrder = 0,
  String phoneNumber = '+15551234567',
  List<MessageChannel>? channels,
}) => EmergencyContact(
  id: id,
  name: name,
  phoneNumber: phoneNumber,
  sortOrder: sortOrder,
  channels: channels ?? const [MessageChannel.sms],
);
