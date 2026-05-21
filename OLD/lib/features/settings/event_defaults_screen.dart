/// Per-step-type event defaults configuration screen. Spec 04
/// §Defaults submenu — exposes `AppDefaults.eventDefaults`, one
/// ExpansionTile per `ChainStepType`. Each tile reveals a small
/// edit form for the most-relevant fields of that step's config.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/core/widgets/timing_slider.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/app_defaults.dart';
import 'package:guardianangela/domain/models/event_defaults.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Event-defaults screen.
class EventDefaultsScreen extends ConsumerWidget {
  /// Creates the event-defaults screen.
  const EventDefaultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider).value;
    final defaults = settings?.defaults ?? const AppDefaults();
    final eventDefaults = defaults.eventDefaults;
    return Scaffold(
      appBar: AppBar(title: Text(l.eventDefaultsTitle)),
      body: ListView(
        children: [
          for (final type in ChainStepType.values)
            _StepTile(
              type: type,
              eventDefaults: eventDefaults,
              onUpdated: (next) => _save(ref, defaults, next),
            ),
        ],
      ),
    );
  }

  void _save(WidgetRef ref, AppDefaults defaults, EventDefaults next) {
    final notifier = ref.read(settingsControllerProvider.notifier);
    notifier.setDefaults(defaults.copyWith(eventDefaults: next));
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.type,
    required this.eventDefaults,
    required this.onUpdated,
  });

  final ChainStepType type;
  final EventDefaults eventDefaults;
  final ValueChanged<EventDefaults> onUpdated;

  @override
  Widget build(BuildContext context) => ExpansionTile(
        title: Text(_titleFor(type)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _bodyFor(context),
          ),
        ],
      );

  String _titleFor(ChainStepType t) => switch (t) {
        ChainStepType.holdButton => 'Hold button',
        ChainStepType.disguisedReminder => 'Disguised reminder',
        ChainStepType.countdownWarning => 'Countdown warning',
        ChainStepType.fakeCall => 'Fake call',
        ChainStepType.smsContact => 'SMS contact',
        ChainStepType.phoneCallContact => 'Phone call contact',
        ChainStepType.loudAlarm => 'Loud alarm',
        ChainStepType.callEmergency => 'Call emergency',
        ChainStepType.hardwareButton => 'Hardware button',
      };

  Widget _bodyFor(BuildContext context) => switch (type) {
        ChainStepType.holdButton => _HoldButtonEditor(
            cfg: eventDefaults.holdButton,
            onChanged: (c) => onUpdated(eventDefaults.copyWith(holdButton: c)),
          ),
        ChainStepType.disguisedReminder => _DisguisedReminderEditor(
            cfg: eventDefaults.disguisedReminder,
            onChanged: (c) =>
                onUpdated(eventDefaults.copyWith(disguisedReminder: c)),
          ),
        ChainStepType.countdownWarning => _CountdownWarningEditor(
            cfg: eventDefaults.countdownWarning,
            onChanged: (c) =>
                onUpdated(eventDefaults.copyWith(countdownWarning: c)),
          ),
        ChainStepType.fakeCall => _FakeCallEditor(
            cfg: eventDefaults.fakeCall,
            onChanged: (c) => onUpdated(eventDefaults.copyWith(fakeCall: c)),
          ),
        ChainStepType.smsContact => _SmsContactEditor(
            cfg: eventDefaults.smsContact,
            onChanged: (c) => onUpdated(eventDefaults.copyWith(smsContact: c)),
          ),
        ChainStepType.phoneCallContact => _PhoneCallContactEditor(
            cfg: eventDefaults.phoneCallContact,
            onChanged: (c) =>
                onUpdated(eventDefaults.copyWith(phoneCallContact: c)),
          ),
        ChainStepType.loudAlarm => _LoudAlarmEditor(
            cfg: eventDefaults.loudAlarm,
            onChanged: (c) => onUpdated(eventDefaults.copyWith(loudAlarm: c)),
          ),
        ChainStepType.callEmergency => _CallEmergencyEditor(
            cfg: eventDefaults.callEmergency,
            onChanged: (c) =>
                onUpdated(eventDefaults.copyWith(callEmergency: c)),
          ),
        ChainStepType.hardwareButton => _HardwareButtonEditor(
            cfg: eventDefaults.hardwareButton,
            onChanged: (c) =>
                onUpdated(eventDefaults.copyWith(hardwareButton: c)),
          ),
      };
}

class _HoldButtonEditor extends StatelessWidget {
  const _HoldButtonEditor({required this.cfg, required this.onChanged});
  final HoldButtonConfig cfg;
  final ValueChanged<HoldButtonConfig> onChanged;
  @override
  Widget build(BuildContext context) => TextFormField(
        initialValue: cfg.releaseSensitivity.toString(),
        decoration: const InputDecoration(labelText: 'Release sensitivity (s)'),
        keyboardType: TextInputType.number,
        onChanged: (v) {
          final d = double.tryParse(v);
          if (d != null) onChanged(cfg.copyWith(releaseSensitivity: d));
        },
      );
}

class _DisguisedReminderEditor extends StatelessWidget {
  const _DisguisedReminderEditor({
    required this.cfg,
    required this.onChanged,
  });
  final DisguisedReminderConfig cfg;
  final ValueChanged<DisguisedReminderConfig> onChanged;
  @override
  Widget build(BuildContext context) => TimingSlider(
        label: 'Interval',
        seconds: cfg.intervalSeconds,
        onChanged: (v) => onChanged(cfg.copyWith(intervalSeconds: v)),
      );
}

