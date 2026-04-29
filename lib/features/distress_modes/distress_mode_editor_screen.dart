/// Distress-mode create / edit screen; reuses the mode-editor
/// widgets for chain-step editing.
///
/// Per Q52, "distress modes" are the user-facing rename of the
/// underlying `DistressChain` aggregate.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/distress_chain.dart';
import 'package:guardianangela/features/distress_modes/distress_modes_controller.dart';
import 'package:guardianangela/features/modes/widgets/chain_step_tile.dart';
import 'package:guardianangela/features/modes/widgets/step_type_picker.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Distress-mode create / edit screen.
class DistressModeEditorScreen extends ConsumerStatefulWidget {
  /// Creates the distress-mode editor.
  const DistressModeEditorScreen({super.key});

  @override
  ConsumerState<DistressModeEditorScreen> createState() =>
      _DistressModeEditorScreenState();
}

class _DistressModeEditorScreenState
    extends ConsumerState<DistressModeEditorScreen> {
  DistressChain? _chain;
  final TextEditingController _nameCtrl = TextEditingController();
  List<ChainStep> _steps = const [];
  bool _hydrated = false;

  void _hydrate(List<DistressChain> all) {
    if (_hydrated) return;
    _hydrated = true;
    final id = GoRouterState.of(context).uri.queryParameters['id'];
    if (id == null) return;
    for (final c in all) {
      if (c.id == id) {
        _chain = c;
        _nameCtrl.text = c.name;
        _steps = List.of(c.steps);
        break;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_steps.isEmpty) return;
    final base = _chain;
    final chain = DistressChain(
      id: base?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim().isEmpty ? 'Mode' : _nameCtrl.text.trim(),
      steps: List.of(_steps),
    );
    await ref.read(distressModesControllerProvider.notifier).save(chain);
    if (mounted) context.pop();
  }

  Future<void> _addStep() async {
    final type = await showStepTypePicker(context);
    if (type == null) return;
    setState(() {
      _steps = [
        ..._steps,
        ChainStep(
          id: const Uuid().v4(),
          type: type,
          order: _steps.length,
          durationSeconds: 30,
          gracePeriodSeconds: 15,
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final modesAsync = ref.watch(distressModesControllerProvider);
    if (!_hydrated) {
      modesAsync.whenData(_hydrate);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _chain == null
              ? l.distressModeEditorTitleCreate
              : l.distressModeEditorTitleEdit,
        ),
        actions: [IconButton(onPressed: _save, icon: const Icon(Icons.check))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(labelText: l.distressModeName),
          ),
          const SizedBox(height: 16),
          Text(
            l.modeChainHeader,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (_steps.isEmpty) Text(l.modeChainEmpty),
          for (var i = 0; i < _steps.length; i++)
            ChainStepTile(
              key: ValueKey(_steps[i].id),
              step: _steps[i],
              onChanged: (s) => setState(() {
                _steps = [..._steps]..[i] = s;
              }),
              onDelete: () => setState(() {
                _steps = [..._steps]..removeAt(i);
              }),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: Text(l.modeChainAddStep),
            onPressed: _addStep,
          ),
        ],
      ),
    );
  }
}
