import 'dart:developer';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';

/// Unique ID base for disguised-reminder notifications.
///
/// Each step's notification ID is derived from [ChainStep.order] offset by
/// this base so it never collides with the foreground-service notification
/// (ID 1) or other fixed IDs.
const int _kReminderNotificationIdBase = 100;

/// Strategy for [ChainStepType.disguisedReminder] steps.
///
/// Real mode: fires [NotificationServiceProtocol.showDisguisedReminder] with
/// maximum-urgency flags (Extra-35 fullScreenIntent / Importance.max) so the
/// reminder surfaces when the device is locked. The reminder overlay is also
/// rendered by [SessionScreen] in response to the engine's `stepFired` event
/// (Phase 6); the notification is the out-of-app delivery path.
///
/// Vibration: [VibrationServiceProtocol.reminderPattern] fires in both real
/// and simulation mode (local hardware, safe in sim per spec 02 §Simulation
/// behavior summary).
///
/// Simulation: both notification and vibration fire normally (local-only
/// actions). No `[SIM]` card substitution is needed; this strategy returns
/// `null` from [simulationDescription].
///
/// See spec 02 §2 disguisedReminder and spec 05:843-867 for notification flags.
final class DisguisedReminderStrategy implements EventStrategy {
  /// Creates a [DisguisedReminderStrategy].
  const DisguisedReminderStrategy();

  @override
  Future<void> executeReal(ChainStep step, EventServices services) async {
    final config = step.config is DisguisedReminderConfig
        ? step.config! as DisguisedReminderConfig
        : const DisguisedReminderConfig();

    // Vibration: fires in real and simulation mode (local hardware, safe in
    // sim per spec 02 §Simulation behavior summary and spec 05:211-213).
    await services.vibration.reminderPattern();

    // Notification: fires in real and simulation mode so out-of-app delivery
    // works. The notification layer does not need a [SIM] suffix here — the
    // overlay drives the primary UX; the notification is supplemental.
    //
    // Title/body come from the template the controller selected for this fire
    // (spec 02 §disguisedReminder template selection) so the notification
    // shows the same disguise as the in-app overlay. The fallbacks only apply
    // defensively when no template was attached (e.g. an empty pool).
    final notificationId = _kReminderNotificationIdBase + step.order;
    final template = services.selectedReminderTemplate;
    final title =
        template?.title ??
        (config.blackScreenMode ? 'Reminder' : 'Guardian Angela');
    final body = template?.body ?? 'Check in now.';

    log(
      'DisguisedReminderStrategy: firing notification id=$notificationId '
      'title="$title"',
      name: 'DisguisedReminderStrategy',
    );

    await services.notification.showDisguisedReminder(
      id: notificationId,
      title: title,
      body: body,
    );
  }

  /// Returns `null` — the actual reminder overlay fires identically in
  /// simulation; no `[SIM]` card substitution is needed. The background
  /// notification carries a `[SIM]` suffix, applied by the notification
  /// layer (Phase 5), not by this strategy.
  @override
  String? simulationDescription(ChainStep step, EventServices services) => null;
}
