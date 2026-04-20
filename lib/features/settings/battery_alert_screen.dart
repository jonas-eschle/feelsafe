/// Battery-alert configuration screen.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/features/battery_alert/battery_alert_controller.dart';
import 'package:guardianangela/features/modes/widgets/chain_step_tile.dart';
import 'package:guardianangela/features/modes/widgets/step_type_picker.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Battery-alert screen.
class BatteryAlertScreen extends ConsumerWidget {
  /// Creates the battery-alert screen.
  const BatteryAlertScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(batteryAlertControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.batteryAlertTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('$e')),
        data: (config) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              title: Text(l.batteryAlertEnable),
              value: config.enabled,
              onChanged: (v) async {
                final notifier = ref.read(
                  batteryAlertControllerProvider.notifier,
                );
                if (v) {
                  await notifier.enable();
                } else {
                  await notifier.disable();
                }
              },
            ),
            ListTile(
              title: Text(l.batteryAlertThreshold(config.thresholdPercent)),
            ),
            Slider(
              min: 5,
              max: 50,
              divisions: 9,
              value: config.thresholdPercent.toDouble(),
              label: '${config.thresholdPercent}%',
              onChanged: (v) => ref
                  .read(batteryAlertControllerProvider.notifier)
                  .setThresholdPercent(v.round()),
            ),
            const Divider(),
            Text(
              l.modeChainHeader,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < config.chain.length; i++)
              ChainStepTile(
                key: ValueKey(config.chain[i].id),
                step: config.chain[i],
                onChanged: (s) {
                  final list = List<ChainStep>.of(config.chain)..[i] = s;
                  ref
                      .read(batteryAlertControllerProvider.notifier)
                      .setChain(list);
                },
                onDelete: () {
                  final list = List<ChainStep>.of(config.chain)..removeAt(i);
                  ref
                      .read(batteryAlertControllerProvider.notifier)
                      .setChain(list);
                },
              ),
            OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: Text(l.modeChainAddStep),
              onPressed: () async {
                final type = await showStepTypePicker(context);
                if (type == null) return;
                final list = [
                  ...config.chain,
                  ChainStep(
                    id: const Uuid().v4(),
                    type: type,
                    order: config.chain.length,
                    durationSeconds: 30,
                    gracePeriodSeconds: 15,
                  ),
                ];
                await ref
                    .read(batteryAlertControllerProvider.notifier)
                    .setChain(list);
              },
            ),
            _TriggerDismiss(dismiss: ChainStepType.disguisedReminder),
          ],
        ),
      ),
    );
  }
}

class _TriggerDismiss extends StatelessWidget {
  const _TriggerDismiss({required this.dismiss});
  final ChainStepType dismiss;
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
