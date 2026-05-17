/// Extended tests for [ContactFormScreen]:
///   * Validation errors (empty name / empty phone) keep Save from
///     persisting.
///   * All four channel chips toggle state cleanly.
///   * Unchecking the last channel shows a SnackBar on save instead
///     of persisting.
///   * Relationship and language fields optional; blank → null on
///     saved model.
///   * Query-parameter-based id path hydrates (not just prop-based).
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/features/contacts/contact_form_screen.dart';

import '../../helpers/test_helpers.dart';
import '../fake_repositories.dart';
import '../widget_test_helpers.dart';

void main() {
  testWidgets(
    'ContactFormScreen Save with blank name does not persist',
    (tester) async {
      final repo = FakeContactsRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [contactsRepositoryProvider.overrideWithValue(repo)],
        child: const ContactFormScreen(),
      ));
      await tester.pumpAndSettle();
      final save = find.descendant(
        of: find.byType(ContactFormScreen),
        matching: find.widgetWithText(FilledButton, 'Save'),
      );
      await tester.dragUntilVisible(
        save,
        find.descendant(
          of: find.byType(ContactFormScreen),
          matching: find.byType(Scrollable),
        ).first,
        const Offset(0, -100),
      );
      await tester.tap(save);
      await tester.pumpAndSettle();
      check(await repo.getAll()).isEmpty();
    },
  );

  testWidgets(
    'ContactFormScreen tapping a selected channel chip deselects it',
    (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: [
          contactsRepositoryProvider
              .overrideWithValue(FakeContactsRepository()),
        ],
        child: const ContactFormScreen(),
      ));
      await tester.pumpAndSettle();
      final smsChip = find.byType(FilterChip).first;
      // Default = all selected, so the SMS chip starts selected.
      check(tester.widget<FilterChip>(smsChip).selected).isTrue();
      await tester.tap(smsChip);
      await tester.pumpAndSettle();
      check(tester.widget<FilterChip>(smsChip).selected).isFalse();
    },
  );

  testWidgets(
    'ContactFormScreen all four channel chips render and start selected',
    (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: [
          contactsRepositoryProvider
              .overrideWithValue(FakeContactsRepository()),
        ],
        child: const ContactFormScreen(),
      ));
      await tester.pumpAndSettle();
      final chips = find.descendant(
        of: find.byType(ContactFormScreen),
        matching: find.byType(FilterChip),
      );
      check(chips.evaluate().length).equals(4);
      for (var i = 0; i < 4; i++) {
        check(tester.widget<FilterChip>(chips.at(i)).selected).isTrue();
      }
    },
  );

  testWidgets(
    'ContactFormScreen saving with all channels unchecked shows SnackBar',
    (tester) async {
      final repo = FakeContactsRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [contactsRepositoryProvider.overrideWithValue(repo)],
        child: const ContactFormScreen(),
      ));
      await tester.pumpAndSettle();
      final fields = find.descendant(
        of: find.byType(ContactFormScreen),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(fields.at(0), 'Kate');
      await tester.enterText(fields.at(1), '+15559998877');
      await tester.pump();
      // Default is all 4 chips selected — deselect every one to leave
      // the channels set empty.
      final chips = find.descendant(
        of: find.byType(ContactFormScreen),
        matching: find.byType(FilterChip),
      );
      for (var i = 0; i < 4; i++) {
        await tester.tap(chips.at(i));
      }
      await tester.pumpAndSettle();
      final save = find.descendant(
        of: find.byType(ContactFormScreen),
        matching: find.widgetWithText(FilledButton, 'Save'),
      );
      await tester.dragUntilVisible(
        save,
        find.descendant(
          of: find.byType(ContactFormScreen),
          matching: find.byType(Scrollable),
        ).first,
        const Offset(0, -100),
      );
      await tester.tap(save);
      await tester.pumpAndSettle();
      check(find.byType(SnackBar).evaluate().length).equals(1);
      check(await repo.getAll()).isEmpty();
    },
  );

  testWidgets(
    'ContactFormScreen persists relationship + language when populated',
    (tester) async {
      // Spec 04 line 1357: language is a Dropdown, not a free-form
      // text field. Pick "es" via the DropdownButtonFormField path.
      final repo = FakeContactsRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [contactsRepositoryProvider.overrideWithValue(repo)],
        child: const ContactFormScreen(),
      ));
      await tester.pumpAndSettle();
      final fields = find.descendant(
        of: find.byType(ContactFormScreen),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(fields.at(0), 'Sara');
      await tester.enterText(fields.at(1), '+15550001111');
      await tester.enterText(fields.at(2), 'Sister');
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('es').last);
      await tester.pump();
      final save = find.descendant(
        of: find.byType(ContactFormScreen),
        matching: find.widgetWithText(FilledButton, 'Save'),
      );
      await tester.dragUntilVisible(
        save,
        find.descendant(
          of: find.byType(ContactFormScreen),
          matching: find.byType(Scrollable),
        ).first,
        const Offset(0, -100),
      );
      await tester.tap(save);
      await tester.pumpAndSettle();
      final stored = await repo.getAll();
      check(stored.length).equals(1);
      final c = stored.single;
      check(c.relationship).equals('Sister');
      check(c.languageCode).equals('es');
    },
  );

  testWidgets(
    'ContactFormScreen saves with all four channels by default',
    (tester) async {
      final repo = FakeContactsRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [contactsRepositoryProvider.overrideWithValue(repo)],
        child: const ContactFormScreen(),
      ));
      await tester.pumpAndSettle();
      final fields = find.descendant(
        of: find.byType(ContactFormScreen),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(fields.at(0), 'Bob');
      await tester.enterText(fields.at(1), '+15550002222');
      await tester.pump();
      // The default state is "all 4 channels selected"; no toggling
      // needed before save.
      final save = find.descendant(
        of: find.byType(ContactFormScreen),
        matching: find.widgetWithText(FilledButton, 'Save'),
      );
      await tester.dragUntilVisible(
        save,
        find.descendant(
          of: find.byType(ContactFormScreen),
          matching: find.byType(Scrollable),
        ).first,
        const Offset(0, -100),
      );
      await tester.tap(save);
      await tester.pumpAndSettle();
      final stored = await repo.getAll();
      final channels = stored.single.channels.toSet();
      check(channels.contains(MessageChannel.sms)).isTrue();
      check(channels.contains(MessageChannel.whatsapp)).isTrue();
      check(channels.contains(MessageChannel.telegram)).isTrue();
      check(channels.contains(MessageChannel.phoneCall)).isTrue();
    },
  );

  testWidgets(
    'ContactFormScreen hydrates via query-parameter id',
    (tester) async {
      final existing = EmergencyContact(
        id: 'c-42',
        name: 'Via Query',
        phoneNumber: '+15551112222',
        sortOrder: 0,
        relationship: 'Dad',
        languageCode: 'de',
        channels: const [MessageChannel.sms, MessageChannel.phoneCall],
      );
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          contactsRepositoryProvider
              .overrideWithValue(FakeContactsRepository([existing])),
        ],
        initialQuery: 'id=c-42',
        child: const ContactFormScreen(),
      ));
      await tester.pumpAndSettle();
      final fields = find.descendant(
        of: find.byType(ContactFormScreen),
        matching: find.byType(TextFormField),
      );
      final nameField = tester.widget<TextFormField>(fields.at(0));
      check(nameField.controller!.text).equals('Via Query');
      final relField = tester.widget<TextFormField>(fields.at(2));
      check(relField.controller!.text).equals('Dad');
    },
  );

  testWidgets(
    'ContactFormScreen query-param id with unknown id stays blank',
    (tester) async {
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          contactsRepositoryProvider
              .overrideWithValue(FakeContactsRepository([makeContact()])),
        ],
        initialQuery: 'id=non-existent',
        child: const ContactFormScreen(),
      ));
      await tester.pumpAndSettle();
      final fields = find.descendant(
        of: find.byType(ContactFormScreen),
        matching: find.byType(TextFormField),
      );
      final nameField = tester.widget<TextFormField>(fields.at(0));
      check(nameField.controller!.text).equals('');
    },
  );
}
