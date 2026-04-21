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
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        settingsRepositoryProvider
            .overrideWithValue(FakeSettingsRepository()),
        userProfileRepositoryProvider
            .overrideWithValue(FakeUserProfileRepository()),
        contactsRepositoryProvider
            .overrideWithValue(FakeContactsRepository()),
      ],
      child: const OnboardingScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(OnboardingScreen).evaluate().length).equals(1);
  });

  testWidgets('OnboardingScreen shows a PageView', (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        settingsRepositoryProvider
            .overrideWithValue(FakeSettingsRepository()),
        userProfileRepositoryProvider
            .overrideWithValue(FakeUserProfileRepository()),
        contactsRepositoryProvider
            .overrideWithValue(FakeContactsRepository()),
      ],
      child: const OnboardingScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(PageView).evaluate().length).equals(1);
  });

  testWidgets('OnboardingScreen advances through pages via Next',
      (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        settingsRepositoryProvider
            .overrideWithValue(FakeSettingsRepository()),
        userProfileRepositoryProvider
            .overrideWithValue(FakeUserProfileRepository()),
        contactsRepositoryProvider
            .overrideWithValue(FakeContactsRepository()),
      ],
      child: const OnboardingScreen(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    check(find.byIcon(Icons.lock_open).evaluate().length).equals(1);
  });

  testWidgets('OnboardingScreen Skip button persists settings',
      (tester) async {
    final settingsRepo = FakeSettingsRepository();
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        userProfileRepositoryProvider
            .overrideWithValue(FakeUserProfileRepository()),
        contactsRepositoryProvider
            .overrideWithValue(FakeContactsRepository()),
      ],
      child: const OnboardingScreen(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    // Skip persists the completion flag and routes home.
    check(settingsRepo.stored).isNotNull();
    check(settingsRepo.stored!.isFirstLaunch).isFalse();
  });

  testWidgets(
    'OnboardingScreen finish button on last page saves profile + contact',
    (tester) async {
      final settingsRepo = FakeSettingsRepository();
      final profileRepo = FakeUserProfileRepository();
      final contactsRepo = FakeContactsRepository();
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          userProfileRepositoryProvider.overrideWithValue(profileRepo),
          contactsRepositoryProvider.overrideWithValue(contactsRepo),
        ],
        child: const OnboardingScreen(),
      ));
      await tester.pumpAndSettle();
      // Advance to page 2 and fill in name + contact.
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Alice');
      await tester.enterText(fields.at(1), 'Bob');
      await tester.enterText(fields.at(2), '+15550001111');
      await tester.pump();
      // Advance to last page.
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      // Tap Finish (last-page FilledButton).
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      check(profileRepo.stored).isNotNull();
      check(profileRepo.stored!.name).equals('Alice');
      final contacts = await contactsRepo.getAll();
      check(contacts.length).equals(1);
      check(contacts.single.phoneNumber).equals('+15550001111');
      check(settingsRepo.stored!.isFirstLaunch).isFalse();
    },
  );
}
