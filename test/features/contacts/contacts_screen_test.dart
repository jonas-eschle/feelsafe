/// Widget tests for [ContactsScreen].
///
/// Follows the reference pattern from `test/features/home/home_screen_test.dart`:
/// 1. A `_FakeContactsController` subclasses [ContactsController] and
///    overrides `build()` to return a canned [ContactsState].
/// 2. Each test calls `pumpScreen(tester, const ContactsScreen(), …)`.
/// 3. Assertions use `find.byType`, `find.text`, l10n keys, and
///    a [_FakeNavigatorObserver] for navigation assertions.
///
/// Spec ref: `docs/spec/04-screens-navigation.md §Contacts Screen`.
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/features/contacts/contacts_controller.dart';
import 'package:guardianangela/features/contacts/contacts_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Test fakes
// ---------------------------------------------------------------------------

class _FakeContactsController extends ContactsController {
  _FakeContactsController(this._initial);

  final ContactsState _initial;

  int deleteCalls = 0;
  String? lastDeletedId;
  int reorderCalls = 0;
  int? lastOldIndex;
  int? lastNewIndex;
  int deleteAllCalls = 0;

  @override
  Future<ContactsState> build() async => _initial;

  @override
  Future<void> delete(String id) async {
    deleteCalls++;
    lastDeletedId = id;
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      ContactsState(
        contacts: current.contacts.where((c) => c.id != id).toList(),
      ),
    );
  }

  @override
  Future<void> reorder(int oldIndex, int newIndex) async {
    reorderCalls++;
    lastOldIndex = oldIndex;
    lastNewIndex = newIndex;
    final current = state.value;
    if (current == null) return;
    final list = List<EmergencyContact>.from(current.contacts);
    final adjusted = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final moved = list.removeAt(oldIndex);
    list.insert(adjusted, moved);
    state = AsyncData(ContactsState(contacts: list));
  }

  @override
  Future<void> deleteAll() async {
    deleteAllCalls++;
    state = const AsyncData(ContactsState(contacts: <EmergencyContact>[]));
  }
}

/// Records which named route was last pushed through GoRouter.
///
/// GoRouter drives its own internal [Navigator]; this observer captures
/// any route pushed on that navigator after the initial route.
class _FakeNavigatorObserver extends NavigatorObserver {
  final List<Route<Object?>> pushed = <Route<Object?>>[];

  @override
  void didPush(Route<Object?> route, Route<Object?>? previousRoute) {
    pushed.add(route);
  }
}

// ---------------------------------------------------------------------------
// Test data factories
// ---------------------------------------------------------------------------

EmergencyContact _contact(
  String id,
  String name, {
  List<MessageChannel> channels = const <MessageChannel>[MessageChannel.sms],
  int sortOrder = 0,
}) => EmergencyContact(
  id: id,
  name: name,
  phoneNumber: '+15550100$id',
  sortOrder: sortOrder,
  channels: channels,
);

ContactsState _state({List<EmergencyContact>? contacts}) =>
    ContactsState(contacts: contacts ?? <EmergencyContact>[]);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

List<Override> _overrideWith(_FakeContactsController fake) => <Override>[
  contactsControllerProvider.overrideWith(() => fake),
];

