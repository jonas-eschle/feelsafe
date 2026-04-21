/// Smoke tests for [TemplateEditorScreen].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/features/templates/template_editor_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  testWidgets('TemplateEditorScreen renders a blank form for creation',
      (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        templatesRepositoryProvider
            .overrideWithValue(FakeTemplatesRepository()),
      ],
      child: const TemplateEditorScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(TemplateEditorScreen).evaluate().length).equals(1);
    check(find.byType(AppBar).evaluate().length).equals(1);
  });

  testWidgets('TemplateEditorScreen shows TextField inputs', (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        templatesRepositoryProvider
            .overrideWithValue(FakeTemplatesRepository()),
      ],
      child: const TemplateEditorScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(TextField).evaluate().length).isGreaterThan(1);
  });
}
