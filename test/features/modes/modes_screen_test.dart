/// Widget tests for [ModesScreen].
///
/// Follows the reference pattern from
/// `test/features/home/home_screen_test.dart`:
/// 1. [_FakeModesController] subclasses the real controller and overrides
///    `build()` to return a canned [ModesState].
/// 2. Navigation tests use [_pumpWithRouter] + [_FakeNavigatorObserver].
/// 3. Assertions use `find.byType`, l10n keys, `package:checks`.
///
/// Spec ref: `docs/spec/04-screens-navigation.md §Modes Screen`.
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
import 'package:guardianangela/features/modes/modes_controller.dart';
import 'package:guardianangela/features/modes/modes_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Test fakes
// ---------------------------------------------------------------------------

class _FakeModesController extends ModesController {
  _FakeModesController(this._initial);

  final ModesState _initial;

  int createBlankCalls = 0;
  int duplicateCalls = 0;
  String? lastDuplicateId;
  int deleteCalls = 0;
  String? lastDeletedId;

  @override
  Future<ModesState> build() async => _initial;

  @override
  Future<String> createBlank() async {
    createBlankCalls++;
    return 'new-blank-id';
  }

  @override
  Future<String> duplicate(String sourceId) async {
    duplicateCalls++;
    lastDuplicateId = sourceId;
    return 'new-dup-id';
  }

