/// Session-mode create / edit screen.
///
/// The mode's main chain is edited via [ChainStepTile]s
/// in a [ReorderableListView]. Below the chain the editor surfaces
/// collapsible sections for distress triggers and per-mode overrides
/// of [AppDefaults]. Tracking (spec 11 §DE-3) and the icon picker
/// are also exposed inline. The screen is wrapped in a [PopScope]
/// that asks for confirmation when leaving with unsaved changes.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/event_defaults.dart';
import 'package:guardianangela/domain/models/gps_logging_config.dart';
import 'package:guardianangela/domain/models/mode_overrides.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/models/stealth_config.dart';
import 'package:guardianangela/domain/models/trigger.dart';
import 'package:guardianangela/features/distress_modes/distress_modes_controller.dart';
import 'package:guardianangela/features/modes/modes_controller.dart';
import 'package:guardianangela/features/modes/widgets/chain_step_tile.dart';
import 'package:guardianangela/features/modes/widgets/mode_icon_library.dart';
import 'package:guardianangela/features/modes/widgets/step_type_picker.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Mode create / edit screen.
///
/// Phase 2.6: this screen now handles both regular session modes and
/// distress-flagged modes (`isDistress=true`). For distress modes
/// the irrelevant fields (icon, distress reference,
/// triggers, tracking, overrides) are hidden — distress modes only
/// expose the name and the chain steps.
class ModeEditorScreen extends ConsumerStatefulWidget {
  /// Creates the mode editor.
  ///
  /// [isDistress] — when true, the editor reads/writes a
  /// distress-flagged `SessionMode` (`isDistressMode=true`) and shows
  /// the simplified UI. Default `false`.
  const ModeEditorScreen({super.key, this.isDistress = false});

  /// True when this editor is used to manage a distress mode.
  final bool isDistress;

  @override
  ConsumerState<ModeEditorScreen> createState() => _ModeEditorScreenState();
}

/// Spec 11 §DE-3 — snap-stop list for the tracking-interval slider.
/// 10s → 1h. The slider position is the index into this list; the
/// label renders the value as human-readable text.
const List<int> _kTrackingIntervalSnapStops = <int>[
  10,
  30,
  60,
  120,
  300,
  600,
  900,
  1800,
  3600,
];

/// Lower bound of the tracking buffer-size slider (points).
const int _kMinTrackingBufferSize = 10;

/// Upper bound of the tracking buffer-size slider (points).
const int _kMaxTrackingBufferSize = 200;

class _ModeEditorScreenState extends ConsumerState<ModeEditorScreen> {
  // ---------- form state ----------
  SessionMode? _mode;
  final TextEditingController _nameCtrl = TextEditingController();
  String? _distressModeId;
  String? _iconName;
  List<ChainStep> _chain = const [];
  List<DistressTrigger> _distressTriggers = const [];
  ModeOverrides? _overrides;

  /// Spec 11 §DE-3 — interval-based GPS recording state.
  bool _trackingEnabled = false;
  int _trackingIntervalSeconds = 300;
  int _trackingBufferSize = 50;

  bool _hydrated = false;

  void _hydrate(List<SessionMode> modes) {
    if (_hydrated) return;
    _hydrated = true;
    final id = GoRouterState.of(context).uri.queryParameters['id'];
    if (id == null) return;
    for (final m in modes) {
      if (m.id == id) {
        _mode = m;
        _nameCtrl.text = m.name;
        _distressModeId = m.distressModeId;
        _iconName = m.iconName;
        _chain = List.of(m.chainSteps);
        _distressTriggers = List.of(m.distressTriggers);
        _overrides = m.overrides;
        _trackingEnabled = m.trackingEnabled;
        _trackingIntervalSeconds = m.trackingIntervalSeconds;
        _trackingBufferSize = m.trackingBufferSize.clamp(
          _kMinTrackingBufferSize,
          _kMaxTrackingBufferSize,
        );
        break;
      }
    }
  }

