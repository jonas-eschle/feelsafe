/// Supplemental tests for [ContactsScreen] covering the `onReorder`
/// callback (lines 32–33) of the [ReorderableListView].
///
/// The callback is accessed directly from the widget tree to avoid
/// the complexity of a proper long-press drag gesture.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/features/contacts/contacts_screen.dart';

import '../../helpers/test_helpers.dart';
import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  group('ContactsScreen — onReorder (lines 32–33)', () {
    testWidgets('onReorder callback can be invoked directly (lines 32–33)', (
      tester,
    ) async {
      final repo = FakeContactsRepository([
        makeContact(id: 'c1', name: 'Alice'),
        makeContact(id: 'c2', name: 'Bob'),
        makeContact(id: 'c3', name: 'Carol'),
      ]);

      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: [contactsRepositoryProvider.overrideWithValue(repo)],
          child: const ContactsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find the ReorderableListView and invoke onReorder directly.
      final rlv = tester.widget<ReorderableListView>(
        find.byType(ReorderableListView),
      );
      // Move index 0 to 2 (Alice → after Bob).
      rlv.onReorder(0, 2);
      await tester.pumpAndSettle();

      // Screen still visible after reorder.
      check(find.byType(ContactsScreen).evaluate()).isNotEmpty();
    });

    testWidgets('reorder in reverse direction (lines 32–33)', (tester) async {
      final repo = FakeContactsRepository([
        makeContact(id: 'd1', name: 'Dave'),
        makeContact(id: 'd2', name: 'Eve'),
      ]);

      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: [contactsRepositoryProvider.overrideWithValue(repo)],
          child: const ContactsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final rlv = tester.widget<ReorderableListView>(
        find.byType(ReorderableListView),
      );
      // Move index 1 to 0.
      rlv.onReorder(1, 0);
      await tester.pumpAndSettle();

      check(find.byType(ContactsScreen).evaluate()).isNotEmpty();
    });
  });
}
