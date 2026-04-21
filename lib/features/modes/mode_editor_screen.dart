/// Session-mode create / edit screen.
///
/// The mode's main escalation chain is edited via
/// [ChainStepTile]s in a [ReorderableListView]. An FAB opens
/// [showStepTypePicker] to add a new step.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/features/distress_chains/distress_chains_controller.dart';
import 'package:guardianangela/features/modes/modes_controller.dart';
import 'package:guardianangela/features/modes/widgets/chain_step_tile.dart';
import 'package:guardianangela/features/modes/widgets/step_type_picker.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Mode create / edit screen.
class ModeEditorScreen extends ConsumerStatefulWidget {
  /// Creates the mode editor.
  const ModeEditorScreen({super.key});

  @override
  ConsumerState<ModeEditorScreen> createState() => _ModeEditorScreenState();
}

class _ModeEditorScreenState extends ConsumerState<ModeEditorScreen> {
  SessionMode? _mode;
  final TextEditingController _nameCtrl = TextEditingController();
  ChainStepType _checkInType = ChainStepType.holdButton;
  String? _distressChainId;
  List<ChainStep> _chain = const [];
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
        _checkInType = m.checkInType;
        _distressChainId = m.distressChainId;
        _chain = List.of(m.chainSteps);
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
    final mode = _mode;
    final current = SessionMode(
      id: mode?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim().isEmpty ? 'Mode' : _nameCtrl.text.trim(),
      checkInType: _checkInType,
      chainSteps: List.of(_chain),
      distressChainId: _distressChainId,
      distressTriggers: mode?.distressTriggers ?? const [],
      disarmTriggers: mode?.disarmTriggers ?? const [],
      overrides: mode?.overrides,
    );
    await ref.read(modesControllerProvider.notifier).save(current);
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
          gracePeriodSeconds: 15,
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final modesAsync = ref.watch(modesControllerProvider);
    if (!_hydrated) {
      modesAsync.whenData(_hydrate);
    }
    final distressChains =
        ref.watch(distressChainsControllerProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _mode == null ? l.modeEditorTitleCreate : l.modeEditorTitleEdit,
        ),
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: _save)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(labelText: l.modeFieldName),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ChainStepType>(
            initialValue: _checkInType,
            decoration: InputDecoration(labelText: l.modeFieldCheckInType),
            items: [
              DropdownMenuItem(
                value: ChainStepType.holdButton,
                child: Text(l.stepTypeHoldButton),
              ),
              DropdownMenuItem(
                value: ChainStepType.disguisedReminder,
                child: Text(l.stepTypeDisguisedReminder),
              ),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _checkInType = v);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            initialValue: _distressChainId,
            decoration: InputDecoration(labelText: l.modeFieldDistressChain),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(l.modeFieldDistressChainDefault),
              ),
              for (final c in distressChains)
                DropdownMenuItem<String?>(value: c.id, child: Text(c.name)),
            ],
            onChanged: (v) => setState(() => _distressChainId = v),
          ),
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
                    onChanged: (s) => setState(() {
                      _chain = [..._chain]..[i] = s;
                    }),
                    onDelete: () => setState(() {
                      _chain = [..._chain]..removeAt(i);
                    }),
                  ),
              ],
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
