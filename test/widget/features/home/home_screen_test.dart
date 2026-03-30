import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safewayhome/data/models/app_settings.dart';
import 'package:safewayhome/data/models/emergency_contact.dart';
import 'package:safewayhome/data/models/session_mode.dart';
import 'package:safewayhome/features/contacts/contacts_controller.dart';
import 'package:safewayhome/features/home/home_screen.dart';
import 'package:safewayhome/features/modes/modes_controller.dart';
import 'package:safewayhome/features/settings/settings_controller.dart';
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

final _defaultModes = [
  SessionMode(
    id: 'walk_mode',
    name: 'Walk Mode',
    checkInMechanism: CheckInMechanism.holdButton,
    checkInIntervalSeconds: 10,
    escalationSteps: [],
    isBuiltIn: true,
  ),
  SessionMode(
    id: 'date_mode',
    name: 'Date Mode',
    checkInMechanism: CheckInMechanism.disguisedReminder,
    checkInIntervalSeconds: 30,
    escalationSteps: [],
    isBuiltIn: true,
  ),
];

void main() {
  group('HomeScreen', () {
    testWidgets('renders app title', (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(
          const HomeScreen(),
          [
            modesControllerProvider
                .overrideWith(() => _FakeModesController(_defaultModes)),
            settingsControllerProvider
                .overrideWith(() => _FakeSettingsController()),
            contactsControllerProvider
                .overrideWith(() => _FakeContactsController([])),
          ],
        ),
      );
      await tester.pump();
      await tester.pump();

      // App title appears in AppBar and body
      expect(find.text('SafeWayHome'), findsWidgets);
    });

    testWidgets('shows mode selector with modes', (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(
          const HomeScreen(),
          [
            modesControllerProvider
                .overrideWith(() => _FakeModesController(_defaultModes)),
            settingsControllerProvider
                .overrideWith(() => _FakeSettingsController()),
            contactsControllerProvider
                .overrideWith(() => _FakeContactsController([])),
          ],
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Modes'), findsOneWidget);
      // Walk and Date mode chips
      expect(find.text('Walk Mode'), findsOneWidget);
      expect(find.text('Date Mode'), findsOneWidget);
    });

    testWidgets('start button is present', (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(
          const HomeScreen(),
          [
            modesControllerProvider
                .overrideWith(() => _FakeModesController(_defaultModes)),
            settingsControllerProvider
                .overrideWith(() => _FakeSettingsController()),
            contactsControllerProvider
                .overrideWith(() => _FakeContactsController([])),
          ],
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Start Session'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('navigation icons present (contacts, settings)',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(
          const HomeScreen(),
          [
            modesControllerProvider
                .overrideWith(() => _FakeModesController(_defaultModes)),
            settingsControllerProvider
                .overrideWith(() => _FakeSettingsController()),
            contactsControllerProvider
                .overrideWith(() => _FakeContactsController([])),
          ],
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.people), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('shows contact chips when contacts exist', (tester) async {
      final contacts = [
        EmergencyContact(
          id: 'c1',
          name: 'Alice',
          phoneNumber: '+49111',
          sortOrder: 0,
        ),
        EmergencyContact(
          id: 'c2',
          name: 'Bob',
          phoneNumber: '+49222',
          sortOrder: 1,
        ),
      ];

      await tester.pumpWidget(
        _wrapWithProviders(
          const HomeScreen(),
          [
            modesControllerProvider
                .overrideWith(() => _FakeModesController(_defaultModes)),
            settingsControllerProvider
                .overrideWith(() => _FakeSettingsController()),
            contactsControllerProvider
                .overrideWith(() => _FakeContactsController(contacts)),
          ],
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byType(Chip), findsNWidgets(2));
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('shows add contact link when no contacts', (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(
          const HomeScreen(),
          [
            modesControllerProvider
                .overrideWith(() => _FakeModesController(_defaultModes)),
            settingsControllerProvider
                .overrideWith(() => _FakeSettingsController()),
            contactsControllerProvider
                .overrideWith(() => _FakeContactsController([])),
          ],
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Add Contact'), findsOneWidget);
    });

    testWidgets('shield icon is displayed', (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(
          const HomeScreen(),
          [
            modesControllerProvider
                .overrideWith(() => _FakeModesController(_defaultModes)),
            settingsControllerProvider
                .overrideWith(() => _FakeSettingsController()),
            contactsControllerProvider
                .overrideWith(() => _FakeContactsController([])),
          ],
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.shield), findsWidgets);
    });
  });
}

class _FakeModesController extends ModesController {
  final List<SessionMode> _modes;

  _FakeModesController(this._modes);

  @override
  Future<List<SessionMode>> build() async => _modes;
}

class _FakeSettingsController extends SettingsController {
  @override
  Future<AppSettings> build() async => AppSettings();
}

class _FakeContactsController extends ContactsController {
  final List<EmergencyContact> _contacts;

  _FakeContactsController(this._contacts);

  @override
  Future<List<EmergencyContact>> build() async => _contacts;
}
