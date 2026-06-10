import 'package:flutter/material.dart';

import 'package:guardianangela/core/widgets/info_icon_button.dart';
import 'package:guardianangela/domain/enums/button_type.dart';
import 'package:guardianangela/domain/enums/gps_destination_source.dart';
import 'package:guardianangela/domain/enums/press_pattern.dart';
import 'package:guardianangela/domain/models/event_defaults.dart';
import 'package:guardianangela/domain/models/gps_logging_config.dart';
import 'package:guardianangela/domain/models/mode_overrides.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/stealth_config.dart';
import 'package:guardianangela/domain/triggers/disarm_trigger.dart';
import 'package:guardianangela/domain/triggers/distress_trigger.dart';
import 'package:guardianangela/features/modes/widgets/config_fields.dart';
import 'package:guardianangela/features/modes/widgets/gps_logging_fields.dart';
import 'package:guardianangela/features/modes/widgets/mode_event_defaults.dart';
import 'package:guardianangela/features/modes/widgets/stealth_config_fields.dart';
import 'package:guardianangela/features/template_editor/reminder_template_form.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// The override state of a [ModeOverrides] config field with an `enabled`
/// flag (GPS logging, stealth).
///
/// Maps the spec's three-state selector (Inherit / Custom / Off) onto the
/// underlying nullable override. A null override is [inherit]; a non-null
/// override with `enabled = false` is [off]; otherwise [custom].
enum _TriState { inherit, custom, off }

/// The collapsible "Safety options" section at the bottom of the mode editor.
///
/// Edits the [SessionMode]-level fields that are not part of the escalation
/// chain (spec 04 §Mode — Safety Options, §Distress Mode Editor):
/// distress-mode picker, distress triggers, disarm triggers, GPS-logging /
/// stealth / event-defaults overrides, and mode-local templates. In the
/// distress variant the distress-mode picker is hidden and an
/// "Allow disarm while active as distress" toggle (G-014) appears instead.
///
/// Every change is staged through [onChanged] against the editor's in-memory
/// draft; nothing is persisted until the user saves the mode.
class SafetyOptionsSection extends StatelessWidget {
  /// Creates a [SafetyOptionsSection].
  const SafetyOptionsSection({
    super.key,
    required this.mode,
    required this.onChanged,
    required this.isDistress,
    required this.distressModes,
    required this.defaultDistressModeId,
    required this.onManageDistressModes,
    required this.onManageTemplates,
  });

  /// The mode draft being edited.
  final SessionMode mode;

  /// Called with the updated draft whenever a field changes.
  final ValueChanged<SessionMode> onChanged;

  /// Whether the editor is in distress-mode variant.
  final bool isDistress;

  /// All distress modes, for the distress-mode picker (excluding [mode]
  /// itself when it is a distress mode).
  final List<SessionMode> distressModes;

  /// The app-wide default distress mode id (shown as the "Use default"
  /// hint in the picker). Null when none is configured.
  final String? defaultDistressModeId;

  /// Opens the distress-modes management screen.
  final VoidCallback onManageDistressModes;

  /// Opens the global reminder-templates screen.
  final VoidCallback onManageTemplates;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: ExpansionTile(
        title: Text(l10n.safetyOptionsHeader),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (!isDistress)
            _DistressModePicker(
              mode: mode,
              onChanged: onChanged,
              distressModes: distressModes,
              defaultDistressModeId: defaultDistressModeId,
              onManageDistressModes: onManageDistressModes,
            ),
          _DistressTriggersEditor(mode: mode, onChanged: onChanged),
          _DisarmTriggersEditor(mode: mode, onChanged: onChanged),
          _GpsLoggingTriState(mode: mode, onChanged: onChanged),
          _StealthTriState(mode: mode, onChanged: onChanged),
          _LocalTemplatesEditor(
            mode: mode,
            onChanged: onChanged,
            onManageTemplates: onManageTemplates,
          ),
          _EventDefaultsTriState(mode: mode, onChanged: onChanged),
          if (isDistress)
            _AllowDisarmAsDistressToggle(mode: mode, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// A flush subsection header row with an inline [InfoIconButton].
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.infoBody});

  final String title;
  final String infoBody;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleSmall),
          ),
          InfoIconButton(title: title, body: infoBody),
        ],
      ),
    );
  }
}

// ─── Distress-mode picker ──────────────────────────────────────────────────

