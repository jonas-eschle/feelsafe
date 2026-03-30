import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safewayhome/l10n/app_localizations.dart';

import '../../core/theme/pride_widgets.dart';
import '../../core/widgets/logarithmic_slider.dart';
import '../../data/models/escalation_step.dart';
import '../../data/models/session_mode.dart';
import '../escalation/escalation_step_list.dart';
import 'modes_controller.dart';

class ModeEditorScreen extends ConsumerStatefulWidget {
  final String? modeId;

  const ModeEditorScreen({super.key, this.modeId});

  @override
  ConsumerState<ModeEditorScreen> createState() => _ModeEditorScreenState();
}

class _ModeEditorScreenState extends ConsumerState<ModeEditorScreen> {
  late TextEditingController _nameController;
  CheckInMechanism _mechanism = CheckInMechanism.holdButton;
  double _intervalSeconds = 10;
  int _tolerance = 0;
  List<EscalationStep> _steps = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _loadMode(SessionMode mode) {
    if (_loaded) return;
    _loaded = true;
    _nameController.text = mode.name;
    _mechanism = mode.checkInMechanism;
    _intervalSeconds = mode.checkInIntervalSeconds.toDouble();
    _tolerance = mode.missedTolerance;
    _steps = mode.escalationSteps
        .map((s) => s.copyWith())
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// holdButton: 5s..300s (5 min)
  /// disguisedReminder: 60s..86400s (24 hrs)
  double get _minInterval =>
      _mechanism == CheckInMechanism.holdButton ? 5 : 60;

  double get _maxInterval =>
      _mechanism == CheckInMechanism.holdButton ? 300 : 86400;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final modesAsync = ref.watch(modesControllerProvider);

    return modesAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.editMode)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.editMode)),
        body: Center(child: Text('$e')),
      ),
      data: (modes) {
        final mode = modes.cast<SessionMode?>().firstWhere(
              (m) => m!.id == widget.modeId,
              orElse: () => null,
            );
        if (mode == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.editMode)),
            body: const Center(child: Text('Mode not found')),
          );
        }

        _loadMode(mode);

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.modeId == null ? l10n.createMode : l10n.editMode),
            bottom: const PrideAppBarBottom(),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // Mode name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.modes,
                    hintText: l10n.customMode,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Check-in mechanism picker
              ListTile(
                title: Text(l10n.checkInMechanism),
              ),
              RadioGroup<CheckInMechanism>(
                groupValue: _mechanism,
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _mechanism = v;
                    _intervalSeconds = _intervalSeconds.clamp(
                      _minInterval,
                      _maxInterval,
                    );
                  });
                },
                child: Column(
                  children: [
                    RadioListTile<CheckInMechanism>(
                      title: Text(l10n.holdButton),
                      value: CheckInMechanism.holdButton,
                    ),
                    RadioListTile<CheckInMechanism>(
                      title: Text(l10n.disguisedReminder),
                      value: CheckInMechanism.disguisedReminder,
                    ),
                  ],
                ),
              ),
              const PrideDivider(),

              // Check-in interval -- logarithmic slider
              ListTile(
                title: Text(l10n.checkInInterval),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LogarithmicSlider(
                  min: _minInterval,
                  max: _maxInterval,
                  value: _intervalSeconds.clamp(_minInterval, _maxInterval),
                  onChanged: (v) => setState(() => _intervalSeconds = v),
                ),
              ),
              const PrideDivider(),

              // Missed tolerance
              ListTile(
                title: Text(l10n.missedTolerance),
                subtitle: Text('$_tolerance'),
              ),
              Slider(
                value: _tolerance.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                label: '$_tolerance',
                onChanged: (v) => setState(() => _tolerance = v.round()),
              ),
              const PrideDivider(),

              // Escalation chain
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  l10n.escalationChain,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              EscalationStepList(
                steps: _steps,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = _steps.removeAt(oldIndex);
                    _steps.insert(newIndex, item);
                    for (var i = 0; i < _steps.length; i++) {
                      _steps[i] = _steps[i].copyWith(order: i);
                    }
                  });
                },
                onRemove: (index) {
                  setState(() {
                    _steps.removeAt(index);
                    for (var i = 0; i < _steps.length; i++) {
                      _steps[i] = _steps[i].copyWith(order: i);
                    }
                  });
                },
                onAdd: (type) {
                  setState(() {
                    _steps.add(EscalationStep(
                      type: type,
                      timeoutSeconds: 30,
                      order: _steps.length,
                    ));
                  });
                },
                onTimeoutChanged: (index, seconds) {
                  setState(() {
                    _steps[index] =
                        _steps[index].copyWith(timeoutSeconds: seconds);
                  });
                },
              ),
              const SizedBox(height: 24),

              // Save button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilledButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(l10n.save),
                  onPressed: () => _save(mode),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _save(SessionMode original) {
    final updated = original.copyWith(
      name: _nameController.text.trim(),
      checkInMechanism: _mechanism,
      checkInIntervalSeconds: _intervalSeconds.round(),
      missedTolerance: _tolerance,
      escalationSteps: _steps,
    );
    ref.read(modesControllerProvider.notifier).saveMode(updated);
    context.pop();
  }
}
