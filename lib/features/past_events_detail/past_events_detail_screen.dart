import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import 'package:guardianangela/domain/models/session_log.dart';
import 'package:guardianangela/features/past_events/past_events_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Session log detail / evidence-export screen.
///
/// `evidenceMode` switches the share format to JSON for police reports.
/// Spec 04 §Session Log Detail (lines 2463–2550) requires a Delete
/// IconButton in the AppBar and a Share menu with a "PDF" option.
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

  Future<void> _shareText() async {
    final log = _log;
    if (log == null) return;
    final text = widget.evidenceMode
        ? _toEvidenceJson(log)
        : _toTextSummary(log);
    await SharePlus.instance.share(
      ShareParams(text: text, subject: 'Guardian Angela session log'),
    );
  }

  Future<void> _sharePdf() async {
    final log = _log;
    if (log == null) return;
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (pw.Context ctx) => <pw.Widget>[
          pw.Header(level: 0, text: 'Guardian Angela session log'),
          pw.Paragraph(text: 'Mode: ${log.modeName}'),
          pw.Paragraph(text: 'Started: ${log.startedAt.toIso8601String()}'),
          if (log.endedAt != null)
            pw.Paragraph(text: 'Ended: ${log.endedAt!.toIso8601String()}'),
          pw.SizedBox(height: 12),
          pw.Header(text: 'Events'),
          pw.TableHelper.fromTextArray(
            headers: const <String>['Timestamp', 'Type'],
            data: <List<String>>[
              for (final e in log.events)
                <String>[e.timestamp.toIso8601String(), e.eventType],
            ],
          ),
        ],
      ),
    );
    final bytes = await doc.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'guardian_angela_${log.id}.pdf',
    );
  }

  Future<void> _confirmAndDelete() async {
    final log = _log;
    if (log == null) return;
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(l10n.pastEventsDeleteConfirm),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.pastEventsDetailDelete),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      await ref.read(pastEventsControllerProvider.notifier).softDelete(log.id);
      if (mounted) Navigator.of(context).pop();
    }
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

  /// Builds the police-report evidence bundle via [jsonEncode] so
  /// user-editable strings (mode name) are escaped correctly — hand-rolled
  /// interpolation produced malformed JSON for quotes/backslashes/newlines.
  String _toEvidenceJson(SessionLog log) => jsonEncode(<String, Object?>{
    'id': log.id,
    'modeName': log.modeName,
    'startedAt': log.startedAt.toIso8601String(),
    'endedAt': log.endedAt?.toIso8601String() ?? '',
    'events': <Object?>[
      for (final e in log.events)
        <String, Object?>{
          'timestamp': e.timestamp.toIso8601String(),
          'type': e.eventType,
        },
    ],
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pastEventsDetailTitle),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.pastEventsDetailDelete,
            icon: const Icon(Icons.delete_outline),
            onPressed: _log == null ? null : _confirmAndDelete,
          ),
          PopupMenuButton<_ShareChoice>(
            tooltip: l10n.pastEventsDetailShare,
            icon: const Icon(Icons.share),
            enabled: _log != null,
            onSelected: (choice) {
              switch (choice) {
                case _ShareChoice.text:
                  _shareText();
                case _ShareChoice.pdf:
                  _sharePdf();
              }
            },
            itemBuilder: (_) => <PopupMenuEntry<_ShareChoice>>[
              PopupMenuItem<_ShareChoice>(
                value: _ShareChoice.text,
                child: Text(l10n.pastEventsDetailShareText),
              ),
              PopupMenuItem<_ShareChoice>(
                value: _ShareChoice.pdf,
                child: Text(l10n.pastEventsDetailSharePdf),
              ),
            ],
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

enum _ShareChoice { text, pdf }

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
