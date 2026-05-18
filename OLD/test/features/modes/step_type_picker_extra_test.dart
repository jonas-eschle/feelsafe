/// Supplemental tests for [showStepTypePicker] / [_StepTypePickerSheet]
/// covering the "More options…" expand flow, category filter chips,
/// and the [categoryOf] / [stepCategoryLabel] functions.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/features/modes/widgets/step_type_picker.dart';

import '../widget_test_helpers.dart';

void main() {
  group('categoryOf', () {
    test('holdButton → disarm', () {
      check(categoryOf(ChainStepType.holdButton)).equals(StepCategory.disarm);
    });
    test('hardwareButton → disarm', () {
      check(categoryOf(ChainStepType.hardwareButton))
          .equals(StepCategory.disarm);
    });
    test('disguisedReminder → reminder', () {
      check(categoryOf(ChainStepType.disguisedReminder))
          .equals(StepCategory.reminder);
    });
    test('countdownWarning → reminder', () {
      check(categoryOf(ChainStepType.countdownWarning))
          .equals(StepCategory.reminder);
    });
    test('fakeCall → action', () {
      check(categoryOf(ChainStepType.fakeCall)).equals(StepCategory.action);
    });
    test('smsContact → action', () {
      check(categoryOf(ChainStepType.smsContact)).equals(StepCategory.action);
    });
    test('phoneCallContact → action', () {
      check(categoryOf(ChainStepType.phoneCallContact))
          .equals(StepCategory.action);
    });
    test('loudAlarm → action', () {
      check(categoryOf(ChainStepType.loudAlarm)).equals(StepCategory.action);
    });
    test('callEmergency → action', () {
      check(categoryOf(ChainStepType.callEmergency))
          .equals(StepCategory.action);
    });
  });

  group('showStepTypePicker', () {
    Future<void> openPicker(WidgetTester tester) async {
      await tester.pumpWidget(
        hostScreen(
          child: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                await showStepTypePicker(ctx);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    testWidgets('picker opens and shows Hold button by default',
        (tester) async {
      await openPicker(tester);
      check(find.text('Hold button').evaluate()).isNotEmpty();
    });

    testWidgets('More options… expands to full list', (tester) async {
      await openPicker(tester);
      // Tap "More options…"
      await tester.tap(find.text('More options...'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // After expanding, the ListView should contain all step types.
      // Scroll to ensure items are rendered.
      await tester.dragUntilVisible(
        find.text('Loud alarm'),
        find.byType(ListView).last,
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();
      check(find.text('Loud alarm').evaluate()).isNotEmpty();
    });

    testWidgets('category filter chips appear after More options',
        (tester) async {
      await openPicker(tester);
      await tester.tap(find.text('More options...'));
      await tester.pumpAndSettle();

      // Category filter row — chips rendered.
      check(find.byType(ChoiceChip).evaluate()).isNotEmpty();
    });

    testWidgets('selecting Action filter hides check-in-type steps',
        (tester) async {
      await openPicker(tester);
      await tester.tap(find.text('More options...'));
      await tester.pumpAndSettle();

      // Tap the Action category chip.
      await tester.tap(find.text('Action'));
      await tester.pumpAndSettle();

      // Action steps should be visible.
      check(find.text('SMS contact').evaluate()).isNotEmpty();
      // Hardware button is a Check-in step — should NOT be visible.
      check(find.text('Hardware button').evaluate()).isEmpty();
    });

    testWidgets('tapping an entry in expanded list returns the type',
        (tester) async {
      ChainStepType? result;
      await tester.pumpWidget(
        hostScreen(
          child: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                result = await showStepTypePicker(ctx);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Expand to full list.
      await tester.tap(find.text('More options...'));
      await tester.pumpAndSettle();

      // Pick SMS contact.
      await tester.tap(find.text('SMS contact'));
      await tester.pumpAndSettle();

      check(result).equals(ChainStepType.smsContact);
    });

    testWidgets('Check-in filter shows only hold/hardware button steps',
        (tester) async {
      await openPicker(tester);
      await tester.tap(find.text('More options...'));
      await tester.pumpAndSettle();

      // The l10n label for StepCategory.disarm is "Check-in".
      await tester.tap(find.text('Check-in'));
      await tester.pumpAndSettle();

      check(find.text('Hold button').evaluate()).isNotEmpty();
      check(find.text('Hardware button').evaluate()).isNotEmpty();
      // SMS contact is an Action step.
      check(find.text('SMS contact').evaluate()).isEmpty();
    });

    testWidgets('Reminder filter shows only reminder steps', (tester) async {
      await openPicker(tester);
      await tester.tap(find.text('More options...'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reminder'));
      await tester.pumpAndSettle();

      check(find.text('Disguised reminder').evaluate()).isNotEmpty();
      check(find.text('Countdown warning').evaluate()).isNotEmpty();
      check(find.text('SMS contact').evaluate()).isEmpty();
    });

    testWidgets('All filter (re-selection) shows all entries', (tester) async {
      await openPicker(tester);
      await tester.tap(find.text('More options...'));
      await tester.pumpAndSettle();

      // First select Check-in, then All.
      await tester.tap(find.text('Check-in'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      // All nine types should be visible now.
      check(find.text('Hold button').evaluate()).isNotEmpty();
      check(find.text('SMS contact').evaluate()).isNotEmpty();
    });
  });
}
