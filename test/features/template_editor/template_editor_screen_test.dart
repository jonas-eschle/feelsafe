/// Widget tests for [TemplateEditorScreen].
///
/// Covers spec 04 §Template Editor (lines 2180–2254): name/title/body
/// fields, multiline body, confirmation-type radio buttons,
/// display-style radio buttons, loading state, create/edit modes,
/// save writes to the DB, cancel pops without saving, validation
/// (required name, title, body), plus dark-mode / RTL / accessibility
/// smokes.
///
/// The screen reads [databaseProvider] directly (no separate
/// controller). Every test overrides [databaseProvider] with an
/// in-memory database via [_openDb] / [_dbOverride].
///
/// Tests that exercise the _save() path call [_pumpWithRouter] which
/// mounts the screen inside a minimal [GoRouter] shell so that
/// [context.pop()] resolves without a "No GoRouter" error.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/features/template_editor/template_editor_screen.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import 'package:guardianangela/services/service_providers.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Opens a no-seed in-memory database.
GuardianAngelaDatabase _openDb() =>
    GuardianAngelaDatabase.memory(seedCallback: (_) async {});

/// Returns an [Override] that wires [databaseProvider] to [db].
Override _dbOverride(GuardianAngelaDatabase db) =>
    databaseProvider.overrideWith((_) async => db);

/// A canonical [ReminderTemplate] fixture for edit-mode tests.
ReminderTemplate _template({
  String id = 't-1',
  String name = 'Calendar',
  String title = 'Meeting at 3pm',
  String body = 'Tap to confirm you are safe.',
  ConfirmationType confirmationType = ConfirmationType.tapButton,
  ReminderDisplayStyle displayStyle = ReminderDisplayStyle.fullScreen,
}) => ReminderTemplate(
  id: id,
  name: name,
  title: title,
  body: body,
  confirmationType: confirmationType,
  isCustom: true,
  displayStyle: displayStyle,
  isGlobal: true,
);

