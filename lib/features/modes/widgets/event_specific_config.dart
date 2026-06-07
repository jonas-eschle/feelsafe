import 'package:flutter/material.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/button_type.dart';
import 'package:guardianangela/domain/enums/call_style.dart';
import 'package:guardianangela/domain/enums/countdown_style.dart';
import 'package:guardianangela/domain/enums/hold_style.dart';
import 'package:guardianangela/domain/enums/loud_alarm_sound.dart';
import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/enums/press_pattern.dart';
import 'package:guardianangela/domain/enums/voice_output_mode.dart';
import 'package:guardianangela/features/modes/widgets/config_fields.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Renders the type-specific configuration form for a [StepConfig].
///
/// Shared by the Mode Editor's `StepConfigPanel` (per-step config) and the
/// Event Defaults screen (global per-type defaults). Dispatches on the
/// sealed [StepConfig] subtype — adding a new step type is a compile error
/// until a branch is added. Each field calls [onChanged] with an updated
/// config; the caller decides whether to persist immediately (Event
/// Defaults) or stage the change in a draft (Mode Editor). See spec 04
/// §Event configuration.
class EventSpecificConfig extends StatelessWidget {
  /// Creates an [EventSpecificConfig] for [config].
  const EventSpecificConfig({
    super.key,
    required this.config,
    required this.onChanged,
  });

  /// The current per-step config to edit.
  final StepConfig config;

  /// Called with an updated config whenever a field changes.
  final ValueChanged<StepConfig> onChanged;

  @override
  Widget build(BuildContext context) => switch (config) {
    final HoldButtonConfig c => _HoldButtonForm(
      config: c,
      onChanged: onChanged,
    ),
    final DisguisedReminderConfig c => _DisguisedReminderForm(
      config: c,
      onChanged: onChanged,
    ),
    final CountdownWarningConfig c => _CountdownWarningForm(
      config: c,
      onChanged: onChanged,
    ),
    final FakeCallConfig c => _FakeCallForm(config: c, onChanged: onChanged),
    final SmsContactConfig c => _SmsContactForm(
      config: c,
      onChanged: onChanged,
    ),
    final PhoneCallContactConfig c => _PhoneCallContactForm(
      config: c,
      onChanged: onChanged,
    ),
    final LoudAlarmConfig c => _LoudAlarmForm(config: c, onChanged: onChanged),
    final CallEmergencyConfig c => _CallEmergencyForm(
      config: c,
      onChanged: onChanged,
    ),
    final HardwareButtonConfig c => _HardwareButtonForm(
      config: c,
      onChanged: onChanged,
    ),
  };
}

// ─── Per-type forms ───────────────────────────────────────────────────────

class _HoldButtonForm extends StatelessWidget {
  const _HoldButtonForm({required this.config, required this.onChanged});

  final HoldButtonConfig config;
  final ValueChanged<HoldButtonConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        EnumDropdownField<HoldStyle>(
          label: l10n.eventDefaultsHoldStyle,
          values: HoldStyle.values,
          value: config.holdStyle,
          labelFor: (HoldStyle v) => v.name,
          onChanged: (HoldStyle v) => onChanged(config.copyWith(holdStyle: v)),
        ),
        DoubleSliderField(
          label: l10n.eventDefaultsHoldSensitivity,
          value: config.releaseSensitivity,
          min: 0.3,
          max: 3.0,
          onChanged: (double v) =>
              onChanged(config.copyWith(releaseSensitivity: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.eventDefaultsHoldVibrate),
          value: config.vibrateOnRelease,
          onChanged: (bool v) =>
              onChanged(config.copyWith(vibrateOnRelease: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.eventDefaultsHoldSound),
          value: config.soundOnRelease,
          onChanged: (bool v) => onChanged(config.copyWith(soundOnRelease: v)),
        ),
        _BlackScreenSwitch(
          value: config.blackScreenMode,
          onChanged: (bool v) => onChanged(config.copyWith(blackScreenMode: v)),
        ),
      ],
    );
  }
}

class _DisguisedReminderForm extends StatelessWidget {
  const _DisguisedReminderForm({required this.config, required this.onChanged});

  final DisguisedReminderConfig config;
  final ValueChanged<DisguisedReminderConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.eventDefaultsReminderRandomInterval),
          value: config.randomizeInterval,
          onChanged: (bool v) =>
              onChanged(config.copyWith(randomizeInterval: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.eventDefaultsReminderRandomTemplate),
          value: config.randomizeTemplateOrder,
          onChanged: (bool v) =>
              onChanged(config.copyWith(randomizeTemplateOrder: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.eventDefaultsReminderResetOnEarly),
          value: config.resetOnEarlyCheckIn,
          onChanged: (bool v) =>
              onChanged(config.copyWith(resetOnEarlyCheckIn: v)),
        ),
        _BlackScreenSwitch(
          value: config.blackScreenMode,
          onChanged: (bool v) => onChanged(config.copyWith(blackScreenMode: v)),
        ),
      ],
    );
  }
}

