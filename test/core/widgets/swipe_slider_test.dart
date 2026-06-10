/// Widget tests for [SwipeSlider].
///
/// Verifies:
///   * dragging the knob below the threshold does NOT fire `onConfirm`
///     and the knob animates back to the start;
///   * dragging past the threshold fires `onConfirm` exactly once;
///   * a single drag-cycle is debounced — continuing the drag (forward or
///     backward) after crossing the threshold does not double-fire;
///   * crossing the threshold triggers a light-impact haptic exactly once;
///   * Semantics expose a slider role with the supplied label.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

    testWidgets(
      'dragging back below threshold then forward within the same gesture '
      'does not re-fire',
      (WidgetTester tester) async {
        // Guards against a regression where `_didFire` is reset on backwards
        // motion within the same pan-update sequence. Only a fresh pan-down
        // event may re-arm the slider.
        var confirmCount = 0;
        await _pump(tester, onConfirm: () => confirmCount++);
        final slider = find.byType(SwipeSlider);
        final start = tester.getCenter(slider);
        final gesture = await tester.startGesture(start);
        // Cross the threshold (240 > 179.2).
        await gesture.moveBy(const Offset(240, 0));
        await tester.pump();
        // Move backwards well below the threshold.
        await gesture.moveBy(const Offset(-200, 0));
        await tester.pump();
        // Cross forward again.
        await gesture.moveBy(const Offset(240, 0));
        await tester.pump();
        await gesture.up();
        await tester.pumpAndSettle();
        check(confirmCount).equals(1);
      },
    );

    testWidgets(
      'a cancelled drag below the threshold resets the knob without firing '
      '(onPanCancel path)',
      (WidgetTester tester) async {
        var confirmCount = 0;
        await _pump(tester, onConfirm: () => confirmCount++);
        final slider = find.byType(SwipeSlider);
        final gesture = await tester.startGesture(tester.getCenter(slider));
        // Move partway (below threshold) then CANCEL the gesture.
        await gesture.moveBy(const Offset(40, 0));
        await tester.pump();
        await gesture.cancel();
        await tester.pumpAndSettle();
        // No confirm; the knob animated back from its dragged position.
        check(confirmCount).equals(0);
      },
    );
  });

  group('SwipeSlider — onPanCancel (real arena loss)', () {
    testWidgets(
      'losing the gesture arena to a parent Scrollable mid-cycle fires a '
      'REAL onPanCancel that resets a still-displaced knob',
      (WidgetTester tester) async {
        // _onPanCancel needs _dragX > 0, but a pan recognizer only receives a
        // cancel BEFORE it accepts (after acceptance the framework routes a
        // pointer cancel to onEnd). The one real-world path: a previous drag
        // left the knob displaced and its reset animation running; a new
        // pointer goes down (onPanDown stops the reset, freezing _dragX > 0)
        // and the OS/arena cancels that pointer before the pan accepts. Here
        // the slider sits in a vertical ListView: moving the second pointer
        // 25 px vertically is past the scrollable's drag slop (18) but below
        // the pan slop (36), so the scrollable wins the arena and the pan
        // recognizer receives a genuine cancel.
        var confirmCount = 0;
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
              body: ListView(
                children: <Widget>[
                  const SizedBox(height: 40),
                  Center(
                    child: SizedBox(
                      width: 320,
                      child: SwipeSlider(
                        label: 'Swipe to confirm',
                        onConfirm: () => confirmCount++,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final knob = find.byIcon(Icons.arrow_forward_rounded);
        final restDx = tester.getTopLeft(knob).dx;

        // Drag 1: displace the knob below the threshold, then release —
        // _onPanEnd starts the 220 ms reset animation. The first 80 px get
        // absorbed by drag-start slop handling, so add a separate 40 px
        // update that definitely reaches _onPanUpdate.
        final g1 = await tester.startGesture(tester.getCenter(knob));
        await g1.moveBy(const Offset(80, 0));
        await tester.pump();
        await g1.moveBy(const Offset(40, 0));
        await tester.pump();
        await g1.up();
        // Zero-duration pump: the reset animation has not advanced yet.
        await tester.pump();
        final displacedDx = tester.getTopLeft(knob).dx;
        check(displacedDx).isGreaterThan(restDx);

        // Drag 2: pointer down stops the reset (knob frozen displaced), then
        // a 25 px vertical move hands the arena to the ListView → the pan
        // recognizer is rejected → real onPanCancel with _dragX > 0.
        final g2 = await tester.startGesture(tester.getCenter(knob));
        await tester.pump();
        await g2.moveBy(const Offset(0, 25));
        await tester.pump();
        await g2.up();
        await tester.pumpAndSettle();

        // The cancel handler restarted the reset: the knob is back at rest.
        // (If onPanCancel had not run, the animation would still be stopped
        // and the knob would remain frozen at displacedDx.)
        check(confirmCount).equals(0);
        check(tester.getTopLeft(knob).dx).equals(restDx);
      },
    );
  });

  group('SwipeSlider — haptic feedback', () {
    testWidgets('crossing the threshold triggers a light-impact haptic', (
      WidgetTester tester,
    ) async {
      final hapticCalls = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            hapticCalls.add(call.arguments as String);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      await _pump(tester, onConfirm: () {});
      final slider = find.byType(SwipeSlider);
      final start = tester.getCenter(slider);
      final gesture = await tester.startGesture(start);
      await gesture.moveBy(const Offset(240, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      // Exactly one HapticFeedback.lightImpact() call mapped to the
      // platform-channel argument 'HapticFeedbackType.lightImpact'.
      check(hapticCalls).deepEquals(<String>['HapticFeedbackType.lightImpact']);
    });

    testWidgets('aborted-below-threshold drag does NOT fire haptic', (
      WidgetTester tester,
    ) async {
      final hapticCalls = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            hapticCalls.add(call.arguments as String);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      await _pump(tester, onConfirm: () {});
      final slider = find.byType(SwipeSlider);
      final start = tester.getCenter(slider);
      final gesture = await tester.startGesture(start);
      await gesture.moveBy(const Offset(80, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      check(hapticCalls).isEmpty();
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
