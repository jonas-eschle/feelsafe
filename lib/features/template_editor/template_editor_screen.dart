import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Create / edit a reminder template.
///
/// See spec 04 §Template Editor.
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
  final _nameCtl = TextEditingController();
  final _titleCtl = TextEditingController();
  final _bodyCtl = TextEditingController();
  ConfirmationType _confirmType = ConfirmationType.tapButton;
  ReminderDisplayStyle _displayStyle = ReminderDisplayStyle.fullScreen;
  bool _loading = true;
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
      final t = all.firstWhere(
        (ReminderTemplate x) => x.id == widget.templateId,
      );
      _nameCtl.text = t.name;
      _titleCtl.text = t.title;
      _bodyCtl.text = t.body;
      _confirmType = t.confirmationType;
      _displayStyle = t.displayStyle;
      _existing = t;
      setState(() => _loading = false);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _titleCtl.dispose();
    _bodyCtl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtl.text.trim();
    final title = _titleCtl.text.trim();
    final body = _bodyCtl.text.trim();
    if (name.isEmpty || title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name, title, and body required.')),
      );
      return;
    }
    final db = await ref.read(databaseProvider.future);
    final t = ReminderTemplate(
      id: _existing?.id ?? const Uuid().v4(),
      name: name,
      title: title,
      body: body,
      confirmationType: _confirmType,
      buttonLabel: _confirmType == ConfirmationType.tapButton ? 'OK' : null,
      isCustom: true,
      displayStyle: _displayStyle,
      isGlobal: true,
    );
    await db.reminderTemplatesDao.upsert(t);
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.templateId == null
              ? l10n.templatesCreateTitle
              : l10n.templatesEditTitle,
        ),
        actions: <Widget>[
          TextButton(onPressed: _save, child: Text(l10n.commonSave)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  TextField(
                    controller: _nameCtl,
                    decoration: InputDecoration(
                      labelText: l10n.templatesNameLabel,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _titleCtl,
                    decoration: InputDecoration(
                      labelText: l10n.templatesTitleLabel,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _bodyCtl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: l10n.templatesBodyLabel,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RadioGroup<ConfirmationType>(
                    groupValue: _confirmType,
                    onChanged: (ConfirmationType? v) {
                      if (v != null) setState(() => _confirmType = v);
                    },
                    child: Column(
                      children: <Widget>[
                        for (final t in ConfirmationType.values)
                          RadioListTile<ConfirmationType>(
                            title: Text(t.name),
                            value: t,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  RadioGroup<ReminderDisplayStyle>(
                    groupValue: _displayStyle,
                    onChanged: (ReminderDisplayStyle? v) {
                      if (v != null) setState(() => _displayStyle = v);
                    },
                    child: Column(
                      children: <Widget>[
                        for (final s in ReminderDisplayStyle.values)
                          RadioListTile<ReminderDisplayStyle>(
                            title: Text(s.name),
                            value: s,
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
