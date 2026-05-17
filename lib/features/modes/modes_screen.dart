/// Session-modes list with add / edit / delete / reorder.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/data/seed_data.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/features/modes/modes_controller.dart';
import 'package:guardianangela/features/modes/widgets/mode_icon_library.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Modes list.
class ModesScreen extends ConsumerWidget {
  /// Creates the modes screen.
  const ModesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(modesControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.modesTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('$e')),
        data: (modes) => modes.isEmpty
            ? Center(child: Text(l.modesEmpty))
            : ReorderableListView.builder(
                itemCount: modes.length,
                onReorder: (o, n) =>
                    ref.read(modesControllerProvider.notifier).reorder(o, n),
                itemBuilder: (context, i) {
                  final m = modes[i];
                  return ListTile(
                    key: ValueKey(m.id),
                    leading: Icon(iconForName(m.iconName) ?? Icons.tune),
                    title: Text(m.name),
                    subtitle: Text('${m.chainSteps.length} steps'),
                    onTap: () =>
                        context.push('${RouteNames.modeEditor}?id=${m.id}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => ref
                          .read(modesControllerProvider.notifier)
                          .delete(m.id),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(l.modesAdd),
        onPressed: () => _onAddPressed(context, ref),
      ),
    );
  }

  Future<void> _onAddPressed(BuildContext context, WidgetRef ref) async {
    final modes =
        ref.read(modesControllerProvider).value ?? const <SessionMode>[];
    final entries = _templateEntries(modes);
    final choice = await showModalBottomSheet<_NewModeChoice>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => _NewModePicker(entries: entries),
    );
    if (choice == null || !context.mounted) return;
    switch (choice) {
      case _BlankChoice():
        await context.push(RouteNames.modeEditor);
      case _TemplateChoice(:final source):
        final l = AppLocalizations.of(context);
        final clone = _cloneAsNewMode(
          source,
          copyName: l.modesNewPickerCopyName(source.name),
        );
        await ref.read(modesControllerProvider.notifier).save(clone);
        if (!context.mounted) return;
        await context.push('${RouteNames.modeEditor}?id=${clone.id}');
    }
  }
}

/// Returns the picker's template list: each built-in mode appears
/// FIRST (badged as `isBuiltIn: true`), followed by every
/// user-created non-distress mode. Built-in ids that overlap with
/// the user's saved modes are deduped — the user's customised copy
/// wins (since they may have tuned its chain) but keeps the badge.
List<_TemplateEntry> _templateEntries(List<SessionMode> userModes) {
  final byId = <String, _TemplateEntry>{};
  // 1) Built-in defaults — always present.
  for (final m in builtInTemplates()) {
    byId[m.id] = _TemplateEntry(mode: m, isBuiltIn: true);
  }
  // 2) User modes — non-distress only; overwrite the built-in entry
  //    if the id matches so the user sees their tuned version, but
  //    keep the built-in badge so they can tell it's the seed mode.
  for (final m in userModes) {
    if (m.isDistressMode) continue;
    final wasBuiltIn = byId[m.id]?.isBuiltIn ?? kBuiltInModeIds.contains(m.id);
    byId[m.id] = _TemplateEntry(mode: m, isBuiltIn: wasBuiltIn);
  }
  return byId.values.toList(growable: false);
}

/// Returns a fresh [SessionMode] with a new id and "Copy of …" name
/// that mirrors [source]'s chain, triggers, overrides, and tracking.
SessionMode _cloneAsNewMode(SessionMode source, {required String copyName}) =>
    source.copyWith(
      id: const Uuid().v4(),
      name: copyName,
    );

sealed class _NewModeChoice {
  const _NewModeChoice();
}

class _BlankChoice extends _NewModeChoice {
  const _BlankChoice();
}

class _TemplateChoice extends _NewModeChoice {
  const _TemplateChoice(this.source);
  final SessionMode source;
}

class _TemplateEntry {
  const _TemplateEntry({required this.mode, required this.isBuiltIn});
  final SessionMode mode;
  final bool isBuiltIn;
}

class _NewModePicker extends StatelessWidget {
  const _NewModePicker({required this.entries});

  final List<_TemplateEntry> entries;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l.modesNewPickerTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: Text(l.modesNewPickerBlank),
            subtitle: Text(l.modesNewPickerBlankSubtitle),
            onTap: () => Navigator.of(context).pop(const _BlankChoice()),
          ),
          if (entries.isNotEmpty) const Divider(),
          for (final e in entries)
            ListTile(
              leading: Icon(iconForName(e.mode.iconName) ?? Icons.content_copy),
              title: Row(
                children: [
                  Flexible(
                    child: Text(l.modesNewPickerFromTemplate(e.mode.name)),
                  ),
                  if (e.isBuiltIn) ...[
                    const SizedBox(width: 8),
                    _BuiltInBadge(label: l.modesNewPickerBuiltinBadge),
                  ],
                ],
              ),
              subtitle: Text(l.modesNewPickerFromTemplateSubtitle),
              onTap: () =>
                  Navigator.of(context).pop(_TemplateChoice(e.mode)),
            ),
        ],
      ),
    );
  }
}

class _BuiltInBadge extends StatelessWidget {
  const _BuiltInBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onSecondaryContainer,
            ),
      ),
    );
  }
}
