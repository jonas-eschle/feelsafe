import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:guardianangela/core/widgets/swipe_slider.dart';
import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/features/disguised_reminder/reminder_word_choices.dart';
import 'package:guardianangela/features/template_editor/reminder_template_form.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Renders the disguise content of a [ReminderTemplate] — icon, title,
/// optional subtitle, body — followed by the [ReminderConfirmation]
/// interaction matching the template's [ConfirmationType].
///
/// Shared by the inline reminder step UI ([subtle] templates) and the
/// full-screen `DisguisedReminderScreen` ([fullScreen] templates) so both
/// presentations stay consistent. [onConfirm] fires when the user completes
/// the confirmation interaction (their "I'm safe" check-in).
class ReminderDisguiseContent extends StatelessWidget {
  /// Creates a [ReminderDisguiseContent].
  const ReminderDisguiseContent({
    super.key,
    required this.template,
    required this.onConfirm,
  });

  /// The selected disguise to render.
  final ReminderTemplate template;

  /// Fired once the user completes the template's confirmation interaction.
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final subtitle = template.subtitle;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _TemplateDisguiseIcon(template: template),
        const SizedBox(height: 12),
        Text(
          template.title,
          style: textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        if (subtitle != null && subtitle.isNotEmpty) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 8),
        Text(
          template.body,
          style: textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ReminderConfirmation(template: template, onConfirm: onConfirm),
      ],
    );
  }
}

/// The leading disguise glyph for a [ReminderTemplate].
///
/// Renders the template's own art when set, falling back to a neutral
/// notification icon otherwise (user decision M3 #6):
///
/// 1. [ReminderTemplate.imagePath] — a custom image (full-screen disguise art);
///    rendered from assets, or from the device file system when an absolute
///    path. This is the richest disguise, so it wins.
/// 2. [ReminderTemplate.iconAsset] — either one of the canonical
///    [kReminderIconCategories] keys (the value the template editor persists),
///    mapped to its Material symbol, or an asset image path (e.g.
///    `assets/icons/<name>.png`, per spec 03 §ReminderTemplate).
/// 3. Otherwise the Material [Icons.notifications_active_outlined] fallback.
///
/// A broken image reference degrades to the Material fallback rather than
/// showing an error glyph, so a bad path can never make the disguise obvious.
class _TemplateDisguiseIcon extends StatelessWidget {
  const _TemplateDisguiseIcon({required this.template});

  final ReminderTemplate template;

  static const double _size = 48;

  @override
  Widget build(BuildContext context) {
    final imagePath = template.imagePath;
    if (imagePath != null && imagePath.isNotEmpty) {
      return _image(imagePath);
    }
    final iconAsset = template.iconAsset;
    if (iconAsset != null && iconAsset.isNotEmpty) {
      if (kReminderIconCategories.contains(iconAsset)) {
        return _materialIcon(context, reminderIconDataFor(iconAsset));
      }
      if (_looksLikeAssetPath(iconAsset)) {
        return _image(iconAsset);
      }
    }
    return _fallback(context);
  }

  Widget _image(String path) {
    final ImageProvider provider = path.startsWith('/')
        ? FileImage(File(path))
        : AssetImage(path) as ImageProvider;
    return Image(
      image: provider,
      width: _size,
      height: _size,
      fit: BoxFit.contain,
      // A missing asset/file must never surface an error glyph — that would
      // break the disguise. Degrade silently to the neutral Material icon.
      errorBuilder: (context, error, stackTrace) => _fallback(context),
    );
  }

  Widget _materialIcon(BuildContext context, IconData icon) =>
      Icon(icon, size: _size, color: Theme.of(context).colorScheme.primary);

  Widget _fallback(BuildContext context) =>
      _materialIcon(context, Icons.notifications_active_outlined);

  /// Heuristic: an [iconAsset] that is not a known category key is treated as
  /// an asset path when it looks like one (contains a slash or ends in a
  /// common image extension), matching the `assets/icons/<name>.png`-style
  /// example in spec 03 §ReminderTemplate.
  static bool _looksLikeAssetPath(String value) {
    if (value.contains('/')) {
      return true;
    }
    const exts = <String>['.png', '.jpg', '.jpeg', '.webp', '.gif', '.bmp'];
    final lower = value.toLowerCase();
    return exts.any(lower.endsWith);
  }
}

/// The confirmation interaction for a disguised reminder, chosen by the
/// template's [ConfirmationType] (spec 02 §disguisedReminder Disarm).
///
/// - [ConfirmationType.tapButton] → a single labelled button.
/// - [ConfirmationType.tapWord] → the keyword among decoy words.
/// - [ConfirmationType.swipe] → a swipe-to-dismiss track.
/// - [ConfirmationType.dismiss] → a dismiss button.
///
/// Each completed interaction calls [onConfirm] exactly once.
class ReminderConfirmation extends StatelessWidget {
  /// Creates a [ReminderConfirmation].
  const ReminderConfirmation({
    super.key,
    required this.template,
    required this.onConfirm,
  });

  /// The template whose [ReminderTemplate.confirmationType] selects the UI.
  final ReminderTemplate template;

  /// Fired once when the user completes the confirmation.
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (template.confirmationType) {
      ConfirmationType.tapButton => FilledButton(
        onPressed: onConfirm,
        child: Text(_buttonLabel(l10n)),
      ),
      ConfirmationType.tapWord => _TapWordChoices(
        keyword: template.keyword ?? '',
        onConfirm: onConfirm,
      ),
      ConfirmationType.swipe => SwipeSlider(
        label: l10n.sessionReminderSwipeLabel,
        onConfirm: onConfirm,
        threshold: 0.85,
      ),
      ConfirmationType.dismiss => OutlinedButton.icon(
        onPressed: onConfirm,
        icon: const Icon(Icons.close),
        label: Text(l10n.sessionReminderDismissLabel),
      ),
    };
  }

  String _buttonLabel(AppLocalizations l10n) {
    final label = template.buttonLabel;
    if (label != null && label.isNotEmpty) {
      return label;
    }
    return l10n.sessionReminderDefaultButton;
  }
}

/// The `tapWord` confirmation: the correct [keyword] shown among decoys.
///
/// Tapping the correct word (case-insensitive) checks the user in; tapping a
/// decoy gives a light haptic nudge and is otherwise ignored, so an onlooker
/// sees an ordinary "pick the option" prompt. The prompt deliberately never
/// reveals which word is correct.
class _TapWordChoices extends StatelessWidget {
  const _TapWordChoices({required this.keyword, required this.onConfirm});

  final String keyword;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final words = buildReminderWordChoices(
      keyword,
      decoyPool: _decoyPoolFor(l10n),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          l10n.sessionReminderTapWordHint,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: <Widget>[
            for (final word in words)
              OutlinedButton(onPressed: () => _onTap(word), child: Text(word)),
          ],
        ),
      ],
    );
  }

  void _onTap(String word) {
    if (word.toLowerCase() == keyword.toLowerCase()) {
      onConfirm();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  /// Parses the comma-separated localized decoy words for the current locale.
  ///
  /// Returns null when the resource is blank, letting
  /// [buildReminderWordChoices] fall back to its English pool.
  static List<String>? _decoyPoolFor(AppLocalizations l10n) {
    final words = <String>[
      for (final raw in l10n.sessionReminderDecoyWords.split(','))
        if (raw.trim().isNotEmpty) raw.trim().toUpperCase(),
    ];
    return words.isEmpty ? null : words;
  }
}