class _CountdownWarningForm extends StatelessWidget {
  const _CountdownWarningForm({required this.config, required this.onChanged});

  final CountdownWarningConfig config;
  final ValueChanged<CountdownWarningConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        EnumDropdownField<CountdownStyle>(
          label: l10n.eventDefaultsCountdownStyle,
          values: CountdownStyle.values,
          value: config.style,
          labelFor: (CountdownStyle v) => v.name,
          onChanged: (CountdownStyle v) => onChanged(config.copyWith(style: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.eventDefaultsCountdownVibrate),
          value: config.vibrate,
          onChanged: (bool v) => onChanged(config.copyWith(vibrate: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.eventDefaultsCountdownSound),
          value: config.sound,
          onChanged: (bool v) => onChanged(config.copyWith(sound: v)),
        ),
        _BlackScreenSwitch(
          value: config.blackScreenMode,
          onChanged: (bool v) => onChanged(config.copyWith(blackScreenMode: v)),
        ),
      ],
    );
  }
}

class _FakeCallForm extends StatelessWidget {
  const _FakeCallForm({required this.config, required this.onChanged});

  final FakeCallConfig config;
  final ValueChanged<FakeCallConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        EnumDropdownField<CallStyle>(
          label: l10n.eventDefaultsFakeCallStyle,
          values: CallStyle.values,
          value: config.callStyle,
          labelFor: (CallStyle v) => v.name,
          onChanged: (CallStyle v) => onChanged(config.copyWith(callStyle: v)),
        ),
        LabeledTextField(
          label: l10n.eventDefaultsFakeCallCallerName,
          value: config.callerName,
          onChanged: (String v) =>
              onChanged(config.copyWith(callerName: v.isEmpty ? 'Angela' : v)),
        ),
        IntSpinnerField(
          label: l10n.eventDefaultsFakeCallRingDuration,
          value: config.ringDurationSeconds,
          min: 5,
          max: 120,
          onChanged: (int v) =>
              onChanged(config.copyWith(ringDurationSeconds: v)),
        ),
        EnumDropdownField<VoiceOutputMode>(
          label: l10n.eventDefaultsFakeCallVoiceOutput,
          values: VoiceOutputMode.values,
          value: config.voiceOutputMode,
          labelFor: (VoiceOutputMode v) => v.name,
          onChanged: (VoiceOutputMode v) =>
              onChanged(config.copyWith(voiceOutputMode: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.eventDefaultsFakeCallDeclineIsSafe),
          value: config.declineIsSafe,
          onChanged: (bool v) => onChanged(config.copyWith(declineIsSafe: v)),
        ),
        _BlackScreenSwitch(
          value: config.blackScreenMode,
          onChanged: (bool v) => onChanged(config.copyWith(blackScreenMode: v)),
        ),
      ],
    );
  }
}

class _SmsContactForm extends StatelessWidget {
  const _SmsContactForm({required this.config, required this.onChanged});

  final SmsContactConfig config;
  final ValueChanged<SmsContactConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        EnumDropdownField<MessageChannel>(
          label: l10n.eventDefaultsSmsChannel,
          values: MessageChannel.values,
          value: config.channel,
          labelFor: (MessageChannel v) => v.name,
          onChanged: (MessageChannel v) =>
              onChanged(config.copyWith(channel: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.eventDefaultsSmsIncludeLocation),
          value: config.includeLocation,
          onChanged: (bool v) => onChanged(config.copyWith(includeLocation: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.eventDefaultsSmsIncludeMedical),
          value: config.includeMedicalInfo,
          onChanged: (bool v) =>
              onChanged(config.copyWith(includeMedicalInfo: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.eventDefaultsSmsAutoRecord),
          value: config.autoRecordAudio,
          onChanged: (bool v) => onChanged(config.copyWith(autoRecordAudio: v)),
        ),
        if (config.autoRecordAudio)
          IntSpinnerField(
            label: l10n.eventDefaultsSmsRecordDuration,
            value: config.recordDurationSeconds,
            min: 5,
            max: 120,
            onChanged: (int v) =>
                onChanged(config.copyWith(recordDurationSeconds: v)),
          ),
        _BlackScreenSwitch(
          value: config.blackScreenMode,
          onChanged: (bool v) => onChanged(config.copyWith(blackScreenMode: v)),
        ),
      ],
    );
  }
}

class _PhoneCallContactForm extends StatelessWidget {
  const _PhoneCallContactForm({required this.config, required this.onChanged});

  final PhoneCallContactConfig config;
  final ValueChanged<PhoneCallContactConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        LabeledTextField(
          label: l10n.eventDefaultsPhonePrimaryContact,
          value: config.contactId ?? '',
          onChanged: (String v) =>
              onChanged(config.copyWith(contactId: v.isEmpty ? null : v)),
        ),
        _BlackScreenSwitch(
          value: config.blackScreenMode,
          onChanged: (bool v) => onChanged(config.copyWith(blackScreenMode: v)),
        ),
      ],
    );
  }
}

