/// Backup import / export screen.
///
/// Calls [BackupController.exportAll] / [BackupController.importAll]
/// with a user-supplied optional PIN and a per-element [BackupSelection]
/// driven by the on-screen toggles (D5).
///
/// Export payloads are stringified JSON shown in a dialog so the user
/// can copy-paste into email / drive; import accepts pasted JSON the
/// same way.
library;

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/features/backup/backup_controller.dart';
import 'package:guardianangela/features/backup/backup_service.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Backup screen.
class BackupScreen extends ConsumerStatefulWidget {
  /// Creates the backup screen.
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  final _pinController = TextEditingController();

  /// Per-element export selection. The "Settings" toggle is not part
  /// of [BackupSelection] — it is rendered as an always-on disabled
  /// switch (D5: backup must be self-restorable).
  BackupSelection _selection = BackupSelection.all;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.backupTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: TextField(
                controller: _pinController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l.backupPinOptional,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Text(
                l.backupSelectionHeader,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            // Settings — always on, disabled. The backup MUST remain
            // self-restorable, so this toggle cannot be turned off.
            SwitchListTile(
              value: true,
              onChanged: null,
              title: Text(l.backupToggleSettings),
              subtitle: Text(l.backupToggleSettingsSubtitle),
            ),
            SwitchListTile(
              value: _selection.contacts,
              onChanged: (v) => setState(
                () => _selection = _selection.copyWith(contacts: v),
              ),
              title: Text(l.backupToggleContacts),
            ),
            SwitchListTile(
              value: _selection.modes,
              onChanged: (v) => setState(
                () => _selection = _selection.copyWith(modes: v),
              ),
              title: Text(l.backupToggleModes),
            ),
            SwitchListTile(
              value: _selection.distressModes,
              onChanged: (v) => setState(
                () => _selection = _selection.copyWith(distressModes: v),
              ),
              title: Text(l.backupToggleDistressModes),
            ),
            SwitchListTile(
              value: _selection.templates,
              onChanged: (v) => setState(
                () => _selection = _selection.copyWith(templates: v),
              ),
              title: Text(l.backupToggleTemplates),
            ),
            SwitchListTile(
              value: _selection.sessionLogs,
              onChanged: (v) => setState(
                () => _selection = _selection.copyWith(sessionLogs: v),
              ),
              title: Text(l.backupToggleSessionLogs),
            ),
            SwitchListTile(
              value: _selection.recordings,
              onChanged: (v) => setState(
                () => _selection = _selection.copyWith(recordings: v),
              ),
              title: Text(l.backupToggleRecordings),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FilledButton(
                onPressed: _onExport,
                child: Text(l.backupExport),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: OutlinedButton(
                onPressed: _onImport,
                child: Text(l.backupImport),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _onExport() async {
    final l = AppLocalizations.of(context);
    final pin = _pinController.text.trim();
    try {
      final payload = await ref
          .read(backupControllerProvider.notifier)
          .exportAll(
            pin: pin.isEmpty ? null : pin,
            selection: _selection,
          );
      if (!mounted) return;
      final encoded = const JsonEncoder.withIndent('  ').convert(payload);
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.backupExport),
          content: SingleChildScrollView(child: SelectableText(encoded)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l.commonClose),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _onImport() async {
    final l = AppLocalizations.of(context);
    final text = await _promptJson(context);
    if (text == null || text.trim().isEmpty) return;
    final pin = _pinController.text.trim();
    try {
      final payload = jsonDecode(text) as Map<String, Object?>;
      await ref
          .read(backupControllerProvider.notifier)
          .importAll(payload, pin: pin.isEmpty ? null : pin);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.backupImportOk)));
    } on BackupVersionError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } on BackupAuthenticationError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<String?> _promptJson(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.backupImport),
        content: TextField(
          controller: controller,
          maxLines: 10,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: Text(l.commonConfirm),
          ),
        ],
      ),
    );
  }
}
