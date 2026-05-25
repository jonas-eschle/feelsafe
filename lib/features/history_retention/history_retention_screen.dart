import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/features/history_retention/history_retention_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// History & retention settings screen.
///
/// Two sliders: `sessionLogRetentionDays` (1–365) and
/// `trashRetentionDays` (1–90). See spec 06 §History & Retention.
class HistoryRetentionScreen extends ConsumerWidget {
  /// Creates a [HistoryRetentionScreen].
  const HistoryRetentionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stateAsync = ref.watch(historyRetentionControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyRetentionTitle)),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(child: Text('Error: $e')),
        data: (s) {
          final notifier = ref.read(
            historyRetentionControllerProvider.notifier,
          );
          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text(l10n.historyRetentionLogsLabel),
              Slider(
                value: s.sessionLogRetentionDays.toDouble(),
                min: 1,
                max: 365,
                divisions: 364,
                label: '${s.sessionLogRetentionDays}d',
                onChanged: (double v) =>
                    notifier.setSessionLogRetention(v.round()),
              ),
              Text(
                l10n.historyRetentionLogsHelper,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Text(l10n.historyRetentionTrashLabel),
              Slider(
                value: s.trashRetentionDays.toDouble(),
                min: 1,
                max: 90,
                divisions: 89,
                label: '${s.trashRetentionDays}d',
                onChanged: (double v) => notifier.setTrashRetention(v.round()),
              ),
              Text(
                l10n.historyRetentionTrashHelper,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}
