/// CRUD repository for [SessionMode] aggregates, backed by Drift.
library;

import 'package:meta/meta.dart';

import 'package:guardianangela/data/db/daos/modes_dao.dart';
import 'package:guardianangela/domain/models/session_mode.dart';

/// Repository for `SessionMode` aggregates.
class ModesRepository {
  /// Creates a modes repository backed by [dao].
  ModesRepository(ModesDao dao) : _dao = dao;

  /// Test-only constructor that leaves the DAO unset. Subclasses
  /// (fakes) must override every method so the DAO is never touched.
  @visibleForTesting
  ModesRepository.forTesting() : _dao = null;

  final ModesDao? _dao;

  /// Returns all modes, including both built-in seeded modes and
  /// any user-customized modes.
  Future<List<SessionMode>> getAll() => _dao!.getAll();

  /// Returns the mode with [id], or null if not found.
  Future<SessionMode?> getById(String id) => _dao!.getById(id);

  /// Upserts [value] by its `id`.
  Future<void> save(SessionMode value) => _dao!.save(value);

  /// Bulk upsert. Each element's `id` is used as the key.
  Future<void> saveAll(List<SessionMode> values) => _dao!.saveAll(values);

  /// Deletes the mode with [id].
  Future<void> delete(String id) => _dao!.deleteById(id);

  /// Deletes every persisted mode. Primarily used by nuke-and-reseed.
  Future<void> deleteAll() => _dao!.deleteAll();
}
