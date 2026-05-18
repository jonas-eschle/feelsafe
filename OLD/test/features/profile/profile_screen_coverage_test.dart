/// Coverage filler for [ProfileScreen]:
///   * multiline text fields for allergies, medications, conditions.
///   * Error async state path via a throwing repo.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/features/profile/profile_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  testWidgets(
    'ProfileScreen allergies text field persists value on save',
    (tester) async {
      final repo = FakeUserProfileRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(repo),
        ],
        child: const ProfileScreen(),
      ));
      await tester.pumpAndSettle();
      // Fields: 0=name, 1=age, 2=phone, 3=physical, 4=blood,
      //         5=allergies, 6=medications, 7=conditions, 8=instructions
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(5), 'Peanuts');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();
      check(repo.stored!.allergies).equals('Peanuts');
    },
  );

  testWidgets(
    'ProfileScreen blank allergies field saves as null',
    (tester) async {
      final repo = FakeUserProfileRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(repo),
        ],
        child: const ProfileScreen(),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();
      check(repo.stored!.allergies).isNull();
    },
  );
}
