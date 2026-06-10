import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:guardianangela/features/home/home_controller.dart';
import 'package:guardianangela/features/modes/modes_controller.dart';
import 'package:guardianangela/features/reminder_templates/reminder_templates_controller.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/app_state_providers.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Backup & restore screen.
///
/// Wraps `BackupService.exportToJson` + `importFromJson`. Sharing uses
/// `share_plus`; import uses `file_selector`. See spec 04 §Backup &
/// Restore (lines 2358–2402). During an active session the buttons are
/// disabled and a banner explains why.
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
  DateTime? _lastBackupAt;
  bool _lastBackupLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadLastBackup();
  }

  Future<void> _loadLastBackup() async {
    try {
      final settings = await ref.read(appSettingsRepositoryProvider).load();
      if (!mounted) return;
      setState(() {
        _lastBackupAt = settings.lastBackupAt;
        _lastBackupLoaded = true;
      });
    } on Object catch (_) {
      if (!mounted) return;
      setState(() => _lastBackupLoaded = true);
    }
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final service = await ref.read(backupServiceProvider.future);
      final jsonStr = await service.exportToJson(
        includeSessionLogs: _includeLogs,
        includeMedia: _includeMedia,
      );
      await SharePlus.instance.share(
        ShareParams(text: jsonStr, subject: 'Guardian Angela backup'),
      );
      // Record the successful backup timestamp so the UI can surface
      // "Last backup at <time>" (spec 04:2401 / R-39). The save is
      // best-effort; failure to persist must not block the export
      // share that already succeeded.
      try {
        final repo = ref.read(appSettingsRepositoryProvider);
        final settings = await repo.load();
        final now = DateTime.now().toUtc();
        await repo.save(settings.copyWith(lastBackupAt: now));
        if (mounted) setState(() => _lastBackupAt = now);
      } on Object catch (_) {
        // Persisting the timestamp is non-essential.
      }
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
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'JSON',
      extensions: <String>['json'],
    );
    final XFile? file = await openFile(
      acceptedTypeGroups: <XTypeGroup>[typeGroup],
    );
    if (file == null) return;
    setState(() => _busy = true);
    try {
      final Uint8List bytes = await file.readAsBytes();
      if (bytes.isEmpty) return;
      final service = await ref.read(backupServiceProvider.future);
      await service.importFromJson(utf8.decode(bytes));
      if (!mounted) return;
      // importFromJson wiped + re-inserted sessionModes behind both list
      // controllers' backs; home and modes are keep-alive, so without a
      // rebuild their cached chip lists would keep showing the deleted
      // pre-restore modes until app restart (spec 04:1518-1521). Stays at
      // the screen layer — BackupService must remain Riverpod-free.
      ref.invalidate(homeControllerProvider);
      ref.invalidate(modesControllerProvider);
      // importFromJson also wiped + re-inserted reminder_templates; the
      // templates list controller caches its DAO read the same way (bug #14
      // staleness family).
      ref.invalidate(reminderTemplatesControllerProvider);
      // importFromJson also overwrote the AppSettings singleton, which may
      // carry a different themeMode / languageCode; the root MaterialApp
      // reads both from the keep-alive appSettingsLiveProvider, so without
      // this re-read the restored theme + language would not apply until
      // the next cold start.
      ref.invalidate(appSettingsLiveProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.backupImportSuccess)));
    } on FormatException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.backupImportError(e.message)),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.backupImportError(e.toString())),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
      // StateError (forward-incompatible schema) is intentionally
      // surfaced via the broader Object catch below — `avoid_catching_errors`
      // disallows narrowing it.
    } on Object catch (e) {
      // ignore: avoid_catches_without_on_clauses
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.backupImportError(e.toString())),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sessionState = ref.watch(sessionControllerProvider).value;
    final sessionRunning =
        sessionState != null &&
        sessionState.activeChain.isNotEmpty &&
        sessionState.phase != SessionPhase.idle &&
        sessionState.phase != SessionPhase.ended;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupTitle)),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            if (_busy) const LinearProgressIndicator(),
            if (sessionRunning)
              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.errorContainer,
                padding: const EdgeInsets.all(12),
                child: Text(
                  l10n.backupActiveSessionBanner,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  SwitchListTile(
                    title: Text(l10n.backupIncludeLogs),
                    value: _includeLogs,
                    onChanged: sessionRunning
                        ? null
                        : (bool v) => setState(() => _includeLogs = v),
                  ),
                  SwitchListTile(
                    title: Text(l10n.backupIncludeMedia),
                    value: _includeMedia,
                    onChanged: sessionRunning
                        ? null
                        : (bool v) => setState(() => _includeMedia = v),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    icon: const Icon(Icons.upload_outlined),
                    onPressed: (_busy || sessionRunning) ? null : _export,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    label: Text(l10n.backupExportButton),
                  ),
                  const SizedBox(height: 12),
                  if (_lastBackupLoaded)
                    ListTile(
                      dense: true,
                      title: Text(
                        _lastBackupAt == null
                            ? l10n.backupNeverExportedLabel
                            : l10n.backupLastBackupAtLabel(
                                _lastBackupAt!.toLocal().toString(),
                              ),
                      ),
                    ),
                  const Divider(),
                  Text(
                    l10n.backupOverwriteWarning,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.download_outlined),
                    onPressed: (_busy || sessionRunning) ? null : _import,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    label: Text(l10n.backupImportButton),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
