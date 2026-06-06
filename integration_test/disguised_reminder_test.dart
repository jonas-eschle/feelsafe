// M0 / #18 — disguised-reminder confirmation UI renders and works on a real
// device build.
//
// #18 is pure Flutter/Dart wiring (no native playback path like #21's audio),
// so the bulk of its proof lives in host widget/controller/golden tests. This
// device test adds the one thing those cannot: it builds the new reminder UI
// (template disguise + all four ConfirmationType interactions, including the
// SwipeSlider gesture and tapWord grid) through the REAL Android Flutter engine
// — catching any device-only render, font, or layout regression — and proves
// each confirmation actually fires its check-in callback on-device.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:guardianangela/domain/enums/confirmation_type.dart';
import 'package:guardianangela/domain/enums/reminder_display_style.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/features/disguised_reminder/reminder_confirmation.dart';
import 'package:guardianangela/features/disguised_reminder/reminder_word_choices.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  ReminderTemplate template({
    required ConfirmationType confirmationType,
    String? keyword,
    String? buttonLabel,
  }) => ReminderTemplate(
    id: 'tmpl',
    name: 'Calendar Event',
    title: 'You have an appointment',
    body: 'Meeting with Alex at 3 PM',
    confirmationType: confirmationType,
    keyword: keyword,
    buttonLabel: buttonLabel,
    isCustom: false,
    displayStyle: ReminderDisplayStyle.fullScreen,
    isGlobal: true,
  );

  Future<void> pump(
    WidgetTester tester,
    ReminderTemplate t,
    VoidCallback onConfirm,
  ) async {
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
          body: Center(
            child: ReminderDisguiseContent(template: t, onConfirm: onConfirm),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('tapButton disguise renders and confirms on-device', (
    tester,
  ) async {
    var confirmed = 0;
    await pump(
      tester,
      template(
        confirmationType: ConfirmationType.tapButton,
        buttonLabel: 'Acknowledge',
      ),
      () => confirmed++,
    );
    expect(find.text('You have an appointment'), findsOneWidget);
    expect(find.text('Acknowledge'), findsOneWidget);
    await tester.tap(find.text('Acknowledge'));
    await tester.pump();
    expect(confirmed, 1);
  });

  testWidgets('tapWord disguise renders the keyword grid on-device', (
    tester,
  ) async {
    var confirmed = 0;
    await pump(
      tester,
      template(confirmationType: ConfirmationType.tapWord, keyword: 'STREAK'),
      () => confirmed++,
    );
    expect(find.text('STREAK'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNWidgets(3));
    await tester.tap(find.text('STREAK'));
    await tester.pump();
    expect(confirmed, 1);
    // A decoy must not confirm.
    final decoy = buildReminderWordChoices(
      'STREAK',
    ).firstWhere((w) => w != 'STREAK');
    await tester.tap(find.text(decoy));
    await tester.pump();
    expect(confirmed, 1);
  });

  testWidgets('dismiss disguise confirms on-device', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    var confirmed = 0;
    await pump(
      tester,
      template(confirmationType: ConfirmationType.dismiss),
      () => confirmed++,
    );
    await tester.tap(find.text(l10n.sessionReminderDismissLabel));
    await tester.pump();
    expect(confirmed, 1);
  });

  testWidgets('swipe disguise confirms via a full-track drag on-device', (
    tester,
  ) async {
    var confirmed = 0;
    await pump(
      tester,
      template(confirmationType: ConfirmationType.swipe),
      () => confirmed++,
    );
    // Drag the knob across the track (well past the 0.85 threshold).
    await tester.drag(
      find.byIcon(Icons.arrow_forward_rounded),
      const Offset(600, 0),
    );
    await tester.pumpAndSettle();
    expect(confirmed, 1);
  });
}
