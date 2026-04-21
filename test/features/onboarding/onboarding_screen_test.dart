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
}
