/// Widget tests for [OnboardingScreen] — 3-page first-launch flow.
///
/// Mirrors the canonical home_screen_test.dart pattern:
/// 1. A `_FakeOnboardingController` subclasses [OnboardingController] and
///    overrides `build()` to return a canned [OnboardingState].
/// 2. Each `testWidgets` body calls [_pumpOnboarding] which wraps the
///    screen in a GoRouter-aware harness (required because `_finish()`
///    calls `context.goNamed`).
/// 3. Assertions use `find.byType`, `find.text(l10n.*)`, and
///    `package:checks` for expressive checks.
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/widgets/pride_page_indicator.dart';
import 'package:guardianangela/features/onboarding/onboarding_controller.dart';
import 'package:guardianangela/features/onboarding/onboarding_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/protocols/device_info_service_protocol.dart';
import 'package:guardianangela/services/service_providers.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Test fake
// ---------------------------------------------------------------------------

class _FakeOnboardingController extends OnboardingController {
  _FakeOnboardingController(this._initial);

  final OnboardingState _initial;

  int updateProfileDraftCalls = 0;
  int completeOnboardingCalls = 0;
  int requestAllPermissionsCalls = 0;

  @override
  OnboardingState build() => _initial;

  @override
  void updateProfileDraft({String? name, String? phone}) {
    updateProfileDraftCalls++;
    state = state.copyWith(draftName: name, draftPhone: phone);
  }

  @override
  Future<void> completeOnboarding() async {
    completeOnboardingCalls++;
    // No actual I/O in widget tests.
  }

  @override
  Future<void> requestAllPermissions() async {
    requestAllPermissionsCalls++;
    // No platform permission dialogs in widget tests.
  }
}

/// Canned [DeviceInfoServiceProtocol] driving the "Use my SIM number"
/// result branches (spec 04 §Onboarding, Extra 28).
class _FakeDeviceInfoService implements DeviceInfoServiceProtocol {
  _FakeDeviceInfoService(this._result);

  final SimNumberResult _result;
  int calls = 0;

  @override
  Future<SimNumberResult> getSimPhoneNumber() async {
    calls++;
    return _result;
  }
}

// ---------------------------------------------------------------------------
// Harness
// ---------------------------------------------------------------------------

/// Builds a minimal [GoRouter] so that `context.goNamed` and
/// `context.pushNamed` calls inside [OnboardingScreen] do not throw.
///
/// Routes provided:
/// - `/` — home placeholder (blank `Scaffold`)
/// - `/onboarding` — the [OnboardingScreen] under test
/// - `/contacts/new` — stub for the contact form
GoRouter _router({required List<Override> overrides}) => GoRouter(
  initialLocation: '/onboarding',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const Scaffold(body: SizedBox.shrink()),
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
      builder: (context, state) => const Scaffold(
        key: ValueKey('contact-form-stub'),
        body: SizedBox.shrink(),
      ),
    ),
  ],
);

/// Pumps [OnboardingScreen] inside a GoRouter + ProviderScope + MaterialApp
/// harness with the supplied [overrides] and [locale].
Future<void> _pumpOnboarding(
  WidgetTester tester, {
  required List<Override> overrides,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  bool settle = true,
}) async {
  final router = _router(overrides: overrides);
  await tester.pumpWidget(
    ProviderScope(
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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF131118)),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF131118),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  }
}

// ---------------------------------------------------------------------------
// Shared state factories
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

