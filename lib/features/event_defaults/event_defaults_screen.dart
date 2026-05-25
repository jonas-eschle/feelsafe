import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/button_type.dart';
import 'package:guardianangela/domain/enums/call_style.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/countdown_style.dart';
import 'package:guardianangela/domain/enums/hold_style.dart';
import 'package:guardianangela/domain/enums/loud_alarm_sound.dart';
import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/enums/press_pattern.dart';
import 'package:guardianangela/domain/enums/voice_output_mode.dart';
import 'package:guardianangela/domain/models/event_defaults.dart';
import 'package:guardianangela/features/event_defaults/event_defaults_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Event defaults screen.
///
/// Renders an [ExpansionTile] per step type with inline per-field editors
/// for the typed [StepConfig] defaults. Changes auto-save through
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
        error: (Object e, _) => Center(child: Text('Error: $e')),
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
    return Card(
      child: ExpansionTile(
        leading: Icon(_iconFor(type)),
        title: Text(type.name),
        subtitle: Text(_descriptionFor(type)),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: switch (type) {
              ChainStepType.holdButton => _HoldButtonForm(
                config: defaults.holdButton,
                onChanged: (HoldButtonConfig c) => _save(ref, c),
              ),
              ChainStepType.disguisedReminder => _DisguisedReminderForm(
                config: defaults.disguisedReminder,
                onChanged: (DisguisedReminderConfig c) => _save(ref, c),
              ),
              ChainStepType.countdownWarning => _CountdownWarningForm(
                config: defaults.countdownWarning,
                onChanged: (CountdownWarningConfig c) => _save(ref, c),
              ),
              ChainStepType.fakeCall => _FakeCallForm(
                config: defaults.fakeCall,
                onChanged: (FakeCallConfig c) => _save(ref, c),
              ),
              ChainStepType.smsContact => _SmsContactForm(
                config: defaults.smsContact,
                onChanged: (SmsContactConfig c) => _save(ref, c),
              ),
              ChainStepType.phoneCallContact => _PhoneCallContactForm(
                config: defaults.phoneCallContact,
                onChanged: (PhoneCallContactConfig c) => _save(ref, c),
              ),
              ChainStepType.loudAlarm => _LoudAlarmForm(
                config: defaults.loudAlarm,
                onChanged: (LoudAlarmConfig c) => _save(ref, c),
              ),
              ChainStepType.callEmergency => _CallEmergencyForm(
                config: defaults.callEmergency,
                onChanged: (CallEmergencyConfig c) => _save(ref, c),
              ),
              ChainStepType.hardwareButton => _HardwareButtonForm(
                config: defaults.hardwareButton,
                onChanged: (HardwareButtonConfig c) => _save(ref, c),
              ),
            },
          ),
        ],
      ),
    );
  }

  IconData _iconFor(ChainStepType t) {
    return switch (t) {
      ChainStepType.holdButton => Icons.touch_app_outlined,
      ChainStepType.disguisedReminder => Icons.notifications_outlined,
      ChainStepType.countdownWarning => Icons.warning_amber_outlined,
      ChainStepType.fakeCall => Icons.phone_outlined,
      ChainStepType.smsContact => Icons.message_outlined,
      ChainStepType.phoneCallContact => Icons.phone_forwarded_outlined,
      ChainStepType.loudAlarm => Icons.volume_up_outlined,
      ChainStepType.callEmergency => Icons.emergency_outlined,
      ChainStepType.hardwareButton => Icons.touch_app,
    };
  }

  String _descriptionFor(ChainStepType t) {
    return switch (t) {
      ChainStepType.holdButton =>
        'Hold to stay safe — releasing starts a grace countdown.',
      ChainStepType.disguisedReminder =>
        'Sends a disguised notification — respond to confirm safety.',
      ChainStepType.countdownWarning =>
        'Shows a countdown with sound and flash as a last warning.',
      ChainStepType.fakeCall =>
        'Simulates an incoming call — answer or decline.',
      ChainStepType.smsContact =>
        'Sends an SMS with your location to emergency contacts.',
      ChainStepType.phoneCallContact => 'Calls an emergency contact directly.',
      ChainStepType.loudAlarm =>
        'Plays a max-volume alarm with flash to attract attention.',
      ChainStepType.callEmergency =>
        'Calls emergency services (112/911) automatically.',
      ChainStepType.hardwareButton =>
        'Watches a hardware button for a panic press pattern.',
    };
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
        _EnumDropdown<HoldStyle>(
          label: l10n.eventDefaultsHoldStyle,
          values: HoldStyle.values,
          value: config.holdStyle,
          labelFor: (HoldStyle v) => v.name,
          onChanged: (HoldStyle v) => onChanged(config.copyWith(holdStyle: v)),
        ),
        _DoubleSlider(
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
        _EnumDropdown<CountdownStyle>(
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
        _EnumDropdown<CallStyle>(
          label: l10n.eventDefaultsFakeCallStyle,
          values: CallStyle.values,
          value: config.callStyle,
          labelFor: (CallStyle v) => v.name,
          onChanged: (CallStyle v) => onChanged(config.copyWith(callStyle: v)),
        ),
        _TextField(
          label: l10n.eventDefaultsFakeCallCallerName,
          value: config.callerName,
          onChanged: (String v) =>
              onChanged(config.copyWith(callerName: v.isEmpty ? 'Angela' : v)),
        ),
        _IntSpinner(
          label: l10n.eventDefaultsFakeCallRingDuration,
          value: config.ringDurationSeconds,
          min: 5,
          max: 120,
          onChanged: (int v) =>
              onChanged(config.copyWith(ringDurationSeconds: v)),
        ),
        _EnumDropdown<VoiceOutputMode>(
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
        _EnumDropdown<MessageChannel>(
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
          _IntSpinner(
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
        _TextField(
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
        _DoubleSlider(
          label: l10n.eventDefaultsLoudAlarmVolume,
          value: config.volume,
          min: 0,
          max: 1,
          onChanged: (double v) => onChanged(config.copyWith(volume: v)),
        ),
        _EnumDropdown<LoudAlarmSound>(
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
        _TextField(
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
          _IntSpinner(
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
        _EnumDropdown<ButtonType>(
          label: l10n.eventDefaultsHardwareButton,
          values: ButtonType.values,
          value: config.buttonType,
          labelFor: (ButtonType v) => v.name,
          onChanged: (ButtonType v) =>
              onChanged(config.copyWith(buttonType: v)),
        ),
        _EnumDropdown<PressPattern>(
          label: l10n.eventDefaultsHardwarePattern,
          values: PressPattern.values,
          value: config.pressPattern,
          labelFor: (PressPattern v) => v.name,
          onChanged: (PressPattern v) =>
              onChanged(config.copyWith(pressPattern: v)),
        ),
        if (isRepeat)
          _IntSpinner(
            label: l10n.eventDefaultsHardwarePressCount,
            value: config.pressCount,
            min: 2,
            max: 10,
            onChanged: (int v) => onChanged(config.copyWith(pressCount: v)),
          )
        else
          _DoubleSlider(
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

// ─── Shared editor widgets ────────────────────────────────────────────────

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

class _EnumDropdown<T> extends StatelessWidget {
  const _EnumDropdown({
    required this.label,
    required this.values,
    required this.value,
    required this.labelFor,
    required this.onChanged,
  });

  final String label;
  final List<T> values;
  final T value;
  final String Function(T) labelFor;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            isExpanded: true,
            value: value,
            items: <DropdownMenuItem<T>>[
              for (final v in values)
                DropdownMenuItem<T>(value: v, child: Text(labelFor(v))),
            ],
            onChanged: (T? v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ),
    );
  }
}

class _DoubleSlider extends StatelessWidget {
  const _DoubleSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('$label: ${value.toStringAsFixed(2)}'),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _IntSpinner extends StatelessWidget {
  const _IntSpinner({
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    required this.max,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: value <= min ? null : () => onChanged(value - 1),
          ),
          Text(value.toString()),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: value >= max ? null : () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _TextField extends StatefulWidget {
  const _TextField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<_TextField> createState() => _TextFieldState();
}

class _TextFieldState extends State<_TextField> {
  late final TextEditingController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _TextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && widget.value != _ctl.text) {
      _ctl.text = widget.value;
    }
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: _ctl,
        decoration: InputDecoration(labelText: widget.label),
        onSubmitted: widget.onChanged,
        onEditingComplete: () => widget.onChanged(_ctl.text),
      ),
    );
  }
}
