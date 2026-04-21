/// Tests for [StepTypePicker] bottom-sheet + [stepTypeLabel].
///
/// Covers: all 9 step types render a ListTile, the picker pops the
/// selected enum back via `Navigator.pop`, and the label helper is
/// total for every [ChainStepType].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/features/modes/widgets/step_type_picker.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

Widget _appWithPicker({
  void Function(ChainStepType?)? onResolved,
}) => MaterialApp(
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Builder(
    builder: (context) => Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final result = await showStepTypePicker(context);
            onResolved?.call(result);
          },
          child: const Text('open'),
        ),
      ),
    ),
  ),
);

Future<void> _openPicker(WidgetTester tester) async {
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('stepTypeLabel returns a non-empty string for every step type',
      (tester) async {
    await tester.pumpWidget(_appWithPicker());
    await tester.pumpAndSettle();
    final context = tester.element(find.text('open'));
    for (final type in ChainStepType.values) {
      check(stepTypeLabel(context, type)).isNotEmpty();
    }
  });

  testWidgets('showStepTypePicker renders a list of ListTile rows',
      (tester) async {
    ChainStepType? chosen;
    await tester.pumpWidget(
      _appWithPicker(onResolved: (r) => chosen = r),
    );
    await tester.pumpAndSettle();
    await _openPicker(tester);
    // The sheet ListView lazily builds rows as the viewport scrolls.
    // We only need to verify that it produced at least one ListTile
    // (i.e. the sheet opened and ran its builder).
    check(find.byType(ListTile).evaluate().length).isGreaterOrEqual(1);
    // Dismiss by tapping outside the sheet.
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    check(chosen).isNull();
  });

  testWidgets('tapping hold-button tile pops the picker with holdButton',
      (tester) async {
    ChainStepType? chosen;
    await tester.pumpWidget(_appWithPicker(onResolved: (r) => chosen = r));
    await tester.pumpAndSettle();
    await _openPicker(tester);
    await tester.tap(find.byIcon(Icons.touch_app));
    await tester.pumpAndSettle();
    check(chosen).equals(ChainStepType.holdButton);
  });

  testWidgets('tapping loudAlarm row pops the picker with loudAlarm',
      (tester) async {
    ChainStepType? chosen;
    await tester.pumpWidget(_appWithPicker(onResolved: (r) => chosen = r));
    await tester.pumpAndSettle();
    await _openPicker(tester);
    // loudAlarm sits near the bottom of the list — scroll the sheet
    // list until the icon is in the hit-testable viewport.
    await tester.scrollUntilVisible(
      find.byIcon(Icons.alarm),
      60,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.alarm));
    await tester.pumpAndSettle();
    check(chosen).equals(ChainStepType.loudAlarm);
  });

  testWidgets('picker lists all 9 step-type icons', (tester) async {
    ChainStepType? chosen;
    await tester.pumpWidget(_appWithPicker(onResolved: (r) => chosen = r));
    await tester.pumpAndSettle();
    await _openPicker(tester);
    // Scroll from top-to-bottom assert each icon can be brought into
    // view. scrollUntilVisible no-ops if the icon is already in the
    // viewport, so this works whether the list is lazily building.
    const expected = [
      Icons.touch_app,
      Icons.notifications,
      Icons.timer,
      Icons.call,
      Icons.sms,
      Icons.phone_forwarded,
      Icons.alarm,
      Icons.emergency,
      Icons.power_settings_new,
    ];
    final scrollable = find.byType(Scrollable).last;
    for (final icon in expected) {
      await tester.scrollUntilVisible(find.byIcon(icon), 60,
          scrollable: scrollable);
      await tester.pumpAndSettle();
      check(find.byIcon(icon).evaluate().length).isGreaterOrEqual(1);
    }
    // Pick any row so the future resolves.
    await tester.scrollUntilVisible(
      find.byIcon(Icons.touch_app),
      -60,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.touch_app));
    await tester.pumpAndSettle();
    check(chosen).equals(ChainStepType.holdButton);
  });
}
