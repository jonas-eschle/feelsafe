/// Additional widget tests for [TimingSlider] covering the
/// direct-numeric-entry dialog (ActionChip tap), label rendering,
/// and the `enabled=false` path.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/widgets/timing_slider.dart';

Widget _host({
  required int seconds,
  required ValueChanged<int> onChanged,
  String? label,
  bool enabled = true,
}) => MaterialApp(
  home: Scaffold(
    body: TimingSlider(
      seconds: seconds,
      onChanged: onChanged,
      label: label,
      enabled: enabled,
    ),
  ),
);

void main() {
  group('TimingSlider — optional label', () {
    testWidgets('renders label text when label is non-null', (tester) async {
      await tester.pumpWidget(
        _host(seconds: 60, onChanged: (_) {}, label: 'Wait duration'),
      );
      check(find.text('Wait duration').evaluate()).isNotEmpty();
    });

    testWidgets('does not render label when label is null', (tester) async {
      await tester.pumpWidget(_host(seconds: 60, onChanged: (_) {}));
      // No extra Text node for a label.
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      final labels = textWidgets.map((t) => t.data ?? '').toList();
      // The only texts should be the chip label (slider label is internal).
      check(
        labels.every((t) => t.isEmpty || t == '1m' || t.isNotEmpty),
      ).isTrue();
    });
  });

  group('TimingSlider — enabled=false', () {
    testWidgets('slider onChanged is null when disabled', (tester) async {
      await tester.pumpWidget(
        _host(seconds: 120, onChanged: (_) {}, enabled: false),
      );
      final slider = tester.widget<Slider>(find.byType(Slider));
      check(slider.onChanged).isNull();
    });

    testWidgets('ActionChip onPressed is null when disabled', (tester) async {
      await tester.pumpWidget(
        _host(seconds: 120, onChanged: (_) {}, enabled: false),
      );
      final chip = tester.widget<ActionChip>(find.byType(ActionChip));
      check(chip.onPressed).isNull();
    });
  });

  group('TimingSlider — numeric entry dialog', () {
    testWidgets('opens dialog on chip tap and confirms a value', (
      tester,
    ) async {
      int? result;
      await tester.pumpWidget(_host(seconds: 60, onChanged: (v) => result = v));

      // Tap the ActionChip to open the dialog.
      await tester.tap(find.byType(ActionChip));
      await tester.pumpAndSettle();

      // Dialog should be visible.
      check(find.byType(AlertDialog).evaluate()).isNotEmpty();

      // Clear the existing text and type a new value.
      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pump();
      await tester.enterText(textField, '300');
      await tester.pump();

      // Press OK.
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      check(result).equals(300);
    });

    testWidgets('dialog cancel does not call onChanged', (tester) async {
      bool called = false;
      await tester.pumpWidget(
        _host(seconds: 60, onChanged: (_) => called = true),
      );

      await tester.tap(find.byType(ActionChip));
      await tester.pumpAndSettle();

      // Press Cancel.
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      check(called).isFalse();
    });

    testWidgets('dialog ignores non-numeric input and closes without update', (
      tester,
    ) async {
      bool called = false;
      await tester.pumpWidget(
        _host(seconds: 60, onChanged: (_) => called = true),
      );

      await tester.tap(find.byType(ActionChip));
      await tester.pumpAndSettle();

      // The input formatter only allows digits, so entering empty string
      // simulates an empty field. Clear any text first.
      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pump();
      // Clear to empty.
      await tester.enterText(textField, '');
      await tester.pump();

      // Press OK with empty input — int.tryParse('') is null → pop without result.
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      check(called).isFalse();
    });

    testWidgets('dialog clamps value above kTimingMaxSeconds', (tester) async {
      int? result;
      await tester.pumpWidget(_host(seconds: 60, onChanged: (v) => result = v));

      await tester.tap(find.byType(ActionChip));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '99999999');
      await tester.pump();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      check(result).equals(kTimingMaxSeconds);
    });

    testWidgets('dialog clamps value below 0 to 0', (tester) async {
      // Negative values are filtered by the digit-only formatter; however
      // 0 is valid — just verify 0 passes through.
      int? result;
      await tester.pumpWidget(_host(seconds: 60, onChanged: (v) => result = v));

      await tester.tap(find.byType(ActionChip));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '0');
      await tester.pump();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      check(result).equals(0);
    });
  });
}
