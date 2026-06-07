/// Widget tests for the Mode Editor's "Safety options" section (GA #13c).
///
/// Drive the REAL [ModeEditorScreen] → in-memory draft → DB flow: each test
/// edits a Safety Options control, taps Save, and asserts the persisted
/// [SessionMode]. The harness overrides `databaseProvider` (real in-memory
/// [GuardianAngelaDatabase]) and `appSettingsRepositoryProvider` (a fake
/// returning seed [AppSettings]); no controller is subclassed.
///
/// Test IDs map to spec 04 §Mode — Safety Options (lines 1601-1614) and
/// §Distress Mode Editor (lines 1646-1659).
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
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/gps_destination_source.dart';
import 'package:guardianangela/domain/models/app_defaults.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/triggers/disarm_trigger.dart';
import 'package:guardianangela/domain/triggers/distress_trigger.dart';
import 'package:guardianangela/features/mode_editor/mode_editor_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';

// ---------------------------------------------------------------------------
// Fakes / helpers
// ---------------------------------------------------------------------------

/// Returns [settings] (seed defaults by default) without touching the
/// filesystem.
class _FakeAppSettingsRepository extends AppSettingsRepository {
  _FakeAppSettingsRepository({this.settings = const AppSettings()})
    : super(
        keyProvider: _key,
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('safety_options_test_'),
      );

  final AppSettings settings;

  static Future<String> _key() async => '00' * 32;

  @override
  Future<AppSettings> load() async => settings;
}

GuardianAngelaDatabase _emptyDb() =>
    GuardianAngelaDatabase.memory(seedCallback: (_) async {});

List<Override> _overrides(GuardianAngelaDatabase db) => <Override>[
  databaseProvider.overrideWith((_) async => db),
  appSettingsRepositoryProvider.overrideWithValue(_FakeAppSettingsRepository()),
];

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

Future<SessionMode> _seedMode(
  GuardianAngelaDatabase db,
  SessionMode mode,
) async {
  await db.sessionModesDao.upsert(mode);
  return mode;
}

