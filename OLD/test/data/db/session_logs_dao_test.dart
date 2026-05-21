/// Direct DAO tests for [SessionLogsDao]. Covers ordering via the
/// mirrored `startedAt` column.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/app_database.dart';
import 'package:guardianangela/data/db/daos/session_logs_dao.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'dao_test_support.dart';

SessionLog _log({
  required String id,
  required DateTime startedAt,
  bool isSimulation = false,
  List<SessionLogEvent>? events,
}) => SessionLog(
  id: id,
  modeId: 'mode-x',
  modeName: 'Test Mode',
  startedAt: startedAt,
  isSimulation: isSimulation,
  events:
      events ??
      [SessionLogEvent(event: ChainEvent.sessionStarted, timestamp: startedAt)],
);

void main() {
  setUpAll(overrideSqliteOpen);

  late AppDatabase db;
  late SessionLogsDao dao;

  setUp(() {
    db = makeMemoryDb();
    dao = SessionLogsDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('empty db returns empty list', () async {
    check(await dao.getAll()).isEmpty();
  });

  test('getById returns null for a missing id', () async {
    check(await dao.getById('nope')).isNull();
  });

  test('save + getById round-trips', () async {
    await dao.save(_log(id: 'l1', startedAt: DateTime.utc(2026, 1, 1)));
    check((await dao.getById('l1'))!.id).equals('l1');
  });

  test('save overwrites existing log', () async {
    final t = DateTime.utc(2026, 4, 20);
    await dao.save(_log(id: 'dup', startedAt: t));
    await dao.save(_log(id: 'dup', startedAt: t, isSimulation: true));
    final read = await dao.getById('dup');
    check(read!.isSimulation).isTrue();
  });

  test('getAll orders newest-first by startedAt', () async {
    final a = _log(id: 'a', startedAt: DateTime.utc(2026, 1, 1));
    final b = _log(id: 'b', startedAt: DateTime.utc(2026, 6, 1));
    final c = _log(id: 'c', startedAt: DateTime.utc(2026, 3, 1));
    await dao.save(a);
    await dao.save(b);
    await dao.save(c);
    final ids = (await dao.getAll()).map((l) => l.id).toList();
    check(ids).deepEquals(['b', 'c', 'a']);
  });

  test('event order is preserved', () async {
    final now = DateTime.utc(2026, 4, 20);
    final log = SessionLog(
      id: 'e',
      modeId: 'm',
      modeName: 'Mode',
      startedAt: now,
      isSimulation: false,
      events: [
        SessionLogEvent(event: ChainEvent.sessionStarted, timestamp: now),
        SessionLogEvent(
          event: ChainEvent.stepStarted,
          timestamp: now.add(const Duration(seconds: 1)),
          stepIndex: 0,
          stepType: ChainStepType.holdButton,
        ),
        SessionLogEvent(
          event: ChainEvent.sessionEnded,
          timestamp: now.add(const Duration(seconds: 2)),
        ),
      ],
    );
    await dao.save(log);
    final read = await dao.getById('e');
    check(read!.events.first.event).equals(ChainEvent.sessionStarted);
    check(read.events.last.event).equals(ChainEvent.sessionEnded);
  });

  test('deleteById removes only target row', () async {
    await dao.save(_log(id: 'a', startedAt: DateTime.utc(2026, 1, 1)));
    await dao.save(_log(id: 'b', startedAt: DateTime.utc(2026, 2, 1)));
    await dao.deleteById('a');
    check(await dao.getById('a')).isNull();
    check(await dao.getById('b')).isNotNull();
  });

  test('deleteById on missing id is a no-op', () async {
    await dao.deleteById('ghost');
    check(await dao.getAll()).isEmpty();
  });

  test('deleteAll wipes everything', () async {
    await dao.save(_log(id: 'a', startedAt: DateTime.utc(2026, 1, 1)));
    await dao.save(_log(id: 'b', startedAt: DateTime.utc(2026, 2, 1)));
    await dao.deleteAll();
    check(await dao.getAll()).isEmpty();
  });
}
