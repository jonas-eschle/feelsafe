/// Distress-chain create / edit screen; reuses the mode-editor
/// widgets for chain-step editing.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/distress_chain.dart';
import 'package:guardianangela/features/distress_chains/distress_chains_controller.dart';
import 'package:guardianangela/features/modes/widgets/chain_step_tile.dart';
import 'package:guardianangela/features/modes/widgets/step_type_picker.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Distress-chain create / edit screen.
class DistressChainEditorScreen extends ConsumerStatefulWidget {
  /// Creates the distress-chain editor.
  const DistressChainEditorScreen({super.key});

  @override
  ConsumerState<DistressChainEditorScreen> createState() =>
      _DistressChainEditorScreenState();
}

class _DistressChainEditorScreenState
    extends ConsumerState<DistressChainEditorScreen> {
  DistressChain? _chain;
  final TextEditingController _nameCtrl = TextEditingController();
  List<ChainStep> _steps = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = GoRouterState.of(context).uri.queryParameters['id'];
    if (id != null && _chain == null) {
      final all = ref.read(distressChainsControllerProvider).value ??
          const <DistressChain>[];
      for (final c in all) {
        if (c.id == id) {
          _chain = c;
          _nameCtrl.text = c.name;
          _steps = List.of(c.steps);
          break;
        }
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
    final chain = DistressChain(
      id: _chain?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim().isEmpty ? 'Chain' : _nameCtrl.text.trim(),
      steps: List.of(_steps),
    );
    await ref.read(distressChainsControllerProvider.notifier).save(chain);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_chain == null
            ? l.distressChainEditorTitleCreate
            : l.distressChainEditorTitleEdit),
        actions: [
          IconButton(onPressed: _save, icon: const Icon(Icons.check)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(labelText: l.distressChainName),
          ),
          const SizedBox(height: 16),
          Text(l.modeChainHeader,
              style: Theme.of(context).textTheme.titleMedium),
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
