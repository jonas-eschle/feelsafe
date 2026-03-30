import 'models/escalation_chain.dart';
import 'models/reminder_template.dart';
import 'models/session_mode.dart';
import 'repositories/modes_repository.dart';
import 'repositories/templates_repository.dart';

/// Seeds default modes and reminder templates on first launch.
Future<void> seedDefaults() async {
  final modesRepo = ModesRepository();
  final templatesRepo = TemplatesRepository();

  if (await modesRepo.isEmpty()) {
    await _seedModes(modesRepo);
  }
  if (await templatesRepo.isEmpty()) {
    await _seedTemplates(templatesRepo);
  }
}

Future<void> _seedModes(ModesRepository repo) async {
  final walkChain = EscalationChain.walkDefaults();
  final dateChain = EscalationChain.dateDefaults();

  await repo.save(SessionMode(
    id: 'walk_mode',
    name: 'Walk Mode',
    iconName: 'directions_walk',
    checkInMechanism: CheckInMechanism.holdButton,
    checkInIntervalSeconds: 10,
    missedTolerance: 0,
    escalationSteps: walkChain.steps,
    isBuiltIn: true,
  ));

  await repo.save(SessionMode(
    id: 'date_mode',
    name: 'Date Mode',
    iconName: 'local_cafe',
    checkInMechanism: CheckInMechanism.disguisedReminder,
    checkInIntervalSeconds: 1800,
    missedTolerance: 2,
    escalationSteps: dateChain.steps,
    reminderTemplateIds: [
      'tpl_calendar',
      'tpl_duolingo',
      'tpl_delivery',
      'tpl_weather',
      'tpl_fitness',
      'tpl_message',
      'tpl_app_update',
      'tpl_battery',
    ],
    isBuiltIn: true,
  ));
}

Future<void> _seedTemplates(TemplatesRepository repo) async {
  final templates = [
    ReminderTemplate(
      id: 'tpl_calendar',
      name: 'Calendar Event',
      title: 'Calendar',
      body: 'Team standup in 15 min',
      confirmationType: ConfirmationType.tapButton,
      buttonLabel: 'Dismiss',
    ),
    ReminderTemplate(
      id: 'tpl_duolingo',
      name: 'Language Lesson',
      title: 'Duolingo',
      body: "Don't lose your streak! Translate:",
      confirmationType: ConfirmationType.tapWord,
      keyword: 'house',
    ),
    ReminderTemplate(
      id: 'tpl_delivery',
      name: 'Delivery Update',
      title: 'Delivery',
      body: 'Your package is out for delivery',
      confirmationType: ConfirmationType.swipe,
    ),
    ReminderTemplate(
      id: 'tpl_weather',
      name: 'Weather Alert',
      title: 'Weather',
      body: 'Rain expected at 10 PM',
      confirmationType: ConfirmationType.tapButton,
      buttonLabel: 'OK',
    ),
    ReminderTemplate(
      id: 'tpl_fitness',
      name: 'Fitness Reminder',
      title: 'Fitness',
      body: 'Time for your evening walk!',
      confirmationType: ConfirmationType.tapButton,
      buttonLabel: 'Skip',
    ),
    ReminderTemplate(
      id: 'tpl_message',
      name: 'Message Preview',
      title: 'Mom',
      body: 'Are you coming home for dinner?',
      confirmationType: ConfirmationType.tapButton,
      buttonLabel: 'Reply',
    ),
    ReminderTemplate(
      id: 'tpl_app_update',
      name: 'App Update',
      title: 'SafeWayHome',
      body: 'Update available',
      confirmationType: ConfirmationType.tapButton,
      buttonLabel: 'Later',
    ),
    ReminderTemplate(
      id: 'tpl_battery',
      name: 'Battery Warning',
      title: 'System',
      body: 'Battery optimization active',
      confirmationType: ConfirmationType.swipe,
    ),
  ];

  for (final template in templates) {
    await repo.save(template);
  }
}
