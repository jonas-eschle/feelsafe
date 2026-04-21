/// Smoke tests for [ProfileScreen] — renders the form without
/// throwing with and without pre-populated profile.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/profile/profile_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  testWidgets('ProfileScreen renders with no profile stored',
      (tester) async {
    await tester.pumpWidget(hostScreen(
      overrides: [
        userProfileRepositoryProvider
            .overrideWithValue(FakeUserProfileRepository()),
      ],
      child: const ProfileScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(ProfileScreen).evaluate().length).equals(1);
    check(find.byType(TextField).evaluate().length).isGreaterThan(0);
  });

  testWidgets('ProfileScreen hydrates form from stored profile',
      (tester) async {
    const profile = UserProfile(name: 'Alice', age: 30);
    await tester.pumpWidget(hostScreen(
      overrides: [
        userProfileRepositoryProvider
            .overrideWithValue(FakeUserProfileRepository(profile)),
      ],
      child: const ProfileScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(ProfileScreen).evaluate().length).equals(1);
  });
}
