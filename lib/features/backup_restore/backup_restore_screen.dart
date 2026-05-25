import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Backup & restore screen.
///
/// Wraps `BackupService.exportToJson` + `importFromJson`. Sharing uses
/// `share_plus`; import uses `file_picker`. See spec 04 §Backup & Restore.
class BackupRestoreScreen extends ConsumerStatefulWidget {
  /// Creates a [BackupRestoreScreen].
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() =>
      _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  bool _includeLogs = true;
  bool _includeMedia = true;
  bool _busy = false;

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final service = await ref.read(backupServiceProvider.future);
      final jsonStr = await service.exportToJson();
      await SharePlus.instance.share(
        ShareParams(text: jsonStr, subject: 'Guardian Angela backup'),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(l10n.backupTitle),
        content: Text(l10n.settingsImportConfirmBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    setState(() => _busy = true);
    try {
      final bytes = result.files.first.bytes;
      if (bytes == null) return;
      final service = await ref.read(backupServiceProvider.future);
      await service.importFromJson(utf8.decode(bytes));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Import complete. Restart to apply.')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            SwitchListTile(
              title: Text(l10n.backupIncludeLogs),
              value: _includeLogs,
              onChanged: (bool v) => setState(() => _includeLogs = v),
            ),
            SwitchListTile(
              title: Text(l10n.backupIncludeMedia),
              value: _includeMedia,
              onChanged: (bool v) => setState(() => _includeMedia = v),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.upload_outlined),
              onPressed: _busy ? null : _export,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              label: Text(l10n.backupExportButton),
            ),
            const Divider(),
            Text(
              l10n.backupOverwriteWarning,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.download_outlined),
              onPressed: _busy ? null : _import,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              label: Text(l10n.backupImportButton),
            ),
          ],
        ),
      ),
    );
  }
}
