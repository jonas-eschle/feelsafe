import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/event_defaults.dart';
import 'package:guardianangela/features/event_defaults/event_defaults_controller.dart';
import 'package:guardianangela/features/modes/widgets/black_screen_field.dart';
import 'package:guardianangela/features/modes/widgets/event_specific_config.dart';
import 'package:guardianangela/features/modes/widgets/step_helpers.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Event defaults screen.
///
/// Renders an [ExpansionTile] per step type with an inline [EventSpecificConfig]
/// editor for the typed [StepConfig] defaults, followed by the shared
/// [BlackScreenSwitch] so the universal per-type `blackScreenMode` default
/// stays editable here (spec 06:376/388/462/501). Changes auto-save through
/// [EventDefaultsController.save]. See spec 04 §Event Defaults.
class EventDefaultsScreen extends ConsumerWidget {
  /// Creates an [EventDefaultsScreen].
  const EventDefaultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stateAsync = ref.watch(eventDefaultsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.eventDefaultsTitle)),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) =>
            Center(child: Text(l10n.commonErrorWithDetail(e))),
        data: (state) => ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            _Header(text: l10n.eventDefaultsCheckInHeader),
            for (final t in <ChainStepType>[
              ChainStepType.holdButton,
              ChainStepType.disguisedReminder,
            ])
              _TypeTile(type: t, defaults: state.defaults),
            const Divider(),
            _Header(text: l10n.eventDefaultsEscalationHeader),
            for (final t in <ChainStepType>[
              ChainStepType.countdownWarning,
              ChainStepType.fakeCall,
              ChainStepType.smsContact,
              ChainStepType.phoneCallContact,
              ChainStepType.loudAlarm,
              ChainStepType.callEmergency,
            ])
              _TypeTile(type: t, defaults: state.defaults),
            const Divider(),
            _Header(text: l10n.eventDefaultsPanicHeader),
            _TypeTile(
              type: ChainStepType.hardwareButton,
              defaults: state.defaults,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _TypeTile extends ConsumerWidget {
  const _TypeTile({required this.type, required this.defaults});

  final ChainStepType type;
  final EventDefaults defaults;

  Future<void> _save(WidgetRef ref, StepConfig updated) async {
    final next = _replace(defaults, type, updated);
    await ref.read(eventDefaultsControllerProvider.notifier).save(next);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final StepConfig config = defaults.forType(type);
    return Card(
      child: ExpansionTile(
        leading: Icon(stepIcon(type)),
        title: Text(stepName(l10n, type)),
        subtitle: Text(stepDescription(l10n, type)),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                EventSpecificConfig(
                  config: config,
                  onChanged: (StepConfig c) => _save(ref, c),
                ),
                // The universal blackScreenMode DEFAULT stays editable here
                // (spec 06:376/388/462/501) — the toggle shared with the
                // step panel's Retry & Advanced group renders below the
                // form, not inside it (single implementation).
                BlackScreenSwitch(
                  value: config.blackScreenMode,
                  onChanged: (bool v) =>
                      _save(ref, withBlackScreenMode(config, v)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

EventDefaults _replace(
  EventDefaults base,
  ChainStepType type,
  StepConfig updated,
) {
  return switch (type) {
    ChainStepType.holdButton => base.copyWith(
      holdButton: updated as HoldButtonConfig,
    ),
    ChainStepType.disguisedReminder => base.copyWith(
      disguisedReminder: updated as DisguisedReminderConfig,
    ),
    ChainStepType.countdownWarning => base.copyWith(
      countdownWarning: updated as CountdownWarningConfig,
    ),
    ChainStepType.fakeCall => base.copyWith(
      fakeCall: updated as FakeCallConfig,
    ),
    ChainStepType.smsContact => base.copyWith(
      smsContact: updated as SmsContactConfig,
    ),
    ChainStepType.phoneCallContact => base.copyWith(
      phoneCallContact: updated as PhoneCallContactConfig,
    ),
    ChainStepType.loudAlarm => base.copyWith(
      loudAlarm: updated as LoudAlarmConfig,
    ),
    ChainStepType.callEmergency => base.copyWith(
      callEmergency: updated as CallEmergencyConfig,
    ),
    ChainStepType.hardwareButton => base.copyWith(
      hardwareButton: updated as HardwareButtonConfig,
    ),
  };
}
