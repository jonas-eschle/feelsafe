/// CRUD repository for [ReminderTemplate] aggregates, backed by
/// Drift.
library;

import 'package:meta/meta.dart';

import 'package:guardianangela/data/db/daos/templates_dao.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';

/// Repository for `ReminderTemplate` aggregates.
class TemplatesRepository {
  /// Creates a templates repository backed by [dao].
  TemplatesRepository(TemplatesDao dao) : _dao = dao;

  /// Test-only constructor; subclasses must override every method.
  @visibleForTesting
  TemplatesRepository.forTesting() : _dao = null;

  final TemplatesDao? _dao;

  /// Returns every saved reminder template (global + mode-local).
  Future<List<ReminderTemplate>> getAll() => _dao!.getAll();

  /// Returns only the global templates (`isGlobal == true`).
  Future<List<ReminderTemplate>> getAllGlobal() => _dao!.getAllGlobal();

  /// Returns the template with [id], or null if not found.
  Future<ReminderTemplate?> getById(String id) => _dao!.getById(id);

  /// Upserts [value] by its `id`.
  Future<void> save(ReminderTemplate value) => _dao!.save(value);

  /// Deletes the template with [id].
  Future<void> delete(String id) => _dao!.deleteById(id);

  /// Deletes every persisted template.
  Future<void> deleteAll() => _dao!.deleteAll();
}
