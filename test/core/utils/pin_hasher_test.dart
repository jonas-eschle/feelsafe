/// Tests for [PinHasher].
///
/// Verifies the salted/iterated PIN primitive used after the
/// bugs.json Block "PIN Argon2id upgrade" fix. Round-trip, wrong-pin,
/// per-call randomness, empty-pin guard, malformed-stored tolerance.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/utils/pin_hasher.dart';

void main() {
  group('PinHasher.hash', () {
    test('produces a non-empty PHC-style string', () {
      final hash = PinHasher.hash('1234');
      check(hash).isNotEmpty();
      // crypt SHA-512 prefix; see doc in pin_hasher.dart for rationale.
      check(hash.startsWith(r'$6$')).isTrue();
    });

    test('two calls with the same PIN produce different stored hashes', () {
      // The per-call random salt must differ, so two hashes of the
      // same PIN must not collide character-for-character.
      final a = PinHasher.hash('9999');
      final b = PinHasher.hash('9999');
      check(a).not((it) => it.equals(b));
    });

    test('rejects an empty PIN with ArgumentError', () {
      check(() => PinHasher.hash('')).throws<ArgumentError>();
    });
  });

  group('PinHasher.verify', () {
    test('round-trip: verify returns true for the original PIN', () {
      final stored = PinHasher.hash('4242');
      check(PinHasher.verify('4242', stored)).isTrue();
    });

    test('wrong PIN returns false', () {
      final stored = PinHasher.hash('4242');
      check(PinHasher.verify('0000', stored)).isFalse();
    });

    test('near-miss PIN returns false (not a prefix match)', () {
      final stored = PinHasher.hash('12345678');
      check(PinHasher.verify('1234567', stored)).isFalse();
    });

    test('malformed stored hash returns false (no throw)', () {
      check(PinHasher.verify('1234', 'not-a-valid-hash-string')).isFalse();
    });

    test('empty stored hash returns false', () {
      check(PinHasher.verify('1234', '')).isFalse();
    });

    test(
      'verify with PIN that contains colons / special chars round-trips',
      () {
        // Ensures the hasher does not mangle special chars; PINs are
        // numeric in the UI but defensive assertion against future
        // alpha PINs.
        final stored = PinHasher.hash(r'$abc:def');
        check(PinHasher.verify(r'$abc:def', stored)).isTrue();
        check(PinHasher.verify('abc', stored)).isFalse();
      },
    );
  });
}