  /// True iff any field has diverged from the loaded mode.
  bool get _isDirty {
    final m = _mode;
    final loadedName = m?.name ?? '';
    final loadedChain = m?.chainSteps ?? const <ChainStep>[];
    final loadedDistress = m?.distressTriggers ?? const <DistressTrigger>[];
    final loadedOverrides = m?.overrides;
    final loadedIcon = m?.iconName;
    final loadedDistressChainId = m?.distressModeId;
    if (_nameCtrl.text.trim() != loadedName) return true;
    if (_distressModeId != loadedDistressChainId) return true;
    if (_iconName != loadedIcon) return true;
    if (!_listEquals(_chain, loadedChain)) return true;
    if (!_listEquals(_distressTriggers, loadedDistress)) return true;
    if (_overrides != loadedOverrides) return true;
    return false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final mode = _mode;
    final isDistress = widget.isDistress;
    final current = SessionMode(
      id: mode?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim().isEmpty ? 'Mode' : _nameCtrl.text.trim(),
      chainSteps: List.of(_chain),
      distressModeId: isDistress ? null : _distressModeId,
      distressTriggers: isDistress ? const [] : List.of(_distressTriggers),
      disarmTriggers: mode?.disarmTriggers ?? const [],
      overrides: isDistress ? null : _overrides,
      trackingEnabled: isDistress ? false : _trackingEnabled,
      trackingIntervalSeconds: _trackingIntervalSeconds,
      trackingBufferSize: _trackingBufferSize,
      iconName: isDistress ? null : _iconName,
      isDistressMode: isDistress,
    );
    if (isDistress) {
      await ref.read(distressModesControllerProvider.notifier).save(current);
    } else {
      await ref.read(modesControllerProvider.notifier).save(current);
    }
    if (mounted) context.pop();
  }

  Future<void> _addStep() async {
    final type = await showStepTypePicker(context);
    if (type == null) return;
    setState(() {
      _chain = [
        ..._chain,
        ChainStep(
          id: const Uuid().v4(),
          type: type,
          order: _chain.length,
          durationSeconds: 30,
          // Issues-v4 #16: hold-button grace defaults to 0 so the
          // countdown escalates immediately when it elapses. Other
          // step types keep the generic 15s grace.
          gracePeriodSeconds: type == ChainStepType.holdButton ? 0 : 15,
        ),
      ];
    });
  }

  void _duplicateStep(int index) {
    final src = _chain[index];
    final clone = ChainStep(
      id: const Uuid().v4(),
      type: src.type,
      order: src.order + 1,
      durationSeconds: src.durationSeconds,
      gracePeriodSeconds: src.gracePeriodSeconds,
      waitSeconds: src.waitSeconds,
      retryCount: src.retryCount,
      randomize: src.randomize,
      config: src.config,
    );
    setState(() {
      final list = [..._chain];
      list.insert(index + 1, clone);
      _chain = list;
    });
  }

  void _addDistressTrigger() {
    setState(() {
      _distressTriggers = [
        ..._distressTriggers,
        const HardwareButtonDistressTrigger(
          buttonType: ButtonType.volumeUp,
          trigger: RepeatPressTrigger(),
        ),
      ];
    });
  }

  void _replaceDistressTrigger(int index, DistressTrigger updated) {
    setState(() {
      final list = [..._distressTriggers];
      list[index] = updated;
      _distressTriggers = list;
    });
  }

  void _removeDistressTrigger(int index) {
    setState(() {
      final list = [..._distressTriggers]..removeAt(index);
      _distressTriggers = list;
    });
  }

