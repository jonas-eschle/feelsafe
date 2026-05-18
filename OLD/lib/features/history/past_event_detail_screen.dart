/// Single past-session detail view.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/domain/models/session_log.dart';
import 'package:guardianangela/features/history/history_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Past-session detail.
class PastEventDetailScreen extends ConsumerWidget {
  /// Creates the detail screen.
  const PastEventDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final id = GoRouterState.of(context).uri.queryParameters['id'];
    final logs =
        ref.watch(historyControllerProvider).value ?? const <SessionLog>[];
    SessionLog? log;
    for (final e in logs) {
      if (e.id == id) {
        log = e;
        break;
      }
    }
    if (log == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.historyDetailTitle)),
        body: Center(child: Text(l.historyEmpty)),
      );
    }
    final entry = log;
    return Scaffold(
      appBar: AppBar(title: Text(l.historyDetailTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(title: Text(entry.modeName)),
          ListTile(title: Text(entry.startedAt.toLocal().toString())),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.share),
        label: Text(l.evidenceExportTitle),
        onPressed: () =>
            context.push('${RouteNames.evidenceExport}?id=${entry.id}'),
      ),
    );
  }
}
