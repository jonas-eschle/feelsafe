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

import 'package:guardianangela/core/widgets/timing_slider.dart';
import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/session_context.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy_registry.dart';
import 'package:guardianangela/features/modes/widgets/log_gps_selector.dart';
import 'package:guardianangela/features/modes/widgets/more_settings_panel.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
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
      ChainStepType.holdButton => _HoldButtonForm(
        step: step,
        onChanged: onChanged,
      ),
      ChainStepType.disguisedReminder => _DisguisedReminderForm(
        step: step,
        onChanged: onChanged,
      ),
      ChainStepType.countdownWarning => _CountdownForm(
        step: step,
        onChanged: onChanged,
      ),
      ChainStepType.fakeCall => _FakeCallForm(step: step, onChanged: onChanged),
      ChainStepType.smsContact => _SmsForm(step: step, onChanged: onChanged),
      ChainStepType.phoneCallContact => _PhoneForm(
        step: step,
        onChanged: onChanged,
      ),
      ChainStepType.loudAlarm => _LoudAlarmForm(
        step: step,
        onChanged: onChanged,
      ),
      ChainStepType.callEmergency => _EmergencyForm(
        step: step,
        onChanged: onChanged,
      ),
      ChainStepType.hardwareButton => _HardwareForm(
        step: step,
        onChanged: onChanged,
      ),
    };
    final canPreview =
        step.type == ChainStepType.fakeCall ||
        step.type == ChainStepType.loudAlarm ||
        step.type == ChainStepType.countdownWarning ||
        step.type == ChainStepType.disguisedReminder;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        form,
        // Spec 11 §DE-4: collapsible "More settings" tile hosts the
        // rare-toggle subset (currently the DE-2 GPS override).
        // Hidden by default; the badge counter on the collapsed
        // header surfaces non-default values without expanding.
        _StepMoreSettings(step: step, onChanged: onChanged),
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l.stepPreviewFired(description))));
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
      decoration: InputDecoration(
        labelText: l.stepConfigHoldReleaseSensitivity,
      ),
      onChanged: (v) => onChanged(
        step.copyWith(
          config: cfg.copyWith(
            releaseSensitivity: double.tryParse(v) ?? cfg.releaseSensitivity,
          ),
        ),
      ),
    );
  }
}

/// Disguised reminder event-specific form.
///
/// Bugs.json Note 3: `DisguisedReminderConfig.intervalSeconds` is
/// stored only for legacy round-trip — the engine drives reminder
/// cadence from `ChainStep.waitSeconds`. The interval input was
/// previously rendered here; it has been removed (the field stays on
/// the model so already-saved configs still deserialize). The
/// configurable timing for a disguised reminder now lives on the
/// timing panel above this widget.
class _DisguisedReminderForm extends StatelessWidget {
  const _DisguisedReminderForm({required this.step, required this.onChanged});
  final ChainStep step;
  final ValueChanged<ChainStep> onChanged;

