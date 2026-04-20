/// Past sessions list.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/features/history/history_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Past events screen.
class PastEventsScreen extends ConsumerWidget {
  /// Creates the past-events screen.
  const PastEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(historyControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.historyTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('$e')),
        data: (logs) => logs.isEmpty
            ? Center(child: Text(l.historyEmpty))
            : ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, i) {
                  final log = logs[i];
                  return ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(log.modeName),
                    subtitle: Text(log.startedAt.toLocal().toString()),
                    onTap: () => context.push(
                      '${RouteNames.pastEventDetail}?id=${log.id}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => ref
                          .read(historyControllerProvider.notifier)
                          .delete(log.id),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
