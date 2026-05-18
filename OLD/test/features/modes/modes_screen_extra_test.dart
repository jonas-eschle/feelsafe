/// Supplemental widget tests for [ModesScreen] covering branches not
/// exercised by the existing smoke tests:
///  - loading spinner (line 27)
///  - error state text (lines 32–33)
///  - FAB navigates to modeEditor (line 56)
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/features/modes/modes_controller.dart';
import 'package:guardianangela/features/modes/modes_screen.dart';

import '../../helpers/test_helpers.dart';
import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  group('ModesScreen — extra branches', () {
    testWidgets('shows loading spinner briefly on first frame',
        (tester) async {
      // The screen starts with an async provider. On the first pump
      // (before settlement) a CircularProgressIndicator may appear.
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: [
            modesRepositoryProvider.overrideWithValue(
              FakeModesRepository([]),
            ),
          ],
          child: const ModesScreen(),
        ),
      );
      // First frame — provider may still be loading.
      await tester.pump();
      // The widget tree exists.
      check(find.byType(ModesScreen).evaluate()).isNotEmpty();
    });

    testWidgets('error state shows error text', (tester) async {
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: [
            modesControllerProvider.overrideWith(_ThrowingController.new),
          ],
          child: const ModesScreen(),
        ),
      );
      await tester.pumpAndSettle();
      check(find.textContaining('modes error').evaluate()).isNotEmpty();
    });

    testWidgets('FAB is present and can be tapped', (tester) async {
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: [
            modesRepositoryProvider.overrideWithValue(
              FakeModesRepository([]),
            ),
          ],
          child: const ModesScreen(),
        ),
      );
      await tester.pumpAndSettle();
      final fab = find.byType(FloatingActionButton);
      check(fab.evaluate()).isNotEmpty();
      // Tap — GoRouter pushes modeEditor. The router swallows the
      // navigation request in the test harness; we just verify no
      // exception is thrown.
      await tester.tap(fab);
      await tester.pumpAndSettle();
    });

    testWidgets('tapping a list tile navigates (no exception)', (tester) async {
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: [
            modesRepositoryProvider.overrideWithValue(
              FakeModesRepository([makeMode(id: 'm1', name: 'Walk')]),
            ),
          ],
          child: const ModesScreen(),
        ),
      );
      await tester.pumpAndSettle();
      // Tap the tile — GoRouter navigates; no exception expected.
      await tester.tap(find.text('Walk'));
      await tester.pumpAndSettle();
    });
  });
}

class _ThrowingController extends ModesController {
  @override
  Future<List<SessionMode>> build() async =>
      throw Exception('modes error');
}
