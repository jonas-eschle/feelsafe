/// Event-specific config widget dispatching on [ChainStepType].
///
/// CRITICAL D-UI-2: the "Preview" button fires the matching
/// [EventStrategy] via [EventStrategyRegistry] with an
/// [EventServices] bundle built from the simulation providers. That
/// is what makes the preview actually run the real strategy logic
/// in simulation mode (no side effects on the device).
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/session_context.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy_registry.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Edits the typed [StepConfig] for a single [ChainStep].
class EventSpecificConfig extends ConsumerWidget {
  /// Creates the config editor.
  const EventSpecificConfig({
    super.key,
    required this.step,
    required this.onChanged,
  });

  /// The step under edit.
  final ChainStep step;

  /// Callback fired with the updated step.
  final ValueChanged<ChainStep> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final form = switch (step.type) {
      ChainStepType.holdButton => _HoldButtonForm(step: step, onChanged: onChanged),
      ChainStepType.disguisedReminder =>
        _DisguisedReminderForm(step: step, onChanged: onChanged),
      ChainStepType.countdownWarning =>
        _CountdownForm(step: step, onChanged: onChanged),
      ChainStepType.fakeCall => _FakeCallForm(step: step, onChanged: onChanged),
      ChainStepType.smsContact => _SmsForm(step: step, onChanged: onChanged),
      ChainStepType.phoneCallContact =>
        _PhoneForm(step: step, onChanged: onChanged),
      ChainStepType.loudAlarm => _LoudAlarmForm(step: step, onChanged: onChanged),
      ChainStepType.callEmergency =>
        _EmergencyForm(step: step, onChanged: onChanged),
      ChainStepType.hardwareButton =>
        _HardwareForm(step: step, onChanged: onChanged),
    };
    final canPreview = step.type == ChainStepType.fakeCall ||
        step.type == ChainStepType.loudAlarm ||
        step.type == ChainStepType.countdownWarning ||
        step.type == ChainStepType.disguisedReminder;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        form,
        if (canPreview) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: Text(l.stepPreview),
            onPressed: () => _runPreview(context, ref),
          ),
        ],
      ],
    );
  }

  Future<void> _runPreview(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final services = EventServices(
      audio: ref.read(simulationAudioProvider),
      messaging: ref.read(simulationMessagingProvider),
      phone: ref.read(simulationPhoneProvider),
      notification: ref.read(simulationNotificationProvider),
      vibration: ref.read(simulationVibrationProvider),
      context: SessionContext(
        mode: SessionMode(
          id: 'preview',
          name: 'Preview',
          checkInType: step.type,
          chainSteps: [step],
        ),
        contacts: const [],
        userProfile: null,
        isSimulation: true,
        reminderTemplates: const [],
      ),
      isCancelled: () => false,
    );
    final strategy = EventStrategyRegistry.forStep(step);
    final description = strategy.simulationDescription(step, services);
    // Execute the real strategy in simulation mode — this is D-UI-2.
    await strategy.executeReal(step, services);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.stepPreviewFired(description))),
    );
  }
}

class _HoldButtonForm extends StatelessWidget {
  const _HoldButtonForm({required this.step, required this.onChanged});
  final ChainStep step;
  final ValueChanged<ChainStep> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cfg = (step.config is HoldButtonConfig)
        ? step.config! as HoldButtonConfig
        : const HoldButtonConfig();
    return TextFormField(
      initialValue: cfg.releaseSensitivity.toString(),
      keyboardType: TextInputType.number,
      decoration:
          InputDecoration(labelText: l.stepConfigHoldReleaseSensitivity),
      onChanged: (v) => onChanged(step.copyWith(
        config: cfg.copyWith(
          releaseSensitivity: double.tryParse(v) ?? cfg.releaseSensitivity,
        ),
      )),
    );
  }
}