  @override
  Widget build(BuildContext context) {
    // [step] / [onChanged] are unused while the form is empty but
    // kept so the constructor signature stays uniform with siblings.
    return const SizedBox.shrink();
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
          onChanged: (v) =>
              onChanged(step.copyWith(config: cfg.copyWith(vibrate: v))),
        ),
        SwitchListTile(
          value: cfg.playTone,
          title: Text(l.stepConfigCountdownTone),
          onChanged: (v) =>
              onChanged(step.copyWith(config: cfg.copyWith(playTone: v))),
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
          onChanged: (v) =>
              onChanged(step.copyWith(config: cfg.copyWith(declineIsSafe: v))),
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
    // Issue-v4 #6 — show the duration slider only when at least one
    // of the auto-record toggles is on. Surfacing the slider when
    // both are off would clutter the form with a value that has no
    // effect on the step's behaviour.
    final showRecordDuration = cfg.autoRecordAudio || cfg.autoRecordVideo;
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
            onChanged(step.copyWith(config: cfg.copyWith(contactSelection: v)));
          },
        ),
        SwitchListTile(
          value: cfg.includeLocation,
          title: Text(l.stepConfigSmsIncludeLocation),
          onChanged: (v) => onChanged(
            step.copyWith(config: cfg.copyWith(includeLocation: v)),
          ),
        ),
        SwitchListTile(
          value: cfg.includeMedicalInfo,
          title: Text(l.stepConfigSmsIncludeMedical),
          onChanged: (v) => onChanged(
            step.copyWith(config: cfg.copyWith(includeMedicalInfo: v)),
          ),
        ),
        SwitchListTile(
          value: cfg.autoRecordAudio,
          title: Text(l.stepConfigSmsAutoRecordAudio),
          onChanged: (v) => onChanged(
            step.copyWith(config: cfg.copyWith(autoRecordAudio: v)),
          ),
        ),
        SwitchListTile(
          value: cfg.autoRecordVideo,
          title: Text(l.stepConfigSmsAutoRecordVideo),
          onChanged: (v) => onChanged(
            step.copyWith(config: cfg.copyWith(autoRecordVideo: v)),
          ),
        ),
        if (showRecordDuration)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: TimingSlider(
              label: l.stepConfigSmsRecordDuration,
              seconds: cfg.recordDurationSeconds.clamp(
                _kMinRecordDurationSeconds,
                _kMaxRecordDurationSeconds,
              ),
              onChanged: (v) {
                final clamped = v.clamp(
                  _kMinRecordDurationSeconds,
                  _kMaxRecordDurationSeconds,
                );
                onChanged(
                  step.copyWith(
                    config: cfg.copyWith(recordDurationSeconds: clamped),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Issues-v4 #6 — minimum auto-record duration in seconds. Below 5 s
/// most platforms produce unusable clips (audio init lag, video
/// codec warm-up).
const int _kMinRecordDurationSeconds = 5;

/// Issues-v4 #6 — maximum auto-record duration in seconds. 5 minutes
/// keeps the on-disk file size bounded.
const int _kMaxRecordDurationSeconds = 300;

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
      onChanged: (v) =>
          onChanged(step.copyWith(config: cfg.copyWith(preSendSms: v))),
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
          onChanged: (v) =>
              onChanged(step.copyWith(config: cfg.copyWith(flashScreen: v))),
        ),
        SwitchListTile(
          value: cfg.maxVolume,
          title: Text(l.stepConfigLoudAlarmVolume),
          onChanged: (v) =>
              onChanged(step.copyWith(config: cfg.copyWith(maxVolume: v))),
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
          onChanged: (v) => onChanged(
            step.copyWith(
              // Fix for bugs.json historical Warn (copy-with clear
              // patterns): use `clearEmergencyNumber: true` for
              // empty text so the value is explicitly nulled.
              config: v.isEmpty
                  ? cfg.copyWith(clearEmergencyNumber: true)
                  : cfg.copyWith(emergencyNumber: v),
            ),
          ),
        ),
        SwitchListTile(
          value: cfg.showConfirmation,
          title: Text(l.stepConfigEmergencyConfirm),
          onChanged: (v) => onChanged(
            step.copyWith(config: cfg.copyWith(showConfirmation: v)),
          ),
        ),
      ],
    );
  }
}

/// Issues-v4 #9 — full inline hardware-button config.
///
/// Surfaces every persisted [HardwareButtonConfig] field:
/// * [HardwareButtonConfig.buttonType] — volume up/down or power.
/// * [HardwareButtonConfig.pattern] — repeat-press or long-press.
/// * [HardwareButtonConfig.pressCount] — visible only when pattern
///   is repeat-press (a longPress count is meaningless).
/// * [HardwareButtonConfig.pressWindowMs] — visible only when
///   pattern is repeat-press.
/// * [HardwareButtonConfig.longPressDurationSeconds] — visible only
///   when pattern is long-press.
///
/// *Why visibility is conditional:* mixing pattern-specific fields
/// in the same view makes the form hard to scan; users editing a
/// repeat-press shouldn't see the long-press duration.
class _HardwareForm extends StatefulWidget {
  const _HardwareForm({required this.step, required this.onChanged});
  final ChainStep step;
  final ValueChanged<ChainStep> onChanged;

  @override
  State<_HardwareForm> createState() => _HardwareFormState();
}

class _HardwareFormState extends State<_HardwareForm> {
  late TextEditingController _pressCountCtrl;
  late TextEditingController _pressWindowCtrl;
  late TextEditingController _longDurationCtrl;

  HardwareButtonConfig get _cfg => (widget.step.config is HardwareButtonConfig)
      ? widget.step.config! as HardwareButtonConfig
      : const HardwareButtonConfig();

  @override
  void initState() {
    super.initState();
    final cfg = _cfg;
    _pressCountCtrl = TextEditingController(text: cfg.pressCount.toString());
    _pressWindowCtrl = TextEditingController(
      text: cfg.pressWindowMs.toString(),
    );
    _longDurationCtrl = TextEditingController(
      text: cfg.longPressDurationSeconds.toStringAsFixed(1),
    );
  }

