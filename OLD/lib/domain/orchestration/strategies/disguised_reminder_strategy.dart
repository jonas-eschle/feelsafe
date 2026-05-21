/// `DisguisedReminderStrategy` — strategy for
/// `ChainStepType.disguisedReminder`.
///
/// Posts a disguised reminder via the notification service. The
/// template is resolved from `services.context.reminderTemplates`:
/// if `config.templateId` is set and resolves, that template is
/// used; otherwise the first effective template is used. If no
/// template is available (empty list), the strategy logs and
/// returns — no garbage notification.
library;

import 'dart:developer' as developer;

import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';

/// Strategy for disguised-reminder steps.
final class DisguisedReminderStrategy extends EventStrategy {
  /// Const constructor.
  const DisguisedReminderStrategy();

  @override
  Future<void> executeReal(ChainStep step, EventServices services) async {
    final template = _resolveTemplate(step, services);
    if (template == null) {
      developer.log(
        'DisguisedReminderStrategy: no templates available; skipping.',
        name: 'orchestration.disguisedReminder',
      );
      return;
    }
    await services.notification.showDisguisedReminder(
      template: template,
      isSimulation: services.context.isSimulation,
    );
  }

  @override
  SimulationDescription simulationDescription(
    ChainStep step,
    EventServices services,
  ) {
    final template = _resolveTemplate(step, services);
    if (template == null) {
      return const SimulationDescription('simDisguisedReminderEmpty');
    }
    return SimulationDescription(
      'simDisguisedReminder',
      {'title': template.title},
    );
  }

  /// Resolves the template for [step] from [services.context].
  ///
  /// Returns the template whose id matches
  /// `DisguisedReminderConfig.templateId`, or the first entry in
  /// `reminderTemplates`, or null when the list is empty.
  ReminderTemplate? _resolveTemplate(ChainStep step, EventServices services) {
    final templates = services.context.reminderTemplates;
    if (templates.isEmpty) return null;
    final config = step.config;
    if (config is DisguisedReminderConfig && config.templateId != null) {
      for (final t in templates) {
        if (t.id == config.templateId) return t;
      }
    }
    return templates.first;
  }
}
