/// Tests for the Angela-name warning shown by [ProfileScreen].
///
/// Spec 06 §"Angela" Safety Keyword: when the user enters a name
/// containing "angela" (word-boundary, case-insensitive), the screen
/// shows an [AlertDialog] before saving. Names that do not match
/// (e.g. "Angelica", "Angelo") must NOT trigger the dialog.
///
/// The save button on [ProfileScreen] is an [IconButton] with
/// [Icons.check] in the AppBar.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/features/profile/profile_screen.dart';
import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

/// Finds the save (checkmark) icon button and taps it, then pumps enough
/// frames to show any dialog.
Future<void> _tapSave(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.check));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('Angela-name warning dialog', () {
    testWidgets('saving "Angela" triggers the warning dialog', (tester) async {
      // Arrange
      final repo = FakeUserProfileRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(repo),
        ],
        child: const ProfileScreen(),
      ));
      await tester.pumpAndSettle();

      // Act — enter "Angela" into the name field and save.
      await tester.enterText(find.byType(TextField).first, 'Angela');
      await _tapSave(tester);

      // Assert — an AlertDialog appeared.
      check(find.byType(AlertDialog).evaluate().length).isGreaterOrEqual(1);
    });

    testWidgets(
        'saving "angela smith" (lowercase) triggers the warning dialog',
        (tester) async {
      // Arrange
      final repo = FakeUserProfileRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(repo),
        ],
        child: const ProfileScreen(),
      ));
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(find.byType(TextField).first, 'angela smith');
      await _tapSave(tester);

      // Assert
      check(find.byType(AlertDialog).evaluate().length).isGreaterOrEqual(1);
    });

    testWidgets('"Angelas" triggers the warning dialog', (tester) async {
      // Arrange
      final repo = FakeUserProfileRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(repo),
        ],
        child: const ProfileScreen(),
      ));
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(find.byType(TextField).first, 'Angelas');
      await _tapSave(tester);

      // Assert — matches \bangela[s]?\b
      check(find.byType(AlertDialog).evaluate().length).isGreaterOrEqual(1);
    });

    testWidgets('"Angelica" does NOT trigger the warning dialog',
        (tester) async {
      // Arrange
      final repo = FakeUserProfileRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(repo),
        ],
        child: const ProfileScreen(),
      ));
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(find.byType(TextField).first, 'Angelica');
      await _tapSave(tester);
      await tester.pumpAndSettle();

      // Assert — no AlertDialog.
      check(find.byType(AlertDialog).evaluate().length).equals(0);
    });

    testWidgets('"Angelo" does NOT trigger the warning dialog', (tester) async {
      // Arrange
      final repo = FakeUserProfileRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(repo),
        ],
        child: const ProfileScreen(),
      ));
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(find.byType(TextField).first, 'Angelo');
      await _tapSave(tester);
      await tester.pumpAndSettle();

      // Assert — no AlertDialog.
      check(find.byType(AlertDialog).evaluate().length).equals(0);
    });

    testWidgets('"ANGELA" (all caps) triggers the warning dialog',
        (tester) async {
      // Case-insensitive match.
      final repo = FakeUserProfileRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(repo),
        ],
        child: const ProfileScreen(),
      ));
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(find.byType(TextField).first, 'ANGELA');
      await _tapSave(tester);

      // Assert
      check(find.byType(AlertDialog).evaluate().length).isGreaterOrEqual(1);
    });

    testWidgets('dialog OK button dismisses dialog', (tester) async {
      // Arrange
      final repo = FakeUserProfileRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(repo),
        ],
        child: const ProfileScreen(),
      ));
      await tester.pumpAndSettle();

      // Show dialog.
      await tester.enterText(find.byType(TextField).first, 'Angela');
      await _tapSave(tester);
      check(find.byType(AlertDialog).evaluate().length).isGreaterOrEqual(1);

      // Act — tap the FilledButton inside the dialog (the OK button).
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // Assert — dialog dismissed.
      check(find.byType(AlertDialog).evaluate().length).equals(0);
    });
  });
}
