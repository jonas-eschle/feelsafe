/// Widget tests for [LogarithmicSlider].
///
/// Drives the underlying [Slider] via drag gestures and asserts the
/// mapped value lands on a log-scale midpoint.
library;

import 'dart:math' as math;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/widgets/logarithmic_slider.dart';

Widget _host({
  required double value,
  required ValueChanged<double> onChanged,
  String? label,
}) => MaterialApp(
  home: Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: LogarithmicSlider(
        minValue: 1,
        maxValue: 1000,
        value: value,
        onChanged: onChanged,
        label: label,
      ),
    ),
  ),
);

void main() {
  testWidgets('renders a Slider', (tester) async {
    await tester.pumpWidget(_host(value: 10, onChanged: (_) {}));
    check(find.byType(Slider).evaluate().length).equals(1);
  });

  testWidgets('does not render label when null', (tester) async {
    await tester.pumpWidget(_host(value: 10, onChanged: (_) {}));
    check(find.text('GPS interval').evaluate()).isEmpty();
  });

  testWidgets('renders provided label above the slider', (tester) async {
    await tester.pumpWidget(
      _host(value: 10, onChanged: (_) {}, label: 'My Label'),
    );
    check(find.text('My Label').evaluate().length).equals(1);
  });

  testWidgets('at min value the slider sits at 0.0 linear', (tester) async {
    await tester.pumpWidget(_host(value: 1, onChanged: (_) {}));
    final slider = tester.widget<Slider>(find.byType(Slider));
    check(slider.value).equals(0.0);
  });

  testWidgets('at max value the slider sits at 1.0 linear', (tester) async {
    await tester.pumpWidget(_host(value: 1000, onChanged: (_) {}));
    final slider = tester.widget<Slider>(find.byType(Slider));
    check(slider.value).equals(1.0);
  });

  testWidgets('log midpoint maps to linear 0.5', (tester) async {
    // sqrt(1 * 1000) ≈ 31.6 — the log-midpoint of (1, 1000).
    await tester.pumpWidget(_host(value: math.sqrt(1000), onChanged: (_) {}));
    final slider = tester.widget<Slider>(find.byType(Slider));
    check((slider.value - 0.5).abs() < 0.01).isTrue();
  });

  testWidgets('out-of-range values clamp', (tester) async {
    await tester.pumpWidget(_host(value: -999, onChanged: (_) {}));
    final slider = tester.widget<Slider>(find.byType(Slider));
    check(slider.value).equals(0.0);
  });
}
