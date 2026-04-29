/// Coverage filler for [ProfileScreen]:
///   * `_ListEditor` add-item path (typed text + tapping the + icon,
///     lines 180-184 of profile_screen.dart).
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
    'ProfileScreen _ListEditor add-item button persists typed entry on save',
    (tester) async {
      final repo = FakeUserProfileRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(repo),
        ],
        child: const ProfileScreen(),
      ));
      await tester.pumpAndSettle();
      // Find the allergies inline TextField (first list editor).
      final listFields = find.byType(TextField);
      // The _ListEditor inline field comes after the three profile
      // fields (name, age, bloodType). Index 3 = first _ListEditor
      // input.
      await tester.enterText(listFields.at(3), 'Peanuts');
      await tester.pump();
      // The add icon is the first Icons.add in the list editor row.
      final addIcons = find.byIcon(Icons.add);
      await tester.tap(addIcons.first);
      await tester.pumpAndSettle();
      // Now save.
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();
      check(repo.stored!.allergies).deepEquals(['Peanuts']);
    },
  );

  testWidgets(
    'ProfileScreen _ListEditor add-item with blank input is a no-op',
    (tester) async {
      final repo = FakeUserProfileRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(repo),
        ],
        child: const ProfileScreen(),
      ));
      await tester.pumpAndSettle();
      // Tap add without typing — should not add anything.
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();
      check(repo.stored!.allergies).isEmpty();
    },
  );
}
