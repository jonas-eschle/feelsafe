/// Widget tests for [DistressModesScreen].
///
/// Follows the reference pattern from
/// `test/features/home/home_screen_test.dart`:
/// 1. `_FakeDistressModesController` subclasses the real controller
///    and overrides `build()` to return a canned [DistressModesState].
/// 2. Each test calls `pumpScreen` or `_pumpWithRouter` (for navigation
///    assertions).
/// 3. Assertions use `find.byType`, `find.text`, l10n keys, `checks`.
///
/// Spec ref: `docs/spec/04-screens-navigation.md §Distress Modes Screen
/// (lines 1619–1644)`.
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/features/distress_modes/distress_modes_controller.dart';
import 'package:guardianangela/features/distress_modes/distress_modes_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Test fakes
// ---------------------------------------------------------------------------

class _FakeDistressModesController extends DistressModesController {
  _FakeDistressModesController(this._initial);

  final DistressModesState _initial;

  int createBlankCalls = 0;
  int duplicateCalls = 0;
  String? lastDuplicatedId;
  int setDefaultCalls = 0;
  String? lastSetDefaultId;
  int deleteCalls = 0;
  String? lastDeletedId;

  @override
  Future<DistressModesState> build() async => _initial;

  @override
  Future<String> createBlank() async {
    createBlankCalls++;
    return 'new-id';
  }

  @override
  Future<String> duplicate(String sourceId) async {
    duplicateCalls++;
    lastDuplicatedId = sourceId;
    return 'dup-id';
  }

  @override
  Future<void> setDefault(String id) async {
    setDefaultCalls++;
    lastSetDefaultId = id;
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      DistressModesState(
        modes: current.modes,
        defaultId: id,
        referencedIds: current.referencedIds,
      ),
    );
  }

  @override
  Future<void> delete(String id) async {
    deleteCalls++;
    lastDeletedId = id;
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      DistressModesState(
        modes: current.modes.where((m) => m.id != id).toList(),
        defaultId: current.defaultId,
        referencedIds: current.referencedIds,
      ),
    );
  }
}

/// Records routes pushed on the router's internal navigator.
class _FakeNavigatorObserver extends NavigatorObserver {
  final List<Route<Object?>> pushed = <Route<Object?>>[];

  @override
  void didPush(Route<Object?> route, Route<Object?>? previousRoute) =>
      pushed.add(route);
}

// ---------------------------------------------------------------------------
// Test data factories
// ---------------------------------------------------------------------------

/// Minimal distress-mode [ChainStep] for test fixtures.
ChainStep _step(String id) => ChainStep(
  id: id,
  type: ChainStepType.smsContact,
  order: 0,
  waitSeconds: 0,
  durationSeconds: 15,
  gracePeriodSeconds: 0,
  retryCount: 0,
  randomize: false,
);

/// Builds a [SessionMode] with `isDistressMode: true`.
SessionMode _mode(String id, String name) => SessionMode(
  id: id,
  name: name,
  isDistressMode: true,
  chainSteps: <ChainStep>[_step('$id-s0')],
);

