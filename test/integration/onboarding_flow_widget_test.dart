/// Widget scenario WID-001 — onboarding full flow, end-to-end against the
/// REAL [OnboardingController] (spec 07 §Coverage matrix "Onboarding full
/// flow"; spec 04 §Onboarding).
///
/// The pre-existing `test/features/onboarding/onboarding_screen_test.dart`
/// covers the *screen rendering* with a canned `_FakeOnboardingController`
/// (every page's widgets, navigation, the page indicator, a11y). This scenario
/// fills the genuine gap: it drives the **real** `OnboardingController` (not a
/// fake) through the entire welcome → profile → permissions → "Get started"
/// flow and proves the wired completion side-effects actually happen:
///   - the profile draft typed on the profile page is **persisted** to the
///     `UserProfileRepository` (name + phone);
///   - `AppSettings.isFirstLaunch` is **flipped to false** (so the app never
///     re-shows onboarding);
///   - navigation leaves the onboarding screen for home.
///
/// It uses in-memory recording repositories that round-trip `save → load`
/// (the harness's fixed-value fakes cannot prove a write), the established
/// permission-handler platform seam (so the real `requestAllPermissions`
/// `permission_handler` call is a deterministic no-op with no OS dialog), and a
/// real in-memory DB for the controller's contacts watch. Every assertion
/// would go red if the real completion wiring regressed.
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/data/repositories/user_profile_repository.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/user_profile.dart';
import 'package:guardianangela/features/onboarding/onboarding_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';
import '../helpers/widget_test_helpers.dart';

// ─── In-memory recording repositories (round-trip save → load) ───────────────

/// [AppSettingsRepository] backed by an in-memory value that `save()` updates
/// and `load()`/`loadOrNull()` return — so a test can assert what the real
/// `completeOnboarding` persisted.
final class _RecordingSettingsRepository extends AppSettingsRepository {
  _RecordingSettingsRepository(this._value)
    : super(
        keyProvider: () async => '00' * 33,
        resolveDir: () async => throw UnimplementedError('no disk in tests'),
      );

  AppSettings _value;
  int saveCount = 0;

  @override
  Future<AppSettings> load() async => _value;

  @override
  Future<AppSettings?> loadOrNull() async => _value;

  @override
  Future<void> save(AppSettings value) async {
    saveCount++;
    _value = value;
  }
}

/// [UserProfileRepository] backed by an in-memory value (round-trips save/load).
final class _RecordingProfileRepository extends UserProfileRepository {
  _RecordingProfileRepository(this._value)
    : super(keyProvider: () async => '00' * 32);

  UserProfile _value;
  int saveCount = 0;

  @override
  Future<UserProfile> load() async => _value;

  @override
  Future<void> save(UserProfile value) async {
    saveCount++;
    _value = value;
  }
}

// ─── Permission seam ─────────────────────────────────────────────────────────

final class _NoopPermissionPlatform extends PermissionHandlerPlatform
    with MockPlatformInterfaceMixin {
  int requestCalls = 0;

  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async =>
      PermissionStatus.granted;

  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
    List<Permission> permissions,
  ) async {
    requestCalls++;
    return {for (final p in permissions) p: PermissionStatus.granted};
  }

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> shouldShowRequestPermissionRationale(
    Permission permission,
  ) async => false;

  @override
  Future<ServiceStatus> checkServiceStatus(Permission permission) async =>
      ServiceStatus.enabled;
}

// ─── Harness ─────────────────────────────────────────────────────────────────

GoRouter _router(List<Override> overrides) => GoRouter(
  initialLocation: '/onboarding',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) =>
          const Scaffold(body: Center(child: Text('HOME-REACHED'))),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) =>
          ProviderScope(overrides: overrides, child: const OnboardingScreen()),
    ),
    GoRoute(
      path: '/contacts/new',
      name: 'contact_form',
      builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
    ),
  ],
);

