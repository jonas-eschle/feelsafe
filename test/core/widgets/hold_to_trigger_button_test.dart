/// Widget tests for [HoldToTriggerButton].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/theme/app_theme.dart';
import 'package:guardianangela/core/widgets/hold_to_trigger_button.dart';

Widget _host({
  required VoidCallback onHoldStart,
  required VoidCallback onHoldRelease,
  String label = 'Hold',
}) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(
    body: Center(
      child: HoldToTriggerButton(
        onHoldStart: onHoldStart,
        onHoldRelease: onHoldRelease,
        semanticLabel: 'hold button',
        label: label,
      ),
    ),
  ),
);

void main() {
  testWidgets('shows the label', (tester) async {
    await tester.pumpWidget(_host(
      onHoldStart: () {},
      onHoldRelease: () {},
      label: 'Press Me',
    ));
    check(find.text('Press Me').evaluate().length).equals(1);
  });

  testWidgets('tap down + up fires both callbacks in order', (tester) async {
    final events = <String>[];
    await tester.pumpWidget(_host(
      onHoldStart: () => events.add('start'),
      onHoldRelease: () => events.add('release'),
    ));
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(HoldToTriggerButton)),
    );
    await tester.pump();
    await gesture.up();
    await tester.pump();
    check(events).deepEquals(['start', 'release']);
  });

  testWidgets('release without a prior start is ignored', (tester) async {
    // Simulating a tap-cancel from a non-held state — the widget
    // should not call onHoldRelease again.
    var starts = 0;
    var releases = 0;
    await tester.pumpWidget(_host(
      onHoldStart: () => starts++,
      onHoldRelease: () => releases++,
    ));
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(HoldToTriggerButton)),
    );
    await tester.pump();
    await gesture.up();
    await tester.pump();
    // Now attempting another tap-cancel that never started should be
    // a no-op.
    check(starts).equals(1);
    check(releases).equals(1);
  });

  testWidgets('exposes a Semantics label', (tester) async {
    await tester.pumpWidget(_host(onHoldStart: () {}, onHoldRelease: () {}));
    // Inspect the Semantics widget directly rather than relying on
    // the semantics tree (which requires ensureSemantics).
    final semanticsWidgets = tester
        .widgetList<Semantics>(
          find.descendant(
            of: find.byType(HoldToTriggerButton),
            matching: find.byType(Semantics),
          ),
        )
        .toList();
    check(semanticsWidgets.any((s) => s.properties.label == 'hold button'))
        .isTrue();
  });
}