/// Pumps the editor inside a router that provides `/home` (so `context.pop`
/// after Save works) plus stub `/distress-modes` and
/// `/settings/reminder-templates` routes for the "Manage …" deep links.
Future<void> _pump(
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
      GoRoute(
        path: '/distress-modes',
        name: 'distress_modes',
        builder: (BuildContext ctx, GoRouterState s) =>
            const Scaffold(body: Text('distress modes screen')),
      ),
      GoRoute(
        path: '/settings/reminder-templates',
        name: 'settings_reminder_templates',
        builder: (BuildContext ctx, GoRouterState s) =>
            const Scaffold(body: Text('templates screen')),
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

/// Scrolls [target] into view in the editor's [CustomScrollView].
Future<void> _scrollTo(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(
    target,
    120,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

/// Expands the "Safety options" section.
Future<void> _openSafetyOptions(
  WidgetTester tester,
  AppLocalizations l10n,
) async {
  await _scrollTo(tester, find.text(l10n.safetyOptionsHeader));
  await tester.tap(find.text(l10n.safetyOptionsHeader));
  await tester.pumpAndSettle();
}

Future<void> _tapSave(WidgetTester tester, AppLocalizations l10n) async {
  await tester.tap(find.text(l10n.commonSave));
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SafetyOptions — section presence', () {
    testWidgets('renders the "Safety options" header', (
      WidgetTester tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(db, _mode());
      await _pump(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        _overrides(db),
      );
      await _scrollTo(tester, find.text(l10n.safetyOptionsHeader));
      expect(find.text(l10n.safetyOptionsHeader), findsOneWidget);
    });
  });

  group('SafetyOptions — distress-mode picker', () {
    testWidgets('regular mode shows the distress-mode picker', (
      WidgetTester tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(db, _mode());
      await _pump(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        _overrides(db),
      );
      await _openSafetyOptions(tester, l10n);
      await _scrollTo(tester, find.text(l10n.safetyOptionsManageDistressModes));
      expect(
        find.text(l10n.safetyOptionsDistressModeUseDefault),
        findsOneWidget,
      );
      expect(find.text(l10n.safetyOptionsManageDistressModes), findsOneWidget);
    });

    testWidgets('distress variant hides the distress-mode picker', (
      WidgetTester tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(
        db,
        _mode(id: 'd1', name: 'Panic', isDistress: true),
      );
      await _pump(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: true),
        _overrides(db),
      );
      await _openSafetyOptions(tester, l10n);
      expect(find.text(l10n.safetyOptionsManageDistressModes), findsNothing);
    });

    testWidgets('"Use default" names the resolved default distress mode', (
      WidgetTester tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      await _seedMode(
        db,
        _mode(
          id: 'panic1',
          name: 'House Panic',
          isDistress: true,
          steps: <ChainStep>[_step('p0', type: ChainStepType.smsContact)],
        ),
      );
      final mode = await _seedMode(db, _mode());
      // Override settings to carry a configured default distress mode.
      final overrides = <Override>[
        databaseProvider.overrideWith((_) async => db),
        appSettingsRepositoryProvider.overrideWithValue(
          _FakeAppSettingsRepository(
            settings: const AppSettings(
              defaults: AppDefaults(defaultDistressModeId: 'panic1'),
            ),
          ),
        ),
      ];
      await _pump(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        overrides,
      );
      await _openSafetyOptions(tester, l10n);
      await _scrollTo(tester, find.text(l10n.safetyOptionsManageDistressModes));
      expect(
        find.text(l10n.safetyOptionsDistressModeUseDefaultNamed('House Panic')),
        findsOneWidget,
      );
    });

    testWidgets('selecting a distress mode persists distressModeId', (
      WidgetTester tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      await _seedMode(
        db,
        _mode(
          id: 'panic1',
          name: 'My Panic',
          isDistress: true,
          steps: <ChainStep>[_step('p0', type: ChainStepType.smsContact)],
        ),
      );
      final mode = await _seedMode(db, _mode());
      await _pump(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        _overrides(db),
      );
      await _openSafetyOptions(tester, l10n);
      // Open the dropdown and pick the distress mode by name.
      await _scrollTo(
        tester,
        find.text(l10n.safetyOptionsDistressModeUseDefault),
      );
      await tester.tap(find.text(l10n.safetyOptionsDistressModeUseDefault));
      await tester.pumpAndSettle();
      await tester.tap(find.text('My Panic').last);
      await tester.pumpAndSettle();
      await _tapSave(tester, l10n);

      final saved = await db.sessionModesDao.getById('m1');
      check(saved!.distressModeId).equals('panic1');
    });
  });

  group('SafetyOptions — distress triggers', () {
    testWidgets('adding a hardware panic trigger persists it', (
      WidgetTester tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(db, _mode());
      await _pump(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        _overrides(db),
      );
      await _openSafetyOptions(tester, l10n);
      await _scrollTo(tester, find.text(l10n.safetyOptionsAddHardwarePanic));
      await tester.tap(find.text(l10n.safetyOptionsAddHardwarePanic));
      await tester.pumpAndSettle();
      await _tapSave(tester, l10n);

      final saved = await db.sessionModesDao.getById('m1');
      check(saved!.distressTriggers.length).equals(1);
      check(saved.distressTriggers.single).isA<HardwareButtonDistressTrigger>();
    });
  });

  group('SafetyOptions — disarm triggers', () {
    testWidgets('enabling GPS-arrival disarm persists a GPS trigger', (
      WidgetTester tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(db, _mode());
      await _pump(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        _overrides(db),
      );
      await _openSafetyOptions(tester, l10n);
      final gpsToggle = find.widgetWithText(
        SwitchListTile,
        l10n.safetyOptionsGpsArrivalTitle,
      );
      await _scrollTo(tester, gpsToggle);
      await tester.tap(gpsToggle);
      await tester.pumpAndSettle();
      await _tapSave(tester, l10n);

      final saved = await db.sessionModesDao.getById('m1');
      final gps = saved!.disarmTriggers
          .whereType<GpsArrivalDisarmTrigger>()
          .single;
      check(gps.radiusMeters).equals(200);
      check(gps.destinationSource).equals(GpsDestinationSource.promptAtStart);
    });

    testWidgets('enabling Timer disarm persists a timer trigger', (
      WidgetTester tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(db, _mode());
      await _pump(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        _overrides(db),
      );
      await _openSafetyOptions(tester, l10n);
      final timerToggle = find.widgetWithText(
        SwitchListTile,
        l10n.safetyOptionsTimerDisarmTitle,
      );
      await _scrollTo(tester, timerToggle);
      await tester.tap(timerToggle);
      await tester.pumpAndSettle();
      await _tapSave(tester, l10n);

      final saved = await db.sessionModesDao.getById('m1');
      final timer = saved!.disarmTriggers
          .whereType<TimerDisarmTrigger>()
          .single;
      check(timer.durationSeconds).equals(30 * 60);
    });

    testWidgets('disabling an enabled GPS-arrival trigger removes it', (
      WidgetTester tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(
        db,
        SessionMode(
          id: 'm1',
          name: 'Walk',
          chainSteps: <ChainStep>[_step('s0')],
          disarmTriggers: const <DisarmTrigger>[GpsArrivalDisarmTrigger()],
        ),
      );
      await _pump(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        _overrides(db),
      );
      await _openSafetyOptions(tester, l10n);
      final gpsToggle = find.widgetWithText(
        SwitchListTile,
        l10n.safetyOptionsGpsArrivalTitle,
      );
      await _scrollTo(tester, gpsToggle);
      await tester.tap(gpsToggle);
      await tester.pumpAndSettle();
      await _tapSave(tester, l10n);

      final saved = await db.sessionModesDao.getById('m1');
      check(saved!.disarmTriggers).isEmpty();
    });

    testWidgets('GPS-arrival fixed source reveals and persists lat/lng', (
      WidgetTester tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(
        db,
        SessionMode(
          id: 'm1',
          name: 'Walk',
          chainSteps: <ChainStep>[_step('s0')],
          disarmTriggers: const <DisarmTrigger>[GpsArrivalDisarmTrigger()],
        ),
      );
      await _pump(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        _overrides(db),
      );
      await _openSafetyOptions(tester, l10n);
      // Open the destination-source dropdown via its current value, then pick
      // "Fixed coordinates".
      await _scrollTo(tester, find.text(l10n.safetyOptionsDestinationPrompt));
      await tester.tap(find.text(l10n.safetyOptionsDestinationPrompt).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.safetyOptionsDestinationFixed).last);
      await tester.pumpAndSettle();
      final latField = find.widgetWithText(
        TextField,
        l10n.safetyOptionsLatitude,
      );
      await _scrollTo(tester, latField);
      await tester.enterText(latField, '52.52');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      final lngField = find.widgetWithText(
        TextField,
        l10n.safetyOptionsLongitude,
      );
      await _scrollTo(tester, lngField);
      await tester.enterText(lngField, '13.405');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await _tapSave(tester, l10n);

      final saved = await db.sessionModesDao.getById('m1');
      final gps = saved!.disarmTriggers
          .whereType<GpsArrivalDisarmTrigger>()
          .single;
      check(gps.destinationSource).equals(GpsDestinationSource.fixed);
      check(gps.lat).equals(52.52);
      check(gps.lng).equals(13.405);
    });

    testWidgets('GPS and Timer disarm coexist independently', (
      WidgetTester tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(db, _mode());
      await _pump(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        _overrides(db),
      );
      await _openSafetyOptions(tester, l10n);
      final gpsToggle = find.widgetWithText(
        SwitchListTile,
        l10n.safetyOptionsGpsArrivalTitle,
      );
      await _scrollTo(tester, gpsToggle);
      await tester.tap(gpsToggle);
      await tester.pumpAndSettle();
      final timerToggle = find.widgetWithText(
        SwitchListTile,
        l10n.safetyOptionsTimerDisarmTitle,
      );
      await _scrollTo(tester, timerToggle);
      await tester.tap(timerToggle);
      await tester.pumpAndSettle();
      await _tapSave(tester, l10n);

      final saved = await db.sessionModesDao.getById('m1');
      check(saved!.disarmTriggers.length).equals(2);
      check(
        saved.disarmTriggers.whereType<GpsArrivalDisarmTrigger>().length,
      ).equals(1);
      check(
        saved.disarmTriggers.whereType<TimerDisarmTrigger>().length,
      ).equals(1);
    });
  });

  group('SafetyOptions — GPS-logging tri-state', () {
    testWidgets('selecting Custom persists an enabled GPS-logging override', (
      WidgetTester tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(db, _mode());
      await _pump(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        _overrides(db),
      );
      await _openSafetyOptions(tester, l10n);
      // The first "Custom" segment belongs to the GPS-logging selector
      // (it is the first tri-state in the section).
      await _scrollTo(tester, find.text(l10n.safetyOptionsGpsLoggingTitle));
      await tester.tap(find.text(l10n.safetyOptionsTriStateCustom).first);
      await tester.pumpAndSettle();
      await _tapSave(tester, l10n);

      final saved = await db.sessionModesDao.getById('m1');
      check(saved!.overrides?.gpsLogging?.enabled).equals(true);
    });

    testWidgets('selecting Off persists a disabled GPS-logging override', (
      WidgetTester tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(db, _mode());
      await _pump(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        _overrides(db),
      );
      await _openSafetyOptions(tester, l10n);
      await _scrollTo(tester, find.text(l10n.safetyOptionsGpsLoggingTitle));
      await tester.tap(find.text(l10n.safetyOptionsTriStateOff).first);
      await tester.pumpAndSettle();
      await _tapSave(tester, l10n);

      final saved = await db.sessionModesDao.getById('m1');
      check(saved!.overrides?.gpsLogging?.enabled).equals(false);
    });

    testWidgets(
      'Custom then Inherit clears the override back to null (no copyWith leak)',
      (WidgetTester tester) async {
        final l10n = await AppLocalizations.delegate.load(const Locale('en'));
        final db = _emptyDb();
        addTearDown(db.close);
        final mode = await _seedMode(db, _mode());
        await _pump(
          tester,
          ModeEditorScreen(modeId: mode.id, isDistress: false),
          _overrides(db),
        );
        await _openSafetyOptions(tester, l10n);
        await _scrollTo(tester, find.text(l10n.safetyOptionsGpsLoggingTitle));
        await tester.tap(find.text(l10n.safetyOptionsTriStateCustom).first);
        await tester.pumpAndSettle();
        await _scrollTo(tester, find.text(l10n.safetyOptionsGpsLoggingTitle));
        await tester.tap(find.text(l10n.safetyOptionsTriStateInherit).first);
        await tester.pumpAndSettle();
        await _tapSave(tester, l10n);

        final saved = await db.sessionModesDao.getById('m1');
        // Inherit must NULL the field; since no other override is set, the
        // whole overrides object is normalised to null.
        check(saved!.overrides).isNull();
      },
    );
  });

  group('SafetyOptions — Stealth tri-state', () {
    testWidgets('selecting Custom persists an enabled stealth override', (
      WidgetTester tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(db, _mode());
      await _pump(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        _overrides(db),
      );
      await _openSafetyOptions(tester, l10n);
      // The stealth selector's "Custom" is the second one in the section.
      await _scrollTo(tester, find.text(l10n.safetyOptionsStealthTitle));
      final customSegments = find.text(l10n.safetyOptionsTriStateCustom);
      await tester.tap(customSegments.at(1));
      await tester.pumpAndSettle();
      await _tapSave(tester, l10n);

      final saved = await db.sessionModesDao.getById('m1');
      check(saved!.overrides?.stealth?.enabled).equals(true);
    });
  });

  group('SafetyOptions — event-defaults tri-state', () {
    testWidgets('selecting Custom persists an event-defaults override', (
      WidgetTester tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(db, _mode());
      await _pump(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        _overrides(db),
      );
      await _openSafetyOptions(tester, l10n);
      await _scrollTo(tester, find.text(l10n.safetyOptionsEventDefaultsTitle));
      // The event-defaults two-state "Custom" is the last in the section.
      await tester.tap(find.text(l10n.safetyOptionsTriStateCustom).last);
      await tester.pumpAndSettle();
      await _tapSave(tester, l10n);

      final saved = await db.sessionModesDao.getById('m1');
      check(saved!.overrides?.eventDefaults).isNotNull();
    });
  });

  group('SafetyOptions — allowDisarmAsDistress (distress only)', () {
    testWidgets('toggle is shown only in the distress variant', (
      WidgetTester tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(db, _mode());
      await _pump(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        _overrides(db),
      );
      await _openSafetyOptions(tester, l10n);
      expect(
        find.text(l10n.safetyOptionsAllowDisarmAsDistressTitle),
        findsNothing,
      );
    });

    testWidgets('toggling allowDisarmAsDistress persists the new value', (
      WidgetTester tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      // Default allowDisarmAsDistress is true → toggling flips to false.
      final mode = await _seedMode(
        db,
        _mode(id: 'd1', name: 'Panic', isDistress: true),
      );
      check(mode.allowDisarmAsDistress).isTrue();
      await _pump(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: true),
        _overrides(db),
      );
      await _openSafetyOptions(tester, l10n);
      final toggle = find.widgetWithText(
        SwitchListTile,
        l10n.safetyOptionsAllowDisarmAsDistressTitle,
      );
      await _scrollTo(tester, toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      await _tapSave(tester, l10n);

      final saved = await db.sessionModesDao.getById('d1');
      check(saved!.allowDisarmAsDistress).isFalse();
    });
  });

  group('SafetyOptions — RTL', () {
    testWidgets('expanded section renders without overflow in Arabic', (
      WidgetTester tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(db, _mode());
      // Reuse the router pump but force an Arabic locale via Directionality
      // is unnecessary — MaterialApp resolves locale from supportedLocales.
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
                builder: (BuildContext ctx, GoRouterState s) =>
                    ModeEditorScreen(modeId: mode.id, isDistress: false),
              ),
            ],
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(db),
          child: MaterialApp.router(
            routerConfig: router,
            locale: const Locale('ar'),
            localizationsDelegates: const <LocalizationsDelegate<Object>>[
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData(useMaterial3: true),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _openSafetyOptions(tester, l10n);
      // Reveal the GPS-arrival and timer disarm sub-fields too.
      final gpsToggle = find.widgetWithText(
        SwitchListTile,
        l10n.safetyOptionsGpsArrivalTitle,
      );
      await _scrollTo(tester, gpsToggle);
      await tester.tap(gpsToggle);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('SafetyOptions — distress-variant add-step', () {
    testWidgets('distress add-step sheet omits the check-in category', (
      WidgetTester tester,
    ) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      final db = _emptyDb();
      addTearDown(db.close);
      final mode = await _seedMode(
        db,
        _mode(
          id: 'd1',
          name: 'Panic',
          isDistress: true,
          steps: <ChainStep>[_step('s0', type: ChainStepType.smsContact)],
        ),
      );
      await _pump(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: true),
        _overrides(db),
      );
      await _scrollTo(tester, find.text(l10n.modeChainAddStep));
      await tester.tap(find.text(l10n.modeChainAddStep));
      await tester.pumpAndSettle();
      // Escalation + Panic categories present; Check-in header absent.
      expect(find.text(l10n.eventDefaultsEscalationHeader), findsOneWidget);
      expect(find.text(l10n.eventDefaultsCheckInHeader), findsNothing);
    });
  });
}