class _DisguisedReminderForm extends StatelessWidget {
  const _DisguisedReminderForm({
    required this.step,
    required this.onChanged,
  });
  final ChainStep step;
  final ValueChanged<ChainStep> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cfg = (step.config is DisguisedReminderConfig)
        ? step.config! as DisguisedReminderConfig
        : const DisguisedReminderConfig();
    return TextFormField(
      initialValue: cfg.intervalSeconds.toString(),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: l.stepConfigReminderInterval),
      onChanged: (v) => onChanged(step.copyWith(
        config: cfg.copyWith(
          intervalSeconds: int.tryParse(v) ?? cfg.intervalSeconds,
        ),
      )),
    );
  }
}

class _CountdownForm extends StatelessWidget {
  const _CountdownForm({required this.step, required this.onChanged});
  final ChainStep step;
  final ValueChanged<ChainStep> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cfg = (step.config is CountdownWarningConfig)
        ? step.config! as CountdownWarningConfig
        : const CountdownWarningConfig();
    return Column(
      children: [
        SwitchListTile(
          value: cfg.vibrate,
          title: Text(l.stepConfigCountdownVibrate),
          onChanged: (v) => onChanged(step.copyWith(
            config: cfg.copyWith(vibrate: v),
          )),
        ),
        SwitchListTile(
          value: cfg.playTone,
          title: Text(l.stepConfigCountdownTone),
          onChanged: (v) => onChanged(step.copyWith(
            config: cfg.copyWith(playTone: v),
          )),
        ),
      ],
    );
  }
}

class _FakeCallForm extends StatelessWidget {
  const _FakeCallForm({required this.step, required this.onChanged});
  final ChainStep step;
  final ValueChanged<ChainStep> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cfg = (step.config is FakeCallConfig)
        ? step.config! as FakeCallConfig
        : const FakeCallConfig();
    return Column(
      children: [
        TextFormField(
          initialValue: cfg.callerName ?? '',
          decoration: InputDecoration(labelText: l.stepConfigFakeCallCaller),
          onChanged: (v) =>
              onChanged(step.copyWith(config: cfg.copyWith(callerName: v))),
        ),
        SwitchListTile(
          value: cfg.declineIsSafe,
          title: Text(l.stepConfigFakeCallDecline),
          onChanged: (v) => onChanged(step.copyWith(
            config: cfg.copyWith(declineIsSafe: v),
          )),
        ),
      ],
    );
  }
}

class _SmsForm extends StatelessWidget {
  const _SmsForm({required this.step, required this.onChanged});
  final ChainStep step;
  final ValueChanged<ChainStep> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cfg = (step.config is SmsContactConfig)
        ? step.config! as SmsContactConfig
        : const SmsContactConfig();
    return Column(
      children: [
        DropdownButtonFormField<SmsContactSelection>(
          initialValue: cfg.contactSelection,
          decoration: InputDecoration(labelText: l.stepConfigSmsSelection),
          items: [
            DropdownMenuItem(
              value: SmsContactSelection.allContacts,
              child: Text(l.stepConfigSmsAllContacts),
            ),
            DropdownMenuItem(
              value: SmsContactSelection.specificIds,
              child: Text(l.stepConfigSmsSpecific),
            ),
          ],
          onChanged: (v) {
            if (v == null) return;
            onChanged(step.copyWith(
              config: cfg.copyWith(contactSelection: v),
            ));
          },
        ),
        SwitchListTile(
          value: cfg.includeLocation,
          title: Text(l.stepConfigSmsIncludeLocation),
          onChanged: (v) => onChanged(step.copyWith(
            config: cfg.copyWith(includeLocation: v),
          )),
        ),
        SwitchListTile(
          value: cfg.includeMedicalInfo,
          title: Text(l.stepConfigSmsIncludeMedical),
          onChanged: (v) => onChanged(step.copyWith(
            config: cfg.copyWith(includeMedicalInfo: v),
          )),
        ),
      ],
    );
  }
}

class _PhoneForm extends StatelessWidget {
  const _PhoneForm({required this.step, required this.onChanged});
  final ChainStep step;
  final ValueChanged<ChainStep> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cfg = (step.config is PhoneCallContactConfig)
        ? step.config! as PhoneCallContactConfig
        : const PhoneCallContactConfig();
    return SwitchListTile(
      value: cfg.preSendSms,
      title: Text(l.stepConfigPhonePreSms),
      onChanged: (v) => onChanged(step.copyWith(
        config: cfg.copyWith(preSendSms: v),
      )),
    );
  }
}

