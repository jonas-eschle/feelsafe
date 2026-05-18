/// Top-level `GoRouter` wiring every named route to its screen.
///
/// Keeping every route in a single file makes path surgery cheap.
/// Path strings live in `RouteNames` so renames stay trivial.
///
/// Fix for bugs.json Warn (first-launch redirect): when the settings
/// controller reports `isFirstLaunch == true` and the target is not
/// onboarding, the redirect sends the user to the onboarding flow.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';
import 'package:guardianangela/features/about/about_screen.dart';
import 'package:guardianangela/features/about/feedback_screen.dart';
import 'package:guardianangela/features/contacts/contact_form_screen.dart';
import 'package:guardianangela/features/contacts/contacts_screen.dart';
import 'package:guardianangela/features/distress_modes/distress_modes_screen.dart';
import 'package:guardianangela/features/fake_call/fake_call_screen.dart';
import 'package:guardianangela/features/history/evidence_export_screen.dart';
import 'package:guardianangela/features/history/past_event_detail_screen.dart';
import 'package:guardianangela/features/history/past_events_screen.dart';
import 'package:guardianangela/features/home/home_screen.dart';
import 'package:guardianangela/features/modes/mode_editor_screen.dart';
import 'package:guardianangela/features/modes/modes_screen.dart';
import 'package:guardianangela/features/onboarding/onboarding_screen.dart';
import 'package:guardianangela/features/preview/step_preview_screen.dart';
import 'package:guardianangela/features/profile/profile_screen.dart';
import 'package:guardianangela/features/session/session_completed_screen.dart';
import 'package:guardianangela/features/session/session_screen.dart';
import 'package:guardianangela/features/session/simulation_summary_screen.dart';
import 'package:guardianangela/features/settings/backup_screen.dart';
import 'package:guardianangela/features/settings/battery_alert_screen.dart';
import 'package:guardianangela/features/settings/event_defaults_screen.dart';
import 'package:guardianangela/features/settings/gps_logging_screen.dart';
import 'package:guardianangela/features/settings/history_retention_screen.dart';
import 'package:guardianangela/features/settings/notification_settings_screen.dart';
import 'package:guardianangela/features/settings/pin_setup_screen.dart';
import 'package:guardianangela/features/settings/reminder_templates_screen.dart';
import 'package:guardianangela/features/settings/security_screen.dart';
import 'package:guardianangela/features/settings/settings_screen.dart';
import 'package:guardianangela/features/settings/stealth_screen.dart';
import 'package:guardianangela/features/templates/template_editor_screen.dart';
import 'package:guardianangela/features/templates/templates_screen.dart';

