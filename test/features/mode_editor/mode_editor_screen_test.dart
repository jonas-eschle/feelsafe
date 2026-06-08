/// Widget tests for [ModeEditorScreen].
///
/// The screen owns its own in-memory draft state and delegates persistence to
/// [ModeEditorService]; default step configs come from
/// [appSettingsRepositoryProvider]. Tests override `databaseProvider` with an
/// in-memory [GuardianAngelaDatabase] and `appSettingsRepositoryProvider` with
/// a fake returning seed defaults — no subclassed controller is needed, so the
/// tests drive the REAL screen → draft → DB flow.
///
/// Test IDs map to spec 04 §Mode Editor (lines 1473–1614) and §Distress Mode
/// Editor (lines 1645–1663).
library;

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/gps_destination_source.dart';
import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/enums/press_pattern.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/triggers/disarm_trigger.dart';
import 'package:guardianangela/domain/triggers/distress_trigger.dart';
import 'package:guardianangela/features/mode_editor/mode_editor_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Fakes / helpers
// ---------------------------------------------------------------------------

/// Returns seed default [AppSettings] without touching the filesystem.
class _FakeAppSettingsRepository extends AppSettingsRepository {
  _FakeAppSettingsRepository()
    : super(
        keyProvider: _key,
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('mode_editor_test_'),
      );

  static Future<String> _key() async => '00' * 32;

  @override
  Future<AppSettings> load() async => const AppSettings();
}

/// Opens an empty in-memory database (no seed data).
GuardianAngelaDatabase _emptyDb() =>
    GuardianAngelaDatabase.memory(seedCallback: (_) async {});

/// Overrides backing both providers the screen depends on.
List<Override> _overrides(GuardianAngelaDatabase db) => <Override>[
  databaseProvider.overrideWith((_) async => db),
  appSettingsRepositoryProvider.overrideWithValue(_FakeAppSettingsRepository()),
];

/// Creates a minimal [ChainStep] for test fixtures.
ChainStep _step(
  String id, {
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

/// Pumps [child] inside a [MaterialApp.router] with a parent '/home' route so
/// `context.pop()` can succeed (used for save-and-pop flows).
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
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF131118)),
          useMaterial3: true,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Scrolls [target] into view inside the editor's [CustomScrollView].
