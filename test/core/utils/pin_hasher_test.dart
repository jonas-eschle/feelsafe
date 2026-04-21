/// Tests for [PinHasher] — Argon2id PIN primitive per D-SEC-10.
///
/// Covers round-trip, wrong-pin rejection, per-call salt randomness,
/// empty-pin guard, malformed-stored tolerance, PHC parse, param
/// embedding (m=65536, t=3, p=4), and a loose CI timing ceiling.
///
/// Fix for bugs.json Block (Argon2id UI-thread freeze): the
/// primitive is now async (hash/verify dispatch the derivation to a
/// worker isolate via `Isolate.run`). Every test awaits the futures.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/utils/pin_hasher.dart';

void main() {
  group('PinHasher.hash', () {
    test('produces a non-empty Argon2id PHC-style string', () async {
      final hash = await PinHasher.hash('1234');
      check(hash).isNotEmpty();
      check(hash.startsWith(r'$argon2id$')).isTrue();
    });

    test('two calls with the same PIN produce different stored hashes',
        () async {
      // Per-call random salt -> outputs must differ bit-for-bit.
      final a = await PinHasher.hash('9999');
      final b = await PinHasher.hash('9999');
      check(a).not((it) => it.equals(b));
    });

    test('rejects an empty PIN with ArgumentError', () async {
      await check(PinHasher.hash('')).throws<ArgumentError>();
    });

    test('PHC string embeds D-SEC-10 parameters (m=65536,t=3,p=4)', () async {
      final hash = await PinHasher.hash('4321');
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
    test('round-trip: verify returns true for the original PIN', () async {
      final stored = await PinHasher.hash('4242');
      check(await PinHasher.verify('4242', stored)).isTrue();
    });

    test('wrong PIN returns false', () async {
      final stored = await PinHasher.hash('4242');
      check(await PinHasher.verify('0000', stored)).isFalse();
    });

    test('near-miss PIN returns false (not a prefix match)', () async {
      final stored = await PinHasher.hash('12345678');
      check(await PinHasher.verify('1234567', stored)).isFalse();
    });

    test('malformed stored hash returns false (no throw)', () async {
      check(
        await PinHasher.verify('1234', 'not-a-valid-hash-string'),
      ).isFalse();
    });

    test('empty stored hash returns false', () async {
      check(await PinHasher.verify('1234', '')).isFalse();
    });

    test('PIN with special characters round-trips', () async {
      // PINs are numeric in UI today, but the primitive must not
      // mangle other chars (defensive guard for future alpha PINs).
      final stored = await PinHasher.hash(r'$abc:def');
      check(await PinHasher.verify(r'$abc:def', stored)).isTrue();
      check(await PinHasher.verify('abc', stored)).isFalse();
    });

    test('hash with mismatched params is rejected', () async {
      // Splicing weaker params must not be honored. We rebuild a
      // valid-looking PHC with m=1024 (8x weaker) and expect reject.
      final original = await PinHasher.hash('5555');
      final parts = original.split(r'$');
      parts[3] = 'm=1024,t=3,p=4';
      final tampered = parts.join(r'$');
      check(await PinHasher.verify('5555', tampered)).isFalse();
    });
  });

  group('PinHasher timing', () {
    test('hash completes under 10s (CI-loose upper bound)', () async {
      // This is not a security floor — just a sanity ceiling so a
      // future regression to pathologically slow hashing (>10s) fails
      // loudly. Nominal on modern hardware is ~1.3s for Argon2id at
      // m=65536/t=3/p=4; under parallel `flutter test -j 6` the CPU
      // is contended so we give it generous headroom.
      final stopwatch = Stopwatch()..start();
      await PinHasher.hash('timing-probe');
      stopwatch.stop();
      check(stopwatch.elapsed.inSeconds).isLessThan(10);
    });
  });
}
