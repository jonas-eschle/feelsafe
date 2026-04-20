/// Battery-alert feature controller.
///
/// Exposes the singleton [BatteryAlertConfig] and mediates every
/// field edit so UI layers never touch the repository directly.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';

/// Async controller exposing the current battery-alert config.
class BatteryAlertController extends AsyncNotifier<BatteryAlertConfig> {
  @override
  Future<BatteryAlertConfig> build() async {
    final repo = ref.read(batteryAlertRepositoryProvider);
    final stored = await repo.get();
    return stored ?? const BatteryAlertConfig();
  }

  /// Overwrites the current config with [value] and persists it.
  Future<void> save(BatteryAlertConfig value) async {
    final repo = ref.read(batteryAlertRepositoryProvider);
    await repo.save(value);
    state = AsyncValue.data(value);
  }

  /// Enables the alert.
  Future<void> enable() async {
    final current = await future;
    await save(current.copyWith(enabled: true));
  }

  /// Disables the alert.
  Future<void> disable() async {
    final current = await future;
    await save(current.copyWith(enabled: false));
  }

  /// Replaces the escalation chain [chain].
  Future<void> setChain(List<ChainStep> chain) async {
    final current = await future;
    await save(current.copyWith(chain: chain));
  }

  /// Sets the threshold percentage.
  Future<void> setThresholdPercent(int percent) async {
    final current = await future;
    await save(current.copyWith(thresholdPercent: percent));
  }
}

/// Provider for `BatteryAlertController`.
final AsyncNotifierProvider<BatteryAlertController, BatteryAlertConfig>
batteryAlertControllerProvider =
    AsyncNotifierProvider<BatteryAlertController, BatteryAlertConfig>(
      BatteryAlertController.new,
    );
