/// Canonical route paths used throughout the app.
///
/// All `GoRoute` definitions and navigation callers pull path
/// strings from this single source of truth so renames stay cheap
/// and typos surface as compile-time errors.
library;

/// Namespace for every named route path. Not instantiable —
/// reference members directly as `RouteNames.home`.
abstract class RouteNames {
  // ------------------------------- core
  /// Root route; the home screen.
  static const String home = '/';

  /// First-launch onboarding flow.
  static const String onboarding = '/onboarding';

  // ------------------------------- session lifecycle
  /// Active safety session screen.
  static const String session = '/session';

  /// Success screen shown after a session ends normally.
  static const String sessionCompleted = '/session/completed';

  /// Post-session summary for simulation runs only.
  static const String simulationSummary = '/session/simulation-summary';

  // ------------------------------- fake call
  /// Simulated incoming call used as a safety pretext.
  static const String fakeCall = '/fake-call';

  // ------------------------------- contacts
  /// Emergency contacts list.
  static const String contacts = '/contacts';

  /// Contact create / edit form.
  static const String contactForm = '/contacts/edit';

  // ------------------------------- modes
  /// Session modes list.
  static const String modes = '/modes';

  /// Session mode create / edit form.
  static const String modeEditor = '/modes/edit';

  /// Per-step preview screen (issues-v4 #10/#13/#14).
  ///
  /// Hydrates from `?stepId=...&modeId=...` query parameters and
  /// dispatches to a step-type-specific preview body that shows the
  /// real UI (e.g. hold-button, fake-call) in simulation mode so the
  /// user can try a single step without running the full session.
  static const String stepPreview = '/modes/step-preview';

  // ------------------------------- distress modes
  /// Global distress modes list.
  static const String distressModes = '/distress-modes';

  /// Distress mode create / edit form.
  static const String distressModeEditor = '/distress-modes/edit';

  // ------------------------------- templates
  /// Disguised reminder templates list.
  static const String templates = '/settings/templates';

  /// Template create / edit form (canonical /settings/-nested path
  /// per Q29; Phase 7b consolidation).
  static const String templateEditor = '/settings/templates/edit';

  // ------------------------------- profile
  /// User profile (identity + medical info).
  static const String profile = '/profile';

  // ------------------------------- settings tree
  /// Top-level settings hub.
  static const String settings = '/settings';

  /// Security submenu (the three PINs).
  static const String settingsSecurity = '/settings/security';

  /// Stealth appearance submenu.
  static const String settingsStealth = '/settings/stealth';

  /// PIN setup flow (create / change one PIN).
  static const String pinSetup = '/settings/pin-setup';

  /// Battery-alert one-shot config.
  static const String batteryAlert = '/settings/battery-alert';

  /// Per-step-type escalation defaults.
  static const String eventDefaults = '/settings/event-defaults';

  /// GPS logging defaults.
  static const String gpsLogging = '/settings/gps-logging';

  /// Global reminder-template management.
  static const String reminderTemplates = '/settings/reminder-templates';

  /// System notifications config.
  static const String notificationSettings = '/settings/notifications';

  /// Session-history retention policy.
  static const String historyRetention = '/settings/history-retention';

  /// Import / export backup tool.
  static const String backup = '/settings/backup';

  // ------------------------------- history
  /// Past sessions list.
  static const String pastEvents = '/past-events';

  /// Single past-session detail.
  static const String pastEventDetail = '/past-events/detail';

  /// Evidence export (share full session log).
  static const String evidenceExport = '/past-events/evidence';

  // ------------------------------- misc (nested under /settings/
  // per Q28 — these are reached only from the Settings hub.)
  /// About / credits screen.
  static const String about = '/settings/about';

  /// User-feedback form.
  static const String feedback = '/settings/feedback';
}
