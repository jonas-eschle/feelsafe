/// Coverage filler for [BackupScreen]:
///   * Export throws → Snackbar path (lines 89-92).
///   * Import with mismatched PIN → BackupAuthenticationError branch
///     (lines 116-119).
library;

import 'dart:convert';

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/modes_repository.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/backup/backup_service.dart';
import 'package:guardianangela/features/settings/backup_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

class _ThrowingModes extends ModesRepository {
  _ThrowingModes() : super.forTesting();
  @override
  Future<List<SessionMode>> getAll() async {
    throw StateError('export-failed');
  }
}

List<Override> _allRepoOverrides({ModesRepository? modes}) => [
  modesRepositoryProvider.overrideWithValue(modes ?? FakeModesRepository()),
  contactsRepositoryProvider.overrideWithValue(FakeContactsRepository()),
  templatesRepositoryProvider.overrideWithValue(FakeTemplatesRepository()),
  settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
  userProfileRepositoryProvider
      .overrideWithValue(FakeUserProfileRepository()),
  batteryAlertRepositoryProvider
      .overrideWithValue(FakeBatteryAlertRepository()),
  sessionLogsRepositoryProvider
      .overrideWithValue(FakeSessionLogsRepository()),
];

void main() {
  testWidgets(
    'BackupScreen export throws → renders a SnackBar with error',
    (tester) async {
      await tester.pumpWidget(hostScreen(
        overrides: _allRepoOverrides(modes: _ThrowingModes()),
        child: const BackupScreen(),
      ));
      await tester.pumpAndSettle();
      await tester.dragUntilVisible(
        find.byType(FilledButton),
        find.byType(SingleChildScrollView).first,
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      // A SnackBar should surface the thrown StateError.
      check(find.byType(SnackBar).evaluate().length).isGreaterOrEqual(1);
      check(find.textContaining('export-failed').evaluate().length)
          .isGreaterOrEqual(1);
    },
  );

  testWidgets(
    'BackupScreen import with mismatched PIN hits auth-error branch',
    (tester) async {
      // First export with PIN "secret" so we have an encrypted payload
      // we can replay with a WRONG PIN and trigger the auth-error
      // branch (BackupAuthenticationError).
      await tester.pumpWidget(hostScreen(
        overrides: _allRepoOverrides(),
        child: const BackupScreen(),
      ));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'secret');
      await tester.pump();
      await tester.dragUntilVisible(
        find.byType(FilledButton),
        find.byType(SingleChildScrollView).first,
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      // Copy the displayed encrypted payload.
      final encrypted = (tester.widget<SelectableText>(
        find.byType(SelectableText),
      ).data)!;
      // Close the dialog.
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      // Now enter a WRONG PIN and import the payload we captured.
      await tester.enterText(find.byType(TextField), 'wrong');
      await tester.pump();
      await tester.dragUntilVisible(
        find.byType(OutlinedButton),
        find.byType(SingleChildScrollView).first,
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        encrypted,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
      await tester.pumpAndSettle();
      check(find.byType(SnackBar).evaluate().length).isGreaterOrEqual(1);
    },
  );

  testWidgets(
    'BackupScreen import with malformed encrypted payload hits format branch',
    (tester) async {
      await tester.pumpWidget(hostScreen(
        overrides: _allRepoOverrides(),
        child: const BackupScreen(),
      ));
      await tester.pumpAndSettle();
      // No PIN; import an encrypted-flagged but missing-fields payload.
      await tester.dragUntilVisible(
        find.byType(OutlinedButton),
        find.byType(SingleChildScrollView).first,
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        jsonEncode({
          'version': kBackupVersion,
          'encrypted': true,
          // missing salt/nonce/tag/ciphertext triggers format error
        }),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
      await tester.pumpAndSettle();
      check(find.byType(SnackBar).evaluate().length).isGreaterOrEqual(1);
    },
  );
}
