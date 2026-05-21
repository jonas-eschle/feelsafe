/// Smoke tests for [ContactsScreen] — renders, shows empty text
/// when list is empty, and renders a list tile per contact.
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
  testWidgets('ContactsScreen shows empty text with no contacts', (
    tester,
  ) async {
    await tester.pumpWidget(
      hostScreen(
        overrides: [
          contactsRepositoryProvider.overrideWithValue(
            FakeContactsRepository(),
          ),
        ],
        child: const ContactsScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(ContactsScreen).evaluate().length).equals(1);
  });

  testWidgets('ContactsScreen renders list tile per contact', (tester) async {
    await tester.pumpWidget(
      hostScreen(
        overrides: [
          contactsRepositoryProvider.overrideWithValue(
            FakeContactsRepository([
              makeContact(id: 'c1', name: 'Alice'),
              makeContact(id: 'c2', name: 'Bob'),
            ]),
          ),
        ],
        child: const ContactsScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(ListTile).evaluate().length).isGreaterThan(0);
    check(find.text('Alice').evaluate().length).equals(1);
    check(find.text('Bob').evaluate().length).equals(1);
  });

  testWidgets('ContactsScreen shows a FAB to add a new contact', (
    tester,
  ) async {
    await tester.pumpWidget(
      hostScreen(
        overrides: [
          contactsRepositoryProvider.overrideWithValue(
            FakeContactsRepository(),
          ),
        ],
        child: const ContactsScreen(),
      ),
    );
    await tester.pumpAndSettle();
    check(find.byType(FloatingActionButton).evaluate().length).equals(1);
  });

  testWidgets('ContactsScreen delete dialog cancel button leaves contact', (
    tester,
  ) async {
    final repo = FakeContactsRepository([makeContact(id: 'c1', name: 'A')]);
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: [contactsRepositoryProvider.overrideWithValue(repo)],
        child: const ContactsScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    check((await repo.getAll()).length).equals(1);
  });

  testWidgets('ContactsScreen delete dialog confirm removes contact', (
    tester,
  ) async {
    final repo = FakeContactsRepository([makeContact(id: 'c1', name: 'A')]);
    await tester.pumpWidget(
      hostScreenWithRouter(
        overrides: [contactsRepositoryProvider.overrideWithValue(repo)],
        child: const ContactsScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    check(await repo.getAll()).isEmpty();
  });
}
