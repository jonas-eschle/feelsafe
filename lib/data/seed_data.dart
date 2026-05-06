/// First-run seeding for Guardian Angela's persistent store.
///
/// Seeds the two built-in modes (Walk Mode + Date Mode), the default
/// distress mode (a SessionMode with isDistressMode=true), the
/// 8 disguised-reminder templates, the default app settings /
/// user profile / battery alert, and the per-step-type event
/// defaults (via `AppSettings.defaults`).
///
/// The entry point [seedData] is idempotent: it inspects each
/// repository and only writes entries that do not yet exist. Pre-
/// alpha policy: the stable human-readable ids below are part of
/// the schema — never renumber them without a nuke-and-reseed.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';

/// Stable ids for the built-in modes.
class SeedModeIds {
  const SeedModeIds._();

  /// Walk Mode (hold-button check-in).
  static const String walk = 'seed.mode.walk';

  /// Date Mode (disguised reminder check-in).
  static const String date = 'seed.mode.date';
}

/// Stable id of the default distress-flagged mode.
const String seedDefaultDistressModeId = 'seed.distress.default';

/// Idempotent first-launch seeding. Writes built-in modes (regular
/// + distress-flagged), templates, default app settings, the empty
/// user profile, and the default battery-alert config — only for
/// entries that are not already persisted.
///
/// [ref] — the Riverpod handle used to resolve repository providers.
Future<void> seedData(Ref ref) async {
  final templatesRepo = ref.read(templatesRepositoryProvider);
  final modesRepo = ref.read(modesRepositoryProvider);
  final settingsRepo = ref.read(settingsRepositoryProvider);
  final profileRepo = ref.read(userProfileRepositoryProvider);
  final batteryRepo = ref.read(batteryAlertRepositoryProvider);

  // Reminder templates.
  for (final template in _builtInTemplates()) {
    if (await templatesRepo.getById(template.id) == null) {
      await templatesRepo.save(template);
    }
  }

  // Built-in modes: walk + date + the default distress-flagged mode.
  if (await modesRepo.getById(SeedModeIds.walk) == null) {
    await modesRepo.save(_walkMode());
  }
  if (await modesRepo.getById(SeedModeIds.date) == null) {
    await modesRepo.save(_dateMode());
  }
  if (await modesRepo.getById(seedDefaultDistressModeId) == null) {
    await modesRepo.save(_defaultDistressMode());
  }

  // App settings (includes AppDefaults + EventDefaults).
  if (await settingsRepo.get() == null) {
    await settingsRepo.save(const AppSettings(defaults: AppDefaults()));
  }

  // User profile — empty stub; onboarding fills it in.
  if (await profileRepo.get() == null) {
    await profileRepo.save(const UserProfile());
  }

  // Battery alert — default on at 15%.
  if (await batteryRepo.get() == null) {
    await batteryRepo.save(const BatteryAlertConfig());
  }
}

// ---------------------------------------------------------------------
// Default distress mode
// ---------------------------------------------------------------------

/// The built-in fallback distress mode — a `SessionMode` with
/// `isDistressMode=true`, referenced by every regular mode that
/// doesn't override `distressModeId`.
SessionMode _defaultDistressMode() => const SessionMode(
  id: seedDefaultDistressModeId,
  name: 'Default Distress Chain',
  checkInType: ChainStepType.smsContact,
  isDistressMode: true,
  chainSteps: [
    ChainStep(
      id: 'seed.distress.step.sms',
      type: ChainStepType.smsContact,
      order: 0,
      durationSeconds: 5,
      gracePeriodSeconds: 0,
      config: SmsContactConfig(
        contactSelection: SmsContactSelection.firstContact,
        includeLocation: true,
      ),
    ),
    ChainStep(
      id: 'seed.distress.step.wait',
      type: ChainStepType.countdownWarning,
      order: 1,
      durationSeconds: 15,
      gracePeriodSeconds: 0,
    ),
    ChainStep(
      id: 'seed.distress.step.emergency',
      type: ChainStepType.callEmergency,
      order: 2,
      durationSeconds: 30,
      gracePeriodSeconds: 0,
      config: CallEmergencyConfig(showConfirmation: false),
    ),
  ],
);

// ---------------------------------------------------------------------
// Built-in modes
// ---------------------------------------------------------------------

SessionMode _walkMode() => const SessionMode(
  id: SeedModeIds.walk,
  name: 'Walk Mode',
  // Issues-v4 #12 — seed an iconName so the Walk tile matches its
  // mode-editor selection on Home + Modes list. The legacy
  // name-heuristic in `home_screen._iconForModeName` is kept as a
  // fallback for unnamed user modes.
  iconName: 'directions_walk',
  checkInType: ChainStepType.holdButton,
  chainSteps: [
    ChainStep(
      id: 'seed.mode.walk.step.hold',
      type: ChainStepType.holdButton,
      order: 0,
      durationSeconds: 0,
      // Issues-v4 #16: hold-button grace defaults to 0 (escalate
      // immediately when the countdown ends). Spec 02 § hold-button
      // says 5s; updated per user-test feedback. Spec doc updated in
      // Phase 14.
      gracePeriodSeconds: 0,
    ),
    ChainStep(
      id: 'seed.mode.walk.step.countdown',
      type: ChainStepType.countdownWarning,
      order: 1,
      durationSeconds: 15,
      gracePeriodSeconds: 0,
    ),
    ChainStep(
      id: 'seed.mode.walk.step.alarm',
      type: ChainStepType.loudAlarm,
      order: 2,
      durationSeconds: 30,
      gracePeriodSeconds: 0,
    ),
  ],
  distressTriggers: [
    HardwareButtonDistressTrigger(
      buttonType: ButtonType.volumeUp,
      trigger: RepeatPressTrigger(pressCount: 5, pressWindowMs: 1500),
    ),
  ],
);

