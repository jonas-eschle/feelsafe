/// Coverage filler for [TemplateEditorScreen]:
///   * ConfirmationType dropdown onChanged (lines 139-140).
///   * ReminderDisplayStyle dropdown onChanged (lines 156-157).
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/enums.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/features/templates/template_editor_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  testWidgets(
    'TemplateEditorScreen ConfirmationType dropdown change persists on save',
    (tester) async {
      final repo = FakeTemplatesRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [templatesRepositoryProvider.overrideWithValue(repo)],
        child: const TemplateEditorScreen(),
      ));
      await tester.pumpAndSettle();
      // First dropdown is ConfirmationType.
      final confirm = find.byType(DropdownButtonFormField<ConfirmationType>);
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      // Tap a menu entry by its rendered text. The popup appends the
      // option text nodes; the existing closed-state entry remains
      // in the tree, so pick `.last` to reliably grab the menu copy.
      await tester.tap(find.text('Tap word').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Test');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();
      final saved = await repo.getAll();
      check(saved.single.confirmationType).equals(ConfirmationType.tapWord);
    },
  );

  testWidgets(
    'TemplateEditorScreen DisplayStyle dropdown change persists on save',
    (tester) async {
      final repo = FakeTemplatesRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [templatesRepositoryProvider.overrideWithValue(repo)],
        child: const TemplateEditorScreen(),
      ));
      await tester.pumpAndSettle();
      final display = find.byType(
        DropdownButtonFormField<ReminderDisplayStyle>,
      );
      await tester.tap(display);
      await tester.pumpAndSettle();
      // Pick fullScreen option from the popup.
      await tester.tap(find.text('Full screen').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Test');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();
      final saved = await repo.getAll();
      check(saved.single.displayStyle).equals(ReminderDisplayStyle.fullScreen);
    },
  );

  testWidgets(
    'TemplateEditorScreen button-label text field persists for tapButton',
    (tester) async {
      // Default confirmation type is tapButton; the button-label
      // field is the only conditional field shown.
      final repo = FakeTemplatesRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [templatesRepositoryProvider.overrideWithValue(repo)],
        child: const TemplateEditorScreen(),
      ));
      await tester.pumpAndSettle();
      final fields = find.byType(TextField);
      // Fields: 0=name, 1=title, 2=body, 3=buttonLabel (only
      // for tapButton, which is the default).
      await tester.enterText(fields.at(0), 'K');
      await tester.enterText(fields.at(3), 'Btn');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();
      final saved = await repo.getAll();
      check(saved.single.buttonLabel).equals('Btn');
    },
  );

  testWidgets(
    'TemplateEditorScreen keyword text field persists for tapWord',
    (tester) async {
      final repo = FakeTemplatesRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [templatesRepositoryProvider.overrideWithValue(repo)],
        child: const TemplateEditorScreen(),
      ));
      await tester.pumpAndSettle();
      // Switch to tapWord so the keyword field appears.
      final confirm = find.byType(DropdownButtonFormField<ConfirmationType>);
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tap word').last);
      await tester.pumpAndSettle();
      final fields = find.byType(TextField);
      // Fields: 0=name, 1=title, 2=body, 3=keyword.
      await tester.enterText(fields.at(0), 'K');
      await tester.enterText(fields.at(3), 'keyword');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();
      final saved = await repo.getAll();
      check(saved.single.keyword).equals('keyword');
    },
  );
}
