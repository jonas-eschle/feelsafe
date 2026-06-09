import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/enums/sms_contact_selection.dart';
import 'package:guardianangela/domain/models/app_defaults.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/user_profile.dart';

/// Built-in seed data installed on first launch and after every
/// nuke-and-reseed migration.
///
/// See spec 03 §Seed Data. Stable string ids (e.g. `'walk_mode_seed'`)
/// are used for the seeded modes and templates so tests can find them
/// without depending on a UUID.
final class SeedData {
  const SeedData._();

  // ─── Stable seed ids ────────────────────────────────────────────────

  /// Stable id of the seeded Walk Mode.
  static const String walkModeId = 'walk_mode_seed';

  /// Stable id of the seeded Date Mode.
  static const String dateModeId = 'date_mode_seed';

  /// Stable id of the seeded default distress mode.
  static const String defaultDistressModeId = 'default_distress_seed';

  /// Stable id prefix for built-in reminder templates.
  static const String reminderTemplatePrefix = 'reminder_template_seed_';

  /// Stable id prefix for chain steps inside built-in modes.
  static const String _stepIdPrefix = 'step_seed_';

  // ─── Public seed entry points ───────────────────────────────────────

  /// Populates [db] with the full seed (modes, templates, settings,
  /// profile).
  ///
  /// Called from [GuardianAngelaDatabase] migration callbacks on
  /// `onCreate` and after every nuke-and-reseed `onUpgrade`. The JSON
  /// singletons (app settings, user profile) are not touched here — the
  /// Phase 5 startup flow seeds them via their respective repositories
  /// using the helpers below.
  static Future<void> seedInto(GuardianAngelaDatabase db) async {
    await db.transaction(() async {
      // 1. Seed distress mode FIRST so its id is stable and referenced by
      //    AppDefaults / AppSettings later.
      await db.sessionModesDao.upsert(defaultDistressMode());
      // 2. Seed regular modes.
      await db.sessionModesDao.upsert(walkMode());
      await db.sessionModesDao.upsert(dateMode());
      // 3. Seed reminder templates.
      for (final template in reminderTemplates()) {
        await db.reminderTemplatesDao.upsert(template);
      }
    });
  }

  // ─── Seed factory: Walk Mode ────────────────────────────────────────

  /// Built-in Walk Mode (`holdButton → fakeCall → smsContact →
  /// phoneCallContact → callEmergency`).
  ///
  /// See spec 03 §Walk Mode for the canonical timing values.
  static SessionMode walkMode() => SessionMode(
    id: walkModeId,
    name: 'Walk Mode',
    iconName: 'directions_walk',
    isBuiltIn: true,
    chainSteps: [
      ChainStep(
        id: '${_stepIdPrefix}walk_0_hold',
        type: ChainStepType.holdButton,
        order: 0,
        waitSeconds: 0,
        durationSeconds: 10,
        gracePeriodSeconds: 1,
        retryCount: 0,
        randomize: false,
        config: const HoldButtonConfig(),
      ),
      ChainStep(
        id: '${_stepIdPrefix}walk_1_fakecall',
        type: ChainStepType.fakeCall,
        order: 1,
        waitSeconds: 0,
        durationSeconds: 30,
        gracePeriodSeconds: 5,
        retryCount: 0,
        randomize: false,
      ),
      ChainStep(
        id: '${_stepIdPrefix}walk_2_sms',
        type: ChainStepType.smsContact,
        order: 2,
        waitSeconds: 0,
        durationSeconds: 15,
        gracePeriodSeconds: 5,
        retryCount: 0,
        randomize: false,
      ),
      ChainStep(
        id: '${_stepIdPrefix}walk_3_phone',
        type: ChainStepType.phoneCallContact,
        order: 3,
        waitSeconds: 0,
        durationSeconds: 60,
        gracePeriodSeconds: 5,
        retryCount: 0,
        randomize: false,
      ),
      ChainStep(
        id: '${_stepIdPrefix}walk_4_emergency',
        type: ChainStepType.callEmergency,
        order: 4,
        waitSeconds: 0,
        durationSeconds: 5,
        gracePeriodSeconds: 0,
        retryCount: 0,
        randomize: false,
      ),
    ],
  );