class _LoudAlarmForm extends StatelessWidget {
  const _LoudAlarmForm({required this.step, required this.onChanged});
  final ChainStep step;
  final ValueChanged<ChainStep> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cfg = (step.config is LoudAlarmConfig)
        ? step.config! as LoudAlarmConfig
        : const LoudAlarmConfig();
    return Column(
      children: [
        SwitchListTile(
          value: cfg.flashScreen,
          title: Text(l.stepConfigLoudAlarmFlash),
          onChanged: (v) => onChanged(step.copyWith(
            config: cfg.copyWith(flashScreen: v),
          )),
        ),
        SwitchListTile(
          value: cfg.maxVolume,
          title: Text(l.stepConfigLoudAlarmVolume),
          onChanged: (v) => onChanged(step.copyWith(
            config: cfg.copyWith(maxVolume: v),
          )),
        ),
      ],
    );
  }
}

class _EmergencyForm extends StatelessWidget {
  const _EmergencyForm({required this.step, required this.onChanged});
  final ChainStep step;
  final ValueChanged<ChainStep> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cfg = (step.config is CallEmergencyConfig)
        ? step.config! as CallEmergencyConfig
        : const CallEmergencyConfig();
    return Column(
      children: [
        TextFormField(
          initialValue: cfg.emergencyNumber ?? '',
          decoration: InputDecoration(labelText: l.stepConfigEmergencyNumber),
          onChanged: (v) => onChanged(step.copyWith(
            config: cfg.copyWith(emergencyNumber: v.isEmpty ? null : v),
          )),
        ),
        SwitchListTile(
          value: cfg.confirmBeforeCalling,
          title: Text(l.stepConfigEmergencyConfirm),
          onChanged: (v) => onChanged(step.copyWith(
            config: cfg.copyWith(confirmBeforeCalling: v),
          )),
        ),
      ],
    );
  }
}

class _HardwareForm extends StatelessWidget {
  const _HardwareForm({required this.step, required this.onChanged});
  final ChainStep step;
  final ValueChanged<ChainStep> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cfg = (step.config is HardwareButtonConfig)
        ? step.config! as HardwareButtonConfig
        : const HardwareButtonConfig();
    return Column(
      children: [
        DropdownButtonFormField<ButtonType>(
          initialValue: cfg.buttonType,
          decoration: InputDecoration(labelText: l.stepConfigHardwareButton),
          items: [
            DropdownMenuItem(
              value: ButtonType.volumeUp,
              child: Text(l.stepConfigHardwareButtonVolumeUp),
            ),
            DropdownMenuItem(
              value: ButtonType.volumeDown,
              child: Text(l.stepConfigHardwareButtonVolumeDown),
            ),
            DropdownMenuItem(
              value: ButtonType.power,
              child: Text(l.stepConfigHardwareButtonPower),
            ),
          ],
          onChanged: (v) {
            if (v == null) return;
            onChanged(step.copyWith(
              config: cfg.copyWith(buttonType: v),
            ));
          },
        ),
        DropdownButtonFormField<HardwarePattern>(
          initialValue: cfg.pattern,
          decoration: InputDecoration(labelText: l.stepConfigHardwarePattern),
          items: [
            DropdownMenuItem(
              value: HardwarePattern.repeatPress,
              child: Text(l.stepConfigHardwarePatternRepeat),
            ),
            DropdownMenuItem(
              value: HardwarePattern.longPress,
              child: Text(l.stepConfigHardwarePatternLong),
            ),
          ],
          onChanged: (v) {
            if (v == null) return;
            onChanged(step.copyWith(
              config: cfg.copyWith(pattern: v),
            ));
          },
        ),
        TextFormField(
          initialValue: cfg.pressCount.toString(),
          keyboardType: TextInputType.number,
          decoration:
              InputDecoration(labelText: l.stepConfigHardwarePressCount),
          onChanged: (v) => onChanged(step.copyWith(
            config: cfg.copyWith(pressCount: int.tryParse(v) ?? cfg.pressCount),
          )),
        ),
      ],
    );
  }
}
