import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/features/mode_editor/mode_editor_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Mode editor screen.
///
/// Shared between `/modes/edit` (regular) and `/distress-modes/edit`
/// (distress). The `isDistress` parameter:
/// - changes the title
/// - sets `SessionMode.isDistressMode = true` on save
/// - hides the distress-mode picker in the safety options.
class ModeEditorScreen extends ConsumerStatefulWidget {
  /// Creates a [ModeEditorScreen].
  const ModeEditorScreen({super.key, this.modeId, required this.isDistress});

  /// Mode id when editing; null for create.
  final String? modeId;

  /// Whether this is a distress mode editor.
  final bool isDistress;

  @override
  ConsumerState<ModeEditorScreen> createState() => _ModeEditorScreenState();
}

class _ModeEditorScreenState extends ConsumerState<ModeEditorScreen> {
  final TextEditingController _nameCtl = TextEditingController();
  bool _dirty = false;
  bool _loading = true;
  SessionMode? _draft;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = await ref.read(databaseProvider.future);
    final service = ModeEditorService(db);
    final mode = widget.modeId == null
        ? service.blankMode(isDistress: widget.isDistress)
        : await service.load(widget.modeId!);
    if (!mounted) return;
    _nameCtl.text = mode.name;
    setState(() {
      _draft = mode;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    super.dispose();
  }

  void _addStep(ChainStep step) {
    final current = _draft;
    if (current == null) return;
    setState(() {
      _draft = current.copyWith(
        chainSteps: <ChainStep>[
          ...current.chainSteps,
          step.copyWith(order: current.chainSteps.length),
        ],
      );
      _dirty = true;
    });
  }

  void _removeStep(int index) {
    final current = _draft;
    if (current == null) return;
    if (current.chainSteps.length <= 1) return;
    final list = <ChainStep>[...current.chainSteps]..removeAt(index);
    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(order: i);
    }
    setState(() {
      _draft = current.copyWith(chainSteps: list);
      _dirty = true;
    });
  }

  Future<void> _save() async {
    final current = _draft;
    if (current == null) return;
    final updated = current.copyWith(
      name: _nameCtl.text.trim().isEmpty ? current.name : _nameCtl.text.trim(),
      isDistressMode: widget.isDistress,
    );
    final db = await ref.read(databaseProvider.future);
    await ModeEditorService(db).save(updated);
    if (!mounted) return;
    _dirty = false;
    context.pop();
  }

  Future<bool> _confirmLeave() async {
    if (!_dirty) return true;
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(l10n.modeUnsavedTitle),
        content: Text(l10n.modeUnsavedBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.modeUnsavedKeep),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.modeUnsavedDiscard),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _addStepSheet(BuildContext context) async {
    final selected = await showModalBottomSheet<ChainStepType>(
      context: context,
      builder: (BuildContext ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            for (final t in ChainStepType.values)
              ListTile(
                title: Text(t.name),
                onTap: () => Navigator.of(ctx).pop(t),
              ),
          ],
        ),
      ),
    );
    if (selected != null) {
      _addStep(
        ChainStep(
          id: const Uuid().v4(),
          type: selected,
          order: 0,
          waitSeconds: 0,
          durationSeconds: 10,
          gracePeriodSeconds: 5,
          retryCount: 0,
          randomize: false,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final draft = _draft;
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (bool didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final ok = await _confirmLeave();
        if (ok && mounted) navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.modeId == null
                ? l10n.modeEditorTitleCreate
                : l10n.modeEditorTitleEdit,
          ),
          actions: <Widget>[
            TextButton(onPressed: _save, child: Text(l10n.commonSave)),
          ],
        ),
        body: _loading || draft == null
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    TextField(
                      controller: _nameCtl,
                      onChanged: (_) {
                        if (!_dirty) setState(() => _dirty = true);
                      },
                      decoration: InputDecoration(
                        labelText: l10n.modeFieldName,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.modeChainHeader),
                    for (int i = 0; i < draft.chainSteps.length; i++)
                      Card(
                        child: ListTile(
                          leading: CircleAvatar(child: Text('${i + 1}')),
                          title: Text(draft.chainSteps[i].type.name),
                          subtitle: Text(
                            l10n.stepTimingSummary(
                              draft.chainSteps[i].waitSeconds.toString(),
                              draft.chainSteps[i].durationSeconds.toString(),
                              draft.chainSteps[i].gracePeriodSeconds.toString(),
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _removeStep(i),
                          ),
                        ),
                      ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.add),
                      label: Text(l10n.modeChainAddStep),
                      onPressed: () => _addStepSheet(context),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
