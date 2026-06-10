/// Bug #14 invalidation sweep — the Templates LIST must show an editor save
/// on pop-back.
///
/// [ReminderTemplatesController] caches the DAO read; the editor's Save
/// writes the DAO directly, so without an explicit
/// `ref.invalidate(reminderTemplatesControllerProvider)` in
/// `template_editor_screen._save` the list beneath the popped editor kept
/// the stale name (M5 staleness family). This drives the REAL list → editor
/// → save → list round trip over one database.
library;

import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/features/reminder_templates/reminder_templates_screen.dart';
import 'package:guardianangela/features/template_editor/template_editor_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';
import '../../helpers/widget_test_helpers.dart';

ReminderTemplate _template() => ReminderTemplate(
  id: 'tpl-1',
  name: 'Hydrate',
  title: 'Drink water',
  body: 'Time for a glass',
  confirmationType: ConfirmationType.dismiss,
  isCustom: true,
  displayStyle: ReminderDisplayStyle.subtle,
  isGlobal: true,
);

void main() {
  testWidgets('editor Save refreshes the templates list on pop-back '
      '(bug #14 staleness family)', (WidgetTester tester) async {
    final l10n = await loadL10n(const Locale('en'));
    final db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
    addTearDown(db.close);
    await db.reminderTemplatesDao.upsert(_template());

    final GoRouter router = GoRouter(
      initialLocation: '/settings/reminder-templates',
      routes: <RouteBase>[
        GoRoute(
          path: '/settings/reminder-templates',
          name: RouteNames.settingsReminderTemplates,
          builder: (_, _) => const ReminderTemplatesScreen(),
        ),
        GoRoute(
          path: '/settings/templates/edit',
          name: RouteNames.templateEditor,
          builder: (_, GoRouterState state) =>
              TemplateEditorScreen(templateId: state.uri.queryParameters['id']),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[databaseProvider.overrideWith((_) async => db)],
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
    expect(find.text('Hydrate'), findsOneWidget);

    // Open the editor from the list, rename, and Save (pops the editor).
    await tester.tap(find.text('Hydrate'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Hydrate v2');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
    await tester.pumpAndSettle();

    // Back on the list: the rename is visible without an app restart.
    expect(find.text('Hydrate v2'), findsOneWidget);
    expect(find.text('Hydrate'), findsNothing);
  });
}