Future<void> _pump(WidgetTester tester, List<Override> overrides) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(
        routerConfig: _router(overrides),
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
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GuardianAngelaDatabase db;
  late _RecordingSettingsRepository settingsRepo;
  late _RecordingProfileRepository profileRepo;
  late _NoopPermissionPlatform permPlatform;

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
    // isFirstLaunch starts TRUE (a genuine first launch — the model default);
    // completion must flip it to false. Asserted live below before/after.
    settingsRepo = _RecordingSettingsRepository(const AppSettings());
    profileRepo = _RecordingProfileRepository(const UserProfile());
    final original = PermissionHandlerPlatform.instance;
    permPlatform = _NoopPermissionPlatform();
    PermissionHandlerPlatform.instance = permPlatform;
    addTearDown(() => PermissionHandlerPlatform.instance = original);
  });

  tearDown(() async {
    await db.close();
  });

  List<Override> overrides() => <Override>[
    databaseProvider.overrideWith((ref) async => db),
    appSettingsRepositoryProvider.overrideWithValue(settingsRepo),
    userProfileRepositoryProvider.overrideWithValue(profileRepo),
    // onboardingControllerProvider is NOT overridden — the REAL controller
    // runs against the in-memory repos above.
  ];

  testWidgets(
    'WID-001 full flow: welcome → profile (enter name+phone) → permissions → '
    '"Get started" persists the profile, flips isFirstLaunch, routes home',
    (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, overrides());

      // Page 0 — Welcome. The first-launch flag is still TRUE here.
      check(settingsRepo._value.isFirstLaunch).isTrue();
      expect(find.text(l10n.onboardingWelcomeGreeting), findsOneWidget);
      await tester.tap(find.text(l10n.onboardingNext));
      await tester.pumpAndSettle();

      // Page 1 — Profile. Type a name + phone into the real text fields; the
      // real controller stores the draft.
      expect(find.text(l10n.onboardingProfileTitle), findsOneWidget);
      await tester.enterText(find.byType(TextField).at(0), 'Sam Carter');
      await tester.pump();
      await tester.enterText(find.byType(TextField).at(1), '+15557654321');
      await tester.pump();
      await tester.tap(find.text(l10n.onboardingNext));
      await tester.pumpAndSettle();

      // Page 2 — Permissions. Grant-all drives the real requestAllPermissions
      // (deterministic no-op via the platform seam) and "Get started" finishes.
      expect(find.text(l10n.onboardingPermissionsTitle), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text(l10n.onboardingPermissionsGrantAll),
        100,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.onboardingPermissionsGrantAll));
      await tester.pumpAndSettle();
      check(permPlatform.requestCalls).isGreaterThan(0);

      await tester.scrollUntilVisible(
        find.text(l10n.onboardingGetStarted),
        100,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.onboardingGetStarted));
      await tester.pumpAndSettle();

      // Completion side-effects — proven against the REAL repos:
      // 1. isFirstLaunch flipped to false (onboarding never re-shows).
      check(settingsRepo.saveCount).isGreaterThan(0);
      check(settingsRepo._value.isFirstLaunch).isFalse();
      // 2. The typed profile draft was persisted verbatim.
      check(profileRepo.saveCount).isGreaterThan(0);
      check(profileRepo._value.name).equals('Sam Carter');
      check(profileRepo._value.phoneNumber).equals('+15557654321');
      // 3. Navigation left onboarding for home.
      expect(find.text('HOME-REACHED'), findsOneWidget);
      expect(find.text(l10n.onboardingPermissionsTitle), findsNothing);
    },
  );

  testWidgets(
    'WID-001 finishing with an empty profile persists null name/phone (the '
    'draft is optional) but still flips isFirstLaunch and routes home',
    (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(tester, overrides());

      // Skip straight through the pages without entering profile details.
      await tester.tap(find.text(l10n.onboardingNext));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.onboardingNext));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text(l10n.onboardingGetStarted),
        100,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.onboardingGetStarted));
      await tester.pumpAndSettle();

      // First-launch flag still flips; empty draft → null profile fields.
      check(settingsRepo._value.isFirstLaunch).isFalse();
      check(profileRepo._value.name).isNull();
      check(profileRepo._value.phoneNumber).isNull();
      expect(find.text('HOME-REACHED'), findsOneWidget);
    },
  );
}
