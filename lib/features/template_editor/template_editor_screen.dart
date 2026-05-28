import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

/// The 8 canonical icon categories enumerated by spec 04:2246. The
/// dropdown value persists to [ReminderTemplate.iconAsset].
const List<String> _kIconCategories = <String>[
  'calendar',
  'app_notification',
  'fitness',
  'health',
  'food',
  'coffee',
  'battery',
  'weather',
];

IconData _iconDataFor(String category) => switch (category) {
  'calendar' => Icons.calendar_today_outlined,
  'app_notification' => Icons.notifications_outlined,
  'fitness' => Icons.fitness_center_outlined,
  'health' => Icons.favorite_border_outlined,
  'food' => Icons.restaurant_outlined,
  'coffee' => Icons.local_cafe_outlined,
  'battery' => Icons.battery_alert_outlined,
  'weather' => Icons.wb_cloudy_outlined,
  _ => Icons.notifications_outlined,
};

/// Create / edit a reminder template with live preview and a Cancel /
/// Save action pair. See spec 04 §Template Editor (lines 2180–2254).
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
  String _iconCategory = 'calendar';
  bool _loading = true;
  bool _dirty = false;
  ReminderTemplate? _existing;

  @override
  void initState() {
    super.initState();
    _load();
    _nameCtl.addListener(_markDirty);
    _titleCtl.addListener(_markDirty);
    _bodyCtl.addListener(_markDirty);
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
      _iconCategory =
          t.iconAsset != null && _kIconCategories.contains(t.iconAsset)
          ? t.iconAsset!
          : 'calendar';
      _existing = t;
      _dirty = false;
      setState(() => _loading = false);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _titleCtl.dispose();
    _bodyCtl.dispose();
    super.dispose();
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
      iconAsset: _iconCategory,
      confirmationType: _confirmType,
      buttonLabel: _confirmType == ConfirmationType.tapButton ? 'OK' : null,
      isCustom: true,
      displayStyle: _displayStyle,
      isGlobal: true,
    );
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
                    DropdownButtonFormField<String>(
                      initialValue: _iconCategory,
                      decoration: InputDecoration(
                        labelText: l10n.templatesIconLabel,
                      ),
                      items: <DropdownMenuItem<String>>[
                        for (final cat in _kIconCategories)
                          DropdownMenuItem<String>(
                            value: cat,
                            child: Row(
                              children: <Widget>[
                                Icon(_iconDataFor(cat)),
                                const SizedBox(width: 8),
                                Text(_iconLabel(cat, l10n)),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (String? v) {
                        if (v != null) {
                          setState(() {
                            _iconCategory = v;
                            _dirty = true;
                          });
                        }
                      },
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
                        if (v != null) {
                          setState(() {
                            _confirmType = v;
                            _dirty = true;
                          });
                        }
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
                        if (v != null) {
                          setState(() {
                            _displayStyle = v;
                            _dirty = true;
                          });
                        }
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
                    const SizedBox(height: 24),
                    Text(
                      l10n.templatesPreviewHeading,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _LivePreview(
                      title: _titleCtl.text.isEmpty
                          ? l10n.templatesTitleLabel
                          : _titleCtl.text,
                      body: _bodyCtl.text,
                      iconCategory: _iconCategory,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  String _iconLabel(String category, AppLocalizations l10n) =>
      switch (category) {
        'calendar' => l10n.templatesIconCalendar,
        'app_notification' => l10n.templatesIconAppNotification,
        'fitness' => l10n.templatesIconFitness,
        'health' => l10n.templatesIconHealth,
        'food' => l10n.templatesIconFood,
        'coffee' => l10n.templatesIconCoffee,
        'battery' => l10n.templatesIconBattery,
        'weather' => l10n.templatesIconWeather,
        _ => category,
      };
}

/// 55%-scaled preview of the reminder card. Rebuilds every frame the
/// editor re-runs `build()` so typing updates the preview live.
class _LivePreview extends StatelessWidget {
  const _LivePreview({
    required this.title,
    required this.body,
    required this.iconCategory,
  });

  final String title;
  final String body;
  final String iconCategory;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.55,
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(_iconDataFor(iconCategory), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
