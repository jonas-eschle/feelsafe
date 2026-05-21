/// Smoke tests for [ReminderTemplatesScreen] — proxies TemplatesScreen.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/features/settings/reminder_templates_screen.dart';
import 'package:guardianangela/features/templates/templates_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  testWidgets('ReminderTemplatesScreen renders the TemplatesScreen proxy', (
    tester,
  ) async {
    await tester.pumpWidget(
      hostScreen(
        overrides: [
          templatesRepositoryProvider.overrideWithValue(
            FakeTemplatesRepository(),
          ),
        ],
        child: const ReminderTemplatesScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(ReminderTemplatesScreen).evaluate().length).equals(1);
    check(find.byType(TemplatesScreen).evaluate().length).equals(1);
  });
}