Future<void> _scrollTo(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(
    target,
    120,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

/// Taps the (collapsed) step tile whose title shows [name] to expand it.
Future<void> _expandStep(WidgetTester tester, String name) async {
  await tester.tap(find.text(name));
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ModeEditorScreen — AppBar', () {
    testWidgets('shows "New mode" title when modeId is null', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      await pumpScreen(
        tester,
        const ModeEditorScreen(isDistress: false),
        overrides: _overrides(db),
      );
      // The blank-mode name ("New mode") also pre-fills the name field, so
      // the create title appears in both the AppBar and the TextField.
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
        overrides: _overrides(db),
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
        overrides: _overrides(db),
      );
      expect(find.text(l10n.commonSave), findsOneWidget);
    });
  });

  group('ModeEditorScreen — async loading', () {
    testWidgets('shows CircularProgressIndicator on first frame', (
      WidgetTester tester,
    ) async {
      final db = _emptyDb();
      addTearDown(db.close);
      await pumpScreen(
        tester,
        const ModeEditorScreen(isDistress: false),
        overrides: _overrides(db),
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
        overrides: _overrides(db),
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('ModeEditorScreen — name field', () {
    testWidgets('renders the Name text field', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      await pumpScreen(
        tester,
        const ModeEditorScreen(isDistress: false),
        overrides: _overrides(db),
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
        overrides: _overrides(db),
      );
      expect(find.text('Date Night'), findsAtLeastNWidgets(1));
    });
  });

  group('ModeEditorScreen — chain list', () {
    testWidgets('renders the Chain header text', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      await pumpScreen(
        tester,
        const ModeEditorScreen(isDistress: false),
        overrides: _overrides(db),
      );
      expect(find.text(l10n.modeChainHeader), findsOneWidget);
    });

    testWidgets('shows each step localized name in its tile title', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
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
        overrides: _overrides(db),
      );
      expect(find.text(l10n.chainStepNameHoldButton), findsOneWidget);
      expect(find.text(l10n.chainStepNameSmsContact), findsOneWidget);
      expect(find.text(l10n.chainStepNameLoudAlarm), findsOneWidget);
    });

    testWidgets('each tile shows a timing summary subtitle', (
      WidgetTester tester,
    ) async {
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
        overrides: _overrides(db),
      );
      final l10n = await loadL10n(const Locale('en'));
      expect(find.text(l10n.stepTimingSummary('0', '30', '5')), findsOneWidget);
    });

    testWidgets('renders a drag handle per step', (WidgetTester tester) async {
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
        overrides: _overrides(db),
      );
      expect(find.byIcon(Icons.drag_handle), findsNWidgets(2));
    });
  });

  group('ModeEditorScreen — step config panel', () {
    testWidgets('expanding a step reveals the three config subsections', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(db, _mode(steps: <ChainStep>[_step('s1')]));
      await pumpScreen(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        overrides: _overrides(db),
      );
      await _expandStep(tester, l10n.chainStepNameHoldButton);
      expect(find.text(l10n.stepConfigTimingHeader), findsOneWidget);
      expect(find.text(l10n.stepConfigEventHeader), findsOneWidget);
      expect(find.text(l10n.stepConfigAdvancedHeader), findsOneWidget);
    });

    testWidgets('timing fields are editable text fields when expanded', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(db, _mode(steps: <ChainStep>[_step('s1')]));
      await pumpScreen(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        overrides: _overrides(db),
      );
      await _expandStep(tester, l10n.chainStepNameHoldButton);
      expect(
        find.widgetWithText(TextField, l10n.stepFieldWait),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextField, l10n.stepFieldDuration),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextField, l10n.stepFieldGrace),
        findsOneWidget,
      );
    });

    testWidgets('event-config fields for the step type are shown', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(db, _mode(steps: <ChainStep>[_step('s1')]));
      await pumpScreen(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        overrides: _overrides(db),
      );
      await _expandStep(tester, l10n.chainStepNameHoldButton);
      // holdButton config renders the hold-style dropdown (via EventSpecificConfig).
      await _scrollTo(tester, find.text(l10n.eventDefaultsHoldStyle));
      expect(find.text(l10n.eventDefaultsHoldStyle), findsOneWidget);
    });
  });

  group('ModeEditorScreen — edit persists through save', () {
    testWidgets('editing the wait field saves the new value', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(db, _mode(steps: <ChainStep>[_step('s1')]));
      await _pumpWithRouter(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        _overrides(db),
      );
      await _expandStep(tester, l10n.chainStepNameHoldButton);
      final waitField = find.widgetWithText(TextField, l10n.stepFieldWait);
      await tester.enterText(waitField, '42');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.commonSave));
      await tester.pumpAndSettle();

      final saved = await db.sessionModesDao.getById('m1');
      check(saved!.chainSteps.single.waitSeconds).equals(42);
    });

    testWidgets('toggling a config switch materialises the per-step config', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      // Seed a step with null config so the toggle must materialise it.
      final mode = await _seedMode(db, _mode(steps: <ChainStep>[_step('s1')]));
      check(mode.chainSteps.single.config).isNull();
      await _pumpWithRouter(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        _overrides(db),
      );
      await _expandStep(tester, l10n.chainStepNameHoldButton);
      // vibrateOnRelease defaults to true → toggling flips to false.
      final vibrateTile = find.widgetWithText(
        SwitchListTile,
        l10n.eventDefaultsHoldVibrate,
      );
      await _scrollTo(tester, vibrateTile);
      await tester.tap(vibrateTile);
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.commonSave));
      await tester.pumpAndSettle();

      final saved = await db.sessionModesDao.getById('m1');
      final config = saved!.chainSteps.single.config;
      check(config).isA<HoldButtonConfig>();
      check((config as HoldButtonConfig).vibrateOnRelease).isFalse();
    });
  });

  group('ModeEditorScreen — per-step actions', () {
    testWidgets('Duplicate adds a copy right after the step', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(db, _mode(steps: <ChainStep>[_step('s1')]));
      await pumpScreen(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        overrides: _overrides(db),
      );
      expect(find.byIcon(Icons.drag_handle), findsOneWidget);
      await _expandStep(tester, l10n.chainStepNameHoldButton);
      final dupBtn = find.widgetWithText(TextButton, l10n.stepDuplicate);
      await _scrollTo(tester, dupBtn);
      await tester.tap(dupBtn);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.drag_handle), findsNWidgets(2));
    });

    testWidgets('Delete in the panel removes the step', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
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
        overrides: _overrides(db),
      );
      expect(find.byIcon(Icons.drag_handle), findsNWidgets(2));
      await _expandStep(tester, l10n.chainStepNameHoldButton);
      final delBtn = find.widgetWithText(TextButton, l10n.commonDelete);
      await _scrollTo(tester, delBtn);
      await tester.tap(delBtn);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.drag_handle), findsOneWidget);
    });

    testWidgets('Delete is disabled when only one step remains', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(db, _mode(steps: <ChainStep>[_step('s1')]));
      await pumpScreen(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        overrides: _overrides(db),
      );
      await _expandStep(tester, l10n.chainStepNameHoldButton);
      final delBtn = find.widgetWithText(TextButton, l10n.commonDelete);
      await _scrollTo(tester, delBtn);
      final TextButton btn = tester.widget<TextButton>(delBtn);
      check(btn.onPressed).isNull();
    });

    testWidgets('Reset restores the config to defaults', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      // Seed a step whose config differs from the default (vibrate=false).
      final mode = await _seedMode(
        db,
        _mode(
          steps: <ChainStep>[
            ChainStep(
              id: 's1',
              type: ChainStepType.holdButton,
              order: 0,
              waitSeconds: 0,
              durationSeconds: 10,
              gracePeriodSeconds: 5,
              retryCount: 0,
              randomize: false,
              config: const HoldButtonConfig(vibrateOnRelease: false),
            ),
          ],
        ),
      );
      await _pumpWithRouter(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        _overrides(db),
      );
      await _expandStep(tester, l10n.chainStepNameHoldButton);
      final resetBtn = find.widgetWithText(TextButton, l10n.stepResetDefaults);
      await _scrollTo(tester, resetBtn);
      await tester.tap(resetBtn);
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.commonSave));
      await tester.pumpAndSettle();

      final saved = await db.sessionModesDao.getById('m1');
      final config = saved!.chainSteps.single.config as HoldButtonConfig;
      // Default HoldButtonConfig has vibrateOnRelease = true.
      check(config.vibrateOnRelease).isTrue();
    });
  });

  group('ModeEditorScreen — Add Step', () {
    testWidgets('renders the "Add step" button', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      await pumpScreen(
        tester,
        const ModeEditorScreen(isDistress: false),
        overrides: _overrides(db),
      );
      expect(find.text(l10n.modeChainAddStep), findsOneWidget);
    });

    testWidgets('Add Step opens a categorised sheet with localized names', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      await pumpScreen(
        tester,
        const ModeEditorScreen(isDistress: false),
        overrides: _overrides(db),
      );
      await tester.tap(find.text(l10n.modeChainAddStep));
      await tester.pumpAndSettle();
      expect(find.text(l10n.eventDefaultsCheckInHeader), findsOneWidget);
      expect(find.text(l10n.eventDefaultsEscalationHeader), findsOneWidget);
      expect(find.text(l10n.chainStepNameFakeCall), findsAtLeastNWidgets(1));
    });

    testWidgets('selecting a type from the sheet appends a new step', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(db, _mode(steps: <ChainStep>[_step('s1')]));
      await pumpScreen(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        overrides: _overrides(db),
      );
      expect(find.byIcon(Icons.drag_handle), findsOneWidget);
      await tester.tap(find.text(l10n.modeChainAddStep));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.chainStepNameFakeCall).last);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.drag_handle), findsNWidgets(2));
    });
  });

  group('ModeEditorScreen — smsContact recipient grid', () {
    testWidgets('an smsContact step shows the recipient grid with contacts', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      await db.contactsDao.upsert(
        EmergencyContact(
          id: 'a',
          name: 'Alice',
          phoneNumber: '+15550001',
          sortOrder: 0,
        ),
      );
      final mode = await _seedMode(
        db,
        _mode(steps: <ChainStep>[_step('s1', type: ChainStepType.smsContact)]),
      );
      await pumpScreen(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        overrides: _overrides(db),
      );
      await _expandStep(tester, l10n.chainStepNameSmsContact);
      await _scrollTo(tester, find.text(l10n.smsContactRecipientsHeader));
      expect(find.text(l10n.smsContactRecipientsHeader), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Alice'), findsOneWidget);
    });
  });

  group('ModeEditorScreen — reorder', () {
    testWidgets('dragging the first step down past the second reorders it', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
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
      await _pumpWithRouter(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        _overrides(db),
      );
      // Drag the first step's handle down past the second (immediate drag via
      // ReorderableDragStartListener — no long-press needed).
      final Offset start = tester.getCenter(
        find.byIcon(Icons.drag_handle).first,
      );
      final TestGesture gesture = await tester.startGesture(start);
      await tester.pump(const Duration(milliseconds: 150));
      for (int i = 0; i < 6; i++) {
        await gesture.moveBy(const Offset(0, 30));
        await tester.pump(const Duration(milliseconds: 30));
      }
      await gesture.up();
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.commonSave));
      await tester.pumpAndSettle();

      final saved = await db.sessionModesDao.getById('m1');
      check(saved!.chainSteps.first.type).equals(ChainStepType.fakeCall);
      check(saved.chainSteps.first.order).equals(0);
      check(saved.chainSteps.last.type).equals(ChainStepType.holdButton);
    });
  });

  group('ModeEditorScreen — save', () {
    testWidgets('tapping Save writes the mode to the database', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      await _pumpWithRouter(
        tester,
        const ModeEditorScreen(isDistress: false),
        _overrides(db),
      );
      final nameFinder = find.byType(TextField).first;
      await tester.enterText(nameFinder, 'Saved Mode');
      await tester.pump();
      await tester.tap(find.text(l10n.commonSave));
      await tester.pumpAndSettle();

      final allModes = await db.sessionModesDao.getAll();
      final saved = allModes.firstWhere((m) => m.name == 'Saved Mode');
      check(saved.name).equals('Saved Mode');
    });

    testWidgets('save with isDistress: true persists isDistressMode = true', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      await _pumpWithRouter(
        tester,
        const ModeEditorScreen(isDistress: true),
        _overrides(db),
      );
      final nameFinder = find.byType(TextField).first;
      await tester.enterText(nameFinder, 'Panic Mode');
      await tester.pump();
      await tester.tap(find.text(l10n.commonSave));
      await tester.pumpAndSettle();
      // A blank distress mode has only a holdButton step (no SMS/call), so the
      // non-blocking no-action warning appears; proceed to save (spec 04:1659).
      await tester.tap(
        find.widgetWithText(FilledButton, l10n.validationSaveAnyway),
      );
      await tester.pumpAndSettle();

      final allModes = await db.sessionModesDao.getAll();
      final saved = allModes.firstWhere((m) => m.name == 'Panic Mode');
      check(saved.isDistressMode).isTrue();
    });
  });

  group('ModeEditorScreen — unsaved-changes guard', () {
    testWidgets('back navigation without edits pops immediately', (
      WidgetTester tester,
    ) async {
      final db = _emptyDb();
      addTearDown(db.close);
      await pumpScreen(
        tester,
        const ModeEditorScreen(isDistress: false),
        overrides: _overrides(db),
      );
      final NavigatorState nav = tester.state(find.byType(Navigator));
      nav.pop();
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('back after editing name shows unsaved-changes dialog', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      await pumpScreen(
        tester,
        const ModeEditorScreen(isDistress: false),
        overrides: _overrides(db),
      );
      final nameFinder = find.byType(TextField).first;
      await tester.enterText(nameFinder, 'Changed Name');
      await tester.pump();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text(l10n.modeUnsavedTitle), findsOneWidget);
    });
  });

  group('ModeEditorScreen — distress variant', () {
    testWidgets('distress edit screen renders without exception', (
      WidgetTester tester,
    ) async {
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(
        db,
        _mode(id: 'd1', name: 'Panic', isDistress: true),
      );
      await pumpScreen(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: true),
        overrides: _overrides(db),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(AppBar), findsOneWidget);
    });
  });

  group('ModeEditorScreen — RTL & dark mode', () {
    testWidgets('renders without overflow in Arabic (RTL)', (
      WidgetTester tester,
    ) async {
      final db = _emptyDb();
      addTearDown(db.close);
      await pumpScreen(
        tester,
        const ModeEditorScreen(isDistress: false),
        overrides: _overrides(db),
        locale: const Locale('ar'),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders without exception in dark mode', (
      WidgetTester tester,
    ) async {
      final db = _emptyDb();
      addTearDown(db.close);
      await pumpScreen(
        tester,
        const ModeEditorScreen(isDistress: false),
        overrides: _overrides(db),
        themeMode: ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
    });
  });

  // -------------------------------------------------------------------------
  // Save validation (spec 04:1595-1599, 1656-1659) — drives the real _save().
  // -------------------------------------------------------------------------

  group('ModeEditorScreen — save validation', () {
    testWidgets('blocks save with a too-short name and shows an error', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      await _pumpWithRouter(
        tester,
        const ModeEditorScreen(isDistress: false),
        _overrides(db),
      );
      await tester.enterText(find.byType(TextField).first, 'A');
      await tester.pump();
      await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
      await tester.pumpAndSettle();

      // Error surfaced, save blocked: nothing written to the DB.
      expect(find.text(l10n.validationNameTooShort), findsOneWidget);
      check(await db.sessionModesDao.getAll()).isEmpty();
    });

    testWidgets('blocks save when a fixed GPS trigger is missing coords', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      // Seed a mode whose persisted GPS-arrival trigger uses a fixed
      // destination but has no lat/lng (the UI lets the fields be blank).
      await _seedMode(
        db,
        SessionMode(
          id: 'm1',
          name: 'Walk',
          chainSteps: <ChainStep>[_step('s0')],
          disarmTriggers: const <DisarmTrigger>[
            GpsArrivalDisarmTrigger(
              destinationSource: GpsDestinationSource.fixed,
            ),
          ],
        ),
      );
      await _pumpWithRouter(
        tester,
        const ModeEditorScreen(modeId: 'm1', isDistress: false),
        _overrides(db),
      );
      await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
      await tester.pumpAndSettle();

      // Blocking SnackBar shown and the editor did not pop (Save still here).
      expect(find.text(l10n.validationGpsFixedCoords), findsOneWidget);
      expect(find.widgetWithText(TextButton, l10n.commonSave), findsOneWidget);
    });

    testWidgets('saves once the fixed GPS trigger has both coordinates', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      await _seedMode(
        db,
        SessionMode(
          id: 'm1',
          name: 'Walk',
          chainSteps: <ChainStep>[_step('s0')],
          disarmTriggers: const <DisarmTrigger>[
            GpsArrivalDisarmTrigger(
              destinationSource: GpsDestinationSource.fixed,
              lat: 47.3769,
              lng: 8.5417,
            ),
          ],
        ),
      );
      await _pumpWithRouter(
        tester,
        const ModeEditorScreen(modeId: 'm1', isDistress: false),
        _overrides(db),
      );
      await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
      await tester.pumpAndSettle();

      expect(find.text(l10n.validationGpsFixedCoords), findsNothing);
      final saved = await db.sessionModesDao.getById('m1');
      check(saved).isNotNull();
      check(saved!.disarmTriggers).length.equals(1);
    });

    testWidgets('blocks save when a long-press hardware trigger has no '
        'duration', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      // A directly-constructed long-press trigger with a null duration is
      // internally inconsistent; the editor's normaliser never produces this,
      // but a seeded / hand-edited mode can.
      await _seedMode(
        db,
        SessionMode(
          id: 'm1',
          name: 'Panic',
          isDistressMode: true,
          chainSteps: <ChainStep>[_step('s0', type: ChainStepType.smsContact)],
          distressTriggers: const <DistressTrigger>[
            HardwareButtonDistressTrigger(pattern: PressPattern.longPress),
          ],
        ),
      );
      await _pumpWithRouter(
        tester,
        const ModeEditorScreen(modeId: 'm1', isDistress: true),
        _overrides(db),
      );
      await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
      await tester.pumpAndSettle();

      expect(find.text(l10n.validationHardwareTrigger), findsOneWidget);
      expect(find.widgetWithText(TextButton, l10n.commonSave), findsOneWidget);
    });

    testWidgets('distress mode without an action step warns but allows save', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      // A distress mode whose only step is a countdown — no outbound trail.
      await _seedMode(
        db,
        SessionMode(
          id: 'm1',
          name: 'Silent panic',
          isDistressMode: true,
          chainSteps: <ChainStep>[
            _step('s0', type: ChainStepType.countdownWarning),
          ],
        ),
      );
      await _pumpWithRouter(
        tester,
        const ModeEditorScreen(modeId: 'm1', isDistress: true),
        _overrides(db),
      );
      await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
      await tester.pumpAndSettle();

      // A non-blocking warning dialog appears (does NOT block).
      expect(find.text(l10n.validationDistressNoActionTitle), findsOneWidget);
      // Proceed anyway → the mode persists.
      await tester.tap(
        find.widgetWithText(FilledButton, l10n.validationSaveAnyway),
      );
      await tester.pumpAndSettle();
      final saved = await db.sessionModesDao.getById('m1');
      check(saved).isNotNull();
      check(saved!.isDistressMode).isTrue();
    });

    testWidgets('distress no-action warning can be cancelled (not saved)', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      await _seedMode(
        db,
        SessionMode(
          id: 'm1',
          name: 'Silent panic',
          isDistressMode: true,
          chainSteps: <ChainStep>[
            _step('s0', type: ChainStepType.countdownWarning),
          ],
        ),
      );
      await _pumpWithRouter(
        tester,
        const ModeEditorScreen(modeId: 'm1', isDistress: true),
        _overrides(db),
      );
      // Rename so the save would otherwise persist a visible change.
      await tester.enterText(find.byType(TextField).first, 'Renamed panic');
      await tester.pump();
      await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
      await tester.pumpAndSettle();
      // Cancel the warning dialog.
      await tester.tap(find.widgetWithText(TextButton, l10n.commonCancel));
      await tester.pumpAndSettle();

      // Still on the editor; the rename was not persisted.
      expect(find.widgetWithText(TextButton, l10n.commonSave), findsOneWidget);
      final saved = await db.sessionModesDao.getById('m1');
      check(saved!.name).equals('Silent panic');
    });

    testWidgets('a distress mode WITH an sms step saves without a warning', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      await _seedMode(
        db,
        SessionMode(
          id: 'm1',
          name: 'Loud panic',
          isDistressMode: true,
          chainSteps: <ChainStep>[_step('s0', type: ChainStepType.smsContact)],
        ),
      );
      await _pumpWithRouter(
        tester,
        const ModeEditorScreen(modeId: 'm1', isDistress: true),
        _overrides(db),
      );
      await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
      await tester.pumpAndSettle();

      // No warning dialog; saved straight away.
      expect(find.text(l10n.validationDistressNoActionTitle), findsNothing);
      final saved = await db.sessionModesDao.getById('m1');
      check(saved).isNotNull();
    });
  });

  // -------------------------------------------------------------------------
  // #20 — channel validation on save (spec 02:319). Drives the real _save()
  // with the real contact list.
  // -------------------------------------------------------------------------

  group('ModeEditorScreen — sms channel validation on save', () {
    testWidgets('blocks save when no targeted contact has the step channel', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      // One SMS-only contact; the step sends via WhatsApp → nobody can receive.
      await db.contactsDao.upsert(
        EmergencyContact(
          id: 'a',
          name: 'Alice',
          phoneNumber: '+15550001',
          sortOrder: 0,
        ),
      );
      await _seedMode(
        db,
        _mode(
          steps: <ChainStep>[
            ChainStep(
              id: 's0',
              type: ChainStepType.smsContact,
              order: 0,
              waitSeconds: 0,
              durationSeconds: 15,
              gracePeriodSeconds: 5,
              retryCount: 0,
              randomize: false,
              config: const SmsContactConfig(channel: MessageChannel.whatsapp),
            ),
          ],
        ),
      );
      await _pumpWithRouter(
        tester,
        const ModeEditorScreen(modeId: 'm1', isDistress: false),
        _overrides(db),
      );
      await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
      await tester.pumpAndSettle();

      // Blocking SnackBar shown; the editor did not pop (Save still present);
      // no later edit was written (re-load yields the original whatsapp config,
      // proving _save() bailed before persisting an update).
      expect(find.text(l10n.validationSmsChannelNotOnContacts), findsOneWidget);
      expect(find.widgetWithText(TextButton, l10n.commonSave), findsOneWidget);
      // Explicit no-persist proof: the seeded step config is still the
      // original whatsapp config (the blocked _save() never wrote to the DB).
      final reloaded = await db.sessionModesDao.getById('m1');
      check(
        reloaded!.chainSteps.first.config,
      ).equals(const SmsContactConfig(channel: MessageChannel.whatsapp));
    });

    testWidgets('saves when a targeted contact has the step channel', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      // The contact has WhatsApp → the WhatsApp step is deliverable.
      await db.contactsDao.upsert(
        EmergencyContact(
          id: 'a',
          name: 'Alice',
          phoneNumber: '+15550001',
          sortOrder: 0,
          channels: const <MessageChannel>[MessageChannel.whatsapp],
        ),
      );
      await _seedMode(
        db,
        _mode(
          steps: <ChainStep>[
            ChainStep(
              id: 's0',
              type: ChainStepType.smsContact,
              order: 0,
              waitSeconds: 0,
              durationSeconds: 15,
              gracePeriodSeconds: 5,
              retryCount: 0,
              randomize: false,
              config: const SmsContactConfig(channel: MessageChannel.whatsapp),
            ),
          ],
        ),
      );
      await _pumpWithRouter(
        tester,
        const ModeEditorScreen(modeId: 'm1', isDistress: false),
        _overrides(db),
      );
      await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
      await tester.pumpAndSettle();

      expect(find.text(l10n.validationSmsChannelNotOnContacts), findsNothing);
      final saved = await db.sessionModesDao.getById('m1');
      check(saved).isNotNull();
    });
  });

  // -------------------------------------------------------------------------
  // #20 — SMS message-template editor (spec 02:287-304). Drives the real
  // screen → draft → DB round-trip.
  // -------------------------------------------------------------------------

  group('ModeEditorScreen — sms message template', () {
    testWidgets('typing a template persists it through draft → DB', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      await _seedMode(
        db,
        _mode(steps: <ChainStep>[_step('s0', type: ChainStepType.smsContact)]),
      );
      await _pumpWithRouter(
        tester,
        const ModeEditorScreen(modeId: 'm1', isDistress: false),
        _overrides(db),
      );
      await _expandStep(tester, l10n.chainStepNameSmsContact);
      final Finder field = find.widgetWithText(
        TextField,
        l10n.eventDefaultsSmsMessageTemplate,
      );
      await _scrollTo(tester, field);
      await tester.enterText(field, 'Help {name} at {location}');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.commonSave));
      await tester.pumpAndSettle();

      final saved = await db.sessionModesDao.getById('m1');
      final SmsContactConfig config =
          saved!.chainSteps.first.config! as SmsContactConfig;
      check(config.messageTemplate).equals('Help {name} at {location}');
    });

    testWidgets('a placeholder chip inserts its token into the template', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      await _seedMode(
        db,
        _mode(steps: <ChainStep>[_step('s0', type: ChainStepType.smsContact)]),
      );
      await _pumpWithRouter(
        tester,
        const ModeEditorScreen(modeId: 'm1', isDistress: false),
        _overrides(db),
      );
      await _expandStep(tester, l10n.chainStepNameSmsContact);
      final Finder chip = find.widgetWithText(ActionChip, '{location}');
      await _scrollTo(tester, chip);
      await tester.tap(chip);
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.commonSave));
      await tester.pumpAndSettle();

      final saved = await db.sessionModesDao.getById('m1');
      final SmsContactConfig config =
          saved!.chainSteps.first.config! as SmsContactConfig;
      check(config.messageTemplate).equals('{location}');
    });
  });
}
