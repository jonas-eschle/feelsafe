/// Reminder-template create / edit form.
library;

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/features/templates/templates_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Template editor.
class TemplateEditorScreen extends ConsumerStatefulWidget {
  /// Creates the template editor.
  const TemplateEditorScreen({super.key});

  @override
  ConsumerState<TemplateEditorScreen> createState() =>
      _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends ConsumerState<TemplateEditorScreen> {
  ReminderTemplate? _existing;
  final _nameCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _keywordCtrl = TextEditingController();
  final _buttonCtrl = TextEditingController();
  ConfirmationType _confirm = ConfirmationType.tapButton;
  ReminderDisplayStyle _display = ReminderDisplayStyle.subtle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = GoRouterState.of(context).uri.queryParameters['id'];
    if (id != null && _existing == null) {
      final all =
          ref.read(templatesControllerProvider).value ??
          const <ReminderTemplate>[];
      for (final t in all) {
        if (t.id == id) {
          _existing = t;
          _nameCtrl.text = t.name;
          _titleCtrl.text = t.title;
          _bodyCtrl.text = t.body;
          _keywordCtrl.text = t.keyword ?? '';
          _buttonCtrl.text = t.buttonLabel ?? '';
          _confirm = t.confirmationType;
          _display = t.displayStyle;
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _keywordCtrl.dispose();
    _buttonCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final template = ReminderTemplate(
      id: _existing?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim().isEmpty ? 'Template' : _nameCtrl.text.trim(),
      title: _titleCtrl.text,
      body: _bodyCtrl.text,
      confirmationType: _confirm,
      displayStyle: _display,
      isGlobal: _existing?.isGlobal ?? true,
      isCustom: true,
      keyword: _keywordCtrl.text.trim().isEmpty ? null : _keywordCtrl.text,
      buttonLabel: _buttonCtrl.text.trim().isEmpty ? null : _buttonCtrl.text,
    );
    await ref.read(templatesControllerProvider.notifier).save(template);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _existing == null
              ? l.templateEditorTitleCreate
              : l.templateEditorTitleEdit,
        ),
        actions: [IconButton(onPressed: _save, icon: const Icon(Icons.check))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(labelText: l.templateFieldName),
          ),
          TextField(
            controller: _titleCtrl,
            decoration: InputDecoration(labelText: l.templateFieldTitle),
          ),
          TextField(
            controller: _bodyCtrl,
            decoration: InputDecoration(labelText: l.templateFieldBody),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ConfirmationType>(
            initialValue: _confirm,
            decoration: InputDecoration(
              labelText: l.templateFieldConfirmationType,
            ),
            items: [
              DropdownMenuItem(
                value: ConfirmationType.tapButton,
                child: Text(l.templateConfirmTapButton),
              ),
              DropdownMenuItem(
                value: ConfirmationType.tapWord,
                child: Text(l.templateConfirmTapWord),
              ),
              DropdownMenuItem(
                value: ConfirmationType.swipe,
                child: Text(l.templateConfirmSwipe),
              ),
              DropdownMenuItem(
                value: ConfirmationType.dismiss,
                child: Text(l.templateConfirmDismiss),
              ),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _confirm = v);
            },
          ),
          DropdownButtonFormField<ReminderDisplayStyle>(
            initialValue: _display,
            decoration: InputDecoration(labelText: l.templateFieldDisplayStyle),
            items: [
              DropdownMenuItem(
                value: ReminderDisplayStyle.fullScreen,
                child: Text(l.templateDisplayFullscreen),
              ),
              DropdownMenuItem(
                value: ReminderDisplayStyle.subtle,
                child: Text(l.templateDisplaySubtle),
              ),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _display = v);
            },
          ),
          TextField(
            controller: _keywordCtrl,
            decoration: InputDecoration(labelText: l.templateFieldKeyword),
          ),
          TextField(
            controller: _buttonCtrl,
            decoration: InputDecoration(labelText: l.templateFieldButtonLabel),
          ),
        ],
      ),
    );
  }
}
