import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';

import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// The 8 canonical icon categories enumerated by spec 04:2246. The
/// dropdown value persists to [ReminderTemplate.iconAsset].
const List<String> kReminderIconCategories = <String>[
  'calendar',
  'app_notification',
  'fitness',
  'health',
  'food',
  'coffee',
  'battery',
  'weather',
];

/// Maps an icon category to its Material [IconData].
IconData reminderIconDataFor(String category) => switch (category) {
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

/// The shared reminder-template form body: name / icon / title / body
/// fields, confirmation-type and display-style radios, and a live preview.
///
/// Owns its own field state so it can be reused by both the global
/// [TemplateEditorScreen] (which persists to the database with
/// `isGlobal: true`) and the mode editor's mode-local template flow (which
/// stages a `isGlobal: false` template into the in-memory draft). Neither
/// the database nor navigation is touched here — the host reads the current
/// value via [ReminderTemplateFormState.buildTemplate] and decides what to
/// do with it. See spec 04 §Template Editor (lines 2180–2254).
class ReminderTemplateForm extends StatefulWidget {
  /// Creates a [ReminderTemplateForm].
  const ReminderTemplateForm({super.key, this.initial, this.onDirtyChanged});

  /// The template to edit; null seeds an empty create form.
  final ReminderTemplate? initial;

  /// Called the first time any field changes, so the host can track
  /// unsaved-changes state for its own discard prompt.
  final ValueChanged<bool>? onDirtyChanged;

  @override
  State<ReminderTemplateForm> createState() => ReminderTemplateFormState();
}

/// State for [ReminderTemplateForm], exposing [buildTemplate] for the host.
class ReminderTemplateFormState extends State<ReminderTemplateForm> {
  final TextEditingController _nameCtl = TextEditingController();
  final TextEditingController _titleCtl = TextEditingController();
  final TextEditingController _bodyCtl = TextEditingController();
  ConfirmationType _confirmType = ConfirmationType.tapButton;
  ReminderDisplayStyle _displayStyle = ReminderDisplayStyle.fullScreen;
  String _iconCategory = 'calendar';
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final ReminderTemplate? t = widget.initial;
    if (t != null) {
      _nameCtl.text = t.name;
      _titleCtl.text = t.title;
      _bodyCtl.text = t.body;
      _confirmType = t.confirmationType;
      _displayStyle = t.displayStyle;
      _iconCategory =
          t.iconAsset != null && kReminderIconCategories.contains(t.iconAsset)
          ? t.iconAsset!
          : 'calendar';
    }
    _nameCtl.addListener(_markDirty);
    _titleCtl.addListener(_markDirty);
    _bodyCtl.addListener(_markDirty);
  }

  void _markDirty() {
    if (!_dirty) {
      setState(() => _dirty = true);
      widget.onDirtyChanged?.call(true);
    } else {
      // Rebuild so the live preview tracks the latest text.
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _titleCtl.dispose();
    _bodyCtl.dispose();
    super.dispose();
  }

  /// Whether the form has been edited since it was opened.
  bool get isDirty => _dirty;

  /// Builds a [ReminderTemplate] from the current field values, or null when
  /// the required name/title/body are blank.
  ///
  /// Reuses [existing]'s id when set; otherwise mints a fresh UUID. [isGlobal]
  /// distinguishes a global template (stored in `AppDefaults.templates`) from
  /// a mode-local one (staged into `ModeOverrides.localTemplates`).
  ReminderTemplate? buildTemplate({
    required ReminderTemplate? existing,
    required bool isGlobal,
  }) {
    final String name = _nameCtl.text.trim();
    final String title = _titleCtl.text.trim();
    final String body = _bodyCtl.text.trim();
    if (name.isEmpty || title.isEmpty || body.isEmpty) {
      return null;
    }
    return ReminderTemplate(
      id: existing?.id ?? const Uuid().v4(),
      name: name,
      title: title,
      body: body,
      iconAsset: _iconCategory,
      confirmationType: _confirmType,
      buttonLabel: _confirmType == ConfirmationType.tapButton ? 'OK' : null,
      isCustom: true,
      displayStyle: _displayStyle,
      isGlobal: isGlobal,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        TextField(
          controller: _nameCtl,
          decoration: InputDecoration(labelText: l10n.templatesNameLabel),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _iconCategory,
          decoration: InputDecoration(labelText: l10n.templatesIconLabel),
          items: <DropdownMenuItem<String>>[
            for (final cat in kReminderIconCategories)
              DropdownMenuItem<String>(
                value: cat,
                child: Row(
                  children: <Widget>[
                    Icon(reminderIconDataFor(cat)),
                    const SizedBox(width: 8),
                    Text(_iconLabel(cat, l10n)),
                  ],
                ),
              ),
          ],
          onChanged: (String? v) {
            if (v != null) {
              setState(() => _iconCategory = v);
              _markDirty();
            }
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _titleCtl,
          decoration: InputDecoration(labelText: l10n.templatesTitleLabel),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _bodyCtl,
          maxLines: 3,
          decoration: InputDecoration(labelText: l10n.templatesBodyLabel),
        ),
        const SizedBox(height: 16),
        RadioGroup<ConfirmationType>(
          groupValue: _confirmType,
          onChanged: (ConfirmationType? v) {
            if (v != null) {
              setState(() => _confirmType = v);
              _markDirty();
            }
          },
          child: Column(
            children: <Widget>[
              for (final t in ConfirmationType.values)
                RadioListTile<ConfirmationType>(title: Text(t.name), value: t),
            ],
          ),
        ),
        const SizedBox(height: 16),
        RadioGroup<ReminderDisplayStyle>(
          groupValue: _displayStyle,
          onChanged: (ReminderDisplayStyle? v) {
            if (v != null) {
              setState(() => _displayStyle = v);
              _markDirty();
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
/// form re-runs `build()` so typing updates the preview live.
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
                Icon(reminderIconDataFor(iconCategory), size: 28),
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
