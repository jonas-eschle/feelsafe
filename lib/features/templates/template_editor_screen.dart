import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:safewayhome/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/pride_widgets.dart';
import '../../data/models/reminder_template.dart';
import '../session/widgets/disguised_reminder_overlay.dart';
import 'templates_controller.dart';

class TemplateEditorScreen extends ConsumerStatefulWidget {
  final String? templateId;

  const TemplateEditorScreen({super.key, this.templateId});

  @override
  ConsumerState<TemplateEditorScreen> createState() =>
      _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends ConsumerState<TemplateEditorScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _bodyController;
  late final TextEditingController _keywordController;
  late final TextEditingController _buttonLabelController;
  late ConfirmationType _confirmationType;
  String? _imagePath;
  bool _loaded = false;

  ReminderTemplate? _existingTemplate;

  bool get _isNew => widget.templateId == null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _titleController = TextEditingController();
    _subtitleController = TextEditingController();
    _bodyController = TextEditingController();
    _keywordController = TextEditingController();
    _buttonLabelController = TextEditingController();
    _confirmationType = ConfirmationType.tapButton;

    // Listen to all controllers to rebuild live preview
    for (final c in [
      _nameController,
      _titleController,
      _subtitleController,
      _bodyController,
      _keywordController,
      _buttonLabelController,
    ]) {
      c.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() {
    setState(() {});
  }

  void _loadTemplate(ReminderTemplate tpl) {
    if (_loaded) return;
    _loaded = true;
    _existingTemplate = tpl;
    _nameController.text = tpl.name;
    _titleController.text = tpl.title;
    _subtitleController.text = tpl.subtitle ?? '';
    _bodyController.text = tpl.body;
    _keywordController.text = tpl.keyword ?? '';
    _buttonLabelController.text = tpl.buttonLabel ?? '';
    _confirmationType = tpl.confirmationType;
    _imagePath = tpl.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _bodyController.dispose();
    _keywordController.dispose();
    _buttonLabelController.dispose();
    super.dispose();
  }

  /// Build a transient template from the current form state for live preview.
  ReminderTemplate get _previewTemplate {
    return ReminderTemplate(
      id: 'preview',
      name: _nameController.text.isNotEmpty
          ? _nameController.text
          : 'Notification',
      title: _titleController.text.isNotEmpty
          ? _titleController.text
          : 'Title',
      body: _bodyController.text.isNotEmpty ? _bodyController.text : 'Body',
      subtitle: _subtitleController.text.isNotEmpty
          ? _subtitleController.text
          : null,
      confirmationType: _confirmationType,
      keyword: _keywordController.text.isNotEmpty
          ? _keywordController.text
          : 'house',
      buttonLabel: _buttonLabelController.text.isNotEmpty
          ? _buttonLabelController.text
          : 'OK',
      imagePath: _imagePath,
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'template_${DateTime.now().millisecondsSinceEpoch}.png';
    final savedFile = await File(picked.path).copy('${appDir.path}/$fileName');

    setState(() {
      _imagePath = savedFile.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final templatesAsync = ref.watch(templatesControllerProvider);

    // Load existing template data if editing
    if (!_isNew && !_loaded) {
      templatesAsync.whenData((templates) {
        final tpl = templates.cast<ReminderTemplate?>().firstWhere(
              (t) => t!.id == widget.templateId,
              orElse: () => null,
            );
        if (tpl != null) _loadTemplate(tpl);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? l10n.reminderTemplates : _nameController.text),
        bottom: const PrideAppBarBottom(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Live preview
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 120,
              child: OverflowBox(
                alignment: Alignment.topCenter,
                maxHeight: 120 / 0.55,
                maxWidth: double.infinity,
                child: Transform.scale(
                  scale: 0.55,
                  alignment: Alignment.topCenter,
                  child: IgnorePointer(
                    child: DisguisedReminderOverlay(
                      template: _previewTemplate,
                      onConfirmed: () {},
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.contactName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // Title
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // Subtitle (new)
          TextField(
            controller: _subtitleController,
            decoration: InputDecoration(
              labelText: l10n.templateSubtitle,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // Body
          TextField(
            controller: _bodyController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Body',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Image picker
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: _imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_imagePath!),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.image_outlined),
            title: Text(l10n.templateImage),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_imagePath != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _imagePath = null),
                  ),
                IconButton(
                  icon: const Icon(Icons.photo_library),
                  onPressed: _pickImage,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Confirmation type
          Text(
            l10n.checkInMechanism,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          SegmentedButton<ConfirmationType>(
            segments: const [
              ButtonSegment(
                value: ConfirmationType.tapButton,
                icon: Icon(Icons.touch_app),
                label: Text('Tap'),
              ),
              ButtonSegment(
                value: ConfirmationType.tapWord,
                icon: Icon(Icons.spellcheck),
                label: Text('Word'),
              ),
              ButtonSegment(
                value: ConfirmationType.swipe,
                icon: Icon(Icons.swipe),
                label: Text('Swipe'),
              ),
              ButtonSegment(
                value: ConfirmationType.dismiss,
                icon: Icon(Icons.close),
                label: Text('Dismiss'),
              ),
            ],
            selected: {_confirmationType},
            onSelectionChanged: (set) {
              setState(() => _confirmationType = set.first);
            },
          ),
          const SizedBox(height: 12),

          // Conditional fields based on confirmation type
          if (_confirmationType == ConfirmationType.tapWord)
            TextField(
              controller: _keywordController,
              decoration: const InputDecoration(
                labelText: 'Keyword',
                border: OutlineInputBorder(),
              ),
            ),
          if (_confirmationType == ConfirmationType.tapButton)
            TextField(
              controller: _buttonLabelController,
              decoration: const InputDecoration(
                labelText: 'Button Label',
                border: OutlineInputBorder(),
              ),
            ),

          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.save),
            label: Text(l10n.save),
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  void _save() {
    final name = _nameController.text.trim();
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (name.isEmpty || title.isEmpty || body.isEmpty) return;

    final subtitle = _subtitleController.text.trim();

    final template = ReminderTemplate(
      id: _existingTemplate?.id ?? const Uuid().v4(),
      name: name,
      title: title,
      body: body,
      subtitle: subtitle.isNotEmpty ? subtitle : null,
      confirmationType: _confirmationType,
      keyword: _confirmationType == ConfirmationType.tapWord
          ? _keywordController.text.trim()
          : null,
      buttonLabel: _confirmationType == ConfirmationType.tapButton
          ? _buttonLabelController.text.trim()
          : null,
      isCustom: _existingTemplate?.isCustom ?? true,
      imagePath: _imagePath,
    );

    ref.read(templatesControllerProvider.notifier).saveTemplate(template);
    context.pop();
  }
}
