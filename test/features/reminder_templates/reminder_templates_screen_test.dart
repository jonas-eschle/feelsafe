/// Widget tests for [ReminderTemplatesScreen].
///
/// Follows the reference pattern from
/// `test/features/home/home_screen_test.dart`:
/// 1. A [_FakeReminderTemplatesController] subclasses the real controller and
///    overrides `build()` to return a canned [ReminderTemplatesState].
/// 2. Each test calls `pumpScreen` or `_pumpWithRouter` as appropriate.
/// 3. Assertions use `find.byType`, l10n keys, and a
///    [_FakeNavigatorObserver] for navigation assertions.
///
/// Spec ref: `docs/spec/04-screens-navigation.md §Templates Screen`.
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/features/reminder_templates/reminder_templates_controller.dart';
import 'package:guardianangela/features/reminder_templates/reminder_templates_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Test fakes
// ---------------------------------------------------------------------------

/// Controller whose build throws — drives the AsyncValue error branch.
class _ErrorReminderTemplatesController extends ReminderTemplatesController {
  @override
  Future<ReminderTemplatesState> build() async => throw Exception('db failure');
}

class _FakeReminderTemplatesController extends ReminderTemplatesController {
  _FakeReminderTemplatesController(this._initial);

  final ReminderTemplatesState _initial;

  int duplicateCalls = 0;
  String? lastDuplicateId;
  int deleteCalls = 0;
  String? lastDeletedId;

  @override
  Future<ReminderTemplatesState> build() async => _initial;

  @override
  Future<String> duplicate(String sourceId) async {
    duplicateCalls++;
    lastDuplicateId = sourceId;
    return 'new-id';
  }

  @override
  Future<void> delete(String id) async {
    deleteCalls++;
    lastDeletedId = id;
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      ReminderTemplatesState(
        templates: current.templates.where((t) => t.id != id).toList(),
      ),
    );
  }
}

/// Records routes pushed via GoRouter's navigator.
class _FakeNavigatorObserver extends NavigatorObserver {
  final List<Route<Object?>> pushed = <Route<Object?>>[];

  @override
  void didPush(Route<Object?> route, Route<Object?>? previousRoute) =>
      pushed.add(route);
}

// ---------------------------------------------------------------------------
// Test data factories
// ---------------------------------------------------------------------------

ReminderTemplate _template(String id, String name, {bool isCustom = false}) =>
    ReminderTemplate(
      id: id,
      name: name,
      title: '$name title',
      body: '$name body',
      confirmationType: ConfirmationType.dismiss,
      isCustom: isCustom,
      displayStyle: ReminderDisplayStyle.subtle,
      isGlobal: true,
    );

/// Eight seed templates matching the built-in set count.
List<ReminderTemplate> _seedTemplates() => List<ReminderTemplate>.generate(
  8,
  (int i) => _template('seed-$i', 'Seed $i'),
);

ReminderTemplatesState _state({List<ReminderTemplate>? templates}) =>
    ReminderTemplatesState(templates: templates ?? <ReminderTemplate>[]);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

List<Override> _overrideWith(_FakeReminderTemplatesController fake) =>
    <Override>[reminderTemplatesControllerProvider.overrideWith(() => fake)];

