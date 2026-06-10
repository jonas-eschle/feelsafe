/// Widget tests for [StepConfigPanel]'s timing / retry / randomize editors
/// (spec 04 §Step Expansion): each field change must emit an updated
/// [ChainStep] via `onChanged` with only that field replaced.
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/features/modes/widgets/step_config_panel.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import '../../../helpers/widget_test_helpers.dart';

ChainStep _step({int retryCount = 0, bool randomize = false}) => ChainStep(
  id: 's1',
  type: ChainStepType.holdButton,
  order: 0,
  waitSeconds: 5,
  durationSeconds: 30,
  gracePeriodSeconds: 10,
  retryCount: retryCount,
  randomize: randomize,
);

Future<void> _pump(
  WidgetTester tester,
  ChainStep step, {
  required ValueChanged<ChainStep> onChanged,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: StepConfigPanel(
            step: step,
            defaultConfig: const HoldButtonConfig(),
            onChanged: onChanged,
            onDuplicate: () {},
            onReset: () {},
            onDelete: () {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Commits [text] into the timing field labelled [label].
Future<void> _commitText(WidgetTester tester, String label, String text) async {
  final Finder field = find.widgetWithText(TextField, label);
  await tester.ensureVisible(field);
  await tester.enterText(field, text);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
}

/// Expands the initially-collapsed "Retry & advanced" subsection.
Future<void> _openAdvanced(WidgetTester tester, AppLocalizations l10n) async {
  final Finder header = find.text(l10n.stepConfigAdvancedHeader);
  await tester.ensureVisible(header);
  await tester.tap(header);
  await tester.pumpAndSettle();
}

void main() {
  group('StepConfigPanel — timing fields', () {
    testWidgets('committing a new active duration emits the updated step', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      ChainStep? emitted;
      await _pump(tester, _step(), onChanged: (ChainStep s) => emitted = s);

      await _commitText(tester, l10n.stepFieldDuration, '45');

      check(emitted).isNotNull();
      check(emitted!.durationSeconds).equals(45);
      // Only the duration changed.
      check(emitted!.waitSeconds).equals(5);
      check(emitted!.gracePeriodSeconds).equals(10);
    });

    testWidgets('committing a new grace period emits the updated step', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      ChainStep? emitted;
      await _pump(tester, _step(), onChanged: (ChainStep s) => emitted = s);

      await _commitText(tester, l10n.stepFieldGrace, '20');

      check(emitted).isNotNull();
      check(emitted!.gracePeriodSeconds).equals(20);
      check(emitted!.durationSeconds).equals(30);
    });
  });

  group('StepConfigPanel — retry & advanced', () {
    testWidgets('incrementing the retry spinner emits retryCount + 1', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      ChainStep? emitted;
      await _pump(
        tester,
        _step(retryCount: 2),
        onChanged: (ChainStep s) => emitted = s,
      );
      await _openAdvanced(tester, l10n);

      final Finder plus = find.byIcon(Icons.add_circle_outline);
      await tester.ensureVisible(plus);
      await tester.tap(plus);
      await tester.pumpAndSettle();

      check(emitted).isNotNull();
      check(emitted!.retryCount).equals(3);
    });

    testWidgets('toggling Randomise timing emits randomize: true', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      ChainStep? emitted;
      await _pump(tester, _step(), onChanged: (ChainStep s) => emitted = s);
      await _openAdvanced(tester, l10n);

      final Finder toggle = find.widgetWithText(
        SwitchListTile,
        l10n.stepFieldRandomize,
      );
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();

      check(emitted).isNotNull();
      check(emitted!.randomize).isTrue();
    });
  });

  group('StepConfigPanel — manage-templates link (spec 04:1635)', () {
    testWidgets(
      'a disguisedReminder step forwards onManageTemplates to its form',
      (WidgetTester tester) async {
        final l10n = await loadL10n(const Locale('en'));
        var tapped = 0;
        final ChainStep step = ChainStep(
          id: 's1',
          type: ChainStepType.disguisedReminder,
          order: 0,
          waitSeconds: 5,
          durationSeconds: 30,
          gracePeriodSeconds: 10,
          retryCount: 0,
          randomize: false,
        );
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const <LocalizationsDelegate<Object>>[
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: StepConfigPanel(
                  step: step,
                  defaultConfig: const DisguisedReminderConfig(),
                  onChanged: (_) {},
                  onDuplicate: () {},
                  onReset: () {},
                  onDelete: () {},
                  onManageTemplates: () => tapped++,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final Finder link = find.widgetWithText(
          ListTile,
          l10n.safetyOptionsManageTemplates,
        );
        expect(link, findsOneWidget);
        await tester.ensureVisible(link);
        await tester.tap(link);
        check(tapped).equals(1);
      },
    );
  });
}
