/// Widget tests for [SessionElapsedClock] — the spec-named elapsed clock
/// with three presentations (spec 04 §Timer Display Options) and the G-018
/// idle-fade behaviour of the small (corner) variant.
library;

import 'package:flutter/material.dart';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/domain/enums/stealth_timer_display.dart';
import 'package:guardianangela/features/session/widgets/session_elapsed_clock.dart';

/// Pumps a single [SessionElapsedClock] inside a minimal Material shell.
Future<void> _pumpClock(
  WidgetTester tester, {
  required int elapsedSeconds,
  required StealthTimerDisplay mode,
  Listenable? interactionSignal,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SessionElapsedClock(
            elapsedSeconds: elapsedSeconds,
            displayMode: mode,
            interactionSignal: interactionSignal,
          ),
        ),
      ),
    ),
  );
}

/// Returns the opacity currently applied by the small-mode [AnimatedOpacity].
double _smallOpacity(WidgetTester tester) {
  final opacity = tester.widget<AnimatedOpacity>(
    find.descendant(
      of: find.byKey(sessionElapsedClockKey),
      matching: find.byType(AnimatedOpacity),
    ),
  );
  return opacity.opacity;
}

void main() {
  group('SessionElapsedClock — formatting', () {
    testWidgets('normal mode: M:SS below an hour (non-padded minutes)', (
      WidgetTester tester,
    ) async {
      await _pumpClock(
        tester,
        elapsedSeconds: 65,
        mode: StealthTimerDisplay.normal,
      );
      expect(find.text('1:05'), findsOneWidget);
      expect(find.byKey(sessionElapsedClockKey), findsOneWidget);
    });

    testWidgets('normal mode: H:MM:SS at or above an hour', (
      WidgetTester tester,
    ) async {
      // 1 h 02 min 03 s.
      await _pumpClock(
        tester,
        elapsedSeconds: 3723,
        mode: StealthTimerDisplay.normal,
      );
      expect(find.text('1:02:03'), findsOneWidget);
    });

    testWidgets('small mode: M:SS at or below 99 min', (
      WidgetTester tester,
    ) async {
      // 99 min 59 s — still M:SS.
      await _pumpClock(
        tester,
        elapsedSeconds: 99 * 60 + 59,
        mode: StealthTimerDisplay.small,
      );
      expect(find.text('99:59'), findsOneWidget);
    });

    testWidgets('small mode: falls back to H:MM beyond 99 min', (
      WidgetTester tester,
    ) async {
      // 100 min = 1 h 40 min → "1:40".
      await _pumpClock(
        tester,
        elapsedSeconds: 100 * 60,
        mode: StealthTimerDisplay.small,
      );
      expect(find.text('1:40'), findsOneWidget);
    });

    testWidgets('none mode renders no text but keeps the key', (
      WidgetTester tester,
    ) async {
      await _pumpClock(
        tester,
        elapsedSeconds: 65,
        mode: StealthTimerDisplay.none,
      );
      expect(find.byKey(sessionElapsedClockKey), findsOneWidget);
      expect(find.text('1:05'), findsNothing);
    });
  });

  group('SessionElapsedClock — G-018 idle fade (small mode)', () {
    testWidgets('starts at full opacity, fades to 50% after 10s idle', (
      WidgetTester tester,
    ) async {
      await _pumpClock(
        tester,
        elapsedSeconds: 65,
        mode: StealthTimerDisplay.small,
      );
      // Immediately after mount: full opacity.
      check(_smallOpacity(tester)).equals(1.0);

      // Advance just under the 10 s idle threshold — still full.
      await tester.pump(const Duration(seconds: 9));
      check(_smallOpacity(tester)).equals(1.0);

      // Cross the 10 s threshold — the target opacity flips to 0.5, then the
      // 400 ms animation settles there.
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 450));
      check(_smallOpacity(tester)).equals(0.5);
    });

    testWidgets('an interaction signal restores full opacity and re-arms', (
      WidgetTester tester,
    ) async {
      final signal = ValueNotifier<int>(0);
      addTearDown(signal.dispose);
      await _pumpClock(
        tester,
        elapsedSeconds: 65,
        mode: StealthTimerDisplay.small,
        interactionSignal: signal,
      );
      // Let it dim.
      await tester.pump(const Duration(seconds: 11));
      await tester.pump(const Duration(milliseconds: 450));
      check(_smallOpacity(tester)).equals(0.5);

      // Signal an interaction → instantly back to full opacity.
      signal.value++;
      await tester.pump();
      check(_smallOpacity(tester)).equals(1.0);

      // …and the 10 s countdown restarts: still full at 9 s, dim again at 11 s.
      await tester.pump(const Duration(seconds: 9));
      check(_smallOpacity(tester)).equals(1.0);
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 450));
      check(_smallOpacity(tester)).equals(0.5);
    });

    testWidgets('normal mode never dims (no AnimatedOpacity fade)', (
      WidgetTester tester,
    ) async {
      await _pumpClock(
        tester,
        elapsedSeconds: 65,
        mode: StealthTimerDisplay.normal,
      );
      await tester.pump(const Duration(seconds: 30));
      // No AnimatedOpacity wrapper in normal mode.
      expect(
        find.descendant(
          of: find.byKey(sessionElapsedClockKey),
          matching: find.byType(AnimatedOpacity),
        ),
        findsNothing,
      );
    });
  });
}