List<Override> _overrides(_FakeOnboardingController fake) => <Override>[
  onboardingControllerProvider.overrideWith(() => fake),
];

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Welcome page
  // -------------------------------------------------------------------------

  group('OnboardingScreen — Welcome page', () {
    testWidgets('shows the GuardianAngelaLogo widget', (
      WidgetTester tester,
    ) async {
      final fake = _FakeOnboardingController(_state());
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      // Logo renders inside the first PageView page.
      expect(
        find.byWidgetPredicate(
          (w) => w.runtimeType.toString() == 'GuardianAngelaLogo',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows "Hi, I\'m Angela" greeting text', (
      WidgetTester tester,
    ) async {
      final fake = _FakeOnboardingController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      expect(find.text(l10n.onboardingWelcomeGreeting), findsOneWidget);
    });

    testWidgets('shows the welcome body paragraph', (
      WidgetTester tester,
    ) async {
      final fake = _FakeOnboardingController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      expect(find.text(l10n.onboardingWelcomeBodyFull), findsOneWidget);
    });

    testWidgets('shows the tagline in italic style', (
      WidgetTester tester,
    ) async {
      final fake = _FakeOnboardingController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      expect(find.text(l10n.homeTagline), findsOneWidget);
    });

    testWidgets('shows "Next" button on page 0 (not "Get started")', (
      WidgetTester tester,
    ) async {
      final fake = _FakeOnboardingController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      expect(find.text(l10n.onboardingNext), findsOneWidget);
      expect(find.text(l10n.onboardingGetStarted), findsNothing);
    });

    testWidgets('Back button is disabled on the first page', (
      WidgetTester tester,
    ) async {
      final fake = _FakeOnboardingController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      final backBtn = tester.widget<TextButton>(
        find.widgetWithText(TextButton, l10n.commonBack),
      );
      check(backBtn.onPressed).isNull();
    });

    testWidgets('PridePageIndicator shows current page 0 of 3', (
      WidgetTester tester,
    ) async {
      final fake = _FakeOnboardingController(_state());
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      final indicator = tester.widget<PridePageIndicator>(
        find.byType(PridePageIndicator),
      );
      check(indicator.currentIndex).equals(0);
      check(indicator.pageCount).equals(3);
    });
  });

  // -------------------------------------------------------------------------
  // Page navigation
  // -------------------------------------------------------------------------

  group('OnboardingScreen — Page navigation', () {
    testWidgets('tapping Next advances from page 0 to page 1', (
      WidgetTester tester,
    ) async {
      final fake = _FakeOnboardingController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      await tester.tap(find.text(l10n.onboardingNext));
      await tester.pumpAndSettle();
      final indicator = tester.widget<PridePageIndicator>(
        find.byType(PridePageIndicator),
      );
      check(indicator.currentIndex).equals(1);
    });

    testWidgets('Back button becomes enabled on page 1', (
      WidgetTester tester,
    ) async {
      final fake = _FakeOnboardingController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      await tester.tap(find.text(l10n.onboardingNext));
      await tester.pumpAndSettle();
      final backBtn = tester.widget<TextButton>(
        find.widgetWithText(TextButton, l10n.commonBack),
      );
      check(backBtn.onPressed).isNotNull();
    });

    testWidgets('tapping Back on page 1 returns to page 0', (
      WidgetTester tester,
    ) async {
      final fake = _FakeOnboardingController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      // Advance to page 1.
      await tester.tap(find.text(l10n.onboardingNext));
      await tester.pumpAndSettle();
      // Go back.
      await tester.tap(find.text(l10n.commonBack));
      await tester.pumpAndSettle();
      final indicator = tester.widget<PridePageIndicator>(
        find.byType(PridePageIndicator),
      );
      check(indicator.currentIndex).equals(0);
    });

    testWidgets('tapping Next twice reaches page 2 with "Get started"', (
      WidgetTester tester,
    ) async {
      final fake = _FakeOnboardingController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      await tester.tap(find.text(l10n.onboardingNext));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.onboardingNext));
      await tester.pumpAndSettle();
      expect(find.text(l10n.onboardingGetStarted), findsOneWidget);
      expect(find.text(l10n.onboardingNext), findsNothing);
    });

    testWidgets('PridePageIndicator updates to currentIndex=2 on last page', (
      WidgetTester tester,
    ) async {
      final fake = _FakeOnboardingController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      await tester.tap(find.text(l10n.onboardingNext));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.onboardingNext));
      await tester.pumpAndSettle();
      final indicator = tester.widget<PridePageIndicator>(
        find.byType(PridePageIndicator),
      );
      check(indicator.currentIndex).equals(2);
    });
  });

  // -------------------------------------------------------------------------
  // Profile + Contact page
  // -------------------------------------------------------------------------

  group('OnboardingScreen — Profile page', () {
    Future<void> goToProfilePage(
      WidgetTester tester,
      AppLocalizations l10n,
    ) async {
      await tester.tap(find.text(l10n.onboardingNext));
      await tester.pumpAndSettle();
    }

    testWidgets('shows the profile page title after Next tap', (
      WidgetTester tester,
    ) async {
      final fake = _FakeOnboardingController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      await goToProfilePage(tester, l10n);
      expect(find.text(l10n.onboardingProfileTitle), findsOneWidget);
    });

    testWidgets('shows Name and Phone text fields (2 total)', (
      WidgetTester tester,
    ) async {
      final fake = _FakeOnboardingController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      await goToProfilePage(tester, l10n);
      // InputDecoration labels are Text nodes; the name label must appear.
      expect(find.text(l10n.onboardingProfileNameLabel), findsOneWidget);
      // Profile page renders exactly 2 TextFields: name + phone.
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('shows phone helper text below phone field', (
      WidgetTester tester,
    ) async {
      final fake = _FakeOnboardingController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      await goToProfilePage(tester, l10n);
      expect(find.text(l10n.onboardingProfilePhoneHelper), findsOneWidget);
    });

    testWidgets('pre-fills name field from draftName in state', (
      WidgetTester tester,
    ) async {
      final fake = _FakeOnboardingController(_state(draftName: 'Alice'));
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      await goToProfilePage(tester, l10n);
      expect(find.widgetWithText(TextField, 'Alice'), findsOneWidget);
    });

    testWidgets('shows Emergency Contact section header', (
      WidgetTester tester,
    ) async {
      final fake = _FakeOnboardingController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      await goToProfilePage(tester, l10n);
      expect(find.text(l10n.onboardingEmergencyContactHeader), findsOneWidget);
    });

    testWidgets(
      'shows "No contact added yet" and Add button when contactCount==0',
      (WidgetTester tester) async {
        final fake = _FakeOnboardingController(_state());
        final l10n = await loadL10n(const Locale('en'));
        await _pumpOnboarding(tester, overrides: _overrides(fake));
        await goToProfilePage(tester, l10n);
        expect(find.text(l10n.onboardingEmergencyContactAdd), findsOneWidget);
      },
    );

    testWidgets('shows contact card (not Add button) when contactCount > 0', (
      WidgetTester tester,
    ) async {
      final fake = _FakeOnboardingController(_state(contactCount: 1));
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      await goToProfilePage(tester, l10n);
      // Add button should be hidden when a contact exists.
      expect(find.text(l10n.onboardingEmergencyContactAdd), findsNothing);
      // A Card wrapping a ListTile should be visible.
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('typing in name field calls updateProfileDraft', (
      WidgetTester tester,
    ) async {
      final fake = _FakeOnboardingController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      await goToProfilePage(tester, l10n);
      // Find the first TextField (name field).
      await tester.enterText(find.byType(TextField).first, 'Bob');
      await tester.pump();
      check(fake.updateProfileDraftCalls).isGreaterThan(0);
    });
  });

  // -------------------------------------------------------------------------
  // Permissions page
  // -------------------------------------------------------------------------

  group('OnboardingScreen — Permissions page', () {
    Future<void> goToPermissionsPage(
      WidgetTester tester,
      AppLocalizations l10n,
    ) async {
      await tester.tap(find.text(l10n.onboardingNext));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.onboardingNext));
      await tester.pumpAndSettle();
    }

    testWidgets('shows permissions page title after two Next taps', (
      WidgetTester tester,
    ) async {
      final fake = _FakeOnboardingController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      await goToPermissionsPage(tester, l10n);
      expect(find.text(l10n.onboardingPermissionsTitle), findsOneWidget);
    });

    testWidgets('shows intro sentence on permissions page', (
      WidgetTester tester,
    ) async {
      final fake = _FakeOnboardingController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      await goToPermissionsPage(tester, l10n);
      expect(find.text(l10n.onboardingPermissionsIntro), findsOneWidget);
    });

    testWidgets('shows Notifications permission tile', (
      WidgetTester tester,
    ) async {
      final fake = _FakeOnboardingController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      await goToPermissionsPage(tester, l10n);
      expect(find.text(l10n.homePermissionsNotification), findsOneWidget);
    });

    testWidgets('shows SMS permission tile', (WidgetTester tester) async {
      final fake = _FakeOnboardingController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      await goToPermissionsPage(tester, l10n);
      expect(find.text(l10n.homePermissionsSendSms), findsOneWidget);
    });

    testWidgets('shows Phone permission tile', (WidgetTester tester) async {
      final fake = _FakeOnboardingController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      await goToPermissionsPage(tester, l10n);
      expect(find.text(l10n.homePermissionsCallPhone), findsOneWidget);
    });

    testWidgets('shows Location permission tile', (WidgetTester tester) async {
      final fake = _FakeOnboardingController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      await goToPermissionsPage(tester, l10n);
      expect(find.text(l10n.homePermissionsLocation), findsOneWidget);
    });

    testWidgets('shows Microphone permission tile (OPTIONAL)', (
      WidgetTester tester,
    ) async {
      final fake = _FakeOnboardingController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      await goToPermissionsPage(tester, l10n);
      expect(find.text(l10n.onboardingPermissionsMicrophone), findsOneWidget);
    });

    testWidgets('shows Camera permission tile (OPTIONAL)', (
      WidgetTester tester,
    ) async {
      final fake = _FakeOnboardingController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      await goToPermissionsPage(tester, l10n);
      expect(find.text(l10n.onboardingPermissionsCamera), findsOneWidget);
    });

    testWidgets('at least one REQUIRED badge is visible', (
      WidgetTester tester,
    ) async {
      final fake = _FakeOnboardingController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      await goToPermissionsPage(tester, l10n);
      expect(find.text(l10n.onboardingPermissionsRequired), findsWidgets);
    });

    testWidgets('at least one OPTIONAL badge is visible', (
      WidgetTester tester,
    ) async {
      final fake = _FakeOnboardingController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      await goToPermissionsPage(tester, l10n);
      expect(find.text(l10n.onboardingPermissionsOptional), findsWidgets);
    });

    testWidgets('"Grant all" button calls requestAllPermissions', (
      WidgetTester tester,
    ) async {
      final fake = _FakeOnboardingController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      await goToPermissionsPage(tester, l10n);
      // The button is below the fold in a SingleChildScrollView; scroll
      // to it before tapping.
      await tester.scrollUntilVisible(
        find.text(l10n.onboardingPermissionsGrantAll),
        100,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.onboardingPermissionsGrantAll));
      await tester.pumpAndSettle();
      check(fake.requestAllPermissionsCalls).equals(1);
    });
  });

  // -------------------------------------------------------------------------
  // First-launch completion
  // -------------------------------------------------------------------------

  group('OnboardingScreen — First-launch completion', () {
    testWidgets(
      '"Get started" calls completeOnboarding and navigates to home',
      (WidgetTester tester) async {
        final fake = _FakeOnboardingController(_state());
        final l10n = await loadL10n(const Locale('en'));
        await _pumpOnboarding(tester, overrides: _overrides(fake));
        // Navigate to last page.
        await tester.tap(find.text(l10n.onboardingNext));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.onboardingNext));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.onboardingGetStarted));
        await tester.pumpAndSettle();
        check(fake.completeOnboardingCalls).equals(1);
      },
    );

    testWidgets(
      '"Get started" routes away from onboarding (home scaffold visible)',
      (WidgetTester tester) async {
        final fake = _FakeOnboardingController(_state());
        final l10n = await loadL10n(const Locale('en'));
        await _pumpOnboarding(tester, overrides: _overrides(fake));
        await tester.tap(find.text(l10n.onboardingNext));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.onboardingNext));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.onboardingGetStarted));
        await tester.pumpAndSettle();
        // After navigation the OnboardingScreen should no longer be visible.
        expect(find.text(l10n.onboardingPermissionsTitle), findsNothing);
      },
    );
  });

  // -------------------------------------------------------------------------
  // RTL smoke
  // -------------------------------------------------------------------------

  group('OnboardingScreen — RTL', () {
    testWidgets('renders in Arabic (RTL) without exception', (
      WidgetTester tester,
    ) async {
      final fake = _FakeOnboardingController(_state());
      await _pumpOnboarding(
        tester,
        overrides: _overrides(fake),
        locale: const Locale('ar'),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Dark mode smoke
  // -------------------------------------------------------------------------

  group('OnboardingScreen — Dark mode', () {
    testWidgets('renders without exception in dark mode', (
      WidgetTester tester,
    ) async {
      final fake = _FakeOnboardingController(_state());
      await _pumpOnboarding(
        tester,
        overrides: _overrides(fake),
        themeMode: ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Accessibility
  // -------------------------------------------------------------------------

  group('OnboardingScreen — Accessibility', () {
    testWidgets('passes Flutter accessibility guidelines on welcome page', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final fake = _FakeOnboardingController(_state());
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('passes accessibility guidelines on profile page', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final fake = _FakeOnboardingController(_state());
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      await tester.tap(find.text(l10n.onboardingNext));
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });
  });

  // -------------------------------------------------------------------------
  // Skip button (AppBar, pages 1-2 only)
  // -------------------------------------------------------------------------

  group('OnboardingScreen — Skip button', () {
    testWidgets('is absent on page 0 and Skip on page 1 jumps to page 2', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeOnboardingController(_state());
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      expect(find.text(l10n.onboardingSkip), findsNothing);

      await tester.tap(find.text(l10n.onboardingNext));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.onboardingSkip));
      await tester.pumpAndSettle();

      // Landed on the permissions page with the final-page CTA.
      expect(find.text(l10n.onboardingPermissionsTitle), findsOneWidget);
      expect(find.text(l10n.onboardingGetStarted), findsOneWidget);
      check(fake.completeOnboardingCalls).equals(0);
    });

    testWidgets('Skip on the last page finishes onboarding and leaves the '
        'screen', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeOnboardingController(_state());
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      await tester.tap(find.text(l10n.onboardingNext));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.onboardingNext));
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.onboardingSkip));
      await tester.pumpAndSettle();

      check(fake.completeOnboardingCalls).equals(1);
      expect(find.byType(OnboardingScreen), findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  // "Use my SIM number" (profile page, Extra 28)
  // -------------------------------------------------------------------------

  group('OnboardingScreen — Use my SIM number', () {
    Future<void> pumpProfilePage(
      WidgetTester tester, {
      required _FakeDeviceInfoService device,
      required _FakeOnboardingController fake,
    }) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpOnboarding(
        tester,
        overrides: <Override>[
          ..._overrides(fake),
          deviceInfoServiceProvider.overrideWithValue(device),
        ],
      );
      await tester.tap(find.text(l10n.onboardingNext));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.onboardingUseSimNumber));
      await tester.pumpAndSettle();
    }

    testWidgets('an available SIM number fills the phone field and shows '
        'the source hint', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeOnboardingController(_state());
      final device = _FakeDeviceInfoService(
        const SimNumberAvailable('+15559990000'),
      );
      await pumpProfilePage(tester, device: device, fake: fake);

      check(device.calls).equals(1);
      // The phone TextField (index 1) now carries the SIM number and the
      // hint row below the button names the source.
      final phoneField = tester.widget<TextField>(find.byType(TextField).at(1));
      check(phoneField.controller?.text).equals('+15559990000');
      // The en hint template is verbatim "{number}", so the number appears
      // twice: once inside the phone field, once in the hint row below the
      // button — the second occurrence proves the hint row rendered.
      expect(
        find.text(l10n.onboardingUseSimNumberHint('+15559990000')),
        findsNWidgets(2),
      );
      // The listener-driven draft persisted through the controller.
      check(fake.updateProfileDraftCalls).isGreaterThan(0);
    });

    testWidgets('a permission denial surfaces the denied SnackBar', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeOnboardingController(_state());
      final device = _FakeDeviceInfoService(const SimNumberPermissionDenied());
      await pumpProfilePage(tester, device: device, fake: fake);

      expect(
        find.text(l10n.onboardingUseSimNumberPermissionDenied),
        findsOneWidget,
      );
    });

    testWidgets('an unsupported platform surfaces the unsupported SnackBar', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeOnboardingController(_state());
      final device = _FakeDeviceInfoService(const SimNumberUnsupported());
      await pumpProfilePage(tester, device: device, fake: fake);

      expect(find.text(l10n.onboardingUseSimNumberUnsupported), findsOneWidget);
    });

    testWidgets('an empty SIM slot surfaces the unavailable SnackBar', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeOnboardingController(_state());
      final device = _FakeDeviceInfoService(const SimNumberUnavailable());
      await pumpProfilePage(tester, device: device, fake: fake);

      expect(find.text(l10n.onboardingUseSimNumberUnavailable), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Add-emergency-contact CTA (profile page)
  // -------------------------------------------------------------------------

  group('OnboardingScreen — add emergency contact', () {
    testWidgets('tapping the add button pushes the contact form route', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeOnboardingController(_state());
      await _pumpOnboarding(tester, overrides: _overrides(fake));
      await tester.tap(find.text(l10n.onboardingNext));
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.onboardingEmergencyContactAdd));
      await tester.pumpAndSettle();

      // The harness's /contacts/new stub replaced the onboarding UI.
      expect(find.text(l10n.onboardingProfileTitle), findsNothing);
      expect(find.byKey(const ValueKey('contact-form-stub')), findsOneWidget);
    });
  });
}
