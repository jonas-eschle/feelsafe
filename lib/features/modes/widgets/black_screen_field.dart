import 'package:flutter/material.dart';

import 'package:guardianangela/core/widgets/info_icon_button.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// The single shared editor for [StepConfig.blackScreenMode] — a field of
/// EVERY step type (spec 04:1614; user ruling 2026-06-10: the stealth
/// benefit applies to any step, so the capability is universal).
///
/// Rendered by the mode editor's step panel inside the Retry & Advanced
/// group (spec 04:1592) and, as a trailing section below the per-type
/// event form, by both defaults surfaces — the global Event Defaults
/// screen and the per-mode overrides editor (spec 06:376/388/462/501).
/// One widget plus one write helper ([withBlackScreenMode]) keeps the
/// switch logic single-sourced.
///
/// Carries its [InfoIconButton] like every config field (spec 04:1591).
class BlackScreenSwitch extends StatelessWidget {
  /// Creates a [BlackScreenSwitch].
  const BlackScreenSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  /// The current [StepConfig.blackScreenMode] value.
  final bool value;

  /// Called with the flipped value when the user toggles the switch.
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.eventDefaultsBlackScreen),
            value: value,
            onChanged: onChanged,
          ),
        ),
        InfoIconButton(
          title: l10n.eventDefaultsBlackScreen,
          body: l10n.eventDefaultsBlackScreenInfo,
        ),
      ],
    );
  }
}

/// Returns [config] with `blackScreenMode` set to [value].
///
/// The sealed [StepConfig] base intentionally has no `copyWith`, so the
/// shared toggle dispatches over the subtypes — adding a step type is a
/// compile error here until its arm exists, mirroring the registry rule.
StepConfig withBlackScreenMode(StepConfig config, bool value) =>
    switch (config) {
      final HoldButtonConfig c => c.copyWith(blackScreenMode: value),
      final DisguisedReminderConfig c => c.copyWith(blackScreenMode: value),
      final CountdownWarningConfig c => c.copyWith(blackScreenMode: value),
      final FakeCallConfig c => c.copyWith(blackScreenMode: value),
      final SmsContactConfig c => c.copyWith(blackScreenMode: value),
      final PhoneCallContactConfig c => c.copyWith(blackScreenMode: value),
      final LoudAlarmConfig c => c.copyWith(blackScreenMode: value),
      final CallEmergencyConfig c => c.copyWith(blackScreenMode: value),
      final HardwareButtonConfig c => c.copyWith(blackScreenMode: value),
    };
