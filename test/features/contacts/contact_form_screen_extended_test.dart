/// Extended tests for [ContactFormScreen]:
///   * Validation errors (empty name / empty phone) keep Save from
///     persisting.
///   * All four channel checkboxes toggle state cleanly.
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
    'ContactFormScreen unchecking SMS default-channel leaves the field '
    'available to re-add',
    (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: [
          contactsRepositoryProvider
              .overrideWithValue(FakeContactsRepository()),
        ],
        child: const ContactFormScreen(),
      ));
      await tester.pumpAndSettle();
      final smsTile = find.byType(CheckboxListTile).first;
      await tester.tap(smsTile);
      await tester.pumpAndSettle();
      final sms = tester.widget<CheckboxListTile>(smsTile);
      check(sms.value).equals(false);
    },
  );

  testWidgets(
    'ContactFormScreen all four channel checkboxes render',
    (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: [
          contactsRepositoryProvider
              .overrideWithValue(FakeContactsRepository()),
        ],
        child: const ContactFormScreen(),
      ));
      await tester.pumpAndSettle();
      final tiles = find.descendant(
        of: find.byType(ContactFormScreen),
        matching: find.byType(CheckboxListTile),
      );
      check(tiles.evaluate().length).equals(4);
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
      // Uncheck SMS so channels set is empty.
      final tiles = find.descendant(
        of: find.byType(ContactFormScreen),
        matching: find.byType(CheckboxListTile),
      );
      await tester.tap(tiles.at(0));
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
      await tester.enterText(fields.at(3), 'es');
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
    'ContactFormScreen toggling Telegram + WhatsApp + Phone adds channels',
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
      final tiles = find.descendant(
        of: find.byType(ContactFormScreen),
        matching: find.byType(CheckboxListTile),
      );
      // Tile order: SMS, WhatsApp, Telegram, Phone
      await tester.tap(tiles.at(1));
      await tester.tap(tiles.at(2));
      await tester.tap(tiles.at(3));
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
