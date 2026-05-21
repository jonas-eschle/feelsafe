/// Smoke tests for [TemplateEditorScreen].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/templates/template_editor_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  testWidgets('TemplateEditorScreen renders a blank form for creation', (
    tester,
  ) async {
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: [
          templatesRepositoryProvider.overrideWithValue(
            FakeTemplatesRepository(),
          ),
        ],
        child: const TemplateEditorScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(TemplateEditorScreen).evaluate().length).equals(1);
    check(find.byType(AppBar).evaluate().length).equals(1);
  });

  testWidgets('TemplateEditorScreen shows TextField inputs', (tester) async {
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: [
          templatesRepositoryProvider.overrideWithValue(
            FakeTemplatesRepository(),
          ),
        ],
        child: const TemplateEditorScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(TextField).evaluate().length).isGreaterThan(1);
  });

  testWidgets(
    'TemplateEditorScreen hydrates fields when editing an existing template',
    (tester) async {
      final existing = ReminderTemplate(
        id: 't1',
        name: 'Calendar',
        title: 'Meeting',
        body: 'Body text',
        confirmationType: ConfirmationType.tapButton,
        displayStyle: ReminderDisplayStyle.fullScreen,
        isGlobal: true,
        keyword: 'ok',
        buttonLabel: 'Dismiss',
      );
      await tester.pumpWidget(
        hostScreenPushed(
          overrides: [
            templatesRepositoryProvider.overrideWithValue(
              FakeTemplatesRepository([existing]),
            ),
          ],
          initialQuery: 'id=t1',
          child: const TemplateEditorScreen(),
        ),
      );
      await tester.pumpAndSettle();
      final fields = find.byType(TextField);
      final nameField = tester.widget<TextField>(fields.at(0));
      check(nameField.controller!.text).equals('Calendar');
      final titleField = tester.widget<TextField>(fields.at(1));
      check(titleField.controller!.text).equals('Meeting');
    },
  );

  testWidgets('TemplateEditorScreen save persists a new template', (
    tester,
  ) async {
    final repo = FakeTemplatesRepository();
    await tester.pumpWidget(
      hostScreenPushed(
        overrides: [templatesRepositoryProvider.overrideWithValue(repo)],
        child: const TemplateEditorScreen(),
      ),
    );
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Custom');
    await tester.enterText(fields.at(1), 'T');
    await tester.enterText(fields.at(2), 'B');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();
    final saved = await repo.getAll();
    check(saved.length).equals(1);
    check(saved.single.name).equals('Custom');
    check(saved.single.title).equals('T');
  });

  testWidgets(
    'TemplateEditorScreen empty name falls back to default "Template"',
    (tester) async {
      final repo = FakeTemplatesRepository();
      await tester.pumpWidget(
        hostScreenPushed(
          overrides: [templatesRepositoryProvider.overrideWithValue(repo)],
          child: const TemplateEditorScreen(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();
      final saved = await repo.getAll();
      check(saved.single.name).equals('Template');
    },
  );
}
