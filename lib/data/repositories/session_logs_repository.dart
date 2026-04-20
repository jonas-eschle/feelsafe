/// CRUD repository for [SessionLog] aggregates. Phase 6 fills the
/// bodies against Drift; until then every method throws
/// [UnimplementedError].
library;

import 'package:guardianangela/domain/models/session_log.dart';

/// Repository for `SessionLog` aggregates (completed session
/// records).
final class SessionLogsRepository {
  /// Creates a session-logs repository.
  SessionLogsRepository();

  /// Returns every saved session log, newest-first recommended.
  Future<List<SessionLog>> getAll() async =>
      throw UnimplementedError('TODO: Phase 6 fills this in');

  /// Returns the session log with [id], or null if not found.
  Future<SessionLog?> getById(String id) async =>
      throw UnimplementedError('TODO: Phase 6 fills this in');

  /// Upserts [value] by its `id`.
  Future<void> save(SessionLog value) async =>
      throw UnimplementedError('TODO: Phase 6 fills this in');

  /// Deletes the session log with [id].
  Future<void> delete(String id) async =>
      throw UnimplementedError('TODO: Phase 6 fills this in');
}
