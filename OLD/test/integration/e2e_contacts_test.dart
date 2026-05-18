/// End-to-end UI integration tests for contacts feature.
///
/// Covers ContactsScreen (list, delete, add FAB) and ContactFormScreen
/// (create, edit, language dropdown, channel toggles, validation).
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/contacts/contact_form_screen.dart';
import 'package:guardianangela/features/contacts/contacts_screen.dart';

import '../features/fake_repositories.dart';
import '../features/widget_test_helpers.dart';
import '../helpers/test_helpers.dart';

// ---------------------------------------------------------------------------
// helpers
// ---------------------------------------------------------------------------

List<Override> _sessionOverride() => [
  settingsRepositoryProvider.overrideWithValue(
    FakeSettingsRepository(const AppSettings(defaults: AppDefaults())),
  ),
];

List<Override> _contactsOverrides({List<EmergencyContact> contacts = const []}) =>
    [
      contactsRepositoryProvider
          .overrideWithValue(FakeContactsRepository(contacts)),
      ..._sessionOverride(),
    ];

List<Override> _formOverrides({List<EmergencyContact> contacts = const []}) => [
  contactsRepositoryProvider
      .overrideWithValue(FakeContactsRepository(contacts)),
  ..._sessionOverride(),
];

// ---------------------------------------------------------------------------
// Tests: ContactsScreen
// ---------------------------------------------------------------------------