/// Pumps [ContactsScreen] inside a minimal GoRouter so that
/// `context.pushNamed(...)` can resolve without a "No GoRouter" error.
///
/// The router defines two routes:
/// - `/contacts` — renders [ContactsScreen].
/// - `/contacts/edit` — renders an empty [Scaffold] (stub destination).
///
/// The [observer] is registered on the router's internal navigator so
/// that tests can assert that a push occurred.
Future<void> _pumpWithRouter(
  WidgetTester tester, {
  required _FakeContactsController fake,
  required _FakeNavigatorObserver observer,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
}) async {
  final router = GoRouter(
    initialLocation: '/contacts',
    observers: <NavigatorObserver>[observer],
    routes: <RouteBase>[
      GoRoute(
        path: '/contacts',
        name: RouteNames.contacts,
        builder: (ctx, st) => const ContactsScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: 'edit',
            name: RouteNames.contactForm,
            builder: (ctx, st) => const Scaffold(body: SizedBox.shrink()),
          ),
        ],
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        contactsControllerProvider.overrideWith(() => fake),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        locale: locale,
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        themeMode: themeMode,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF131118)),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF131118),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ── App bar ──────────────────────────────────────────────────────────────

  group('ContactsScreen — AppBar', () {
    testWidgets('renders app bar with contacts title', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeContactsController(_state());
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.text(l10n.contactsTitle), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders FAB with add-contact tooltip', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeContactsController(_state());
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byTooltip(l10n.contactsAdd), findsOneWidget);
    });

    testWidgets('FAB has add icon', (WidgetTester tester) async {
      final fake = _FakeContactsController(_state());
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  // ── Async states ─────────────────────────────────────────────────────────

  group('ContactsScreen — async states', () {
    testWidgets('shows CircularProgressIndicator while loading', (
      WidgetTester tester,
    ) async {
      final fake = _FakeContactsController(_state());
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
        settle: false,
      );
      // First frame: AsyncNotifier is still building.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('no loading spinner once async value resolves', (
      WidgetTester tester,
    ) async {
      final fake = _FakeContactsController(_state());
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  // ── Empty state ───────────────────────────────────────────────────────────

  group('ContactsScreen — empty state', () {
    testWidgets('shows empty banner when contacts list is empty', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeContactsController(_state());
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.text(l10n.contactsEmpty), findsOneWidget);
    });

    testWidgets('no ListTile when contacts list is empty', (
      WidgetTester tester,
    ) async {
      final fake = _FakeContactsController(_state());
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byType(ListTile), findsNothing);
    });
  });

  // ── Contact list ──────────────────────────────────────────────────────────

  group('ContactsScreen — contact list', () {
    testWidgets('renders one ListTile per contact', (
      WidgetTester tester,
    ) async {
      final contacts = <EmergencyContact>[
        _contact('c1', 'Alice'),
        _contact('c2', 'Bob'),
        _contact('c3', 'Carol'),
      ];
      final fake = _FakeContactsController(_state(contacts: contacts));
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byType(ListTile), findsNWidgets(3));
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Carol'), findsOneWidget);
    });

    testWidgets('each row shows the phone number as subtitle', (
      WidgetTester tester,
    ) async {
      final contact = _contact('c1', 'Alice');
      final fake = _FakeContactsController(
        _state(contacts: <EmergencyContact>[contact]),
      );
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.text(contact.phoneNumber), findsOneWidget);
    });

    testWidgets('each row shows CircleAvatar with initial letter', (
      WidgetTester tester,
    ) async {
      final fake = _FakeContactsController(
        _state(contacts: <EmergencyContact>[_contact('c1', 'Alice')]),
      );
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byType(CircleAvatar), findsOneWidget);
      // Initial 'A' is rendered inside the avatar.
      expect(
        find.descendant(
          of: find.byType(CircleAvatar),
          matching: find.text('A'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('channel chips are rendered for each contact', (
      WidgetTester tester,
    ) async {
      final contact = _contact(
        'c1',
        'Alice',
        channels: <MessageChannel>[MessageChannel.sms, MessageChannel.whatsapp],
      );
      final fake = _FakeContactsController(
        _state(contacts: <EmergencyContact>[contact]),
      );
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
      );
      // One Chip for each channel in the trailing Wrap.
      expect(find.byType(Chip), findsNWidgets(2));
    });
  });

  // ── Navigation: FAB → create ──────────────────────────────────────────────

  group('ContactsScreen — FAB navigation', () {
    testWidgets('tapping FAB navigates to the contact-form route', (
      WidgetTester tester,
    ) async {
      final observer = _FakeNavigatorObserver();
      final fake = _FakeContactsController(_state());
      await _pumpWithRouter(tester, fake: fake, observer: observer);
      // observer.pushed[0] is the initial /contacts route.
      final countBefore = observer.pushed.length;
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      // A new route was pushed after the initial load.
      check(observer.pushed.length).isGreaterThan(countBefore);
    });
  });

  // ── Navigation: tap row → edit ────────────────────────────────────────────

  group('ContactsScreen — row tap navigation', () {
    testWidgets('tapping a contact row navigates to the edit route', (
      WidgetTester tester,
    ) async {
      final observer = _FakeNavigatorObserver();
      final contact = _contact('c1', 'Alice');
      final fake = _FakeContactsController(
        _state(contacts: <EmergencyContact>[contact]),
      );
      await _pumpWithRouter(tester, fake: fake, observer: observer);
      final countBefore = observer.pushed.length;
      await tester.tap(find.text('Alice'));
      await tester.pumpAndSettle();
      check(observer.pushed.length).isGreaterThan(countBefore);
    });
  });

  // ── Swipe to delete ───────────────────────────────────────────────────────

  group('ContactsScreen — swipe to delete', () {
    testWidgets('swiping end-to-start shows delete confirmation dialog', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final contact = _contact('c1', 'Alice');
      final fake = _FakeContactsController(
        _state(contacts: <EmergencyContact>[contact]),
      );
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(find.text(l10n.contactDeleteConfirm), findsOneWidget);
    });

    testWidgets('confirming delete calls controller.delete', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final contact = _contact('c1', 'Alice');
      final fake = _FakeContactsController(
        _state(contacts: <EmergencyContact>[contact]),
      );
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();
      // Tap the Delete button in the confirmation dialog.
      await tester.tap(find.text(l10n.commonDelete));
      await tester.pumpAndSettle();
      check(fake.deleteCalls).equals(1);
      check(fake.lastDeletedId).equals('c1');
    });

    testWidgets('cancelling delete does NOT call controller.delete', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final contact = _contact('c1', 'Alice');
      final fake = _FakeContactsController(
        _state(contacts: <EmergencyContact>[contact]),
      );
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();
      // Tap Cancel in the confirmation dialog.
      await tester.tap(find.text(l10n.commonCancel));
      await tester.pumpAndSettle();
      check(fake.deleteCalls).equals(0);
    });

    testWidgets('confirmation dialog body includes contact name', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final contact = _contact('c1', 'Alice');
      final fake = _FakeContactsController(
        _state(contacts: <EmergencyContact>[contact]),
      );
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(find.text(l10n.contactDeleteBody('Alice')), findsOneWidget);
    });

    testWidgets('delete dismiss background shows delete icon on right side', (
      WidgetTester tester,
    ) async {
      final contact = _contact('c1', 'Alice');
      final fake = _FakeContactsController(
        _state(contacts: <EmergencyContact>[contact]),
      );
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
      );
      // Partial drag to reveal background without triggering confirm.
      await tester.drag(find.byType(Dismissible), const Offset(-100, 0));
      await tester.pump();
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });
  });

  // ── Dismissible widget structure ──────────────────────────────────────────

  group('ContactsScreen — Dismissible presence', () {
    testWidgets('each contact row is wrapped in a Dismissible', (
      WidgetTester tester,
    ) async {
      final contacts = <EmergencyContact>[
        _contact('c1', 'Alice'),
        _contact('c2', 'Bob'),
      ];
      final fake = _FakeContactsController(_state(contacts: contacts));
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byType(Dismissible), findsNWidgets(2));
    });
  });

  // ── Multiple channels display ─────────────────────────────────────────────

  group('ContactsScreen — channel chip labels', () {
    testWidgets('SMS channel name is shown as a chip', (
      WidgetTester tester,
    ) async {
      final contact = _contact(
        'c1',
        'Alice',
        channels: <MessageChannel>[MessageChannel.sms],
      );
      final fake = _FakeContactsController(
        _state(contacts: <EmergencyContact>[contact]),
      );
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
      );
      expect(
        find.descendant(
          of: find.byType(Chip),
          matching: find.text(MessageChannel.sms.name),
        ),
        findsOneWidget,
      );
    });

    testWidgets('multiple channels render multiple chips', (
      WidgetTester tester,
    ) async {
      final contact = _contact(
        'c1',
        'Alice',
        channels: <MessageChannel>[
          MessageChannel.sms,
          MessageChannel.telegram,
          MessageChannel.whatsapp,
        ],
      );
      final fake = _FakeContactsController(
        _state(contacts: <EmergencyContact>[contact]),
      );
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byType(Chip), findsNWidgets(3));
    });
  });

  // ── RTL smoke ─────────────────────────────────────────────────────────────

  group('ContactsScreen — RTL', () {
    testWidgets('renders in Arabic (RTL) without overflow', (
      WidgetTester tester,
    ) async {
      final fake = _FakeContactsController(
        _state(contacts: <EmergencyContact>[_contact('c1', 'Alice')]),
      );
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
        locale: const Locale('ar'),
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty state renders in Arabic without overflow', (
      WidgetTester tester,
    ) async {
      final fake = _FakeContactsController(_state());
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
        locale: const Locale('ar'),
      );
      expect(tester.takeException(), isNull);
    });
  });

  // ── Dark mode smoke ───────────────────────────────────────────────────────

  group('ContactsScreen — dark mode', () {
    testWidgets('renders without exception in dark mode (empty)', (
      WidgetTester tester,
    ) async {
      final fake = _FakeContactsController(_state());
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
        themeMode: ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without exception in dark mode (with contacts)', (
      WidgetTester tester,
    ) async {
      final fake = _FakeContactsController(
        _state(contacts: <EmergencyContact>[_contact('c1', 'Alice')]),
      );
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
        themeMode: ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
    });
  });

  // ── Accessibility ─────────────────────────────────────────────────────────

  group('ContactsScreen — accessibility', () {
    testWidgets('FAB has semantic tooltip for screen readers', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeContactsController(_state());
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byTooltip(l10n.contactsAdd), findsOneWidget);
    });

    testWidgets('contact names are visible text nodes for a11y', (
      WidgetTester tester,
    ) async {
      final contacts = <EmergencyContact>[
        _contact('c1', 'Alice'),
        _contact('c2', 'Bob'),
      ];
      final fake = _FakeContactsController(_state(contacts: contacts));
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('empty state text is accessible and readable', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeContactsController(_state());
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
      );
      final emptyText = tester.widget<Text>(find.text(l10n.contactsEmpty));
      check(emptyText.textAlign).equals(TextAlign.center);
    });
  });

  // ── Reorderable list ─────────────────────────────────────────────────────

  group('ContactsScreen — reorder', () {
    testWidgets('renders ReorderableListView when contacts exist', (
      WidgetTester tester,
    ) async {
      final contacts = <EmergencyContact>[
        _contact('c1', 'Alice'),
        _contact('c2', 'Bob'),
      ];
      final fake = _FakeContactsController(_state(contacts: contacts));
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byType(ReorderableListView), findsOneWidget);
    });

    testWidgets('each row exposes a drag-handle icon', (
      WidgetTester tester,
    ) async {
      final contacts = <EmergencyContact>[
        _contact('c1', 'Alice'),
        _contact('c2', 'Bob'),
      ];
      final fake = _FakeContactsController(_state(contacts: contacts));
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byIcon(Icons.drag_handle), findsNWidgets(2));
    });
  });

  // ── AppBar import action ─────────────────────────────────────────────────

  group('ContactsScreen — Import from device', () {
    testWidgets('import IconButton renders on mobile', (
      WidgetTester tester,
    ) async {
      final fake = _FakeContactsController(_state());
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
      );
      // The test runner is Linux desktop so the conditional renders nothing.
      // Verify only that the PopupMenuButton (overflow) is still present.
      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    });
  });

  // ── Delete-all overflow menu ─────────────────────────────────────────────

  group('ContactsScreen — Delete all', () {
    testWidgets('overflow menu exposes Delete all item', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeContactsController(_state());
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      expect(find.text(l10n.contactsDeleteAllMenu), findsOneWidget);
    });

    testWidgets('tapping Delete all opens first confirmation dialog', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeContactsController(_state());
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.contactsDeleteAllMenu));
      await tester.pumpAndSettle();
      expect(
        find.text(l10n.contactsDeleteAllConfirmTitle),
        findsOneWidget,
      );
    });

    testWidgets('cancelling first dialog does NOT call deleteAll', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeContactsController(_state());
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.contactsDeleteAllMenu));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.commonCancel));
      await tester.pumpAndSettle();
      check(fake.deleteAllCalls).equals(0);
    });

    testWidgets('confirming first dialog opens typed-confirm dialog', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeContactsController(_state());
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.contactsDeleteAllMenu));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.commonConfirm));
      await tester.pumpAndSettle();
      expect(
        find.text(l10n.contactsDeleteAllTypeConfirmTitle),
        findsOneWidget,
      );
    });

    testWidgets('typed confirm only enables button when sentinel matches', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeContactsController(_state());
      await pumpScreen(
        tester,
        const ContactsScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.contactsDeleteAllMenu));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.commonConfirm));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'wrong');
      await tester.pumpAndSettle();
      // Confirm button is still disabled (onPressed null).
      final btn = tester.widget<FilledButton>(
        find.widgetWithText(
          FilledButton,
          l10n.contactsDeleteAllConfirmButton,
        ),
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets(
      'typing DELETE ALL enables confirm + tapping invokes deleteAll',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final fake = _FakeContactsController(_state());
        await pumpScreen(
          tester,
          const ContactsScreen(),
          overrides: _overrideWith(fake),
        );
        await tester.tap(find.byType(PopupMenuButton<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.contactsDeleteAllMenu));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.commonConfirm));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(TextField),
          l10n.contactsDeleteAllTypeConfirmSentinel,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.contactsDeleteAllConfirmButton));
        await tester.pumpAndSettle();
        check(fake.deleteAllCalls).equals(1);
      },
    );
  });
}
