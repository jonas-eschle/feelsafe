/// CRUD repository for [SessionLog] aggregates, backed by Drift.
library;

import 'package:meta/meta.dart';

import 'package:guardianangela/data/db/daos/session_logs_dao.dart';
import 'package:guardianangela/domain/models/session_log.dart';

/// Repository for `SessionLog` aggregates (completed session
/// records).
class SessionLogsRepository {
  /// Creates a session-logs repository backed by [dao].
  SessionLogsRepository(SessionLogsDao dao) : _dao = dao;

  /// Test-only constructor; subclasses must override every method.
  @visibleForTesting
  SessionLogsRepository.forTesting() : _dao = null;

  final SessionLogsDao? _dao;

  /// Returns every saved session log, newest-first.
  Future<List<SessionLog>> getAll() => _dao!.getAll();

  /// Returns the session log with [id], or null if not found.
  Future<SessionLog?> getById(String id) => _dao!.getById(id);

  /// Upserts [value] by its `id`.
  Future<void> save(SessionLog value) => _dao!.save(value);

  /// Deletes the session log with [id].
  Future<void> delete(String id) => _dao!.deleteById(id);

  /// Deletes every persisted session log.
  Future<void> deleteAll() => _dao!.deleteAll();
}
