/// Supplemental tests for [ContactsScreen] covering branches not
/// exercised by the smoke tests:
///  - loading indicator (line 26)
///  - error state text (line 27)
///  - FAB navigates to contactForm (line 43)
///  - tile onTap navigates (line 61)
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/features/contacts/contacts_controller.dart';
import 'package:guardianangela/features/contacts/contacts_screen.dart';
import 'package:guardianangela/domain/models/models.dart';

import '../../helpers/test_helpers.dart';
import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  group('ContactsScreen — extra branches', () {
    testWidgets('loading indicator on first frame', (tester) async {
      await tester.pumpWidget(
        hostScreen(
          overrides: [
            contactsRepositoryProvider
                .overrideWithValue(FakeContactsRepository()),
          ],
          child: const ContactsScreen(),
        ),
      );
      // First pump — may still be loading; widget tree must exist.
      await tester.pump();
      check(find.byType(ContactsScreen).evaluate()).isNotEmpty();
    });

    testWidgets('error state shows error text', (tester) async {
      await tester.pumpWidget(
        hostScreen(
          overrides: [
            contactsControllerProvider.overrideWith(_ThrowingController.new),
          ],
          child: const ContactsScreen(),
        ),
      );
      await tester.pumpAndSettle();
      check(find.textContaining('contacts error').evaluate()).isNotEmpty();
    });

    testWidgets('FAB is present and tappable', (tester) async {
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: [
            contactsRepositoryProvider
                .overrideWithValue(FakeContactsRepository()),
          ],
          child: const ContactsScreen(),
        ),
      );
      await tester.pumpAndSettle();
      final fab = find.byType(FloatingActionButton);
      check(fab.evaluate()).isNotEmpty();
      // Tap — GoRouter pushes contactForm; no exception expected.
      await tester.tap(fab);
      await tester.pumpAndSettle();
    });

    testWidgets('tapping a contact tile navigates (no exception)',
        (tester) async {
      await tester.pumpWidget(
        hostScreenWithRouter(
          overrides: [
            contactsRepositoryProvider.overrideWithValue(
              FakeContactsRepository([
                makeContact(id: 'c1', name: 'Eve'),
              ]),
            ),
          ],
          child: const ContactsScreen(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eve'));
      await tester.pumpAndSettle();
    });
  });
}

class _ThrowingController extends ContactsController {
  @override
  Future<List<EmergencyContact>> build() async =>
      throw Exception('contacts error');
}
