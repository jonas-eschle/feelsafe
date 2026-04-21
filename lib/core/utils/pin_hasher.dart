/// `PinHasher` — Argon2id PIN hashing for Guardian Angela.
///
/// Honors **D-SEC-10**: PINs are hashed with Argon2id at
/// m=65536 KiB (64 MiB), t=3 iterations, p=4 parallelism (lanes),
/// a 16-byte random salt from `Random.secure`, and a 32-byte digest.
/// The stored value is a self-describing PHC-style string
/// `\$argon2id\$v=19\$m=65536,t=3,p=4\$<base64-salt>\$<base64-hash>`,
/// so [verify] re-derives with the exact parameters used to hash.
///
/// Implementation uses `package:argon2` (pure Dart). It is slower than
/// a native implementation but runs on the infrequent PIN-hash path
/// (a handful of hashes per app launch), so the cost is acceptable
/// and it keeps unit tests runnable without native bindings.
///
/// Fix for bugs.json Block (Argon2id UI-thread freeze): [hash] and
/// [verify] are now async and hop the Argon2 derivation into a
/// worker isolate via `Isolate.run`, so the ~1.3s cost no longer
/// blocks the UI thread. `Isolate.run` is used rather than
/// `compute()` so the API works from pure-Dart call sites (no
/// Flutter dependency).
///
/// Pre-alpha break-compat: any hashes stored under a previous scheme
/// will fail to parse and be rejected; users must re-set their PIN.
library;

import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:argon2/argon2.dart';

/// Hashes and verifies PINs using Argon2id per D-SEC-10.
abstract final class PinHasher {
  /// Memory cost in KiB. 65536 = 64 MiB (D-SEC-10).
  static const int _memoryKib = 65536;

  /// Iterations / time cost (D-SEC-10).
  static const int _iterations = 3;

  /// Parallelism / lanes (D-SEC-10).
  static const int _lanes = 4;

  /// Salt length in bytes. 16 is the conventional minimum for
  /// Argon2id and matches OWASP guidance.
  static const int _saltLength = 16;

  /// Output digest length in bytes.
  static const int _hashLength = 32;

  /// Argon2 version tag embedded in the PHC string (0x13 = v1.3).
  static const int _version = Argon2Parameters.ARGON2_VERSION_13;

  /// Hashes [pin] into a self-describing PHC-style string.
  ///
  /// The returned string embeds algorithm, version, params, the
  /// per-hash random salt, and the derived digest — [verify] needs
  /// no side channel to reproduce the digest. Two calls with the
  /// same [pin] return **different** strings (random salt).
  ///
  /// Runs the ~1.3s Argon2id derivation inside a worker isolate
  /// (`Isolate.run`) so the caller's event loop is not blocked.
  ///
  /// Throws [ArgumentError] when [pin] is empty.
  static Future<String> hash(String pin) async {
    if (pin.isEmpty) {
      throw ArgumentError.value(pin, 'pin', 'must not be empty');
    }
    final salt = _generateSalt();
    final digest = await Isolate.run(() => _derive(pin, salt));
    return _encodePhc(salt, digest);
  }

  /// Returns true iff [pin] re-hashes, under [stored]'s embedded
  /// parameters and salt, to the same digest as [stored].
  ///
  /// Uses a constant-time comparison over the digest bytes. Returns
  /// false on any malformed or unsupported [stored] string (wrong
  /// algorithm, wrong version, wrong params, bad base64, etc.) —
  /// never throws.
  ///
  /// Runs the derivation in a worker isolate (see [hash]).
  static Future<bool> verify(String pin, String stored) async {
    if (pin.isEmpty || stored.isEmpty) return false;
    final parsed = _decodePhc(stored);
    if (parsed == null) return false;
    // We intentionally pin m/t/p to the current D-SEC-10 values —
    // mismatched params are rejected rather than re-hashed. This is
    // safe pre-alpha: on schema change users re-set their PIN.
    if (parsed.memory != _memoryKib ||
        parsed.iterations != _iterations ||
        parsed.lanes != _lanes) {
      return false;
    }
    final hashLen = parsed.hash.length;
    final salt = parsed.salt;
    final candidate = await Isolate.run(
      () => _derive(pin, salt, hashLen: hashLen),
    );
    return _constantTimeEquals(candidate, parsed.hash);
  }

