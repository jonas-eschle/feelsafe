/// Smoke tests for [BackupScreen] including export / import flows.
library;

import 'dart:convert';

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/features/backup/backup_service.dart';
import 'package:guardianangela/features/settings/backup_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

List<Override> _allRepoOverrides() => [
  modesRepositoryProvider.overrideWithValue(FakeModesRepository()),
  contactsRepositoryProvider.overrideWithValue(FakeContactsRepository()),
  templatesRepositoryProvider.overrideWithValue(FakeTemplatesRepository()),
  distressChainsRepositoryProvider
      .overrideWithValue(FakeDistressChainsRepository()),
  settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
  userProfileRepositoryProvider
      .overrideWithValue(FakeUserProfileRepository()),
  batteryAlertRepositoryProvider
      .overrideWithValue(FakeBatteryAlertRepository()),
  sessionLogsRepositoryProvider
      .overrideWithValue(FakeSessionLogsRepository()),
];

void main() {
  testWidgets('BackupScreen renders without throwing', (tester) async {
    await tester.pumpWidget(hostScreen(child: const BackupScreen()));
    await tester.pumpAndSettle();
    check(find.byType(BackupScreen).evaluate().length).equals(1);
    check(find.byType(AppBar).evaluate().length).equals(1);
  });

  testWidgets('BackupScreen shows a PIN field + export/import buttons',
      (tester) async {
    await tester.pumpWidget(hostScreen(child: const BackupScreen()));
    await tester.pumpAndSettle();
    check(find.byType(TextField).evaluate().length).equals(1);
    check(find.byType(FilledButton).evaluate().length).equals(1);
    check(find.byType(OutlinedButton).evaluate().length).equals(1);
  });

  testWidgets('BackupScreen PIN field accepts text', (tester) async {
    await tester.pumpWidget(hostScreen(child: const BackupScreen()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '1234');
    await tester.pump();
    check(find.text('1234').evaluate().length).equals(1);
  });

  testWidgets('BackupScreen export opens dialog with JSON payload',
      (tester) async {
    await tester.pumpWidget(hostScreen(
      overrides: _allRepoOverrides(),
      child: const BackupScreen(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    check(find.byType(AlertDialog).evaluate().length).equals(1);
    check(find.byType(SelectableText).evaluate().length).equals(1);
  });

  testWidgets('BackupScreen export dialog closes', (tester) async {
    await tester.pumpWidget(hostScreen(
      overrides: _allRepoOverrides(),
      child: const BackupScreen(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    check(find.byType(AlertDialog).evaluate()).isEmpty();
  });

  testWidgets('BackupScreen export with PIN produces encrypted payload',
      (tester) async {
    await tester.pumpWidget(hostScreen(
      overrides: _allRepoOverrides(),
      child: const BackupScreen(),
    ));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'pass');
    await tester.pump();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    // Encrypted envelope contains "encrypted": true.
    check(find.textContaining('"encrypted": true').evaluate().length)
        .equals(1);
  });

  testWidgets('BackupScreen import opens prompt dialog', (tester) async {
    await tester.pumpWidget(hostScreen(
      overrides: _allRepoOverrides(),
      child: const BackupScreen(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();
    check(find.byType(AlertDialog).evaluate().length).equals(1);
  });

  testWidgets('BackupScreen import with valid JSON shows success',
      (tester) async {
    await tester.pumpWidget(hostScreen(
      overrides: _allRepoOverrides(),
      child: const BackupScreen(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();
    final payload = jsonEncode({
      'version': kBackupVersion,
      'encrypted': false,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'modes': const <Map<String, Object?>>[],
      'contacts': const <Map<String, Object?>>[],
      'templates': const <Map<String, Object?>>[],
      'distressChains': const <Map<String, Object?>>[],
      'sessionLogs': const <Map<String, Object?>>[],
    });
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      payload,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
    await tester.pumpAndSettle();
    check(find.byType(SnackBar).evaluate().length).isGreaterOrEqual(1);
  });

  testWidgets('BackupScreen import cancels when prompt dialog is cancelled',
      (tester) async {
    await tester.pumpWidget(hostScreen(
      overrides: _allRepoOverrides(),
      child: const BackupScreen(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    check(find.byType(AlertDialog).evaluate()).isEmpty();
  });

  testWidgets('BackupScreen import with wrong version shows error',
      (tester) async {
    await tester.pumpWidget(hostScreen(
      overrides: _allRepoOverrides(),
      child: const BackupScreen(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      jsonEncode({'version': 9999, 'encrypted': false}),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
    await tester.pumpAndSettle();
    check(find.byType(SnackBar).evaluate().length).isGreaterOrEqual(1);
  });

  testWidgets('BackupScreen import with malformed JSON shows error',
      (tester) async {
    await tester.pumpWidget(hostScreen(
      overrides: _allRepoOverrides(),
      child: const BackupScreen(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'not-json',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
    await tester.pumpAndSettle();
    check(find.byType(SnackBar).evaluate().length).isGreaterOrEqual(1);
  });

  testWidgets('BackupScreen import with PIN-needed payload shows error',
      (tester) async {
    await tester.pumpWidget(hostScreen(
      overrides: _allRepoOverrides(),
      child: const BackupScreen(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();
    // Encrypted payload with no PIN set -> BackupFormatError branch.
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      jsonEncode({
        'version': kBackupVersion,
        'encrypted': true,
        'salt': 'AA==',
        'nonce': 'AA==',
        'tag': 'AA==',
        'ciphertext': 'AA==',
      }),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
    await tester.pumpAndSettle();
    check(find.byType(SnackBar).evaluate().length).isGreaterOrEqual(1);
  });

  testWidgets('BackupScreen import with empty text is a no-op',
      (tester) async {
    await tester.pumpWidget(hostScreen(
      overrides: _allRepoOverrides(),
      child: const BackupScreen(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
    await tester.pumpAndSettle();
    // No snackbar should appear since text was empty.
    check(find.byType(SnackBar).evaluate()).isEmpty();
  });
}