class _DistressModePicker extends StatelessWidget {
  const _DistressModePicker({
    required this.mode,
    required this.onChanged,
    required this.distressModes,
    required this.defaultDistressModeId,
    required this.onManageDistressModes,
  });

  final SessionMode mode;
  final ValueChanged<SessionMode> onChanged;
  final List<SessionMode> distressModes;
  final String? defaultDistressModeId;
  final VoidCallback onManageDistressModes;

  void _select(String? id) {
    // copyWith cannot null distressModeId; clearing requires direct
    // construction so "Use default" persists as null.
    onChanged(_modeWithDistressModeId(mode, id));
  }

  /// The "Use default" label, naming the resolved default mode when known.
  String _defaultLabel(AppLocalizations l10n) {
    final Iterable<SessionMode> match = distressModes.where(
      (SessionMode m) => m.id == defaultDistressModeId,
    );
    return match.isEmpty
        ? l10n.safetyOptionsDistressModeUseDefault
        : l10n.safetyOptionsDistressModeUseDefaultNamed(match.first.name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // The stored id may reference a mode no longer present; fall back to the
    // "use default" sentinel so the dropdown always has a valid value.
    final bool known = distressModes.any(
      (SessionMode m) => m.id == mode.distressModeId,
    );
    final String? value = known ? mode.distressModeId : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SectionHeader(
          title: l10n.safetyOptionsDistressModeTitle,
          infoBody: l10n.safetyOptionsDistressModeInfo,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: l10n.safetyOptionsDistressModeTitle,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                isExpanded: true,
                value: value,
                items: <DropdownMenuItem<String?>>[
                  DropdownMenuItem<String?>(child: Text(_defaultLabel(l10n))),
                  for (final SessionMode m in distressModes)
                    DropdownMenuItem<String?>(value: m.id, child: Text(m.name)),
                ],
                onChanged: _select,
              ),
            ),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: onManageDistressModes,
            icon: const Icon(Icons.chevron_right),
            label: Text(l10n.safetyOptionsManageDistressModes),
          ),
        ),
      ],
    );
  }
}

// ─── Distress triggers ─────────────────────────────────────────────────────

class _DistressTriggersEditor extends StatelessWidget {
  const _DistressTriggersEditor({required this.mode, required this.onChanged});

  final SessionMode mode;
  final ValueChanged<SessionMode> onChanged;

  void _replaceAt(int index, DistressTrigger updated) {
    final List<DistressTrigger> next = <DistressTrigger>[
      ...mode.distressTriggers,
    ];
    next[index] = updated;
    onChanged(mode.copyWith(distressTriggers: next));
  }

  void _removeAt(int index) {
    final List<DistressTrigger> next = <DistressTrigger>[
      ...mode.distressTriggers,
    ]..removeAt(index);
    onChanged(mode.copyWith(distressTriggers: next));
  }

  void _add() {
    onChanged(
      mode.copyWith(
        distressTriggers: <DistressTrigger>[
          ...mode.distressTriggers,
          const HardwareButtonDistressTrigger(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SectionHeader(
          title: l10n.safetyOptionsDistressTriggersTitle,
          infoBody: l10n.safetyOptionsDistressTriggersInfo,
        ),
        if (mode.distressTriggers.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n.safetyOptionsDistressTriggersEmpty,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          )
        else
          for (int i = 0; i < mode.distressTriggers.length; i++)
            _HardwareTriggerTile(
              key: ValueKey<int>(i),
              trigger:
                  mode.distressTriggers[i] as HardwareButtonDistressTrigger,
              onChanged: (HardwareButtonDistressTrigger t) => _replaceAt(i, t),
              onRemove: () => _removeAt(i),
            ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: _add,
            icon: const Icon(Icons.add),
            label: Text(l10n.safetyOptionsAddHardwarePanic),
          ),
        ),
      ],
    );
  }
}

/// Expandable editor for a single [HardwareButtonDistressTrigger].
class _HardwareTriggerTile extends StatelessWidget {
  const _HardwareTriggerTile({
    super.key,
    required this.trigger,
    required this.onChanged,
    required this.onRemove,
  });

  final HardwareButtonDistressTrigger trigger;
  final ValueChanged<HardwareButtonDistressTrigger> onChanged;
  final VoidCallback onRemove;

