/// Widget tests for [ContactFormScreen].
///
/// Covers spec 04 §Contact Form (lines 1352–1413): form fields,
/// create/edit modes, channel toggles, save validation, cancel behaviour,
/// dirty guard, and a dark-mode / RTL / accessibility smoke.
///
/// The screen reads [databaseProvider] directly (no separate controller),
/// so every test overrides [databaseProvider] with an in-memory database.
///
/// Tests that exercise the _save() path (which calls context.pop() via
/// GoRouter) use [_pumpWithRouter], which mounts the screen inside a
/// minimal [GoRouter] shell so the pop succeeds.
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/contacts_repository.dart';
import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/features/contact_form/contact_form_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Opens a no-seed in-memory database.
GuardianAngelaDatabase _openDb() =>
    GuardianAngelaDatabase.memory(seedCallback: (_) async {});

/// Returns an [Override] that wires [databaseProvider] to [db].
Override _dbOverride(GuardianAngelaDatabase db) =>
    databaseProvider.overrideWith((_) async => db);

/// Builds a [ContactFormScreen] mounted under a minimal [GoRouter] so that
/// [context.pop()] inside [_save] resolves without a "No GoRouter" error.
///
/// The router has two routes:
/// - `/` — a blank sentinel so the screen has a route to pop back to.
/// - `/form` — the [ContactFormScreen] (with optional [contactId]).
///
/// After pump, [tester.pumpAndSettle] is called once to let async providers
/// settle. Pass [settle] = false to skip the settle call.
Future<void> _pumpWithRouter(
  WidgetTester tester, {
  String? contactId,
  required List<Override> overrides,
  bool settle = true,
}) async {
  final router = GoRouter(
    initialLocation: '/form',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, _) =>
            const Scaffold(body: Text('home')),
        routes: <RouteBase>[
          GoRoute(
            path: 'form',
            builder: (context, _) =>
                ContactFormScreen(contactId: contactId),
          ),
        ],
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF131118),
          ),
          useMaterial3: true,
        ),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  }
}

