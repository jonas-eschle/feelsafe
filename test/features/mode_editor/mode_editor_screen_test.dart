/// Widget tests for [ModeEditorScreen].
///
/// Mirrors the reference pattern from `test/features/home/home_screen_test.dart`.
/// The screen owns its own in-memory draft state and delegates persistence to
/// [ModeEditorService]. Because the screen's `_load()` calls
/// `databaseProvider`, every test overrides `databaseProvider` with an
/// in-memory [GuardianAngelaDatabase] — no subclassed fake notifier is needed.
///
/// Test IDs map to spec 04 §Mode Editor (lines 1473–1618) and §Distress Mode
/// Editor (lines 1645–1663).
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/features/mode_editor/mode_editor_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Opens an empty in-memory database (no seed data).
GuardianAngelaDatabase _emptyDb() =>
    GuardianAngelaDatabase.memory(seedCallback: (_) async {});

/// Returns an override that backs [databaseProvider] with [db].
Override _dbOverride(GuardianAngelaDatabase db) =>
    databaseProvider.overrideWith((_) async => db);

/// Creates a minimal [ChainStep] for test fixtures.
///
/// Defaults: type = [ChainStepType.holdButton], order = 0.
ChainStep _step(String id, {
  ChainStepType type = ChainStepType.holdButton,
  int order = 0,
}) => ChainStep(
  id: id,
  type: type,
  order: order,
  waitSeconds: 0,
  durationSeconds: 10,
  gracePeriodSeconds: 5,
  retryCount: 0,
  randomize: false,
);

/// Stores [mode] in [db] and returns it for convenience.
Future<SessionMode> _seedMode(
  GuardianAngelaDatabase db,
  SessionMode mode,
) async {
  await db.sessionModesDao.upsert(mode);
  return mode;
}

/// Creates a [SessionMode] with the given [name] and [steps].
///
/// Defaults: id = 'm1', name = 'Walk', isDistress = false, one holdButton step.
SessionMode _mode({
  String id = 'm1',
  String name = 'Walk',
  bool isDistress = false,
  List<ChainStep>? steps,
}) => SessionMode(
  id: id,
  name: name,
  isDistressMode: isDistress,
  chainSteps: steps ?? <ChainStep>[_step('s0')],
);

