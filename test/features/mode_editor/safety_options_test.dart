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
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/button_type.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/enums/gps_accuracy.dart';
import 'package:guardianangela/domain/enums/gps_destination_source.dart';
import 'package:guardianangela/domain/enums/press_pattern.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/models/app_defaults.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/gps_logging_config.dart';
import 'package:guardianangela/domain/models/mode_overrides.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/stealth_config.dart';
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

/// A mode-local [ReminderTemplate] fixture (`isGlobal: false`).
ReminderTemplate _localTemplate({
  String id = 'lt-1',
  String name = 'Local note',
  String title = 'Local title',
}) => ReminderTemplate(
  id: id,
  name: name,
  title: title,
  body: 'Tap to confirm you are safe.',
  confirmationType: ConfirmationType.tapButton,
  isCustom: true,
  displayStyle: ReminderDisplayStyle.fullScreen,
  isGlobal: false,
);

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
  // A distress mode without an SMS/call step raises a non-blocking warning
  // (spec 04:1659). These tests assert other fields, so proceed past it.
  final Finder saveAnyway = find.widgetWithText(
    FilledButton,
    l10n.validationSaveAnyway,
  );
  if (saveAnyway.evaluate().isNotEmpty) {
    await tester.tap(saveAnyway);
    await tester.pumpAndSettle();
  }
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

  // T1 — Manage-link navigation -------------------------------------------
  group('SafetyOptions — manage-link navigation', () {
    testWidgets('"Manage distress modes →" navigates to /distress-modes', (
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
      final link = find.text(l10n.safetyOptionsManageDistressModes);
      await _scrollTo(tester, link);
      await tester.tap(link);
      await tester.pumpAndSettle();
      expect(find.text('distress modes screen'), findsOneWidget);
    });

    testWidgets(
      '"Manage reminder templates" navigates to the templates screen',
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
        final link = find.text(l10n.safetyOptionsManageTemplates);
        await _scrollTo(tester, link);
        await tester.tap(link);
        await tester.pumpAndSettle();
        expect(find.text('templates screen'), findsOneWidget);
      },
    );
  });

  // T2 — distress-trigger edit/remove --------------------------------------
  group('SafetyOptions — distress-trigger edit/remove', () {
    testWidgets('changing the pattern to longPress normalises and persists', (
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
          distressTriggers: const <DistressTrigger>[
            HardwareButtonDistressTrigger(),
          ],
        ),
      );
      await _pump(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        _overrides(db),
      );
      await _openSafetyOptions(tester, l10n);
      // Expand the trigger tile via its collapsed summary (volumeUp / 5×).
      final summary = find.text(
        l10n.safetyOptionsTriggerHardwareRepeat(
          l10n.safetyOptionsButtonVolumeUp,
          '5',
        ),
      );
      await _scrollTo(tester, summary);
      await tester.tap(summary);
      await tester.pumpAndSettle();
      // Open the pattern dropdown (current value = "repeat") and pick "long".
      final patternValue = find.text(l10n.safetyOptionsPatternRepeat);
      await _scrollTo(tester, patternValue);
      await tester.tap(patternValue);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.safetyOptionsPatternLong).last);
      await tester.pumpAndSettle();
      await _tapSave(tester, l10n);

      final saved = await db.sessionModesDao.getById('m1');
      final trigger =
          saved!.distressTriggers.single as HardwareButtonDistressTrigger;
      check(trigger.pattern).equals(PressPattern.longPress);
      check(trigger.durationSeconds).equals(2.0);
      // pressCount is normalised back to the model default for longPress.
      check(trigger.pressCount).equals(5);
    });

    testWidgets('deleting a distress trigger persists an empty list', (
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
          distressTriggers: const <DistressTrigger>[
            HardwareButtonDistressTrigger(),
          ],
        ),
      );
      await _pump(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        _overrides(db),
      );
      await _openSafetyOptions(tester, l10n);
      // The trigger tile's trailing delete button.
      final deleteBtn = find.descendant(
        of: find.byType(ExpansionTile),
        matching: find.widgetWithIcon(IconButton, Icons.delete_outline),
      );
      await _scrollTo(tester, deleteBtn.first);
      await tester.tap(deleteBtn.first);
      await tester.pumpAndSettle();
      await _tapSave(tester, l10n);

      final saved = await db.sessionModesDao.getById('m1');
      check(saved!.distressTriggers).isEmpty();
    });

    testWidgets('changing the button to volumeDown persists', (
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
          distressTriggers: const <DistressTrigger>[
            HardwareButtonDistressTrigger(),
          ],
        ),
      );
      await _pump(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        _overrides(db),
      );
      await _openSafetyOptions(tester, l10n);
      final summary = find.text(
        l10n.safetyOptionsTriggerHardwareRepeat(
          l10n.safetyOptionsButtonVolumeUp,
          '5',
        ),
      );
      await _scrollTo(tester, summary);
      await tester.tap(summary);
      await tester.pumpAndSettle();
      // Open the button dropdown (current value = "Volume up") → "Volume down".
      final buttonValue = find.text(l10n.safetyOptionsButtonVolumeUp);
      await _scrollTo(tester, buttonValue);
      await tester.tap(buttonValue.first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.safetyOptionsButtonVolumeDown).last);
      await tester.pumpAndSettle();
      await _tapSave(tester, l10n);

      final saved = await db.sessionModesDao.getById('m1');
      final trigger =
          saved!.distressTriggers.single as HardwareButtonDistressTrigger;
      check(trigger.buttonType).equals(ButtonType.volumeDown);
    });
  });

  // T3 — GPS-arrival radius at a non-default value -------------------------
  group('SafetyOptions — GPS-arrival radius', () {
    testWidgets('dragging the radius slider persists a non-default radius', (
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
      // The radius slider is the first Slider revealed by the enabled GPS
      // trigger. Drag it far right (towards the 5 km max).
      final slider = find.byType(Slider).first;
      await _scrollTo(tester, slider);
      await tester.drag(slider, const Offset(400, 0));
      await tester.pumpAndSettle();
      await _tapSave(tester, l10n);

      final saved = await db.sessionModesDao.getById('m1');
      final gps = saved!.disarmTriggers
          .whereType<GpsArrivalDisarmTrigger>()
          .single;
      // Default is 200 m; a rightward drag must raise it within 50–5000.
      check(gps.radiusMeters).isGreaterThan(200);
      check(gps.radiusMeters).isLessOrEqual(5000);
    });
  });

  // T4 — Inherit-clears round-trip for Stealth + Event-defaults; two-slot ---
  group('SafetyOptions — inherit clears overrides', () {
    testWidgets('Stealth Custom then Inherit clears overrides to null', (
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
      await _scrollTo(tester, find.text(l10n.safetyOptionsStealthTitle));
      // Stealth's Custom is the 2nd tri-state "Custom" in the section.
      await tester.tap(find.text(l10n.safetyOptionsTriStateCustom).at(1));
      await tester.pumpAndSettle();
      await _scrollTo(tester, find.text(l10n.safetyOptionsStealthTitle));
      await tester.tap(find.text(l10n.safetyOptionsTriStateInherit).at(1));
      await tester.pumpAndSettle();
      await _tapSave(tester, l10n);

      final saved = await db.sessionModesDao.getById('m1');
      check(saved!.overrides).isNull();
    });

    testWidgets('Event-defaults Custom then Inherit clears overrides to null', (
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
      await tester.tap(find.text(l10n.safetyOptionsTriStateCustom).last);
      await tester.pumpAndSettle();
      await _scrollTo(tester, find.text(l10n.safetyOptionsEventDefaultsTitle));
      // Event-defaults' two-state "Inherit" is the last "Inherit" in the
      // section (after the GPS-logging and Stealth tri-states).
      await tester.tap(
        find.text(l10n.safetyOptionsEventDefaultsTwoStateInherit).last,
      );
      await tester.pumpAndSettle();
      await _tapSave(tester, l10n);

      final saved = await db.sessionModesDao.getById('m1');
      check(saved!.overrides).isNull();
    });

    testWidgets(
      'flipping Stealth→Inherit preserves a sibling GPS-logging override',
      (WidgetTester tester) async {
        final l10n = await AppLocalizations.delegate.load(const Locale('en'));
        final db = _emptyDb();
        addTearDown(db.close);
        // Seed BOTH gpsLogging (custom) and stealth (custom) overrides.
        final mode = await _seedMode(
          db,
          SessionMode(
            id: 'm1',
            name: 'Walk',
            chainSteps: <ChainStep>[_step('s0')],
            overrides: const ModeOverrides(
              gpsLogging: GpsLoggingConfig(intervalSeconds: 99),
              stealth: StealthConfig(enabled: true),
            ),
          ),
        );
        await _pump(
          tester,
          ModeEditorScreen(modeId: mode.id, isDistress: false),
          _overrides(db),
        );
        await _openSafetyOptions(tester, l10n);
        // Flip the stealth tri-state to Inherit (2nd group's "Inherit").
        await _scrollTo(tester, find.text(l10n.safetyOptionsStealthTitle));
        await tester.tap(find.text(l10n.safetyOptionsTriStateInherit).at(1));
        await tester.pumpAndSettle();
        await _tapSave(tester, l10n);

        final saved = await db.sessionModesDao.getById('m1');
        // GPS-logging override survives; stealth is dropped — the base slot
        // must not be lost when only stealth flips to inherit.
        check(saved!.overrides).isNotNull();
        check(saved.overrides!.gpsLogging).isNotNull();
        check(saved.overrides!.gpsLogging!.intervalSeconds).equals(99);
        check(saved.overrides!.stealth).isNull();
      },
    );
  });

  // T5 — GPS-logging Custom: edit an inline field round-trips --------------
  // (Uses the accuracy dropdown: the former includeInSms toggle was trimmed
  // from GpsLoggingConfig — D-DATA-22 — so accuracy is the editable inline
  // field that proves the Custom draft round-trips.)
  group('SafetyOptions — GPS-logging inline field', () {
    testWidgets('changing accuracy under Custom round-trips', (
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
      // Enter Custom (1st tri-state Custom) → inline GpsLoggingFields appears.
      await tester.tap(find.text(l10n.safetyOptionsTriStateCustom).first);
      await tester.pumpAndSettle();
      // accuracy defaults to high; switch it to Balanced via the dropdown.
      final accuracyDropdown = find.text(l10n.gpsLoggingAccuracyHigh);
      await _scrollTo(tester, accuracyDropdown);
      await tester.tap(accuracyDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.gpsLoggingAccuracyBalanced).last);
      await tester.pumpAndSettle();
      await _tapSave(tester, l10n);

      final saved = await db.sessionModesDao.getById('m1');
      check(saved!.overrides?.gpsLogging?.enabled).equals(true);
      check(saved.overrides?.gpsLogging?.accuracy).equals(GpsAccuracy.medium);
    });
  });

  // T6 — Local Templates: remove + add -------------------------------------
  group('SafetyOptions — local templates', () {
    testWidgets('removing the only local template clears overrides to null', (
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
          overrides: ModeOverrides(
            localTemplates: <ReminderTemplate>[_localTemplate()],
          ),
        ),
      );
      await _pump(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        _overrides(db),
      );
      await _openSafetyOptions(tester, l10n);
      // The local-template list tile's trailing delete button.
      final tile = find.widgetWithText(ListTile, 'Local note');
      await _scrollTo(tester, tile);
      final deleteBtn = find.descendant(
        of: tile,
        matching: find.widgetWithIcon(IconButton, Icons.delete_outline),
      );
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();
      await _tapSave(tester, l10n);

      final saved = await db.sessionModesDao.getById('m1');
      // The sole override removed → the whole overrides object normalises null.
      check(saved!.overrides).isNull();
    });

    testWidgets('[+ Add Template] stages a new local template into overrides', (
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
      final addBtn = find.text(l10n.safetyOptionsAddTemplate);
      await _scrollTo(tester, addBtn);
      await tester.tap(addBtn);
      await tester.pumpAndSettle();
      // The full-screen editor sheet opens with the create title.
      expect(find.text(l10n.templatesCreateTitle), findsWidgets);
      // Fill the three required fields (name / title / body).
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Delivery');
      await tester.enterText(fields.at(1), 'Package arrived');
      await tester.enterText(fields.at(2), 'Confirm you collected it.');
      await tester.pumpAndSettle();
      // Save the template (the sheet's Save action returns it to the editor).
      await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
      await tester.pumpAndSettle();
      // Now save the mode itself.
      await _tapSave(tester, l10n);

      final saved = await db.sessionModesDao.getById('m1');
      check(saved!.overrides).isNotNull();
      final locals = saved.overrides!.localTemplates;
      check(locals).isNotNull();
      check(locals!.length).equals(1);
      check(locals.single.name).equals('Delivery');
      check(locals.single.isGlobal).isFalse();
      check(locals.single.isCustom).isTrue();
      // It must NOT have leaked into the global templates table.
      final globals = await db.reminderTemplatesDao.getAll();
      check(globals).isEmpty();
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

  // T7 — distress-trigger pattern fields (press count / hold duration) ------
  group('SafetyOptions — distress-trigger pattern fields', () {
    testWidgets('incrementing the press count persists pressCount + 1', (
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
          distressTriggers: const <DistressTrigger>[
            HardwareButtonDistressTrigger(),
          ],
        ),
      );
      await _pump(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        _overrides(db),
      );
      await _openSafetyOptions(tester, l10n);
      final summary = find.text(
        l10n.safetyOptionsTriggerHardwareRepeat(
          l10n.safetyOptionsButtonVolumeUp,
          '5',
        ),
      );
      await _scrollTo(tester, summary);
      await tester.tap(summary);
      await tester.pumpAndSettle();
      // The repeat pattern reveals the press-count spinner; tap its +.
      await _scrollTo(tester, find.text(l10n.safetyOptionsTriggerPressCount));
      await tester.tap(find.byIcon(Icons.add_circle_outline).first);
      await tester.pumpAndSettle();
      await _tapSave(tester, l10n);

      final saved = await db.sessionModesDao.getById('m1');
      final trigger =
          saved!.distressTriggers.single as HardwareButtonDistressTrigger;
      check(trigger.pressCount).equals(6);
      check(trigger.pattern).equals(PressPattern.repeatPress);
    });

    testWidgets('dragging the hold-duration slider persists a new duration', (
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
          distressTriggers: const <DistressTrigger>[
            HardwareButtonDistressTrigger(
              pattern: PressPattern.longPress,
              durationSeconds: 2.0,
            ),
          ],
        ),
      );
      await _pump(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        _overrides(db),
      );
      await _openSafetyOptions(tester, l10n);
      final summary = find.text(
        l10n.safetyOptionsTriggerHardwareLong(
          l10n.safetyOptionsButtonVolumeUp,
          '2.0',
        ),
      );
      await _scrollTo(tester, summary);
      await tester.tap(summary);
      await tester.pumpAndSettle();
      // The longPress pattern reveals the hold-duration slider; drag it.
      final slider = find.byType(Slider).first;
      await _scrollTo(tester, slider);
      await tester.drag(slider, const Offset(150, 0));
      await tester.pumpAndSettle();
      await _tapSave(tester, l10n);

      final saved = await db.sessionModesDao.getById('m1');
      final trigger =
          saved!.distressTriggers.single as HardwareButtonDistressTrigger;
      check(trigger.pattern).equals(PressPattern.longPress);
      check(trigger.durationSeconds).isNotNull();
      check(trigger.durationSeconds!).isGreaterThan(2.0);
      check(trigger.durationSeconds!).isLessOrEqual(10.0);
    });

    testWidgets('changing the pattern back to repeat normalises duration', (
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
          distressTriggers: const <DistressTrigger>[
            HardwareButtonDistressTrigger(
              pattern: PressPattern.longPress,
              durationSeconds: 2.0,
            ),
          ],
        ),
      );
      await _pump(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        _overrides(db),
      );
      await _openSafetyOptions(tester, l10n);
      final summary = find.text(
        l10n.safetyOptionsTriggerHardwareLong(
          l10n.safetyOptionsButtonVolumeUp,
          '2.0',
        ),
      );
      await _scrollTo(tester, summary);
      await tester.tap(summary);
      await tester.pumpAndSettle();
      // Pattern dropdown (current = "long") → "repeat".
      final patternValue = find.text(l10n.safetyOptionsPatternLong);
      await _scrollTo(tester, patternValue);
      await tester.tap(patternValue);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.safetyOptionsPatternRepeat).last);
      await tester.pumpAndSettle();
      await _tapSave(tester, l10n);

      final saved = await db.sessionModesDao.getById('m1');
      final trigger =
          saved!.distressTriggers.single as HardwareButtonDistressTrigger;
      check(trigger.pattern).equals(PressPattern.repeatPress);
      // repeat ⇒ duration normalised back to null (save-time validation).
      check(trigger.durationSeconds).isNull();
      check(trigger.pressCount).equals(5);
    });
  });

  // T8 — Timer disarm: hour-scale duration label + slider --------------------
  group('SafetyOptions — timer disarm duration', () {
    testWidgets('a 1 h duration renders the hours/minutes label', (
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
          disarmTriggers: const <DisarmTrigger>[
            TimerDisarmTrigger(durationSeconds: 3600),
          ],
        ),
      );
      await _pump(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        _overrides(db),
      );
      await _openSafetyOptions(tester, l10n);
      final label = find.text(
        '${l10n.safetyOptionsTimerDuration}: '
        '${l10n.safetyOptionsDurationHoursMinutes('1', '0')}',
      );
      await _scrollTo(tester, label);
      expect(label, findsOneWidget);
    });

    testWidgets('a 1 h 30 min duration renders hours AND minutes', (
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
          disarmTriggers: const <DisarmTrigger>[
            TimerDisarmTrigger(durationSeconds: 5400),
          ],
        ),
      );
      await _pump(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        _overrides(db),
      );
      await _openSafetyOptions(tester, l10n);
      final label = find.text(
        '${l10n.safetyOptionsTimerDuration}: '
        '${l10n.safetyOptionsDurationHoursMinutes('1', '30')}',
      );
      await _scrollTo(tester, label);
      expect(label, findsOneWidget);
    });

    testWidgets('dragging the timer slider persists a 5-min-snapped duration', (
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
          disarmTriggers: const <DisarmTrigger>[
            TimerDisarmTrigger(durationSeconds: 1800),
          ],
        ),
      );
      await _pump(
        tester,
        ModeEditorScreen(modeId: mode.id, isDistress: false),
        _overrides(db),
      );
      await _openSafetyOptions(tester, l10n);
      // The timer slider is the only Slider (no GPS trigger seeded).
      final slider = find.byType(Slider).first;
      await _scrollTo(tester, slider);
      await tester.drag(slider, const Offset(200, 0));
      await tester.pumpAndSettle();
      await _tapSave(tester, l10n);

      final saved = await db.sessionModesDao.getById('m1');
      final timer = saved!.disarmTriggers
          .whereType<TimerDisarmTrigger>()
          .single;
      check(timer.durationSeconds).not((it) => it.equals(1800));
      // onChanged snaps to 5-minute steps.
      check(timer.durationSeconds % 300).equals(0);
    });
  });

  // T9 — Stealth Off + inline stealth field passthrough ----------------------
  group('SafetyOptions — stealth Off and inline fields', () {
    testWidgets('selecting Off persists a disabled stealth override', (
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
      await _scrollTo(tester, find.text(l10n.safetyOptionsStealthTitle));
      // The stealth selector's "Off" is the second tri-state in the section.
      await tester.tap(find.text(l10n.safetyOptionsTriStateOff).at(1));
      await tester.pumpAndSettle();
      await _tapSave(tester, l10n);

      final saved = await db.sessionModesDao.getById('m1');
      check(saved!.overrides?.stealth).isNotNull();
      check(saved.overrides!.stealth!.enabled).isFalse();
    });

    testWidgets('toggling lock-task under Custom round-trips', (
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
      await _scrollTo(tester, find.text(l10n.safetyOptionsStealthTitle));
      await tester.tap(find.text(l10n.safetyOptionsTriStateCustom).at(1));
      await tester.pumpAndSettle();
      // The inline StealthConfigFields appear; toggle lock-task (off → on).
      final lockTask = find.widgetWithText(
        SwitchListTile,
        l10n.stealthLockTaskLabel,
      );
      await _scrollTo(tester, lockTask);
      await tester.tap(lockTask);
      await tester.pumpAndSettle();
      await _tapSave(tester, l10n);

      final saved = await db.sessionModesDao.getById('m1');
      check(saved!.overrides?.stealth?.enabled).equals(true);
      check(saved.overrides?.stealth?.lockTaskMode).equals(true);
    });
  });

  // T10 — Event-defaults inline editor passthrough ---------------------------
  group('SafetyOptions — event-defaults inline editor', () {
    testWidgets('editing a per-type default under Custom persists it', (
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
      await tester.tap(find.text(l10n.safetyOptionsTriStateCustom).last);
      await tester.pumpAndSettle();
      // Expand the loudAlarm tile (unique text — the chain has no such step)
      // and flip its flash-screen default (blackScreenMode is no longer an
      // event-form field — it lives in the step panel's Retry & Advanced,
      // spec 04:1592/1614).
      final tile = find.text(l10n.chainStepNameLoudAlarm);
      await _scrollTo(tester, tile);
      await tester.tap(tile);
      await tester.pumpAndSettle();
      final flashScreen = find.widgetWithText(
        SwitchListTile,
        l10n.eventDefaultsLoudAlarmFlashScreen,
      );
      await _scrollTo(tester, flashScreen);
      await tester.tap(flashScreen);
      await tester.pumpAndSettle();
      await _tapSave(tester, l10n);

      final saved = await db.sessionModesDao.getById('m1');
      final defaults = saved!.overrides?.eventDefaults;
      check(defaults).isNotNull();
      check(defaults!.loudAlarm.flashScreen).isTrue();
      // Sibling defaults are untouched.
      check(defaults.holdButton).equals(const HoldButtonConfig());
    });
  });

  // T11 — Local template sheet: invalid save + cancel ------------------------
  group('SafetyOptions — local template sheet validation', () {
    testWidgets('saving an empty template shows the snackbar, stays open', (
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
      final addBtn = find.text(l10n.safetyOptionsAddTemplate);
      await _scrollTo(tester, addBtn);
      await tester.tap(addBtn);
      await tester.pumpAndSettle();
      // Save with all required fields empty → inline snackbar, no pop.
      await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
      await tester.pump();
      expect(find.text('Name, title, and body required.'), findsOneWidget);
      expect(find.text(l10n.templatesCreateTitle), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('cancelling the sheet stages nothing', (
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
      final addBtn = find.text(l10n.safetyOptionsAddTemplate);
      await _scrollTo(tester, addBtn);
      await tester.tap(addBtn);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, l10n.commonCancel));
      await tester.pumpAndSettle();
      // Back in the editor; no template staged.
      expect(find.text(l10n.templatesCreateTitle), findsNothing);
      await _tapSave(tester, l10n);

      final saved = await db.sessionModesDao.getById('m1');
      check(saved!.overrides).isNull();
    });
  });
}
