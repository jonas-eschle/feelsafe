/// Singleton repository for [BatteryAlertConfig]. Phase 6 fills the
/// bodies against Drift; until then every method throws
/// [UnimplementedError].
library;

import 'package:guardianangela/domain/models/battery_alert_config.dart';

/// Singleton repository for the low-battery alert config.
final class BatteryAlertRepository {
  /// Creates a battery-alert repository.
  BatteryAlertRepository();

  /// Returns the saved [BatteryAlertConfig], or null if unset.
  Future<BatteryAlertConfig?> get() async =>
      throw UnimplementedError('TODO: Phase 6 fills this in');

  /// Overwrites the persisted config with [value].
  Future<void> save(BatteryAlertConfig value) async =>
      throw UnimplementedError('TODO: Phase 6 fills this in');
}
