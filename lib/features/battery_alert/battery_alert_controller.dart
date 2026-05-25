import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import 'package:guardianangela/data/seed_data.dart';
import 'package:guardianangela/domain/models/battery_alert_config.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Immutable state for the battery alert screen.
@immutable
class BatteryAlertState {
  /// Creates a [BatteryAlertState].
  const BatteryAlertState({required this.config});

  /// Current battery alert configuration.
  final BatteryAlertConfig config;
}

/// Controller for the battery alert screen.
class BatteryAlertController extends AsyncNotifier<BatteryAlertState> {
  @override
  Future<BatteryAlertState> build() async {
    final repo = ref.watch(batteryAlertConfigRepositoryProvider);
    final cfg = await repo.load();
    return BatteryAlertState(config: cfg);
  }

  Future<void> _save(BatteryAlertConfig cfg) async {
    await ref.read(batteryAlertConfigRepositoryProvider).save(cfg);
    ref.invalidateSelf();
  }

  /// Toggle enable.
  Future<void> setEnabled(bool v) async {
    final current = state.value;
    if (current == null) return;
    await _save(current.config.copyWith(enabled: v));
  }

  /// Update threshold percent.
  Future<void> setThreshold(int percent) async {
    final current = state.value;
    if (current == null) return;
    await _save(current.config.copyWith(thresholdPercent: percent));
  }

  /// Reset chain to seed default.
  Future<void> resetChain() async {
    final current = state.value;
    if (current == null) return;
    final defaults = SeedData.defaultBatteryAlertConfig();
    await _save(current.config.copyWith(chain: defaults.chain));
  }

  /// Persist a new chain.
  ///
  /// Throws [ArgumentError] when [chain] contains a forbidden step type
  /// (interactive types are not allowed in a battery-alert chain — the
  /// alert is OS-triggered, not user-driven).
  Future<void> setChain(List<ChainStep> chain) async {
    final current = state.value;
    if (current == null) return;
    BatteryAlertConfig.validateChain(chain);
    await _save(current.config.copyWith(chain: chain));
  }
}

/// Provides [BatteryAlertController].
final batteryAlertControllerProvider =
    AsyncNotifierProvider<BatteryAlertController, BatteryAlertState>(
      BatteryAlertController.new,
    );
