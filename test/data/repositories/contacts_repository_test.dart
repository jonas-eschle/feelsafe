// Coverage for ContactsRepository — the thin DAO facade used by
// ContactService. Driven against a real in-memory database so every
// delegation runs the genuine ContactsDao path.

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/contacts_repository.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';

EmergencyContact _contact(
  String id, {
  String name = 'Alice',
  int sortOrder = 0,
}) => EmergencyContact(
  id: id,
  name: name,
  phoneNumber: '+15551234567',
  sortOrder: sortOrder,
);

void main() {
  late GuardianAngelaDatabase db;
  late ContactsRepository repo;

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
    repo = ContactsRepository(db.contactsDao);
  });

  tearDown(() async {
    await db.close();
  });

  group('ContactsRepository', () {
    test('upsert + getById + getAll delegate to the DAO', () async {
      await repo.upsert(_contact('a'));
      check((await repo.getById('a'))!.name).equals('Alice');
      check(await repo.getAll()).length.equals(1);
    });

    test('deleteById removes the row', () async {
      await repo.upsert(_contact('a'));
      await repo.deleteById('a');
      check(await repo.getById('a')).isNull();
    });

    test('bulkUpdate writes all rows in order', () async {
      await repo.bulkUpdate([
        _contact('a'),
        _contact('b', sortOrder: 1, name: 'Bob'),
      ]);
      check(
        (await repo.getAll()).map((c) => c.id).toList(),
      ).deepEquals(['a', 'b']);
    });

    test('watchAll emits the current contacts', () async {
      await repo.upsert(_contact('a'));
      final first = await repo.watchAll().first;
      check(first.single.id).equals('a');
    });

    test('deleteAll clears every contact', () async {
      await repo.upsert(_contact('a'));
      await repo.upsert(_contact('b', sortOrder: 1));
      await repo.deleteAll();
      check(await repo.getAll()).isEmpty();
    });
  });
}