  String _buttonLabel(ButtonType t, AppLocalizations l10n) => switch (t) {
    ButtonType.volumeUp => l10n.safetyOptionsButtonVolumeUp,
    ButtonType.volumeDown => l10n.safetyOptionsButtonVolumeDown,
  };

  String _patternLabel(PressPattern p, AppLocalizations l10n) => switch (p) {
    PressPattern.repeatPress => l10n.safetyOptionsPatternRepeat,
    PressPattern.longPress => l10n.safetyOptionsPatternLong,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bool isRepeat = trigger.pattern == PressPattern.repeatPress;
    final String summary = isRepeat
        ? l10n.safetyOptionsTriggerHardwareRepeat(
            _buttonLabel(trigger.buttonType, l10n),
            trigger.pressCount.toString(),
          )
        : l10n.safetyOptionsTriggerHardwareLong(
            _buttonLabel(trigger.buttonType, l10n),
            (trigger.durationSeconds ?? 2.0).toStringAsFixed(1),
          );
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(summary),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: l10n.commonDelete,
        onPressed: onRemove,
      ),
      childrenPadding: const EdgeInsets.only(bottom: 8),
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        EnumDropdownField<ButtonType>(
          label: l10n.safetyOptionsTriggerButton,
          values: ButtonType.values,
          value: trigger.buttonType,
          labelFor: (ButtonType v) => _buttonLabel(v, l10n),
          onChanged: (ButtonType v) =>
              onChanged(_triggerWithButton(trigger, v)),
        ),
        EnumDropdownField<PressPattern>(
          label: l10n.safetyOptionsTriggerPattern,
          values: PressPattern.values,
          value: trigger.pattern,
          labelFor: (PressPattern v) => _patternLabel(v, l10n),
          onChanged: (PressPattern v) =>
              onChanged(_triggerWithPattern(trigger, v)),
        ),
        if (isRepeat)
          IntSpinnerField(
            label: l10n.safetyOptionsTriggerPressCount,
            value: trigger.pressCount,
            min: 2,
            max: 10,
            onChanged: (int v) => onChanged(_triggerWithPressCount(trigger, v)),
          )
        else
          DoubleSliderField(
            label: l10n.safetyOptionsTriggerHoldDuration,
            value: trigger.durationSeconds ?? 2.0,
            min: 0.5,
            max: 10,
            onChanged: (double v) =>
                onChanged(_triggerWithDuration(trigger, v)),
          ),
      ],
    );
  }
}

// ─── Disarm triggers ───────────────────────────────────────────────────────

class _DisarmTriggersEditor extends StatelessWidget {
  const _DisarmTriggersEditor({required this.mode, required this.onChanged});

  final SessionMode mode;
  final ValueChanged<SessionMode> onChanged;

  GpsArrivalDisarmTrigger? get _gps {
    final Iterable<GpsArrivalDisarmTrigger> matches = mode.disarmTriggers
        .whereType<GpsArrivalDisarmTrigger>();
    return matches.isEmpty ? null : matches.first;
  }

  TimerDisarmTrigger? get _timer {
    final Iterable<TimerDisarmTrigger> matches = mode.disarmTriggers
        .whereType<TimerDisarmTrigger>();
    return matches.isEmpty ? null : matches.first;
  }

  /// Replaces the list with [gps]/[timer] preserved if non-null.
  void _commit({
    required GpsArrivalDisarmTrigger? gps,
    required TimerDisarmTrigger? timer,
  }) {
    onChanged(mode.copyWith(disarmTriggers: <DisarmTrigger>[?gps, ?timer]));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final GpsArrivalDisarmTrigger? gps = _gps;
    final TimerDisarmTrigger? timer = _timer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            l10n.safetyOptionsDisarmTriggersTitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        _GpsArrivalDisarm(
          trigger: gps,
          onChanged: (GpsArrivalDisarmTrigger? g) =>
              _commit(gps: g, timer: timer),
        ),
        _TimerDisarm(
          trigger: timer,
          onChanged: (TimerDisarmTrigger? t) => _commit(gps: gps, timer: t),
        ),
      ],
    );
  }
}

class _GpsArrivalDisarm extends StatelessWidget {
  const _GpsArrivalDisarm({required this.trigger, required this.onChanged});

  final GpsArrivalDisarmTrigger? trigger;
  final ValueChanged<GpsArrivalDisarmTrigger?> onChanged;

