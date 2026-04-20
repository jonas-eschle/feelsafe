/// Session-modes list with add / edit / delete / reorder.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/features/modes/modes_controller.dart';
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
                onReorder: (o, n) => ref
                    .read(modesControllerProvider.notifier)
                    .reorder(o, n),
                itemBuilder: (context, i) {
                  final m = modes[i];
                  return ListTile(
                    key: ValueKey(m.id),
                    leading: const Icon(Icons.tune),
                    title: Text(m.name),
                    subtitle: Text('${m.chainSteps.length} steps'),
                    onTap: () => context
                        .push('${RouteNames.modeEditor}?id=${m.id}'),
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
        onPressed: () => context.push(RouteNames.modeEditor),
      ),
    );
  }
}
