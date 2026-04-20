/// Backup import / export screen.
///
/// Calls [BackupController.exportAll] / [BackupController.importAll]
/// with a user-supplied optional PIN. Export payloads are stringified
/// JSON shown in a dialog so the user can copy-paste into email /
/// drive; import accepts pasted JSON the same way. File-system
/// read/write is deferred to a Phase 15.1 enhancement.
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _pinController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l.backupPinOptional,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _onExport, child: Text(l.backupExport)),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _onImport, child: Text(l.backupImport)),
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
          .exportAll(pin: pin.isEmpty ? null : pin);
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