  String _radiusLabel(int meters, AppLocalizations l10n) => meters >= 1000
      ? l10n.safetyOptionsRadiusKilometers((meters / 1000).toStringAsFixed(1))
      : l10n.safetyOptionsRadiusMeters(meters.toString());

  String _sourceLabel(GpsDestinationSource s, AppLocalizations l10n) =>
      switch (s) {
        GpsDestinationSource.promptAtStart =>
          l10n.safetyOptionsDestinationPrompt,
        GpsDestinationSource.fixed => l10n.safetyOptionsDestinationFixed,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final GpsArrivalDisarmTrigger? t = trigger;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.safetyOptionsGpsArrivalTitle),
                value: t != null,
                onChanged: (bool on) =>
                    onChanged(on ? const GpsArrivalDisarmTrigger() : null),
              ),
            ),
            InfoIconButton(
              title: l10n.safetyOptionsGpsArrivalTitle,
              body: l10n.safetyOptionsGpsArrivalInfo,
            ),
          ],
        ),
        if (t != null) ...<Widget>[
          Text(
            '${l10n.safetyOptionsGpsArrivalRadius}: '
            '${_radiusLabel(t.radiusMeters, l10n)}',
          ),
          Slider(
            value: t.radiusMeters.clamp(50, 5000).toDouble(),
            min: 50,
            max: 5000,
            onChanged: (double v) => onChanged(_gpsWithRadius(t, v.round())),
          ),
          EnumDropdownField<GpsDestinationSource>(
            label: l10n.safetyOptionsDestinationSource,
            values: GpsDestinationSource.values,
            value: t.destinationSource,
            labelFor: (GpsDestinationSource v) => _sourceLabel(v, l10n),
            onChanged: (GpsDestinationSource v) =>
                onChanged(_gpsWithSource(t, v)),
          ),
          if (t.destinationSource == GpsDestinationSource.fixed) ...<Widget>[
            LabeledTextField(
              label: l10n.safetyOptionsLatitude,
              value: t.lat?.toString() ?? '',
              onChanged: (String v) =>
                  onChanged(_gpsWithLat(t, double.tryParse(v))),
            ),
            LabeledTextField(
              label: l10n.safetyOptionsLongitude,
              value: t.lng?.toString() ?? '',
              onChanged: (String v) =>
                  onChanged(_gpsWithLng(t, double.tryParse(v))),
            ),
          ],
        ],
      ],
    );
  }
}

class _TimerDisarm extends StatelessWidget {
  const _TimerDisarm({required this.trigger, required this.onChanged});

  final TimerDisarmTrigger? trigger;
  final ValueChanged<TimerDisarmTrigger?> onChanged;

  String _durationLabel(int seconds, AppLocalizations l10n) {
    final int totalMinutes = seconds ~/ 60;
    if (totalMinutes < 60) {
      return l10n.safetyOptionsDurationMinutes(totalMinutes.toString());
    }
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;
    return minutes == 0
        ? l10n.safetyOptionsDurationHoursMinutes(hours.toString(), '0')
        : l10n.safetyOptionsDurationHoursMinutes(
            hours.toString(),
            minutes.toString(),
          );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final TimerDisarmTrigger? t = trigger;
    // 5 min … 8 h, in 5-minute steps.
    const int minSeconds = 5 * 60;
    const int maxSeconds = 8 * 60 * 60;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.safetyOptionsTimerDisarmTitle),
                value: t != null,
                onChanged: (bool on) => onChanged(
                  on
                      ? const TimerDisarmTrigger(durationSeconds: 30 * 60)
                      : null,
                ),
              ),
            ),
            InfoIconButton(
              title: l10n.safetyOptionsTimerDisarmTitle,
              body: l10n.safetyOptionsTimerDisarmInfo,
            ),
          ],
        ),
        if (t != null) ...<Widget>[
          Text(
            '${l10n.safetyOptionsTimerDuration}: '
            '${_durationLabel(t.durationSeconds, l10n)}',
          ),
          Slider(
            value: t.durationSeconds.clamp(minSeconds, maxSeconds).toDouble(),
            min: minSeconds.toDouble(),
            max: maxSeconds.toDouble(),
            divisions: (maxSeconds - minSeconds) ~/ 300,
            onChanged: (double v) {
              final int snapped = (v / 300).round() * 300;
              onChanged(TimerDisarmTrigger(durationSeconds: snapped));
            },
          ),
        ],
      ],
    );
  }
}

