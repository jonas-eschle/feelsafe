import 'package:drift/drift.dart';

/// Abstract interface for AES-256 key lifecycle management.
///
/// See spec 05 §EncryptionService. Manages the key stored in
/// `flutter_secure_storage` (Android Keystore / iOS Keychain) and
/// opens the `sqlite3mc`-backed Drift database with that key.
///
/// Both the Drift database and the JSON-backed singleton repositories
/// are always encrypted using the same key — there is no opt-out
/// (spec 05 §EncryptionService §Always Encrypted).
abstract interface class EncryptionServiceProtocol {
  /// Generates a cryptographically secure 256-bit (32-byte) AES key.
  ///
  /// Uses a CSPRNG (`Random.secure()`) — never derived from a
  /// password. Does NOT persist the key; callers must call [saveKey]
  /// separately.
  Future<Uint8List> generateKey();

  /// Retrieves the persisted key from `flutter_secure_storage`.
  ///
  /// Returns `null` if no key has been saved yet (first launch before
  /// [saveKey] is called).
  Future<Uint8List?> getKey();

  /// Stores [key] in `flutter_secure_storage` under the app's
  /// canonical key identifier (`ga_db_aes_key_v1`).
  Future<void> saveKey(Uint8List key);

  /// Returns the encryption key as a base64 string, creating and
  /// persisting one if none exists yet.
  ///
  /// This is the [KeyProvider] signature consumed by
  /// [JsonSingletonRepository] and [GuardianAngelaDatabase.open].
  /// Subsequent calls return the same key (idempotent).
  Future<String> getOrCreateKeyAsBase64();

  /// Opens the Drift database at [path] with the stored AES-256 key.
  ///
  /// Applies `PRAGMA key = 'x'<hex>''` via the sqlite3mc cipher before
  /// any read or write. See spec 05 §EncryptionService
  /// §Database Encryption.
  Future<DatabaseConnection> openEncryptedDatabase(String path);
}
