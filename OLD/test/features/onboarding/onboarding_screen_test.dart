/// Smoke tests for [OnboardingScreen].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/features/onboarding/onboarding_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  testWidgets('OnboardingScreen renders without throwing', (tester) async {
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            FakeSettingsRepository(),
          ),
          userProfileRepositoryProvider.overrideWithValue(
            FakeUserProfileRepository(),
          ),
          contactsRepositoryProvider.overrideWithValue(
            FakeContactsRepository(),
          ),
        ],
        child: const OnboardingScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(OnboardingScreen).evaluate().length).equals(1);
  });

  testWidgets('OnboardingScreen shows a PageView', (tester) async {
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            FakeSettingsRepository(),
          ),
          userProfileRepositoryProvider.overrideWithValue(
            FakeUserProfileRepository(),
          ),
          contactsRepositoryProvider.overrideWithValue(
            FakeContactsRepository(),
          ),
        ],
        child: const OnboardingScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(PageView).evaluate().length).equals(1);
  });

  testWidgets('OnboardingScreen advances through pages via Next', (
    tester,
  ) async {
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            FakeSettingsRepository(),
          ),
          userProfileRepositoryProvider.overrideWithValue(
            FakeUserProfileRepository(),
          ),
          contactsRepositoryProvider.overrideWithValue(
            FakeContactsRepository(),
          ),
        ],
        child: const OnboardingScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.lock_open).evaluate().length).equals(1);
  });

  testWidgets('OnboardingScreen Skip button persists settings', (tester) async {
    final settingsRepo = FakeSettingsRepository();
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          userProfileRepositoryProvider.overrideWithValue(
            FakeUserProfileRepository(),
          ),
          contactsRepositoryProvider.overrideWithValue(
            FakeContactsRepository(),
          ),
        ],
        child: const OnboardingScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    // Skip persists the completion flag and routes home.
    check(settingsRepo.stored).isNotNull();
    check(settingsRepo.stored!.isFirstLaunch).isFalse();
  });

  testWidgets('OnboardingScreen finish button on last page saves profile only '
      '(contacts captured via the full ContactFormScreen, Q26)', (
    tester,
  ) async {
    final settingsRepo = FakeSettingsRepository();
    final profileRepo = FakeUserProfileRepository();
    final contactsRepo = FakeContactsRepository();
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          userProfileRepositoryProvider.overrideWithValue(profileRepo),
          contactsRepositoryProvider.overrideWithValue(contactsRepo),
        ],
        child: const OnboardingScreen(),
      ),
    );
    await tester.pumpAndSettle();
    // Advance to page 2 (profile name + contacts list).
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    // p2 exposes only the profile name TextField; contacts come
    // from the pushed ContactFormScreen which we don't exercise here.
    await tester.enterText(fields.first, 'Alice');
    await tester.pump();
    // Advance to permissions page.
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    // Tap Finish (last-page FilledButton).
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    check(profileRepo.stored).isNotNull();
    check(profileRepo.stored!.name).equals('Alice');
    check(settingsRepo.stored!.isFirstLaunch).isFalse();
  });
}
