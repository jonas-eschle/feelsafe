import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safewayhome/data/models/reminder_template.dart';
import 'package:safewayhome/features/session/widgets/disguised_reminder_overlay.dart';

Widget _wrapWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  group('DisguisedReminderOverlay', () {
    group('tapButton confirmation', () {
      testWidgets('shows button label and confirms on tap', (tester) async {
        bool confirmed = false;

        final template = ReminderTemplate(
          id: 'test_calendar',
          name: 'Calendar Event',
          title: 'Calendar',
          body: 'Team standup in 15 min',
          confirmationType: ConfirmationType.tapButton,
          buttonLabel: 'Dismiss',
        );

        await tester.pumpWidget(_wrapWidget(
          DisguisedReminderOverlay(
            template: template,
            onConfirmed: () => confirmed = true,
          ),
        ));

        // Verify template content is displayed
        expect(find.text('Calendar'), findsOneWidget);
        expect(find.text('Team standup in 15 min'), findsOneWidget);
        expect(find.text('Dismiss'), findsOneWidget);

        // Tap the button
        await tester.tap(find.text('Dismiss'));
        await tester.pump();

        expect(confirmed, isTrue);
      });

      testWidgets('defaults to "OK" when buttonLabel is null', (tester) async {
        final template = ReminderTemplate(
          id: 'test_no_label',
          name: 'Test',
          title: 'Test',
          body: 'Body',
          confirmationType: ConfirmationType.tapButton,
        );

        await tester.pumpWidget(_wrapWidget(
          DisguisedReminderOverlay(
            template: template,
            onConfirmed: () {},
          ),
        ));

        expect(find.text('OK'), findsOneWidget);
      });
    });

    group('tapWord confirmation', () {
      testWidgets('shows 3 word options including the keyword', (tester) async {
        final template = ReminderTemplate(
          id: 'test_duolingo',
          name: 'Language Lesson',
          title: 'Duolingo',
          body: "Don't lose your streak! Translate:",
          confirmationType: ConfirmationType.tapWord,
          keyword: 'house',
        );

        await tester.pumpWidget(_wrapWidget(
          DisguisedReminderOverlay(
            template: template,
            onConfirmed: () {},
          ),
        ));

        // Verify the keyword is shown
        expect(find.text('house'), findsOneWidget);

        // There should be exactly 3 OutlinedButton widgets
        expect(find.byType(OutlinedButton), findsNWidgets(3));
      });

      testWidgets('tapping correct keyword confirms', (tester) async {
        bool confirmed = false;

        final template = ReminderTemplate(
          id: 'test_duolingo',
          name: 'Language Lesson',
          title: 'Duolingo',
          body: 'Translate:',
          confirmationType: ConfirmationType.tapWord,
          keyword: 'house',
        );

        await tester.pumpWidget(_wrapWidget(
          DisguisedReminderOverlay(
            template: template,
            onConfirmed: () => confirmed = true,
          ),
        ));

        // Tap the correct keyword
        await tester.tap(find.text('house'));
        await tester.pump();

        expect(confirmed, isTrue);
      });

      testWidgets('tapping wrong word does not confirm', (tester) async {
        bool confirmed = false;
        bool wrongTapped = false;

        final template = ReminderTemplate(
          id: 'test_duolingo',
          name: 'Language Lesson',
          title: 'Duolingo',
          body: 'Translate:',
          confirmationType: ConfirmationType.tapWord,
          keyword: 'house',
        );

        await tester.pumpWidget(_wrapWidget(
          DisguisedReminderOverlay(
            template: template,
            onConfirmed: () => confirmed = true,
            onDismissedWrong: () => wrongTapped = true,
          ),
        ));

        // Find a button that is NOT the keyword
        final buttons = find.byType(OutlinedButton);
        for (var i = 0; i < 3; i++) {
          final button = buttons.at(i);
          final textFinder = find.descendant(
            of: button,
            matching: find.text('house'),
          );
          if (textFinder.evaluate().isEmpty) {
            // This is a wrong word
            await tester.tap(button);
            await tester.pump();
            break;
          }
        }

        expect(confirmed, isFalse);
        expect(wrongTapped, isTrue);
      });
    });

    group('swipe confirmation', () {
      testWidgets('shows swipe hint and confirms on swipe', (tester) async {
        bool confirmed = false;

        final template = ReminderTemplate(
          id: 'test_delivery',
          name: 'Delivery Update',
          title: 'Delivery',
          body: 'Your package is out for delivery',
          confirmationType: ConfirmationType.swipe,
        );

        await tester.pumpWidget(_wrapWidget(
          DisguisedReminderOverlay(
            template: template,
            onConfirmed: () => confirmed = true,
          ),
        ));

        // Verify swipe hint is shown
        expect(find.text('Swipe to dismiss'), findsOneWidget);

        // Find the Dismissible and swipe it
        final card = find.byType(Dismissible);
        expect(card, findsOneWidget);

        // Swipe right to dismiss
        await tester.drag(card, const Offset(500, 0));
        await tester.pumpAndSettle();

        expect(confirmed, isTrue);
      });
    });

    group('dismiss confirmation', () {
      testWidgets('confirms on tap anywhere on card', (tester) async {
        bool confirmed = false;

        final template = ReminderTemplate(
          id: 'test_dismiss',
          name: 'Battery Warning',
          title: 'System',
          body: 'Battery optimization active',
          confirmationType: ConfirmationType.dismiss,
        );

        await tester.pumpWidget(_wrapWidget(
          DisguisedReminderOverlay(
            template: template,
            onConfirmed: () => confirmed = true,
          ),
        ));

        // Verify dismiss hint is shown
        expect(find.text('Tap to dismiss'), findsOneWidget);

        // Tap the card
        await tester.tap(find.text('Battery optimization active'));
        await tester.pump();

        expect(confirmed, isTrue);
      });
    });

    group('template rendering', () {
      testWidgets('renders all 8 default template types', (tester) async {
        final templates = [
          ReminderTemplate(
            id: 'tpl_calendar',
            name: 'Calendar Event',
            title: 'Calendar',
            body: 'Team standup in 15 min',
            confirmationType: ConfirmationType.tapButton,
            buttonLabel: 'Dismiss',
          ),
          ReminderTemplate(
            id: 'tpl_duolingo',
            name: 'Language Lesson',
            title: 'Duolingo',
            body: "Don't lose your streak! Translate:",
            confirmationType: ConfirmationType.tapWord,
            keyword: 'house',
          ),
          ReminderTemplate(
            id: 'tpl_delivery',
            name: 'Delivery Update',
            title: 'Delivery',
            body: 'Your package is out for delivery',
            confirmationType: ConfirmationType.swipe,
          ),
          ReminderTemplate(
            id: 'tpl_weather',
            name: 'Weather Alert',
            title: 'Weather',
            body: 'Rain expected at 10 PM',
            confirmationType: ConfirmationType.tapButton,
            buttonLabel: 'OK',
          ),
          ReminderTemplate(
            id: 'tpl_fitness',
            name: 'Fitness Reminder',
            title: 'Fitness',
            body: 'Time for your evening walk!',
            confirmationType: ConfirmationType.tapButton,
            buttonLabel: 'Skip',
          ),
          ReminderTemplate(
            id: 'tpl_message',
            name: 'Message Preview',
            title: 'Mom',
            body: 'Are you coming home for dinner?',
            confirmationType: ConfirmationType.tapButton,
            buttonLabel: 'Reply',
          ),
          ReminderTemplate(
            id: 'tpl_app_update',
            name: 'App Update',
            title: 'SafeWayHome',
            body: 'Update available',
            confirmationType: ConfirmationType.tapButton,
            buttonLabel: 'Later',
          ),
          ReminderTemplate(
            id: 'tpl_battery',
            name: 'Battery Warning',
            title: 'System',
            body: 'Battery optimization active',
            confirmationType: ConfirmationType.swipe,
          ),
        ];

        for (final template in templates) {
          await tester.pumpWidget(_wrapWidget(
            DisguisedReminderOverlay(
              template: template,
              onConfirmed: () {},
            ),
          ));

          // Each template should show its title and body
          expect(find.text(template.title), findsOneWidget,
              reason: 'Template ${template.name} should show title');
          expect(find.text(template.body), findsOneWidget,
              reason: 'Template ${template.name} should show body');
        }
      });
    });
  });
}
