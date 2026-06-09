/// Widget tests for [StealthConfigFields]: each control must emit an updated
/// [StealthConfig] with only the edited field replaced (spec 04 §Mode —
/// Safety Options §Stealth).
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/enums/stealth_icon_preset.dart';
import 'package:guardianangela/domain/enums/stealth_timer_display.dart';
import 'package:guardianangela/domain/models/stealth_config.dart';
import 'package:guardianangela/features/modes/widgets/stealth_config_fields.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';
import '../../../helpers/widget_test_helpers.dart';

Future<void> _pump(
  WidgetTester tester,
  StealthConfig config, {
  required ValueChanged<StealthConfig> onChanged,
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
          child: StealthConfigFields(config: config, onChanged: onChanged),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _toggle(WidgetTester tester, String title) async {
  final Finder tile = find.widgetWithText(SwitchListTile, title);
  await tester.ensureVisible(tile);
  await tester.tap(tile);
  await tester.pumpAndSettle();
}

void main() {
  group('StealthConfigFields — fake name', () {
    testWidgets('committing a new fake name emits it', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      StealthConfig? emitted;
      await _pump(
        tester,
        const StealthConfig(),
        onChanged: (StealthConfig c) => emitted = c,
      );

      final Finder field = find.widgetWithText(
        TextField,
        l10n.stealthFakeNameLabel,
      );
      await tester.enterText(field, 'Tunes');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      check(emitted).isNotNull();
      check(emitted!.fakeName).equals('Tunes');
    });

    testWidgets('committing an empty fake name falls back to "Music"', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      StealthConfig? emitted;
      await _pump(
        tester,
        const StealthConfig(fakeName: 'Tunes'),
        onChanged: (StealthConfig c) => emitted = c,
      );

      final Finder field = find.widgetWithText(
        TextField,
        l10n.stealthFakeNameLabel,
      );
      await tester.enterText(field, '');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      check(emitted).isNotNull();
      check(emitted!.fakeName).equals('Music');
    });
  });

  group('StealthConfigFields — fake icon dropdown', () {
    testWidgets('selecting Calendar emits fakeIcon: calendar', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      StealthConfig? emitted;
      // fakeName 'Player' so the name field's text cannot collide with the
      // dropdown's current "Music" preset label.
      await _pump(
        tester,
        const StealthConfig(fakeName: 'Player'),
        onChanged: (StealthConfig c) => emitted = c,
      );

      await tester.tap(find.text(l10n.stealthPresetMusic));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.stealthPresetCalendar).last);
      await tester.pumpAndSettle();

      check(emitted).isNotNull();
      check(emitted!.fakeIcon).equals(StealthIconPreset.calendar);
    });
  });

  group('StealthConfigFields — switches', () {
    testWidgets('toggling notification disguise emits the new value', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      StealthConfig? emitted;
      await _pump(
        tester,
        const StealthConfig(),
        onChanged: (StealthConfig c) => emitted = c,
      );

      await _toggle(tester, l10n.stealthNotificationDisguiseLabel);

      check(emitted).isNotNull();
      check(emitted!.notificationDisguise).isFalse();
    });

    testWidgets('toggling session-screen stealth emits the new value', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      StealthConfig? emitted;
      await _pump(
        tester,
        const StealthConfig(),
        onChanged: (StealthConfig c) => emitted = c,
      );

      await _toggle(tester, l10n.stealthSessionScreenLabel);

      check(emitted).isNotNull();
      check(emitted!.sessionScreenStealth).isFalse();
    });

    testWidgets('toggling lock-task mode emits the new value', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      StealthConfig? emitted;
      await _pump(
        tester,
        const StealthConfig(),
        onChanged: (StealthConfig c) => emitted = c,
      );

      await _toggle(tester, l10n.stealthLockTaskLabel);

      check(emitted).isNotNull();
      check(emitted!.lockTaskMode).isTrue();
    });
  });

  group('StealthConfigFields — timer display dropdown', () {
    testWidgets('selecting Small emits timerDisplay: small', (
      WidgetTester tester,
    ) async {
      final l10n = await loadL10n(const Locale('en'));
      StealthConfig? emitted;
      await _pump(
        tester,
        const StealthConfig(),
        onChanged: (StealthConfig c) => emitted = c,
      );

      final Finder current = find.text(l10n.stealthTimerDisplayNormal);
      await tester.ensureVisible(current);
      await tester.tap(current);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.stealthTimerDisplaySmall).last);
      await tester.pumpAndSettle();

      check(emitted).isNotNull();
      check(emitted!.timerDisplay).equals(StealthTimerDisplay.small);
    });
  });
}
