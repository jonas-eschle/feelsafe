/// DAO for the `battery_alert` singleton table.
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:guardianangela/data/db/app_database.dart';
import 'package:guardianangela/data/db/schema/tables.dart';
import 'package:guardianangela/domain/models/battery_alert_config.dart';

part 'battery_alert_dao.g.dart';

/// Data-access object for the singleton `BatteryAlertConfig` row.
@DriftAccessor(tables: [BatteryAlertTable])
class BatteryAlertDao extends DatabaseAccessor<AppDatabase>
    with _$BatteryAlertDaoMixin {
  /// Creates a battery-alert DAO.
  BatteryAlertDao(super.db);

  static const String _singletonId = 'singleton';

  /// Returns the stored [BatteryAlertConfig], or null if none exists.
  Future<BatteryAlertConfig?> get() async {
    final row =
        await (select(batteryAlertTable)
              ..where((t) => t.id.equals(_singletonId))
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return null;
    return BatteryAlertConfig.fromJson(
      jsonDecode(row.jsonPayload) as Map<String, Object?>,
    );
  }

  /// Overwrites the persisted [BatteryAlertConfig] with [value].
  Future<void> save(BatteryAlertConfig value) async {
    await into(batteryAlertTable).insertOnConflictUpdate(
      BatteryAlertTableCompanion.insert(
        id: const Value(_singletonId),
        jsonPayload: jsonEncode(value.toJson()),
      ),
    );
  }

  /// Deletes the singleton row.
  Future<void> clear() async {
    await (delete(
      batteryAlertTable,
    )..where((t) => t.id.equals(_singletonId))).go();
  }
}
