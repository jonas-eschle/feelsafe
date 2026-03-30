import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../data/models/reminder_template.dart';

/// Callback when the user successfully confirms the disguised reminder.
typedef ReminderConfirmedCallback = void Function();

/// Full-screen overlay that renders a [ReminderTemplate] as a fake
/// notification. The confirmation mechanism varies per [ConfirmationType].
///
/// - **tapButton**: A single button with the template's [buttonLabel].
/// - **tapWord**: Three word options; the user must tap the correct [keyword].
/// - **swipe**: Swipe the notification card left or right to dismiss.
/// - **dismiss**: Tap anywhere on the notification to dismiss.
class DisguisedReminderOverlay extends StatelessWidget {
  final ReminderTemplate template;
  final ReminderConfirmedCallback onConfirmed;
  final VoidCallback? onDismissedWrong;

  const DisguisedReminderOverlay({
    super.key,
    required this.template,
    required this.onConfirmed,
    this.onDismissedWrong,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 32),
              _buildNotificationCard(context),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context) {
    final theme = Theme.of(context);
    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header row: icon + app name + time
        Row(
          children: [
            _buildIcon(theme),
            const SizedBox(width: 8),
            Text(
              template.title,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              'now',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Subtitle (if present)
        if (template.subtitle != null && template.subtitle!.isNotEmpty) ...[
          Text(
            template.subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
        ],
        // Body text
        Text(
          template.body,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        // Confirmation area
        _buildConfirmationArea(context),
      ],
    );

    final card = Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: cardContent,
      ),
    );

    // Wrap with dismissible for swipe type
    if (template.confirmationType == ConfirmationType.swipe) {
      return Dismissible(
        key: ValueKey(template.id),
        onDismissed: (_) => onConfirmed(),
        child: card,
      );
    }

    // Wrap with InkWell for dismiss type
    if (template.confirmationType == ConfirmationType.dismiss) {
      return GestureDetector(
        onTap: onConfirmed,
        child: card,
      );
    }

    return card;
  }

  Widget _buildConfirmationArea(BuildContext context) {
    return switch (template.confirmationType) {
      ConfirmationType.tapButton => _TapButtonConfirmation(
          label: template.buttonLabel ?? 'OK',
          onConfirmed: onConfirmed,
        ),
      ConfirmationType.tapWord => _TapWordConfirmation(
          keyword: template.keyword ?? 'house',
          onConfirmed: onConfirmed,
          onWrong: onDismissedWrong,
        ),
      ConfirmationType.swipe => _SwipeHint(),
      ConfirmationType.dismiss => _DismissHint(),
    };
  }

  Widget _buildIcon(ThemeData theme) {
    if (template.imagePath != null && template.imagePath!.isNotEmpty) {
      final file = File(template.imagePath!);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.file(
            file,
            width: 18,
            height: 18,
            fit: BoxFit.cover,
          ),
        );
      }
    }
    return Icon(
      _templateIcon,
      size: 18,
      color: theme.colorScheme.onSurfaceVariant,
    );
  }

  IconData get _templateIcon {
    // Map known template names to appropriate icons
    final name = template.name.toLowerCase();
    if (name.contains('calendar')) return Icons.calendar_today;
    if (name.contains('language') || name.contains('duolingo')) {
      return Icons.school;
    }
    if (name.contains('delivery')) return Icons.local_shipping;
    if (name.contains('weather')) return Icons.cloud;
    if (name.contains('fitness')) return Icons.fitness_center;
    if (name.contains('message')) return Icons.message;
    if (name.contains('update') || name.contains('app')) return Icons.system_update;
    if (name.contains('battery')) return Icons.battery_alert;
    return Icons.notifications;
  }
}

/// Simple button confirmation (Calendar "Dismiss", Weather "OK", etc.)
class _TapButtonConfirmation extends StatelessWidget {
  final String label;
  final VoidCallback onConfirmed;

  const _TapButtonConfirmation({
    required this.label,
    required this.onConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: onConfirmed,
        child: Text(label),
      ),
    );
  }
}

/// Duolingo-style word selection. Shows 3 words; the user must tap the
/// correct keyword.
class _TapWordConfirmation extends StatefulWidget {
  final String keyword;
  final VoidCallback onConfirmed;
  final VoidCallback? onWrong;

  const _TapWordConfirmation({
    required this.keyword,
    required this.onConfirmed,
    this.onWrong,
  });

  @override
  State<_TapWordConfirmation> createState() => _TapWordConfirmationState();
}

class _TapWordConfirmationState extends State<_TapWordConfirmation> {
  late final List<String> _options;
  String? _selectedWrong;

  static const _decoyWords = [
    'tree',
    'water',
    'book',
    'light',
    'bread',
    'chair',
    'river',
    'cloud',
    'stone',
    'dream',
    'glass',
    'music',
    'clock',
    'train',
    'bridge',
    'garden',
    'window',
    'forest',
    'mirror',
    'flower',
  ];

  @override
  void initState() {
    super.initState();
    final rng = Random();
    // Pick 2 random decoys that aren't the keyword
    final decoys = (_decoyWords.toList()..shuffle(rng))
        .where((w) => w.toLowerCase() != widget.keyword.toLowerCase())
        .take(2)
        .toList();
    _options = [...decoys, widget.keyword]..shuffle(rng);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: _options.map((word) {
        final isWrong = _selectedWrong == word;
        return OutlinedButton(
          onPressed: () {
            if (word.toLowerCase() == widget.keyword.toLowerCase()) {
              widget.onConfirmed();
            } else {
              setState(() => _selectedWrong = word);
              widget.onWrong?.call();
            }
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: isWrong ? Colors.red : null,
            side: isWrong ? const BorderSide(color: Colors.red) : null,
          ),
          child: Text(word),
        );
      }).toList(),
    );
  }
}

/// Visual hint for swipe-to-dismiss.
class _SwipeHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.swipe,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          'Swipe to dismiss',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

/// Visual hint for tap-to-dismiss.
class _DismissHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.touch_app,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          'Tap to dismiss',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
