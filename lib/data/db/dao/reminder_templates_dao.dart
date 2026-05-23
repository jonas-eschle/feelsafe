import 'package:drift/drift.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/db/tables/reminder_templates_table.dart';
import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';

part 'reminder_templates_dao.g.dart';

/// DAO for the [ReminderTemplates] table.
///
/// Provides CRUD and a watch stream for [ReminderTemplate] rows.
@DriftAccessor(tables: [ReminderTemplates])
class ReminderTemplatesDao extends DatabaseAccessor<GuardianAngelaDatabase>
    with _$ReminderTemplatesDaoMixin {
  /// Creates a DAO bound to [db].
  ReminderTemplatesDao(super.db);

  /// Returns all templates in insertion order.
  Future<List<ReminderTemplate>> getAll() async {
    final rows = await select(reminderTemplates).get();
    return rows.map(_rowToModel).toList();
  }

  /// Returns the template with [id], or null if not found.
  Future<ReminderTemplate?> getById(String id) async {
    final row = await (select(
      reminderTemplates,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _rowToModel(row);
  }

  /// Inserts or replaces [template] (upsert keyed by
  /// [ReminderTemplate.id]).
  Future<void> upsert(ReminderTemplate template) async {
    await into(
      reminderTemplates,
    ).insertOnConflictUpdate(_modelToCompanion(template));
  }

  /// Deletes the template with [id]. No-op if not found.
  Future<void> deleteById(String id) async {
    await (delete(reminderTemplates)..where((t) => t.id.equals(id))).go();
  }

  /// Streams all templates (re-emitting on every change).
  Stream<List<ReminderTemplate>> watchAll() => select(
    reminderTemplates,
  ).watch().map((rows) => rows.map(_rowToModel).toList());

  static ReminderTemplate _rowToModel(ReminderTemplateRow row) =>
      ReminderTemplate(
        id: row.id,
        name: row.name,
        title: row.title,
        body: row.body,
        iconAsset: row.iconAsset,
        confirmationType: ConfirmationType.values.byName(row.confirmationType),
        keyword: row.keyword,
        buttonLabel: row.buttonLabel,
        isCustom: row.isCustom,
        imagePath: row.imagePath,
        subtitle: row.subtitle,
        displayStyle: ReminderDisplayStyle.values.byName(row.displayStyle),
        isGlobal: row.isGlobal,
      );

  static ReminderTemplatesCompanion _modelToCompanion(ReminderTemplate t) =>
      ReminderTemplatesCompanion(
        id: Value(t.id),
        name: Value(t.name),
        title: Value(t.title),
        body: Value(t.body),
        iconAsset: Value(t.iconAsset),
        confirmationType: Value(t.confirmationType.name),
        keyword: Value(t.keyword),
        buttonLabel: Value(t.buttonLabel),
        isCustom: Value(t.isCustom),
        imagePath: Value(t.imagePath),
        subtitle: Value(t.subtitle),
        displayStyle: Value(t.displayStyle.name),
        isGlobal: Value(t.isGlobal),
      );
}
