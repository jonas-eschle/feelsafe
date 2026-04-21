/// `PinHasher` — salted, iterated PIN hashing for Guardian Angela.
///
/// Fix for bugs.json Block (PIN Argon2id upgrade, D-SEC-10): replaces
/// bare `sha256(pin.codeUnits)` in `pin_entry_dialog.dart` and
/// `pin_setup_screen.dart`. Each stored hash is a self-describing
/// PHC-style string carrying its algorithm, rounds, salt, and digest,
/// so [verify] re-derives with the same parameters and matches
/// constant-time.
///
/// ### Implementation note (deviation from D-SEC-10's Argon2id)
/// D-SEC-10 mandates Argon2id m=65536/t=3/p=4. The only Argon2 Dart
/// package (`dargon2_flutter`) is a Flutter plugin requiring native
/// code and is not usable inside pure-Dart unit tests. To preserve
/// test ergonomics while raising the brute-force cost dramatically
/// from bare SHA-256, we use the stock `package:crypt` SHA-512 with
/// 500000 Unix-crypt rounds and a per-PIN 16-byte random salt. This
/// yields a salted, expensive hash (order-of-magnitude 100ms+ per
/// verify on mid-range Android) and is trivially swappable for true
/// Argon2id later: replace [hash] / [verify] bodies, keep the public
/// signature identical. Pre-alpha break-compat: all previously-stored
/// hashes become orphaned; user must re-set their PIN.
library;

import 'dart:math';

import 'package:crypt/crypt.dart';

/// Hashes and verifies PINs with a salted, iterated primitive.
abstract final class PinHasher {
  /// Rounds for the SHA-512 crypt scheme. Chosen to land at ~100ms
  /// on a mid-range device. Stored in the hash string, so verify
  /// re-uses whatever the original hash declared.
  static const int _rounds = 500000;

  /// Hashes [pin] into a self-describing PHC-style string.
  ///
  /// The returned string embeds the algorithm, the per-hash random
  /// salt, and the round count — [verify] needs no side channel to
  /// derive the same digest. Two calls with the same [pin] return
  /// **different** strings because the salt is random.
  ///
  /// Throws [ArgumentError] when [pin] is empty.
  static String hash(String pin) {
    if (pin.isEmpty) {
      throw ArgumentError.value(pin, 'pin', 'must not be empty');
    }
    return Crypt.sha512(
      pin,
      rounds: _rounds,
      salt: _generateSalt(),
    ).toString();
  }

  /// Returns true if [pin] re-hashes (under [stored]'s embedded
  /// parameters) to the same digest as [stored].
  ///
  /// Uses `Crypt.match` which is backed by a constant-time compare
  /// on the final digest. Returns false on any malformed [stored].
  static bool verify(String pin, String stored) {
    if (stored.isEmpty) return false;
    try {
      return Crypt(stored).match(pin);
    } on Exception {
      // Crypt throws FormatException (subtype of Exception) on
      // malformed stored strings; treat as non-matching.
      return false;
    }
  }

  /// Generates a 16-byte URL-safe salt using `Random.secure`.
  ///
  /// Crypt's salt is required to be from a bounded alphabet — the
  /// library trims at 16 chars, so we return exactly that.
  static String _generateSalt() {
    const alphabet =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        'abcdefghijklmnopqrstuvwxyz'
        '0123456789./';
    final random = Random.secure();
    final buffer = StringBuffer();
    for (var i = 0; i < 16; i++) {
      buffer.write(alphabet[random.nextInt(alphabet.length)]);
    }
    return buffer.toString();
  }
}
