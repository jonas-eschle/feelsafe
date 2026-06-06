import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';

/// Hard-coded built-in template used when the session pool is entirely empty
/// (spec 02 §disguisedReminder template selection, step 2). In practice the
/// pool is never empty — 8 templates are seeded on first launch — so this is
/// a defensive last resort, never the normal path.
final ReminderTemplate _emptyPoolFallback = ReminderTemplate(
  id: 'builtin_reminder_fallback',
  name: 'Reminder',
  title: 'Reminder',
  body: 'Tap to check in.',
  confirmationType: ConfirmationType.dismiss,
  isCustom: false,
  displayStyle: ReminderDisplayStyle.subtle,
  isGlobal: true,
);

/// Selects the reminder template to show for a `disguisedReminder` fire.
///
/// Pure and stateless — implements the selection algorithm from spec 02
/// §disguisedReminder template selection (Extra-8, C4). The caller (the
/// session controller) owns the avoidance state and passes [avoidId]; this
/// function never reads the clock itself ([nowMillis] is injected) so it is
/// fully deterministic and testable.
///
/// Algorithm:
/// 1. Filter [pool] to [templateIds] when that list is non-empty; otherwise
///    every template is eligible.
/// 2. If the filter matches nothing, fall back to the full [pool] (and, if
///    that is empty too, the hard-coded built-in template).
/// 3. `randomizeTemplateOrder == false` → the first eligible template.
/// 4. `randomizeTemplateOrder == true` → a time-based index
///    (`nowMillis ~/ 1000 % length`) so the disguise varies without a
///    `Random` instance.
///
/// Finally, when [avoidId] matches the chosen template and at least one other
/// eligible template exists, the next template is used instead so the same
/// disguise does not appear twice in a row (C4).
ReminderTemplate selectReminderTemplate({
  required List<ReminderTemplate> pool,
  required List<String> templateIds,
  required bool randomizeTemplateOrder,
  required int nowMillis,
  String? avoidId,
}) {
  if (pool.isEmpty) {
    return _emptyPoolFallback;
  }
  // Step 1 + 2: filter, falling back to the full pool when nothing matches.
  final filtered = templateIds.isEmpty
      ? pool
      : pool.where((t) => templateIds.contains(t.id)).toList();
  final candidates = filtered.isEmpty ? pool : filtered;

  // Step 3 + 4: pick the base index.
  final baseIndex = randomizeTemplateOrder
      ? (nowMillis ~/ 1000) % candidates.length
      : 0;
  final chosen = candidates[baseIndex];

  // C4: avoid repeating the previous template when an alternative exists.
  if (avoidId != null && chosen.id == avoidId && candidates.length > 1) {
    return candidates[(baseIndex + 1) % candidates.length];
  }
  return chosen;
}
