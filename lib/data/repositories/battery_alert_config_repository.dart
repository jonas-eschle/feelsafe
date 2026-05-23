import 'dart:math';

import 'package:guardianangela/data/repositories/json_singleton_repository.dart';
import 'package:guardianangela/data/seed_data.dart';
import 'package:guardianangela/domain/models/battery_alert_config.dart';

/// JSON-backed singleton repository for [BatteryAlertConfig].
///
/// Lazy default: when the on-disk file is missing,
/// [SeedData.defaultBatteryAlertConfig] is returned (disabled,
/// threshold 10 %, single-step SMS-to-all chain).
class BatteryAlertConfigRepository {
  /// Creates a [BatteryAlertConfigRepository] backed by
  /// `battery_alert.json`.
  BatteryAlertConfigRepository({
    required KeyProvider keyProvider,
    DirectoryResolver? resolveDir,
    Random? random,
  }) : _store = JsonSingletonRepository<BatteryAlertConfig>(
         fileName: 'battery_alert.json',
         fromJson: BatteryAlertConfig.fromJson,
         toJson: (c) => c.toJson(),
         keyProvider: keyProvider,
         resolveDir: resolveDir,
         random: random,
       );

  final JsonSingletonRepository<BatteryAlertConfig> _store;

  /// Loads the stored config, or [SeedData.defaultBatteryAlertConfig]
  /// if no file exists yet.
  Future<BatteryAlertConfig> load() async =>
      await _store.load() ?? SeedData.defaultBatteryAlertConfig();

  /// Returns the stored value verbatim, or null if no file exists.
  Future<BatteryAlertConfig?> loadOrNull() => _store.load();

  /// Encrypts and writes [value] to disk.
  Future<void> save(BatteryAlertConfig value) => _store.save(value);

  /// Deletes the on-disk file. No-op if missing.
  Future<void> delete() => _store.delete();
}
