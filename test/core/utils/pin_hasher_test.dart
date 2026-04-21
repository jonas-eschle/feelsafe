/// Tests for [PinHasher] — Argon2id PIN primitive per D-SEC-10.
///
/// Covers round-trip, wrong-pin rejection, per-call salt randomness,
/// empty-pin guard, malformed-stored tolerance, PHC parse, param
/// embedding (m=65536, t=3, p=4), and a loose CI timing ceiling.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/utils/pin_hasher.dart';

void main() {
  group('PinHasher.hash', () {
    test('produces a non-empty Argon2id PHC-style string', () {
      final hash = PinHasher.hash('1234');
      check(hash).isNotEmpty();
      check(hash.startsWith(r'$argon2id$')).isTrue();
    });

    test('two calls with the same PIN produce different stored hashes', () {
      // Per-call random salt -> outputs must differ bit-for-bit.
      final a = PinHasher.hash('9999');
      final b = PinHasher.hash('9999');
      check(a).not((it) => it.equals(b));
    });

    test('rejects an empty PIN with ArgumentError', () {
      check(() => PinHasher.hash('')).throws<ArgumentError>();
    });

    test('PHC string embeds D-SEC-10 parameters (m=65536,t=3,p=4)', () {
      final hash = PinHasher.hash('4321');
      // Split PHC segments: ['', 'argon2id', 'v=19', 'm=..,t=..,p=..',
      // salt, hash].
      final parts = hash.split(r'$');
      check(parts.length).equals(6);
      check(parts[1]).equals('argon2id');
      check(parts[2]).equals('v=19');
      check(parts[3]).equals('m=65536,t=3,p=4');
      // Salt and hash segments must be non-empty base64 blobs.
      check(parts[4]).isNotEmpty();
      check(parts[5]).isNotEmpty();
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
      check(
        PinHasher.verify('1234', 'not-a-valid-hash-string'),
      ).isFalse();
    });

    test('empty stored hash returns false', () {
      check(PinHasher.verify('1234', '')).isFalse();
    });

    test('PIN with special characters round-trips', () {
      // PINs are numeric in UI today, but the primitive must not
      // mangle other chars (defensive guard for future alpha PINs).
      final stored = PinHasher.hash(r'$abc:def');
      check(PinHasher.verify(r'$abc:def', stored)).isTrue();
      check(PinHasher.verify('abc', stored)).isFalse();
    });

    test('hash with mismatched params is rejected', () {
      // Splicing weaker params must not be honored. We rebuild a
      // valid-looking PHC with m=1024 (8x weaker) and expect reject.
      final original = PinHasher.hash('5555');
      final parts = original.split(r'$');
      parts[3] = 'm=1024,t=3,p=4';
      final tampered = parts.join(r'$');
      check(PinHasher.verify('5555', tampered)).isFalse();
    });
  });

  group('PinHasher timing', () {
    test('hash completes under 10s (CI-loose upper bound)', () {
      // This is not a security floor — just a sanity ceiling so a
      // future regression to pathologically slow hashing (>10s) fails
      // loudly. Nominal on modern hardware is ~1.3s for Argon2id at
      // m=65536/t=3/p=4; under parallel `flutter test -j 6` the CPU
      // is contended so we give it generous headroom.
      final stopwatch = Stopwatch()..start();
      PinHasher.hash('timing-probe');
      stopwatch.stop();
      check(stopwatch.elapsed.inSeconds).isLessThan(10);
    });
  });
}
