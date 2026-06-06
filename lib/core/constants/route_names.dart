/// Frozen GoRouter `name:` constants.
///
/// Every named route used by `lib/router/app_router.dart` and consumed by
/// `context.goNamed(...)` / `context.pushNamed(...)` MUST be declared here.
/// Tests reference these constants by name; spec 04 §Appendix lists the
/// full route map.
library;

/// Names for every named GoRouter route in Guardian Angela.
///
/// Stable string constants — referenced by tests, deep links, and
/// in-app navigation. Keep alphabetical inside each section.
final class RouteNames {
  const RouteNames._();

  // ── Top-level ──────────────────────────────────────────────────────
  /// Home dashboard.
  static const String home = 'home';

  /// First-launch onboarding flow.
  static const String onboarding = 'onboarding';

  /// App-lock launch gate (App PIN / biometric) shown on cold start when an
  /// App PIN is configured. Spec 06 §App PIN.
  static const String launchPin = 'launch_pin';

  // ── Session ────────────────────────────────────────────────────────
  /// Active session screen.
  static const String session = 'session';

  /// Modal fake-call screen.
  static const String fakeCall = 'fake_call';

  /// Full-screen disguised-reminder screen (fullScreen display style).
  static const String disguisedReminder = 'disguised_reminder';

  /// Post-completion summary for real sessions.
  static const String sessionCompleted = 'session_completed';

  /// Post-completion summary for simulated sessions.
  static const String sessionSimulationSummary = 'session_simulation_summary';

  // ── Contacts ───────────────────────────────────────────────────────
  /// Emergency contacts list.
  static const String contacts = 'contacts';

  /// Contact create / edit form (`?id=` for edit).
  static const String contactForm = 'contact_form';

  // ── Modes ──────────────────────────────────────────────────────────
  /// Regular session modes list.
  static const String modes = 'modes';

  /// Mode editor (`?id=` for edit).
  static const String modeEditor = 'mode_editor';

  /// Distress modes list (filtered modes view).
  static const String distressModes = 'distress_modes';

  /// Distress mode editor — same screen as [modeEditor] with `isDistress`.
  static const String distressModeEditor = 'distress_mode_editor';

  // ── Settings ───────────────────────────────────────────────────────
  /// Settings hub.
  static const String settings = 'settings';

  /// Security submenu (App / Session-End / Duress PINs).
  static const String settingsSecurity = 'settings_security';

  /// Stealth submenu.
  static const String settingsStealth = 'settings_stealth';

  /// PIN setup flow (`?type=app|sessionEnd|duress`).
  static const String pinSetup = 'pin_setup';

  /// Per-step-type event defaults.
  static const String settingsEventDefaults = 'settings_event_defaults';

  /// GPS logging defaults.
  static const String settingsGpsLogging = 'settings_gps_logging';

  /// Reminder templates list.
  static const String settingsReminderTemplates = 'settings_reminder_templates';

  /// Template editor (`?id=` for edit).
  static const String templateEditor = 'template_editor';

  /// Notification permission re-ask screen.
  static const String settingsNotifications = 'settings_notifications';

  /// History & retention sliders.
  static const String settingsHistoryRetention = 'settings_history_retention';

  /// Battery alert configuration.
  static const String settingsBatteryAlert = 'settings_battery_alert';

  /// User profile editor.
  static const String profile = 'profile';

  /// About screen.
  static const String settingsAbout = 'settings_about';

  /// In-app feedback form.
  static const String settingsFeedback = 'settings_feedback';

  /// Backup & restore (export / import).
  static const String settingsBackup = 'settings_backup';

  // ── History ────────────────────────────────────────────────────────
  /// Past sessions (history) list.
  static const String pastEvents = 'past_events';

  /// Past sessions trash (soft-deleted logs).
  static const String pastEventsTrash = 'past_events_trash';

  /// Past session detail view (`?id=`).
  static const String pastEventDetail = 'past_event_detail';

  /// Past session evidence export (`?id=`).
  static const String pastEventEvidence = 'past_event_evidence';
}
