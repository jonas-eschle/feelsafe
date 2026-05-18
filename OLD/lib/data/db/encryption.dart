/// SQLCipher encryption-key management.
///
/// A random 32-byte passphrase is generated on first launch, stored
/// via `flutter_secure_storage`, and reused for every subsequent
/// database open. Losing the passphrase (e.g., via
/// [EncryptionKey.reset]) makes the database unrecoverable — the
/// caller must then nuke the `.sqlite` file and re-seed.
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Per D-SEC-10, the raw SQLCipher passphrase lives in the platform
/// keystore (Keychain on iOS, EncryptedSharedPreferences on Android)
/// and is loaded lazily when the database opens.
final class EncryptionKey {
  const EncryptionKey._();

  /// Secure-storage key under which the passphrase is stored.
  static const String _storageKey = 'ga_sqlcipher_passphrase';

  /// Returns the database passphrase, generating and persisting a
  /// new 32-byte random value on first access.
  ///
  /// [storage] — injectable for tests; defaults to the process-level
  /// `FlutterSecureStorage` singleton.
  static Future<String> load({FlutterSecureStorage? storage}) async {
    final s = storage ?? const FlutterSecureStorage();
    final existing = await s.read(key: _storageKey);
    if (existing != null) return existing;
    final generated = _generateRandomBase64(32);
    await s.write(key: _storageKey, value: generated);
    return generated;
  }

  /// Deletes the stored passphrase.
  ///
  /// The caller must also delete the physical `.sqlite` file or
  /// recover via nuke-and-reseed — any subsequent open with a new
  /// passphrase will fail against a stale encrypted file.
  static Future<void> reset({FlutterSecureStorage? storage}) async {
    final s = storage ?? const FlutterSecureStorage();
    await s.delete(key: _storageKey);
  }

  /// Generates [bytes] of cryptographically-random data encoded as
  /// URL-safe base64 (suitable for passing to SQLCipher `PRAGMA
  /// key`).
  static String _generateRandomBase64(int bytes) {
    final random = Random.secure();
    final buffer = Uint8List(bytes);
    for (var i = 0; i < bytes; i++) {
      buffer[i] = random.nextInt(256);
    }
    return base64UrlEncode(buffer);
  }
}
