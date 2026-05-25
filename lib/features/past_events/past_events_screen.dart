import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/features/past_events/past_events_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Past sessions screen (history).
///
/// Tabs split real vs. simulated sessions. Tap to view detail, swipe to
/// soft-delete. See spec 04 §Past Events Screen.
class PastEventsScreen extends ConsumerWidget {
  /// Creates a [PastEventsScreen].
  const PastEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stateAsync = ref.watch(pastEventsControllerProvider);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.pastEventsTitle),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(text: l10n.pastEventsTabReal),
              Tab(text: l10n.pastEventsTabSimulated),
            ],
          ),
        ),
        body: stateAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object e, _) => Center(child: Text('Error: $e')),
          data: (state) {
            final real = state.logs.where((s) => !s.isSimulation).toList();
            final sim = state.logs.where((s) => s.isSimulation).toList();
            return TabBarView(
              children: <Widget>[
                _LogList(items: real),
                _LogList(items: sim),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LogList extends ConsumerWidget {
  const _LogList({required this.items});

  final List<PastEventsLog> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (items.isEmpty) {
      return Center(child: Text(l10n.pastEventsEmpty));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext ctx, int i) {
        final log = items[i];
        return Dismissible(
          key: ValueKey<String>(log.id),
          background: Container(
            color: Theme.of(ctx).colorScheme.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            ref.read(pastEventsControllerProvider.notifier).softDelete(log.id);
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(l10n.pastEventsSoftDeleted),
                action: SnackBarAction(
                  label: l10n.pastEventsUndo,
                  onPressed: () => ref
                      .read(pastEventsControllerProvider.notifier)
                      .undo(log.id),
                ),
              ),
            );
          },
          child: ListTile(
            leading: Icon(
              log.isSimulation ? Icons.play_circle_outline : Icons.shield,
            ),
            title: Text(log.modeName),
            subtitle: Text(_formatTime(log.startedAt)),
            trailing: Text(_formatDuration(log.durationSeconds)),
            onTap: () => ctx.pushNamed(
              RouteNames.pastEventDetail,
              queryParameters: <String, String>{'id': log.id},
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime t) =>
      '${t.year}-${t.month.toString().padLeft(2, '0')}-'
      '${t.day.toString().padLeft(2, '0')} '
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}';

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s}s';
  }
}
