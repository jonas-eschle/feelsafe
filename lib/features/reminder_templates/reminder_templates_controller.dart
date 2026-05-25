import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Immutable state for the reminder templates list.
@immutable
class ReminderTemplatesState {
  /// Creates a [ReminderTemplatesState].
  const ReminderTemplatesState({required this.templates});

  /// All reminder templates (built-in + custom) in display order.
  final List<ReminderTemplate> templates;
}

/// Controller for the reminder templates list.
class ReminderTemplatesController
    extends AsyncNotifier<ReminderTemplatesState> {
  @override
  Future<ReminderTemplatesState> build() async {
    final db = await ref.watch(databaseProvider.future);
    final all = await db.reminderTemplatesDao.getAll();
    return ReminderTemplatesState(templates: all);
  }

  /// Duplicates [sourceId]; returns the new template's id.
  Future<String> duplicate(String sourceId) async {
    final db = await ref.read(databaseProvider.future);
    final all = await db.reminderTemplatesDao.getAll();
    final src = all.firstWhere((ReminderTemplate t) => t.id == sourceId);
    final newId = const Uuid().v4();
    final copy = src.copyWith(
      id: newId,
      name: '${src.name} (Copy)',
      isCustom: true,
    );
    await db.reminderTemplatesDao.upsert(copy);
    ref.invalidateSelf();
    return newId;
  }

  /// Deletes [id]. Only effective on custom templates.
  Future<void> delete(String id) async {
    final db = await ref.read(databaseProvider.future);
    await db.reminderTemplatesDao.deleteById(id);
    ref.invalidateSelf();
  }
}

/// Provides [ReminderTemplatesController].
final reminderTemplatesControllerProvider =
    AsyncNotifierProvider<ReminderTemplatesController, ReminderTemplatesState>(
      ReminderTemplatesController.new,
    );
