import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safewayhome/l10n/app_localizations.dart';

import '../../core/theme/pride_widgets.dart';
import '../../data/models/escalation_step.dart';
import '../modes/modes_controller.dart';
import '../settings/settings_controller.dart';
import 'escalation_step_list.dart';

/// Standalone escalation chain editor. Edits the escalation chain of the
/// currently selected mode (or the first mode if none is selected).
class EscalationSettingsScreen extends ConsumerStatefulWidget {
  const EscalationSettingsScreen({super.key});

  @override
  ConsumerState<EscalationSettingsScreen> createState() =>
      _EscalationSettingsScreenState();
}

class _EscalationSettingsScreenState
    extends ConsumerState<EscalationSettingsScreen> {
  List<EscalationStep>? _steps;
  String? _modeId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final modesAsync = ref.watch(modesControllerProvider);
    final settingsAsync = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.escalationChain),
        bottom: const PrideAppBarBottom(),
        actions: [
          if (_steps != null)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _save,
              tooltip: l10n.save,
            ),
        ],
      ),
      body: modesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (modes) {
          if (modes.isEmpty) {
            return Center(child: Text(l10n.modes));
          }

          final selectedId = settingsAsync.valueOrNull?.selectedModeId;
          final mode = modes.firstWhere(
            (m) => m.id == selectedId,
            orElse: () => modes.first,
          );

          if (_steps == null || _modeId != mode.id) {
            _modeId = mode.id;
            _steps = mode.escalationSteps
                .map((s) => s.copyWith())
                .toList()
              ..sort((a, b) => a.order.compareTo(b.order));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mode selector dropdown
              Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<String>(
                  initialValue: mode.id,
                  decoration: InputDecoration(
                    labelText: l10n.modes,
                    border: const OutlineInputBorder(),
                  ),
                  items: modes
                      .map((m) => DropdownMenuItem(
                            value: m.id,
                            child: Text(m.name.isEmpty ? l10n.customMode : m.name),
                          ))
                      .toList(),
                  onChanged: (id) {
                    if (id == null) return;
                    final selected = modes.firstWhere((m) => m.id == id);
                    setState(() {
                      _modeId = selected.id;
                      _steps = selected.escalationSteps
                          .map((s) => s.copyWith())
                          .toList()
                        ..sort((a, b) => a.order.compareTo(b.order));
                    });
                  },
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: EscalationStepList(
                    steps: _steps!,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex -= 1;
                        final item = _steps!.removeAt(oldIndex);
                        _steps!.insert(newIndex, item);
                        for (var i = 0; i < _steps!.length; i++) {
                          _steps![i] = _steps![i].copyWith(order: i);
                        }
                      });
                    },
                    onRemove: (index) {
                      setState(() {
                        _steps!.removeAt(index);
                        for (var i = 0; i < _steps!.length; i++) {
                          _steps![i] = _steps![i].copyWith(order: i);
                        }
                      });
                    },
                    onAdd: (type) {
                      setState(() {
                        _steps!.add(EscalationStep(
                          type: type,
                          timeoutSeconds: 30,
                          order: _steps!.length,
                        ));
                      });
                    },
                    onTimeoutChanged: (index, seconds) {
                      setState(() {
                        _steps![index] =
                            _steps![index].copyWith(timeoutSeconds: seconds);
                      });
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _save() {
    if (_modeId == null || _steps == null) return;
    final modesAsync = ref.read(modesControllerProvider);
    final modes = modesAsync.valueOrNull;
    if (modes == null) return;

    final mode = modes.firstWhere((m) => m.id == _modeId);
    final updated = mode.copyWith(escalationSteps: _steps);
    ref.read(modesControllerProvider.notifier).saveMode(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).save),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
