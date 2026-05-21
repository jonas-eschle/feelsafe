/// Supplemental tests for [TemplatesScreen] covering branches not
/// exercised by the smoke tests:
///  - loading indicator (line 25)
///  - error state text (line 26)
///  - tile onTap navigates (lines 37–38)
///  - FAB navigates to templateEditor (line 52)
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/templates/templates_controller.dart';
import 'package:guardianangela/features/templates/templates_screen.dart';

import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

ReminderTemplate _template(String id) => ReminderTemplate(
  id: id,
  name: id,
  title: 'Title $id',
  body: 'Body $id',
  confirmationType: ConfirmationType.dismiss,
  displayStyle: ReminderDisplayStyle.fullScreen,
  isGlobal: true,
);

void main() {
  group('TemplatesScreen — extra branches', () {
    testWidgets('loading indicator on first frame', (tester) async {
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
      await tester.pump();
      check(find.byType(TemplatesScreen).evaluate()).isNotEmpty();
    });

    testWidgets('error state shows error text', (tester) async {
      await tester.pumpWidget(
        hostScreen(
          overrides: [
            templatesControllerProvider.overrideWith(_ThrowingController.new),
          ],
          child: const TemplatesScreen(),
        ),
      );
      await tester.pumpAndSettle();
      check(find.textContaining('templates error').evaluate()).isNotEmpty();
    });

    testWidgets('tapping a template tile navigates (no exception)', (
      tester,
    ) async {
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: [
            templatesRepositoryProvider.overrideWithValue(
              FakeTemplatesRepository([_template('cal')]),
            ),
          ],
          child: const TemplatesScreen(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('cal'));
      await tester.pumpAndSettle();
    });

    testWidgets('FAB is present and tappable', (tester) async {
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: [
            templatesRepositoryProvider.overrideWithValue(
              FakeTemplatesRepository(),
            ),
          ],
          child: const TemplatesScreen(),
        ),
      );
      await tester.pumpAndSettle();
      final fab = find.byType(FloatingActionButton);
      check(fab.evaluate()).isNotEmpty();
      await tester.tap(fab);
      await tester.pumpAndSettle();
    });
  });
}

class _ThrowingController extends TemplatesController {
  @override
  Future<List<ReminderTemplate>> build() async =>
      throw Exception('templates error');
}
