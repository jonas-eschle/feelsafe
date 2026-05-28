import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/features/distress_modes/distress_modes_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Distress modes list screen.
///
/// Reuses the same UX shape as the regular modes screen but only shows
/// `SessionMode`s where `isDistressMode == true`. See spec 04
/// §Distress Modes Screen.
class DistressModesScreen extends ConsumerWidget {
  /// Creates a [DistressModesScreen].
  const DistressModesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stateAsync = ref.watch(distressModesControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.modesDistressTitle)),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.modesAdd,
        onPressed: () async {
          final id = await ref
              .read(distressModesControllerProvider.notifier)
              .createBlank();
          if (!context.mounted) return;
          await context.pushNamed<void>(
            RouteNames.distressModeEditor,
            queryParameters: <String, String>{'id': id},
          );
        },
        child: const Icon(Icons.add),
      ),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(child: Text('Error: $e')),
        data: (state) {
          if (state.modes.isEmpty) {
            return Center(child: Text(l10n.distressModesEmpty));
          }
          return ListView.builder(
            itemCount: state.modes.length,
            itemBuilder: (BuildContext ctx, int i) {
              final m = state.modes[i];
              final isDefault = state.defaultId == m.id;
              final isLast = state.modes.length == 1;
              final isInUse = state.referencedIds.contains(m.id);
              return ListTile(
                leading: const Icon(Icons.warning_amber_outlined),
                title: Row(
                  children: <Widget>[
                    Expanded(child: Text(m.name)),
                    if (isDefault) ...<Widget>[
                      const Icon(Icons.star, size: 16),
                      const SizedBox(width: 4),
                      Text(l10n.modesDistressDefaultBadge),
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
                          RouteNames.distressModeEditor,
                          queryParameters: <String, String>{'id': m.id},
                        );
                      case 'duplicate':
                        await ref
                            .read(distressModesControllerProvider.notifier)
                            .duplicate(m.id);
                      case 'default':
                        await ref
                            .read(distressModesControllerProvider.notifier)
                            .setDefault(m.id);
                      case 'delete':
                        if (isLast || isDefault) return;
                        if (isInUse) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.modesDistressInUse)),
                          );
                          return;
                        }
                        await ref
                            .read(distressModesControllerProvider.notifier)
                            .delete(m.id);
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
                    if (!isDefault)
                      PopupMenuItem<String>(
                        value: 'default',
                        child: Text(l10n.modesDistressSetDefault),
                      ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      enabled: !isLast && !isDefault && !isInUse,
                      child: Tooltip(
                        message: isLast
                            ? l10n.modesDistressCantDeleteLast
                            : isInUse
                            ? l10n.modesDistressInUse
                            : '',
                        child: Text(l10n.commonDelete),
                      ),
                    ),
                  ],
                ),
                onTap: () => context.pushNamed(
                  RouteNames.distressModeEditor,
                  queryParameters: <String, String>{'id': m.id},
                ),
              );
            },
          );
        },
      ),
    );
  }
}