SessionMode _dateMode() => const SessionMode(
  id: SeedModeIds.date,
  name: 'Date Mode',
  // Issues-v4 #12 — seed an iconName so the Date tile matches its
  // mode-editor selection on Home + Modes list.
  iconName: 'favorite',
  checkInType: ChainStepType.disguisedReminder,
  chainSteps: [
    ChainStep(
      id: 'seed.mode.date.step.reminder',
      type: ChainStepType.disguisedReminder,
      order: 0,
      durationSeconds: 30,
      gracePeriodSeconds: 60,
      config: DisguisedReminderConfig(intervalSeconds: 600),
    ),
    ChainStep(
      id: 'seed.mode.date.step.fakecall',
      type: ChainStepType.fakeCall,
      order: 1,
      durationSeconds: 30,
      gracePeriodSeconds: 20,
    ),
    ChainStep(
      id: 'seed.mode.date.step.sms',
      type: ChainStepType.smsContact,
      order: 2,
      durationSeconds: 10,
      gracePeriodSeconds: 0,
    ),
  ],
  distressTriggers: [
    HardwareButtonDistressTrigger(
      buttonType: ButtonType.volumeUp,
      trigger: RepeatPressTrigger(pressCount: 5, pressWindowMs: 1500),
    ),
  ],
);

// ---------------------------------------------------------------------
// Built-in reminder templates
// ---------------------------------------------------------------------

List<ReminderTemplate> _builtInTemplates() => const [
  ReminderTemplate(
    id: 'seed.template.calendar',
    name: 'Calendar Event',
    title: 'Upcoming event',
    body: 'You have an event starting soon. Tap to confirm.',
    confirmationType: ConfirmationType.tapButton,
    displayStyle: ReminderDisplayStyle.fullScreen,
    isGlobal: true,
    buttonLabel: 'Got it',
  ),
  ReminderTemplate(
    id: 'seed.template.duolingo',
    name: 'Duolingo Streak',
    title: 'Don\u2019t lose your streak!',
    body: 'Tap to complete today\u2019s lesson.',
    confirmationType: ConfirmationType.tapButton,
    displayStyle: ReminderDisplayStyle.fullScreen,
    isGlobal: true,
    buttonLabel: 'Continue',
  ),
  ReminderTemplate(
    id: 'seed.template.delivery',
    name: 'Delivery Update',
    title: 'Your package is nearby',
    body: 'Tap to confirm you can receive it.',
    confirmationType: ConfirmationType.tapButton,
    displayStyle: ReminderDisplayStyle.fullScreen,
    isGlobal: true,
    buttonLabel: 'Track',
  ),
  ReminderTemplate(
    id: 'seed.template.weather',
    name: 'Weather Alert',
    title: 'Weather update',
    body: 'Conditions are changing. Tap to view the forecast.',
    confirmationType: ConfirmationType.tapButton,
    displayStyle: ReminderDisplayStyle.fullScreen,
    isGlobal: true,
    buttonLabel: 'View',
  ),
  ReminderTemplate(
    id: 'seed.template.news',
    name: 'News Brief',
    title: 'Top story',
    body: 'A new story is waiting for you. Tap to read.',
    confirmationType: ConfirmationType.tapButton,
    displayStyle: ReminderDisplayStyle.fullScreen,
    isGlobal: true,
    buttonLabel: 'Read',
  ),
  ReminderTemplate(
    id: 'seed.template.calendar_reminder',
    name: 'Calendar Reminder',
    title: 'Reminder',
    body: 'Quick tap to acknowledge your reminder.',
    confirmationType: ConfirmationType.tapButton,
    displayStyle: ReminderDisplayStyle.fullScreen,
    isGlobal: true,
    buttonLabel: 'OK',
  ),
  ReminderTemplate(
    id: 'seed.template.workout',
    name: 'Workout Check-In',
    title: 'Workout time',
    body: 'Tap to begin your scheduled workout.',
    confirmationType: ConfirmationType.tapButton,
    displayStyle: ReminderDisplayStyle.fullScreen,
    isGlobal: true,
    buttonLabel: 'Start',
  ),
  ReminderTemplate(
    id: 'seed.template.quiz',
    name: 'Quiz Challenge',
    title: 'Ready for a challenge?',
    body: 'Tap the matching word to continue.',
    confirmationType: ConfirmationType.tapWord,
    displayStyle: ReminderDisplayStyle.fullScreen,
    isGlobal: true,
    keyword: 'continue',
  ),
];
