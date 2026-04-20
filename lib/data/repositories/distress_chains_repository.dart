/// CRUD repository for [DistressChain] aggregates, backed by Drift.
library;

import 'package:guardianangela/data/db/daos/distress_chains_dao.dart';
import 'package:guardianangela/domain/models/distress_chain.dart';

/// Repository for `DistressChain` aggregates (global-only: all
/// modes reference them by id).
final class DistressChainsRepository {
  /// Creates a distress-chains repository backed by [dao].
  DistressChainsRepository(this._dao);

  final DistressChainsDao _dao;

  /// Returns every saved distress chain. The first element is the
  /// default used when `SessionMode.distressChainId` is null.
  Future<List<DistressChain>> getAll() => _dao.getAll();

  /// Returns the distress chain with [id], or null if not found.
  Future<DistressChain?> getById(String id) => _dao.getById(id);

  /// Upserts [value] by its `id`.
  Future<void> save(DistressChain value) => _dao.save(value);

  /// Deletes the distress chain with [id].
  Future<void> delete(String id) => _dao.deleteById(id);

  /// Deletes every persisted distress chain.
  Future<void> deleteAll() => _dao.deleteAll();
}