void main() {
  group('contacts screen', () {
    testWidgets('contacts_screen_empty_shows_empty_state', (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _contactsOverrides(contacts: []),
        child: const ContactsScreen(),
      ));
      await tester.pumpAndSettle();
      check(find.byType(Center).evaluate().length).isGreaterOrEqual(1);
    });

    testWidgets('contacts_screen_seeded_shows_names', (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _contactsOverrides(contacts: [
          makeContact(id: 'c1', name: 'Alice'),
          makeContact(id: 'c2', name: 'Bob'),
        ]),
        child: const ContactsScreen(),
      ));
      await tester.pumpAndSettle();
      check(find.text('Alice').evaluate().length).isGreaterOrEqual(1);
      check(find.text('Bob').evaluate().length).isGreaterOrEqual(1);
    });

    testWidgets('contacts_screen_shows_phone_numbers', (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _contactsOverrides(contacts: [
          makeContact(id: 'c1', name: 'Alice', phoneNumber: '+441234567890'),
        ]),
        child: const ContactsScreen(),
      ));
      await tester.pumpAndSettle();
      check(find.text('+441234567890').evaluate().length).isGreaterOrEqual(1);
    });

    testWidgets('contacts_screen_add_fab_visible', (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _contactsOverrides(),
        child: const ContactsScreen(),
      ));
      await tester.pumpAndSettle();
      check(find.byType(FloatingActionButton).evaluate().length)
          .isGreaterOrEqual(1);
    });

    testWidgets('contacts_screen_delete_icon_per_contact', (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _contactsOverrides(contacts: [
          makeContact(id: 'c1', name: 'Alice'),
          makeContact(id: 'c2', name: 'Bob'),
        ]),
        child: const ContactsScreen(),
      ));
      await tester.pumpAndSettle();
      check(find.byIcon(Icons.delete_outline).evaluate().length)
          .isGreaterOrEqual(2);
    });

    testWidgets('contacts_screen_delete_shows_confirm_dialog', (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _contactsOverrides(contacts: [
          makeContact(id: 'c1', name: 'Alice'),
        ]),
        child: const ContactsScreen(),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();
      // Confirmation dialog appears.
      check(find.byType(AlertDialog).evaluate().length).isGreaterOrEqual(1);
    });

    testWidgets('contacts_screen_delete_cancel_keeps_contact', (tester) async {
      final repo = FakeContactsRepository([makeContact(id: 'c1', name: 'Alice')]);
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: [
          contactsRepositoryProvider.overrideWithValue(repo),
          ..._sessionOverride(),
        ],
        child: const ContactsScreen(),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();
      // Tap Cancel in the dialog.
      await tester.tap(find.byType(TextButton).last);
      await tester.pumpAndSettle();
      final remaining = await repo.getAll();
      check(remaining.length).equals(1);
    });

    testWidgets('contacts_screen_delete_confirm_removes_contact', (tester) async {
      final repo = FakeContactsRepository([
        makeContact(id: 'c1', name: 'Alice'),
        makeContact(id: 'c2', name: 'Bob'),
      ]);
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: [
          contactsRepositoryProvider.overrideWithValue(repo),
          ..._sessionOverride(),
        ],
        child: const ContactsScreen(),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();
      // Tap the confirm (FilledButton) in the dialog.
      await tester.tap(find.byType(FilledButton).last);
      await tester.pumpAndSettle();
      final remaining = await repo.getAll();
      check(remaining.length).equals(1);
    });
  });

  // ---- ContactFormScreen: create -------------------------------------------

  group('contact form — create', () {
    testWidgets('contact_form_create_renders_name_and_phone_fields',
        (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _formOverrides(),
        child: const ContactFormScreen(),
      ));
      await tester.pumpAndSettle();
      check(find.byType(TextFormField).evaluate().length).isGreaterOrEqual(2);
    });

    testWidgets('contact_form_save_with_name_and_phone', (tester) async {
      final repo = FakeContactsRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          contactsRepositoryProvider.overrideWithValue(repo),
          ..._sessionOverride(),
        ],
        child: const ContactFormScreen(),
      ));
      await tester.pumpAndSettle();
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Carol');
      await tester.enterText(fields.at(1), '+441112223344');
      await tester.pump();
      // The contact form uses a FilledButton in the body for save.
      // Scroll to the save button at the bottom of the form.
      await tester.drag(find.byType(ListView).first, const Offset(0, -400));
      await tester.pump();
      await tester.ensureVisible(find.byType(FilledButton).last);
      await tester.tap(find.byType(FilledButton).last);
      await tester.pumpAndSettle();
      final saved = await repo.getAll();
      check(saved.length).equals(1);
      check(saved.first.name).equals('Carol');
      check(saved.first.phoneNumber).equals('+441112223344');
    });

    testWidgets('contact_form_empty_name_shows_validation_error', (tester) async {
      final repo = FakeContactsRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          contactsRepositoryProvider.overrideWithValue(repo),
          ..._sessionOverride(),
        ],
        child: const ContactFormScreen(),
      ));
      await tester.pumpAndSettle();
      // Scroll to the save button (form content may exceed screen height).
      await tester.drag(find.byType(ListView).first, const Offset(0, -400));
      await tester.pump();
      // Tap save without entering a name.
      await tester.ensureVisible(find.byType(FilledButton).last);
      await tester.tap(find.byType(FilledButton).last);
      await tester.pumpAndSettle();
      // Nothing saved.
      final saved = await repo.getAll();
      check(saved).isEmpty();
    });

    testWidgets('contact_form_sms_channel_default', (tester) async {
      final repo = FakeContactsRepository();
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          contactsRepositoryProvider.overrideWithValue(repo),
          ..._sessionOverride(),
        ],
        child: const ContactFormScreen(),
      ));
      await tester.pumpAndSettle();
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Dave');
      await tester.enterText(fields.at(1), '+441234567890');
      await tester.pump();
      // Scroll to the save button at the bottom of the form.
      await tester.drag(find.byType(ListView).first, const Offset(0, -400));
      await tester.pump();
      await tester.ensureVisible(find.byType(FilledButton).last);
      await tester.tap(find.byType(FilledButton).last);
      await tester.pumpAndSettle();
      final saved = await repo.getAll();
      check(saved.first.channels).contains(MessageChannel.sms);
    });

    testWidgets('contact_form_language_dropdown_has_entries', (tester) async {
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _formOverrides(),
        child: const ContactFormScreen(),
      ));
      await tester.pumpAndSettle();
      // There should be a DropdownButtonFormField for language.
      // Use predicate since find.byType doesn't match on generic type params.
      check(
        find.byWidgetPredicate((w) => w is DropdownButtonFormField)
            .evaluate()
            .length,
      ).isGreaterOrEqual(1);
    });

    testWidgets('contact_form_shows_channel_toggles', (tester) async {
      // Channel toggles are FilterChip buttons (one per channel),
      // and they all start selected by default.
      await tester.pumpWidget(hostScreenWithRouter(
        overrides: _formOverrides(),
        child: const ContactFormScreen(),
      ));
      await tester.pumpAndSettle();
      check(find.byType(FilterChip).evaluate().length).isGreaterOrEqual(4);
    });
  });

  // ---- ContactFormScreen: edit ---------------------------------------------

  group('contact form — edit', () {
    testWidgets('contact_form_edit_pre_fills_name', (tester) async {
      final existing = makeContact(id: 'c1', name: 'Alice', phoneNumber: '+10000000000');
      final repo = FakeContactsRepository([existing]);
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          contactsRepositoryProvider.overrideWithValue(repo),
          ..._sessionOverride(),
        ],
        child: ContactFormScreen(id: 'c1'),
      ));
      await tester.pumpAndSettle();
      // The name field should be pre-filled with 'Alice'.
      final fields = tester.widgetList<TextFormField>(find.byType(TextFormField));
      // At least one field contains 'Alice'.
      final hasAlice = fields.any((f) {
        final ctrl = f.controller;
        return ctrl != null && ctrl.text == 'Alice';
      });
      check(hasAlice).isTrue();
    });

    testWidgets('contact_form_edit_pre_fills_phone', (tester) async {
      final existing = makeContact(id: 'c1', name: 'Alice', phoneNumber: '+19991112222');
      final repo = FakeContactsRepository([existing]);
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          contactsRepositoryProvider.overrideWithValue(repo),
          ..._sessionOverride(),
        ],
        child: ContactFormScreen(id: 'c1'),
      ));
      await tester.pumpAndSettle();
      final fields = tester.widgetList<TextFormField>(find.byType(TextFormField));
      final hasPhone = fields.any((f) {
        final ctrl = f.controller;
        return ctrl != null && ctrl.text == '+19991112222';
      });
      check(hasPhone).isTrue();
    });

    testWidgets('contact_form_edit_saves_changed_phone', (tester) async {
      final existing = makeContact(
        id: 'c1',
        name: 'Alice',
        phoneNumber: '+10000000000',
      );
      final repo = FakeContactsRepository([existing]);
      await tester.pumpWidget(hostScreenPushed(
        overrides: [
          contactsRepositoryProvider.overrideWithValue(repo),
          ..._sessionOverride(),
        ],
        child: ContactFormScreen(id: 'c1'),
      ));
      await tester.pumpAndSettle();
      // Change the phone field (index 1).
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(1), '+19998887777');
      await tester.pump();
      // Scroll to the save button.
      await tester.drag(find.byType(ListView).first, const Offset(0, -400));
      await tester.pump();
      // Tap the save button.
      await tester.ensureVisible(find.byType(FilledButton).last);
      await tester.tap(find.byType(FilledButton).last);
      await tester.pumpAndSettle();
      final saved = await repo.getAll();
      check(saved.where((c) => c.phoneNumber == '+19998887777').length).equals(1);
    });
  });
}
