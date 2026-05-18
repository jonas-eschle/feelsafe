/// Semantics audit: verifies that key interactive widgets expose a
/// Semantics label readable by TalkBack / VoiceOver.
///
/// Each test pumps the widget in isolation under a minimal
/// `MaterialApp` and walks the descendant Semantics widgets looking
/// for the expected label (matches the pattern used in
/// `test/core/widgets/hold_to_trigger_button_test.dart`).
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/theme/app_theme.dart';
import 'package:guardianangela/core/widgets/hold_to_trigger_button.dart';
import 'package:guardianangela/core/widgets/im_safe_slider.dart';
import 'package:guardianangela/core/widgets/info_icon_button.dart';
import 'package:guardianangela/core/widgets/pin_keypad.dart';

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: Center(child: child)),
);

bool _hasLabel(WidgetTester tester, Finder scope, String label) {
  final widgets = tester
      .widgetList<Semantics>(
        find.descendant(of: scope, matching: find.byType(Semantics)),
      )
      .toList();
  return widgets.any((s) => s.properties.label == label);
}

void main() {
  group('HoldToTriggerButton', () {
    testWidgets('exposes its semanticLabel', (tester) async {
      await tester.pumpWidget(
        _host(
          HoldToTriggerButton(
            onHoldStart: () {},
            onHoldRelease: () {},
            semanticLabel: 'Hold to stay safe',
          ),
        ),
      );
      check(
        _hasLabel(
          tester,
          find.byType(HoldToTriggerButton),
          'Hold to stay safe',
        ),
      ).isTrue();
    });
  });

  group('ImSafeSlider', () {
    testWidgets('exposes its label', (tester) async {
      await tester.pumpWidget(
        _host(ImSafeSlider(label: "I'm safe", onConfirmed: () {})),
      );
      check(_hasLabel(tester, find.byType(ImSafeSlider), "I'm safe")).isTrue();
    });

    testWidgets('is marked as a slider', (tester) async {
      await tester.pumpWidget(
        _host(ImSafeSlider(label: 'Confirm', onConfirmed: () {})),
      );
      final sems = tester
          .widgetList<Semantics>(
            find.descendant(
              of: find.byType(ImSafeSlider),
              matching: find.byType(Semantics),
            ),
          )
          .toList();
      check(sems.any((s) => s.properties.slider == true)).isTrue();
    });
  });

  group('InfoIconButton', () {
    testWidgets('exposes a help label derived from the title', (tester) async {
      await tester.pumpWidget(
        _host(const InfoIconButton(title: 'Timeout', body: 'Seconds')),
      );
      check(
        _hasLabel(tester, find.byType(InfoIconButton), 'Help: Timeout'),
      ).isTrue();
    });
  });

  group('PinKeypad', () {
    testWidgets('digit keys expose per-digit labels', (tester) async {
      await tester.pumpWidget(
        _host(PinKeypad(onDigit: (_) {}, onBackspace: () {})),
      );
      for (var digit = 0; digit <= 9; digit++) {
        check(
          _hasLabel(tester, find.byType(PinKeypad), 'Digit $digit'),
        ).isTrue();
      }
    });

    testWidgets('backspace key exposes a Backspace label', (tester) async {
      await tester.pumpWidget(
        _host(PinKeypad(onDigit: (_) {}, onBackspace: () {})),
      );
      check(_hasLabel(tester, find.byType(PinKeypad), 'Backspace')).isTrue();
    });

    testWidgets('digit keys are marked as buttons', (tester) async {
      await tester.pumpWidget(
        _host(PinKeypad(onDigit: (_) {}, onBackspace: () {})),
      );
      final sems = tester
          .widgetList<Semantics>(
            find.descendant(
              of: find.byType(PinKeypad),
              matching: find.byType(Semantics),
            ),
          )
          .toList();
      // At least one digit + backspace must be marked as button=true.
      final buttonCount = sems.where((s) => s.properties.button == true).length;
      check(buttonCount).isGreaterOrEqual(10);
    });

    testWidgets('empty slot key has no Semantics label', (tester) async {
      await tester.pumpWidget(
        _host(PinKeypad(onDigit: (_) {}, onBackspace: () {})),
      );
      // Ensure the empty slot doesn't introduce a spurious "Digit "
      // label.
      check(_hasLabel(tester, find.byType(PinKeypad), 'Digit ')).isFalse();
    });
  });
}
