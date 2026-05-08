/// Tests for `SessionLog.hadMedicalInfo` — JSON round-trip and
/// Drift (database) round-trip with both true and false values.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/app_database.dart';
import 'package:guardianangela/data/db/daos/session_logs_dao.dart';
import 'package:guardianangela/domain/models/chain_event.dart';
import 'package:guardianangela/domain/models/session_log.dart';

import '../../data/db/dao_test_support.dart';

// ---------------------------------------------------------------------------
// Shared factory
// ---------------------------------------------------------------------------

SessionLog _log({required String id, required bool hadMedicalInfo}) => SessionLog(
  id: id,
  modeId: 'mode-test',
  modeName: 'Test Mode',
  startedAt: DateTime.utc(2026, 5, 1, 12),
  isSimulation: false,
  hadMedicalInfo: hadMedicalInfo,
  events: [
    SessionLogEvent(
      timestamp: DateTime.utc(2026, 5, 1, 12),
      event: ChainEvent.sessionStarted,
    ),
  ],
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // JSON round-trip
  // -------------------------------------------------------------------------
  group('SessionLog.hadMedicalInfo — JSON round-trip', () {
    test('hadMedicalInfo=true survives toJson/fromJson', () {
      final original = _log(id: 'j1', hadMedicalInfo: true);
      final json = original.toJson();
      final restored = SessionLog.fromJson(json);
      check(restored.hadMedicalInfo).isTrue();
    });

    test('hadMedicalInfo=false survives toJson/fromJson', () {
      final original = _log(id: 'j2', hadMedicalInfo: false);
      final json = original.toJson();
      final restored = SessionLog.fromJson(json);
      check(restored.hadMedicalInfo).isFalse();
    });

    test('toJson includes hadMedicalInfo key', () {
      final json = _log(id: 'j3', hadMedicalInfo: true).toJson();
      check(json.containsKey('hadMedicalInfo')).isTrue();
      check(json['hadMedicalInfo']).equals(true);
    });

    test('fromJson defaults hadMedicalInfo to false when key is absent', () {
      final json = _log(id: 'j4', hadMedicalInfo: false).toJson()
        ..remove('hadMedicalInfo');
      final restored = SessionLog.fromJson(json);
      check(restored.hadMedicalInfo).isFalse();
    });

    test('round-trip preserves all other fields with hadMedicalInfo=true', () {
      final original = _log(id: 'j5', hadMedicalInfo: true);
      final restored = SessionLog.fromJson(original.toJson());
      check(restored.id).equals(original.id);
      check(restored.modeId).equals(original.modeId);
      check(restored.modeName).equals(original.modeName);
      check(restored.isSimulation).equals(original.isSimulation);
      check(restored.hadMedicalInfo).equals(original.hadMedicalInfo);
    });
  });

  // -------------------------------------------------------------------------
  // Drift round-trip (in-memory database)
  // -------------------------------------------------------------------------
  group('SessionLog.hadMedicalInfo — Drift round-trip', () {
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

    test('hadMedicalInfo=true is persisted and restored by the DAO', () async {
      final log = _log(id: 'd1', hadMedicalInfo: true);
      await dao.save(log);
      final restored = await dao.getById('d1');
      check(restored).isNotNull();
      check(restored!.hadMedicalInfo).isTrue();
    });

    test('hadMedicalInfo=false is persisted and restored by the DAO', () async {
      final log = _log(id: 'd2', hadMedicalInfo: false);
      await dao.save(log);
      final restored = await dao.getById('d2');
      check(restored).isNotNull();
      check(restored!.hadMedicalInfo).isFalse();
    });

    test('saving with hadMedicalInfo=true then false updates correctly',
        () async {
      await dao.save(_log(id: 'd3', hadMedicalInfo: true));
      check((await dao.getById('d3'))!.hadMedicalInfo).isTrue();

      await dao.save(_log(id: 'd3', hadMedicalInfo: false));
      check((await dao.getById('d3'))!.hadMedicalInfo).isFalse();
    });

    test('getAll preserves hadMedicalInfo across multiple logs', () async {
      await dao.save(_log(id: 'a', hadMedicalInfo: true));
      await dao.save(_log(id: 'b', hadMedicalInfo: false));
      final all = await dao.getAll();
      check(all.length).equals(2);
      final byId = {for (final l in all) l.id: l};
      check(byId['a']!.hadMedicalInfo).isTrue();
      check(byId['b']!.hadMedicalInfo).isFalse();
    });
  });
}
