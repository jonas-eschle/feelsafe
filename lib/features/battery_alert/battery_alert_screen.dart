import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/features/battery_alert/battery_alert_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Battery alert configuration screen.
///
/// Toggle + threshold slider + step chain editor (Phase 7 will add the
/// per-step inline editor; Phase 6 shows the chain summary). See spec
/// 04 §Battery Alert.
class BatteryAlertScreen extends ConsumerWidget {
  /// Creates a [BatteryAlertScreen].
  const BatteryAlertScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stateAsync = ref.watch(batteryAlertControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.batteryAlertTitle)),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(child: Text('Error: $e')),
        data: (state) {
          final notifier = ref.read(batteryAlertControllerProvider.notifier);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              SwitchListTile(
                title: Text(l10n.batteryAlertEnableLabel),
                value: state.config.enabled,
                onChanged: notifier.setEnabled,
              ),
              if (state.config.enabled) ...<Widget>[
                Text(l10n.batteryAlertThresholdLabel),
                Slider(
                  value: state.config.thresholdPercent.toDouble(),
                  min: 5,
                  max: 50,
                  divisions: 45,
                  label: '${state.config.thresholdPercent}%',
                  onChanged: (double v) => notifier.setThreshold(v.round()),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(l10n.batteryAlertChainHeader),
                    TextButton(
                      onPressed: notifier.resetChain,
                      child: Text(l10n.batteryAlertResetChain),
                    ),
                  ],
                ),
                for (int i = 0; i < state.config.chain.length; i++)
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${i + 1}')),
                      title: Text(state.config.chain[i].type.name),
                      subtitle: Text(
                        l10n.stepTimingSummary(
                          state.config.chain[i].waitSeconds.toString(),
                          state.config.chain[i].durationSeconds.toString(),
                          state.config.chain[i].gracePeriodSeconds.toString(),
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
