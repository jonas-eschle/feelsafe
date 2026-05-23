import 'package:drift/drift.dart';

/// Drift table backing the [SessionMode] domain model.
///
/// See spec 03 §SessionMode. Three JSON columns hold list data:
/// [chainStepsJson] (`List<ChainStep>`), [distressTriggersJson]
/// (`List<DistressTrigger>`), and [disarmTriggersJson]
/// (`List<DisarmTrigger>`). The [overridesJson] column is null when no
/// per-mode overrides are present.
@DataClassName('SessionModeRow')
class SessionModes extends Table {
  /// UUID primary key.
  TextColumn get id => text()();

  /// Human-readable mode name.
  TextColumn get name => text()();

  /// Optional Material icon name (e.g., 'directions_walk').
  TextColumn get iconName => text().nullable()();

  /// JSON-encoded list of `ChainStep.toJson()` maps.
  TextColumn get chainStepsJson => text()();

  /// ID of the distress mode referenced by this mode; null = inherit
  /// `AppDefaults.defaultDistressModeId`.
  TextColumn get distressModeId => text().nullable()();

  /// JSON-encoded list of `DistressTrigger.toJson()` maps.
  TextColumn get distressTriggersJson => text()();

  /// JSON-encoded list of `DisarmTrigger.toJson()` maps.
  TextColumn get disarmTriggersJson => text()();

  /// JSON-encoded [ModeOverrides] map; null = inherit all defaults.
  TextColumn get overridesJson => text().nullable()();

  /// Whether interval GPS tracking is enabled.
  BoolColumn get trackingEnabled => boolean()();

  /// GPS tracking interval in seconds.
  IntColumn get trackingIntervalSeconds => integer()();

  /// Max GPS positions kept in the in-memory buffer.
  IntColumn get trackingBufferSize => integer()();

  /// Whether the user may pause this session.
  BoolColumn get pauseAllowed => boolean()();

  /// Max pause duration in minutes; null = unlimited.
  IntColumn get maxPauseMinutes => integer().nullable()();

  /// True iff this mode IS a distress mode (referenced by other modes).
  BoolColumn get isDistressMode => boolean()();

  /// Whether disarm triggers still fire when this mode runs as a distress
  /// chain (G-014).
  BoolColumn get allowDisarmAsDistress => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
