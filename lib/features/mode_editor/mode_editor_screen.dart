import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/event_defaults.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/features/mode_editor/mode_editor_controller.dart';
import 'package:guardianangela/features/modes/widgets/safety_options_section.dart';
import 'package:guardianangela/features/modes/widgets/step_config_panel.dart';
import 'package:guardianangela/features/modes/widgets/step_helpers.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Mode editor screen.
///
/// Shared between `/modes/edit` (regular) and `/distress-modes/edit`
/// (distress). The `isDistress` parameter:
/// - changes the title
/// - sets `SessionMode.isDistressMode = true` on save
/// - hides the distress-mode picker in the safety options.
///
/// The chain is a reorderable list of [ExpansionTile]s; each tile expands
/// inline to a [StepConfigPanel] that edits the step's timing, type-specific
/// config, and retry/advanced settings. A step with a null config displays
/// the resolved `AppDefaults.eventDefaults` values until the user edits one.
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
  EventDefaults _defaults = const EventDefaults();
  List<EmergencyContact> _contacts = const <EmergencyContact>[];
  List<SessionMode> _distressModes = const <SessionMode>[];
  String? _defaultDistressModeId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = await ref.read(databaseProvider.future);
    final settings = await ref.read(appSettingsRepositoryProvider).load();
    final contacts = await db.contactsDao.getAll();
    final distressModes = await db.sessionModesDao.getDistressModes();
    final service = ModeEditorService(db);
    final mode = widget.modeId == null
        ? service.blankMode(isDistress: widget.isDistress)
        : await service.load(widget.modeId!);
    if (!mounted) return;
    _nameCtl.text = mode.name;
    setState(() {
      _draft = mode;
      _defaults = settings.defaults.eventDefaults;
      _contacts = contacts;
      // A distress mode never references itself in the picker.
      _distressModes = <SessionMode>[
        for (final SessionMode m in distressModes)
          if (m.id != mode.id) m,
      ];
      _defaultDistressModeId = settings.defaults.defaultDistressModeId;
      _loading = false;
    });
  }

  void _manageContacts() => context.pushNamed(RouteNames.contacts);

  void _manageDistressModes() => context.pushNamed(RouteNames.distressModes);

  void _manageTemplates() =>
      context.pushNamed(RouteNames.settingsReminderTemplates);

  /// Stages a whole-draft mutation (used by the Safety Options section).
  void _updateDraft(SessionMode updated) {
    setState(() {
      _draft = updated;
      _dirty = true;
    });
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    super.dispose();
  }

  /// Re-assigns sequential [ChainStep.order] values matching list position.
  List<ChainStep> _reindexed(List<ChainStep> steps) => <ChainStep>[
    for (int i = 0; i < steps.length; i++) steps[i].copyWith(order: i),
  ];

  void _mutateSteps(List<ChainStep> Function(List<ChainStep>) transform) {
    final current = _draft;
    if (current == null) return;
    setState(() {
      _draft = current.copyWith(
        chainSteps: _reindexed(transform(<ChainStep>[...current.chainSteps])),
      );
      _dirty = true;
    });
  }

  void _updateStep(int index, ChainStep updated) =>
      _mutateSteps((List<ChainStep> list) => list..[index] = updated);

  void _addStep(ChainStepType type) => _mutateSteps(
    (List<ChainStep> list) => list
      ..add(
        ChainStep(
          id: const Uuid().v4(),
          type: type,
          order: list.length,
          waitSeconds: 0,
          durationSeconds: 10,
          gracePeriodSeconds: 5,
          retryCount: 0,
          randomize: false,
        ),
      ),
  );

  void _duplicateStep(int index) => _mutateSteps((List<ChainStep> list) {
    final ChainStep copy = list[index].copyWith(id: const Uuid().v4());
    return list..insert(index + 1, copy);
  });

  void _resetStep(int index) => _mutateSteps((List<ChainStep> list) {
    final ChainStep step = list[index];
    return list..[index] = step.copyWith(config: _defaults.forType(step.type));
  });

  void _removeStep(int index) {
    final current = _draft;
    if (current == null || current.chainSteps.length <= 1) return;
    _mutateSteps((List<ChainStep> list) => list..removeAt(index));
  }

  void _reorder(int oldIndex, int newIndex) =>
      _mutateSteps((List<ChainStep> list) {
        final int target = newIndex > oldIndex ? newIndex - 1 : newIndex;
        final ChainStep moved = list.removeAt(oldIndex);
        return list..insert(target, moved);
      });

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

  Future<void> _addStepSheet() async {
    final l10n = AppLocalizations.of(context);
    final ChainStepType? selected = await showModalBottomSheet<ChainStepType>(
      context: context,
      builder: (BuildContext ctx) =>
          _AddStepSheet(l10n: l10n, isDistress: widget.isDistress),
    );
    if (selected != null) _addStep(selected);
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
                ? (widget.isDistress
                      ? l10n.distressModeEditorTitleCreate
                      : l10n.modeEditorTitleCreate)
                : (widget.isDistress
                      ? l10n.distressModeEditorTitleEdit
                      : l10n.modeEditorTitleEdit),
          ),
          actions: <Widget>[
            TextButton(onPressed: _save, child: Text(l10n.commonSave)),
          ],
        ),
        body: _loading || draft == null
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(<Widget>[
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
                          Text(
                            l10n.modeChainHeader,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                        ]),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverReorderableList(
                        itemCount: draft.chainSteps.length,
                        onReorder: _reorder,
                        itemBuilder: (BuildContext ctx, int index) {
                          final ChainStep step = draft.chainSteps[index];
                          return _StepTile(
                            key: ValueKey<String>(step.id),
                            index: index,
                            step: step,
                            defaultConfig: _defaults.forType(step.type),
                            canDelete: draft.chainSteps.length > 1,
                            contacts: _contacts,
                            onManageContacts: _manageContacts,
                            onChanged: (ChainStep s) => _updateStep(index, s),
                            onDuplicate: () => _duplicateStep(index),
                            onReset: () => _resetStep(index),
                            onDelete: () => _removeStep(index),
                          );
                        },
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      sliver: SliverToBoxAdapter(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.add),
                          label: Text(l10n.modeChainAddStep),
                          onPressed: _addStepSheet,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverToBoxAdapter(
                        child: SafetyOptionsSection(
                          mode: draft,
                          onChanged: _updateDraft,
                          isDistress: widget.isDistress,
                          distressModes: _distressModes,
                          defaultDistressModeId: _defaultDistressModeId,
                          onManageDistressModes: _manageDistressModes,
                          onManageTemplates: _manageTemplates,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// One reorderable, expandable step tile in the chain list.
class _StepTile extends StatelessWidget {
  const _StepTile({
    super.key,
    required this.index,
    required this.step,
    required this.defaultConfig,
    required this.canDelete,
    required this.contacts,
    required this.onManageContacts,
    required this.onChanged,
    required this.onDuplicate,
    required this.onReset,
    required this.onDelete,
  });

  final int index;
  final ChainStep step;
  final StepConfig defaultConfig;
  final bool canDelete;
  final List<EmergencyContact> contacts;
  final VoidCallback onManageContacts;
  final ValueChanged<ChainStep> onChanged;
  final VoidCallback onDuplicate;
  final VoidCallback onReset;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: ExpansionTile(
        leading: ReorderableDragStartListener(
          index: index,
          child: const Icon(Icons.drag_handle),
        ),
        title: Row(
          children: <Widget>[
            Text('${index + 1}.'),
            const SizedBox(width: 8),
            Icon(stepIcon(step.type), size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(stepName(l10n, step.type))),
          ],
        ),
        subtitle: Text(
          l10n.stepTimingSummary(
            step.waitSeconds.toString(),
            step.durationSeconds.toString(),
            step.gracePeriodSeconds.toString(),
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        children: <Widget>[
          StepConfigPanel(
            step: step,
            defaultConfig: defaultConfig,
            canDelete: canDelete,
            contacts: contacts,
            onManageContacts: onManageContacts,
            onChanged: onChanged,
            onDuplicate: onDuplicate,
            onReset: onReset,
            onDelete: onDelete,
          ),
        ],
      ),
    );
  }
}

/// Categorised bottom-sheet picker for adding a step (spec 04 §Add Step).
///
/// In the distress variant the check-in category (holdButton /
/// disguisedReminder) is omitted — distress chains start with an action step
/// (spec 04:1649).
class _AddStepSheet extends StatelessWidget {
  const _AddStepSheet({required this.l10n, required this.isDistress});

  final AppLocalizations l10n;
  final bool isDistress;

  static const List<ChainStepType> _checkIn = <ChainStepType>[
    ChainStepType.holdButton,
    ChainStepType.disguisedReminder,
  ];
  static const List<ChainStepType> _escalation = <ChainStepType>[
    ChainStepType.countdownWarning,
    ChainStepType.fakeCall,
    ChainStepType.smsContact,
    ChainStepType.phoneCallContact,
    ChainStepType.loudAlarm,
    ChainStepType.callEmergency,
  ];
  static const List<ChainStepType> _panic = <ChainStepType>[
    ChainStepType.hardwareButton,
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          if (!isDistress) ...<Widget>[
            _SheetHeader(text: l10n.eventDefaultsCheckInHeader),
            for (final ChainStepType t in _checkIn) _stepRow(context, t),
          ],
          _SheetHeader(text: l10n.eventDefaultsEscalationHeader),
          for (final ChainStepType t in _escalation) _stepRow(context, t),
          _SheetHeader(text: l10n.eventDefaultsPanicHeader),
          for (final ChainStepType t in _panic) _stepRow(context, t),
        ],
      ),
    );
  }

  Widget _stepRow(BuildContext context, ChainStepType type) => ListTile(
    leading: Icon(stepIcon(type)),
    title: Text(stepName(l10n, type)),
    onTap: () => Navigator.of(context).pop(type),
  );
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}
