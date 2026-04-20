/// CRUD repository for [ReminderTemplate] aggregates. Phase 6 fills
/// the bodies against Drift; until then every method throws
/// [UnimplementedError].
library;

import 'package:guardianangela/domain/models/reminder_template.dart';

/// Repository for `ReminderTemplate` aggregates.
final class TemplatesRepository {
  /// Creates a templates repository.
  TemplatesRepository();

  /// Returns every saved reminder template (global + mode-local).
  Future<List<ReminderTemplate>> getAll() async =>
      throw UnimplementedError('TODO: Phase 6 fills this in');

  /// Returns the template with [id], or null if not found.
  Future<ReminderTemplate?> getById(String id) async =>
      throw UnimplementedError('TODO: Phase 6 fills this in');

  /// Upserts [value] by its `id`.
  Future<void> save(ReminderTemplate value) async =>
      throw UnimplementedError('TODO: Phase 6 fills this in');

  /// Deletes the template with [id].
  Future<void> delete(String id) async =>
      throw UnimplementedError('TODO: Phase 6 fills this in');
}