  @override
  void didUpdateWidget(covariant _HardwareForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    final cfg = _cfg;
    if (_pressCountCtrl.text != cfg.pressCount.toString()) {
      _pressCountCtrl.text = cfg.pressCount.toString();
    }
    if (_pressWindowCtrl.text != cfg.pressWindowMs.toString()) {
      _pressWindowCtrl.text = cfg.pressWindowMs.toString();
    }
    final newDuration = cfg.longPressDurationSeconds.toStringAsFixed(1);
    if (_longDurationCtrl.text != newDuration) {
      _longDurationCtrl.text = newDuration;
    }
  }

  @override
  void dispose() {
    _pressCountCtrl.dispose();
    _pressWindowCtrl.dispose();
    _longDurationCtrl.dispose();
    super.dispose();
  }

  void _emit(HardwareButtonConfig next) =>
      widget.onChanged(widget.step.copyWith(config: next));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cfg = _cfg;
    final isRepeat = cfg.pattern == HardwarePattern.repeatPress;
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
            _emit(cfg.copyWith(buttonType: v));
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
            _emit(cfg.copyWith(pattern: v));
          },
        ),
        if (isRepeat) ...[
          TextFormField(
            controller: _pressCountCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l.stepConfigHardwarePressCount,
            ),
            onChanged: (v) => _emit(
              cfg.copyWith(pressCount: int.tryParse(v) ?? cfg.pressCount),
            ),
          ),
          TextFormField(
            controller: _pressWindowCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l.stepConfigHardwarePressWindow,
            ),
            onChanged: (v) => _emit(
              cfg.copyWith(
                pressWindowMs: int.tryParse(v) ?? cfg.pressWindowMs,
              ),
            ),
          ),
        ] else ...[
          TextFormField(
            controller: _longDurationCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l.stepConfigHardwareLongDuration,
            ),
            onChanged: (v) => _emit(
              cfg.copyWith(
                longPressDurationSeconds:
                    double.tryParse(v) ?? cfg.longPressDurationSeconds,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// "More settings" tile (DE-4) hosting the rare-toggle fields for
/// the current step.
///
/// Currently wraps just the DE-2 [LogGpsSelector] but is the
/// single host for any future per-step rarity (D-OPS-3 non-blocking
/// flag, randomize toggles, custom sound paths, …).
class _StepMoreSettings extends ConsumerWidget {
  const _StepMoreSettings({required this.step, required this.onChanged});

  final ChainStep step;
  final ValueChanged<ChainStep> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider).value;
    // The fallback boolean shown under "Default" — sourced from the
    // global GPS-logging master toggle. Defaults to true when
    // settings haven't loaded so the UI stays predictable during
    // hydration.
    final fallback = settings?.defaults.gpsLogging.enabled ?? true;
    final currentLogGps = step.config?.logGps ?? LogGpsOverride.useDefault;
    final customizedCount =
        currentLogGps == LogGpsOverride.useDefault ? 0 : 1;
    return MoreSettingsPanel(
      customizedCount: customizedCount,
      children: [
        LogGpsSelector(
          value: currentLogGps,
          resolvedFallback: fallback,
          onChanged: (next) {
            final cfg = step.config;
            if (cfg == null) return;
            onChanged(step.copyWith(config: _withLogGps(cfg, next)));
          },
        ),
      ],
    );
  }

  /// Returns a copy of [config] with `logGps` replaced.
  ///
  /// *Why a switch:* the sealed parent declares `logGps` as an
  /// abstract getter so the only way to update it is to dispatch
  /// per concrete subtype's `copyWith`.
  StepConfig _withLogGps(StepConfig config, LogGpsOverride next) =>
      switch (config) {
        HoldButtonConfig() => config.copyWith(logGps: next),
        DisguisedReminderConfig() => config.copyWith(logGps: next),
        HardwareButtonConfig() => config.copyWith(logGps: next),
        CountdownWarningConfig() => config.copyWith(logGps: next),
        FakeCallConfig() => config.copyWith(logGps: next),
        SmsContactConfig() => config.copyWith(logGps: next),
        PhoneCallContactConfig() => config.copyWith(logGps: next),
        LoudAlarmConfig() => config.copyWith(logGps: next),
        CallEmergencyConfig() => config.copyWith(logGps: next),
      };
}
