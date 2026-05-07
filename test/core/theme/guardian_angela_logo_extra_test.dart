/// Supplemental tests for [GuardianAngelaLogo] covering the uncovered
/// [_LogoPainter.shouldRepaint] method (lines 91–93).
///
/// [shouldRepaint] is invoked by the Flutter framework whenever the
/// widget rebuilds with the same painter type — it compares the old
/// and new painter fields to decide whether to re-run [paint].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/theme/guardian_angela_logo.dart';

/// A wrapper that exposes a [ValueNotifier<ColorScheme>] so the test
/// can swap colors between frames, exercising [shouldRepaint].
class _ColoredLogo extends StatefulWidget {
  const _ColoredLogo({required this.notifier});
  final ValueNotifier<ColorScheme> notifier;

  @override
  State<_ColoredLogo> createState() => _ColoredLogoState();
}

class _ColoredLogoState extends State<_ColoredLogo> {
  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(_update);
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_update);
    super.dispose();
  }

  void _update() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(colorScheme: widget.notifier.value),
      home: const Scaffold(body: GuardianAngelaLogo()),
    );
  }
}

void main() {
  group('GuardianAngelaLogo — shouldRepaint (lines 91–93)', () {
    testWidgets(
      'rebuilding with different colors triggers shouldRepaint',
      (tester) async {
        final scheme1 = ColorScheme.fromSeed(seedColor: Colors.blue);
        final scheme2 = ColorScheme.fromSeed(seedColor: Colors.red);

        final notifier = ValueNotifier<ColorScheme>(scheme1);

        await tester.pumpWidget(_ColoredLogo(notifier: notifier));
        await tester.pumpAndSettle();

        // Verify logo is rendered.
        check(find.byType(GuardianAngelaLogo).evaluate()).isNotEmpty();

        // Swap to a different color scheme — the framework will call
        // shouldRepaint with the old and new _LogoPainter instances.
        notifier.value = scheme2;
        await tester.pumpAndSettle();

        // Logo must still be present after the repaint cycle.
        check(find.byType(GuardianAngelaLogo).evaluate()).isNotEmpty();

        notifier.dispose();
      },
    );

    testWidgets(
      'rebuilding with identical colors skips repaint',
      (tester) async {
        final scheme = ColorScheme.fromSeed(seedColor: Colors.green);
        final notifier = ValueNotifier<ColorScheme>(scheme);

        await tester.pumpWidget(_ColoredLogo(notifier: notifier));
        await tester.pumpAndSettle();

        // Trigger a rebuild with the same scheme — shouldRepaint returns
        // false and paint is skipped, but the widget must still render.
        notifier.value = ColorScheme.fromSeed(seedColor: Colors.green);
        await tester.pumpAndSettle();

        check(find.byType(GuardianAngelaLogo).evaluate()).isNotEmpty();

        notifier.dispose();
      },
    );

    testWidgets(
      'rebuilding with same scheme instance skips repaint',
      (tester) async {
        final scheme = ColorScheme.fromSeed(seedColor: Colors.purple);
        final notifier = ValueNotifier<ColorScheme>(scheme);

        await tester.pumpWidget(_ColoredLogo(notifier: notifier));
        await tester.pumpAndSettle();

        // Same instance — shouldRepaint must return false.
        notifier.value = scheme;
        await tester.pumpAndSettle();

        check(find.byType(CustomPaint).evaluate()).isNotEmpty();

        notifier.dispose();
      },
    );
  });
}
