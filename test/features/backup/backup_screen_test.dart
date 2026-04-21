/// Smoke tests for [BackupScreen].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/features/settings/backup_screen.dart';

import '../widget_test_helpers.dart';

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
}
