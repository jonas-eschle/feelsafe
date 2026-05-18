/// Session evidence export screen (copy text/JSON).
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/features/history/history_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Evidence export screen.
class EvidenceExportScreen extends ConsumerWidget {
  /// Creates the evidence-export screen.
  const EvidenceExportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final id = GoRouterState.of(context).uri.queryParameters['id'];
    final logs = ref.watch(historyControllerProvider).value ?? const [];
    final log = id == null ? null : logs.where((e) => e.id == id).firstOrNull;
    return Scaffold(
      appBar: AppBar(title: Text(l.evidenceExportTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton(
              onPressed: log == null
                  ? null
                  : () async {
                      await Clipboard.setData(
                        ClipboardData(text: log.toString()),
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(l.evidenceCopied)));
                    },
              child: Text(l.evidenceExportAsText),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: log == null
                  ? null
                  : () async {
                      await Clipboard.setData(
                        ClipboardData(text: log.toJson().toString()),
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(l.evidenceCopied)));
                    },
              child: Text(l.evidenceExportAsJson),
            ),
          ],
        ),
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
