import 'package:flutter/material.dart';

import 'package:guardianangela/domain/enums/stealth_icon_preset.dart';
import 'package:guardianangela/domain/enums/stealth_timer_display.dart';
import 'package:guardianangela/domain/models/stealth_config.dart';
import 'package:guardianangela/features/modes/widgets/config_fields.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Inline editor for every [StealthConfig] field except the master `enabled`
/// toggle (which the caller exposes as its tri-state selector).
///
/// Stateless and controller-free so it can render inside the mode editor's
/// in-memory draft. Mirrors the field set of the standalone stealth settings
/// screen.
class StealthConfigFields extends StatelessWidget {
  /// Creates a [StealthConfigFields].
  const StealthConfigFields({
    super.key,
    required this.config,
    required this.onChanged,
  });

  /// The config to edit.
  final StealthConfig config;

  /// Called with an updated config whenever a field changes.
  final ValueChanged<StealthConfig> onChanged;

  String _presetLabel(StealthIconPreset preset, AppLocalizations l10n) =>
      switch (preset) {
        StealthIconPreset.music => l10n.stealthPresetMusic,
        StealthIconPreset.calendar => l10n.stealthPresetCalendar,
        StealthIconPreset.fitness => l10n.stealthPresetFitness,
        StealthIconPreset.weather => l10n.stealthPresetWeather,
        StealthIconPreset.news => l10n.stealthPresetNews,
        StealthIconPreset.photos => l10n.stealthPresetPhotos,
        StealthIconPreset.notes => l10n.stealthPresetNotes,
        StealthIconPreset.clock => l10n.stealthPresetClock,
        StealthIconPreset.podcast => l10n.stealthPresetPodcast,
        StealthIconPreset.none => l10n.stealthPresetNone,
      };

  String _timerLabel(StealthTimerDisplay v, AppLocalizations l10n) =>
      switch (v) {
        StealthTimerDisplay.normal => l10n.stealthTimerDisplayNormal,
        StealthTimerDisplay.small => l10n.stealthTimerDisplaySmall,
        StealthTimerDisplay.none => l10n.stealthTimerDisplayNone,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        LabeledTextField(
          label: l10n.stealthFakeNameLabel,
          value: config.fakeName,
          onChanged: (String v) =>
              onChanged(config.copyWith(fakeName: v.isEmpty ? 'Music' : v)),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.stealthFakeIconLabel),
          trailing: DropdownButton<StealthIconPreset>(
            value: config.fakeIcon,
            onChanged: (StealthIconPreset? v) {
              if (v != null) onChanged(config.copyWith(fakeIcon: v));
            },
            items: <DropdownMenuItem<StealthIconPreset>>[
              for (final StealthIconPreset preset in StealthIconPreset.values)
                DropdownMenuItem<StealthIconPreset>(
                  value: preset,
                  child: Text(_presetLabel(preset, l10n)),
                ),
            ],
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.stealthNotificationDisguiseLabel),
          value: config.notificationDisguise,
          onChanged: (bool v) =>
              onChanged(config.copyWith(notificationDisguise: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.stealthSessionScreenLabel),
          value: config.sessionScreenStealth,
          onChanged: (bool v) =>
              onChanged(config.copyWith(sessionScreenStealth: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.stealthLockTaskLabel),
          subtitle: Text(l10n.stealthLockTaskSubtitle),
          value: config.lockTaskMode,
          onChanged: (bool v) => onChanged(config.copyWith(lockTaskMode: v)),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.stealthTimerDisplayLabel),
          trailing: DropdownButton<StealthTimerDisplay>(
            value: config.timerDisplay,
            onChanged: (StealthTimerDisplay? v) {
              if (v != null) onChanged(config.copyWith(timerDisplay: v));
            },
            items: <DropdownMenuItem<StealthTimerDisplay>>[
              for (final StealthTimerDisplay v in StealthTimerDisplay.values)
                DropdownMenuItem<StealthTimerDisplay>(
                  value: v,
                  child: Text(_timerLabel(v, l10n)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
