/// DAO for the `templates` table.
library;

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:guardianangela/data/db/app_database.dart';
import 'package:guardianangela/data/db/schema/tables.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';

part 'templates_dao.g.dart';

/// Data-access object for [ReminderTemplate] aggregates.
@DriftAccessor(tables: [TemplatesTable])
class TemplatesDao extends DatabaseAccessor<AppDatabase>
    with _$TemplatesDaoMixin {
  /// Creates a templates DAO.
  TemplatesDao(super.db);

  /// Returns every template (global + mode-local), ordered by id.
  Future<List<ReminderTemplate>> getAll() async {
    final rows = await (select(templatesTable)
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    return [for (final row in rows) _decode(row.jsonPayload)];
  }

  /// Returns only the global templates.
  Future<List<ReminderTemplate>> getAllGlobal() async {
    final rows = await (select(templatesTable)
          ..where((t) => t.isGlobal.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    return [for (final row in rows) _decode(row.jsonPayload)];
  }

  /// Returns the template with [id], or null if none exists.
  Future<ReminderTemplate?> getById(String id) async {
    final row = await (select(templatesTable)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;
    return _decode(row.jsonPayload);
  }

  /// Upserts [value] by its `id`.
  Future<void> save(ReminderTemplate value) async {
    await into(templatesTable).insertOnConflictUpdate(
      TemplatesTableCompanion.insert(
        id: value.id,
        jsonPayload: jsonEncode(value.toJson()),
        isGlobal: Value(value.isGlobal),
      ),
    );
  }

  /// Deletes the template with [id]. No-op if it does not exist.
  Future<void> deleteById(String id) async {
    await (delete(templatesTable)..where((t) => t.id.equals(id))).go();
  }

  /// Deletes every row.
  Future<void> deleteAll() async {
    await delete(templatesTable).go();
  }

  ReminderTemplate _decode(String payload) =>
      ReminderTemplate.fromJson(jsonDecode(payload) as Map<String, Object?>);
}
