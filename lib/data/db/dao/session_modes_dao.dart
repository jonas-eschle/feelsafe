import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/db/tables/session_modes_table.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/mode_overrides.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/triggers/disarm_trigger.dart';
import 'package:guardianangela/domain/triggers/distress_trigger.dart';

part 'session_modes_dao.g.dart';

/// DAO for the [SessionModes] table.
///
/// Provides CRUD and a watch stream for [SessionMode] rows, plus filters
/// for distress and regular modes.
@DriftAccessor(tables: [SessionModes])
class SessionModesDao extends DatabaseAccessor<GuardianAngelaDatabase>
    with _$SessionModesDaoMixin {
  /// Creates a DAO bound to [db].
  SessionModesDao(super.db);

  /// Returns every mode (both regular and distress).
  Future<List<SessionMode>> getAll() async {
    final rows = await select(sessionModes).get();
    return rows.map(_rowToModel).toList();
  }

  /// Returns only modes with `isDistressMode = true`.
  Future<List<SessionMode>> getDistressModes() async {
    final rows = await (select(
      sessionModes,
    )..where((m) => m.isDistressMode.equals(true))).get();
    return rows.map(_rowToModel).toList();
  }

  /// Returns only modes with `isDistressMode = false`.
  Future<List<SessionMode>> getRegularModes() async {
    final rows = await (select(
      sessionModes,
    )..where((m) => m.isDistressMode.equals(false))).get();
    return rows.map(_rowToModel).toList();
  }

  /// Returns the mode with [id], or null if not found.
  Future<SessionMode?> getById(String id) async {
    final row = await (select(
      sessionModes,
    )..where((m) => m.id.equals(id))).getSingleOrNull();
    return row == null ? null : _rowToModel(row);
  }

  /// Inserts or replaces [mode] (upsert keyed by [SessionMode.id]).
  Future<void> upsert(SessionMode mode) async {
    await into(sessionModes).insertOnConflictUpdate(_modelToCompanion(mode));
  }

  /// Deletes the mode with [id]. No-op if not found.
  Future<void> deleteById(String id) async {
    await (delete(sessionModes)..where((m) => m.id.equals(id))).go();
  }

  /// Streams all modes (re-emitting on every change).
  Stream<List<SessionMode>> watchAll() => select(
    sessionModes,
  ).watch().map((rows) => rows.map(_rowToModel).toList());

  static SessionMode _rowToModel(SessionModeRow row) {
    final chainStepsRaw = jsonDecode(row.chainStepsJson) as List<dynamic>;
    final distressTriggersRaw =
        jsonDecode(row.distressTriggersJson) as List<dynamic>;
    final disarmTriggersRaw =
        jsonDecode(row.disarmTriggersJson) as List<dynamic>;
    return SessionMode(
      id: row.id,
      name: row.name,
      iconName: row.iconName,
      chainSteps: chainStepsRaw
          .map((e) => ChainStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      distressModeId: row.distressModeId,
      distressTriggers: distressTriggersRaw
          .map((e) => DistressTrigger.fromJson(e as Map<String, dynamic>))
          .toList(),
      disarmTriggers: disarmTriggersRaw
          .map((e) => DisarmTrigger.fromJson(e as Map<String, dynamic>))
          .toList(),
      overrides: row.overridesJson == null
          ? null
          : ModeOverrides.fromJson(
              jsonDecode(row.overridesJson!) as Map<String, dynamic>,
            ),
      trackingEnabled: row.trackingEnabled,
      trackingIntervalSeconds: row.trackingIntervalSeconds,
      trackingBufferSize: row.trackingBufferSize,
      pauseAllowed: row.pauseAllowed,
      maxPauseMinutes: row.maxPauseMinutes,
      isDistressMode: row.isDistressMode,
      allowDisarmAsDistress: row.allowDisarmAsDistress,
      isBuiltIn: row.isBuiltIn,
    );
  }

  static SessionModesCompanion _modelToCompanion(SessionMode m) =>
      SessionModesCompanion(
        id: Value(m.id),
        name: Value(m.name),
        iconName: Value(m.iconName),
        chainStepsJson: Value(
          jsonEncode(m.chainSteps.map((s) => s.toJson()).toList()),
        ),
        distressModeId: Value(m.distressModeId),
        distressTriggersJson: Value(
          jsonEncode(m.distressTriggers.map((t) => t.toJson()).toList()),
        ),
        disarmTriggersJson: Value(
          jsonEncode(m.disarmTriggers.map((t) => t.toJson()).toList()),
        ),
        overridesJson: Value(
          m.overrides == null ? null : jsonEncode(m.overrides!.toJson()),
        ),
        trackingEnabled: Value(m.trackingEnabled),
        trackingIntervalSeconds: Value(m.trackingIntervalSeconds),
        trackingBufferSize: Value(m.trackingBufferSize),
        pauseAllowed: Value(m.pauseAllowed),
        maxPauseMinutes: Value(m.maxPauseMinutes),
        isDistressMode: Value(m.isDistressMode),
        allowDisarmAsDistress: Value(m.allowDisarmAsDistress),
        isBuiltIn: Value(m.isBuiltIn),
      );
}
