import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:guardianangela/core/widgets/swipe_slider.dart';
import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/features/disguised_reminder/reminder_word_choices.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final subtitle = template.subtitle;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.notifications_active_outlined,
          size: 48,
          color: colorScheme.primary,
        ),
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
    final words = buildReminderWordChoices(keyword);
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
}
