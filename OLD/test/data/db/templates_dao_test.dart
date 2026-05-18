/// Direct DAO tests for [TemplatesDao]. Also covers the
/// `getAllGlobal` filter path.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/app_database.dart';
import 'package:guardianangela/data/db/daos/templates_dao.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'dao_test_support.dart';

ReminderTemplate _template({
  required String id,
  bool isGlobal = true,
  String name = 'T',
}) => ReminderTemplate(
  id: id,
  name: name,
  title: 'Title',
  body: 'Body',
  confirmationType: ConfirmationType.tapButton,
  displayStyle: ReminderDisplayStyle.subtle,
  isGlobal: isGlobal,
);

void main() {
  setUpAll(overrideSqliteOpen);

  late AppDatabase db;
  late TemplatesDao dao;

  setUp(() {
    db = makeMemoryDb();
    dao = TemplatesDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('empty db returns empty lists', () async {
    check(await dao.getAll()).isEmpty();
    check(await dao.getAllGlobal()).isEmpty();
  });

  test('save + getById round-trips', () async {
    await dao.save(_template(id: 't1', name: 'Calendar'));
    final read = await dao.getById('t1');
    check(read!.name).equals('Calendar');
  });

  test('save overwrites existing row', () async {
    await dao.save(_template(id: 'dup', name: 'v1'));
    await dao.save(_template(id: 'dup', name: 'v2'));
    check((await dao.getById('dup'))!.name).equals('v2');
  });

  test('getAll returns all templates ordered by id', () async {
    await dao.save(_template(id: 'c'));
    await dao.save(_template(id: 'a'));
    await dao.save(_template(id: 'b'));
    check(
      (await dao.getAll()).map((t) => t.id).toList(),
    ).deepEquals(['a', 'b', 'c']);
  });

  test('getAllGlobal filters to isGlobal == true', () async {
    await dao.save(_template(id: 'g1'));
    await dao.save(_template(id: 'g2'));
    await dao.save(_template(id: 'local', isGlobal: false));
    final globals = await dao.getAllGlobal();
    check(globals.map((t) => t.id).toSet()).deepEquals({'g1', 'g2'});
  });

  test('deleteById removes only target', () async {
    await dao.save(_template(id: 'a'));
    await dao.save(_template(id: 'b'));
    await dao.deleteById('a');
    check(await dao.getById('a')).isNull();
    check(await dao.getById('b')).isNotNull();
  });

  test('deleteById on missing id is a no-op', () async {
    await dao.deleteById('none');
    check(await dao.getAll()).isEmpty();
  });

  test('deleteAll wipes everything', () async {
    await dao.save(_template(id: 'a'));
    await dao.save(_template(id: 'b', isGlobal: false));
    await dao.deleteAll();
    check(await dao.getAll()).isEmpty();
    check(await dao.getAllGlobal()).isEmpty();
  });

  test('toggling isGlobal updates the mirrored column', () async {
    await dao.save(_template(id: 'swap'));
    check((await dao.getAllGlobal()).length).equals(1);
    await dao.save(_template(id: 'swap', isGlobal: false));
    check(await dao.getAllGlobal()).isEmpty();
    check(await dao.getById('swap')).isNotNull();
  });
}