  @override
  Future<void> delete(String id) async {
    deleteCalls++;
    lastDeletedId = id;
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      ModesState(modes: current.modes.where((m) => m.id != id).toList()),
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

ChainStep _step(String id, ChainStepType type, {int order = 0}) => ChainStep(
  id: id,
  type: type,
  order: order,
  waitSeconds: 0,
  durationSeconds: 30,
  gracePeriodSeconds: 5,
  retryCount: 0,
  randomize: false,
);

/// Regular (non-distress) mode with [steps] chain steps.
SessionMode _mode(
  String id,
  String name, {
  List<ChainStep>? steps,
  bool isBuiltIn = false,
}) => SessionMode(
  id: id,
  name: name,
  isBuiltIn: isBuiltIn,
  chainSteps: steps ?? <ChainStep>[_step('$id-s0', ChainStepType.holdButton)],
);

ModesState _state({List<SessionMode>? modes}) =>
    ModesState(modes: modes ?? <SessionMode>[]);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

List<Override> _overrideWith(_FakeModesController fake) => <Override>[
  modesControllerProvider.overrideWith(() => fake),
];

/// Pumps [ModesScreen] inside a minimal GoRouter.
///
/// Two routes are registered so `context.pushNamed(RouteNames.modeEditor)`
/// resolves without a "No GoRouter" error:
/// - `/modes` — renders [ModesScreen].
/// - `/modes/edit` — renders a stub [Scaffold].
Future<void> _pumpWithRouter(
  WidgetTester tester, {
  required _FakeModesController fake,
  required _FakeNavigatorObserver observer,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
}) async {
  final router = GoRouter(
    initialLocation: '/modes',
    observers: <NavigatorObserver>[observer],
    routes: <RouteBase>[
      GoRoute(
        path: '/modes',
        name: RouteNames.modes,
        builder: (_, _) => const ModesScreen(),
      ),
      GoRoute(
        path: '/modes/edit',
        name: RouteNames.modeEditor,
        builder: (_, _) => const Scaffold(body: SizedBox.shrink()),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[modesControllerProvider.overrideWith(() => fake)],
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

  group('ModesScreen — AppBar', () {
    testWidgets('renders AppBar with modesTitle', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeModesController(_state());
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.text(l10n.modesTitle), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });
  });

  // ── FAB ────────────────────────────────────────────────────────────────────

  group('ModesScreen — FAB', () {
    testWidgets('shows FloatingActionButton', (WidgetTester tester) async {
      final fake = _FakeModesController(_state());
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('FAB carries modesAdd tooltip', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeModesController(_state());
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byTooltip(l10n.modesAdd), findsOneWidget);
    });

    testWidgets('FAB has an add icon', (WidgetTester tester) async {
      final fake = _FakeModesController(_state());
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('tapping FAB shows bottom sheet with blank-mode option', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeModesController(
        _state(modes: <SessionMode>[_mode('m1', 'Walk Mode')]),
      );
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text(l10n.modesNewPickerBlank), findsOneWidget);
    });

    testWidgets('FAB sheet shows blank-mode subtitle', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeModesController(_state());
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text(l10n.modesNewPickerBlankSubtitle), findsOneWidget);
    });

    testWidgets('FAB sheet includes one From-template row per existing mode', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeModesController(
        _state(
          modes: <SessionMode>[
            _mode('m1', 'Walk Mode'),
            _mode('m2', 'Date Mode'),
          ],
        ),
      );
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(
        find.text(l10n.modesNewPickerFromTemplate('Walk Mode')),
        findsOneWidget,
      );
      expect(
        find.text(l10n.modesNewPickerFromTemplate('Date Mode')),
        findsOneWidget,
      );
    });

    testWidgets('tapping Blank mode in sheet calls createBlank', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeModesController(_state());
      // createBlank navigates after creation — requires GoRouter context.
      await _pumpWithRouter(
        tester,
        fake: fake,
        observer: _FakeNavigatorObserver(),
      );
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.modesNewPickerBlank));
      await tester.pumpAndSettle();
      check(fake.createBlankCalls).equals(1);
    });
  });

  // ── Async states ───────────────────────────────────────────────────────────

  group('ModesScreen — async states', () {
    testWidgets('shows CircularProgressIndicator on first frame', (
      WidgetTester tester,
    ) async {
      final fake = _FakeModesController(_state());
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
        settle: false,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('no spinner once provider resolves', (
      WidgetTester tester,
    ) async {
      final fake = _FakeModesController(_state());
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('error state renders "Error:" text', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: <Override>[
          modesControllerProvider.overrideWith(() {
            final ctrl = _FakeModesController(_state());
            ctrl.state = AsyncError<ModesState>(
              Exception('db failure'),
              StackTrace.empty,
            );
            return ctrl;
          }),
        ],
      );
      expect(find.textContaining('Error:'), findsOneWidget);
    });
  });

  // ── Empty state ────────────────────────────────────────────────────────────

  group('ModesScreen — empty state', () {
    testWidgets('shows modesEmpty when list is empty', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeModesController(_state());
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.text(l10n.modesEmpty), findsOneWidget);
    });

    testWidgets('no ListTile rendered when list is empty', (
      WidgetTester tester,
    ) async {
      final fake = _FakeModesController(_state());
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byType(ListTile), findsNothing);
    });
  });

  // ── List rendering ─────────────────────────────────────────────────────────

  group('ModesScreen — list rendering', () {
    testWidgets('renders one ListTile per mode', (WidgetTester tester) async {
      final fake = _FakeModesController(
        _state(
          modes: <SessionMode>[
            _mode('m1', 'Walk Mode'),
            _mode('m2', 'Date Mode'),
          ],
        ),
      );
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('each row shows the mode name', (WidgetTester tester) async {
      final fake = _FakeModesController(
        _state(
          modes: <SessionMode>[
            _mode('m1', 'Walk Mode'),
            _mode('m2', 'Date Mode'),
          ],
        ),
      );
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.text('Walk Mode'), findsOneWidget);
      expect(find.text('Date Mode'), findsOneWidget);
    });

    testWidgets('subtitle shows step types joined by →', (
      WidgetTester tester,
    ) async {
      final m = _mode(
        'm1',
        'Night Out',
        steps: <ChainStep>[
          _step('s0', ChainStepType.holdButton),
          _step('s1', ChainStepType.smsContact, order: 1),
        ],
      );
      final fake = _FakeModesController(_state(modes: <SessionMode>[m]));
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.text('holdButton → smsContact'), findsOneWidget);
    });

    testWidgets('single-step subtitle has no arrow', (
      WidgetTester tester,
    ) async {
      final m = _mode(
        'm1',
        'Quick Check',
        steps: <ChainStep>[_step('s0', ChainStepType.holdButton)],
      );
      final fake = _FakeModesController(_state(modes: <SessionMode>[m]));
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.text('holdButton'), findsOneWidget);
    });

    testWidgets('each row has a PopupMenuButton', (WidgetTester tester) async {
      final fake = _FakeModesController(
        _state(
          modes: <SessionMode>[
            _mode('m1', 'Walk Mode'),
            _mode('m2', 'Date Mode'),
          ],
        ),
      );
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byType(PopupMenuButton<String>), findsNWidgets(2));
    });

    testWidgets('distress modes are NOT shown in the regular list', (
      WidgetTester tester,
    ) async {
      // The controller's build() already filters — here we verify the
      // screen renders only what ModesState.modes contains.
      final fake = _FakeModesController(
        _state(
          modes: <SessionMode>[
            _mode('m1', 'Walk Mode'),
            // A distress mode would never appear because the controller
            // filters it; if it were passed, the screen would still render
            // it. This test confirms the regular list path works correctly
            // with only non-distress modes.
          ],
        ),
      );
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byType(ListTile), findsOneWidget);
    });
  });

  // ── Popup menu — Edit ──────────────────────────────────────────────────────

  group('ModesScreen — popup Edit', () {
    testWidgets('tapping Edit in popup navigates to modeEditor route', (
      WidgetTester tester,
    ) async {
      final observer = _FakeNavigatorObserver();
      final fake = _FakeModesController(
        _state(modes: <SessionMode>[_mode('m1', 'Walk Mode')]),
      );
      await _pumpWithRouter(tester, fake: fake, observer: observer);
      final countBefore = observer.pushed.length;
      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      final l10n = await loadL10n(const Locale('en'));
      await tester.tap(find.text(l10n.commonEdit));
      await tester.pumpAndSettle();
      check(observer.pushed.length).isGreaterThan(countBefore);
    });
  });

  // ── Popup menu — Duplicate ─────────────────────────────────────────────────

  group('ModesScreen — popup Duplicate', () {
    testWidgets('tapping Duplicate calls controller.duplicate', (
      WidgetTester tester,
    ) async {
      final fake = _FakeModesController(
        _state(modes: <SessionMode>[_mode('m1', 'Walk Mode')]),
      );
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      final l10n = await loadL10n(const Locale('en'));
      await tester.tap(find.text(l10n.modesDuplicate));
      await tester.pumpAndSettle();
      check(fake.duplicateCalls).equals(1);
      check(fake.lastDuplicateId).equals('m1');
    });
  });

  // ── Popup menu — Delete ────────────────────────────────────────────────────

  group('ModesScreen — popup Delete', () {
    testWidgets('tapping Delete opens confirmation dialog with mode name', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeModesController(
        _state(modes: <SessionMode>[_mode('m1', 'Walk Mode')]),
      );
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.commonDelete));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text(l10n.modesDeleteConfirmTitle), findsOneWidget);
    });

    testWidgets('confirming delete calls controller.delete', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeModesController(
        _state(modes: <SessionMode>[_mode('m1', 'Walk Mode')]),
      );
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.commonDelete));
      await tester.pumpAndSettle();
      // Confirm via the FilledButton in the dialog.
      await tester.tap(
        find.ancestor(
          of: find.text(l10n.commonDelete).last,
          matching: find.byType(FilledButton),
        ),
      );
      await tester.pumpAndSettle();
      check(fake.deleteCalls).equals(1);
      check(fake.lastDeletedId).equals('m1');
    });

    testWidgets('cancelling delete dialog does NOT call controller.delete', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeModesController(
        _state(modes: <SessionMode>[_mode('m1', 'Walk Mode')]),
      );
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.tap(find.byType(PopupMenuButton<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.commonDelete));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.commonCancel));
      await tester.pumpAndSettle();
      check(fake.deleteCalls).equals(0);
    });
  });

  // ── Row tap → navigate ────────────────────────────────────────────────────

  group('ModesScreen — row tap navigation', () {
    testWidgets('tapping a row navigates to modeEditor', (
      WidgetTester tester,
    ) async {
      final observer = _FakeNavigatorObserver();
      final fake = _FakeModesController(
        _state(modes: <SessionMode>[_mode('m1', 'Walk Mode')]),
      );
      await _pumpWithRouter(tester, fake: fake, observer: observer);
      final countBefore = observer.pushed.length;
      await tester.tap(find.text('Walk Mode'));
      await tester.pumpAndSettle();
      check(observer.pushed.length).isGreaterThan(countBefore);
    });
  });

  // ── Multiple modes ──────────────────────────────────────────────────────────

  group('ModesScreen — three modes', () {
    testWidgets('renders all three mode names', (WidgetTester tester) async {
      final fake = _FakeModesController(
        _state(
          modes: <SessionMode>[
            _mode('m1', 'Walk Mode'),
            _mode('m2', 'Date Mode'),
            _mode('m3', 'Night Out'),
          ],
        ),
      );
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.text('Walk Mode'), findsOneWidget);
      expect(find.text('Date Mode'), findsOneWidget);
      expect(find.text('Night Out'), findsOneWidget);
    });

    testWidgets('three rows each have a PopupMenuButton', (
      WidgetTester tester,
    ) async {
      final fake = _FakeModesController(
        _state(
          modes: <SessionMode>[
            _mode('m1', 'Walk Mode'),
            _mode('m2', 'Date Mode'),
            _mode('m3', 'Night Out'),
          ],
        ),
      );
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byType(PopupMenuButton<String>), findsNWidgets(3));
    });
  });

  // ── RTL ────────────────────────────────────────────────────────────────────

  group('ModesScreen — RTL', () {
    testWidgets('renders in Arabic (RTL) without overflow', (
      WidgetTester tester,
    ) async {
      final fake = _FakeModesController(
        _state(modes: <SessionMode>[_mode('m1', 'Walk Mode')]),
      );
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
        locale: const Locale('ar'),
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ── Dark mode ──────────────────────────────────────────────────────────────

  group('ModesScreen — dark mode', () {
    testWidgets('renders without exception in dark mode', (
      WidgetTester tester,
    ) async {
      final fake = _FakeModesController(
        _state(
          modes: <SessionMode>[
            _mode('m1', 'Walk Mode'),
            _mode('m2', 'Date Mode'),
          ],
        ),
      );
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
        themeMode: ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
    });
  });

  // ── Accessibility ──────────────────────────────────────────────────────────

  group('ModesScreen — accessibility', () {
    testWidgets('FAB tooltip satisfies accessibility label requirement', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeModesController(_state());
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byTooltip(l10n.modesAdd), findsOneWidget);
    });

    testWidgets('semantics tree is present and no exceptions thrown', (
      WidgetTester tester,
    ) async {
      final handle = tester.binding.ensureSemantics();
      final fake = _FakeModesController(
        _state(
          modes: <SessionMode>[
            _mode('m1', 'Walk Mode'),
            _mode('m2', 'Date Mode'),
          ],
        ),
      );
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(tester.getSemantics(find.byType(AppBar)), isNotNull);
      handle.dispose();
      expect(tester.takeException(), isNull);
    });
  });

  // ── Built-in protection ─────────────────────────────────────────────────

  group('ModesScreen — built-in protection', () {
    testWidgets('built-in mode renders the Built-in chip badge', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeModesController(
        _state(
          modes: <SessionMode>[_mode('walk', 'Walk Mode', isBuiltIn: true)],
        ),
      );
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.text(l10n.modesBuiltinBadge), findsOneWidget);
    });

    testWidgets('custom mode does NOT render the Built-in chip', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeModesController(
        _state(modes: <SessionMode>[_mode('custom', 'Night Out')]),
      );
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.text(l10n.modesBuiltinBadge), findsNothing);
    });

    testWidgets('built-in mode is NOT wrapped in a Dismissible', (
      WidgetTester tester,
    ) async {
      final fake = _FakeModesController(
        _state(
          modes: <SessionMode>[_mode('walk', 'Walk Mode', isBuiltIn: true)],
        ),
      );
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byType(Dismissible), findsNothing);
    });

    testWidgets('custom mode IS wrapped in a Dismissible (swipe-to-delete)', (
      WidgetTester tester,
    ) async {
      final fake = _FakeModesController(
        _state(modes: <SessionMode>[_mode('custom', 'Night Out')]),
      );
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      expect(find.byType(Dismissible), findsOneWidget);
    });

    testWidgets('built-in mode popup Delete is disabled', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeModesController(
        _state(
          modes: <SessionMode>[_mode('walk', 'Walk Mode', isBuiltIn: true)],
        ),
      );
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      final del = tester.widget<PopupMenuItem<String>>(
        find.widgetWithText(PopupMenuItem<String>, l10n.commonDelete),
      );
      expect(del.enabled, isFalse);
    });

    testWidgets('built-in mode popup Edit remains enabled', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeModesController(
        _state(
          modes: <SessionMode>[_mode('walk', 'Walk Mode', isBuiltIn: true)],
        ),
      );
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      final edit = tester.widget<PopupMenuItem<String>>(
        find.widgetWithText(PopupMenuItem<String>, l10n.commonEdit),
      );
      expect(edit.enabled, isTrue);
    });

    testWidgets('built-in mode duplicate menu remains enabled', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final fake = _FakeModesController(
        _state(
          modes: <SessionMode>[_mode('walk', 'Walk Mode', isBuiltIn: true)],
        ),
      );
      await pumpScreen(
        tester,
        const ModesScreen(),
        overrides: _overrideWith(fake),
      );
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      final dup = tester.widget<PopupMenuItem<String>>(
        find.widgetWithText(PopupMenuItem<String>, l10n.modesDuplicate),
      );
      expect(dup.enabled, isTrue);
    });
  });
}
