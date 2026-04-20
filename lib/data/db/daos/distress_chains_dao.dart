/// DAO for the `distress_chains` table.
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:guardianangela/data/db/app_database.dart';
import 'package:guardianangela/data/db/schema/tables.dart';
import 'package:guardianangela/domain/models/distress_chain.dart';

part 'distress_chains_dao.g.dart';

/// Data-access object for [DistressChain] aggregates.
@DriftAccessor(tables: [DistressChainsTable])
class DistressChainsDao extends DatabaseAccessor<AppDatabase>
    with _$DistressChainsDaoMixin {
  /// Creates a distress-chains DAO.
  DistressChainsDao(super.db);

  /// Returns every distress chain, ordered by id. The first element
  /// is the default when a mode's `distressChainId` is null.
  Future<List<DistressChain>> getAll() async {
    final rows = await (select(distressChainsTable)
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    return [for (final row in rows) _decode(row.jsonPayload)];
  }

  /// Returns the distress chain with [id], or null if none exists.
  Future<DistressChain?> getById(String id) async {
    final row = await (select(distressChainsTable)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;
    return _decode(row.jsonPayload);
  }

  /// Upserts [value] by its `id`.
  Future<void> save(DistressChain value) async {
    await into(distressChainsTable).insertOnConflictUpdate(
      DistressChainsTableCompanion.insert(
        id: value.id,
        jsonPayload: jsonEncode(value.toJson()),
      ),
    );
  }

  /// Deletes the chain with [id]. No-op if it does not exist.
  Future<void> deleteById(String id) async {
    await (delete(distressChainsTable)..where((t) => t.id.equals(id))).go();
  }

  /// Deletes every row.
  Future<void> deleteAll() async {
    await delete(distressChainsTable).go();
  }

  DistressChain _decode(String payload) =>
      DistressChain.fromJson(jsonDecode(payload) as Map<String, Object?>);
}
