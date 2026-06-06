/// Widget tests for [ReminderConfirmation] and [ReminderDisguiseContent] —
/// the four disguisedReminder confirmation interactions (spec 02
/// §disguisedReminder Disarm) and the disguise card content.
library;

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/widgets/swipe_slider.dart';
import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/features/disguised_reminder/reminder_confirmation.dart';
import 'package:guardianangela/features/disguised_reminder/reminder_word_choices.dart';
import '../../helpers/widget_test_helpers.dart';

ReminderTemplate _template({
  required ConfirmationType confirmationType,
  String? keyword,
  String? buttonLabel,
  String? subtitle,
  ReminderDisplayStyle displayStyle = ReminderDisplayStyle.subtle,
}) => ReminderTemplate(
  id: 'tmpl',
  name: 'Template',
  title: 'You have an appointment',
  body: 'Meeting with Alex at 3 PM',
  subtitle: subtitle,
  confirmationType: confirmationType,
  keyword: keyword,
  buttonLabel: buttonLabel,
  isCustom: false,
  displayStyle: displayStyle,
  isGlobal: true,
);

Future<void> _pump(WidgetTester tester, Widget child) =>
    pumpScreen(tester, Scaffold(body: Center(child: child)));

void main() {
  group('ReminderConfirmation — tapButton', () {
    testWidgets('renders the template buttonLabel and confirms on tap', (
      tester,
    ) async {
      var confirmed = 0;
      await _pump(
        tester,
        ReminderConfirmation(
          template: _template(
            confirmationType: ConfirmationType.tapButton,
            buttonLabel: 'Acknowledge',
          ),
          onConfirm: () => confirmed++,
        ),
      );
      expect(find.text('Acknowledge'), findsOneWidget);
      await tester.tap(find.text('Acknowledge'));
      expect(confirmed, 1);
    });

    testWidgets('falls back to the default label when none is set', (
      tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        ReminderConfirmation(
          template: _template(confirmationType: ConfirmationType.tapButton),
          onConfirm: () {},
        ),
      );
      expect(find.text(l10n.sessionReminderDefaultButton), findsOneWidget);
    });
  });

  group('ReminderConfirmation — tapWord', () {
    testWidgets('shows the keyword among the choices', (tester) async {
      await _pump(
        tester,
        ReminderConfirmation(
          template: _template(
            confirmationType: ConfirmationType.tapWord,
            keyword: 'STREAK',
          ),
          onConfirm: () {},
        ),
      );
      expect(find.text('STREAK'), findsOneWidget);
      // Three choices are rendered as buttons.
      expect(find.byType(OutlinedButton), findsNWidgets(3));
    });

    testWidgets('tapping the correct word confirms', (tester) async {
      var confirmed = 0;
      await _pump(
        tester,
        ReminderConfirmation(
          template: _template(
            confirmationType: ConfirmationType.tapWord,
            keyword: 'STREAK',
          ),
          onConfirm: () => confirmed++,
        ),
      );
      await tester.tap(find.text('STREAK'));
      expect(confirmed, 1);
    });

    testWidgets('tapping a decoy word does NOT confirm', (tester) async {
      var confirmed = 0;
      const keyword = 'STREAK';
      final decoy = buildReminderWordChoices(
        keyword,
      ).firstWhere((w) => w != keyword);
      await _pump(
        tester,
        ReminderConfirmation(
          template: _template(
            confirmationType: ConfirmationType.tapWord,
            keyword: keyword,
          ),
          onConfirm: () => confirmed++,
        ),
      );
      await tester.tap(find.text(decoy));
      expect(confirmed, 0);
    });
  });

  group('ReminderConfirmation — swipe', () {
    testWidgets('renders a SwipeSlider with the swipe label', (tester) async {
      final l10n = await loadL10n(const Locale('en'));
      await _pump(
        tester,
        ReminderConfirmation(
          template: _template(confirmationType: ConfirmationType.swipe),
          onConfirm: () {},
        ),
      );
      expect(find.byType(SwipeSlider), findsOneWidget);
      expect(find.text(l10n.sessionReminderSwipeLabel), findsOneWidget);
    });
  });

  group('ReminderConfirmation — dismiss', () {
    testWidgets('renders the dismiss button and confirms on tap', (
      tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      var confirmed = 0;
      await _pump(
        tester,
        ReminderConfirmation(
          template: _template(confirmationType: ConfirmationType.dismiss),
          onConfirm: () => confirmed++,
        ),
      );
      expect(find.text(l10n.sessionReminderDismissLabel), findsOneWidget);
      await tester.tap(find.text(l10n.sessionReminderDismissLabel));
      expect(confirmed, 1);
    });
  });

  group('ReminderDisguiseContent', () {
    testWidgets('renders title, body, and the confirmation', (tester) async {
      await _pump(
        tester,
        ReminderDisguiseContent(
          template: _template(
            confirmationType: ConfirmationType.tapButton,
            buttonLabel: 'View',
          ),
          onConfirm: () {},
        ),
      );
      expect(find.text('You have an appointment'), findsOneWidget);
      expect(find.text('Meeting with Alex at 3 PM'), findsOneWidget);
      expect(find.text('View'), findsOneWidget);
    });

    testWidgets('renders the optional subtitle when present', (tester) async {
      await _pump(
        tester,
        ReminderDisguiseContent(
          template: _template(
            confirmationType: ConfirmationType.dismiss,
            subtitle: 'Tomorrow, 9:00 AM',
          ),
          onConfirm: () {},
        ),
      );
      expect(find.text('Tomorrow, 9:00 AM'), findsOneWidget);
    });
  });
}
