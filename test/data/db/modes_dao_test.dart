/// Direct DAO tests for [ModesDao] — complement the repository
/// round-trip tests with finer-grained empty/get/save/update/delete/
/// deleteAll/ordering/batch coverage.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/app_database.dart';
import 'package:guardianangela/data/db/daos/modes_dao.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/models.dart';
import '../../helpers/test_helpers.dart';
import 'dao_test_support.dart';

void main() {
  setUpAll(overrideSqliteOpen);

  late AppDatabase db;
  late ModesDao dao;

  setUp(() {
    db = makeMemoryDb();
    dao = ModesDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('getAll returns empty on a fresh db', () async {
    check(await dao.getAll()).isEmpty();
  });

  test('getById returns null for a missing id', () async {
    check(await dao.getById('missing')).isNull();
  });

  test('save + getById round-trips', () async {
    final mode = makeMode(id: 'rt', name: 'Round Trip');
    await dao.save(mode);
    final read = await dao.getById('rt');
    check(read).isNotNull();
    check(read!.name).equals('Round Trip');
  });

  test('save overwrites an existing row', () async {
    await dao.save(makeMode(id: 'dup', name: 'v1'));
    await dao.save(makeMode(id: 'dup', name: 'v2'));
    final read = await dao.getById('dup');
    check(read!.name).equals('v2');
  });

  test('getAll is ordered ascending by id', () async {
    await dao.save(makeMode(id: 'c'));
    await dao.save(makeMode(id: 'a'));
    await dao.save(makeMode(id: 'b'));
    final ids = (await dao.getAll()).map((m) => m.id).toList();
    check(ids).deepEquals(['a', 'b', 'c']);
  });

  test('saveAll batch-inserts', () async {
    await dao.saveAll([
      makeMode(id: 'a'),
      makeMode(id: 'b'),
      makeMode(id: 'c'),
    ]);
    check((await dao.getAll()).length).equals(3);
  });

  test('saveAll overwrites existing rows by id', () async {
    await dao.save(makeMode(id: 'dup', name: 'pre'));
    await dao.saveAll([makeMode(id: 'dup', name: 'post')]);
    final read = await dao.getById('dup');
    check(read!.name).equals('post');
  });

  test('deleteById removes only the target row', () async {
    await dao.saveAll([makeMode(id: 'a'), makeMode(id: 'b')]);
    await dao.deleteById('a');
    check(await dao.getById('a')).isNull();
    check(await dao.getById('b')).isNotNull();
  });

  test('deleteById on missing id is a no-op', () async {
    await dao.deleteById('never-existed');
    check(await dao.getAll()).isEmpty();
  });

  test('deleteAll wipes every row', () async {
    await dao.saveAll([makeMode(id: 'a'), makeMode(id: 'b')]);
    await dao.deleteAll();
    check(await dao.getAll()).isEmpty();
  });

  test('complex step config survives round-trip', () async {
    final mode = makeMode(
      id: 'complex',
      steps: [
        smsStep(order: 0, message: 'help'),
        step(
          type: ChainStepType.fakeCall,
          order: 1,
          durationSeconds: 20,
          config: const FakeCallConfig(declineIsSafe: true),
        ),
      ],
    );
    await dao.save(mode);
    final read = await dao.getById('complex');
    check(read!.chainSteps.length).equals(2);
    check(read.chainSteps[1].config).isA<FakeCallConfig>();
  });
}
