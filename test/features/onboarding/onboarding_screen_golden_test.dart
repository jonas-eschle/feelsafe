/// Alchemist golden tests for [OnboardingScreen].
///
/// Six scenarios covering light, dark, and RTL across the three pages
/// of the first-launch onboarding flow.
///
/// Golden images are written to
/// `test/features/onboarding/goldens/ci/<name>.png` by the default
/// alchemist [CiGoldensConfig.filePathResolver].
///
/// Run with:
///   flutter test test/features/onboarding/onboarding_screen_golden_test.dart \
///     --update-goldens   # regenerate baselines
///   flutter test test/features/onboarding/onboarding_screen_golden_test.dart
library;

import 'package:flutter/material.dart';

import 'package:alchemist/alchemist.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/features/onboarding/onboarding_controller.dart';
import 'package:guardianangela/features/onboarding/onboarding_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/protocols/device_info_service_protocol.dart';
import 'package:guardianangela/services/service_providers.dart';

// ---------------------------------------------------------------------------
// Fake controller
// ---------------------------------------------------------------------------

/// Injects a canned [OnboardingState] so golden tests never touch I/O.
class _FakeOnboardingController extends OnboardingController {
  _FakeOnboardingController(this._initial);

  final OnboardingState _initial;

  @override
  OnboardingState build() => _initial;

  @override
  void updateProfileDraft({String? name, String? phone}) {}

  @override
  Future<void> completeOnboarding() async {}

  @override
  Future<void> requestAllPermissions() async {}
}

// ---------------------------------------------------------------------------
// Fake device-info service
// ---------------------------------------------------------------------------

/// Returns [SimNumberUnsupported] so [_ProfileContactPage] never opens a
/// platform channel during golden capture.
class _FakeDeviceInfoService implements DeviceInfoServiceProtocol {
  const _FakeDeviceInfoService();

  @override
  Future<SimNumberResult> getSimPhoneNumber() async =>
      const SimNumberUnsupported();
}

// ---------------------------------------------------------------------------
// State factories
// ---------------------------------------------------------------------------

OnboardingState _state({
  String? draftName,
  String? draftPhone,
  int contactCount = 0,
}) => OnboardingState(
  draftName: draftName,
  draftPhone: draftPhone,
  contactCount: contactCount,
);

// ---------------------------------------------------------------------------
// Theme helpers
// ---------------------------------------------------------------------------

ThemeData _lightTheme() => ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF131118)),
  useMaterial3: true,
);

ThemeData _darkTheme() => ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF131118),
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
);

// ---------------------------------------------------------------------------
// Harness
// ---------------------------------------------------------------------------

/// Builds a minimal [GoRouter] routing to [OnboardingScreen].
///
/// Routes provided:
/// - `/` — home placeholder (blank [Scaffold])
/// - `/onboarding` — [OnboardingScreen] under test
/// - `/contacts/new` — stub so pushNamed does not throw
GoRouter _router({
  required List<Override> overrides,
}) => GoRouter(
  initialLocation: '/onboarding',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) =>
          const Scaffold(body: SizedBox.shrink()),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => ProviderScope(
        overrides: overrides,
        child: const OnboardingScreen(),
      ),
    ),
    GoRoute(
      path: '/contacts/new',
      name: 'contact_form',
      builder: (context, state) =>
          const Scaffold(body: SizedBox.shrink()),
    ),
  ],
);

/// Wraps [OnboardingScreen] in the full GoRouter + ProviderScope +
/// MaterialApp harness.
///
/// The [pumpWidget] callback used in [goldenTest] receives a single
/// [Widget] argument — this function is used as that callback.
Future<Widget> _buildHarness({
  required List<Override> overrides,
  required ThemeData theme,
  required ThemeData darkTheme,
  required ThemeMode themeMode,
  required Locale locale,
}) async {
  final router = _router(overrides: overrides);
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      routerConfig: router,
      locale: locale,
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      themeMode: themeMode,
      theme: theme,
      darkTheme: darkTheme,
    ),
  );
}

// ---------------------------------------------------------------------------
// Scenario constraint — phone-like viewport (360 × 780 dp)
// ---------------------------------------------------------------------------

const BoxConstraints _phoneConstraints = BoxConstraints(
  minWidth: 360,
  maxWidth: 360,
  minHeight: 780,
  maxHeight: 780,
);

// ---------------------------------------------------------------------------
// Shared overrides builder
// ---------------------------------------------------------------------------

List<Override> _overrides(_FakeOnboardingController fake) => <Override>[
  onboardingControllerProvider.overrideWith(() => fake),
  deviceInfoServiceProvider.overrideWithValue(const _FakeDeviceInfoService()),
];