// ─── GPS-logging tri-state ─────────────────────────────────────────────────

class _GpsLoggingTriState extends StatelessWidget {
  const _GpsLoggingTriState({required this.mode, required this.onChanged});

  final SessionMode mode;
  final ValueChanged<SessionMode> onChanged;

  _TriState get _state {
    final GpsLoggingConfig? cfg = mode.overrides?.gpsLogging;
    if (cfg == null) return _TriState.inherit;
    return cfg.enabled ? _TriState.custom : _TriState.off;
  }

  void _setState(_TriState s) {
    final GpsLoggingConfig? next = switch (s) {
      _TriState.inherit => null,
      _TriState.custom =>
        (mode.overrides?.gpsLogging ?? const GpsLoggingConfig()).copyWith(
          enabled: true,
        ),
      _TriState.off => GpsLoggingConfig.off,
    };
    onChanged(_modeWithGpsLogging(mode, next));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final _TriState state = _state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SectionHeader(
          title: l10n.safetyOptionsGpsLoggingTitle,
          infoBody: l10n.safetyOptionsGpsLoggingInfo,
        ),
        _TriStateSelector(state: state, onChanged: _setState),
        if (state == _TriState.custom)
          GpsLoggingFields(
            config: mode.overrides!.gpsLogging!,
            onChanged: (GpsLoggingConfig c) =>
                onChanged(_modeWithGpsLogging(mode, c)),
          ),
      ],
    );
  }
}

// ─── Stealth tri-state ─────────────────────────────────────────────────────

class _StealthTriState extends StatelessWidget {
  const _StealthTriState({required this.mode, required this.onChanged});

  final SessionMode mode;
  final ValueChanged<SessionMode> onChanged;

  _TriState get _state {
    final StealthConfig? cfg = mode.overrides?.stealth;
    if (cfg == null) return _TriState.inherit;
    return cfg.enabled ? _TriState.custom : _TriState.off;
  }

  void _setState(_TriState s) {
    final StealthConfig? next = switch (s) {
      _TriState.inherit => null,
      _TriState.custom =>
        (mode.overrides?.stealth ?? const StealthConfig()).copyWith(
          enabled: true,
        ),
      _TriState.off => const StealthConfig(),
    };
    onChanged(_modeWithStealth(mode, next));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final _TriState state = _state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SectionHeader(
          title: l10n.safetyOptionsStealthTitle,
          infoBody: l10n.safetyOptionsStealthInfo,
        ),
        _TriStateSelector(state: state, onChanged: _setState),
        if (state == _TriState.custom)
          StealthConfigFields(
            config: mode.overrides!.stealth!,
            onChanged: (StealthConfig c) =>
                onChanged(_modeWithStealth(mode, c)),
          ),
      ],
    );
  }
}

/// A three-option [SegmentedButton] over [_TriState].
class _TriStateSelector extends StatelessWidget {
  const _TriStateSelector({required this.state, required this.onChanged});

  final _TriState state;
  final ValueChanged<_TriState> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SegmentedButton<_TriState>(
        segments: <ButtonSegment<_TriState>>[
          ButtonSegment<_TriState>(
            value: _TriState.inherit,
            label: Text(l10n.safetyOptionsTriStateInherit),
          ),
          ButtonSegment<_TriState>(
            value: _TriState.custom,
            label: Text(l10n.safetyOptionsTriStateCustom),
          ),
          ButtonSegment<_TriState>(
            value: _TriState.off,
            label: Text(l10n.safetyOptionsTriStateOff),
          ),
        ],
        selected: <_TriState>{state},
        showSelectedIcon: false,
        onSelectionChanged: (Set<_TriState> s) => onChanged(s.first),
      ),
    );
  }
}

// ─── Mode-local templates ──────────────────────────────────────────────────

class _LocalTemplatesEditor extends StatelessWidget {
  const _LocalTemplatesEditor({
    required this.mode,
    required this.onChanged,
    required this.onManageTemplates,
  });

  final SessionMode mode;
  final ValueChanged<SessionMode> onChanged;
  final VoidCallback onManageTemplates;

  List<ReminderTemplate> get _templates =>
      mode.overrides?.localTemplates ?? const <ReminderTemplate>[];