  Future<bool> _confirmDiscard() async {
    if (!_isDirty) return true;
    final l = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.modeUnsavedTitle),
        content: Text(l.modeUnsavedBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.modeUnsavedKeep),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.modeUnsavedDiscard),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _pickIcon() async {
    final l = AppLocalizations.of(context);
    final picked = await showModalBottomSheet<String?>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l.modeIconPickerTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Flexible(
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 5,
                padding: const EdgeInsets.all(8),
                children: [
                  // First cell clears the icon selection — empty
                  // string is the sentinel for "clear" so we can
                  // distinguish it from a dismissed sheet (null).
                  IconButton(
                    icon: const Icon(Icons.do_not_disturb_alt),
                    tooltip: l.modeIconClear,
                    onPressed: () => Navigator.of(context).pop<String?>(''),
                  ),
                  for (final entry in kModeIconLibrary)
                    IconButton(
                      icon: Icon(entry.icon),
                      onPressed: () =>
                          Navigator.of(context).pop<String?>(entry.name),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    setState(() {
      _iconName = picked.isEmpty ? null : picked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDistress = widget.isDistress;
    final modesAsync = ref.watch(modesControllerProvider);
    if (!_hydrated) {
      modesAsync.whenData(_hydrate);
    }
    // Distress modes are SessionModes with isDistressMode=true,
    // surfaced via distressModesControllerProvider (filtered view of
    // the modes table). Only the regular-mode UI consumes this.
    final distressChains = isDistress
        ? const <SessionMode>[]
        : ref.watch(distressModesControllerProvider).value ?? const [];
    final createTitle = isDistress
        ? l.distressModeEditorTitleCreate
        : l.modeEditorTitleCreate;
    final editTitle = isDistress
        ? l.distressModeEditorTitleEdit
        : l.modeEditorTitleEdit;
    return PopScope<Object?>(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await _confirmDiscard()) {
          if (mounted) navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_mode == null ? createTitle : editTitle),
          actions: [
            IconButton(icon: const Icon(Icons.check), onPressed: _save),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (isDistress)
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(labelText: l.distressModeName),
                onChanged: (_) => setState(() {}),
              )
            else
              _NameAndIconRow(
                nameCtrl: _nameCtrl,
                iconName: _iconName,
                onIconTap: _pickIcon,
                onNameChanged: () => setState(() {}),
              ),
            if (!isDistress) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _distressModeId,
                decoration:
                    InputDecoration(labelText: l.modeFieldDistressMode),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l.modeFieldDistressModeDefault),
                  ),
                  for (final c in distressChains)
                    DropdownMenuItem<String?>(
                      value: c.id,
                      child: Text(c.name),
                    ),
                ],
                onChanged: (v) => setState(() => _distressModeId = v),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              l.modeChainHeader,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_chain.isEmpty)
              Text(l.modeChainEmpty)
            else
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: (o, n) => setState(() {
                  final list = List<ChainStep>.of(_chain);
                  final moved = list.removeAt(o);
                  final idx = n > o ? n - 1 : n;
                  list.insert(idx.clamp(0, list.length), moved);
                  _chain = list;
                }),
                children: [
                  for (var i = 0; i < _chain.length; i++)
                    ChainStepTile(
                      key: ValueKey(_chain[i].id),
                      step: _chain[i],
                      modeId: _mode?.id,
                      onChanged: (s) => setState(() {
                        _chain = [..._chain]..[i] = s;
                      }),
                      onDelete: () => setState(() {
                        _chain = [..._chain]..removeAt(i);
                      }),
                      onDuplicate: () => _duplicateStep(i),
                    ),
                ],
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: Text(l.modeChainAddStep),
              onPressed: _addStep,
            ),
            if (!isDistress) ...[
              const SizedBox(height: 24),
              // ---- Distress triggers ----
              _DistressTriggersSection(
                triggers: _distressTriggers,
                onAdd: _addDistressTrigger,
                onChanged: _replaceDistressTrigger,
                onRemove: _removeDistressTrigger,
              ),
              const SizedBox(height: 16),
              // ---- Mode overrides ----
              _ModeOverridesSection(
                overrides: _overrides,
                onChanged: (next) => setState(() => _overrides = next),
              ),
              const SizedBox(height: 16),
              // ---- Tracking (DE-3 — interval GPS recording) ----
              _TrackingSection(
                enabled: _trackingEnabled,
                intervalSeconds: _trackingIntervalSeconds,
                bufferSize: _trackingBufferSize,
                onEnabledChanged: (v) =>
                    setState(() => _trackingEnabled = v),
                onIntervalChanged: (v) =>
                    setState(() => _trackingIntervalSeconds = v),
                onBufferSizeChanged: (v) =>
                    setState(() => _trackingBufferSize = v),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Spec 11 §DE-3 — collapsible tracking-config section. Renders the
/// enable toggle, interval slider (snap-stops list), buffer-size
/// slider, and the battery-drain note.
class _TrackingSection extends StatelessWidget {
  const _TrackingSection({
    required this.enabled,
    required this.intervalSeconds,
    required this.bufferSize,
    required this.onEnabledChanged,
    required this.onIntervalChanged,
    required this.onBufferSizeChanged,
  });

  final bool enabled;
  final int intervalSeconds;
  final int bufferSize;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<int> onIntervalChanged;
  final ValueChanged<int> onBufferSizeChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.modeTrackingHeader,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SwitchListTile(
          value: enabled,
          onChanged: onEnabledChanged,
          title: Text(l.modeTrackingEnabled),
        ),
        if (enabled) ...[
          const SizedBox(height: 8),
          Text(l.modeTrackingIntervalLabel),
          _TrackingIntervalSlider(
            seconds: intervalSeconds,
            onChanged: onIntervalChanged,
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(_formatTrackingInterval(intervalSeconds)),
          ),
          const SizedBox(height: 8),
          Text(l.modeTrackingBufferSizeLabel),
          Slider(
            min: _kMinTrackingBufferSize.toDouble(),
            max: _kMaxTrackingBufferSize.toDouble(),
            divisions:
                _kMaxTrackingBufferSize - _kMinTrackingBufferSize,
            value: bufferSize
                .clamp(_kMinTrackingBufferSize, _kMaxTrackingBufferSize)
                .toDouble(),
            label: bufferSize.toString(),
            onChanged: (v) => onBufferSizeChanged(v.round()),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(l.modeTrackingBufferSizeValue(bufferSize.toString())),
          ),
          const SizedBox(height: 4),
          Text(
            l.modeTrackingBatteryNote,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

/// Spec 11 §DE-3 — slider snapping to the documented interval stops.
class _TrackingIntervalSlider extends StatelessWidget {
  const _TrackingIntervalSlider({
    required this.seconds,
    required this.onChanged,
  });

  final int seconds;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final stops = _kTrackingIntervalSnapStops;
    var nearest = 0;
    var nearestDiff = (seconds - stops[0]).abs();
    for (var i = 1; i < stops.length; i++) {
      final diff = (seconds - stops[i]).abs();
      if (diff < nearestDiff) {
        nearest = i;
        nearestDiff = diff;
      }
    }
    return Slider(
      min: 0,
      max: (stops.length - 1).toDouble(),
      divisions: stops.length - 1,
      value: nearest.toDouble(),
      label: _formatTrackingInterval(stops[nearest]),
      onChanged: (v) => onChanged(stops[v.round().clamp(0, stops.length - 1)]),
    );
  }
}

/// Renders a tracking interval (in seconds) as a short label.
String _formatTrackingInterval(int seconds) {
  if (seconds < 60) return '${seconds}s';
  if (seconds % 3600 == 0) return '${seconds ~/ 3600}h';
  if (seconds % 60 == 0) return '${seconds ~/ 60}m';
  return '${seconds}s';
}

/// Row showing the current mode icon (tap to pick) + the name field.
class _NameAndIconRow extends StatelessWidget {
  const _NameAndIconRow({
    required this.nameCtrl,
    required this.iconName,
    required this.onIconTap,
    required this.onNameChanged,
  });

  final TextEditingController nameCtrl;
  final String? iconName;
  final VoidCallback onIconTap;
  final VoidCallback onNameChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        IconButton.filledTonal(
          tooltip: l.modeFieldIcon,
          icon: Icon(iconForName(iconName) ?? Icons.shield),
          onPressed: onIconTap,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: nameCtrl,
            decoration: InputDecoration(labelText: l.modeFieldName),
            onChanged: (_) => onNameChanged(),
          ),
        ),
      ],
    );
  }
}

/// Section listing all configured distress triggers + an "Add" button.
class _DistressTriggersSection extends StatelessWidget {
  const _DistressTriggersSection({
    required this.triggers,
    required this.onAdd,
    required this.onChanged,
    required this.onRemove,
  });

  final List<DistressTrigger> triggers;
  final VoidCallback onAdd;
  final void Function(int index, DistressTrigger updated) onChanged;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.modeDistressHeader,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (triggers.isEmpty)
          Text(l.modeDistressEmpty)
        else
          for (var i = 0; i < triggers.length; i++)
            _DistressTriggerCard(
              key: ValueKey('distress-$i'),
              trigger: triggers[i] as HardwareButtonDistressTrigger,
              onChanged: (t) => onChanged(i, t),
              onDelete: () => onRemove(i),
            ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.add_alert_outlined),
          label: Text(l.modeDistressAdd),
          onPressed: onAdd,
        ),
      ],
    );
  }
}

