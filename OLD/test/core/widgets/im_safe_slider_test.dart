/// Widget tests for [ImSafeSlider].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/theme/app_theme.dart';
import 'package:guardianangela/core/widgets/im_safe_slider.dart';

Widget _host({required VoidCallback onConfirmed, String label = 'I am safe'}) =>
    MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ImSafeSlider(label: label, onConfirmed: onConfirmed),
        ),
      ),
    );

void main() {
  testWidgets('shows the provided label', (tester) async {
    await tester.pumpWidget(_host(onConfirmed: () {}));
    check(find.text('I am safe').evaluate().length).equals(1);
  });

  testWidgets('small drag does not confirm', (tester) async {
    var confirmed = 0;
    await tester.pumpWidget(_host(onConfirmed: () => confirmed++));
    // A 5-pixel drag is well short of the 90% threshold.
    await tester.drag(find.byIcon(Icons.arrow_forward), const Offset(5, 0));
    await tester.pump();
    check(confirmed).equals(0);
  });

  testWidgets('full-width drag fires onConfirmed', (tester) async {
    var confirmed = 0;
    await tester.pumpWidget(_host(onConfirmed: () => confirmed++));
    final handle = find.byIcon(Icons.arrow_forward);
    check(handle.evaluate().length).equals(1);
    // Drag far further than the slider width — guarantees we hit
    // the `_threshold = 0.9` gate.
    await tester.drag(handle, const Offset(2000, 0));
    await tester.pumpAndSettle();
    check(confirmed).equals(1);
  });
}
