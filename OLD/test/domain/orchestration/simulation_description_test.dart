/// Unit tests for [SimulationDescription].
///
/// Exercises equality, hashCode, and toString.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/domain/orchestration/event_strategy.dart';

void main() {
  group('SimulationDescription', () {
    test('equal when templateKey and args are identical', () {
      const a = SimulationDescription('simSms', {'count': 2});
      const b = SimulationDescription('simSms', {'count': 2});
      check(a).equals(b);
    });

    test('not equal when templateKey differs', () {
      const a = SimulationDescription('simSms');
      const b = SimulationDescription('simAlarm');
      check(a).not((it) => it.equals(b));
    });

    test('not equal when args differ in value', () {
      const a = SimulationDescription('k', {'n': 1});
      const b = SimulationDescription('k', {'n': 2});
      check(a).not((it) => it.equals(b));
    });

    test('not equal when args have different keys', () {
      const a = SimulationDescription('k', {'x': 1});
      const b = SimulationDescription('k', {'y': 1});
      check(a).not((it) => it.equals(b));
    });

    test('not equal when args have different lengths', () {
      const a = SimulationDescription('k', {'x': 1, 'y': 2});
      const b = SimulationDescription('k', {'x': 1});
      check(a).not((it) => it.equals(b));
    });

    test('not equal to a non-SimulationDescription object', () {
      const a = SimulationDescription('simSms');
      // ignore: unrelated_type_equality_checks
      check(a == 'simSms').isFalse();
    });

    test('identical reference equals itself', () {
      const a = SimulationDescription('simSms', {'n': 1});
      check(a == a).isTrue();
    });

    test('hashCode is consistent for equal instances', () {
      const a = SimulationDescription('simFakeCall', {'ring': true});
      const b = SimulationDescription('simFakeCall', {'ring': true});
      check(a.hashCode).equals(b.hashCode);
    });

    test('hashCode differs for different templateKeys', () {
      const a = SimulationDescription('key1');
      const b = SimulationDescription('key2');
      // Allow theoretical collision but it should not happen for simple keys.
      check(a.hashCode).not((it) => it.equals(b.hashCode));
    });

    test('toString contains templateKey', () {
      const a = SimulationDescription('simAlarm', {'vol': 100});
      check(a.toString()).contains('simAlarm');
    });

    test('empty args constructor sets args to const empty map', () {
      const a = SimulationDescription('k');
      check(a.args).isEmpty();
    });

    test('two instances with empty args are equal', () {
      const a = SimulationDescription('simHold');
      const b = SimulationDescription('simHold');
      check(a).equals(b);
    });
  });
}
