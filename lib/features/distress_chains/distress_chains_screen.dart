/// Distress chains list with add / edit / delete.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/features/distress_chains/distress_chains_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Distress chains list.
class DistressChainsScreen extends ConsumerWidget {
  /// Creates the distress chains screen.
  const DistressChainsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(distressChainsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.distressChainsTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('$e')),
        data: (chains) => chains.isEmpty
            ? Center(child: Text(l.distressChainsEmpty))
            : ListView.builder(
                itemCount: chains.length,
                itemBuilder: (context, i) {
                  final c = chains[i];
                  return ListTile(
                    leading: const Icon(Icons.warning),
                    title: Text(c.name),
                    subtitle: Text('${c.steps.length} steps'),
                    onTap: () => context.push(
                      '${RouteNames.distressChainEditor}?id=${c.id}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: chains.length > 1
                          ? () => ref
                              .read(distressChainsControllerProvider.notifier)
                              .delete(c.id)
                          : null,
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(l.distressChainsAdd),
        onPressed: () => context.push(RouteNames.distressChainEditor),
      ),
    );
  }
}