/// Pumps [ReminderTemplatesScreen] inside a minimal GoRouter.
///
/// The router exposes two routes so that `context.pushNamed(...)` can
/// resolve without a "No GoRouter" error:
/// - `/settings/reminder-templates` — renders [ReminderTemplatesScreen].
/// - `/settings/templates/edit` — renders a stub [Scaffold].
///
/// The [observer] is attached to the router's navigator so tests can
/// assert navigation occurred.
Future<void> _pumpWithRouter(
  WidgetTester tester, {
  required _FakeReminderTemplatesController fake,
  required _FakeNavigatorObserver observer,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
}) async {
  final router = GoRouter(
    initialLocation: '/settings/reminder-templates',
    observers: <NavigatorObserver>[observer],
    routes: <RouteBase>[
      GoRoute(
        path: '/settings/reminder-templates',
        name: RouteNames.settingsReminderTemplates,
        builder: (_, _) => const ReminderTemplatesScreen(),
      ),
      GoRoute(
        path: '/settings/templates/edit',
        name: RouteNames.templateEditor,
        // Surfaces the id query param so tests can pin WHICH template
        // the screen opened the editor for ('new' on create-from-scratch).
        builder: (_, GoRouterState state) => Scaffold(
          body: Text('editor:${state.uri.queryParameters['id'] ?? 'new'}'),
        ),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        reminderTemplatesControllerProvider.overrideWith(() => fake),
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
  // ── AppBar ─────────────────────────────────────────────────────────────────

  group('ReminderTemplatesScreen — AppBar', () {
    testWidgets('renders app bar with templatesTitle', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeReminderTemplatesController(_state());
      await pumpScreen(
        tester,
        const ReminderTemplatesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.text(l10n.templatesTitle), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders exactly one AppBar', (WidgetTester tester) async {
      final fake = _FakeReminderTemplatesController(
        _state(templates: _seedTemplates()),
      );
      await pumpScreen(
        tester,
        const ReminderTemplatesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byType(AppBar), findsOneWidget);
    });
  });

  // ── FAB ────────────────────────────────────────────────────────────────────

  group('ReminderTemplatesScreen — FAB', () {
    testWidgets('shows FloatingActionButton', (WidgetTester tester) async {
      final fake = _FakeReminderTemplatesController(_state());
      await pumpScreen(
        tester,
        const ReminderTemplatesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('FAB carries templatesCreate tooltip', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeReminderTemplatesController(_state());
      await pumpScreen(
        tester,
        const ReminderTemplatesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byTooltip(l10n.templatesCreate), findsOneWidget);
    });

    testWidgets('FAB has an add icon', (WidgetTester tester) async {
      // Use a non-empty list so the empty-state CTA (also +) doesn't
      // double-count the FAB icon.
      final fake = _FakeReminderTemplatesController(
        _state(templates: _seedTemplates()),
      );
      await pumpScreen(
        tester,
        const ReminderTemplatesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('tapping FAB navigates to templateEditor route', (
      WidgetTester tester,
    ) async {
      final observer = _FakeNavigatorObserver();
      final fake = _FakeReminderTemplatesController(_state());
      await _pumpWithRouter(tester, fake: fake, observer: observer);
      final countBefore = observer.pushed.length;
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      check(observer.pushed.length).isGreaterThan(countBefore);
    });
  });

  // ── FAB add sheet ──────────────────────────────────────────────────────────

  group('ReminderTemplatesScreen — FAB add sheet', () {
    testWidgets('"From scratch" opens the editor without an id', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final observer = _FakeNavigatorObserver();
      final fake = _FakeReminderTemplatesController(
        _state(templates: _seedTemplates()),
      );
      await _pumpWithRouter(tester, fake: fake, observer: observer);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.templatesAddFromScratch));
      await tester.pumpAndSettle();

      expect(find.text('editor:new'), findsOneWidget);
      check(fake.duplicateCalls).equals(0);
    });

    testWidgets('dismissing the sheet via barrier opens nothing', (
      WidgetTester tester,
    ) async {
      final fake = _FakeReminderTemplatesController(
        _state(templates: _seedTemplates()),
      );
      final observer = _FakeNavigatorObserver();
      await _pumpWithRouter(tester, fake: fake, observer: observer);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      // Tap the modal barrier above the sheet to dismiss with a null choice.
      await tester.tapAt(const Offset(400, 20));
      await tester.pumpAndSettle();

      expect(find.textContaining('editor:'), findsNothing);
      check(fake.duplicateCalls).equals(0);
    });

    testWidgets('"From template" lists only built-ins in the picker', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final templates = <ReminderTemplate>[
        _template('b1', 'Calendar'),
        _template('c1', 'My Custom', isCustom: true),
      ];
      final fake = _FakeReminderTemplatesController(
        _state(templates: templates),
      );
      final observer = _FakeNavigatorObserver();
      await _pumpWithRouter(tester, fake: fake, observer: observer);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.templatesAddFromTemplate));
      await tester.pumpAndSettle();

      expect(find.text(l10n.templatesPickFromBuiltinTitle), findsOneWidget);
      // The picker sheet shows the built-in but NOT the custom template.
      // ('Calendar' appears twice: once in the list row behind the sheet,
      // once inside the picker.)
      expect(find.text('Calendar'), findsNWidgets(2));
      expect(find.text('My Custom'), findsOneWidget); // list row only
      check(fake.duplicateCalls).equals(0);
    });

    testWidgets('picking a built-in duplicates it and opens its editor', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeReminderTemplatesController(
        _state(templates: <ReminderTemplate>[_template('b1', 'Calendar')]),
      );
      final observer = _FakeNavigatorObserver();
      await _pumpWithRouter(tester, fake: fake, observer: observer);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.templatesAddFromTemplate));
      await tester.pumpAndSettle();
      // Tap the built-in row INSIDE the picker sheet (the list row behind
      // the sheet shows the same name).
      await tester.tap(find.text('Calendar').last);
      await tester.pumpAndSettle();

      // The clone (isCustom=true) was created from the picked source …
      check(fake.duplicateCalls).equals(1);
      check(fake.lastDuplicateId).equals('b1');
      // … and the editor opened on the freshly minted id.
      expect(find.text('editor:new-id'), findsOneWidget);
    });

    testWidgets('dismissing the built-in picker duplicates nothing', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeReminderTemplatesController(
        _state(templates: <ReminderTemplate>[_template('b1', 'Calendar')]),
      );
      final observer = _FakeNavigatorObserver();
      await _pumpWithRouter(tester, fake: fake, observer: observer);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.templatesAddFromTemplate));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(400, 20));
      await tester.pumpAndSettle();

      check(fake.duplicateCalls).equals(0);
      expect(find.textContaining('editor:'), findsNothing);
    });
  });

  // ── Empty state CTA ────────────────────────────────────────────────────────

  group('ReminderTemplatesScreen — empty state CTA', () {
    testWidgets('Add-first button opens the create editor', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeReminderTemplatesController(_state());
      final observer = _FakeNavigatorObserver();
      await _pumpWithRouter(tester, fake: fake, observer: observer);

      await tester.tap(find.text(l10n.templatesEmptyAddFirst));
      await tester.pumpAndSettle();

      expect(find.text('editor:new'), findsOneWidget);
    });
  });

  // ── Async states ───────────────────────────────────────────────────────────

  group('ReminderTemplatesScreen — async states', () {
    testWidgets('shows CircularProgressIndicator on the first frame', (
      WidgetTester tester,
    ) async {
      final fake = _FakeReminderTemplatesController(_state());
      await pumpScreen(
        tester,
        const ReminderTemplatesScreen(),
        overrides: _overrideWith(fake),
        settle: false,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('no spinner once provider resolves', (
      WidgetTester tester,
    ) async {
      final fake = _FakeReminderTemplatesController(_state());
      await pumpScreen(
        tester,
        const ReminderTemplatesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('error state renders error message', (
      WidgetTester tester,
    ) async {
      // A build()-throwing controller drives the REAL AsyncError branch.
      // (Assigning AsyncError to a just-constructed notifier inside the
      // override factory never arrived — the screen rendered Riverpod's
      // "uninitialized state" error instead, which the old
      // textContaining('Error:') assert matched vacuously.)
      await pumpScreen(
        tester,
        const ReminderTemplatesScreen(),
        overrides: <Override>[
          reminderTemplatesControllerProvider.overrideWith(
            _ErrorReminderTemplatesController.new,
          ),
        ],
      );
      final l10n = await loadL10n(const Locale('en'));
      expect(
        find.text(l10n.commonErrorWithDetail('Exception: db failure')),
        findsOneWidget,
      );
    });
  });

  // ── Empty state ────────────────────────────────────────────────────────────

  group('ReminderTemplatesScreen — empty state', () {
    testWidgets('shows templatesEmpty when list is empty', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeReminderTemplatesController(_state());
      await pumpScreen(
        tester,
        const ReminderTemplatesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.text(l10n.templatesEmpty), findsOneWidget);
    });

    testWidgets('no ListTile when list is empty', (WidgetTester tester) async {
      final fake = _FakeReminderTemplatesController(_state());
      await pumpScreen(
        tester,
        const ReminderTemplatesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byType(ListTile), findsNothing);
    });
  });

  // ── List rendering ─────────────────────────────────────────────────────────

  group('ReminderTemplatesScreen — list rendering', () {
    testWidgets('renders at least one Card per visible seed', (
      WidgetTester tester,
    ) async {
      final seeds = _seedTemplates();
      final fake = _FakeReminderTemplatesController(_state(templates: seeds));
      await pumpScreen(
        tester,
        const ReminderTemplatesScreen(),
        overrides: _overrideWith(fake),
      );
      // ListView.builder only renders visible items; the first page
      // will have at least 1 card and at most 8.
      expect(find.byType(Card), findsAtLeastNWidgets(1));
    });

    testWidgets('renders the first seed template name', (
      WidgetTester tester,
    ) async {
      final seeds = _seedTemplates();
      final fake = _FakeReminderTemplatesController(_state(templates: seeds));
      await pumpScreen(
        tester,
        const ReminderTemplatesScreen(),
        overrides: _overrideWith(fake),
      );
      // Seed 0 is the first item — always visible on first render.
      expect(find.text(seeds.first.name), findsOneWidget);
    });

    testWidgets('subtitle shows title • body for each template', (
      WidgetTester tester,
    ) async {
      final t = _template('t1', 'Calendar');
      final fake = _FakeReminderTemplatesController(
        _state(templates: <ReminderTemplate>[t]),
      );
      await pumpScreen(
        tester,
        const ReminderTemplatesScreen(),
        overrides: _overrideWith(fake),
      );
      // Subtitle is rendered as "${t.title} • ${t.body}".
      expect(find.text('${t.title} • ${t.body}'), findsOneWidget);
    });

    testWidgets('each row has a notification icon in the leading', (
      WidgetTester tester,
    ) async {
      final fake = _FakeReminderTemplatesController(
        _state(templates: <ReminderTemplate>[_template('t1', 'Cal')]),
      );
      await pumpScreen(
        tester,
        const ReminderTemplatesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('user-added template is included in the visible list', (
      WidgetTester tester,
    ) async {
      // Use only a small set so everything fits in the viewport.
      final templates = <ReminderTemplate>[
        _template('s1', 'Alpha'),
        _template('custom-1', 'My Custom', isCustom: true),
      ];
      final fake = _FakeReminderTemplatesController(
        _state(templates: templates),
      );
      await pumpScreen(
        tester,
        const ReminderTemplatesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byType(Card), findsNWidgets(templates.length));
      expect(find.text('My Custom'), findsOneWidget);
    });

    testWidgets('each row exposes a PopupMenuButton', (
      WidgetTester tester,
    ) async {
      final templates = <ReminderTemplate>[
        _template('t1', 'Alpha'),
        _template('t2', 'Beta'),
      ];
      final fake = _FakeReminderTemplatesController(
        _state(templates: templates),
      );
      await pumpScreen(
        tester,
        const ReminderTemplatesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(
        find.byType(PopupMenuButton<String>),
        findsNWidgets(templates.length),
      );
    });
  });

  // ── Popup menu — Edit ──────────────────────────────────────────────────────

  group('ReminderTemplatesScreen — popup Edit', () {
    testWidgets('tapping Edit in popup navigates to templateEditor route', (
      WidgetTester tester,
    ) async {
      final observer = _FakeNavigatorObserver();
      final fake = _FakeReminderTemplatesController(
        _state(templates: <ReminderTemplate>[_template('t1', 'Calendar')]),
      );
      await _pumpWithRouter(tester, fake: fake, observer: observer);
      final countBefore = observer.pushed.length;
      // Open the popup.
      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      final l10n = await loadL10n(const Locale('en'));
      await tester.tap(find.text(l10n.commonEdit));
      await tester.pumpAndSettle();
      check(observer.pushed.length).isGreaterThan(countBefore);
    });
  });

  // ── Popup menu — Duplicate ─────────────────────────────────────────────────

  group('ReminderTemplatesScreen — popup Duplicate', () {
    testWidgets('tapping Duplicate calls controller.duplicate', (
      WidgetTester tester,
    ) async {
      final t = _template('t1', 'Calendar');
      final fake = _FakeReminderTemplatesController(
        _state(templates: <ReminderTemplate>[t]),
      );
      await pumpScreen(
        tester,
        const ReminderTemplatesScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      final l10n = await loadL10n(const Locale('en'));
      await tester.tap(find.text(l10n.modesDuplicate));
      await tester.pumpAndSettle();
      check(fake.duplicateCalls).equals(1);
      check(fake.lastDuplicateId).equals('t1');
    });
  });

  // ── Popup menu — Delete ────────────────────────────────────────────────────

  group('ReminderTemplatesScreen — popup Delete (custom)', () {
    testWidgets('tapping Delete on a custom template calls delete', (
      WidgetTester tester,
    ) async {
      final custom = _template('c1', 'My Custom', isCustom: true);
      final fake = _FakeReminderTemplatesController(
        _state(templates: <ReminderTemplate>[custom]),
      );
      await pumpScreen(
        tester,
        const ReminderTemplatesScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      final l10n = await loadL10n(const Locale('en'));
      await tester.tap(find.text(l10n.commonDelete));
      await tester.pumpAndSettle();
      // Confirm dialog now appears; tap the Delete FilledButton inside it.
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(l10n.commonDelete),
        ),
      );
      await tester.pumpAndSettle();
      check(fake.deleteCalls).equals(1);
      check(fake.lastDeletedId).equals('c1');
    });

    testWidgets('cancelling the delete dialog leaves the template intact', (
      WidgetTester tester,
    ) async {
      final custom = _template('c1', 'My Custom', isCustom: true);
      final fake = _FakeReminderTemplatesController(
        _state(templates: <ReminderTemplate>[custom]),
      );
      await pumpScreen(
        tester,
        const ReminderTemplatesScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      final l10n = await loadL10n(const Locale('en'));
      await tester.tap(find.text(l10n.commonDelete));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.commonCancel));
      await tester.pumpAndSettle();
      check(fake.deleteCalls).equals(0);
    });

    testWidgets('Delete menu item is disabled for built-in templates', (
      WidgetTester tester,
    ) async {
      // Built-in: isCustom defaults to false.
      final builtin = _template('b1', 'Duolingo');
      final fake = _FakeReminderTemplatesController(
        _state(templates: <ReminderTemplate>[builtin]),
      );
      await pumpScreen(
        tester,
        const ReminderTemplatesScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      final l10n = await loadL10n(const Locale('en'));
      final deleteItem = tester.widget<PopupMenuItem<String>>(
        find.ancestor(
          of: find.text(l10n.commonDelete),
          matching: find.byType(PopupMenuItem<String>),
        ),
      );
      check(deleteItem.enabled).isFalse();
    });

    testWidgets('tapping disabled Delete on built-in does NOT call delete', (
      WidgetTester tester,
    ) async {
      final builtin = _template('b1', 'Calendar');
      final fake = _FakeReminderTemplatesController(
        _state(templates: <ReminderTemplate>[builtin]),
      );
      await pumpScreen(
        tester,
        const ReminderTemplatesScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      // Really tap the disabled Delete item. The gesture must be inert:
      // the menu stays open (a selection would dismiss it), no confirm
      // dialog appears, and the controller is never called.
      final l10n = await loadL10n(const Locale('en'));
      await tester.tap(find.text(l10n.commonDelete), warnIfMissed: false);
      await tester.pumpAndSettle();
      check(find.byType(AlertDialog).evaluate()).isEmpty();
      check(find.text(l10n.commonDelete).evaluate()).isNotEmpty();
      check(fake.deleteCalls).equals(0);
    });
  });

  // ── Row tap → navigate ──────────────────────────────────────────────────────

  group('ReminderTemplatesScreen — row tap navigation', () {
    testWidgets('tapping a row navigates to templateEditor', (
      WidgetTester tester,
    ) async {
      final observer = _FakeNavigatorObserver();
      final fake = _FakeReminderTemplatesController(
        _state(templates: <ReminderTemplate>[_template('t1', 'Calendar')]),
      );
      await _pumpWithRouter(tester, fake: fake, observer: observer);
      final countBefore = observer.pushed.length;
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();
      check(observer.pushed.length).isGreaterThan(countBefore);
    });
  });

  // ── RTL ────────────────────────────────────────────────────────────────────

  group('ReminderTemplatesScreen — RTL', () {
    testWidgets('renders in Arabic (RTL) without overflow', (
      WidgetTester tester,
    ) async {
      final fake = _FakeReminderTemplatesController(
        _state(templates: _seedTemplates()),
      );
      await pumpScreen(
        tester,
        const ReminderTemplatesScreen(),
        overrides: _overrideWith(fake),
        locale: const Locale('ar'),
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ── Dark mode ──────────────────────────────────────────────────────────────

  group('ReminderTemplatesScreen — dark mode', () {
    testWidgets('renders without exception in dark mode', (
      WidgetTester tester,
    ) async {
      final fake = _FakeReminderTemplatesController(
        _state(templates: _seedTemplates()),
      );
      await pumpScreen(
        tester,
        const ReminderTemplatesScreen(),
        overrides: _overrideWith(fake),
        themeMode: ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
    });
  });

  // ── Accessibility ──────────────────────────────────────────────────────────

  group('ReminderTemplatesScreen — accessibility', () {
    testWidgets('FAB tooltip satisfies accessibility label requirement', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeReminderTemplatesController(_state());
      await pumpScreen(
        tester,
        const ReminderTemplatesScreen(),
        overrides: _overrideWith(fake),
      );
      // byTooltip verifies the tooltip/semantic label is present.
      expect(find.byTooltip(l10n.templatesCreate), findsOneWidget);
    });

    testWidgets('semantics tree is present and no exceptions are thrown', (
      WidgetTester tester,
    ) async {
      final handle = tester.binding.ensureSemantics();
      final fake = _FakeReminderTemplatesController(
        _state(templates: _seedTemplates()),
      );
      await pumpScreen(
        tester,
        const ReminderTemplatesScreen(),
        overrides: _overrideWith(fake),
      );
      // Verify at least one semantics node is reachable.
      expect(tester.getSemantics(find.byType(AppBar)), isNotNull);
      handle.dispose();
      expect(tester.takeException(), isNull);
    });
  });
}
