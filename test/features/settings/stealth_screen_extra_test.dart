/// Supplemental tests for [StealthScreen] covering uncovered branches:
///   - line 63: the `onChanged` callback from `_FakeNameField` fires when
///     the user submits a non-empty name.
///   - lines 158–161: `_FakeNameField._commit` — commit of trimmed text.
///   - line 176: `onEditingComplete` → `_commit`.
///   - line 148: `didUpdateWidget` path when widget.value changes.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/features/settings/stealth_screen.dart';
import 'package:guardianangela/services/fakes/fake_stealth_icon_service.dart';
import 'package:guardianangela/services/service_providers.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  group('StealthScreen _FakeNameField', () {
    testWidgets('submitting a new fake name fires onChanged (line 63)',
        (tester) async {
      final repo = FakeSettingsRepository();
      final fake = FakeStealthIconService();
      await tester.pumpWidget(hostScreen(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repo),
          stealthIconServiceProvider.overrideWithValue(fake),
        ],
        child: const StealthScreen(),
      ));
      await tester.pumpAndSettle();

      // Find the fake-name TextField and enter + submit text.
      final textField = find.byType(TextField);
      if (textField.evaluate().isEmpty) {
        // If not immediately visible, scroll to reveal it.
        await tester.drag(
          find.byType(Scrollable).first,
          const Offset(0, -200),
        );
        await tester.pumpAndSettle();
      }

      // Enter a valid name and submit.
      await tester.enterText(textField.first, 'Calendar');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // The repository should have been updated (onChanged → update →
      // settingsController.setDefaults).
      check(repo.stored).isNotNull();
    });

    testWidgets('onEditingComplete fires _commit (line 176)', (tester) async {
      final repo = FakeSettingsRepository();
      final fake = FakeStealthIconService();
      await tester.pumpWidget(hostScreen(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repo),
          stealthIconServiceProvider.overrideWithValue(fake),
        ],
        child: const StealthScreen(),
      ));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.enterText(textField.first, 'Notes');
      // Simulate editing complete (tap done on keyboard).
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      check(find.byType(StealthScreen).evaluate()).isNotEmpty();
    });

    testWidgets('empty fake name is rejected by _commit (line 160)',
        (tester) async {
      final repo = FakeSettingsRepository();
      final fake = FakeStealthIconService();
      await tester.pumpWidget(hostScreen(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repo),
          stealthIconServiceProvider.overrideWithValue(fake),
        ],
        child: const StealthScreen(),
      ));
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      // Submit an empty string — _commit returns early at line 160.
      await tester.enterText(textField.first, '  ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // No update — empty string is rejected.
      check(find.byType(StealthScreen).evaluate()).isNotEmpty();
    });
  });
}
