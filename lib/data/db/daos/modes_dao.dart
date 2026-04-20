/// DAO for the `modes` table.
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:guardianangela/data/db/app_database.dart';
import 'package:guardianangela/data/db/schema/tables.dart';
import 'package:guardianangela/domain/models/session_mode.dart';

part 'modes_dao.g.dart';

/// Data-access object for [SessionMode] aggregates. Persists each
/// mode as a single JSON blob keyed by `id`.
@DriftAccessor(tables: [ModesTable])
class ModesDao extends DatabaseAccessor<AppDatabase> with _$ModesDaoMixin {
  /// Creates a modes DAO.
  ModesDao(super.db);

  /// Returns every stored mode, ordered by id ascending.
  Future<List<SessionMode>> getAll() async {
    final rows = await (select(
      modesTable,
    )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
    return [for (final row in rows) _decode(row.jsonPayload)];
  }

  /// Returns the mode with [id], or null if none exists.
  Future<SessionMode?> getById(String id) async {
    final row =
        await (select(modesTable)
              ..where((t) => t.id.equals(id))
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return null;
    return _decode(row.jsonPayload);
  }

  /// Upserts [value] by its `id`.
  Future<void> save(SessionMode value) async {
    await into(modesTable).insertOnConflictUpdate(
      ModesTableCompanion.insert(
        id: value.id,
        jsonPayload: jsonEncode(value.toJson()),
      ),
    );
  }

  /// Bulk upsert. Each element's `id` is used as the key.
  Future<void> saveAll(List<SessionMode> values) async {
    await batch((b) {
      for (final value in values) {
        b.insert(
          modesTable,
          ModesTableCompanion.insert(
            id: value.id,
            jsonPayload: jsonEncode(value.toJson()),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  /// Deletes the mode with [id]. No-op if it does not exist.
  Future<void> deleteById(String id) async {
    await (delete(modesTable)..where((t) => t.id.equals(id))).go();
  }

  /// Deletes every row.
  Future<void> deleteAll() async {
    await delete(modesTable).go();
  }

  SessionMode _decode(String payload) =>
      SessionMode.fromJson(jsonDecode(payload) as Map<String, Object?>);
}