class _DistressTriggerCard extends StatelessWidget {
  const _DistressTriggerCard({
    super.key,
    required this.trigger,
    required this.onChanged,
    required this.onDelete,
  });

  final HardwareButtonDistressTrigger trigger;
  final ValueChanged<HardwareButtonDistressTrigger> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final hw = trigger.trigger;
    final isRepeat = hw is RepeatPressTrigger;
    return Card(
      child: ExpansionTile(
        title: Text(l.modeDistressTypeHardware),
        subtitle: Text(_summary(context, hw)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<ButtonType>(
            initialValue: trigger.buttonType,
            decoration: InputDecoration(labelText: l.modeDistressButtonType),
            items: [
              DropdownMenuItem(
                value: ButtonType.volumeUp,
                child: Text(l.modeDistressButtonVolumeUp),
              ),
              DropdownMenuItem(
                value: ButtonType.volumeDown,
                child: Text(l.modeDistressButtonVolumeDown),
              ),
              DropdownMenuItem(
                value: ButtonType.power,
                child: Text(l.modeDistressButtonPower),
              ),
            ],
            onChanged: (v) {
              if (v != null) onChanged(trigger.copyWith(buttonType: v));
            },
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<bool>(
            initialValue: isRepeat,
            decoration: InputDecoration(labelText: l.modeDistressPattern),
            items: [
              DropdownMenuItem(
                value: true,
                child: Text(l.modeDistressPatternRepeat),
              ),
              DropdownMenuItem(
                value: false,
                child: Text(l.modeDistressPatternLong),
              ),
            ],
            onChanged: (v) {
              if (v == null) return;
              onChanged(
                trigger.copyWith(
                  trigger: v
                      ? const RepeatPressTrigger()
                      : const LongPressTrigger(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          if (hw is RepeatPressTrigger)
            _RepeatPressEditor(
              trigger: hw,
              onChanged: (h) => onChanged(trigger.copyWith(trigger: h)),
            )
          else if (hw is LongPressTrigger)
            _LongPressEditor(
              trigger: hw,
              onChanged: (h) => onChanged(trigger.copyWith(trigger: h)),
            ),
        ],
      ),
    );
  }

  String _summary(BuildContext context, HardwareTrigger hw) {
    final l = AppLocalizations.of(context);
    return switch (hw) {
      RepeatPressTrigger(:final pressCount, :final pressWindowMs) =>
        l.modeDistressSummaryRepeat(
          pressCount.toString(),
          pressWindowMs.toString(),
        ),
      LongPressTrigger(:final durationSeconds) => l.modeDistressSummaryLong(
        durationSeconds.toStringAsFixed(1),
      ),
    };
  }
}

class _RepeatPressEditor extends StatefulWidget {
  const _RepeatPressEditor({required this.trigger, required this.onChanged});

  final RepeatPressTrigger trigger;
  final ValueChanged<RepeatPressTrigger> onChanged;

  @override
  State<_RepeatPressEditor> createState() => _RepeatPressEditorState();
}

class _RepeatPressEditorState extends State<_RepeatPressEditor> {
  late final TextEditingController _countCtrl;
  late final TextEditingController _winCtrl;

  @override
  void initState() {
    super.initState();
    _countCtrl = TextEditingController(
      text: widget.trigger.pressCount.toString(),
    );
    _winCtrl = TextEditingController(
      text: widget.trigger.pressWindowMs.toString(),
    );
  }

  @override
  void dispose() {
    _countCtrl.dispose();
    _winCtrl.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(
      RepeatPressTrigger(
        pressCount: int.tryParse(_countCtrl.text.trim()) ??
            widget.trigger.pressCount,
        pressWindowMs: int.tryParse(_winCtrl.text.trim()) ??
            widget.trigger.pressWindowMs,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _countCtrl,
          decoration: InputDecoration(labelText: l.modeDistressPressCount),
          keyboardType: TextInputType.number,
          onChanged: (_) => _emit(),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _winCtrl,
          decoration: InputDecoration(labelText: l.modeDistressPressWindow),
          keyboardType: TextInputType.number,
          onChanged: (_) => _emit(),
        ),
      ],
    );
  }
}

class _LongPressEditor extends StatefulWidget {
  const _LongPressEditor({required this.trigger, required this.onChanged});

  final LongPressTrigger trigger;
  final ValueChanged<LongPressTrigger> onChanged;

  @override
  State<_LongPressEditor> createState() => _LongPressEditorState();
}

class _LongPressEditorState extends State<_LongPressEditor> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.trigger.durationSeconds.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return TextField(
      controller: _ctrl,
      decoration: InputDecoration(labelText: l.modeDistressLongDuration),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (v) {
        final d = double.tryParse(v.trim());
        if (d == null) return;
        widget.onChanged(LongPressTrigger(durationSeconds: d));
      },
    );
  }
}

/// Collapsible "Mode overrides" section.
///
/// Each row shows a "Use app default" toggle that switches between
/// inherited (null override) and per-mode (non-null override). When
/// inheriting, the row collapses to the toggle only; when
/// overriding, an inline editor appears underneath.
class _ModeOverridesSection extends ConsumerWidget {
  const _ModeOverridesSection({
    required this.overrides,
    required this.onChanged,
  });

  final ModeOverrides? overrides;
  final ValueChanged<ModeOverrides?> onChanged;

  ModeOverrides _ensure() => overrides ?? const ModeOverrides();

  /// Collapses an empty `ModeOverrides` to null so saved modes don't
  /// carry a no-op overrides object that breaks identity equality.
  ModeOverrides? _normalize(ModeOverrides ov) {
    if (ov.gpsLogging == null &&
        ov.stealth == null &&
        ov.eventDefaults == null &&
        ov.localTemplates.isEmpty &&
        ov.distressModeId == null) {
      return null;
    }
    return ov;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final defaults = ref.watch(settingsControllerProvider).value?.defaults;
    return Card(
      child: ExpansionTile(
        title: Text(
          l.modeOverridesHeader,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        initiallyExpanded: false,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          // GPS logging override.
          _OverrideToggleRow(
            label: l.modeOverridesGpsLabel,
            isOverriding: _ensure().gpsLogging != null,
            onToggle: (active) {
              final cur = _ensure();
              final base = defaults?.gpsLogging ?? const GpsLoggingConfig();
              final next = active
                  ? cur.copyWith(gpsLogging: base)
                  : ModeOverrides(
                      distressModeId: cur.distressModeId,
                      stealth: cur.stealth,
                      localTemplates: cur.localTemplates,
                      eventDefaults: cur.eventDefaults,
                    );
              onChanged(_normalize(next));
            },
            child: _GpsOverrideEditor(
              gps: _ensure().gpsLogging ??
                  defaults?.gpsLogging ??
                  const GpsLoggingConfig(),
              onChanged: (g) =>
                  onChanged(_normalize(_ensure().copyWith(gpsLogging: g))),
            ),
          ),
          const Divider(),
          // Stealth override.
          _OverrideToggleRow(
            label: l.modeOverridesStealthLabel,
            isOverriding: _ensure().stealth != null,
            onToggle: (active) {
              final cur = _ensure();
              final base = defaults?.stealth ?? const StealthConfig();
              final next = active
                  ? cur.copyWith(stealth: base)
                  : ModeOverrides(
                      distressModeId: cur.distressModeId,
                      gpsLogging: cur.gpsLogging,
                      localTemplates: cur.localTemplates,
                      eventDefaults: cur.eventDefaults,
                    );
              onChanged(_normalize(next));
            },
            child: _StealthOverrideEditor(
              stealth: _ensure().stealth ??
                  defaults?.stealth ??
                  const StealthConfig(),
              onChanged: (s) =>
                  onChanged(_normalize(_ensure().copyWith(stealth: s))),
            ),
          ),
          const Divider(),
          // Event defaults override (presence-only — the full editor
          // lives in app-wide settings).
          _OverrideToggleRow(
            label: l.modeOverridesEventDefaultsLabel,
            isOverriding: _ensure().eventDefaults != null,
            onToggle: (active) {
              final cur = _ensure();
              final base = defaults?.eventDefaults ?? const EventDefaults();
              final next = active
                  ? cur.copyWith(eventDefaults: base)
                  : ModeOverrides(
                      distressModeId: cur.distressModeId,
                      gpsLogging: cur.gpsLogging,
                      stealth: cur.stealth,
                      localTemplates: cur.localTemplates,
                    );
              onChanged(_normalize(next));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(l.modeOverridesEventDefaultsHint),
            ),
          ),
          const Divider(),
          // Local templates row (read-only count; editing happens
          // elsewhere in the app — this is just the inheritance view).
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.modeOverridesLocalTemplatesLabel),
            trailing: Text(
              l.modeOverridesLocalTemplatesCount(
                _ensure().localTemplates.length.toString(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverrideToggleRow extends StatelessWidget {
  const _OverrideToggleRow({
    required this.label,
    required this.isOverriding,
    required this.onToggle,
    required this.child,
  });

  final String label;
  final bool isOverriding;
  final ValueChanged<bool> onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            // Switch is "on" when the user is *overriding* (NOT using
            // the app default). The label below clarifies polarity.
            Switch.adaptive(
              value: !isOverriding,
              onChanged: (useDefault) => onToggle(!useDefault),
            ),
            Text(l.modeOverridesUseDefault),
          ],
        ),
        if (isOverriding) child,
      ],
    );
  }
}

class _GpsOverrideEditor extends StatelessWidget {
  const _GpsOverrideEditor({required this.gps, required this.onChanged});

  final GpsLoggingConfig gps;
  final ValueChanged<GpsLoggingConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.modeOverridesGpsEnabled),
          value: gps.enabled,
          onChanged: (v) => onChanged(gps.copyWith(enabled: v)),
        ),
        TextFormField(
          key: ValueKey('gps-iv-${gps.intervalSeconds}'),
          initialValue: gps.intervalSeconds.toString(),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l.modeOverridesGpsIntervalLabel,
          ),
          onChanged: (v) {
            final n = int.tryParse(v.trim());
            if (n != null) onChanged(gps.copyWith(intervalSeconds: n));
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.modeOverridesGpsIncludeInSms),
          value: gps.includeInSms,
          onChanged: (v) => onChanged(gps.copyWith(includeInSms: v)),
        ),
      ],
    );
  }
}

class _StealthOverrideEditor extends StatelessWidget {
  const _StealthOverrideEditor({
    required this.stealth,
    required this.onChanged,
  });

  final StealthConfig stealth;
  final ValueChanged<StealthConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.modeOverridesStealthEnabled),
          value: stealth.enabled,
          onChanged: (v) => onChanged(stealth.copyWith(enabled: v)),
        ),
        TextFormField(
          key: ValueKey('stealth-name-${stealth.fakeName}'),
          initialValue: stealth.fakeName,
          decoration: InputDecoration(
            labelText: l.modeOverridesStealthFakeName,
          ),
          onChanged: (v) => onChanged(stealth.copyWith(fakeName: v)),
        ),
      ],
    );
  }
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
