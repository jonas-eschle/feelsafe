/// Tests for the REAL [goRouterProvider] — the production route table,
/// per-route query-parameter parsing, and the two redirect guards
/// (first-launch → onboarding; App-lock launch gate).
///
/// Unlike the per-screen widget tests (which mount each screen in a
/// minimal stub router), these pump `MaterialApp.router` with the actual
/// router instance from `lib/router/app_router.dart`, so every `builder:`
/// closure, every `?id=...` parse, and the redirect ladder run for real.
/// Service overrides reuse the INT harness recording fakes so no screen
/// touches platform channels on mount.
///
/// Spec ref: `docs/spec/04-screens-navigation.md §Navigation & Deep
/// Linking` (route table, deep-link query parameters) and
/// `docs/spec/06-settings.md §App PIN` (launch gate redirect).
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/features/about/about_screen.dart';
import 'package:guardianangela/features/backup_restore/backup_restore_screen.dart';
import 'package:guardianangela/features/contact_form/contact_form_screen.dart';
import 'package:guardianangela/features/contacts/contacts_screen.dart';
import 'package:guardianangela/features/disguised_reminder/disguised_reminder_screen.dart';
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
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/router/app_router.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/sim/background_session_service_sim.dart';
import 'package:guardianangela/services/sim/biometric_service_sim.dart';
import 'package:guardianangela/services/sim/call_state_service_sim.dart';
import 'package:guardianangela/services/sim/home_widget_service_sim.dart';
import 'package:guardianangela/services/sim/session_start_validator_sim.dart';
import 'package:guardianangela/services/sim/system_ui_service_sim.dart';
import '../integration/_session_harness.dart';

// ─── Fixtures ────────────────────────────────────────────────────────────────

ChainStep _step(String id) => ChainStep(
  id: id,
  type: ChainStepType.holdButton,
  order: 0,
  waitSeconds: 0,
  durationSeconds: 10,
  gracePeriodSeconds: 5,
  retryCount: 0,
  randomize: false,
);

SessionMode _mode(String id, String name, {bool isDistress = false}) =>
    SessionMode(
      id: id,
      name: name,
      isDistressMode: isDistress,
      chainSteps: <ChainStep>[_step('$id-s0')],
    );

// ─── Harness ─────────────────────────────────────────────────────────────────

