import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/features/about/about_screen.dart';
import 'package:guardianangela/features/backup_restore/backup_restore_screen.dart';
import 'package:guardianangela/features/battery_alert/battery_alert_screen.dart';
import 'package:guardianangela/features/contact_form/contact_form_screen.dart';
import 'package:guardianangela/features/contacts/contacts_screen.dart';
import 'package:guardianangela/features/distress_modes/distress_modes_screen.dart';
import 'package:guardianangela/features/event_defaults/event_defaults_screen.dart';
import 'package:guardianangela/features/fake_call/fake_call_screen.dart';
import 'package:guardianangela/features/feedback_form/feedback_form_screen.dart';
import 'package:guardianangela/features/gps_logging/gps_logging_screen.dart';
import 'package:guardianangela/features/history_retention/history_retention_screen.dart';
import 'package:guardianangela/features/home/home_screen.dart';
import 'package:guardianangela/features/launch_gate/launch_gate_controller.dart';
import 'package:guardianangela/features/launch_gate/launch_pin_screen.dart';
import 'package:guardianangela/features/mode_editor/mode_editor_screen.dart';
import 'package:guardianangela/features/modes/modes_screen.dart';
import 'package:guardianangela/features/notifications_settings/notifications_settings_screen.dart';
import 'package:guardianangela/features/onboarding/onboarding_screen.dart';
import 'package:guardianangela/features/past_events/past_events_screen.dart';
import 'package:guardianangela/features/past_events_detail/past_events_detail_screen.dart';
import 'package:guardianangela/features/past_events_trash/past_events_trash_screen.dart';
import 'package:guardianangela/features/pin_setup/pin_setup_screen.dart';
import 'package:guardianangela/features/profile/profile_screen.dart';
import 'package:guardianangela/features/reminder_templates/reminder_templates_screen.dart';
import 'package:guardianangela/features/session/session_screen.dart';
import 'package:guardianangela/features/session_completed/session_completed_screen.dart';
import 'package:guardianangela/features/settings/settings_screen.dart';
import 'package:guardianangela/features/settings_security/settings_security_screen.dart';
import 'package:guardianangela/features/settings_stealth/settings_stealth_screen.dart';
import 'package:guardianangela/features/simulation_summary/simulation_summary_screen.dart';
import 'package:guardianangela/features/template_editor/template_editor_screen.dart';
import 'package:guardianangela/services/service_providers.dart';

/// Refresh listenable for redirect re-evaluation.
///
/// GoRouter re-evaluates redirects whenever this notifies. Two triggers:
/// (a) the first-launch flag flips (onboarding finished / restarted), and
/// (b) the App-lock launch gate locks or unlocks — so [LaunchGateController]
/// `unlock()` immediately routes away from the launch screen.
class _RouterRefreshListenable extends ChangeNotifier {
  _RouterRefreshListenable(this._ref) {
    _ref.listen<AsyncValue<bool>>(
      _firstLaunchProvider,
      (_, _) => notifyListeners(),
    );
    _ref.listen<bool>(launchGateProvider, (_, _) => notifyListeners());
  }

  final Ref _ref;
}

/// Async provider that returns whether this is the first app launch.
///
/// Backed by `AppSettings.isFirstLaunch`. Phase 6 marks the flag false at
/// the end of onboarding via `OnboardingController.completeOnboarding`.
final _firstLaunchProvider = FutureProvider<bool>((ref) async {
  final settings = await ref.read(appSettingsRepositoryProvider).load();
  return settings.isFirstLaunch;
});

