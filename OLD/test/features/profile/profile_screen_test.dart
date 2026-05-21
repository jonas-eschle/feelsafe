/// Smoke tests for [ProfileScreen] — renders the form without
/// throwing with and without pre-populated profile.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/user_profile.dart';
import 'package:guardianangela/features/profile/profile_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  testWidgets('ProfileScreen renders with no profile stored', (tester) async {
    await tester.pumpWidget(
      hostScreen(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(
            FakeUserProfileRepository(),
          ),
        ],
        child: const ProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(ProfileScreen).evaluate().length).equals(1);
    check(find.byType(TextField).evaluate().length).isGreaterThan(0);
  });

  testWidgets('ProfileScreen hydrates form from stored profile', (
    tester,
  ) async {
    const profile = UserProfile(name: 'Alice', age: 30);
    await tester.pumpWidget(
      hostScreen(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(
            FakeUserProfileRepository(profile),
          ),
        ],
        child: const ProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(ProfileScreen).evaluate().length).equals(1);
  });

  testWidgets('ProfileScreen hydrates medical text fields', (tester) async {
    const profile = UserProfile(
      name: 'Bob',
      allergies: 'Peanuts',
      medications: 'Aspirin',
      medicalConditions: 'Asthma',
      emergencyInstructions: 'Call home',
    );
    await tester.pumpWidget(
      hostScreenPushed(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(
            FakeUserProfileRepository(profile),
          ),
        ],
        child: const ProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.text('Peanuts').evaluate().length).isGreaterOrEqual(1);
  });

  testWidgets('ProfileScreen save persists edited profile', (tester) async {
    final repo = FakeUserProfileRepository();
    await tester.pumpWidget(
      hostScreenPushed(
        overrides: [userProfileRepositoryProvider.overrideWithValue(repo)],
        child: const ProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Carol');
    await tester.enterText(fields.at(1), '42');
    // field 2 = phone, field 3 = physical, field 4 = bloodType
    await tester.enterText(fields.at(4), 'A+');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();
    check(repo.stored).isNotNull();
    check(repo.stored!.name).equals('Carol');
    check(repo.stored!.age).equals(42);
    check(repo.stored!.bloodType).equals('A+');
  });

  testWidgets(
    'ProfileScreen save with blank fields writes a null-filled profile',
    (tester) async {
      final repo = FakeUserProfileRepository();
      await tester.pumpWidget(
        hostScreenPushed(
          overrides: [userProfileRepositoryProvider.overrideWithValue(repo)],
          child: const ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();
      check(repo.stored).isNotNull();
      check(repo.stored!.name).isNull();
      check(repo.stored!.bloodType).isNull();
      check(repo.stored!.emergencyInstructions).isNull();
    },
  );
}
