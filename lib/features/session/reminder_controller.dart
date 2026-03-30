import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/reminder_template.dart';
import '../../data/repositories/modes_repository.dart';
import '../../data/repositories/templates_repository.dart';

/// State for the active disguised reminder shown to the user.
class ActiveReminder {
  final ReminderTemplate template;
  final DateTime shownAt;

  const ActiveReminder({required this.template, required this.shownAt});
}

final reminderControllerProvider =
    NotifierProvider<ReminderController, ActiveReminder?>(
  ReminderController.new,
);

/// Manages the lifecycle of disguised reminder prompts during a session.
///
/// When the session engine fires a disguised reminder event, this controller
/// picks a random template from the mode's configured list and exposes it
/// as [ActiveReminder]. The session screen uses this to show the overlay.
class ReminderController extends Notifier<ActiveReminder?> {
  final _rng = Random();

  @override
  ActiveReminder? build() => null;

  /// Pick a random template from the mode's configured list and activate it.
  /// If [modeId] is provided, uses that mode's reminderTemplateIds.
  /// Falls back to picking any available template.
  Future<void> fireReminder({String? modeId}) async {
    final templatesRepo = TemplatesRepository();
    final allTemplates = await templatesRepo.getAll();

    if (allTemplates.isEmpty) return;

    List<ReminderTemplate> candidates = allTemplates;

    // Filter to mode's configured templates if available
    if (modeId != null) {
      final modesRepo = ModesRepository();
      final mode = await modesRepo.getById(modeId);
      if (mode != null && mode.reminderTemplateIds.isNotEmpty) {
        final ids = mode.reminderTemplateIds.toSet();
        final filtered = allTemplates.where((t) => ids.contains(t.id)).toList();
        if (filtered.isNotEmpty) {
          candidates = filtered;
        }
      }
    }

    final template = candidates[_rng.nextInt(candidates.length)];
    state = ActiveReminder(template: template, shownAt: DateTime.now());
  }

  /// Called when the user successfully confirms the reminder.
  void confirm() {
    state = null;
  }

  /// Clear without confirming (e.g., session ended).
  void clear() {
    state = null;
  }
}
