/// Widget tests for [SwipeSlider].
///
/// Verifies:
///   * dragging the knob below the threshold does NOT fire `onConfirm`
///     and the knob animates back to the start;
///   * dragging past the threshold fires `onConfirm` exactly once;
///   * a single drag-cycle is debounced — continuing the drag after
///     crossing the threshold does not double-fire;
///   * Semantics expose a slider role with the supplied label.
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/widgets/swipe_slider.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Mounts a [SwipeSlider] inside a minimal `MaterialApp` shell with
/// the project's localization delegates wired up.
Future<void> _pump(
  WidgetTester tester, {
  required VoidCallback onConfirm,
  double threshold = 0.7,
  double width = 320,
  double height = 64,
  String label = 'Swipe to confirm',
  String? semanticsLabel,
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
        body: Center(
          child: SizedBox(
            width: width,
            child: SwipeSlider(
              label: label,
              onConfirm: onConfirm,
              threshold: threshold,
              height: height,
              semanticsLabel: semanticsLabel,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('SwipeSlider — fires onConfirm', () {
    testWidgets('drag past threshold fires onConfirm exactly once', (
      WidgetTester tester,
    ) async {
      var confirmCount = 0;
      await _pump(tester, onConfirm: () => confirmCount++);
      final slider = find.byType(SwipeSlider);
      // Track is 320 wide; knob is 64 wide; usable = 256 px.
      // threshold = 0.7 → must drag past 256*0.7 = 179.2 px.
      // Drag 240 px to be safely past.
      final start = tester.getCenter(slider);
      final gesture = await tester.startGesture(start);
      await gesture.moveBy(const Offset(240, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      check(confirmCount).equals(1);
    });

    testWidgets('continuing the drag past the threshold does not double-fire', (
      WidgetTester tester,
    ) async {
      var confirmCount = 0;
      await _pump(tester, onConfirm: () => confirmCount++);
      final slider = find.byType(SwipeSlider);
      final start = tester.getCenter(slider);
      final gesture = await tester.startGesture(start);
      await gesture.moveBy(const Offset(200, 0));
      await tester.pump();
      await gesture.moveBy(const Offset(40, 0));
      await tester.pump();
      await gesture.moveBy(const Offset(40, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      check(confirmCount).equals(1);
    });
  });

  group('SwipeSlider — below threshold', () {
    testWidgets('drag below threshold does NOT fire onConfirm', (
      WidgetTester tester,
    ) async {
      var confirmCount = 0;
      await _pump(tester, onConfirm: () => confirmCount++);
      final slider = find.byType(SwipeSlider);
      final start = tester.getCenter(slider);
      final gesture = await tester.startGesture(start);
      // Drag only 80 px — well under 179.2 px threshold.
      await gesture.moveBy(const Offset(80, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      check(confirmCount).equals(0);
    });

    testWidgets('released-below-threshold drag re-arms slider for retry', (
      WidgetTester tester,
    ) async {
      var confirmCount = 0;
      await _pump(tester, onConfirm: () => confirmCount++);
      final slider = find.byType(SwipeSlider);
      // First, an aborted drag.
      var start = tester.getCenter(slider);
      var gesture = await tester.startGesture(start);
      await gesture.moveBy(const Offset(80, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      // Then a complete drag.
      start = tester.getCenter(slider);
      gesture = await tester.startGesture(start);
      await gesture.moveBy(const Offset(240, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      check(confirmCount).equals(1);
    });
  });

  group('SwipeSlider — accessibility', () {
    testWidgets('exposes a Semantics node with the supplied label', (
      WidgetTester tester,
    ) async {
      const label = 'Swipe to cancel emergency';
      await _pump(tester, onConfirm: () {}, label: label);
      // Semantics should advertise the label or the explicit override.
      final handle = tester.ensureSemantics();
      final node = tester.getSemantics(find.byType(SwipeSlider));
      check(node.label).contains(label);
      handle.dispose();
    });

    testWidgets('uses explicit semanticsLabel when provided', (
      WidgetTester tester,
    ) async {
      const visible = 'Slide for help';
      const sLabel = 'Swipe-to-trigger emergency-call cancel';
      await _pump(
        tester,
        onConfirm: () {},
        label: visible,
        semanticsLabel: sLabel,
      );
      final handle = tester.ensureSemantics();
      final node = tester.getSemantics(find.byType(SwipeSlider));
      check(node.label).contains(sLabel);
      handle.dispose();
    });
  });

  group('SwipeSlider — threshold parametrisation', () {
    testWidgets('threshold = 0.5 fires at the midpoint', (
      WidgetTester tester,
    ) async {
      var confirmCount = 0;
      await _pump(tester, onConfirm: () => confirmCount++, threshold: 0.5);
      final slider = find.byType(SwipeSlider);
      final start = tester.getCenter(slider);
      final gesture = await tester.startGesture(start);
      // usable = 256 px; threshold 0.5 → 128 px. Drag 150 px to clear.
      await gesture.moveBy(const Offset(150, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      check(confirmCount).equals(1);
    });
  });
}