// ---------------------------------------------------------------------------
// Golden tests
// ---------------------------------------------------------------------------

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // Scenario 1 — Light: Welcome page (initial state)
  // ─────────────────────────────────────────────────────────────────────────

  goldenTest(
    'OnboardingScreen — light — welcome page',
    fileName: 'onboarding_welcome_light',
    builder: () => GoldenTestGroup(
      scenarioConstraints: _phoneConstraints,
      children: <Widget>[
        GoldenTestScenario(
          name: 'welcome • light',
          child: FutureBuilder<Widget>(
            future: _buildHarness(
              overrides: _overrides(
                _FakeOnboardingController(_state()),
              ),
              theme: _lightTheme(),
              darkTheme: _darkTheme(),
              themeMode: ThemeMode.light,
              locale: const Locale('en'),
            ),
            builder: (context, snapshot) =>
                snapshot.data ?? const SizedBox.shrink(),
          ),
        ),
      ],
    ),
    pumpWidget: (tester, widget) async {
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
    },
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Scenario 2 — Light: Profile page (page index 1)
  // ─────────────────────────────────────────────────────────────────────────

  goldenTest(
    'OnboardingScreen — light — profile page',
    fileName: 'onboarding_profile_light',
    builder: () => GoldenTestGroup(
      scenarioConstraints: _phoneConstraints,
      children: <Widget>[
        GoldenTestScenario(
          name: 'profile • light',
          child: FutureBuilder<Widget>(
            future: _buildHarness(
              overrides: _overrides(
                _FakeOnboardingController(_state()),
              ),
              theme: _lightTheme(),
              darkTheme: _darkTheme(),
              themeMode: ThemeMode.light,
              locale: const Locale('en'),
            ),
            builder: (context, snapshot) =>
                snapshot.data ?? const SizedBox.shrink(),
          ),
        ),
      ],
    ),
    pumpWidget: (tester, widget) async {
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
      // Advance PageView to page 1 (Profile).
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.text(l10n.onboardingNext));
      await tester.pumpAndSettle();
    },
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Scenario 3 — Light: Permissions page (page index 2)
  // ─────────────────────────────────────────────────────────────────────────

  goldenTest(
    'OnboardingScreen — light — permissions page',
    fileName: 'onboarding_permissions_light',
    builder: () => GoldenTestGroup(
      scenarioConstraints: _phoneConstraints,
      children: <Widget>[
        GoldenTestScenario(
          name: 'permissions • light',
          child: FutureBuilder<Widget>(
            future: _buildHarness(
              overrides: _overrides(
                _FakeOnboardingController(_state()),
              ),
              theme: _lightTheme(),
              darkTheme: _darkTheme(),
              themeMode: ThemeMode.light,
              locale: const Locale('en'),
            ),
            builder: (context, snapshot) =>
                snapshot.data ?? const SizedBox.shrink(),
          ),
        ),
      ],
    ),
    pumpWidget: (tester, widget) async {
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
      // Advance PageView to page 2 (Permissions).
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.text(l10n.onboardingNext));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.onboardingNext));
      await tester.pumpAndSettle();
    },
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Scenario 4 — Dark: Welcome page
  // ─────────────────────────────────────────────────────────────────────────

  goldenTest(
    'OnboardingScreen — dark — welcome page',
    fileName: 'onboarding_welcome_dark',
    builder: () => GoldenTestGroup(
      scenarioConstraints: _phoneConstraints,
      children: <Widget>[
        GoldenTestScenario(
          name: 'welcome • dark',
          child: FutureBuilder<Widget>(
            future: _buildHarness(
              overrides: _overrides(
                _FakeOnboardingController(_state()),
              ),
              theme: _lightTheme(),
              darkTheme: _darkTheme(),
              themeMode: ThemeMode.dark,
              locale: const Locale('en'),
            ),
            builder: (context, snapshot) =>
                snapshot.data ?? const SizedBox.shrink(),
          ),
        ),
      ],
    ),
    pumpWidget: (tester, widget) async {
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
    },
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Scenario 5 — Dark: Profile page with one emergency contact added
  // ─────────────────────────────────────────────────────────────────────────

  goldenTest(
    'OnboardingScreen — dark — profile page with contact',
    fileName: 'onboarding_profile_dark',
    builder: () => GoldenTestGroup(
      scenarioConstraints: _phoneConstraints,
      children: <Widget>[
        GoldenTestScenario(
          name: 'profile • dark • contactCount=1',
          child: FutureBuilder<Widget>(
            future: _buildHarness(
              overrides: _overrides(
                _FakeOnboardingController(_state(contactCount: 1)),
              ),
              theme: _lightTheme(),
              darkTheme: _darkTheme(),
              themeMode: ThemeMode.dark,
              locale: const Locale('en'),
            ),
            builder: (context, snapshot) =>
                snapshot.data ?? const SizedBox.shrink(),
          ),
        ),
      ],
    ),
    pumpWidget: (tester, widget) async {
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
      // Advance PageView to page 1 (Profile).
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.text(l10n.onboardingNext));
      await tester.pumpAndSettle();
    },
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Scenario 6 — RTL: Welcome page (Arabic locale)
  // ─────────────────────────────────────────────────────────────────────────

  goldenTest(
    'OnboardingScreen — RTL — welcome page',
    fileName: 'onboarding_welcome_rtl',
    builder: () => GoldenTestGroup(
      scenarioConstraints: _phoneConstraints,
      children: <Widget>[
        GoldenTestScenario(
          name: 'welcome • RTL (ar)',
          child: FutureBuilder<Widget>(
            future: _buildHarness(
              overrides: _overrides(
                _FakeOnboardingController(_state()),
              ),
              theme: _lightTheme(),
              darkTheme: _darkTheme(),
              themeMode: ThemeMode.light,
              locale: const Locale('ar'),
            ),
            builder: (context, snapshot) =>
                snapshot.data ?? const SizedBox.shrink(),
          ),
        ),
      ],
    ),
    pumpWidget: (tester, widget) async {
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();
    },
  );
}
