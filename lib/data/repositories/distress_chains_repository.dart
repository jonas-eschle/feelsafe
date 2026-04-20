/// CRUD repository for [DistressChain] aggregates. Phase 6 fills the
/// bodies against Drift; until then every method throws
/// [UnimplementedError].
library;

import 'package:guardianangela/domain/models/distress_chain.dart';

/// Repository for `DistressChain` aggregates (global-only: all
/// modes reference them by id).
final class DistressChainsRepository {
  /// Creates a distress-chains repository.
  DistressChainsRepository();

  /// Returns every saved distress chain.
  Future<List<DistressChain>> getAll() async =>
      throw UnimplementedError('TODO: Phase 6 fills this in');

  /// Returns the distress chain with [id], or null if not found.
  Future<DistressChain?> getById(String id) async =>
      throw UnimplementedError('TODO: Phase 6 fills this in');

  /// Upserts [value] by its `id`.
  Future<void> save(DistressChain value) async =>
      throw UnimplementedError('TODO: Phase 6 fills this in');

  /// Deletes the distress chain with [id].
  Future<void> delete(String id) async =>
      throw UnimplementedError('TODO: Phase 6 fills this in');
}
