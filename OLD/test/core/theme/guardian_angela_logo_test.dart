/// Widget smoke test for [GuardianAngelaLogo]. The logo is rendered
/// via a [CustomPainter] so the main goal is verifying it builds
/// without throwing and sizes itself to the requested dimension.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/theme/guardian_angela_logo.dart';

void main() {
  testWidgets('renders with default size', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: GuardianAngelaLogo())),
    );
    final logoFinder = find.byType(GuardianAngelaLogo);
    check(logoFinder.evaluate().length).equals(1);
    final box = tester.getSize(logoFinder);
    check(box.width).equals(96.0);
    check(box.height).equals(96.0);
  });

  testWidgets('respects custom size', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: GuardianAngelaLogo(size: 48)),
      ),
    );
    final box = tester.getSize(find.byType(GuardianAngelaLogo));
    check(box.width).equals(48.0);
  });

  testWidgets('contains a CustomPaint child', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: GuardianAngelaLogo())),
    );
    check(find.descendant(
      of: find.byType(GuardianAngelaLogo),
      matching: find.byType(CustomPaint),
    ).evaluate().isNotEmpty).isTrue();
  });
}
