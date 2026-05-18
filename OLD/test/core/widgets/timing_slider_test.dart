/// Unit tests for [TimingSlider] + helpers — DE-1.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/widgets/timing_slider.dart';

void main() {
  group('formatTimingLabel', () {
    test('zero renders as "0s (immediate)"', () {
      check(formatTimingLabel(0)).equals('0s (immediate)');
      check(formatTimingLabel(-3)).equals('0s (immediate)');
    });

    test('seconds (<60) renders as "Ns"', () {
      check(formatTimingLabel(1)).equals('1s');
      check(formatTimingLabel(45)).equals('45s');
    });

    test('minutes range (<3600) renders as "Nm" or "Nm Ns"', () {
      check(formatTimingLabel(60)).equals('1m');
      check(formatTimingLabel(90)).equals('1m 30s');
      check(formatTimingLabel(2700)).equals('45m');
    });

    test('hours range (<86400) renders as "Nh" or "Nh Nm"', () {
      check(formatTimingLabel(3600)).equals('1h');
      check(formatTimingLabel(5400)).equals('1h 30m');
      check(formatTimingLabel(86399)).equals('23h 59m');
    });

    test('days range (>=86400) renders as "Nd" or "Nd Nh"', () {
      check(formatTimingLabel(86400)).equals('1d');
      check(formatTimingLabel(90000)).equals('1d 1h');
      check(formatTimingLabel(31536000)).equals('365d');
    });
  });

  group('closestSnapStopIndex', () {
    test('clamps below first stop to 0', () {
      check(closestSnapStopIndex(-5)).equals(0);
      check(closestSnapStopIndex(0)).equals(0);
    });

    test('clamps above last stop to last index', () {
      check(closestSnapStopIndex(31536000)).equals(kTimingSnapStops.length - 1);
      check(closestSnapStopIndex(99999999))
          .equals(kTimingSnapStops.length - 1);
    });

    test('exact match returns the matching index', () {
      check(closestSnapStopIndex(60))
          .equals(kTimingSnapStops.indexOf(60));
      check(closestSnapStopIndex(3600))
          .equals(kTimingSnapStops.indexOf(3600));
    });

    test('between two stops returns the nearest', () {
      // 7 is between 5 and 10 — closer to 5.
      check(kTimingSnapStops[closestSnapStopIndex(7)]).equals(5);
      // 8 is closer to 10.
      check(kTimingSnapStops[closestSnapStopIndex(8)]).equals(10);
    });

    // Spec-derived: 13 is between stops 10 and 15. |15-13|=2 < |13-10|=3,
    // so 13 should snap to the index of 15.
    test('closestSnapStopIndex(13) returns the index of 15', () {
      final idx = closestSnapStopIndex(13);
      check(kTimingSnapStops[idx]).equals(15);
    });

    // Spec-derived boundary assertions for key label values.
    test('formatTimingLabel(0) returns "0s (immediate)"', () {
      check(formatTimingLabel(0)).equals('0s (immediate)');
    });

    test('formatTimingLabel(60) returns "1m"', () {
      check(formatTimingLabel(60)).equals('1m');
    });

    test('formatTimingLabel(3600) returns "1h"', () {
      check(formatTimingLabel(3600)).equals('1h');
    });

    test('formatTimingLabel(86400) returns "1d"', () {
      check(formatTimingLabel(86400)).equals('1d');
    });
  });

  group('TimingSlider widget', () {
    testWidgets('renders the formatted label in the chip', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TimingSlider(
            seconds: 90,
            onChanged: (_) {},
          ),
        ),
      ));
      check(find.text('1m 30s').evaluate().length).isGreaterThan(0);
    });

    testWidgets('renders an immediate label for 0s', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TimingSlider(
            seconds: 0,
            onChanged: (_) {},
          ),
        ),
      ));
      check(find.text('0s (immediate)').evaluate().length).isGreaterThan(0);
    });

    testWidgets('moving the Slider snaps to a stop and notifies',
        (tester) async {
      int? captured;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TimingSlider(
            seconds: 0,
            onChanged: (v) => captured = v,
          ),
        ),
      ));
      // Drag the slider to the right end of the track. Material's
      // `Slider` reports the new value via onChanged on each update,
      // and TimingSlider snaps it to the closest stop.
      final sliderCenter = tester.getCenter(find.byType(Slider));
      await tester.dragFrom(sliderCenter, const Offset(2000, 0));
      await tester.pumpAndSettle();
      check(captured).isNotNull();
      check(kTimingSnapStops).contains(captured!);
      // The drag should land on or near the right edge.
      check(captured!).isGreaterOrEqual(86400);
    });
  });
}