  /// Derives an Argon2id digest from [pin] using the given [salt]
  /// and the D-SEC-10 cost parameters.
  static Uint8List _derive(
    String pin,
    Uint8List salt, {
    int? hashLen,
  }) {
    final parameters = Argon2Parameters(
      Argon2Parameters.ARGON2_id,
      salt,
      version: _version,
      iterations: _iterations,
      memory: _memoryKib,
      lanes: _lanes,
    );
    final generator = Argon2BytesGenerator()..init(parameters);
    final passwordBytes = parameters.converter.convert(pin);
    final out = Uint8List(hashLen ?? _hashLength);
    generator.generateBytes(passwordBytes, out, 0, out.length);
    return out;
  }

  /// Returns a fresh [_saltLength]-byte salt from `Random.secure`.
  static Uint8List _generateSalt() {
    final random = Random.secure();
    final bytes = Uint8List(_saltLength);
    for (var i = 0; i < _saltLength; i++) {
      bytes[i] = random.nextInt(256);
    }
    return bytes;
  }

  /// Encodes an Argon2id PHC string with the current parameters.
  static String _encodePhc(Uint8List salt, Uint8List hash) {
    final saltB64 = _b64NoPad(salt);
    final hashB64 = _b64NoPad(hash);
    return '\$argon2id\$v=$_version'
        '\$m=$_memoryKib,t=$_iterations,p=$_lanes'
        '\$$saltB64\$$hashB64';
  }

  /// Parses a PHC string of the form
  /// `\$argon2id\$v=<v>\$m=<m>,t=<t>,p=<p>\$<salt-b64>\$<hash-b64>`.
  /// Returns null on any structural or decode error.
  static _ParsedPhc? _decodePhc(String stored) {
    final parts = stored.split(r'$');
    // Expected: ['', 'argon2id', 'v=19', 'm=..,t=..,p=..', salt, hash]
    if (parts.length != 6) return null;
    if (parts[0].isNotEmpty) return null;
    if (parts[1] != 'argon2id') return null;
    final version = _parseKv(parts[2], 'v');
    if (version == null) return null;
    final paramMap = _parseParams(parts[3]);
    if (paramMap == null) return null;
    final memory = paramMap['m'];
    final iterations = paramMap['t'];
    final lanes = paramMap['p'];
    if (memory == null || iterations == null || lanes == null) {
      return null;
    }
    final salt = _tryB64Decode(parts[4]);
    final hash = _tryB64Decode(parts[5]);
    if (salt == null || hash == null) return null;
    return _ParsedPhc(
      version: version,
      memory: memory,
      iterations: iterations,
      lanes: lanes,
      salt: salt,
      hash: hash,
    );
  }

  /// Parses a single `key=value` pair. Returns the int value or null.
  static int? _parseKv(String src, String key) {
    final eq = src.indexOf('=');
    if (eq < 0) return null;
    if (src.substring(0, eq) != key) return null;
    return int.tryParse(src.substring(eq + 1));
  }

  /// Parses `m=..,t=..,p=..` into a map of ints, or null on error.
  static Map<String, int>? _parseParams(String src) {
    final out = <String, int>{};
    for (final pair in src.split(',')) {
      final eq = pair.indexOf('=');
      if (eq < 0) return null;
      final k = pair.substring(0, eq);
      final v = int.tryParse(pair.substring(eq + 1));
      if (v == null) return null;
      out[k] = v;
    }
    return out;
  }

  /// Base64 encode without the `=` padding (standard PHC form).
  static String _b64NoPad(Uint8List bytes) {
    final encoded = base64.encode(bytes);
    return encoded.replaceAll('=', '');
  }

  /// Base64 decode tolerating missing PHC-style padding. Returns null
  /// on any decode error.
  static Uint8List? _tryB64Decode(String src) {
    try {
      final padded = src.padRight(((src.length + 3) ~/ 4) * 4, '=');
      return base64.decode(padded);
    } on FormatException {
      return null;
    }
  }

  /// Constant-time byte-sequence comparison. Returns false for
  /// length mismatch; never short-circuits within equal lengths.
  static bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}

/// Decoded pieces of an Argon2id PHC string.
class _ParsedPhc {
  _ParsedPhc({
    required this.version,
    required this.memory,
    required this.iterations,
    required this.lanes,
    required this.salt,
    required this.hash,
  });

  final int version;
  final int memory;
  final int iterations;
  final int lanes;
  final Uint8List salt;
  final Uint8List hash;
}