/// Provides the GoRouter instance.
///
/// First-launch detection redirects `/` → `/onboarding` until the user
/// completes onboarding. Deep links honour `?id=...` query parameters
/// on every detail route per spec 04 §Navigation & Deep Linking.
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: _RouterRefreshListenable(ref),
    redirect: (BuildContext context, GoRouterState state) {
      final firstLaunch = ref.read(_firstLaunchProvider).value;
      if (firstLaunch == true && state.matchedLocation != '/onboarding') {
        return '/onboarding';
      }
      // App-lock launch gate (spec 06 §App PIN). Seeded synchronously at
      // bootstrap from `appPinHash != null`, so the first evaluation already
      // knows whether to gate — no flash of app content before the lock.
      // Onboarding wins (a PIN can only be set after onboarding, so the two
      // never both apply, but the order keeps that invariant explicit).
      final locked = ref.read(launchGateProvider);
      if (locked && state.matchedLocation != '/launch-pin') {
        return '/launch-pin';
      }
      if (!locked && state.matchedLocation == '/launch-pin') {
        return '/';
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: RouteNames.home,
        builder: (_, _) => const HomeScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: RouteNames.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/launch-pin',
        name: RouteNames.launchPin,
        builder: (_, _) => const LaunchPinScreen(),
      ),
      GoRoute(
        path: '/session',
        name: RouteNames.session,
        builder: (_, GoRouterState state) {
          final quickExit = state.uri.queryParameters['quickExit'] == 'true';
          return SessionScreen(quickExit: quickExit);
        },
      ),
      GoRoute(
        path: '/fake-call',
        name: RouteNames.fakeCall,
        builder: (_, GoRouterState state) {
          final extra = state.extra;
          final config = extra is FakeCallConfig
              ? extra
              : const FakeCallConfig();
          return FakeCallScreen(config: config);
        },
      ),
      GoRoute(
        path: '/session/completed',
        name: RouteNames.sessionCompleted,
        builder: (_, GoRouterState state) {
          final duration = int.tryParse(
            state.uri.queryParameters['duration'] ?? '',
          );
          final isSimulation =
              state.uri.queryParameters['simulation'] == 'true';
          return SessionCompletedScreen(
            durationSeconds: duration,
            logId: state.uri.queryParameters['id'],
            isSimulation: isSimulation,
          );
        },
      ),
      GoRoute(
        path: '/session/simulation-summary',
        name: RouteNames.sessionSimulationSummary,
        builder: (_, GoRouterState state) {
          final id = state.uri.queryParameters['id'];
          return SimulationSummaryScreen(logId: id);
        },
      ),
      GoRoute(
        path: '/contacts',
        name: RouteNames.contacts,
        builder: (_, _) => const ContactsScreen(),
      ),
      GoRoute(
        path: '/contacts/edit',
        name: RouteNames.contactForm,
        builder: (_, GoRouterState state) {
          return ContactFormScreen(
            contactId: state.uri.queryParameters['id'],
            initialName: state.uri.queryParameters['name'],
            initialPhone: state.uri.queryParameters['phone'],
          );
        },
      ),
      GoRoute(
        path: '/modes',
        name: RouteNames.modes,
        builder: (_, _) => const ModesScreen(),
      ),
      GoRoute(
        path: '/modes/edit',
        name: RouteNames.modeEditor,
        builder: (_, GoRouterState state) {
          return ModeEditorScreen(
            modeId: state.uri.queryParameters['id'],
            isDistress: false,
          );
        },
      ),
      GoRoute(
        path: '/distress-modes',
        name: RouteNames.distressModes,
        builder: (_, _) => const DistressModesScreen(),
      ),
      GoRoute(
        path: '/distress-modes/edit',
        name: RouteNames.distressModeEditor,
        builder: (_, GoRouterState state) {
          return ModeEditorScreen(
            modeId: state.uri.queryParameters['id'],
            isDistress: true,
          );
        },
      ),
      GoRoute(
        path: '/settings',
        name: RouteNames.settings,
        builder: (_, _) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/security',
        name: RouteNames.settingsSecurity,
        builder: (_, _) => const SettingsSecurityScreen(),
      ),
      GoRoute(
        path: '/settings/stealth',
        name: RouteNames.settingsStealth,
        builder: (_, _) => const SettingsStealthScreen(),
      ),
      GoRoute(
        path: '/settings/pin-setup',
        name: RouteNames.pinSetup,
        builder: (_, GoRouterState state) {
          return PinSetupScreen(
            pinType: state.uri.queryParameters['type'] ?? 'app',
          );
        },
      ),
      GoRoute(
        path: '/settings/event-defaults',
        name: RouteNames.settingsEventDefaults,
        builder: (_, _) => const EventDefaultsScreen(),
      ),
      GoRoute(
        path: '/settings/gps-logging',
        name: RouteNames.settingsGpsLogging,
        builder: (_, _) => const GpsLoggingScreen(),
      ),
      GoRoute(
        path: '/settings/reminder-templates',
        name: RouteNames.settingsReminderTemplates,
        builder: (_, _) => const ReminderTemplatesScreen(),
      ),
      GoRoute(
        path: '/settings/templates/edit',
        name: RouteNames.templateEditor,
        builder: (_, GoRouterState state) {
          return TemplateEditorScreen(
            templateId: state.uri.queryParameters['id'],
          );
        },
      ),
      GoRoute(
        path: '/settings/notifications',
        name: RouteNames.settingsNotifications,
        builder: (_, _) => const NotificationsSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/history-retention',
        name: RouteNames.settingsHistoryRetention,
        builder: (_, _) => const HistoryRetentionScreen(),
      ),
      GoRoute(
        path: '/settings/battery-alert',
        name: RouteNames.settingsBatteryAlert,
        builder: (_, _) => const BatteryAlertScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: RouteNames.profile,
        builder: (_, _) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings/about',
        name: RouteNames.settingsAbout,
        builder: (_, _) => const AboutScreen(),
      ),
      GoRoute(
        path: '/settings/feedback',
        name: RouteNames.settingsFeedback,
        builder: (_, _) => const FeedbackFormScreen(),
      ),
      GoRoute(
        path: '/settings/backup',
        name: RouteNames.settingsBackup,
        builder: (_, _) => const BackupRestoreScreen(),
      ),
      GoRoute(
        path: '/past-events',
        name: RouteNames.pastEvents,
        builder: (_, _) => const PastEventsScreen(),
      ),
      GoRoute(
        path: '/past-events/trash',
        name: RouteNames.pastEventsTrash,
        builder: (_, _) => const PastEventsTrashScreen(),
      ),
      GoRoute(
        path: '/past-events/detail',
        name: RouteNames.pastEventDetail,
        builder: (_, GoRouterState state) {
          final id = state.uri.queryParameters['id'];
          return PastEventsDetailScreen(logId: id ?? '');
        },
      ),
      GoRoute(
        path: '/past-events/evidence',
        name: RouteNames.pastEventEvidence,
        builder: (_, GoRouterState state) {
          final id = state.uri.queryParameters['id'];
          return PastEventsDetailScreen(logId: id ?? '', evidenceMode: true);
        },
      ),
    ],
  );
});
