import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:guardianangela/domain/models/session_log.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Session log detail / evidence-export screen.
///
/// `evidenceMode` switches the share format to JSON for police reports.
/// See spec 04 §Session Log Detail.
class PastEventsDetailScreen extends ConsumerStatefulWidget {
  /// Creates a [PastEventsDetailScreen].
  const PastEventsDetailScreen({
    super.key,
    required this.logId,
    this.evidenceMode = false,
  });

  /// Session log id from the route.
  final String logId;

  /// When true, the share action exports a JSON evidence bundle.
  final bool evidenceMode;

  @override
  ConsumerState<PastEventsDetailScreen> createState() =>
      _PastEventsDetailScreenState();
}

class _PastEventsDetailScreenState
    extends ConsumerState<PastEventsDetailScreen> {
  SessionLog? _log;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = await ref.read(sessionLogRepositoryProvider.future);
    final log = await repo.getById(widget.logId);
    if (mounted) {
      setState(() {
        _log = log;
        _loading = false;
      });
    }
  }

  Future<void> _share() async {
    final log = _log;
    if (log == null) return;
    final text = widget.evidenceMode
        ? _toEvidenceJson(log)
        : _toTextSummary(log);
    await SharePlus.instance.share(
      ShareParams(text: text, subject: 'Guardian Angela session log'),
    );
  }

  String _toTextSummary(SessionLog log) {
    final lines = <String>[
      'Mode: ${log.modeName}',
      'Start: ${log.startedAt}',
      if (log.endedAt != null) 'End: ${log.endedAt}',
      'Events:',
      for (final e in log.events) '  ${e.timestamp} — ${e.eventType}',
    ];
    return lines.join('\n');
  }

  String _toEvidenceJson(SessionLog log) {
    final buf = StringBuffer('{')
      ..write('"id":"${log.id}",')
      ..write('"modeName":"${log.modeName}",')
      ..write('"startedAt":"${log.startedAt.toIso8601String()}",')
      ..write('"endedAt":"${log.endedAt?.toIso8601String() ?? ''}",')
      ..write('"events":[');
    for (int i = 0; i < log.events.length; i++) {
      final e = log.events[i];
      if (i > 0) buf.write(',');
      buf
        ..write('{')
        ..write('"timestamp":"${e.timestamp.toIso8601String()}",')
        ..write('"type":"${e.eventType}"')
        ..write('}');
    }
    buf.write(']}');
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pastEventsDetailTitle),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.pastEventsDetailShare,
            icon: const Icon(Icons.share),
            onPressed: _log == null ? null : _share,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _log == null
          ? Center(child: Text(l10n.pastEventsEmpty))
          : _LogBody(log: _log!),
    );
  }
}

class _LogBody extends StatelessWidget {
  const _LogBody({required this.log});

  final SessionLog log;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(log.modeName, style: textTheme.titleLarge),
        if (log.isSimulation) const Chip(label: Text('SIM')),
        const SizedBox(height: 8),
        Text('Start: ${log.startedAt}', style: textTheme.bodyMedium),
        if (log.endedAt != null)
          Text('End: ${log.endedAt}', style: textTheme.bodyMedium),
        const Divider(),
        for (final e in log.events)
          ListTile(
            dense: true,
            leading: const Icon(Icons.event_note),
            title: Text('${e.timestamp}'),
            subtitle: Text(e.eventType),
          ),
      ],
    );
  }
}
