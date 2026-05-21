/// Smoke tests for [TemplatesScreen].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/templates/templates_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

ReminderTemplate _t(String id) => ReminderTemplate(
  id: id,
  name: id,
  title: 'title',
  body: 'body',
  confirmationType: ConfirmationType.dismiss,
  displayStyle: ReminderDisplayStyle.fullScreen,
  isGlobal: true,
);

void main() {
  testWidgets('TemplatesScreen renders empty state', (tester) async {
    await tester.pumpWidget(
      hostScreen(
        overrides: [
          templatesRepositoryProvider.overrideWithValue(
            FakeTemplatesRepository(),
          ),
        ],
        child: const TemplatesScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(TemplatesScreen).evaluate().length).equals(1);
  });

  testWidgets('TemplatesScreen renders each template', (tester) async {
    await tester.pumpWidget(
      hostScreen(
        overrides: [
          templatesRepositoryProvider.overrideWithValue(
            FakeTemplatesRepository([_t('cal'), _t('duo')]),
          ),
        ],
        child: const TemplatesScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.text('cal').evaluate().length).equals(1);
    check(find.text('duo').evaluate().length).equals(1);
  });

  testWidgets('TemplatesScreen delete icon removes template', (tester) async {
    final repo = FakeTemplatesRepository([_t('x')]);
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: [templatesRepositoryProvider.overrideWithValue(repo)],
        child: const TemplatesScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    check(await repo.getAll()).isEmpty();
  });
}
