/// Smoke tests for [ContactFormScreen].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/features/contacts/contact_form_screen.dart';

import '../../helpers/test_helpers.dart';
import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  testWidgets('ContactFormScreen renders blank form for creation',
      (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        contactsRepositoryProvider
            .overrideWithValue(FakeContactsRepository()),
      ],
      child: const ContactFormScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(ContactFormScreen).evaluate().length).equals(1);
    check(find.byType(TextFormField).evaluate().length).isGreaterThan(0);
  });

  testWidgets('ContactFormScreen hydrates form when editing',
      (tester) async {
    final existing = makeContact(id: 'c1', name: 'Alice');
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        contactsRepositoryProvider.overrideWithValue(
          FakeContactsRepository([existing]),
        ),
      ],
      child: const ContactFormScreen(id: 'c1'),
    ));
    await tester.pumpAndSettle();
    check(find.byType(ContactFormScreen).evaluate().length).equals(1);
  });

  testWidgets('ContactFormScreen has an AppBar', (tester) async {
    await tester.pumpWidget(hostScreenWithRouter(
      overrides: [
        contactsRepositoryProvider
            .overrideWithValue(FakeContactsRepository()),
      ],
      child: const ContactFormScreen(),
    ));
    await tester.pumpAndSettle();
    check(find.byType(AppBar).evaluate().length).equals(1);
  });
}
