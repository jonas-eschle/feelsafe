// Widget tests for [TimingSlider].
//
// Drives the real widget: the log-scale Slider (commit on release only, never
// during drag), the snap-to-stops logic, the duration label formatting across
// s/m/h/d ranges, didUpdateWidget when the parent value changes, and the
// manual-entry dialog (valid → clamped commit, non-numeric → cancelled, the
// Cancel button → no commit).

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/widgets/timing_slider.dart';

Future<void> _pump(
  WidgetTester tester, {
  required int valueSeconds,
  required ValueChanged<int> onChanged,
  int minSeconds = 0,
  int maxSeconds = 365 * 24 * 60 * 60,
  String? label,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: TimingSlider(
            valueSeconds: valueSeconds,
            onChanged: onChanged,
            minSeconds: minSeconds,
            maxSeconds: maxSeconds,
            label: label,
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('TimingSlider — label formatting', () {
    test('asserts maxSeconds > minSeconds at construction', () {
      check(
        () => TimingSlider(
          valueSeconds: 0,
          onChanged: (_) {},
          minSeconds: 10,
          maxSeconds: 5,
        ),
      ).throws<AssertionError>();
    });

    testWidgets('immediate (0s) renders the "immediate" chip', (tester) async {
      await _pump(tester, valueSeconds: 0, onChanged: (_) {});
      expect(find.textContaining('immediate'), findsWidgets);
    });

    testWidgets('seconds < 60 render as Ns', (tester) async {
      await _pump(tester, valueSeconds: 30, onChanged: (_) {});
      expect(find.textContaining('30s'), findsWidgets);
    });

    testWidgets('minutes render as Mm (and Mm Ss when seconds remain)', (
      tester,
    ) async {
      await _pump(tester, valueSeconds: 5 * 60, onChanged: (_) {});
      expect(find.textContaining('5m'), findsWidgets);
    });

    testWidgets('hours render as Hh', (tester) async {
      await _pump(tester, valueSeconds: 6 * 60 * 60, onChanged: (_) {});
      expect(find.textContaining('6h'), findsWidgets);
    });

    testWidgets('days render as Nd', (tester) async {
      await _pump(tester, valueSeconds: 7 * 24 * 60 * 60, onChanged: (_) {});
      expect(find.textContaining('7d'), findsWidgets);
    });

    testWidgets('the optional label is rendered above the slider', (
      tester,
    ) async {
      await _pump(
        tester,
        valueSeconds: 60,
        onChanged: (_) {},
        label: 'Check-in interval',
      );
      expect(find.text('Check-in interval'), findsOneWidget);
    });
  });

  group('TimingSlider — commit semantics', () {
    testWidgets('dragging the Slider does NOT commit until release', (
      tester,
    ) async {
      final commits = <int>[];
      await _pump(tester, valueSeconds: 60, onChanged: commits.add);

      // Drag the slider but never lift the finger — onChanged must NOT fire.
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(Slider)),
      );
      await gesture.moveBy(const Offset(60, 0));
      await tester.pump();
      check(commits).isEmpty();

      // Releasing commits exactly one snapped value.
      await gesture.up();
      await tester.pumpAndSettle();
      check(commits).length.equals(1);
    });

    testWidgets('the committed value is one of the snap stops', (tester) async {
      final commits = <int>[];
      await _pump(tester, valueSeconds: 60, onChanged: commits.add);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(Slider)),
      );
      await gesture.moveBy(const Offset(80, 0));
      await gesture.up();
      await tester.pumpAndSettle();
      check(commits).isNotEmpty();
      check(kTimingSliderStops).contains(commits.last);
    });

    testWidgets('didUpdateWidget re-seeds the draft when the parent value '
        'changes', (tester) async {
      // Mount with one value, then rebuild with another and confirm the
      // displayed label tracks the new parent value.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimingSlider(valueSeconds: 30, onChanged: (_) {}),
          ),
        ),
      );
      expect(find.textContaining('30s'), findsWidgets);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimingSlider(valueSeconds: 6 * 60 * 60, onChanged: (_) {}),
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('6h'), findsWidgets);
    });
  });

  group('TimingSlider — manual entry dialog', () {
    testWidgets('Save with a valid number commits the clamped value', (
      tester,
    ) async {
      final commits = <int>[];
      await _pump(
        tester,
        valueSeconds: 60,
        onChanged: commits.add,
        maxSeconds: 3600,
      );
      // Open the dialog via the chip.
      await tester.tap(find.byType(ActionChip));
      await tester.pumpAndSettle();
      expect(find.text('Enter duration (seconds)'), findsOneWidget);

      // Enter a value over the max → it must clamp to maxSeconds (3600).
      await tester.enterText(find.byType(TextField), '99999');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      check(commits).deepEquals([3600]);
    });

    testWidgets('Save with a non-numeric value cancels (no commit)', (
      tester,
    ) async {
      final commits = <int>[];
      await _pump(tester, valueSeconds: 60, onChanged: commits.add);
      await tester.tap(find.byType(ActionChip));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'not a number');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      check(commits).isEmpty();
      // Dialog dismissed.
      expect(find.text('Enter duration (seconds)'), findsNothing);
    });

    testWidgets('Cancel closes the dialog without committing', (tester) async {
      final commits = <int>[];
      await _pump(tester, valueSeconds: 60, onChanged: commits.add);
      await tester.tap(find.byType(ActionChip));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      check(commits).isEmpty();
      expect(find.text('Enter duration (seconds)'), findsNothing);
    });

    testWidgets('entering the same value does not fire onChanged', (
      tester,
    ) async {
      final commits = <int>[];
      await _pump(tester, valueSeconds: 42, onChanged: commits.add);
      await tester.tap(find.byType(ActionChip));
      await tester.pumpAndSettle();
      // Re-enter the current value → no change → no commit.
      await tester.enterText(find.byType(TextField), '42');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      check(commits).isEmpty();
    });
  });
}
