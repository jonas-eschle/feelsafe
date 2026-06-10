/// Bug #14 — the Mode Editor's template picker reads the Drift DAO and
/// refreshes after the in-editor "Manage reminder templates" round trip.
///
/// Pre-fix the picker pool's global half came from
/// `settings.defaults.templates` (a store the Templates screen never
/// writes), loaded once in `_load()`. Both tests here failed pre-fix:
/// the picker neither showed DAO templates nor refreshed on return from
/// the Templates screen (the M5 staleness family).
library;

import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/features/mode_editor/mode_editor_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';
import '../../helpers/widget_test_helpers.dart';

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _FakeAppSettingsRepository extends AppSettingsRepository {
  _FakeAppSettingsRepository() : super(keyProvider: _k);

  static Future<String> _k() async => '00' * 32;

  @override
  Future<AppSettings> load() async => const AppSettings();
}

ReminderTemplate _template(String id, String name) => ReminderTemplate(
  id: id,
  name: name,
  title: 'Title $name',
  body: 'Body $name',
  confirmationType: ConfirmationType.dismiss,
  isCustom: true,
  displayStyle: ReminderDisplayStyle.subtle,
  isGlobal: true,
);

SessionMode _reminderMode() => SessionMode(
  id: 'm1',
  name: 'Walk',
  chainSteps: <ChainStep>[
    ChainStep(
      id: 's0',
      type: ChainStepType.disguisedReminder,
      order: 0,
      waitSeconds: 0,
      durationSeconds: 10,
      gracePeriodSeconds: 5,
      retryCount: 0,
      randomize: false,
      config: const DisguisedReminderConfig(),
    ),
  ],
);

/// Pumps [ModeEditorScreen] for mode `m1` behind a router that also carries
/// the Templates route (a stub destination — the tests mutate the DAO
/// directly to simulate the user's edit there). Returns the router so tests
/// can pop back into the editor.
Future<GoRouter> _pumpEditorWithTemplatesRoute(
  WidgetTester tester,
  GuardianAngelaDatabase db,
) async {
  final GoRouter router = GoRouter(
    initialLocation: '/edit',
    routes: <RouteBase>[
      GoRoute(
        path: '/edit',
        builder: (_, _) =>
            const ModeEditorScreen(modeId: 'm1', isDistress: false),
      ),
      GoRoute(
        path: '/settings/reminder-templates',
        name: RouteNames.settingsReminderTemplates,
        builder: (_, _) => const Scaffold(body: Text('templates-route')),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        databaseProvider.overrideWith((_) async => db),
        appSettingsRepositoryProvider.overrideWithValue(
          _FakeAppSettingsRepository(),
        ),
      ],
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
  return router;
}

Future<void> _scrollTo(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(
    target,
    120,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

/// Expands the disguisedReminder step tile and scrolls its template picker's
/// "Manage reminder templates" link into view.
Future<void> _openPicker(WidgetTester tester, AppLocalizations l10n) async {
  await tester.tap(find.text(l10n.chainStepNameDisguisedReminder));
  await tester.pumpAndSettle();
  await _scrollTo(tester, find.text(l10n.safetyOptionsManageTemplates));
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  group('ModeEditorScreen — DAO-sourced template picker (bug #14)', () {
    testWidgets('the picker offers the GLOBAL templates from the Drift DAO '
        '(the store the Templates screen writes)', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
      addTearDown(db.close);
      await db.sessionModesDao.upsert(_reminderMode());
      await db.reminderTemplatesDao.upsert(_template('tpl-1', 'Old Name'));

      await _pumpEditorWithTemplatesRoute(tester, db);
      await _openPicker(tester, l10n);

      // The expanded tile's picker is fully built (even when clipped), so
      // existence needs no scrolling.
      expect(find.widgetWithText(FilterChip, 'Old Name'), findsOneWidget);
    });

    testWidgets('STALENESS: after pushing the Templates route from inside '
        'the open editor, a DAO mutation made there shows in the picker on '
        'pop-back', (WidgetTester tester) async {
      final l10n = await loadL10n(const Locale('en'));
      final db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
      addTearDown(db.close);
      await db.sessionModesDao.upsert(_reminderMode());
      await db.reminderTemplatesDao.upsert(_template('tpl-1', 'Old Name'));

      final router = await _pumpEditorWithTemplatesRoute(tester, db);
      await _openPicker(tester, l10n);

      // Push the Templates screen from inside the open editor.
      await tester.tap(find.text(l10n.safetyOptionsManageTemplates));
      await tester.pumpAndSettle();
      expect(find.text('templates-route'), findsOneWidget);

      // While away, the user renames the template and creates a new one
      // (both are plain DAO writes — the Templates screens write the DAO).
      await db.reminderTemplatesDao.upsert(_template('tpl-1', 'New Name'));
      await db.reminderTemplatesDao.upsert(_template('tpl-2', 'Brand New'));

      // Pop back into the still-mounted editor.
      router.pop();
      await tester.pumpAndSettle();

      // The picker must show the fresh DAO state, not the load-once cache.
      expect(find.widgetWithText(FilterChip, 'New Name'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Old Name'), findsNothing);
      expect(find.widgetWithText(FilterChip, 'Brand New'), findsOneWidget);
    });
  });
}
