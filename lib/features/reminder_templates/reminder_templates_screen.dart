import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/features/reminder_templates/reminder_templates_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Reminder templates list screen.
///
/// Unified list of built-in + custom templates. Built-ins cannot be
/// deleted (menu item disabled with tooltip). The FAB opens a bottom
/// sheet offering "From template" (picker of built-ins) or "From
/// scratch" (empty editor). See spec 04 §Templates Screen
/// (lines 2110–2179).
class ReminderTemplatesScreen extends ConsumerWidget {
  /// Creates a [ReminderTemplatesScreen].
  const ReminderTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stateAsync = ref.watch(reminderTemplatesControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.templatesTitle)),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.templatesCreate,
        onPressed: () => _openAddSheet(context, ref, stateAsync.value),
        child: const Icon(Icons.add),
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(child: Text('Error: $e')),
        data: (state) {
          if (state.templates.isEmpty) {
            return _EmptyState(
              onAdd: () => context.pushNamed(RouteNames.templateEditor),
            );
          }
          return ListView.builder(
            itemCount: state.templates.length,
            itemBuilder: (BuildContext ctx, int i) {
              final t = state.templates[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: Text(t.name),
                  subtitle: Text('${t.title} • ${t.body}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (String key) async {
                      switch (key) {
                        case 'edit':
                          await context.pushNamed<void>(
                            RouteNames.templateEditor,
                            queryParameters: <String, String>{'id': t.id},
                          );
                        case 'duplicate':
                          await ref
                              .read(
                                reminderTemplatesControllerProvider.notifier,
                              )
                              .duplicate(t.id);
                        case 'delete':
                          if (!t.isCustom) return;
                          await _confirmAndDelete(context, ref, t);
                      }
                    },
                    itemBuilder: (_) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Text(l10n.commonEdit),
                      ),
                      PopupMenuItem<String>(
                        value: 'duplicate',
                        child: Text(l10n.modesDuplicate),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        enabled: t.isCustom,
                        child: t.isCustom
                            ? Text(l10n.commonDelete)
                            : Tooltip(
                                message: l10n.templatesBuiltinNoDelete,
                                child: Text(l10n.commonDelete),
                              ),
                      ),
                    ],
                  ),
                  onTap: () => context.pushNamed(
                    RouteNames.templateEditor,
                    queryParameters: <String, String>{'id': t.id},
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openAddSheet(
    BuildContext context,
    WidgetRef ref,
    ReminderTemplatesState? state,
  ) async {
    final l10n = AppLocalizations.of(context);
    final choice = await showModalBottomSheet<_AddChoice>(
      context: context,
      builder: (BuildContext ctx) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.library_books_outlined),
              title: Text(l10n.templatesAddFromTemplate),
              onTap: () => Navigator.of(ctx).pop(_AddChoice.fromTemplate),
            ),
            ListTile(
              leading: const Icon(Icons.note_add_outlined),
              title: Text(l10n.templatesAddFromScratch),
              onTap: () => Navigator.of(ctx).pop(_AddChoice.fromScratch),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    switch (choice) {
      case null:
        return;
      case _AddChoice.fromScratch:
        await context.pushNamed<void>(RouteNames.templateEditor);
      case _AddChoice.fromTemplate:
        await _pickBuiltinTemplate(context, ref, state);
    }
  }

  Future<void> _pickBuiltinTemplate(
    BuildContext context,
    WidgetRef ref,
    ReminderTemplatesState? state,
  ) async {
    final l10n = AppLocalizations.of(context);
    final builtins = (state?.templates ?? const <ReminderTemplate>[])
        .where((t) => !t.isCustom)
        .toList();
    final picked = await showModalBottomSheet<ReminderTemplate>(
      context: context,
      builder: (BuildContext ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.templatesPickFromBuiltinTitle,
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
            ),
            for (final ReminderTemplate t in builtins)
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: Text(t.name),
                subtitle: Text(t.title),
                onTap: () => Navigator.of(ctx).pop(t),
              ),
          ],
        ),
      ),
    );
    if (picked == null || !context.mounted) return;
    // Duplicate the picked built-in (the controller clones + marks
    // isCustom=true) and open its editor immediately.
    final notifier = ref.read(reminderTemplatesControllerProvider.notifier);
    final newId = await notifier.duplicate(picked.id);
    if (!context.mounted) return;
    await context.pushNamed<void>(
      RouteNames.templateEditor,
      queryParameters: <String, String>{'id': newId},
    );
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    WidgetRef ref,
    ReminderTemplate t,
  ) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(l10n.templatesDeleteConfirmTitle(t.name)),
        content: Text(l10n.templatesDeleteConfirmBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      await ref.read(reminderTemplatesControllerProvider.notifier).delete(t.id);
    }
  }
}

enum _AddChoice { fromTemplate, fromScratch }

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.notifications_off_outlined, size: 72),
          const SizedBox(height: 16),
          Text(l10n.templatesEmpty),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.add),
            onPressed: onAdd,
            label: Text(l10n.templatesEmptyAddFirst),
          ),
        ],
      ),
    );
  }
}
