import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/features/template_editor/reminder_template_form.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Create / edit a global reminder template with live preview and a Cancel /
/// Save action pair. See spec 04 §Template Editor (lines 2180–2254).
///
/// Templates saved here are global (`isGlobal: true`, stored in
/// `AppDefaults.templates`). The mode editor reuses the same
/// [ReminderTemplateForm] body for mode-local templates via a separate flow.
class TemplateEditorScreen extends ConsumerStatefulWidget {
  /// Creates a [TemplateEditorScreen].
  const TemplateEditorScreen({super.key, this.templateId});

  /// Template id when editing; null for create.
  final String? templateId;

  @override
  ConsumerState<TemplateEditorScreen> createState() =>
      _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends ConsumerState<TemplateEditorScreen> {
  final GlobalKey<ReminderTemplateFormState> _formKey =
      GlobalKey<ReminderTemplateFormState>();
  bool _loading = true;
  bool _dirty = false;
  ReminderTemplate? _existing;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.templateId == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final db = await ref.read(databaseProvider.future);
      final all = await db.reminderTemplatesDao.getAll();
      _existing = all.firstWhere(
        (ReminderTemplate x) => x.id == widget.templateId,
      );
      if (mounted) setState(() => _loading = false);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<bool> _confirmLeave() async {
    if (!_dirty) return true;
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(l10n.templatesDiscardChangesTitle),
        content: Text(l10n.templatesDiscardChangesBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.templatesDiscardKeep),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.templatesDiscardDiscard),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _save() async {
    final ReminderTemplate? t = _formKey.currentState?.buildTemplate(
      existing: _existing,
      isGlobal: true,
    );
    if (t == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name, title, and body required.')),
      );
      return;
    }
    final db = await ref.read(databaseProvider.future);
    await db.reminderTemplatesDao.upsert(t);
    if (!mounted) return;
    _dirty = false;
    context.pop();
  }

  Future<void> _cancel() async {
    final shouldLeave = await _confirmLeave();
    if (!shouldLeave || !mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (bool didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final shouldPop = await _confirmLeave();
        if (shouldPop && mounted) navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.templateId == null
                ? l10n.templatesCreateTitle
                : l10n.templatesEditTitle,
          ),
          actions: <Widget>[
            TextButton(onPressed: _cancel, child: Text(l10n.commonCancel)),
            TextButton(onPressed: _save, child: Text(l10n.commonSave)),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: ReminderTemplateForm(
                  key: _formKey,
                  initial: _existing,
                  onDirtyChanged: (bool dirty) {
                    if (dirty && !_dirty) setState(() => _dirty = true);
                  },
                ),
              ),
      ),
    );
  }
}
