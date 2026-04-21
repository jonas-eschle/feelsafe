/// Direct DAO tests for [DistressChainsDao].
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/app_database.dart';
import 'package:guardianangela/data/db/daos/distress_chains_dao.dart';
import 'package:guardianangela/data/models/enums.dart';
import '../../helpers/test_helpers.dart';
import 'dao_test_support.dart';

void main() {
  setUpAll(overrideSqliteOpen);

  late AppDatabase db;
  late DistressChainsDao dao;

  setUp(() {
    db = makeMemoryDb();
    dao = DistressChainsDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('empty db returns no chains', () async {
    check(await dao.getAll()).isEmpty();
  });

  test('getById returns null for a missing id', () async {
    check(await dao.getById('missing')).isNull();
  });

  test('save + getById round-trips', () async {
    await dao.save(makeDistressChain(id: 'r'));
    check((await dao.getById('r'))!.id).equals('r');
  });

  test('save overwrites existing chain', () async {
    await dao.save(makeDistressChain(id: 'dup', name: 'v1'));
    await dao.save(makeDistressChain(id: 'dup', name: 'v2'));
    check((await dao.getById('dup'))!.name).equals('v2');
  });

  test('getAll orders by id ascending', () async {
    await dao.save(makeDistressChain(id: 'c'));
    await dao.save(makeDistressChain(id: 'a'));
    await dao.save(makeDistressChain(id: 'b'));
    check(
      (await dao.getAll()).map((c) => c.id).toList(),
    ).deepEquals(['a', 'b', 'c']);
  });

  test('multi-step chain survives round-trip', () async {
    final chain = makeDistressChain(
      id: 'multi',
      steps: [
        smsStep(order: 0),
        step(type: ChainStepType.loudAlarm, order: 1),
        step(type: ChainStepType.callEmergency, order: 2),
      ],
    );
    await dao.save(chain);
    final read = await dao.getById('multi');
    check(read!.steps.length).equals(3);
    check(read.steps[2].type).equals(ChainStepType.callEmergency);
  });

  test('deleteById removes one chain', () async {
    await dao.save(makeDistressChain(id: 'a'));
    await dao.save(makeDistressChain(id: 'b'));
    await dao.deleteById('a');
    check(await dao.getById('a')).isNull();
    check(await dao.getById('b')).isNotNull();
  });

  test('deleteById on missing id is a no-op', () async {
    await dao.deleteById('phantom');
    check(await dao.getAll()).isEmpty();
  });

  test('deleteAll wipes every row', () async {
    await dao.save(makeDistressChain(id: 'a'));
    await dao.save(makeDistressChain(id: 'b'));
    await dao.deleteAll();
    check(await dao.getAll()).isEmpty();
  });
}