  void _remove(String id) {
    final List<ReminderTemplate> remaining = <ReminderTemplate>[
      for (final ReminderTemplate t in _templates)
        if (t.id != id) t,
    ];
    onChanged(
      _modeWithLocalTemplates(mode, remaining.isEmpty ? null : remaining),
    );
  }

  /// Opens the reminder-template editor for a new mode-local template and
  /// stages the result (`isGlobal: false`) into the draft on Save.
  Future<void> _add(BuildContext context) async {
    final ReminderTemplate? created = await Navigator.of(context).push(
      MaterialPageRoute<ReminderTemplate>(
        fullscreenDialog: true,
        builder: (_) => const _LocalTemplateEditorSheet(),
      ),
    );
    if (created == null) return;
    onChanged(
      _modeWithLocalTemplates(mode, <ReminderTemplate>[..._templates, created]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final List<ReminderTemplate> templates = _templates;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SectionHeader(
          title: l10n.safetyOptionsLocalTemplatesTitle,
          infoBody: l10n.safetyOptionsLocalTemplatesInfo,
        ),
        if (templates.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n.safetyOptionsLocalTemplatesEmpty,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          )
        else
          for (final ReminderTemplate t in templates)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.collections_outlined),
              title: Text(t.name),
              subtitle: Text(t.title),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.commonDelete,
                onPressed: () => _remove(t.id),
              ),
            ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: () => _add(context),
            icon: const Icon(Icons.add),
            label: Text(l10n.safetyOptionsAddTemplate),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: onManageTemplates,
            icon: const Icon(Icons.chevron_right),
            label: Text(l10n.safetyOptionsManageTemplates),
          ),
        ),
      ],
    );
  }
}

/// A full-screen editor for a new mode-local reminder template.
///
/// Reuses the shared [ReminderTemplateForm] body; on Save it returns a fresh
/// `isCustom: true`, `isGlobal: false` [ReminderTemplate] via `Navigator.pop`
/// for the [_LocalTemplatesEditor] to stage into the draft. Nothing is written
/// to the database — the mode editor persists the whole draft on its own Save.
class _LocalTemplateEditorSheet extends StatefulWidget {
  const _LocalTemplateEditorSheet();

  @override
  State<_LocalTemplateEditorSheet> createState() =>
      _LocalTemplateEditorSheetState();
}

class _LocalTemplateEditorSheetState extends State<_LocalTemplateEditorSheet> {
  final GlobalKey<ReminderTemplateFormState> _formKey =
      GlobalKey<ReminderTemplateFormState>();

  void _save() {
    final ReminderTemplate? created = _formKey.currentState?.buildTemplate(
      existing: null,
      isGlobal: false,
    );
    if (created == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name, title, and body required.')),
      );
      return;
    }
    Navigator.of(context).pop(created);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.templatesCreateTitle),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonCancel),
          ),
          TextButton(onPressed: _save, child: Text(l10n.commonSave)),
        ],
      ),
      body: SafeArea(child: ReminderTemplateForm(key: _formKey)),
    );
  }
}

// ─── Event-defaults tri-state (Inherit / Custom) ───────────────────────────

class _EventDefaultsTriState extends StatelessWidget {
  const _EventDefaultsTriState({required this.mode, required this.onChanged});

  final SessionMode mode;
  final ValueChanged<SessionMode> onChanged;

  void _setCustom(bool custom) {
    onChanged(
      _modeWithEventDefaults(mode, custom ? const EventDefaults() : null),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final EventDefaults? overrides = mode.overrides?.eventDefaults;
    final bool isCustom = overrides != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SectionHeader(
          title: l10n.safetyOptionsEventDefaultsTitle,
          infoBody: l10n.safetyOptionsEventDefaultsInfo,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: SegmentedButton<bool>(
            segments: <ButtonSegment<bool>>[
              ButtonSegment<bool>(
                value: false,
                label: Text(l10n.safetyOptionsEventDefaultsTwoStateInherit),
              ),
              ButtonSegment<bool>(
                value: true,
                label: Text(l10n.safetyOptionsTriStateCustom),
              ),
            ],
            selected: <bool>{isCustom},
            showSelectedIcon: false,
            onSelectionChanged: (Set<bool> s) => _setCustom(s.first),
          ),
        ),
        if (isCustom)
          ModeEventDefaults(
            defaults: overrides,
            onChanged: (EventDefaults d) =>
                onChanged(_modeWithEventDefaults(mode, d)),
          ),
      ],
    );
  }
}

