/// Widget tests for [PinKeypad].
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/widgets/pin_keypad.dart';

Widget _host({
  required void Function(int) onDigit,
  required VoidCallback onBackspace,
}) => MaterialApp(
  home: Scaffold(
    body: Center(
      child: PinKeypad(onDigit: onDigit, onBackspace: onBackspace),
    ),
  ),
);

void main() {
  testWidgets('renders digits 0..9 and a backspace key', (tester) async {
    await tester.pumpWidget(_host(onDigit: (_) {}, onBackspace: () {}));
    for (final digit in ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0']) {
      check(find.text(digit).evaluate().length).equals(1);
    }
    check(find.text('⌫').evaluate().length).equals(1);
  });

  testWidgets('digit tap fires onDigit with correct value', (tester) async {
    final taps = <int>[];
    await tester.pumpWidget(_host(onDigit: taps.add, onBackspace: () {}));
    await tester.tap(find.text('7'));
    await tester.tap(find.text('0'));
    await tester.tap(find.text('3'));
    check(taps).deepEquals([7, 0, 3]);
  });

  testWidgets('backspace tap fires onBackspace', (tester) async {
    var calls = 0;
    await tester.pumpWidget(_host(onDigit: (_) {}, onBackspace: () => calls++));
    await tester.tap(find.text('⌫'));
    check(calls).equals(1);
  });

  testWidgets('tapping 1..9 in order fires all digits', (tester) async {
    final taps = <int>[];
    await tester.pumpWidget(_host(onDigit: taps.add, onBackspace: () {}));
    for (var i = 1; i <= 9; i++) {
      await tester.tap(find.text('$i'));
    }
    check(taps).deepEquals([1, 2, 3, 4, 5, 6, 7, 8, 9]);
  });
}
