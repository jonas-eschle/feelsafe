/// DAO for the `session_logs` table.
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:guardianangela/data/db/app_database.dart';
import 'package:guardianangela/data/db/schema/tables.dart';
import 'package:guardianangela/domain/models/session_log.dart';

part 'session_logs_dao.g.dart';

/// Data-access object for [SessionLog] aggregates.
@DriftAccessor(tables: [SessionLogsTable])
class SessionLogsDao extends DatabaseAccessor<AppDatabase>
    with _$SessionLogsDaoMixin {
  /// Creates a session-logs DAO.
  SessionLogsDao(super.db);

  /// Returns every log, newest-first.
  Future<List<SessionLog>> getAll() async {
    final rows = await (select(sessionLogsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .get();
    return [for (final row in rows) _decode(row.jsonPayload)];
  }

  /// Returns the log with [id], or null if none exists.
  Future<SessionLog?> getById(String id) async {
    final row = await (select(sessionLogsTable)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;
    return _decode(row.jsonPayload);
  }

  /// Upserts [value] by its `id`. Mirrors `startedAt` into its own
  /// column so the history list can sort without parsing.
  Future<void> save(SessionLog value) async {
    await into(sessionLogsTable).insertOnConflictUpdate(
      SessionLogsTableCompanion.insert(
        id: value.id,
        jsonPayload: jsonEncode(value.toJson()),
        startedAt: value.startedAt,
      ),
    );
  }

  /// Deletes the log with [id]. No-op if it does not exist.
  Future<void> deleteById(String id) async {
    await (delete(sessionLogsTable)..where((t) => t.id.equals(id))).go();
  }

  /// Deletes every row.
  Future<void> deleteAll() async {
    await delete(sessionLogsTable).go();
  }

  SessionLog _decode(String payload) =>
      SessionLog.fromJson(jsonDecode(payload) as Map<String, Object?>);
}