// ─── allowDisarmAsDistress (distress variant only) ─────────────────────────

class _AllowDisarmAsDistressToggle extends StatelessWidget {
  const _AllowDisarmAsDistressToggle({
    required this.mode,
    required this.onChanged,
  });

  final SessionMode mode;
  final ValueChanged<SessionMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.safetyOptionsAllowDisarmAsDistressTitle),
            value: mode.allowDisarmAsDistress,
            onChanged: (bool v) =>
                onChanged(mode.copyWith(allowDisarmAsDistress: v)),
          ),
        ),
        InfoIconButton(
          title: l10n.safetyOptionsAllowDisarmAsDistressTitle,
          body: l10n.safetyOptionsAllowDisarmAsDistressInfo,
        ),
      ],
    );
  }
}

// ─── Direct-construction helpers (copyWith cannot null a field) ─────────────

/// Returns [mode] with [distressModeId] set (or cleared when null).
SessionMode _modeWithDistressModeId(SessionMode mode, String? distressModeId) =>
    SessionMode(
      id: mode.id,
      name: mode.name,
      iconName: mode.iconName,
      chainSteps: mode.chainSteps,
      distressModeId: distressModeId,
      distressTriggers: mode.distressTriggers,
      disarmTriggers: mode.disarmTriggers,
      overrides: mode.overrides,
      trackingEnabled: mode.trackingEnabled,
      trackingIntervalSeconds: mode.trackingIntervalSeconds,
      trackingBufferSize: mode.trackingBufferSize,
      pauseAllowed: mode.pauseAllowed,
      maxPauseMinutes: mode.maxPauseMinutes,
      isDistressMode: mode.isDistressMode,
      allowDisarmAsDistress: mode.allowDisarmAsDistress,
      isBuiltIn: mode.isBuiltIn,
    );

HardwareButtonDistressTrigger _triggerWithButton(
  HardwareButtonDistressTrigger t,
  ButtonType buttonType,
) => HardwareButtonDistressTrigger(
  buttonType: buttonType,
  pattern: t.pattern,
  pressCount: t.pressCount,
  durationSeconds: t.durationSeconds,
);

/// Switches the press pattern, normalising the pattern-irrelevant field so
/// save-time validation passes (repeat ⇒ duration null; long ⇒ default hold).
HardwareButtonDistressTrigger _triggerWithPattern(
  HardwareButtonDistressTrigger t,
  PressPattern pattern,
) => switch (pattern) {
  PressPattern.repeatPress => HardwareButtonDistressTrigger(
    buttonType: t.buttonType,
    pressCount: t.pressCount,
  ),
  PressPattern.longPress => HardwareButtonDistressTrigger(
    buttonType: t.buttonType,
    pattern: PressPattern.longPress,
    durationSeconds: t.durationSeconds ?? 2.0,
  ),
};

HardwareButtonDistressTrigger _triggerWithPressCount(
  HardwareButtonDistressTrigger t,
  int pressCount,
) => HardwareButtonDistressTrigger(
  buttonType: t.buttonType,
  pattern: t.pattern,
  pressCount: pressCount,
  durationSeconds: t.durationSeconds,
);

HardwareButtonDistressTrigger _triggerWithDuration(
  HardwareButtonDistressTrigger t,
  double durationSeconds,
) => HardwareButtonDistressTrigger(
  buttonType: t.buttonType,
  pattern: t.pattern,
  durationSeconds: durationSeconds,
);

GpsArrivalDisarmTrigger _gpsWithRadius(
  GpsArrivalDisarmTrigger t,
  int radiusMeters,
) => GpsArrivalDisarmTrigger(
  radiusMeters: radiusMeters,
  destinationSource: t.destinationSource,
  lat: t.lat,
  lng: t.lng,
);

GpsArrivalDisarmTrigger _gpsWithSource(
  GpsArrivalDisarmTrigger t,
  GpsDestinationSource source,
) => GpsArrivalDisarmTrigger(
  radiusMeters: t.radiusMeters,
  destinationSource: source,
  lat: t.lat,
  lng: t.lng,
);

