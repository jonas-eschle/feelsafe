/// Distress modes list with add / edit / delete.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/features/distress_modes/distress_modes_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Distress modes list.
class DistressModesScreen extends ConsumerWidget {
  /// Creates the distress modes screen.
  const DistressModesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(distressModesControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.distressModesTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('$e')),
        data: (modes) => modes.isEmpty
            ? Center(child: Text(l.distressModesEmpty))
            : ListView.builder(
                itemCount: modes.length,
                itemBuilder: (context, i) {
                  final m = modes[i];
                  return ListTile(
                    leading: const Icon(Icons.warning),
                    title: Text(m.name),
                    subtitle: Text('${m.chainSteps.length} steps'),
                    onTap: () => context.push(
                      '${RouteNames.distressModeEditor}?id=${m.id}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      // Refuse to remove the last remaining distress
                      // mode — at least one must exist as a fallback
                      // so distress triggers always have a chain to
                      // execute (D-SAFETY-17).
                      onPressed: modes.length > 1
                          ? () => ref
                              .read(distressModesControllerProvider.notifier)
                              .delete(m.id)
                          : null,
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(l.distressModesAdd),
        onPressed: () => context.push(RouteNames.distressModeEditor),
      ),
    );
  }
}
