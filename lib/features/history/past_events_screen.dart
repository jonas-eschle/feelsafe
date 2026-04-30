/// Past sessions list with search + mode filter + date range.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(historyControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.historyTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('$e')),
        data: (logs) {
          final query = _searchCtrl.text.trim().toLowerCase();
          final modeNames = {for (final log in logs) log.modeName};
          final filtered = logs.where((log) {
            if (_modeFilter != null && log.modeName != _modeFilter) {
              return false;
            }
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
          }).toList(growable: false);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
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
                    initialValue: _modeFilter,
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
                        DropdownMenuItem<String?>(
                          value: name,
                          child: Text(name),
                        ),
                    ],
                    onChanged: (v) => setState(() => _modeFilter = v),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: _dateRange == null
                    ? OutlinedButton.icon(
                        icon: const Icon(Icons.date_range),
                        label: Text(l.historyDateRangePick),
                        onPressed: _pickDateRange,
                      )
                    : InputChip(
                        label: Text(
                          '${_fmt(_dateRange!.start)} – '
                          '${_fmt(_dateRange!.end)}',
                        ),
                        avatar: const Icon(Icons.date_range, size: 18),
                        onPressed: _pickDateRange,
                        onDeleted: () =>
                            setState(() => _dateRange = null),
                      ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Text(l.historyEmpty))
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final log = filtered[i];
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
            ],
          );
        },
      ),
    );
  }
}
