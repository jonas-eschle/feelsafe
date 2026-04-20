/// Unit tests for `DistressChain` — round-trip and equality.
library;

import 'package:checks/checks.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:test/test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('DistressChain', () {
    test('defaults empty steps', () {
      const c = DistressChain(id: 'dc1', name: 'Default');
      check(c.steps).isEmpty();
    });

    test('round-trip empty', () {
      const c = DistressChain(id: 'dc1', name: 'Default');
      check(DistressChain.fromJson(c.toJson())).equals(c);
    });

    test('round-trip with steps', () {
      final c = DistressChain(
        id: 'dc1',
        name: 'Default',
        steps: [smsStep(), fakeCallStep(order: 1)],
      );
      check(DistressChain.fromJson(c.toJson())).equals(c);
    });

    test('copyWith replaces fields', () {
      const c = DistressChain(id: 'dc1', name: 'A');
      final c2 = c.copyWith(name: 'B');
      check(c2.name).equals('B');
      check(c2.id).equals(c.id);
    });

    test('equality', () {
      const a = DistressChain(id: 'dc1', name: 'X');
      const b = DistressChain(id: 'dc1', name: 'X');
      check(a).equals(b);
      check(a.hashCode).equals(b.hashCode);
    });
  });
}