class _CountdownWarningEditor extends StatelessWidget {
  const _CountdownWarningEditor({required this.cfg, required this.onChanged});
  final CountdownWarningConfig cfg;
  final ValueChanged<CountdownWarningConfig> onChanged;
  @override
  Widget build(BuildContext context) => Column(
        children: [
          SwitchListTile(
            title: const Text('Vibrate'),
            value: cfg.vibrate,
            onChanged: (v) => onChanged(cfg.copyWith(vibrate: v)),
          ),
          SwitchListTile(
            title: const Text('Play tone'),
            value: cfg.playTone,
            onChanged: (v) => onChanged(cfg.copyWith(playTone: v)),
          ),
        ],
      );
}

class _FakeCallEditor extends StatelessWidget {
  const _FakeCallEditor({required this.cfg, required this.onChanged});
  final FakeCallConfig cfg;
  final ValueChanged<FakeCallConfig> onChanged;
  @override
  Widget build(BuildContext context) => Column(
        children: [
          TextFormField(
            initialValue: cfg.callerName ?? '',
            decoration: const InputDecoration(labelText: 'Caller name'),
            onChanged: (v) =>
                onChanged(cfg.copyWith(callerName: v.isEmpty ? null : v)),
          ),
          SwitchListTile(
            title: const Text('Decline is safe'),
            value: cfg.declineIsSafe,
            onChanged: (v) => onChanged(cfg.copyWith(declineIsSafe: v)),
          ),
        ],
      );
}

class _SmsContactEditor extends StatelessWidget {
  const _SmsContactEditor({required this.cfg, required this.onChanged});
  final SmsContactConfig cfg;
  final ValueChanged<SmsContactConfig> onChanged;
  @override
  Widget build(BuildContext context) => Column(
        children: [
          DropdownButtonFormField<MessageChannel>(
            initialValue: cfg.channel,
            decoration: const InputDecoration(labelText: 'Channel'),
            items: const [
              DropdownMenuItem(
                value: MessageChannel.sms,
                child: Text('SMS'),
              ),
              DropdownMenuItem(
                value: MessageChannel.whatsapp,
                child: Text('WhatsApp'),
              ),
              DropdownMenuItem(
                value: MessageChannel.telegram,
                child: Text('Telegram'),
              ),
            ],
            onChanged: (v) {
              if (v != null) onChanged(cfg.copyWith(channel: v));
            },
          ),
          SwitchListTile(
            title: const Text('Include location'),
            value: cfg.includeLocation,
            onChanged: (v) => onChanged(cfg.copyWith(includeLocation: v)),
          ),
        ],
      );
}

class _PhoneCallContactEditor extends StatelessWidget {
  const _PhoneCallContactEditor({required this.cfg, required this.onChanged});
  final PhoneCallContactConfig cfg;
  final ValueChanged<PhoneCallContactConfig> onChanged;
  @override
  // Q12: PhoneCallContact has no pre-SMS toggle anymore — that lives
  // on CallEmergencyConfig.sendLocationSmsFirst now. Phone-call-contact
  // currently has no editable defaults beyond GPS-logging override
  // (handled by the shared LogGpsSelector).
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _LoudAlarmEditor extends StatelessWidget {
  const _LoudAlarmEditor({required this.cfg, required this.onChanged});
  final LoudAlarmConfig cfg;
  final ValueChanged<LoudAlarmConfig> onChanged;
  @override
  Widget build(BuildContext context) => Column(
        children: [
          SwitchListTile(
            title: const Text('Flash screen'),
            value: cfg.flashScreen,
            onChanged: (v) => onChanged(cfg.copyWith(flashScreen: v)),
          ),
          SwitchListTile(
            title: const Text('Max volume'),
            value: cfg.maxVolume,
            onChanged: (v) => onChanged(cfg.copyWith(maxVolume: v)),
          ),
          SwitchListTile(
            title: const Text('Flashlight strobe'),
            value: cfg.flashLight,
            onChanged: (v) => onChanged(cfg.copyWith(flashLight: v)),
          ),
        ],
      );
}

class _CallEmergencyEditor extends StatelessWidget {
  const _CallEmergencyEditor({required this.cfg, required this.onChanged});
  final CallEmergencyConfig cfg;
  final ValueChanged<CallEmergencyConfig> onChanged;
  @override
  Widget build(BuildContext context) => SwitchListTile(
        title: const Text('Show confirmation'),
        value: cfg.showConfirmation,
        onChanged: (v) => onChanged(cfg.copyWith(showConfirmation: v)),
      );
}

class _HardwareButtonEditor extends StatelessWidget {
  const _HardwareButtonEditor({required this.cfg, required this.onChanged});
  final HardwareButtonConfig cfg;
  final ValueChanged<HardwareButtonConfig> onChanged;
  @override
  Widget build(BuildContext context) => Column(
        children: [
          TextFormField(
            initialValue: cfg.pressCount.toString(),
            decoration: const InputDecoration(labelText: 'Press count'),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              final n = int.tryParse(v);
              if (n != null) onChanged(cfg.copyWith(pressCount: n));
            },
          ),
          DropdownButtonFormField<ButtonType>(
            initialValue: cfg.buttonType,
            decoration: const InputDecoration(labelText: 'Button'),
            items: const [
              DropdownMenuItem(
                value: ButtonType.volumeUp,
                child: Text('Volume up'),
              ),
              DropdownMenuItem(
                value: ButtonType.volumeDown,
                child: Text('Volume down'),
              ),
              DropdownMenuItem(
                value: ButtonType.power,
                child: Text('Power'),
              ),
            ],
            onChanged: (v) {
              if (v != null) onChanged(cfg.copyWith(buttonType: v));
            },
          ),
        ],
      );
}
