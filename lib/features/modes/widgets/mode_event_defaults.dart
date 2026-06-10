import 'package:flutter/material.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/event_defaults.dart';
import 'package:guardianangela/features/modes/widgets/black_screen_field.dart';
import 'package:guardianangela/features/modes/widgets/event_specific_config.dart';
import 'package:guardianangela/features/modes/widgets/step_helpers.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Inline per-step-type editor for a mode's [EventDefaults] override.
///
/// Renders one [ExpansionTile] per step type whose body is the shared
/// [EventSpecificConfig] form followed by the shared [BlackScreenSwitch]
/// (the universal per-type `blackScreenMode` default stays editable per
/// mode — spec 06:376/388/462/501), mirroring the standalone Event Defaults
/// screen but driven by a plain config+callback so it can stage edits in the
/// mode editor's in-memory draft (spec 04 §Mode — Safety Options §Event
/// Defaults). Contacts are intentionally not passed: a per-mode default has
/// no specific recipients, so the smsContact grid is hidden here (as in
/// global defaults).
class ModeEventDefaults extends StatelessWidget {
  /// Creates a [ModeEventDefaults].
  const ModeEventDefaults({
    super.key,
    required this.defaults,
    required this.onChanged,
  });

  /// The current per-mode event defaults.
  final EventDefaults defaults;

  /// Called with updated defaults whenever a field changes.
  final ValueChanged<EventDefaults> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final ChainStepType type in ChainStepType.values)
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            leading: Icon(stepIcon(type)),
            title: Text(stepName(l10n, type)),
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            childrenPadding: const EdgeInsets.only(bottom: 8),
            children: <Widget>[
              EventSpecificConfig(
                config: defaults.forType(type),
                onChanged: (StepConfig c) =>
                    onChanged(_replace(defaults, type, c)),
              ),
              // The universal blackScreenMode DEFAULT stays editable per
              // mode (spec 06:376/388/462/501) — the toggle shared with
              // the step panel's Retry & Advanced group renders below the
              // form, not inside it (single implementation).
              BlackScreenSwitch(
                value: defaults.forType(type).blackScreenMode,
                onChanged: (bool v) => onChanged(
                  _replace(
                    defaults,
                    type,
                    withBlackScreenMode(defaults.forType(type), v),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// Returns [base] with the config for [type] replaced by [updated].
EventDefaults _replace(
  EventDefaults base,
  ChainStepType type,
  StepConfig updated,
) => switch (type) {
  ChainStepType.holdButton => base.copyWith(
    holdButton: updated as HoldButtonConfig,
  ),
  ChainStepType.disguisedReminder => base.copyWith(
    disguisedReminder: updated as DisguisedReminderConfig,
  ),
  ChainStepType.countdownWarning => base.copyWith(
    countdownWarning: updated as CountdownWarningConfig,
  ),
  ChainStepType.fakeCall => base.copyWith(fakeCall: updated as FakeCallConfig),
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
