import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/core/widgets/step_chain_editor.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/battery_alert_config.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/features/battery_alert/battery_alert_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Battery alert configuration screen.
///
/// Toggle + threshold slider + step-chain editor. Interactive step
/// types are filtered out of the picker because the alert fires from
/// an OS battery event, not user interaction (spec 04 §Battery Alert).
class BatteryAlertScreen extends ConsumerWidget {
  /// Creates a [BatteryAlertScreen].
  const BatteryAlertScreen({super.key});

  /// Step types allowed in a battery-alert chain.
  static final Set<ChainStepType> _allowed = ChainStepType.values
      .where(
        (ChainStepType t) => !BatteryAlertConfig.forbiddenStepTypes.contains(t),
      )
      .toSet();

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
                StepChainEditor(
                  steps: state.config.chain,
                  allowedTypes: _allowed,
                  minSteps: 0,
                  onChanged: (List<ChainStep> next) =>
                      _trySetChain(context, notifier, next),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _trySetChain(
    BuildContext context,
    BatteryAlertController notifier,
    List<ChainStep> next,
  ) {
    // Pre-validate at the call-site to avoid catching an Error (lint).
    // The controller call still validates as a safety net.
    final forbidden = next.firstWhereOrNullForbidden();
    if (forbidden != null) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.batteryAlertForbiddenStep(forbidden.type.name)),
        ),
      );
      return;
    }
    notifier.setChain(next);
  }
}

extension on List<ChainStep> {
  ChainStep? firstWhereOrNullForbidden() {
    for (final step in this) {
      if (BatteryAlertConfig.forbiddenStepTypes.contains(step.type)) {
        return step;
      }
    }
    return null;
  }
}
