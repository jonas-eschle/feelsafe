/// Singleton repository for [BatteryAlertConfig], backed by Drift.
library;

import 'package:guardianangela/data/db/daos/battery_alert_dao.dart';
import 'package:guardianangela/domain/models/battery_alert_config.dart';

/// Singleton repository for the low-battery alert config.
final class BatteryAlertRepository {
  /// Creates a battery-alert repository backed by [dao].
  BatteryAlertRepository(this._dao);

  final BatteryAlertDao _dao;

  /// Returns the saved [BatteryAlertConfig], or null if unset.
  Future<BatteryAlertConfig?> get() => _dao.get();

  /// Overwrites the persisted config with [value].
  Future<void> save(BatteryAlertConfig value) => _dao.save(value);
}
