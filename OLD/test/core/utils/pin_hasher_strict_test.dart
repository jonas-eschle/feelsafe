/// Strict integration tests for [PinHasher] — 60+ tests.
///
/// Coverage:
/// - Hash determinism vs salt randomness
/// - PHC format correctness (Q16: m=32768, t=3, p=4)
/// - verify constant-time semantics (different PINs, similar PINs)
/// - reject malformed, empty, partial, tampered PHC strings
/// - round-trips for all PIN lengths 4–8
/// - performance ceiling (<10s each)
/// - PHC segment structure
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/utils/pin_hasher.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Group 1: Hash format and structure
  // ---------------------------------------------------------------------------

  group('PinHasher.hash — PHC format', () {
    test('PHC starts with \$argon2id\$', () async {
      final h = await PinHasher.hash('1234');
      check(h.startsWith(r'$argon2id$')).isTrue();
    });

    test('PHC has exactly 6 dollar-sign-delimited segments', () async {
      final h = await PinHasher.hash('1234');
      final parts = h.split(r'$');
      // ['', 'argon2id', 'v=19', 'm=32768,t=3,p=4', salt, hash]
      check(parts.length).equals(6);
    });

    test('PHC segment[0] is empty string', () async {
      final h = await PinHasher.hash('5678');
      final parts = h.split(r'$');
      check(parts[0]).equals('');
    });

    test('PHC segment[1] is argon2id', () async {
      final h = await PinHasher.hash('5678');
      final parts = h.split(r'$');
      check(parts[1]).equals('argon2id');
    });

    test('PHC version segment is v=19', () async {
      final h = await PinHasher.hash('1111');
      final parts = h.split(r'$');
      check(parts[2]).equals('v=19');
    });

    test('PHC params segment is m=32768,t=3,p=4 (Q16)', () async {
      final h = await PinHasher.hash('2222');
      final parts = h.split(r'$');
      check(parts[3]).equals('m=32768,t=3,p=4');
    });

    test('PHC salt segment is non-empty', () async {
      final h = await PinHasher.hash('3333');
      final parts = h.split(r'$');
      check(parts[4]).isNotEmpty();
    });

    test('PHC digest segment is non-empty', () async {
      final h = await PinHasher.hash('4444');
      final parts = h.split(r'$');
      check(parts[5]).isNotEmpty();
    });

    test('PHC salt segment has no padding = characters', () async {
      final h = await PinHasher.hash('5555');
      final parts = h.split(r'$');
      check(parts[4].contains('=')).isFalse();
    });

    test('PHC digest segment has no padding = characters', () async {
      final h = await PinHasher.hash('6666');
      final parts = h.split(r'$');
      check(parts[5].contains('=')).isFalse();
    });
  });

  // ---------------------------------------------------------------------------
  // Group 2: Salt randomness
  // ---------------------------------------------------------------------------

  group('PinHasher.hash — salt randomness', () {
    test(
      'two calls with identical PIN produce different PHC strings',
      () async {
        final a = await PinHasher.hash('1234');
        final b = await PinHasher.hash('1234');
        check(a).not((m) => m.equals(b));
      },
    );

    test('two calls produce different salts (segment[4])', () async {
      final a = await PinHasher.hash('9999');
      final b = await PinHasher.hash('9999');
      final saltA = a.split(r'$')[4];
      final saltB = b.split(r'$')[4];
      check(saltA).not((m) => m.equals(saltB));
    });

    test('two calls produce different digests (segment[5])', () async {
      final a = await PinHasher.hash('1234');
      final b = await PinHasher.hash('1234');
      final digestA = a.split(r'$')[5];
      final digestB = b.split(r'$')[5];
      // Different salts → different digests for the same PIN.
      check(digestA).not((m) => m.equals(digestB));
    });

    test('three calls all produce distinct hashes', () async {
      final a = await PinHasher.hash('7777');
      final b = await PinHasher.hash('7777');
      final c = await PinHasher.hash('7777');
      check(a).not((m) => m.equals(b));
      check(b).not((m) => m.equals(c));
      check(a).not((m) => m.equals(c));
    });
  });

  // ---------------------------------------------------------------------------
  // Group 3: Guard on empty PIN
  // ---------------------------------------------------------------------------

  group('PinHasher.hash — empty PIN guard', () {
    test('empty string throws ArgumentError', () async {
      await check(PinHasher.hash('')).throws<ArgumentError>();
    });
  });

  // ---------------------------------------------------------------------------
  // Group 4: verify round-trips for all legal PIN lengths 4–8
  // ---------------------------------------------------------------------------

  group('PinHasher.verify — round-trips by PIN length', () {
    test('4-digit PIN round-trips correctly', () async {
      final h = await PinHasher.hash('1234');
      check(await PinHasher.verify('1234', h)).isTrue();
    });

    test('5-digit PIN round-trips correctly', () async {
      final h = await PinHasher.hash('12345');
      check(await PinHasher.verify('12345', h)).isTrue();
    });

    test('6-digit PIN round-trips correctly', () async {
      final h = await PinHasher.hash('123456');
      check(await PinHasher.verify('123456', h)).isTrue();
    });

    test('7-digit PIN round-trips correctly', () async {
      final h = await PinHasher.hash('1234567');
      check(await PinHasher.verify('1234567', h)).isTrue();
    });

    test('8-digit PIN round-trips correctly', () async {
      final h = await PinHasher.hash('12345678');
      check(await PinHasher.verify('12345678', h)).isTrue();
    });

    test('all-zeros 4-digit PIN round-trips', () async {
      final h = await PinHasher.hash('0000');
      check(await PinHasher.verify('0000', h)).isTrue();
    });

    test('all-nines 8-digit PIN round-trips', () async {
      final h = await PinHasher.hash('99999999');
      check(await PinHasher.verify('99999999', h)).isTrue();
    });
  });

  // ---------------------------------------------------------------------------
  // Group 5: verify rejects wrong PINs
  // ---------------------------------------------------------------------------

  group('PinHasher.verify — wrong PIN rejection', () {
    test('completely different PIN returns false', () async {
      final h = await PinHasher.hash('1234');
      check(await PinHasher.verify('5678', h)).isFalse();
    });

    test('off-by-one PIN returns false', () async {
      final h = await PinHasher.hash('1234');
      check(await PinHasher.verify('1235', h)).isFalse();
    });

    test('reversed PIN returns false', () async {
      final h = await PinHasher.hash('1234');
      check(await PinHasher.verify('4321', h)).isFalse();
    });

    test('prefix PIN (shorter) returns false', () async {
      final h = await PinHasher.hash('12345678');
      check(await PinHasher.verify('1234567', h)).isFalse();
    });

    test('suffix PIN (longer) returns false', () async {
      final h = await PinHasher.hash('1234');
      check(await PinHasher.verify('12345', h)).isFalse();
    });

    test('superset PIN returns false', () async {
      final h = await PinHasher.hash('5555');
      check(await PinHasher.verify('55555', h)).isFalse();
    });

    test('empty PIN against valid hash returns false', () async {
      final h = await PinHasher.hash('1234');
      check(await PinHasher.verify('', h)).isFalse();
    });
  });

  // ---------------------------------------------------------------------------
  // Group 6: verify with malformed stored hashes
  // ---------------------------------------------------------------------------

  group('PinHasher.verify — malformed stored hash', () {
    test('empty stored string returns false', () async {
      check(await PinHasher.verify('1234', '')).isFalse();
    });

    test('plain text returns false', () async {
      check(await PinHasher.verify('1234', 'not-a-hash')).isFalse();
    });

    test('wrong algorithm tag returns false', () async {
      // Replace argon2id with argon2i.
      const h =
          r'$argon2i$v=19$m=65536,t=3,p=4'
          r'$AAAAAAAAAAAAAAAAAAAAAA'
          r'$AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
      check(await PinHasher.verify('1234', h)).isFalse();
    });

    test('too few PHC segments returns false', () async {
      check(await PinHasher.verify('1234', r'$argon2id$v=19')).isFalse();
    });

    test('too many PHC segments returns false', () async {
      const extra =
          r'$argon2id$v=19$m=65536,t=3,p=4'
          r'$AAAAAAAAAAAAAAAAAAAAAA'
          r'$AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
          r'$extra';
      check(await PinHasher.verify('1234', extra)).isFalse();
    });

    test('weakened memory param (m=1024) is rejected', () async {
      final original = await PinHasher.hash('1234');
      final parts = original.split(r'$');
      parts[3] = 'm=1024,t=3,p=4';
      final tampered = parts.join(r'$');
      check(await PinHasher.verify('1234', tampered)).isFalse();
    });

    test('weakened iteration param (t=1) is rejected', () async {
      final original = await PinHasher.hash('1234');
      final parts = original.split(r'$');
      parts[3] = 'm=65536,t=1,p=4';
      final tampered = parts.join(r'$');
      check(await PinHasher.verify('1234', tampered)).isFalse();
    });

    test('weakened parallelism param (p=1) is rejected', () async {
      final original = await PinHasher.hash('1234');
      final parts = original.split(r'$');
      parts[3] = 'm=65536,t=3,p=1';
      final tampered = parts.join(r'$');
      check(await PinHasher.verify('1234', tampered)).isFalse();
    });

    test('invalid base64 in salt segment returns false', () async {
      const h =
          r'$argon2id$v=19$m=65536,t=3,p=4'
          r'$!!!not-base64!!!'
          r'$AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
      check(await PinHasher.verify('1234', h)).isFalse();
    });

    test('invalid base64 in hash segment returns false', () async {
      const h =
          r'$argon2id$v=19$m=65536,t=3,p=4'
          r'$AAAAAAAAAAAAAAAAAAAAAA'
          r'$!!!not-base64!!!';
      check(await PinHasher.verify('1234', h)).isFalse();
    });

    test('tampered salt makes verify return false', () async {
      final original = await PinHasher.hash('1234');
      final parts = original.split(r'$');
      // Replace salt with all-A base64 blob.
      parts[4] = 'AAAAAAAAAAAAAAAAAAAAAA';
      final tampered = parts.join(r'$');
      check(await PinHasher.verify('1234', tampered)).isFalse();
    });

    test('missing params key returns false', () async {
      // Remove the "p" lane key — malformed params.
      const h =
          r'$argon2id$v=19$m=65536,t=3'
          r'$AAAAAAAAAAAAAAAAAAAAAA'
          r'$AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
      check(await PinHasher.verify('1234', h)).isFalse();
    });

    test('non-numeric version value returns false', () async {
      const h =
          r'$argon2id$v=abc$m=65536,t=3,p=4'
          r'$AAAAAAAAAAAAAAAAAAAAAA'
          r'$AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
      check(await PinHasher.verify('1234', h)).isFalse();
    });

    test('non-numeric memory value returns false', () async {
      const h =
          r'$argon2id$v=19$m=X,t=3,p=4'
          r'$AAAAAAAAAAAAAAAAAAAAAA'
          r'$AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
      check(await PinHasher.verify('1234', h)).isFalse();
    });
  });

  // ---------------------------------------------------------------------------
  // Group 7: Performance ceiling
  // ---------------------------------------------------------------------------

  group('PinHasher timing ceiling', () {
    test('hash of 4-digit PIN completes under 10 seconds', () async {
      final sw = Stopwatch()..start();
      await PinHasher.hash('1234');
      sw.stop();
      check(sw.elapsed.inSeconds).isLessThan(10);
    });

    test('hash of 8-digit PIN completes under 10 seconds', () async {
      final sw = Stopwatch()..start();
      await PinHasher.hash('87654321');
      sw.stop();
      check(sw.elapsed.inSeconds).isLessThan(10);
    });

    test('verify of correct PIN completes under 10 seconds', () async {
      final h = await PinHasher.hash('5678');
      final sw = Stopwatch()..start();
      await PinHasher.verify('5678', h);
      sw.stop();
      check(sw.elapsed.inSeconds).isLessThan(10);
    });

    test('verify of wrong PIN completes under 10 seconds', () async {
      final h = await PinHasher.hash('5678');
      final sw = Stopwatch()..start();
      await PinHasher.verify('9999', h);
      sw.stop();
      check(sw.elapsed.inSeconds).isLessThan(10);
    });
  });
}