DistressModesState _state({
  List<SessionMode>? modes,
  String? defaultId,
  Set<String>? referencedIds,
}) => DistressModesState(
  modes: modes ?? <SessionMode>[],
  defaultId: defaultId,
  referencedIds: referencedIds ?? <String>{},
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

List<Override> _overrideWith(_FakeDistressModesController fake) => <Override>[
  distressModesControllerProvider.overrideWith(() => fake),
];

/// Pumps [DistressModesScreen] inside a GoRouter so that
/// `context.pushNamed(...)` resolves without a "No GoRouter" error.
///
/// Two routes are registered:
/// - `/distress-modes` — renders [DistressModesScreen].
/// - `/distress-modes/edit` — stub destination (empty Scaffold).
///
/// The [observer] captures pushes on the internal navigator so tests
/// can assert that navigation occurred.
Future<void> _pumpWithRouter(
  WidgetTester tester, {
  required _FakeDistressModesController fake,
  required _FakeNavigatorObserver observer,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
}) async {
  final router = GoRouter(
    initialLocation: '/distress-modes',
    observers: <NavigatorObserver>[observer],
    routes: <RouteBase>[
      GoRoute(
        path: '/distress-modes',
        name: RouteNames.distressModes,
        builder: (ctx, st) => const DistressModesScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: 'edit',
            name: RouteNames.distressModeEditor,
            builder: (ctx, st) => const Scaffold(body: SizedBox.shrink()),
          ),
        ],
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        distressModesControllerProvider.overrideWith(() => fake),
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
  // ── AppBar ────────────────────────────────────────────────────────────────

  group('DistressModesScreen — AppBar', () {
    testWidgets('renders the distress-modes title in the AppBar', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeDistressModesController(_state());
      await pumpScreen(
        tester,
        const DistressModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.text(l10n.modesDistressTitle), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders FAB with modesAdd tooltip', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeDistressModesController(_state());
      await pumpScreen(
        tester,
        const DistressModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byTooltip(l10n.modesAdd), findsOneWidget);
    });

    testWidgets('FAB carries an add icon', (WidgetTester tester) async {
      final fake = _FakeDistressModesController(_state());
      await pumpScreen(
        tester,
        const DistressModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  // ── Async states ─────────────────────────────────────────────────────────

  group('DistressModesScreen — async states', () {
    testWidgets('shows CircularProgressIndicator while loading', (
      WidgetTester tester,
    ) async {
      final fake = _FakeDistressModesController(_state());
      await pumpScreen(
        tester,
        const DistressModesScreen(),
        overrides: _overrideWith(fake),
        settle: false,
      );
      // First frame: AsyncNotifier is still building.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('no loading spinner once async value resolves', (
      WidgetTester tester,
    ) async {
      final fake = _FakeDistressModesController(_state());
      await pumpScreen(
        tester,
        const DistressModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows error text when controller emits AsyncError', (
      WidgetTester tester,
    ) async {
      // Use a controller that hard-throws during build to produce AsyncError.
      final errorController = _ErrorDistressModesController();
      await pumpScreen(
        tester,
        const DistressModesScreen(),
        overrides: <Override>[
          distressModesControllerProvider.overrideWith(() => errorController),
        ],
      );
      final l10n = await loadL10n(const Locale('en'));
      expect(
        find.text(l10n.commonErrorWithDetail('Bad state: load failed')),
        findsOneWidget,
      );
    });
  });

  // ── Empty state ───────────────────────────────────────────────────────────

  group('DistressModesScreen — empty state', () {
    testWidgets('shows modesEmpty text when list is empty', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeDistressModesController(_state());
      await pumpScreen(
        tester,
        const DistressModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.text(l10n.distressModesEmpty), findsOneWidget);
    });

    testWidgets('no ListTile when list is empty', (WidgetTester tester) async {
      final fake = _FakeDistressModesController(_state());
      await pumpScreen(
        tester,
        const DistressModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byType(ListTile), findsNothing);
    });
  });

  // ── List tiles ────────────────────────────────────────────────────────────

  group('DistressModesScreen — list tiles', () {
    testWidgets('renders one ListTile per distress mode', (
      WidgetTester tester,
    ) async {
      final modes = <SessionMode>[
        _mode('d1', 'Silent Alert'),
        _mode('d2', 'Loud Alarm'),
      ];
      final fake = _FakeDistressModesController(_state(modes: modes));
      await pumpScreen(
        tester,
        const DistressModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byType(ListTile), findsNWidgets(2));
      expect(find.text('Silent Alert'), findsOneWidget);
      expect(find.text('Loud Alarm'), findsOneWidget);
    });

    testWidgets('each tile shows a warning icon as leading', (
      WidgetTester tester,
    ) async {
      final modes = <SessionMode>[_mode('d1', 'Alert')];
      final fake = _FakeDistressModesController(_state(modes: modes));
      await pumpScreen(
        tester,
        const DistressModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);
    });

    testWidgets('subtitle shows the step types joined by →', (
      WidgetTester tester,
    ) async {
      final mode = _mode('d1', 'Alert');
      final fake = _FakeDistressModesController(
        _state(modes: <SessionMode>[mode]),
      );
      await pumpScreen(
        tester,
        const DistressModesScreen(),
        overrides: _overrideWith(fake),
      );
      final expectedSubtitle = mode.chainSteps
          .map((s) => s.type.name)
          .join(' → ');
      expect(find.text(expectedSubtitle), findsOneWidget);
    });

    testWidgets('isDistressMode flag is true for all listed modes', (
      WidgetTester tester,
    ) async {
      // This test validates the test-fixture contract: _mode() sets
      // isDistressMode: true.
      final modes = <SessionMode>[_mode('d1', 'Alpha'), _mode('d2', 'Beta')];
      for (final m in modes) {
        check(m.isDistressMode).isTrue();
      }
      final fake = _FakeDistressModesController(_state(modes: modes));
      await pumpScreen(
        tester,
        const DistressModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byType(ListTile), findsNWidgets(2));
    });
  });

  // ── Default-mode indicator ────────────────────────────────────────────────

  group('DistressModesScreen — default badge', () {
    testWidgets('default mode shows star icon and Default badge', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final modes = <SessionMode>[_mode('d1', 'Alpha'), _mode('d2', 'Beta')];
      final fake = _FakeDistressModesController(
        _state(modes: modes, defaultId: 'd1'),
      );
      await pumpScreen(
        tester,
        const DistressModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text(l10n.modesDistressDefaultBadge), findsOneWidget);
    });

    testWidgets('non-default mode does not show star icon', (
      WidgetTester tester,
    ) async {
      final modes = <SessionMode>[_mode('d1', 'Alpha'), _mode('d2', 'Beta')];
      final fake = _FakeDistressModesController(
        _state(modes: modes, defaultId: 'd1'),
      );
      await pumpScreen(
        tester,
        const DistressModesScreen(),
        overrides: _overrideWith(fake),
      );
      // Only one star for the single default.
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('no star when defaultId is null', (WidgetTester tester) async {
      final modes = <SessionMode>[_mode('d1', 'Alpha')];
      final fake = _FakeDistressModesController(_state(modes: modes));
      await pumpScreen(
        tester,
        const DistressModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byIcon(Icons.star), findsNothing);
    });
  });

  // ── PopupMenu: Set as default ─────────────────────────────────────────────

  group('DistressModesScreen — Set as default action', () {
    testWidgets('non-default tile shows modesDistressSetDefault item', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final modes = <SessionMode>[_mode('d1', 'Default'), _mode('d2', 'Other')];
      final fake = _FakeDistressModesController(
        _state(modes: modes, defaultId: 'd1'),
      );
      await pumpScreen(
        tester,
        const DistressModesScreen(),
        overrides: _overrideWith(fake),
      );
      // Tap the PopupMenuButton in the 'Other' tile's trailing area.
      await tester.tap(
        find
            .descendant(
              of: find.ancestor(
                of: find.text('Other'),
                matching: find.byType(ListTile),
              ),
              matching: find.byType(PopupMenuButton<String>),
            )
            .first,
      );
      await tester.pumpAndSettle();
      expect(find.text(l10n.modesDistressSetDefault), findsOneWidget);
    });

    testWidgets('default tile does NOT show modesDistressSetDefault item', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final modes = <SessionMode>[_mode('d1', 'Default'), _mode('d2', 'Other')];
      final fake = _FakeDistressModesController(
        _state(modes: modes, defaultId: 'd1'),
      );
      await pumpScreen(
        tester,
        const DistressModesScreen(),
        overrides: _overrideWith(fake),
      );
      // Open popup for the default tile (d1 = 'Default').
      await tester.tap(
        find
            .descendant(
              of: find.ancestor(
                of: find.text('Default'),
                matching: find.byType(ListTile),
              ),
              matching: find.byType(PopupMenuButton<String>),
            )
            .first,
      );
      await tester.pumpAndSettle();
      expect(find.text(l10n.modesDistressSetDefault), findsNothing);
    });

    testWidgets('tapping Set as default calls controller.setDefault', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final modes = <SessionMode>[_mode('d1', 'First'), _mode('d2', 'Second')];
      final fake = _FakeDistressModesController(
        _state(modes: modes, defaultId: 'd1'),
      );
      await pumpScreen(
        tester,
        const DistressModesScreen(),
        overrides: _overrideWith(fake),
      );
      // Open popup on the non-default tile.
      await tester.tap(
        find
            .descendant(
              of: find.ancestor(
                of: find.text('Second'),
                matching: find.byType(ListTile),
              ),
              matching: find.byType(PopupMenuButton<String>),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.modesDistressSetDefault));
      await tester.pumpAndSettle();
      check(fake.setDefaultCalls).equals(1);
      check(fake.lastSetDefaultId).equals('d2');
    });
  });

  // ── PopupMenu: Delete ─────────────────────────────────────────────────────

  group('DistressModesScreen — delete action', () {
    testWidgets('delete item is disabled when only one mode exists', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final modes = <SessionMode>[_mode('d1', 'Only')];
      final fake = _FakeDistressModesController(
        _state(modes: modes, defaultId: 'd1'),
      );
      await pumpScreen(
        tester,
        const DistressModesScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.tap(
        find
            .descendant(
              of: find.ancestor(
                of: find.text('Only'),
                matching: find.byType(ListTile),
              ),
              matching: find.byType(PopupMenuButton<String>),
            )
            .first,
      );
      await tester.pumpAndSettle();
      final deleteItem = tester.widget<PopupMenuItem<String>>(
        find
            .ancestor(
              of: find.text(l10n.commonDelete),
              matching: find.byType(PopupMenuItem<String>),
            )
            .first,
      );
      check(deleteItem.enabled).isFalse();
    });

    testWidgets('delete item is disabled for the default mode', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final modes = <SessionMode>[_mode('d1', 'Default'), _mode('d2', 'Other')];
      final fake = _FakeDistressModesController(
        _state(modes: modes, defaultId: 'd1'),
      );
      await pumpScreen(
        tester,
        const DistressModesScreen(),
        overrides: _overrideWith(fake),
      );
      // Open popup on the default tile.
      await tester.tap(
        find
            .descendant(
              of: find.ancestor(
                of: find.text('Default'),
                matching: find.byType(ListTile),
              ),
              matching: find.byType(PopupMenuButton<String>),
            )
            .first,
      );
      await tester.pumpAndSettle();
      final deleteItem = tester.widget<PopupMenuItem<String>>(
        find
            .ancestor(
              of: find.text(l10n.commonDelete),
              matching: find.byType(PopupMenuItem<String>),
            )
            .first,
      );
      check(deleteItem.enabled).isFalse();
    });

    testWidgets('delete item is enabled for a non-default mode', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final modes = <SessionMode>[_mode('d1', 'Default'), _mode('d2', 'Other')];
      final fake = _FakeDistressModesController(
        _state(modes: modes, defaultId: 'd1'),
      );
      await pumpScreen(
        tester,
        const DistressModesScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.tap(
        find
            .descendant(
              of: find.ancestor(
                of: find.text('Other'),
                matching: find.byType(ListTile),
              ),
              matching: find.byType(PopupMenuButton<String>),
            )
            .first,
      );
      await tester.pumpAndSettle();
      final deleteItem = tester.widget<PopupMenuItem<String>>(
        find
            .ancestor(
              of: find.text(l10n.commonDelete),
              matching: find.byType(PopupMenuItem<String>),
            )
            .first,
      );
      check(deleteItem.enabled).isTrue();
    });

    testWidgets('tapping enabled delete calls controller.delete', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final modes = <SessionMode>[_mode('d1', 'Default'), _mode('d2', 'Other')];
      final fake = _FakeDistressModesController(
        _state(modes: modes, defaultId: 'd1'),
      );
      await pumpScreen(
        tester,
        const DistressModesScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.tap(
        find
            .descendant(
              of: find.ancestor(
                of: find.text('Other'),
                matching: find.byType(ListTile),
              ),
              matching: find.byType(PopupMenuButton<String>),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.commonDelete));
      await tester.pumpAndSettle();
      check(fake.deleteCalls).equals(1);
      check(fake.lastDeletedId).equals('d2');
    });

    testWidgets('delete tooltip explains why an in-use mode is locked', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final modes = <SessionMode>[_mode('d1', 'Default'), _mode('d2', 'Used')];
      final fake = _FakeDistressModesController(
        _state(modes: modes, defaultId: 'd1', referencedIds: <String>{'d2'}),
      );
      await pumpScreen(
        tester,
        const DistressModesScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.tap(
        find
            .descendant(
              of: find.ancestor(
                of: find.text('Used'),
                matching: find.byType(ListTile),
              ),
              matching: find.byType(PopupMenuButton<String>),
            )
            .first,
      );
      await tester.pumpAndSettle();

      final deleteItem = tester.widget<PopupMenuItem<String>>(
        find
            .ancestor(
              of: find.text(l10n.commonDelete),
              matching: find.byType(PopupMenuItem<String>),
            )
            .first,
      );
      check(deleteItem.enabled).isFalse();
      final tooltip = tester.widget<Tooltip>(
        find
            .ancestor(
              of: find.text(l10n.commonDelete),
              matching: find.byType(Tooltip),
            )
            .first,
      );
      check(tooltip.message).equals(l10n.modesDistressInUse);
    });

    testWidgets(
      'second line of defense: a delete selection on an in-use mode is '
      'refused with an explanation (no escalation of data loss)',
      (WidgetTester tester) async {
        // The menu item is disabled, so a user cannot normally select it;
        // drive the PopupMenuButton callback directly to pin the defensive
        // guard behind the disabled item.
        final l10n = await loadL10n(const Locale('en'));
        final modes = <SessionMode>[
          _mode('d1', 'Default'),
          _mode('d2', 'Used'),
        ];
        final fake = _FakeDistressModesController(
          _state(modes: modes, defaultId: 'd1', referencedIds: <String>{'d2'}),
        );
        await pumpScreen(
          tester,
          const DistressModesScreen(),
          overrides: _overrideWith(fake),
        );

        final button = tester.widget<PopupMenuButton<String>>(
          find
              .descendant(
                of: find.ancestor(
                  of: find.text('Used'),
                  matching: find.byType(ListTile),
                ),
                matching: find.byType(PopupMenuButton<String>),
              )
              .first,
        );
        button.onSelected?.call('delete');
        await tester.pumpAndSettle();

        // The mode is NOT deleted and the user is told why.
        check(fake.deleteCalls).equals(0);
        expect(find.text(l10n.modesDistressInUse), findsOneWidget);
      },
    );
  });

  // ── PopupMenu: Edit & Duplicate ───────────────────────────────────────────

  group('DistressModesScreen — Edit and Duplicate menu items', () {
    testWidgets('popup menu shows Edit and Duplicate items', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final modes = <SessionMode>[_mode('d1', 'First'), _mode('d2', 'Second')];
      final fake = _FakeDistressModesController(
        _state(modes: modes, defaultId: 'd1'),
      );
      await pumpScreen(
        tester,
        const DistressModesScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.tap(
        find
            .descendant(
              of: find.ancestor(
                of: find.text('Second'),
                matching: find.byType(ListTile),
              ),
              matching: find.byType(PopupMenuButton<String>),
            )
            .first,
      );
      await tester.pumpAndSettle();
      expect(find.text(l10n.commonEdit), findsOneWidget);
      expect(find.text(l10n.modesDuplicate), findsOneWidget);
    });

    testWidgets('tapping Duplicate calls controller.duplicate', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final modes = <SessionMode>[_mode('d1', 'Alpha'), _mode('d2', 'Beta')];
      final fake = _FakeDistressModesController(
        _state(modes: modes, defaultId: 'd1'),
      );
      await pumpScreen(
        tester,
        const DistressModesScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.tap(
        find
            .descendant(
              of: find.ancestor(
                of: find.text('Beta'),
                matching: find.byType(ListTile),
              ),
              matching: find.byType(PopupMenuButton<String>),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.modesDuplicate));
      await tester.pumpAndSettle();
      check(fake.duplicateCalls).equals(1);
      check(fake.lastDuplicatedId).equals('d2');
    });
  });

  // ── Navigation: FAB → create ──────────────────────────────────────────────

  group('DistressModesScreen — FAB navigation', () {
    testWidgets('tapping FAB calls createBlank and pushes editor route', (
      WidgetTester tester,
    ) async {
      final observer = _FakeNavigatorObserver();
      final fake = _FakeDistressModesController(_state());
      await _pumpWithRouter(tester, fake: fake, observer: observer);
      final countBefore = observer.pushed.length;
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      check(fake.createBlankCalls).equals(1);
      check(observer.pushed.length).isGreaterThan(countBefore);
    });
  });

  // ── Navigation: tap row → edit ────────────────────────────────────────────

  group('DistressModesScreen — row tap navigation', () {
    testWidgets('tapping a mode tile pushes the editor route', (
      WidgetTester tester,
    ) async {
      final observer = _FakeNavigatorObserver();
      final fake = _FakeDistressModesController(
        _state(modes: <SessionMode>[_mode('d1', 'Alert')], defaultId: 'd1'),
      );
      await _pumpWithRouter(tester, fake: fake, observer: observer);
      final countBefore = observer.pushed.length;
      await tester.tap(find.text('Alert'));
      await tester.pumpAndSettle();
      check(observer.pushed.length).isGreaterThan(countBefore);
    });
  });

  // ── Navigation: Edit menu item ────────────────────────────────────────────

  group('DistressModesScreen — Edit menu navigation', () {
    testWidgets('tapping Edit in popup pushes the editor route', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final observer = _FakeNavigatorObserver();
      final fake = _FakeDistressModesController(
        _state(
          modes: <SessionMode>[_mode('d1', 'Alpha'), _mode('d2', 'Beta')],
          defaultId: 'd1',
        ),
      );
      await _pumpWithRouter(tester, fake: fake, observer: observer);
      final countBefore = observer.pushed.length;
      await tester.tap(
        find
            .descendant(
              of: find.ancestor(
                of: find.text('Beta'),
                matching: find.byType(ListTile),
              ),
              matching: find.byType(PopupMenuButton<String>),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.commonEdit));
      await tester.pumpAndSettle();
      check(observer.pushed.length).isGreaterThan(countBefore);
    });
  });

  // ── RTL ───────────────────────────────────────────────────────────────────

  group('DistressModesScreen — RTL', () {
    testWidgets('renders in Arabic (RTL) without overflow', (
      WidgetTester tester,
    ) async {
      final modes = <SessionMode>[_mode('d1', 'Alert')];
      final fake = _FakeDistressModesController(
        _state(modes: modes, defaultId: 'd1'),
      );
      await pumpScreen(
        tester,
        const DistressModesScreen(),
        overrides: _overrideWith(fake),
        locale: const Locale('ar'),
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ── Dark mode ─────────────────────────────────────────────────────────────

  group('DistressModesScreen — dark mode', () {
    testWidgets('renders without exception in dark mode', (
      WidgetTester tester,
    ) async {
      final modes = <SessionMode>[_mode('d1', 'Alert')];
      final fake = _FakeDistressModesController(
        _state(modes: modes, defaultId: 'd1'),
      );
      await pumpScreen(
        tester,
        const DistressModesScreen(),
        overrides: _overrideWith(fake),
        themeMode: ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
    });
  });

  // ── Accessibility ─────────────────────────────────────────────────────────

  group('DistressModesScreen — accessibility', () {
    testWidgets('FAB tooltip is accessible via Semantics', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeDistressModesController(_state());
      await pumpScreen(
        tester,
        const DistressModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byTooltip(l10n.modesAdd), findsOneWidget);
    });

    testWidgets('popup menu button is reachable for all listed tiles', (
      WidgetTester tester,
    ) async {
      final modes = <SessionMode>[_mode('d1', 'Alpha'), _mode('d2', 'Beta')];
      final fake = _FakeDistressModesController(
        _state(modes: modes, defaultId: 'd1'),
      );
      await pumpScreen(
        tester,
        const DistressModesScreen(),
        overrides: _overrideWith(fake),
      );
      // One PopupMenuButton per tile.
      expect(find.byType(PopupMenuButton<String>), findsNWidgets(2));
    });
  });
}

// ---------------------------------------------------------------------------
// Error-state fake
// ---------------------------------------------------------------------------

/// Controller that throws during [build] so the screen shows an
/// AsyncError body.
class _ErrorDistressModesController extends DistressModesController {
  @override
  Future<DistressModesState> build() async => throw StateError('load failed');
}