/// Pumps [child] inside a [MaterialApp.router] with a [GoRouter] that has a
/// parent route '/home' and pushes [child] at '/home/edit', so [context.pop()]
/// can succeed. Used for tests that exercise the save-and-pop flow.
Future<void> _pumpWithRouter(
  WidgetTester tester,
  Widget child,
  List<Override> overrides,
) async {
  final GoRouter router = GoRouter(
    initialLocation: '/home/edit',
    routes: <RouteBase>[
      GoRoute(
        path: '/home',
        builder: (BuildContext ctx, GoRouterState s) =>
            const Scaffold(body: SizedBox.shrink()),
        routes: <RouteBase>[
          GoRoute(
            path: 'edit',
            builder: (BuildContext ctx, GoRouterState s) => child,
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
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // AppBar — create variant
  // -------------------------------------------------------------------------

  group('ModeEditorScreen — AppBar (create)', () {
    testWidgets('shows "New mode" title when modeId is null', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      await pumpScreen(
        tester,
        const ModeEditorScreen(isDistress: false),
        overrides: <Override>[_dbOverride(db)],
      );
      // The AppBar title Text widget is the canonical widget; the name
      // also appears in the seeded TextField, so use findsWidgets.
      expect(find.text(l10n.modeEditorTitleCreate), findsWidgets);
    });

    testWidgets('shows "Edit mode" title when modeId is non-null', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(db, _mode());
      await pumpScreen(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        overrides: <Override>[_dbOverride(db)],
      );
      expect(find.text(l10n.modeEditorTitleEdit), findsOneWidget);
    });

    testWidgets('renders Save action button in AppBar', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      await pumpScreen(
        tester,
        const ModeEditorScreen(isDistress: false),
        overrides: <Override>[_dbOverride(db)],
      );
      expect(find.text(l10n.commonSave), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Loading state
  // -------------------------------------------------------------------------

  group('ModeEditorScreen — async loading', () {
    testWidgets('shows CircularProgressIndicator on first frame', (
      WidgetTester tester,
    ) async {
      final db = _emptyDb();
      addTearDown(db.close);
      await pumpScreen(
        tester,
        const ModeEditorScreen(isDistress: false),
        overrides: <Override>[_dbOverride(db)],
        settle: false,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('progress indicator disappears after settle', (
      WidgetTester tester,
    ) async {
      final db = _emptyDb();
      addTearDown(db.close);
      await pumpScreen(
        tester,
        const ModeEditorScreen(isDistress: false),
        overrides: <Override>[_dbOverride(db)],
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  // Name field
  // -------------------------------------------------------------------------

  group('ModeEditorScreen — name field', () {
    testWidgets('renders the Name text field', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      await pumpScreen(
        tester,
        const ModeEditorScreen(isDistress: false),
        overrides: <Override>[_dbOverride(db)],
      );
      expect(
        find.widgetWithText(TextField, l10n.modeFieldName),
        findsOneWidget,
      );
    });

    testWidgets('pre-fills name field when editing an existing mode', (
      WidgetTester tester,
    ) async {
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(db, _mode(name: 'Date Night'));
      await pumpScreen(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        overrides: <Override>[_dbOverride(db)],
      );
      expect(find.text('Date Night'), findsAtLeastNWidgets(1));
    });

    testWidgets('editing the name field does not throw', (
      WidgetTester tester,
    ) async {
      final db = _emptyDb();
      addTearDown(db.close);
      await pumpScreen(
        tester,
        const ModeEditorScreen(isDistress: false),
        overrides: <Override>[_dbOverride(db)],
      );
      final nameFinder = find.byType(TextField).first;
      await tester.tap(nameFinder);
      await tester.enterText(nameFinder, 'Hiking');
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Chain header
  // -------------------------------------------------------------------------

  group('ModeEditorScreen — chain header', () {
    testWidgets('renders the Chain header text', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      await pumpScreen(
        tester,
        const ModeEditorScreen(isDistress: false),
        overrides: <Override>[_dbOverride(db)],
      );
      expect(find.text(l10n.modeChainHeader), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Step list
  // -------------------------------------------------------------------------

  group('ModeEditorScreen — step list', () {
    testWidgets('shows each step type name in its ListTile title', (
      WidgetTester tester,
    ) async {
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(
        db,
        _mode(
          steps: <ChainStep>[
            _step('s1'),
            _step('s2', type: ChainStepType.smsContact, order: 1),
            _step('s3', type: ChainStepType.loudAlarm, order: 2),
          ],
        ),
      );
      await pumpScreen(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        overrides: <Override>[_dbOverride(db)],
      );
      expect(find.text(ChainStepType.holdButton.name), findsOneWidget);
      expect(find.text(ChainStepType.smsContact.name), findsOneWidget);
      expect(find.text(ChainStepType.loudAlarm.name), findsOneWidget);
    });

    testWidgets('renders a numbered CircleAvatar badge per step', (
      WidgetTester tester,
    ) async {
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(
        db,
        _mode(
          steps: <ChainStep>[
            _step('s1'),
            _step('s2', type: ChainStepType.fakeCall, order: 1),
          ],
        ),
      );
      await pumpScreen(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        overrides: <Override>[_dbOverride(db)],
      );
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('renders a delete icon button for each step', (
      WidgetTester tester,
    ) async {
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(
        db,
        _mode(
          steps: <ChainStep>[
            _step('s1'),
            _step('s2', type: ChainStepType.fakeCall, order: 1),
          ],
        ),
      );
      await pumpScreen(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        overrides: <Override>[_dbOverride(db)],
      );
      expect(find.byIcon(Icons.delete_outline), findsNWidgets(2));
    });

    testWidgets(
      'each step ListTile shows timing summary with duration values',
      (WidgetTester tester) async {
        final db = _emptyDb();
        addTearDown(db.close);
        final mode = await _seedMode(
          db,
          _mode(
            steps: <ChainStep>[
              ChainStep(
                id: 's1',
                type: ChainStepType.holdButton,
                order: 0,
                waitSeconds: 0,
                durationSeconds: 30,
                gracePeriodSeconds: 5,
                retryCount: 0,
                randomize: false,
              ),
            ],
          ),
        );
        await pumpScreen(
          tester,
          ModeEditorScreen(modeId: mode.id, isDistress: false),
          overrides: <Override>[_dbOverride(db)],
        );
        final l10n = await loadL10n(const Locale('en'));
        final summary = l10n.stepTimingSummary('0', '30', '5');
        expect(find.text(summary), findsOneWidget);
      },
    );
  });

  // -------------------------------------------------------------------------
  // Add Step button
  // -------------------------------------------------------------------------

  group('ModeEditorScreen — Add Step button', () {
    testWidgets('renders the "Add step" button', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      await pumpScreen(
        tester,
        const ModeEditorScreen(isDistress: false),
        overrides: <Override>[_dbOverride(db)],
      );
      expect(find.text(l10n.modeChainAddStep), findsOneWidget);
    });

    testWidgets('tapping Add Step opens a bottom sheet with step types', (
      WidgetTester tester,
    ) async {
      final db = _emptyDb();
      addTearDown(db.close);
      await pumpScreen(
        tester,
        const ModeEditorScreen(isDistress: false),
        overrides: <Override>[_dbOverride(db)],
      );
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      // The sheet renders a ListView; the first few types are always visible.
      // Use findsAtLeastNWidgets(1) and allow scrolling for others.
      expect(
        find.text(ChainStepType.holdButton.name),
        findsAtLeastNWidgets(1),
      );
      expect(
        find.text(ChainStepType.fakeCall.name),
        findsAtLeastNWidgets(1),
      );
      // Bottom sheet is present (at least one ListTile).
      expect(find.byType(ListTile), findsAtLeastNWidgets(1));
    });

    testWidgets(
      'selecting a step type from the sheet appends a new step',
      (WidgetTester tester) async {
        final db = _emptyDb();
        addTearDown(db.close);
        final mode = await _seedMode(
          db,
          _mode(steps: <ChainStep>[_step('s1')]),
        );
        await pumpScreen(
          tester,
          ModeEditorScreen(modeId: mode.id, isDistress: false),
          overrides: <Override>[_dbOverride(db)],
        );
        expect(find.byIcon(Icons.delete_outline), findsOneWidget);

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        // Use `.last` because the existing step tile also shows fakeCall.name.
        await tester.tap(find.text(ChainStepType.fakeCall.name).last);
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.delete_outline), findsNWidgets(2));
      },
    );
  });

  // -------------------------------------------------------------------------
  // Delete step
  // -------------------------------------------------------------------------

  group('ModeEditorScreen — delete step', () {
    testWidgets(
      'tapping delete icon removes the step and re-numbers the list',
      (WidgetTester tester) async {
        final db = _emptyDb();
        addTearDown(db.close);
        final mode = await _seedMode(
          db,
          _mode(
            steps: <ChainStep>[
              _step('s1'),
              _step('s2', type: ChainStepType.fakeCall, order: 1),
            ],
          ),
        );
        await pumpScreen(
          tester,
          ModeEditorScreen(modeId: mode.id, isDistress: false),
          overrides: <Override>[_dbOverride(db)],
        );
        expect(find.byIcon(Icons.delete_outline), findsNWidgets(2));

        await tester.tap(find.byIcon(Icons.delete_outline).first);
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.delete_outline), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsNothing);
      },
    );

    testWidgets(
      'delete is a no-op when only one step remains',
      (WidgetTester tester) async {
        final db = _emptyDb();
        addTearDown(db.close);
        final mode = await _seedMode(
          db,
          _mode(steps: <ChainStep>[_step('s1')]),
        );
        await pumpScreen(
          tester,
          ModeEditorScreen(modeId: mode.id, isDistress: false),
          overrides: <Override>[_dbOverride(db)],
        );
        await tester.tap(find.byIcon(Icons.delete_outline).first);
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      },
    );
  });

  // -------------------------------------------------------------------------
  // Dirty-flag / unsaved-changes guard
  // -------------------------------------------------------------------------

  group('ModeEditorScreen — unsaved-changes guard', () {
    testWidgets('back navigation without edits pops immediately', (
      WidgetTester tester,
    ) async {
      final db = _emptyDb();
      addTearDown(db.close);
      await pumpScreen(
        tester,
        const ModeEditorScreen(isDistress: false),
        overrides: <Override>[_dbOverride(db)],
      );
      final NavigatorState nav = tester.state(find.byType(Navigator));
      nav.pop();
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets(
      'back navigation after editing name shows unsaved-changes dialog',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final db = _emptyDb();
        addTearDown(db.close);
        await pumpScreen(
          tester,
          const ModeEditorScreen(isDistress: false),
          overrides: <Override>[_dbOverride(db)],
        );
        final nameFinder = find.byType(TextField).first;
        await tester.tap(nameFinder);
        await tester.enterText(nameFinder, 'Changed Name');
        await tester.pump();

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(find.text(l10n.modeUnsavedTitle), findsOneWidget);
      },
    );

    testWidgets(
      '"Keep editing" dismisses dialog without leaving the screen',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final db = _emptyDb();
        addTearDown(db.close);
        await pumpScreen(
          tester,
          const ModeEditorScreen(isDistress: false),
          overrides: <Override>[_dbOverride(db)],
        );
        final nameFinder = find.byType(TextField).first;
        await tester.tap(nameFinder);
        await tester.enterText(nameFinder, 'X');
        await tester.pump();

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        await tester.tap(find.text(l10n.modeUnsavedKeep));
        await tester.pumpAndSettle();

        expect(find.byType(ModeEditorScreen), findsOneWidget);
      },
    );
  });

  // -------------------------------------------------------------------------
  // Save
  // -------------------------------------------------------------------------

  group('ModeEditorScreen — save', () {
    testWidgets(
      'tapping Save writes the mode to the database',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final db = _emptyDb();
        addTearDown(db.close);
        // Use the GoRouter harness so context.pop() does not throw.
        await _pumpWithRouter(
          tester,
          const ModeEditorScreen(isDistress: false),
          <Override>[_dbOverride(db)],
        );
        final nameFinder = find.byType(TextField).first;
        await tester.tap(nameFinder);
        await tester.enterText(nameFinder, 'Saved Mode');
        await tester.pump();

        await tester.tap(find.text(l10n.commonSave));
        await tester.pumpAndSettle();

        final allModes = await db.sessionModesDao.getAll();
        final saved = allModes.firstWhere(
          (SessionMode m) => m.name == 'Saved Mode',
        );
        check(saved.name).equals('Saved Mode');
      },
    );

    testWidgets(
      'save with isDistress: true persists isDistressMode = true',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final db = _emptyDb();
        addTearDown(db.close);
        await _pumpWithRouter(
          tester,
          const ModeEditorScreen(isDistress: true),
          <Override>[_dbOverride(db)],
        );
        final nameFinder = find.byType(TextField).first;
        await tester.tap(nameFinder);
        await tester.enterText(nameFinder, 'Panic Mode');
        await tester.pump();

        await tester.tap(find.text(l10n.commonSave));
        await tester.pumpAndSettle();

        final allModes = await db.sessionModesDao.getAll();
        final saved = allModes.firstWhere(
          (SessionMode m) => m.name == 'Panic Mode',
        );
        check(saved.isDistressMode).isTrue();
      },
    );
  });

  // -------------------------------------------------------------------------
  // Distress variant — isDistress: true
  // -------------------------------------------------------------------------

  group('ModeEditorScreen — distress variant (isDistress: true)', () {
    testWidgets(
      'distress create screen shows a title in the AppBar',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        final db = _emptyDb();
        addTearDown(db.close);
        await pumpScreen(
          tester,
          const ModeEditorScreen(isDistress: true),
          overrides: <Override>[_dbOverride(db)],
        );
        // Title is either the regular or the distress-specific string.
        final hasModeTitle = tester.any(
          find.text(l10n.modeEditorTitleCreate),
        );
        final hasDistressTitle = tester.any(
          find.text(l10n.distressModeEditorTitleCreate),
        );
        check(hasModeTitle || hasDistressTitle).isTrue();
      },
    );

    testWidgets(
      'distress edit screen renders without exception',
      (WidgetTester tester) async {
        final db = _emptyDb();
        addTearDown(db.close);
        final mode = await _seedMode(
          db,
          _mode(id: 'd1', name: 'Panic', isDistress: true),
        );
        await pumpScreen(
          tester,
          ModeEditorScreen(modeId: mode.id, isDistress: true),
          overrides: <Override>[_dbOverride(db)],
        );
        expect(tester.takeException(), isNull);
        expect(find.byType(AppBar), findsOneWidget);
      },
    );

    testWidgets(
      'blank distress mode pre-fills name with "New distress mode"',
      (WidgetTester tester) async {
        final db = _emptyDb();
        addTearDown(db.close);
        await pumpScreen(
          tester,
          const ModeEditorScreen(isDistress: true),
          overrides: <Override>[_dbOverride(db)],
        );
        // ModeEditorService.blankMode seeds name as "New distress mode"
        // when isDistress is true.
        expect(find.text('New distress mode'), findsAtLeastNWidgets(1));
      },
    );
  });

  // -------------------------------------------------------------------------
  // RTL smoke
  // -------------------------------------------------------------------------

  group('ModeEditorScreen — RTL', () {
    testWidgets('renders without overflow in Arabic (RTL)', (
      WidgetTester tester,
    ) async {
      final db = _emptyDb();
      addTearDown(db.close);
      await pumpScreen(
        tester,
        const ModeEditorScreen(isDistress: false),
        overrides: <Override>[_dbOverride(db)],
        locale: const Locale('ar'),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(AppBar), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Dark mode smoke
  // -------------------------------------------------------------------------

  group('ModeEditorScreen — dark mode', () {
    testWidgets('renders without exception in dark mode', (
      WidgetTester tester,
    ) async {
      final db = _emptyDb();
      addTearDown(db.close);
      await pumpScreen(
        tester,
        const ModeEditorScreen(isDistress: false),
        overrides: <Override>[_dbOverride(db)],
        themeMode: ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Accessibility
  // -------------------------------------------------------------------------

  group('ModeEditorScreen — accessibility', () {
    testWidgets('Save action button is present and tappable', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      await pumpScreen(
        tester,
        const ModeEditorScreen(isDistress: false),
        overrides: <Override>[_dbOverride(db)],
      );
      final saveBtn = find.widgetWithText(TextButton, l10n.commonSave);
      expect(saveBtn, findsOneWidget);
      final btn = tester.widget<TextButton>(saveBtn);
      check(btn.onPressed).isNotNull();
    });

    testWidgets('delete icon buttons are findable per step', (
      WidgetTester tester,
    ) async {
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(
        db,
        _mode(
          steps: <ChainStep>[
            _step('s1'),
            _step('s2', type: ChainStepType.fakeCall, order: 1),
          ],
        ),
      );
      await pumpScreen(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        overrides: <Override>[_dbOverride(db)],
      );
      expect(find.byIcon(Icons.delete_outline), findsNWidgets(2));
    });

    testWidgets('name TextField label is visible to screen readers', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      await pumpScreen(
        tester,
        const ModeEditorScreen(isDistress: false),
        overrides: <Override>[_dbOverride(db)],
      );
      // InputDecoration.labelText renders a Text widget.
      expect(find.text(l10n.modeFieldName), findsAtLeastNWidgets(1));
    });
  });

  // -------------------------------------------------------------------------
  // Step ordering
  // -------------------------------------------------------------------------

  group('ModeEditorScreen — step ordering', () {
    testWidgets(
      'add one step to a blank mode produces two numbered badges',
      (WidgetTester tester) async {
        final db = _emptyDb();
        addTearDown(db.close);
        // Blank mode auto-seeds with 1 step.
        await pumpScreen(
          tester,
          const ModeEditorScreen(isDistress: false),
          overrides: <Override>[_dbOverride(db)],
        );
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
        await tester.tap(find.text(ChainStepType.smsContact.name).last);
        await tester.pumpAndSettle();

        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
      },
    );

    testWidgets(
      'deleting middle step re-numbers remaining steps from 1',
      (WidgetTester tester) async {
        final db = _emptyDb();
        addTearDown(db.close);
        final mode = await _seedMode(
          db,
          _mode(
            steps: <ChainStep>[
              _step('s1'),
              _step('s2', type: ChainStepType.fakeCall, order: 1),
              _step('s3', type: ChainStepType.loudAlarm, order: 2),
            ],
          ),
        );
        await pumpScreen(
          tester,
          ModeEditorScreen(modeId: mode.id, isDistress: false),
          overrides: <Override>[_dbOverride(db)],
        );
        expect(find.text('3'), findsOneWidget);

        // Delete the second step (index 1).
        final Finder deleteBtns = find.byIcon(Icons.delete_outline);
        await tester.tap(deleteBtns.at(1));
        await tester.pumpAndSettle();

        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsNothing);
      },
    );
  });
}
