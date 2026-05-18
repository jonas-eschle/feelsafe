/// Direct DAO tests for [ContactsDao].
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/app_database.dart';
import 'package:guardianangela/data/db/daos/contacts_dao.dart';
import 'package:guardianangela/data/models/enums.dart';
import '../../helpers/test_helpers.dart';
import 'dao_test_support.dart';

void main() {
  setUpAll(overrideSqliteOpen);

  late AppDatabase db;
  late ContactsDao dao;

  setUp(() {
    db = makeMemoryDb();
    dao = ContactsDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('empty db returns empty list', () async {
    check(await dao.getAll()).isEmpty();
  });

  test('getById on missing row returns null', () async {
    check(await dao.getById('nope')).isNull();
  });

  test('save + getById round-trips name + channels', () async {
    final c = makeContact(
      id: 'x',
      name: 'Xena',
      channels: const [MessageChannel.sms, MessageChannel.whatsapp],
    );
    await dao.save(c);
    final read = await dao.getById('x');
    check(read!.name).equals('Xena');
    check(read.channels).deepEquals(const [
      MessageChannel.sms,
      MessageChannel.whatsapp,
    ]);
  });

  test('save overwrites existing contact', () async {
    await dao.save(makeContact(id: 'dup', name: 'v1'));
    await dao.save(makeContact(id: 'dup', name: 'v2'));
    check((await dao.getById('dup'))!.name).equals('v2');
  });

  test('getAll orders by sortOrder ascending then id', () async {
    await dao.save(makeContact(id: 'c', sortOrder: 10));
    await dao.save(makeContact(id: 'a', sortOrder: 0));
    await dao.save(makeContact(id: 'b', sortOrder: 5));
    final ids = (await dao.getAll()).map((c) => c.id).toList();
    check(ids).deepEquals(['a', 'b', 'c']);
  });

  test('tied sortOrder falls back to id ordering', () async {
    await dao.save(makeContact(id: 'beta', sortOrder: 0));
    await dao.save(makeContact(id: 'alpha', sortOrder: 0));
    final ids = (await dao.getAll()).map((c) => c.id).toList();
    check(ids).deepEquals(['alpha', 'beta']);
  });

  test('deleteById removes only the target', () async {
    await dao.save(makeContact(id: 'a'));
    await dao.save(makeContact(id: 'b'));
    await dao.deleteById('a');
    check(await dao.getById('a')).isNull();
    check(await dao.getById('b')).isNotNull();
  });

  test('deleteAll wipes everything', () async {
    await dao.save(makeContact(id: 'a'));
    await dao.save(makeContact(id: 'b'));
    await dao.deleteAll();
    check(await dao.getAll()).isEmpty();
  });

  test('deleteById on missing id is a no-op', () async {
    await dao.deleteById('ghost');
    check(await dao.getAll()).isEmpty();
  });
}