/// The app's global router instance.
///
/// Fix for bugs.json Warn (first-launch redirect): if
/// `isFirstLaunch == true` and the user is not already on the
/// onboarding route, redirect them. Reads the settings synchronously
/// via `ProviderScope.containerOf`; while the async hydrate is still
/// pending, the redirect defers (returns null) so the user lands on
/// home briefly, and the next frame re-evaluates.
final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.home,
  redirect: (context, state) {
    final container = ProviderScope.containerOf(context, listen: false);
    final async = container.read(settingsControllerProvider);
    final settings = async.value;
    if (settings == null) return null;
    if (settings.isFirstLaunch &&
        state.matchedLocation != RouteNames.onboarding) {
      return RouteNames.onboarding;
    }
    return null;
  },
  routes: <GoRoute>[
    GoRoute(
      name: 'home',
      path: RouteNames.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      name: 'onboarding',
      path: RouteNames.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      name: 'session',
      path: RouteNames.session,
      builder: (context, state) => const SessionScreen(),
    ),
    GoRoute(
      name: 'sessionCompleted',
      path: RouteNames.sessionCompleted,
      builder: (context, state) => const SessionCompletedScreen(),
    ),
    GoRoute(
      name: 'simulationSummary',
      path: RouteNames.simulationSummary,
      builder: (context, state) => const SimulationSummaryScreen(),
    ),
    GoRoute(
      name: 'fakeCall',
      path: RouteNames.fakeCall,
      builder: (context, state) => const FakeCallScreen(),
    ),
    GoRoute(
      name: 'contacts',
      path: RouteNames.contacts,
      builder: (context, state) => const ContactsScreen(),
    ),
    GoRoute(
      name: 'contactForm',
      path: RouteNames.contactForm,
      builder: (context, state) => const ContactFormScreen(),
    ),
    GoRoute(
      name: 'modes',
      path: RouteNames.modes,
      builder: (context, state) => const ModesScreen(),
    ),
    GoRoute(
      name: 'modeEditor',
      path: RouteNames.modeEditor,
      builder: (context, state) => const ModeEditorScreen(),
    ),
    GoRoute(
      name: 'stepPreview',
      path: RouteNames.stepPreview,
      builder: (context, state) => const StepPreviewScreen(),
    ),
    GoRoute(
      name: 'distressModes',
      path: RouteNames.distressModes,
      builder: (context, state) => const DistressModesScreen(),
    ),
    GoRoute(
      name: 'distressModeEditor',
      path: RouteNames.distressModeEditor,
      builder: (context, state) => const ModeEditorScreen(isDistress: true),
    ),
    GoRoute(
      name: 'templates',
      path: RouteNames.templates,
      builder: (context, state) => const TemplatesScreen(),
    ),
    GoRoute(
      name: 'templateEditor',
      path: RouteNames.templateEditor,
      builder: (context, state) => const TemplateEditorScreen(),
    ),
    GoRoute(
      name: 'profile',
      path: RouteNames.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      name: 'settings',
      path: RouteNames.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      name: 'settingsSecurity',
      path: RouteNames.settingsSecurity,
      builder: (context, state) => const SecurityScreen(),
    ),
    GoRoute(
      name: 'settingsStealth',
      path: RouteNames.settingsStealth,
      builder: (context, state) => const StealthScreen(),
    ),
    GoRoute(
      name: 'pinSetup',
      path: RouteNames.pinSetup,
      builder: (context, state) => const PinSetupScreen(),
    ),
    GoRoute(
      name: 'batteryAlert',
      path: RouteNames.batteryAlert,
      builder: (context, state) => const BatteryAlertScreen(),
    ),
    GoRoute(
      name: 'eventDefaults',
      path: RouteNames.eventDefaults,
      builder: (context, state) => const EventDefaultsScreen(),
    ),
    GoRoute(
      name: 'gpsLogging',
      path: RouteNames.gpsLogging,
      builder: (context, state) => const GpsLoggingScreen(),
    ),
    GoRoute(
      name: 'reminderTemplates',
      path: RouteNames.reminderTemplates,
      builder: (context, state) => const ReminderTemplatesScreen(),
    ),
    GoRoute(
      name: 'notificationSettings',
      path: RouteNames.notificationSettings,
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
    GoRoute(
      name: 'historyRetention',
      path: RouteNames.historyRetention,
      builder: (context, state) => const HistoryRetentionScreen(),
    ),
    GoRoute(
      name: 'backup',
      path: RouteNames.backup,
      builder: (context, state) => const BackupScreen(),
    ),
    GoRoute(
      name: 'pastEvents',
      path: RouteNames.pastEvents,
      builder: (context, state) => const PastEventsScreen(),
    ),
    GoRoute(
      name: 'pastEventDetail',
      path: RouteNames.pastEventDetail,
      builder: (context, state) => const PastEventDetailScreen(),
    ),
    GoRoute(
      name: 'evidenceExport',
      path: RouteNames.evidenceExport,
      builder: (context, state) => const EvidenceExportScreen(),
    ),
    GoRoute(
      name: 'about',
      path: RouteNames.about,
      builder: (context, state) => const AboutScreen(),
    ),
    GoRoute(
      name: 'feedback',
      path: RouteNames.feedback,
      builder: (context, state) => const FeedbackScreen(),
    ),
  ],
);