GpsArrivalDisarmTrigger _gpsWithLat(GpsArrivalDisarmTrigger t, double? lat) =>
    GpsArrivalDisarmTrigger(
      radiusMeters: t.radiusMeters,
      destinationSource: t.destinationSource,
      lat: lat,
      lng: t.lng,
    );

GpsArrivalDisarmTrigger _gpsWithLng(GpsArrivalDisarmTrigger t, double? lng) =>
    GpsArrivalDisarmTrigger(
      radiusMeters: t.radiusMeters,
      destinationSource: t.destinationSource,
      lat: t.lat,
      lng: lng,
    );

/// Returns [mode] with its [overrides] set (or cleared when null).
///
/// `copyWith` cannot null a field, so an all-inherit mode (overrides == null)
/// is built by direct construction; otherwise the override would leak.
SessionMode _modeWithOverrides(SessionMode mode, ModeOverrides? overrides) =>
    SessionMode(
      id: mode.id,
      name: mode.name,
      iconName: mode.iconName,
      chainSteps: mode.chainSteps,
      distressModeId: mode.distressModeId,
      distressTriggers: mode.distressTriggers,
      disarmTriggers: mode.disarmTriggers,
      overrides: overrides,
      trackingEnabled: mode.trackingEnabled,
      trackingIntervalSeconds: mode.trackingIntervalSeconds,
      trackingBufferSize: mode.trackingBufferSize,
      pauseAllowed: mode.pauseAllowed,
      maxPauseMinutes: mode.maxPauseMinutes,
      isDistressMode: mode.isDistressMode,
      allowDisarmAsDistress: mode.allowDisarmAsDistress,
      isBuiltIn: mode.isBuiltIn,
    );

/// Replaces the mode's GPS-logging override; [cfg] null clears it (inherit).
SessionMode _modeWithGpsLogging(SessionMode mode, GpsLoggingConfig? cfg) =>
    _modeWithOverrides(mode, _overridesWithGpsLogging(mode.overrides, cfg));

SessionMode _modeWithStealth(SessionMode mode, StealthConfig? cfg) =>
    _modeWithOverrides(mode, _overridesWithStealth(mode.overrides, cfg));

SessionMode _modeWithLocalTemplates(
  SessionMode mode,
  List<ReminderTemplate>? templates,
) => _modeWithOverrides(
  mode,
  _overridesWithLocalTemplates(mode.overrides, templates),
);

SessionMode _modeWithEventDefaults(SessionMode mode, EventDefaults? defaults) =>
    _modeWithOverrides(
      mode,
      _overridesWithEventDefaults(mode.overrides, defaults),
    );

/// Builds a [ModeOverrides] replacing only `gpsLogging`. Returns null when the
/// result would be empty so the mode stores no overrides at all.
ModeOverrides? _overridesWithGpsLogging(
  ModeOverrides? base,
  GpsLoggingConfig? cfg,
) => _normalised(
  ModeOverrides(
    gpsLogging: cfg,
    stealth: base?.stealth,
    localTemplates: base?.localTemplates,
    eventDefaults: base?.eventDefaults,
  ),
);

ModeOverrides? _overridesWithStealth(ModeOverrides? base, StealthConfig? cfg) =>
    _normalised(
      ModeOverrides(
        gpsLogging: base?.gpsLogging,
        stealth: cfg,
        localTemplates: base?.localTemplates,
        eventDefaults: base?.eventDefaults,
      ),
    );

ModeOverrides? _overridesWithLocalTemplates(
  ModeOverrides? base,
  List<ReminderTemplate>? templates,
) => _normalised(
  ModeOverrides(
    gpsLogging: base?.gpsLogging,
    stealth: base?.stealth,
    localTemplates: templates,
    eventDefaults: base?.eventDefaults,
  ),
);

ModeOverrides? _overridesWithEventDefaults(
  ModeOverrides? base,
  EventDefaults? defaults,
) => _normalised(
  ModeOverrides(
    gpsLogging: base?.gpsLogging,
    stealth: base?.stealth,
    localTemplates: base?.localTemplates,
    eventDefaults: defaults,
  ),
);

/// Returns null when [o] carries no overrides, so an all-inherit mode persists
/// `overrides = null` rather than an empty object.
ModeOverrides? _normalised(ModeOverrides o) =>
    (o.gpsLogging == null &&
        o.stealth == null &&
        o.localTemplates == null &&
        o.eventDefaults == null)
    ? null
    : o;
