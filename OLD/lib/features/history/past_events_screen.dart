/// Past sessions list with search + mode filter + date range.
///
/// Issues-v4 #15: a TabBar splits real (`isSimulation == false`) from
/// simulated (`isSimulation == true`) sessions so simulation runs do
/// not pollute the user's actual history.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/domain/models/session_log.dart';
import 'package:guardianangela/features/history/history_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Past events screen.
class PastEventsScreen extends ConsumerStatefulWidget {
  /// Creates the past-events screen.
  const PastEventsScreen({super.key});

  @override
  ConsumerState<PastEventsScreen> createState() => _PastEventsScreenState();
}

class _PastEventsScreenState extends ConsumerState<PastEventsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String? _modeFilter;
  DateTimeRange? _dateRange;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  List<SessionLog> _filter(List<SessionLog> logs) {
    final query = _searchCtrl.text.trim().toLowerCase();
    return logs
        .where((log) {
          if (_modeFilter != null && log.modeName != _modeFilter) return false;
          if (_dateRange != null) {
            final start = _dateRange!.start;
            final endInclusive = _dateRange!.end
                .add(const Duration(days: 1))
                .subtract(const Duration(microseconds: 1));
            if (log.startedAt.isBefore(start)) return false;
            if (log.startedAt.isAfter(endInclusive)) return false;
          }
          if (query.isEmpty) return true;
          return log.modeName.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(historyControllerProvider);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.historyTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l.historyTabReal),
              Tab(text: l.historyTabSimulated),
            ],
          ),
        ),
        body: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('$e')),
          data: (logs) {
            final realLogs = logs.where((l) => !l.isSimulation).toList();
            final simLogs = logs.where((l) => l.isSimulation).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Filters(
                  searchCtrl: _searchCtrl,
                  onSearchChanged: () => setState(() {}),
                  modeNames: {for (final log in logs) log.modeName},
                  modeFilter: _modeFilter,
                  onModeFilterChanged: (v) => setState(() => _modeFilter = v),
                  dateRange: _dateRange,
                  onPickDateRange: _pickDateRange,
                  onClearDateRange: () => setState(() => _dateRange = null),
                  fmt: _fmt,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _LogList(
                        logs: _filter(realLogs),
                        onDelete: (id) => ref
                            .read(historyControllerProvider.notifier)
                            .delete(id),
                      ),
                      _LogList(
                        logs: _filter(simLogs),
                        onDelete: (id) => ref
                            .read(historyControllerProvider.notifier)
                            .delete(id),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.searchCtrl,
    required this.onSearchChanged,
    required this.modeNames,
    required this.modeFilter,
    required this.onModeFilterChanged,
    required this.dateRange,
    required this.onPickDateRange,
    required this.onClearDateRange,
    required this.fmt,
  });

  final TextEditingController searchCtrl;
  final VoidCallback onSearchChanged;
  final Set<String> modeNames;
  final String? modeFilter;
  final ValueChanged<String?> onModeFilterChanged;
  final DateTimeRange? dateRange;
  final VoidCallback onPickDateRange;
  final VoidCallback onClearDateRange;
  final String Function(DateTime) fmt;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            controller: searchCtrl,
            onChanged: (_) => onSearchChanged(),
            decoration: InputDecoration(
              hintText: l.historySearchHint,
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        if (modeNames.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: DropdownButtonFormField<String?>(
              initialValue: modeFilter,
              decoration: InputDecoration(
                labelText: l.historyFilterModeLabel,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(l.historyFilterModeAll),
                ),
                for (final name in modeNames)
                  DropdownMenuItem<String?>(value: name, child: Text(name)),
              ],
              onChanged: onModeFilterChanged,
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: dateRange == null
              ? OutlinedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(l.historyDateRangePick),
                  onPressed: onPickDateRange,
                )
              : InputChip(
                  label: Text(
                    '${fmt(dateRange!.start)} – ${fmt(dateRange!.end)}',
                  ),
                  avatar: const Icon(Icons.date_range, size: 18),
                  onPressed: onPickDateRange,
                  onDeleted: onClearDateRange,
                ),
        ),
      ],
    );
  }
}

class _LogList extends StatelessWidget {
  const _LogList({required this.logs, required this.onDelete});

  final List<SessionLog> logs;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (logs.isEmpty) return Center(child: Text(l.historyEmpty));
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, i) {
        final log = logs[i];
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(log.modeName),
          subtitle: Text(log.startedAt.toLocal().toString()),
          onTap: () =>
              context.push('${RouteNames.pastEventDetail}?id=${log.id}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => onDelete(log.id),
          ),
        );
      },
    );
  }
}