  // ─── Seed factory: Date Mode ────────────────────────────────────────

  /// Built-in Date Mode (`disguisedReminder → fakeCall → smsContact →
  /// phoneCallContact → callEmergency`).
  ///
  /// See spec 03 §Date Mode for the canonical timing values.
  static SessionMode dateMode() => SessionMode(
    id: dateModeId,
    name: 'Date Mode',
    iconName: 'restaurant',
    isBuiltIn: true,
    chainSteps: [
      ChainStep(
        id: '${_stepIdPrefix}date_0_reminder',
        type: ChainStepType.disguisedReminder,
        order: 0,
        waitSeconds: 1800,
        durationSeconds: 60,
        gracePeriodSeconds: 120,
        retryCount: 1,
        randomize: false,
        config: const DisguisedReminderConfig(),
      ),
      ChainStep(
        id: '${_stepIdPrefix}date_1_fakecall',
        type: ChainStepType.fakeCall,
        order: 1,
        waitSeconds: 0,
        durationSeconds: 30,
        gracePeriodSeconds: 5,
        retryCount: 0,
        randomize: false,
      ),
      ChainStep(
        id: '${_stepIdPrefix}date_2_sms',
        type: ChainStepType.smsContact,
        order: 2,
        waitSeconds: 0,
        durationSeconds: 15,
        gracePeriodSeconds: 5,
        retryCount: 0,
        randomize: false,
      ),
      ChainStep(
        id: '${_stepIdPrefix}date_3_phone',
        type: ChainStepType.phoneCallContact,
        order: 3,
        waitSeconds: 0,
        durationSeconds: 60,
        gracePeriodSeconds: 5,
        retryCount: 0,
        randomize: false,
      ),
      ChainStep(
        id: '${_stepIdPrefix}date_4_emergency',
        type: ChainStepType.callEmergency,
        order: 4,
        waitSeconds: 0,
        durationSeconds: 10,
        gracePeriodSeconds: 0,
        retryCount: 0,
        randomize: false,
        config: const CallEmergencyConfig(),
      ),
    ],
  );

  // ─── Seed factory: default distress mode ────────────────────────────

  /// Built-in default distress mode (`smsContact[firstContact] →
  /// callEmergency`).
  ///
  /// See spec 03 §Default Distress Mode for the canonical timing values.
  /// `contactSelection = firstContact` (ITEM 6) targets only the
  /// uppermost emergency contact, and the second step waits 10 seconds
  /// before tying up the radio.
  static SessionMode defaultDistressMode() => SessionMode(
    id: defaultDistressModeId,
    name: 'Default Distress',
    iconName: 'warning',
    isBuiltIn: true,
    chainSteps: [
      ChainStep(
        id: '${_stepIdPrefix}distress_0_sms',
        type: ChainStepType.smsContact,
        order: 0,
        waitSeconds: 0,
        durationSeconds: 15,
        gracePeriodSeconds: 0,
        retryCount: 0,
        randomize: false,
        config: const SmsContactConfig(
          contactSelection: SmsContactSelection.firstContact,
        ),
      ),
      ChainStep(
        id: '${_stepIdPrefix}distress_1_emergency',
        type: ChainStepType.callEmergency,
        order: 1,
        waitSeconds: 10,
        durationSeconds: 5,
        gracePeriodSeconds: 0,
        retryCount: 0,
        randomize: false,
        config: const CallEmergencyConfig(showConfirmation: false),
      ),
    ],
    isDistressMode: true,
  );

  // ─── Seed factory: reminder templates ───────────────────────────────

