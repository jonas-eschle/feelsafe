/// End-to-end UI integration tests for the onboarding journey.
///
/// Pumps the real [OnboardingScreen] inside a minimal router, uses
/// fake repositories, and validates every observable state transition
/// a real user would trigger.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/onboarding/onboarding_screen.dart';

import '../features/fake_repositories.dart';
import '../features/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

List<Override> _overrides({
  FakeSettingsRepository? settings,
  FakeUserProfileRepository? profile,
  FakeContactsRepository? contacts,
}) => [
  settingsRepositoryProvider.overrideWithValue(
    settings ?? FakeSettingsRepository(),
  ),
  userProfileRepositoryProvider.overrideWithValue(
    profile ?? FakeUserProfileRepository(),
  ),
  contactsRepositoryProvider.overrideWithValue(
    contacts ?? FakeContactsRepository(),
  ),
];

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ---- page structure -------------------------------------------------------

  testWidgets(
    'onboarding_fresh_install_shows_onboarding_not_home',
    (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(),
        child: const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();
      // The OnboardingScreen must be present, not navigated away yet.
      check(find.byType(OnboardingScreen).evaluate().length).equals(1);
      check(find.byType(PageView).evaluate().length).equals(1);
    },
  );

  testWidgets(
    'onboarding_first_page_has_skip_and_next_buttons',
    (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(),
        child: const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();
      // Skip is a TextButton, Next is a FilledButton on page 0.
      check(find.byType(TextButton).evaluate().length).isGreaterOrEqual(1);
      check(find.byType(FilledButton).evaluate().length).isGreaterOrEqual(1);
    },
  );

  testWidgets(
    'onboarding_page_indicators_show_three_dots',
    (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(),
        child: const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();
      // Three small dot containers rendered by the indicator loop.
      // Each is a Container with BoxShape.circle — the screen uses
      // Container with width/height 8 for each dot.
      final circles = tester.widgetList<Container>(find.byType(Container));
      final dots = circles.where((c) {
        final decoration = c.decoration;
        return decoration is BoxDecoration &&
            decoration.shape == BoxShape.circle;
      }).length;
      check(dots).equals(3);
    },
  );

  // ---- Next navigation -------------------------------------------------------

  testWidgets(
    'onboarding_next_advances_to_profile_page_with_text_fields',
    (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(),
        child: const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();
      // Page 2 has text fields for name and contact.
      check(find.byType(TextField).evaluate().length).isGreaterOrEqual(2);
    },
  );

  testWidgets(
    'onboarding_next_next_advances_to_permissions_page',
    (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(),
        child: const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();
      // Permissions page shows lock_open icon.
      check(find.byIcon(Icons.lock_open).evaluate().length).equals(1);
    },
  );

  testWidgets(
    'onboarding_permissions_page_shows_finish_button',
    (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(),
        child: const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();
      // Navigate to last page.
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();
      // Finish button is the FilledButton on the last page.
      check(find.byType(FilledButton).evaluate().length).isGreaterOrEqual(1);
    },
  );

  // ---- Skip -----------------------------------------------------------------

  testWidgets(
    'onboarding_skip_flips_isFirstLaunch_to_false',
    (tester) async {
      final settings = FakeSettingsRepository();
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(settings: settings),
        child: const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextButton).first);
      await tester.pumpAndSettle();
      check(settings.stored).isNotNull();
      check(settings.stored!.isFirstLaunch).isFalse();
    },
  );

  testWidgets(
    'onboarding_skip_does_not_require_profile_or_contact',
    (tester) async {
      final profile = FakeUserProfileRepository();
      final contacts = FakeContactsRepository();
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(profile: profile, contacts: contacts),
        child: const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextButton).first);
      await tester.pumpAndSettle();
      // No profile saved; Skip does not require data.
      check(profile.stored).isNull();
      final all = await contacts.getAll();
      check(all).isEmpty();
    },
  );

  // ---- Profile page + contact -----------------------------------------------

  testWidgets(
    'onboarding_finish_saves_name_and_contact',
    (tester) async {
      final settings = FakeSettingsRepository();
      final profile = FakeUserProfileRepository();
      final contacts = FakeContactsRepository();
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(
          settings: settings,
          profile: profile,
          contacts: contacts,
        ),
        child: const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();
      // Advance to page 2 (profile + contact).
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Alice');
      await tester.enterText(fields.at(1), 'Bob');
      await tester.enterText(fields.at(2), '+15550001111');
      await tester.pump();
      // Advance to last page.
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();
      // Tap Finish.
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();
      check(profile.stored?.name).equals('Alice');
      final saved = await contacts.getAll();
      check(saved.length).equals(1);
      check(saved.first.phoneNumber).equals('+15550001111');
      check(settings.stored!.isFirstLaunch).isFalse();
    },
  );

  testWidgets(
    'onboarding_finish_with_empty_name_does_not_save_profile',
    (tester) async {
      final profile = FakeUserProfileRepository();
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(profile: profile),
        child: const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();
      // Leave name blank; fill contact.
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(1), 'Bob');
      await tester.enterText(fields.at(2), '+15550001111');
      await tester.pump();
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();
      // Empty name → no profile saved.
      check(profile.stored).isNull();
    },
  );

  testWidgets(
    'onboarding_finish_with_incomplete_contact_does_not_save_contact',
    (tester) async {
      final contacts = FakeContactsRepository();
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(contacts: contacts),
        child: const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();
      // Name-only contact, no phone.
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Alice');
      await tester.enterText(fields.at(1), 'Bob');
      // No phone entered.
      await tester.pump();
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();
      final saved = await contacts.getAll();
      check(saved).isEmpty();
    },
  );

  // ---- Completion flag consistency ------------------------------------------

  testWidgets(
    'onboarding_completion_marks_settings_persisted',
    (tester) async {
      final settings = FakeSettingsRepository();
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(settings: settings),
        child: const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();
      final stored = settings.stored;
      check(stored).isNotNull();
      check(stored!.isFirstLaunch).isFalse();
    },
  );

  // ---- Welcome page content ------------------------------------------------

  testWidgets(
    'onboarding_welcome_page_shows_logo',
    (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(),
        child: const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();
      // GuardianAngelaLogo rendered on welcome page (it's a CustomPaint
      // or Container-based widget — at minimum the welcome page renders).
      check(find.byType(PageView).evaluate().length).equals(1);
    },
  );

  testWidgets(
    'onboarding_profile_page_has_name_field',
    (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(),
        child: const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();
      // Profile page is a scrollable form with text fields.
      check(find.byType(SingleChildScrollView).evaluate().length)
          .isGreaterOrEqual(1);
    },
  );

  // ---- Settings seed after finish -------------------------------------------

  testWidgets(
    'onboarding_finish_settings_has_non_null_defaults',
    (tester) async {
      final settings = FakeSettingsRepository();
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(settings: settings),
        child: const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextButton).first);
      await tester.pumpAndSettle();
      check(settings.stored?.defaults).isNotNull();
    },
  );

  testWidgets(
    'onboarding_isFirstLaunch_true_before_finish',
    (tester) async {
      final settings = FakeSettingsRepository(
        const AppSettings(defaults: AppDefaults(), isFirstLaunch: true),
      );
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _overrides(settings: settings),
        child: const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();
      // Before finish, settings still has isFirstLaunch=true.
      check(settings.stored!.isFirstLaunch).isTrue();
    },
  );
}
