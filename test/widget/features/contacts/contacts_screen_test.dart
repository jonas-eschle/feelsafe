import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safewayhome/data/models/emergency_contact.dart';
import 'package:safewayhome/features/contacts/contacts_controller.dart';
import 'package:safewayhome/features/contacts/contacts_screen.dart';
import 'package:safewayhome/l10n/app_localizations.dart';

Widget _wrapWithProviders(Widget child, List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: child,
    ),
  );
}

void main() {
  group('ContactsScreen', () {
    testWidgets('shows empty state when no contacts', (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(
          const ContactsScreen(),
          [
            contactsControllerProvider
                .overrideWith(() => _FakeContactsController([])),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No emergency contacts yet'), findsOneWidget);
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
      expect(find.text('Add Contact'), findsWidgets); // button + FAB tooltip
    });

    testWidgets('shows contact list when contacts exist', (tester) async {
      final contacts = [
        EmergencyContact(
          id: 'c1',
          name: 'Alice',
          phoneNumber: '+49123456',
          sortOrder: 0,
        ),
        EmergencyContact(
          id: 'c2',
          name: 'Bob',
          phoneNumber: '+49654321',
          relationship: 'Brother',
          sortOrder: 1,
        ),
      ];

      await tester.pumpWidget(
        _wrapWithProviders(
          const ContactsScreen(),
          [
            contactsControllerProvider
                .overrideWith(() => _FakeContactsController(contacts)),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('+49123456'), findsOneWidget);
      // Bob has relationship shown in subtitle
      expect(find.textContaining('Brother'), findsOneWidget);
    });

    testWidgets('shows contact initials in avatar', (tester) async {
      final contacts = [
        EmergencyContact(
          id: 'c1',
          name: 'Alice',
          phoneNumber: '+49123456',
          sortOrder: 0,
        ),
      ];

      await tester.pumpWidget(
        _wrapWithProviders(
          const ContactsScreen(),
          [
            contactsControllerProvider
                .overrideWith(() => _FakeContactsController(contacts)),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('A'), findsOneWidget); // Initial in CircleAvatar
    });

    testWidgets('FAB is always visible', (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(
          const ContactsScreen(),
          [
            contactsControllerProvider
                .overrideWith(() => _FakeContactsController([])),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsWidgets);
    });

    testWidgets('shows SMS icon for sms channel', (tester) async {
      final contacts = [
        EmergencyContact(
          id: 'c1',
          name: 'Alice',
          phoneNumber: '+49123456',
          preferredChannel: MessageChannel.sms,
          sortOrder: 0,
        ),
      ];

      await tester.pumpWidget(
        _wrapWithProviders(
          const ContactsScreen(),
          [
            contactsControllerProvider
                .overrideWith(() => _FakeContactsController(contacts)),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.sms), findsOneWidget);
    });

    testWidgets('shows chat icon for whatsapp channel', (tester) async {
      final contacts = [
        EmergencyContact(
          id: 'c1',
          name: 'Alice',
          phoneNumber: '+49123456',
          preferredChannel: MessageChannel.whatsapp,
          sortOrder: 0,
        ),
      ];

      await tester.pumpWidget(
        _wrapWithProviders(
          const ContactsScreen(),
          [
            contactsControllerProvider
                .overrideWith(() => _FakeContactsController(contacts)),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chat), findsOneWidget);
    });

    testWidgets('app bar shows Emergency Contacts title', (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(
          const ContactsScreen(),
          [
            contactsControllerProvider
                .overrideWith(() => _FakeContactsController([])),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Emergency Contacts'), findsOneWidget);
    });
  });
}

class _FakeContactsController extends ContactsController {
  final List<EmergencyContact> _contacts;

  _FakeContactsController(this._contacts);

  @override
  Future<List<EmergencyContact>> build() async => _contacts;
}