EmergencyContact _contact({
  String id = 'c-1',
  String name = 'Alice',
  String phone = '+15550001111',
  String? relationship,
  List<MessageChannel> channels = const <MessageChannel>[
    MessageChannel.sms,
    MessageChannel.whatsapp,
    MessageChannel.telegram,
    MessageChannel.phoneCall,
  ],
}) => EmergencyContact(
  id: id,
  name: name,
  phoneNumber: phone,
  relationship: relationship,
  sortOrder: 0,
  channels: channels,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late GuardianAngelaDatabase db;
  late List<Override> baseOverrides;

  setUp(() {
    db = _openDb();
    baseOverrides = <Override>[_dbOverride(db)];
  });

  tearDown(() async {
    await db.close();
  });

  // ---- Group: AppBar -------------------------------------------------------

  group('ContactFormScreen — AppBar', () {
    testWidgets('shows "New contact" title in create mode', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ContactFormScreen(),
        overrides: baseOverrides,
      );
      expect(find.text(l10n.contactFormTitleCreate), findsOneWidget);
    });

    testWidgets('shows "Edit contact" title when contactId is provided', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await ContactsRepository(db.contactsDao).upsert(_contact());
      await pumpScreen(
        tester,
        const ContactFormScreen(contactId: 'c-1'),
        overrides: baseOverrides,
      );
      expect(find.text(l10n.contactFormTitleEdit), findsOneWidget);
    });

    testWidgets('app bar has a Save action button', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ContactFormScreen(),
        overrides: baseOverrides,
      );
      expect(
        find.widgetWithText(TextButton, l10n.commonSave),
        findsOneWidget,
      );
    });
  });

  // ---- Group: Form fields present -----------------------------------------

  group('ContactFormScreen — form fields', () {
    testWidgets('renders name, phone and relationship text fields', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ContactFormScreen(),
        overrides: baseOverrides,
      );
      expect(find.text(l10n.contactFieldName), findsOneWidget);
      expect(find.text(l10n.contactFieldPhone), findsOneWidget);
      expect(find.text(l10n.contactFieldRelationship), findsOneWidget);
    });

    testWidgets('renders channels header', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ContactFormScreen(),
        overrides: baseOverrides,
      );
      expect(find.text(l10n.contactChannelsHeader), findsOneWidget);
    });

    testWidgets('renders all four channel FilterChips', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ContactFormScreen(),
        overrides: baseOverrides,
      );
      expect(find.byType(FilterChip), findsNWidgets(4));
      expect(find.text(l10n.contactChannelSms), findsOneWidget);
      expect(find.text(l10n.contactChannelWhatsapp), findsOneWidget);
      expect(find.text(l10n.contactChannelTelegram), findsOneWidget);
      expect(find.text(l10n.contactChannelPhone), findsOneWidget);
    });

    testWidgets('renders three TextField widgets for name/phone/relationship', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const ContactFormScreen(),
        overrides: baseOverrides,
      );
      expect(find.byType(TextField), findsNWidgets(3));
    });
  });

  // ---- Group: Create mode --------------------------------------------------

  group('ContactFormScreen — create mode', () {
    testWidgets('all text fields are empty in create mode', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const ContactFormScreen(),
        overrides: baseOverrides,
      );
      final nameField = tester.widget<TextField>(find.byType(TextField).at(0));
      final phoneField = tester.widget<TextField>(find.byType(TextField).at(1));
      final relField = tester.widget<TextField>(find.byType(TextField).at(2));
      check(nameField.controller!.text).isEmpty();
      check(phoneField.controller!.text).isEmpty();
      check(relField.controller!.text).isEmpty();
    });

    testWidgets('all four channels are selected by default', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const ContactFormScreen(),
        overrides: baseOverrides,
      );
      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      for (final chip in chips) {
        check(chip.selected).isTrue();
      }
    });
  });

  // ---- Group: Edit mode pre-population ------------------------------------

  group('ContactFormScreen — edit mode', () {
    testWidgets(
      'pre-fills name, phone and relationship from stored contact',
      (WidgetTester tester) async {
        await ContactsRepository(db.contactsDao).upsert(
          _contact(name: 'Bob', phone: '+4917612345', relationship: 'Friend'),
        );
        await pumpScreen(
          tester,
          const ContactFormScreen(contactId: 'c-1'),
          overrides: baseOverrides,
        );
        final nameField = tester.widget<TextField>(
          find.byType(TextField).at(0),
        );
        final phoneField = tester.widget<TextField>(
          find.byType(TextField).at(1),
        );
        final relField = tester.widget<TextField>(
          find.byType(TextField).at(2),
        );
        check(nameField.controller!.text).equals('Bob');
        check(phoneField.controller!.text).equals('+4917612345');
        check(relField.controller!.text).equals('Friend');
      },
    );

    testWidgets('reflects partial channels from stored contact', (
      WidgetTester tester,
    ) async {
      await ContactsRepository(db.contactsDao).upsert(
        _contact(channels: const <MessageChannel>[MessageChannel.sms]),
      );
      await pumpScreen(
        tester,
        const ContactFormScreen(contactId: 'c-1'),
        overrides: baseOverrides,
      );
      final chips = tester
          .widgetList<FilterChip>(find.byType(FilterChip))
          .toList();
      // Only SMS chip (index 0) is selected.
      check(chips[0].selected).isTrue();
      check(chips[1].selected).isFalse();
      check(chips[2].selected).isFalse();
      check(chips[3].selected).isFalse();
    });

    testWidgets(
      'renders the form body (not loading spinner) after async load',
      (WidgetTester tester) async {
        await ContactsRepository(db.contactsDao).upsert(_contact());
        await pumpScreen(
          tester,
          const ContactFormScreen(contactId: 'c-1'),
          overrides: baseOverrides,
        );
        // After pumpAndSettle, the spinner is gone and fields are visible.
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(FilterChip), findsWidgets);
      },
    );
  });

  // ---- Group: Channel toggles ---------------------------------------------

  group('ContactFormScreen — channel toggles', () {
    testWidgets('tapping a selected chip deselects it', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ContactFormScreen(),
        overrides: baseOverrides,
      );
      // All chips start selected; tap the SMS chip to deselect.
      await tester.tap(find.text(l10n.contactChannelSms));
      await tester.pumpAndSettle();
      final smsChip = tester.widget<FilterChip>(
        find.ancestor(
          of: find.text(l10n.contactChannelSms),
          matching: find.byType(FilterChip),
        ),
      );
      check(smsChip.selected).isFalse();
    });

    testWidgets('tapping a deselected chip re-selects it', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ContactFormScreen(),
        overrides: baseOverrides,
      );
      // Deselect then re-select SMS.
      await tester.tap(find.text(l10n.contactChannelSms));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.contactChannelSms));
      await tester.pumpAndSettle();
      final smsChip = tester.widget<FilterChip>(
        find.ancestor(
          of: find.text(l10n.contactChannelSms),
          matching: find.byType(FilterChip),
        ),
      );
      check(smsChip.selected).isTrue();
    });

    testWidgets('toggling a chip marks the form dirty', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ContactFormScreen(),
        overrides: baseOverrides,
      );
      await tester.tap(find.text(l10n.contactChannelSms));
      await tester.pumpAndSettle();
      // Dirty form: maybePop should trigger the dialog.
      final NavigatorState nav = tester.state(find.byType(Navigator));
      await nav.maybePop();
      await tester.pumpAndSettle();
      expect(find.text(l10n.contactUnsavedDiscardTitle), findsOneWidget);
    });
  });

  // ---- Group: Validation on save ------------------------------------------

  group('ContactFormScreen — validation', () {
    testWidgets('shows snack bar when name is empty on save', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ContactFormScreen(),
        overrides: baseOverrides,
      );
      // Tap Save without entering any data.
      await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
      await tester.pumpAndSettle();
      expect(find.text(l10n.validationNameTooShort), findsOneWidget);
    });

    testWidgets('shows snack bar when name is a single character', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ContactFormScreen(),
        overrides: baseOverrides,
      );
      await tester.enterText(find.byType(TextField).at(0), 'A');
      await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
      await tester.pumpAndSettle();
      expect(find.text(l10n.validationNameTooShort), findsOneWidget);
    });

    testWidgets('shows snack bar when phone is empty on save', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ContactFormScreen(),
        overrides: baseOverrides,
      );
      // Provide valid name but no phone.
      await tester.enterText(find.byType(TextField).at(0), 'Alice');
      await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
      await tester.pumpAndSettle();
      expect(find.text(l10n.validationPhoneRequired), findsOneWidget);
    });

    testWidgets('shows snack bar when no channel is selected', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ContactFormScreen(),
        overrides: baseOverrides,
      );
      await tester.enterText(find.byType(TextField).at(0), 'Alice');
      await tester.enterText(find.byType(TextField).at(1), '+15550001111');
      // Deselect all four chips.
      await tester.tap(find.text(l10n.contactChannelSms));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.contactChannelWhatsapp));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.contactChannelTelegram));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.contactChannelPhone));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
      await tester.pumpAndSettle();
      expect(find.text(l10n.validationChannelsRequired), findsOneWidget);
    });
  });

  // ---- Group: Successful save in create mode ------------------------------

  group('ContactFormScreen — save persists contact', () {
    testWidgets('valid create-mode form persists the contact to the DB', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpWithRouter(tester, overrides: baseOverrides);
      await tester.enterText(find.byType(TextField).at(0), 'Charlie');
      await tester.enterText(find.byType(TextField).at(1), '+15550009999');
      await tester.enterText(find.byType(TextField).at(2), 'Sibling');
      await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
      await tester.pumpAndSettle();
      final all = await ContactsRepository(db.contactsDao).getAll();
      check(all).isNotEmpty();
      final saved = all.first;
      check(saved.name).equals('Charlie');
      check(saved.phoneNumber).equals('+15550009999');
      check(saved.relationship).equals('Sibling');
    });

    testWidgets('trim whitespace from name and phone before saving', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpWithRouter(tester, overrides: baseOverrides);
      await tester.enterText(find.byType(TextField).at(0), '  Dana  ');
      await tester.enterText(find.byType(TextField).at(1), ' +15550007777 ');
      await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
      await tester.pumpAndSettle();
      final all = await ContactsRepository(db.contactsDao).getAll();
      check(all).isNotEmpty();
      check(all.first.name).equals('Dana');
      check(all.first.phoneNumber).equals('+15550007777');
    });

    testWidgets(
      'null relationship stored when relationship field is blank',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await _pumpWithRouter(tester, overrides: baseOverrides);
        await tester.enterText(find.byType(TextField).at(0), 'Frank');
        await tester.enterText(find.byType(TextField).at(1), '+15550005555');
        // Relationship left empty.
        await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
        await tester.pumpAndSettle();
        final all = await ContactsRepository(db.contactsDao).getAll();
        check(all).isNotEmpty();
        check(all.first.relationship).isNull();
      },
    );
  });

  // ---- Group: Save in edit mode -------------------------------------------

  group('ContactFormScreen — edit-mode save', () {
    testWidgets('upserts existing contact with updated name', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await ContactsRepository(db.contactsDao).upsert(
        _contact(name: 'Eve', phone: '+15550002222'),
      );
      await _pumpWithRouter(
        tester,
        contactId: 'c-1',
        overrides: baseOverrides,
      );
      await tester.tap(find.byType(TextField).at(0));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'Eve Updated');
      await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
      await tester.pumpAndSettle();
      final updated = await ContactsRepository(db.contactsDao).getById('c-1');
      check(updated).isNotNull();
      check(updated!.name).equals('Eve Updated');
    });
  });

  // ---- Group: Dirty guard -------------------------------------------------

  group('ContactFormScreen — dirty guard', () {
    testWidgets(
      'editing a field marks the form dirty and shows the discard dialog',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await pumpScreen(
          tester,
          const ContactFormScreen(),
          overrides: baseOverrides,
        );
        await tester.enterText(find.byType(TextField).at(0), 'Dirty');
        await tester.pumpAndSettle();
        final NavigatorState nav = tester.state(find.byType(Navigator));
        await nav.maybePop();
        await tester.pumpAndSettle();
        expect(find.text(l10n.contactUnsavedDiscardTitle), findsOneWidget);
      },
    );

    testWidgets(
      '"Keep editing" button dismisses dialog and stays on form',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await pumpScreen(
          tester,
          const ContactFormScreen(),
          overrides: baseOverrides,
        );
        await tester.enterText(find.byType(TextField).at(0), 'Dirty');
        await tester.pumpAndSettle();
        final NavigatorState nav = tester.state(find.byType(Navigator));
        await nav.maybePop();
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.contactUnsavedDiscardKeep));
        await tester.pumpAndSettle();
        expect(find.byType(ContactFormScreen), findsOneWidget);
        expect(find.text(l10n.contactUnsavedDiscardTitle), findsNothing);
      },
    );

    testWidgets(
      '"Discard" button closes the screen after confirming',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        await pumpScreen(
          tester,
          const ContactFormScreen(),
          overrides: baseOverrides,
        );
        await tester.enterText(find.byType(TextField).at(0), 'Dirty');
        await tester.pumpAndSettle();
        final NavigatorState nav = tester.state(find.byType(Navigator));
        await nav.maybePop();
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.contactUnsavedDiscardDiscard));
        await tester.pumpAndSettle();
        expect(find.byType(ContactFormScreen), findsNothing);
      },
    );

    testWidgets('clean form pops without showing dirty dialog', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ContactFormScreen(),
        overrides: baseOverrides,
      );
      // No edits — form is clean.
      final NavigatorState nav = tester.state(find.byType(Navigator));
      await nav.maybePop();
      await tester.pumpAndSettle();
      expect(find.text(l10n.contactUnsavedDiscardTitle), findsNothing);
    });
  });

  // ---- Group: RTL smoke ---------------------------------------------------

  group('ContactFormScreen — RTL', () {
    testWidgets('renders in Arabic (RTL) without overflow', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const ContactFormScreen(),
        overrides: baseOverrides,
        locale: const Locale('ar'),
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ---- Group: Dark mode smoke --------------------------------------------

  group('ContactFormScreen — dark mode', () {
    testWidgets('renders without exception in dark mode', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const ContactFormScreen(),
        overrides: baseOverrides,
        themeMode: ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
    });
  });

  // ---- Group: Accessibility -----------------------------------------------

  group('ContactFormScreen — accessibility', () {
    testWidgets('form fields have accessible labels', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ContactFormScreen(),
        overrides: baseOverrides,
      );
      expect(find.text(l10n.contactFieldName), findsOneWidget);
      expect(find.text(l10n.contactFieldPhone), findsOneWidget);
      expect(find.text(l10n.contactFieldRelationship), findsOneWidget);
    });

    testWidgets('no exception on semantic pass-through', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const ContactFormScreen(),
        overrides: baseOverrides,
      );
      final SemanticsHandle handle = tester.ensureSemantics();
      expect(tester.takeException(), isNull);
      handle.dispose();
    });

    testWidgets('channels header is visible for screen readers', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const ContactFormScreen(),
        overrides: baseOverrides,
      );
      expect(find.text(l10n.contactChannelsHeader), findsOneWidget);
    });
  });
}
