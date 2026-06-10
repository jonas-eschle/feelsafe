import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/core/utils/mode_icons.dart';
import 'package:guardianangela/features/modes/modes_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Modes list screen.
///
/// Lists every non-distress [SessionMode]. Tap to edit, swipe / popup
/// to delete, FAB opens a "blank / from template" picker. See spec 04
/// §Modes Screen.
class ModesScreen extends ConsumerWidget {
  /// Creates a [ModesScreen].
  const ModesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stateAsync = ref.watch(modesControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.modesTitle)),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.modesAdd,
        onPressed: () => _showCreateSheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) =>
            Center(child: Text(l10n.commonErrorWithDetail(e))),
        data: (state) {
          if (state.modes.isEmpty) {
            return Center(child: Text(l10n.modesEmpty));
          }
          return ListView.builder(
            itemCount: state.modes.length,
            itemBuilder: (BuildContext ctx, int i) {
              final m = state.modes[i];
              final tile = ListTile(
                // Per-mode icon (spec 04:1479-1487 "[Walk icon] Walk Mode").
                leading: Icon(modeIcon(m.iconName)),
                title: Row(
                  children: <Widget>[
                    Expanded(child: Text(m.name)),
                    if (m.isBuiltIn) ...<Widget>[
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(l10n.modesBuiltinBadge),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ],
                ),
                subtitle: Text(
                  m.chainSteps.map((s) => s.type.name).join(' → '),
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (String key) async {
                    switch (key) {
                      case 'edit':
                        await context.pushNamed<void>(
                          RouteNames.modeEditor,
                          queryParameters: <String, String>{'id': m.id},
                        );
                      case 'duplicate':
                        await ref
                            .read(modesControllerProvider.notifier)
                            .duplicate(m.id);
                      case 'delete':
                        if (m.isBuiltIn) return;
                        final ok = await _confirmDelete(ctx, m.name);
                        if (ok) {
                          await ref
                              .read(modesControllerProvider.notifier)
                              .delete(m.id);
                        }
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
                      enabled: !m.isBuiltIn,
                      child: Tooltip(
                        message: m.isBuiltIn ? l10n.modesBuiltinNoDelete : '',
                        child: Text(l10n.commonDelete),
                      ),
                    ),
                  ],
                ),
                onTap: () => context.pushNamed(
                  RouteNames.modeEditor,
                  queryParameters: <String, String>{'id': m.id},
                ),
              );
              if (m.isBuiltIn) return tile;
              return Dismissible(
                key: ValueKey<String>(m.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Theme.of(ctx).colorScheme.error,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) => _confirmDelete(ctx, m.name),
                onDismissed: (_) {
                  ref.read(modesControllerProvider.notifier).delete(m.id);
                },
                child: tile,
              );
            },
          );
        },
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String name) async {
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext ctx) => AlertDialog(
            title: Text(l10n.modesDeleteConfirmTitle),
            content: Text(l10n.modesDeleteConfirmBody(name)),
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
        ) ??
        false;
  }

  Future<void> _showCreateSheet(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final state = ref.read(modesControllerProvider).value;
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text(l10n.modesNewPickerBlank),
              subtitle: Text(l10n.modesNewPickerBlankSubtitle),
              onTap: () async {
                final id = await ref
                    .read(modesControllerProvider.notifier)
                    .createBlank();
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
                await context.pushNamed<void>(
                  RouteNames.modeEditor,
                  queryParameters: <String, String>{'id': id},
                );
              },
            ),
            const Divider(),
            if (state != null)
              for (final m in state.modes)
                ListTile(
                  title: Text(l10n.modesNewPickerFromTemplate(m.name)),
                  subtitle: Text(l10n.modesNewPickerFromTemplateSubtitle),
                  onTap: () async {
                    final id = await ref
                        .read(modesControllerProvider.notifier)
                        .duplicate(m.id);
                    if (!ctx.mounted) return;
                    Navigator.of(ctx).pop();
                    await context.pushNamed<void>(
                      RouteNames.modeEditor,
                      queryParameters: <String, String>{'id': id},
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}
