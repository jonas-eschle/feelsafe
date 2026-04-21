/// Tests for [PinResult] enum shape.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/utils/pin_result.dart';

void main() {
  test('all 6 documented variants are present', () {
    check(PinResult.values.toSet()).deepEquals({
      PinResult.correct,
      PinResult.wrong,
      PinResult.duress,
      PinResult.wrongPinThreshold,
      PinResult.timeout,
      PinResult.cancelled,
    });
  });

  test('value names are stable identifiers', () {
    check(PinResult.correct.name).equals('correct');
    check(PinResult.wrong.name).equals('wrong');
    check(PinResult.duress.name).equals('duress');
    check(PinResult.wrongPinThreshold.name).equals('wrongPinThreshold');
    check(PinResult.timeout.name).equals('timeout');
    check(PinResult.cancelled.name).equals('cancelled');
  });

  test('values preserve declaration order', () {
    check(PinResult.values.indexOf(PinResult.correct)).equals(0);
    check(PinResult.values.indexOf(PinResult.cancelled)).equals(5);
  });

  test('exhaustive switch covers every variant', () {
    String describe(PinResult r) => switch (r) {
      PinResult.correct => 'ok',
      PinResult.wrong => 'retry',
      PinResult.duress => 'silent-distress',
      PinResult.wrongPinThreshold => 'distress',
      PinResult.timeout => 'noop',
      PinResult.cancelled => 'noop',
    };
    for (final r in PinResult.values) {
      check(describe(r)).isNotEmpty();
    }
  });
}