class _LoudAlarmForm extends StatelessWidget {
  const _LoudAlarmForm({required this.config, required this.onChanged});

  final LoudAlarmConfig config;
  final ValueChanged<LoudAlarmConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        DoubleSliderField(
          label: l10n.eventDefaultsLoudAlarmVolume,
          value: config.volume,
          min: 0,
          max: 1,
          onChanged: (double v) => onChanged(config.copyWith(volume: v)),
        ),
        EnumDropdownField<LoudAlarmSound>(
          label: l10n.eventDefaultsLoudAlarmSound,
          values: LoudAlarmSound.values,
          value: config.soundChoice,
          labelFor: (LoudAlarmSound v) => v.name,
          onChanged: (LoudAlarmSound v) =>
              onChanged(config.copyWith(soundChoice: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.eventDefaultsLoudAlarmFlashScreen),
          value: config.flashScreen,
          onChanged: (bool v) => onChanged(config.copyWith(flashScreen: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.eventDefaultsLoudAlarmFlashLight),
          value: config.flashLight,
          onChanged: (bool v) => onChanged(config.copyWith(flashLight: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.eventDefaultsLoudAlarmGradual),
          value: config.gradualVolume,
          onChanged: (bool v) => onChanged(config.copyWith(gradualVolume: v)),
        ),
        _BlackScreenSwitch(
          value: config.blackScreenMode,
          onChanged: (bool v) => onChanged(config.copyWith(blackScreenMode: v)),
        ),
      ],
    );
  }
}

class _CallEmergencyForm extends StatelessWidget {
  const _CallEmergencyForm({required this.config, required this.onChanged});

  final CallEmergencyConfig config;
  final ValueChanged<CallEmergencyConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        LabeledTextField(
          label: l10n.eventDefaultsCallEmergencyNumber,
          value: config.emergencyNumber ?? '',
          onChanged: (String v) =>
              onChanged(config.copyWith(emergencyNumber: v.isEmpty ? null : v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.eventDefaultsCallEmergencySmsFirst),
          value: config.sendLocationSmsFirst,
          onChanged: (bool v) =>
              onChanged(config.copyWith(sendLocationSmsFirst: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.eventDefaultsCallEmergencyConfirm),
          value: config.showConfirmation,
          onChanged: (bool v) =>
              onChanged(config.copyWith(showConfirmation: v)),
        ),
        if (config.showConfirmation)
          IntSpinnerField(
            label: l10n.eventDefaultsCallEmergencyConfirmDuration,
            value: config.confirmationDurationSeconds,
            max: 30,
            onChanged: (int v) =>
                onChanged(config.copyWith(confirmationDurationSeconds: v)),
          ),
        _BlackScreenSwitch(
          value: config.blackScreenMode,
          onChanged: (bool v) => onChanged(config.copyWith(blackScreenMode: v)),
        ),
      ],
    );
  }
}

class _HardwareButtonForm extends StatelessWidget {
  const _HardwareButtonForm({required this.config, required this.onChanged});

  final HardwareButtonConfig config;
  final ValueChanged<HardwareButtonConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isRepeat = config.pressPattern == PressPattern.repeatPress;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        EnumDropdownField<ButtonType>(
          label: l10n.eventDefaultsHardwareButton,
          values: ButtonType.values,
          value: config.buttonType,
          labelFor: (ButtonType v) => v.name,
          onChanged: (ButtonType v) =>
              onChanged(config.copyWith(buttonType: v)),
        ),
        EnumDropdownField<PressPattern>(
          label: l10n.eventDefaultsHardwarePattern,
          values: PressPattern.values,
          value: config.pressPattern,
          labelFor: (PressPattern v) => v.name,
          onChanged: (PressPattern v) =>
              onChanged(config.copyWith(pressPattern: v)),
        ),
        if (isRepeat)
          IntSpinnerField(
            label: l10n.eventDefaultsHardwarePressCount,
            value: config.pressCount,
            min: 2,
            max: 10,
            onChanged: (int v) => onChanged(config.copyWith(pressCount: v)),
          )
        else
          DoubleSliderField(
            label: l10n.eventDefaultsHardwareLongDuration,
            value: config.longPressDurationSeconds,
            min: 0.5,
            max: 10,
            onChanged: (double v) =>
                onChanged(config.copyWith(longPressDurationSeconds: v)),
          ),
        _BlackScreenSwitch(
          value: config.blackScreenMode,
          onChanged: (bool v) => onChanged(config.copyWith(blackScreenMode: v)),
        ),
      ],
    );
  }
}

// ─── Black-screen toggle (shared across all step types) ────────────────────

class _BlackScreenSwitch extends StatelessWidget {
  const _BlackScreenSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(l10n.eventDefaultsBlackScreen),
      value: value,
      onChanged: onChanged,
    );
  }
}
