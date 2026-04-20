/// Backup import / export screen (stubs).
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/features/backup/backup_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Backup screen.
class BackupScreen extends ConsumerWidget {
  /// Creates the backup screen.
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.backupTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.backupNotReady),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                try {
                  await ref.read(backupControllerProvider.notifier).exportAll();
                } on UnimplementedError {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.backupNotReady)),
                  );
                }
              },
              child: Text(l.backupExport),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () async {
                try {
                  await ref
                      .read(backupControllerProvider.notifier)
                      .importAll(const <String, Object?>{});
                } on UnimplementedError {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.backupNotReady)),
                  );
                }
              },
              child: Text(l.backupImport),
            ),
          ],
        ),
      ),
    );
  }
}