/// Pumps [TemplateEditorScreen] inside a minimal [GoRouter] shell so
/// that [context.pop()] inside [_save] resolves without error.
///
/// The router exposes:
/// - `/` — a blank sentinel the screen can pop back to.
/// - `/edit` — the [TemplateEditorScreen] (with optional [templateId]).
Future<void> _pumpWithRouter(
  WidgetTester tester, {
  String? templateId,
  required List<Override> overrides,
  bool settle = true,
}) async {
  final router = GoRouter(
    initialLocation: '/edit',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, _) => const Scaffold(body: Text('home')),
        routes: <RouteBase>[
          GoRoute(
            path: 'edit',
            builder: (context, _) =>
                TemplateEditorScreen(templateId: templateId),
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
  if (settle) {
    await tester.pumpAndSettle();
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late GuardianAngelaDatabase db;
  late List<Override> baseOverrides;

  setUp(() {
    db = _openDb();
    baseOverrides = <Override>[_dbOverride(db)];
  });

  tearDown(() async {
    await db.close();
  });

  // ---- Group: AppBar -------------------------------------------------------

  group('TemplateEditorScreen — AppBar', () {
    testWidgets('shows "New template" title in create mode', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const TemplateEditorScreen(),
        overrides: baseOverrides,
      );
      expect(find.text(l10n.templatesCreateTitle), findsOneWidget);
    });

    testWidgets('shows "Edit template" title when templateId is provided', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await db.reminderTemplatesDao.upsert(_template());
      await pumpScreen(
        tester,
        const TemplateEditorScreen(templateId: 't-1'),
        overrides: baseOverrides,
      );
      expect(find.text(l10n.templatesEditTitle), findsOneWidget);
    });

    testWidgets('app bar has a Save action button', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const TemplateEditorScreen(),
        overrides: baseOverrides,
      );
      expect(
        find.widgetWithText(TextButton, l10n.commonSave),
        findsOneWidget,
      );
    });
  });

  // ---- Group: Async states -------------------------------------------------

  group('TemplateEditorScreen — async states', () {
    testWidgets('shows CircularProgressIndicator while loading', (
      WidgetTester tester,
    ) async {
      // The spinner only appears during _load() in edit mode (create mode
      // sets _loading = false synchronously). A Completer that never
      // completes keeps _loading = true without leaving a pending timer.
      final completer = Completer<GuardianAngelaDatabase>();
      final neverOverride = databaseProvider.overrideWith(
        (_) => completer.future,
      );
      await pumpScreen(
        tester,
        const TemplateEditorScreen(templateId: 't-1'),
        overrides: <Override>[neverOverride],
        settle: false,
      );
      await tester.pump(); // one frame: still loading.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Complete with the real db so tearDown can close it cleanly.
      completer.complete(db);
    });

    testWidgets('hides spinner and shows form once data loads', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const TemplateEditorScreen(),
        overrides: baseOverrides,
      );
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(TextField), findsWidgets);
    });
  });

  // ---- Group: Form fields present -----------------------------------------

  group('TemplateEditorScreen — form fields', () {
    testWidgets('renders name, title and body text fields', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const TemplateEditorScreen(),
        overrides: baseOverrides,
      );
      expect(find.text(l10n.templatesNameLabel), findsOneWidget);
      expect(find.text(l10n.templatesTitleLabel), findsOneWidget);
      expect(find.text(l10n.templatesBodyLabel), findsOneWidget);
    });

    testWidgets('body field is multiline (maxLines > 1)', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const TemplateEditorScreen(),
        overrides: baseOverrides,
      );
      // The body field is the last TextField; it has maxLines: 3.
      final fields = tester.widgetList<TextField>(
        find.byType(TextField),
      ).toList();
      // Spec: name, title, body — three TextField widgets.
      check(fields).length.isGreaterOrEqual(3);
      final bodyField = fields.last;
      check(bodyField.maxLines).isNotNull();
      check(bodyField.maxLines!).isGreaterThan(1);
    });

    testWidgets('renders three TextField widgets in create mode', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const TemplateEditorScreen(),
        overrides: baseOverrides,
      );
      expect(find.byType(TextField), findsNWidgets(3));
    });

    testWidgets('all text fields start empty in create mode', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const TemplateEditorScreen(),
        overrides: baseOverrides,
      );
      final fields = tester
          .widgetList<TextField>(find.byType(TextField))
          .toList();
      for (final field in fields) {
        check(field.controller!.text).isEmpty();
      }
    });
  });

  // ---- Group: Radio buttons ------------------------------------------------

  group('TemplateEditorScreen — confirmation type radios', () {
    testWidgets('renders a RadioListTile for each ConfirmationType', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const TemplateEditorScreen(),
        overrides: baseOverrides,
      );
      // One RadioListTile per ConfirmationType value.
      expect(
        find.byType(RadioListTile<ConfirmationType>),
        findsNWidgets(ConfirmationType.values.length),
      );
    });

    testWidgets('tapButton is selected by default', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const TemplateEditorScreen(),
        overrides: baseOverrides,
      );
      // Read groupValue from the RadioGroup ancestor — not the deprecated
      // RadioListTile.groupValue field.
      final group = tester.widget<RadioGroup<ConfirmationType>>(
        find.byType(RadioGroup<ConfirmationType>),
      );
      check(group.groupValue).equals(ConfirmationType.tapButton);
    });

    testWidgets('tapping a different ConfirmationType selects it', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const TemplateEditorScreen(),
        overrides: baseOverrides,
      );
      // Tap the 'swipe' option by name.
      await tester.tap(find.text(ConfirmationType.swipe.name));
      await tester.pumpAndSettle();
      final group = tester.widget<RadioGroup<ConfirmationType>>(
        find.byType(RadioGroup<ConfirmationType>),
      );
      check(group.groupValue).equals(ConfirmationType.swipe);
    });
  });

  group('TemplateEditorScreen — display style radios', () {
    testWidgets('renders a RadioListTile for each ReminderDisplayStyle', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const TemplateEditorScreen(),
        overrides: baseOverrides,
      );
      expect(
        find.byType(RadioListTile<ReminderDisplayStyle>),
        findsNWidgets(ReminderDisplayStyle.values.length),
      );
    });

    testWidgets('fullScreen is selected by default', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const TemplateEditorScreen(),
        overrides: baseOverrides,
      );
      final group = tester.widget<RadioGroup<ReminderDisplayStyle>>(
        find.byType(RadioGroup<ReminderDisplayStyle>),
      );
      check(group.groupValue).equals(ReminderDisplayStyle.fullScreen);
    });

    testWidgets('tapping "subtle" selects it', (WidgetTester tester) async {
      await pumpScreen(
        tester,
        const TemplateEditorScreen(),
        overrides: baseOverrides,
      );
      // The display-style radios are below the fold; use ensureVisible on the
      // specific RadioListTile to scroll it into view, then tap its title.
      final subtileFinder = find.byWidgetPredicate(
        (w) =>
            w is RadioListTile<ReminderDisplayStyle> &&
            w.value == ReminderDisplayStyle.subtle,
      );
      await tester.ensureVisible(subtileFinder);
      await tester.pumpAndSettle();
      await tester.tap(subtileFinder);
      await tester.pumpAndSettle();
      final group = tester.widget<RadioGroup<ReminderDisplayStyle>>(
        find.byType(RadioGroup<ReminderDisplayStyle>),
      );
      check(group.groupValue).equals(ReminderDisplayStyle.subtle);
    });
  });

  // ---- Group: Edit mode pre-population ------------------------------------

  group('TemplateEditorScreen — edit mode', () {
    testWidgets('pre-fills name, title and body from stored template', (
      WidgetTester tester,
    ) async {
      await db.reminderTemplatesDao.upsert(
        _template(
          name: 'Fitness',
          title: 'Run complete',
          body: 'Did you finish your run safely?',
        ),
      );
      await pumpScreen(
        tester,
        const TemplateEditorScreen(templateId: 't-1'),
        overrides: baseOverrides,
      );
      final fields = tester
          .widgetList<TextField>(find.byType(TextField))
          .toList();
      check(fields[0].controller!.text).equals('Fitness');
      check(fields[1].controller!.text).equals('Run complete');
      check(fields[2].controller!.text).equals('Did you finish your run safely?');
    });

    testWidgets('pre-selects confirmationType from stored template', (
      WidgetTester tester,
    ) async {
      await db.reminderTemplatesDao.upsert(
        _template(confirmationType: ConfirmationType.swipe),
      );
      await pumpScreen(
        tester,
        const TemplateEditorScreen(templateId: 't-1'),
        overrides: baseOverrides,
      );
      final group = tester.widget<RadioGroup<ConfirmationType>>(
        find.byType(RadioGroup<ConfirmationType>),
      );
      check(group.groupValue).equals(ConfirmationType.swipe);
    });

    testWidgets('pre-selects displayStyle from stored template', (
      WidgetTester tester,
    ) async {
      await db.reminderTemplatesDao.upsert(
        _template(displayStyle: ReminderDisplayStyle.subtle),
      );
      await pumpScreen(
        tester,
        const TemplateEditorScreen(templateId: 't-1'),
        overrides: baseOverrides,
      );
      final group = tester.widget<RadioGroup<ReminderDisplayStyle>>(
        find.byType(RadioGroup<ReminderDisplayStyle>),
      );
      check(group.groupValue).equals(ReminderDisplayStyle.subtle);
    });

    testWidgets(
      'shows form (not spinner) after async load in edit mode',
      (WidgetTester tester) async {
        await db.reminderTemplatesDao.upsert(_template());
        await pumpScreen(
          tester,
          const TemplateEditorScreen(templateId: 't-1'),
          overrides: baseOverrides,
        );
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(TextField), findsWidgets);
      },
    );
  });

  // ---- Group: Validation on save ------------------------------------------

  group('TemplateEditorScreen — validation', () {
    testWidgets('shows snack bar when all fields are empty on save', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const TemplateEditorScreen(),
        overrides: baseOverrides,
      );
      await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('shows snack bar when name is empty but others filled', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const TemplateEditorScreen(),
        overrides: baseOverrides,
      );
      // Leave name empty; fill title + body.
      await tester.enterText(find.byType(TextField).at(1), 'Some title');
      await tester.enterText(find.byType(TextField).at(2), 'Some body text');
      await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('shows snack bar when title is empty but name + body filled', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const TemplateEditorScreen(),
        overrides: baseOverrides,
      );
      await tester.enterText(find.byType(TextField).at(0), 'My template');
      // Leave title empty.
      await tester.enterText(find.byType(TextField).at(2), 'Some body text');
      await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('shows snack bar when body is empty but name + title filled', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const TemplateEditorScreen(),
        overrides: baseOverrides,
      );
      await tester.enterText(find.byType(TextField).at(0), 'My template');
      await tester.enterText(find.byType(TextField).at(1), 'My title');
      // Leave body empty.
      await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('valid form does NOT show a snack bar', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpWithRouter(tester, overrides: baseOverrides);
      await tester.enterText(find.byType(TextField).at(0), 'App Update');
      await tester.enterText(find.byType(TextField).at(1), 'New version');
      await tester.enterText(find.byType(TextField).at(2), 'Update available.');
      await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    });
  });

  // ---- Group: Save persists template --------------------------------------

  group('TemplateEditorScreen — save', () {
    testWidgets('valid create-mode form persists template to the DB', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpWithRouter(tester, overrides: baseOverrides);
      await tester.enterText(
        find.byType(TextField).at(0),
        'Weather Alert',
      );
      await tester.enterText(
        find.byType(TextField).at(1),
        'Storm warning',
      );
      await tester.enterText(
        find.byType(TextField).at(2),
        'Are you safe indoors?',
      );
      await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
      await tester.pumpAndSettle();
      final all = await db.reminderTemplatesDao.getAll();
      check(all).isNotEmpty();
      final saved = all.first;
      check(saved.name).equals('Weather Alert');
      check(saved.title).equals('Storm warning');
      check(saved.body).equals('Are you safe indoors?');
    });

    testWidgets('save trims whitespace from name, title and body', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpWithRouter(tester, overrides: baseOverrides);
      await tester.enterText(find.byType(TextField).at(0), '  Delivery  ');
      await tester.enterText(find.byType(TextField).at(1), ' Package arrived ');
      await tester.enterText(
        find.byType(TextField).at(2),
        ' Confirm you collected it. ',
      );
      await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
      await tester.pumpAndSettle();
      final all = await db.reminderTemplatesDao.getAll();
      check(all).isNotEmpty();
      final saved = all.first;
      check(saved.name).equals('Delivery');
      check(saved.title).equals('Package arrived');
      check(saved.body).equals('Confirm you collected it.');
    });

    testWidgets('save persists selected confirmationType', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpWithRouter(tester, overrides: baseOverrides);
      await tester.enterText(find.byType(TextField).at(0), 'Msg');
      await tester.enterText(find.byType(TextField).at(1), 'Hey');
      await tester.enterText(find.byType(TextField).at(2), 'Reply to confirm.');
      // Select 'swipe'.
      await tester.tap(find.text(ConfirmationType.swipe.name));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
      await tester.pumpAndSettle();
      final all = await db.reminderTemplatesDao.getAll();
      check(all).isNotEmpty();
      check(all.first.confirmationType).equals(ConfirmationType.swipe);
    });

    testWidgets('edit-mode save upserts the existing template', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await db.reminderTemplatesDao.upsert(
        _template(name: 'Old name', title: 'Old title', body: 'Old body.'),
      );
      await _pumpWithRouter(
        tester,
        templateId: 't-1',
        overrides: baseOverrides,
      );
      // Clear name field and type new value.
      await tester.tap(find.byType(TextField).at(0));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'New name');
      await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
      await tester.pumpAndSettle();
      final updated = await db.reminderTemplatesDao.getById('t-1');
      check(updated).isNotNull();
      check(updated!.name).equals('New name');
    });

    testWidgets('save pops the screen on success', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pumpWithRouter(tester, overrides: baseOverrides);
      await tester.enterText(find.byType(TextField).at(0), 'Language');
      await tester.enterText(find.byType(TextField).at(1), 'Lesson done');
      await tester.enterText(find.byType(TextField).at(2), 'Are you safe?');
      await tester.tap(find.widgetWithText(TextButton, l10n.commonSave));
      await tester.pumpAndSettle();
      // After pop, TemplateEditorScreen is gone.
      expect(find.byType(TemplateEditorScreen), findsNothing);
    });
  });

  // ---- Group: Cancel pops without saving ----------------------------------

  group('TemplateEditorScreen — cancel', () {
    testWidgets('pressing back (Navigator pop) leaves the screen', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const TemplateEditorScreen(),
        overrides: baseOverrides,
      );
      // Navigate back via the Navigator API (no GoRouter needed to just pop).
      final NavigatorState nav = tester.state(find.byType(Navigator));
      await nav.maybePop();
      await tester.pumpAndSettle();
      // No data persisted.
      final all = await db.reminderTemplatesDao.getAll();
      check(all).isEmpty();
    });
  });

  // ---- Group: RTL smoke ---------------------------------------------------

  group('TemplateEditorScreen — RTL', () {
    testWidgets('renders in Arabic (RTL) without overflow', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const TemplateEditorScreen(),
        overrides: baseOverrides,
        locale: const Locale('ar'),
      );
      expect(find.byType(AppBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // ---- Group: Dark mode smoke --------------------------------------------

  group('TemplateEditorScreen — dark mode', () {
    testWidgets('renders without exception in dark mode', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const TemplateEditorScreen(),
        overrides: baseOverrides,
        themeMode: ThemeMode.dark,
      );
      expect(tester.takeException(), isNull);
    });
  });

  // ---- Group: Accessibility -----------------------------------------------

  group('TemplateEditorScreen — accessibility', () {
    testWidgets('form field labels are visible for screen readers', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await pumpScreen(
        tester,
        const TemplateEditorScreen(),
        overrides: baseOverrides,
      );
      expect(find.text(l10n.templatesNameLabel), findsOneWidget);
      expect(find.text(l10n.templatesTitleLabel), findsOneWidget);
      expect(find.text(l10n.templatesBodyLabel), findsOneWidget);
    });

    testWidgets('no exception on semantic pass-through', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const TemplateEditorScreen(),
        overrides: baseOverrides,
      );
      final SemanticsHandle handle = tester.ensureSemantics();
      expect(tester.takeException(), isNull);
      handle.dispose();
    });

    testWidgets('radio tiles expose text labels for screen readers', (
      WidgetTester tester,
    ) async {
      await pumpScreen(
        tester,
        const TemplateEditorScreen(),
        overrides: baseOverrides,
      );
      // Each ConfirmationType value appears as a label.
      for (final ct in ConfirmationType.values) {
        expect(find.text(ct.name), findsOneWidget);
      }
      for (final ds in ReminderDisplayStyle.values) {
        expect(find.text(ds.name), findsOneWidget);
      }
    });
  });
}