  /// Eight built-in reminder templates per spec 03 §Eight Built-in
  /// Reminder Templates.
  static List<ReminderTemplate> reminderTemplates() => [
    ReminderTemplate(
      id: '${reminderTemplatePrefix}calendar_event',
      name: 'Calendar Event',
      title: 'You have an appointment',
      body: 'Meeting with Alex at 3 PM',
      confirmationType: ConfirmationType.tapButton,
      buttonLabel: 'Acknowledge',
      isCustom: false,
      displayStyle: ReminderDisplayStyle.fullScreen,
      isGlobal: true,
    ),
    ReminderTemplate(
      id: '${reminderTemplatePrefix}duolingo_lesson',
      name: 'Duolingo Lesson',
      title: 'Time for your lesson!',
      body: 'Keep your 50-day streak going',
      confirmationType: ConfirmationType.tapWord,
      keyword: 'STREAK',
      isCustom: false,
      displayStyle: ReminderDisplayStyle.subtle,
      isGlobal: true,
    ),
    ReminderTemplate(
      id: '${reminderTemplatePrefix}delivery_update',
      name: 'Delivery Update',
      title: 'Your package arrived',
      body: 'Check the front porch',
      confirmationType: ConfirmationType.tapButton,
      buttonLabel: 'View',
      isCustom: false,
      displayStyle: ReminderDisplayStyle.fullScreen,
      isGlobal: true,
    ),
    ReminderTemplate(
      id: '${reminderTemplatePrefix}weather_alert',
      name: 'Weather Alert',
      title: 'Rainy tomorrow',
      body: 'Bring an umbrella',
      confirmationType: ConfirmationType.dismiss,
      isCustom: false,
      displayStyle: ReminderDisplayStyle.subtle,
      isGlobal: true,
    ),
    ReminderTemplate(
      id: '${reminderTemplatePrefix}fitness_reminder',
      name: 'Fitness Reminder',
      title: 'Time to exercise',
      body: 'Your workout is due',
      confirmationType: ConfirmationType.tapButton,
      buttonLabel: 'Start',
      isCustom: false,
      displayStyle: ReminderDisplayStyle.subtle,
      isGlobal: true,
    ),
    ReminderTemplate(
      id: '${reminderTemplatePrefix}message_preview',
      name: 'Message Preview',
      title: 'New message from Sarah',
      body: '"Hey, what\'s up?"',
      confirmationType: ConfirmationType.dismiss,
      isCustom: false,
      displayStyle: ReminderDisplayStyle.subtle,
      isGlobal: true,
    ),
    ReminderTemplate(
      id: '${reminderTemplatePrefix}app_update',
      name: 'App Update',
      title: 'Updates available',
      body: 'Tap to install',
      confirmationType: ConfirmationType.tapButton,
      buttonLabel: 'Install',
      isCustom: false,
      displayStyle: ReminderDisplayStyle.fullScreen,
      isGlobal: true,
    ),
    ReminderTemplate(
      id: '${reminderTemplatePrefix}battery_warning',
      name: 'Battery Warning',
      title: 'Battery low',
      body: 'Plug in soon',
      confirmationType: ConfirmationType.dismiss,
      isCustom: false,
      displayStyle: ReminderDisplayStyle.subtle,
      isGlobal: true,
    ),
  ];

  // ─── Seed factory: JSON singletons ──────────────────────────────────

  /// Default app settings with the seeded distress-mode id pre-wired
  /// into [AppDefaults.defaultDistressModeId].
  ///
  /// [seedDistressModeId] defaults to [defaultDistressModeId] (the
  /// canonical id used by [seedInto]); tests pass an override only when
  /// they need to point at a custom-id distress mode.
  ///
  /// [emergencyCallNumber] defaults to `'112'` (the GSM international
  /// fallback, matching the [AppSettings] model default). First-launch
  /// bootstrap passes a locale-derived seed here (spec 06 §Emergency Number,
  /// precedence tier 2).
  static AppSettings defaultAppSettings({
    String seedDistressModeId = defaultDistressModeId,
    String emergencyCallNumber = '112',
  }) {
    final templates = reminderTemplates();
    return AppSettings(
      emergencyCallNumber: emergencyCallNumber,
      defaults: AppDefaults(
        templates: templates,
        defaultDistressModeId: seedDistressModeId,
      ),
    );
  }

  /// Default empty [UserProfile].
  static UserProfile defaultUserProfile() => const UserProfile();
}
