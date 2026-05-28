import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/features/history_retention/history_retention_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Snap stops shared by both retention sliders (spec 06 §History &
/// Retention).
const List<int> _kRetentionStops = <int>[1, 3, 7, 14, 30, 60, 90, 180, 365];

/// Sub-range of stops accepted by the trash slider (max 90).
const List<int> _kTrashStops = <int>[1, 3, 7, 14, 30, 60, 90];

/// History & retention settings screen.
///
/// Two sliders snapping to spec'd stops: `sessionLogRetentionDays`
/// (1–365) and `trashRetentionDays` (1–90), a Purge now button, and an
/// SnackBar emitted on every controller update. See spec 06 §History
/// & Retention.
class HistoryRetentionScreen extends ConsumerStatefulWidget {
  /// Creates a [HistoryRetentionScreen].
  const HistoryRetentionScreen({super.key});

  @override
  ConsumerState<HistoryRetentionScreen> createState() =>
      _HistoryRetentionScreenState();
}

class _HistoryRetentionScreenState
    extends ConsumerState<HistoryRetentionScreen> {
  Future<void> _purgeNow() async {
    final l10n = AppLocalizations.of(context);
    final settings = await ref.read(appSettingsRepositoryProvider).load();
    final repo = await ref.read(sessionLogRepositoryProvider.future);
    final purged = await repo.purgeExpiredLogs(
      retentionDays: settings.sessionLogRetentionDays,
      trashRetentionDays: settings.trashRetentionDays,
      now: DateTime.now().toUtc(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.historyRetentionPurged(purged))),
    );
  }

  void _notifyUpdated() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.historyRetentionUpdated),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              _SnapSlider(
                stops: _kRetentionStops,
                value: s.sessionLogRetentionDays,
                onChanged: (int v) async {
                  await notifier.setSessionLogRetention(v);
                  _notifyUpdated();
                },
              ),
              Text(
                l10n.historyRetentionLogsHelper,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Text(l10n.historyRetentionTrashLabel),
              _SnapSlider(
                stops: _kTrashStops,
                value: s.trashRetentionDays,
                onChanged: (int v) async {
                  await notifier.setTrashRetention(v);
                  _notifyUpdated();
                },
              ),
              Text(
                l10n.historyRetentionTrashHelper,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: _purgeNow,
                label: Text(l10n.historyRetentionPurgeNow),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A Material [Slider] that snaps onChanged to the nearest value in
/// [stops]. Spec 06 §History & Retention enumerates the canonical
/// stops as `[1,3,7,14,30,60,90,180,365]`.
class _SnapSlider extends StatelessWidget {
  const _SnapSlider({
    required this.stops,
    required this.value,
    required this.onChanged,
  });

  /// Allowed values, sorted ascending. Must be non-empty.
  final List<int> stops;

  /// Currently selected value. Snaps to the closest stop on render.
  final int value;

  /// Fires whenever the user releases the thumb on a different stop.
  final ValueChanged<int> onChanged;

  int _snap(double raw) {
    int best = stops.first;
    int bestDist = (raw.round() - best).abs();
    for (final int stop in stops) {
      final int d = (raw.round() - stop).abs();
      if (d < bestDist) {
        best = stop;
        bestDist = d;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final int min = stops.first;
    final int max = stops.last;
    return Slider(
      value: value.toDouble().clamp(min.toDouble(), max.toDouble()),
      min: min.toDouble(),
      max: max.toDouble(),
      divisions: stops.length - 1,
      label: '${value}d',
      onChanged: (double v) {
        final int snapped = _snap(v);
        if (snapped != value) onChanged(snapped);
      },
    );
  }
}
