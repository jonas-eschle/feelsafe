/// CRUD repository for [SessionMode] aggregates. Phase 6 fills the
/// bodies against Drift; until then every method throws
/// [UnimplementedError].
library;

import 'package:guardianangela/domain/models/session_mode.dart';

/// Repository for `SessionMode` aggregates.
final class ModesRepository {
  /// Creates a modes repository.
  ModesRepository();

  /// Returns all modes, including both built-in seeded modes and
  /// any user-customized modes.
  Future<List<SessionMode>> getAll() async =>
      throw UnimplementedError('TODO: Phase 6 fills this in');

  /// Returns the mode with [id], or null if not found.
  Future<SessionMode?> getById(String id) async =>
      throw UnimplementedError('TODO: Phase 6 fills this in');

  /// Upserts [value] by its `id`.
  Future<void> save(SessionMode value) async =>
      throw UnimplementedError('TODO: Phase 6 fills this in');

  /// Deletes the mode with [id].
  Future<void> delete(String id) async =>
      throw UnimplementedError('TODO: Phase 6 fills this in');
}