/// Mirrors `buildIntegrationContainer`'s full service-fake set, plus the
/// biometric / start-validator sims some routed screens read lazily.
ProviderContainer _routerContainer({
  required GuardianAngelaDatabase db,
  required AppSettings settings,
}) {
  final fakes = RecordingFakes();
  final container = ProviderContainer(
    overrides: [
      appSettingsRepositoryProvider.overrideWithValue(
        FakeAppSettingsRepository(settings),
      ),
      userProfileRepositoryProvider.overrideWithValue(
        FakeUserProfileRepository(),
      ),
      databaseProvider.overrideWith((ref) async => db),
      audioServiceProvider.overrideWithValue(fakes.audio),
      vibrationServiceProvider.overrideWithValue(fakes.vibration),
      messagingServiceProvider.overrideWithValue(fakes.messaging),
      phoneServiceProvider.overrideWithValue(fakes.phone),
      locationServiceProvider.overrideWithValue(fakes.location),
      recordingServiceProvider.overrideWithValue(fakes.recording),
      flashServiceProvider.overrideWithValue(fakes.flash),
      screenFlashServiceProvider.overrideWithValue(fakes.screenFlash),
      notificationServiceProvider.overrideWithValue(fakes.notification),
      contactServiceProvider.overrideWith((_) async => fakes.contacts),
      systemUiServiceProvider.overrideWithValue(SimulationSystemUiService()),
      homeWidgetServiceProvider.overrideWithValue(
        SimulationHomeWidgetService(),
      ),
      callStateServiceProvider.overrideWithValue(SimulationCallStateService()),
      backgroundSessionServiceProvider.overrideWithValue(
        SimulationBackgroundSessionService(),
      ),
      biometricServiceProvider.overrideWithValue(SimulationBiometricService()),
      sessionStartValidatorProvider.overrideWithValue(
        SimulationSessionStartValidator(),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Pumps `MaterialApp.router` around the REAL router from
/// [goRouterProvider] and settles the initial route.
Future<GoRouter> _pumpApp(
  WidgetTester tester,
  ProviderContainer container,
) async {
  // Phone-shaped viewport: several routed screens are taller than the
  // 800×600 test default and would overflow mid-transition.
  tester.view.physicalSize = const Size(1080, 2280);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final router = container.read(goRouterProvider);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF131118)),
          useMaterial3: true,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

/// Navigates to [location] and settles the (800ms M3 fade-forwards) page
/// transition so exactly one route is mounted before assertions run.
Future<void> _goTo(
  WidgetTester tester,
  GoRouter router,
  String location, {
  Object? extra,
}) async {
  router.go(location, extra: extra);
  await tester.pumpAndSettle();
}

/// Returns the single mounted screen widget of type [T].
T _screen<T extends Widget>(WidgetTester tester) =>
    tester.widget<T>(find.byType(T));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    PackageInfo.setMockInitialValues(
      appName: 'Guardian Angela',
      packageName: 'com.guardianangela.app',
      version: '9.9.9',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  GuardianAngelaDatabase newDb() {
    final db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
    addTearDown(() => closeIntegrationDb(db));
    return db;
  }

  group('goRouterProvider — route table', () {
    testWidgets('every production route builds its screen and parses its '
        'query parameters (spec 04 §Navigation & Deep Linking)', (
      WidgetTester tester,
    ) async {
      final db = newDb();
      await db.sessionModesDao.upsert(_mode('m1', 'Walk'));
      await db.sessionModesDao.upsert(_mode('d1', 'Panic', isDistress: true));
      final container = _routerContainer(
        db: db,
        settings: const AppSettings().copyWith(isFirstLaunch: false),
      );
      final router = await _pumpApp(tester, container);

      // Initial location: home.
      expect(find.byType(HomeScreen), findsOneWidget);

      // Session — quickExit defaults false when the parameter is absent.
      await _goTo(tester, router, '/session');
      check(_screen<SessionScreen>(tester).quickExit).isFalse();

      // Fake call — a FakeCallConfig passed as `extra` is used verbatim.
      await _goTo(
        tester,
        router,
        '/fake-call',
        extra: const FakeCallConfig(callerName: 'Mum'),
      );
      check(_screen<FakeCallScreen>(tester).config.callerName).equals('Mum');

      await _goTo(tester, router, '/disguised-reminder');
      expect(find.byType(DisguisedReminderScreen), findsOneWidget);

      // Session completed — duration/simulation/feedback/id all parsed.
      await _goTo(
        tester,
        router,
        '/session/completed'
        '?duration=125&simulation=true&feedback=true&id=log1',
      );
      final completed = _screen<SessionCompletedScreen>(tester);
      check(completed.durationSeconds).equals(125);
      check(completed.isSimulation).isTrue();
      check(completed.showFeedbackPrompt).isTrue();
      check(completed.logId).equals('log1');

      await _goTo(tester, router, '/session/simulation-summary?id=sim1');
      check(_screen<SimulationSummaryScreen>(tester).logId).equals('sim1');

      await _goTo(tester, router, '/contacts');
      expect(find.byType(ContactsScreen), findsOneWidget);

      // Contact form — id/name/phone prefill parameters (device import).
      await _goTo(
        tester,
        router,
        '/contacts/edit?id=c9&name=Sam&phone=%2B15551234',
      );
      final form = _screen<ContactFormScreen>(tester);
      check(form.contactId).equals('c9');
      check(form.initialName).equals('Sam');
      check(form.initialPhone).equals('+15551234');

      await _goTo(tester, router, '/modes');
      expect(find.byType(ModesScreen), findsOneWidget);

      // Mode editor — regular vs distress variants share the screen.
      await _goTo(tester, router, '/modes/edit?id=m1');
      var editor = _screen<ModeEditorScreen>(tester);
      check(editor.modeId).equals('m1');
      check(editor.isDistress).isFalse();

      await _goTo(tester, router, '/distress-modes');
      expect(find.byType(DistressModesScreen), findsOneWidget);

      await _goTo(tester, router, '/distress-modes/edit?id=d1');
      editor = _screen<ModeEditorScreen>(tester);
      check(editor.modeId).equals('d1');
      check(editor.isDistress).isTrue();

      await _goTo(tester, router, '/settings');
      expect(find.byType(SettingsScreen), findsOneWidget);

      await _goTo(tester, router, '/settings/security');
      expect(find.byType(SettingsSecurityScreen), findsOneWidget);

      await _goTo(tester, router, '/settings/stealth');
      expect(find.byType(SettingsStealthScreen), findsOneWidget);

      // PIN setup — explicit type, and the 'app' default when absent.
      await _goTo(tester, router, '/settings/pin-setup?type=duress');
      check(_screen<PinSetupScreen>(tester).pinType).equals('duress');
      await _goTo(tester, router, '/settings/pin-setup');
      check(_screen<PinSetupScreen>(tester).pinType).equals('app');

      await _goTo(tester, router, '/settings/event-defaults');
      expect(find.byType(EventDefaultsScreen), findsOneWidget);

      await _goTo(tester, router, '/settings/gps-logging');
      expect(find.byType(GpsLoggingScreen), findsOneWidget);

      await _goTo(tester, router, '/settings/reminder-templates');
      expect(find.byType(ReminderTemplatesScreen), findsOneWidget);

      await _goTo(tester, router, '/settings/templates/edit?id=t1');
      check(_screen<TemplateEditorScreen>(tester).templateId).equals('t1');

      await _goTo(tester, router, '/settings/notifications');
      expect(find.byType(NotificationsSettingsScreen), findsOneWidget);

      await _goTo(tester, router, '/settings/history-retention');
      expect(find.byType(HistoryRetentionScreen), findsOneWidget);

      await _goTo(tester, router, '/profile');
      expect(find.byType(ProfileScreen), findsOneWidget);

      await _goTo(tester, router, '/settings/about');
      expect(find.byType(AboutScreen), findsOneWidget);

      await _goTo(tester, router, '/settings/feedback');
      expect(find.byType(FeedbackFormScreen), findsOneWidget);

      await _goTo(tester, router, '/settings/backup');
      expect(find.byType(BackupRestoreScreen), findsOneWidget);

      await _goTo(tester, router, '/past-events');
      expect(find.byType(PastEventsScreen), findsOneWidget);

      await _goTo(tester, router, '/past-events/trash');
      expect(find.byType(PastEventsTrashScreen), findsOneWidget);

      // Detail vs evidence mode share the screen; both parse ?id=.
      await _goTo(tester, router, '/past-events/detail?id=L1');
      var detail = _screen<PastEventsDetailScreen>(tester);
      check(detail.logId).equals('L1');
      check(detail.evidenceMode).isFalse();

      await _goTo(tester, router, '/past-events/evidence?id=L2');
      detail = _screen<PastEventsDetailScreen>(tester);
      check(detail.logId).equals('L2');
      check(detail.evidenceMode).isTrue();

      // And back home — the walk ends on a settled route.
      await _goTo(tester, router, '/');
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });

  group('goRouterProvider — redirects', () {
    testWidgets('first launch forces every location to /onboarding', (
      WidgetTester tester,
    ) async {
      final db = newDb();
      // Model default: isFirstLaunch == true.
      final container = _routerContainer(db: db, settings: const AppSettings());
      final router = await _pumpApp(tester, container);

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);

      // Deep links cannot escape onboarding while the flag is set.
      await _goTo(tester, router, '/settings');
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.byType(SettingsScreen), findsNothing);
    });

    testWidgets('locking the launch gate routes everything to /launch-pin and '
        'unlock() routes straight back out (spec 06 §App PIN)', (
      WidgetTester tester,
    ) async {
      final db = newDb();
      final container = _routerContainer(
        db: db,
        settings: const AppSettings().copyWith(isFirstLaunch: false),
      );
      final router = await _pumpApp(tester, container);
      expect(find.byType(HomeScreen), findsOneWidget);

      // Bootstrap seeds the gate when an App PIN is set.
      container
          .read(launchGateProvider.notifier)
          .lockForLaunch(appPinSet: true);
      await tester.pumpAndSettle();
      expect(find.byType(LaunchPinScreen), findsOneWidget);

      // Locked: no other location is reachable.
      await _goTo(tester, router, '/settings');
      await tester.pumpAndSettle();
      expect(find.byType(LaunchPinScreen), findsOneWidget);
      expect(find.byType(SettingsScreen), findsNothing);

      // Unlock re-routes away from the gate without an explicit go().
      container.read(launchGateProvider.notifier).unlock();
      await tester.pumpAndSettle();
      expect(find.byType(LaunchPinScreen), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
