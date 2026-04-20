/// Drift table definitions for Guardian Angela's persistent store.
///
/// The domain models (in `lib/domain/models/`) are hand-rolled
/// immutable Dart classes with their own JSON serialization. Rather
/// than re-defining every nested field at the SQL level, each
/// aggregate is stored as a single `jsonPayload` TEXT blob keyed by
/// the aggregate's `id`. This keeps the schema trivial to evolve and
/// the domain fully pure Dart; queries project through the JSON
/// blob in memory.
///
/// Schema v1 — any mismatch triggers a nuke-and-reseed at the
/// `AppDatabase.migration` layer (pre-alpha policy).
library;

import 'package:drift/drift.dart';

/// Session modes keyed by id. Payload is the full
/// `SessionMode.toJson()` map.
@DataClassName('ModeRow')
class ModesTable extends Table {
  /// Stable UUID from `SessionMode.id`.
  TextColumn get id => text()();

  /// Serialized `SessionMode.toJson()` payload.
  TextColumn get jsonPayload => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  String? get tableName => 'modes';
}

/// Emergency contacts keyed by id. Includes a `sortOrder` column to
/// support stable editor-visible ordering without parsing the blob.
@DataClassName('ContactRow')
class ContactsTable extends Table {
  /// Stable UUID from `EmergencyContact.id`.
  TextColumn get id => text()();

  /// Serialized `EmergencyContact.toJson()` payload.
  TextColumn get jsonPayload => text()();

  /// Editor-visible ordering; lower sorts first. Defaults to 0.
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  String? get tableName => 'contacts';
}

/// Reminder templates keyed by id. `isGlobal` is mirrored into a
/// column so the "global templates" query can avoid blob parsing.
@DataClassName('TemplateRow')
class TemplatesTable extends Table {
  /// Stable UUID from `ReminderTemplate.id`.
  TextColumn get id => text()();

  /// Serialized `ReminderTemplate.toJson()` payload.
  TextColumn get jsonPayload => text()();

  /// True if global (`AppDefaults.templates`), false if mode-local.
  /// Mirrors `ReminderTemplate.isGlobal`. Defaults to true.
  BoolColumn get isGlobal => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  String? get tableName => 'templates';
}

/// Global distress chains keyed by id. Per D-DATA-21 these live in
/// their own repository (not inside `AppDefaults`).
@DataClassName('DistressChainRow')
class DistressChainsTable extends Table {
  /// Stable UUID from `DistressChain.id`.
  TextColumn get id => text()();

  /// Serialized `DistressChain.toJson()` payload.
  TextColumn get jsonPayload => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  String? get tableName => 'distress_chains';
}

/// Completed-session records keyed by id. `startedAt` is mirrored
/// into a native DATETIME column so the history list can sort
/// newest-first without parsing every blob.
@DataClassName('SessionLogRow')
class SessionLogsTable extends Table {
  /// Stable UUID from `SessionLog.id`.
  TextColumn get id => text()();

  /// Serialized `SessionLog.toJson()` payload.
  TextColumn get jsonPayload => text()();

  /// Mirror of `SessionLog.startedAt` for sort / range queries.
  DateTimeColumn get startedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  String? get tableName => 'session_logs';
}

/// Singleton `AppSettings`. Always keyed by the literal id
/// `'singleton'`.
@DataClassName('SettingsRow')
class SettingsTable extends Table {
  /// Literal `'singleton'`; there is always exactly one row.
  TextColumn get id => text().withDefault(const Constant('singleton'))();

  /// Serialized `AppSettings.toJson()` payload.
  TextColumn get jsonPayload => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  String? get tableName => 'settings';
}

/// Singleton `UserProfile`. Always keyed by the literal id
/// `'singleton'`.
@DataClassName('UserProfileRow')
class UserProfileTable extends Table {
  /// Literal `'singleton'`; there is always exactly one row.
  TextColumn get id => text().withDefault(const Constant('singleton'))();

  /// Serialized `UserProfile.toJson()` payload.
  TextColumn get jsonPayload => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  String? get tableName => 'user_profile';
}

/// Singleton `BatteryAlertConfig`. Always keyed by the literal id
/// `'singleton'`.
@DataClassName('BatteryAlertRow')
class BatteryAlertTable extends Table {
  /// Literal `'singleton'`; there is always exactly one row.
  TextColumn get id => text().withDefault(const Constant('singleton'))();

  /// Serialized `BatteryAlertConfig.toJson()` payload.
  TextColumn get jsonPayload => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  String? get tableName => 'battery_alert';
}
