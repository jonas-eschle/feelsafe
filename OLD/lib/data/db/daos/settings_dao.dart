/// DAO for the `settings` singleton table.
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:guardianangela/data/db/app_database.dart';
import 'package:guardianangela/data/db/schema/tables.dart';
import 'package:guardianangela/domain/models/app_settings.dart';

part 'settings_dao.g.dart';

/// Data-access object for the singleton `AppSettings` row.
@DriftAccessor(tables: [SettingsTable])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  /// Creates a settings DAO.
  SettingsDao(super.db);

  /// Singleton row id — every `AppSettings` read/write uses this key.
  static const String _singletonId = 'singleton';

  /// Returns the stored [AppSettings], or null if none exists.
  Future<AppSettings?> get() async {
    final row =
        await (select(settingsTable)
              ..where((t) => t.id.equals(_singletonId))
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return null;
    return AppSettings.fromJson(
      jsonDecode(row.jsonPayload) as Map<String, Object?>,
    );
  }

  /// Overwrites the persisted [AppSettings] with [value].
  Future<void> save(AppSettings value) async {
    await into(settingsTable).insertOnConflictUpdate(
      SettingsTableCompanion.insert(
        id: const Value(_singletonId),
        jsonPayload: jsonEncode(value.toJson()),
      ),
    );
  }

  /// Deletes the singleton row. Primarily used by tests and
  /// nuke-and-reseed.
  Future<void> clear() async {
    await (delete(settingsTable)..where((t) => t.id.equals(_singletonId))).go();
  }
}
