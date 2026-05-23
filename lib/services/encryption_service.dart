import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:guardianangela/services/protocols/encryption_service_protocol.dart';

/// The `flutter_secure_storage` key identifier used to persist the
/// AES-256 database key across app launches.
///
/// Changing this identifier renders all existing encrypted data
/// unreadable; bumping requires a nuke-and-reseed (pre-alpha policy).
const String kEncryptionKeyStorageId = 'ga_db_aes_key_v1';

/// Production [EncryptionServiceProtocol] backed by
/// `flutter_secure_storage`.
///
/// Generates and persists a 32-byte (256-bit) AES key on first launch.
/// The key is stored in the Android Keystore / iOS Keychain via
/// `flutter_secure_storage`. The same key drives both the Drift
/// database (via `sqlite3mc` `PRAGMA key`) and the
/// `JsonSingletonRepository` AES-256-GCM envelope.
///
/// **Single constructor location rule:** no `RealEncryptionService()`
/// call may appear outside `lib/services/service_providers.dart`
/// (CI grep enforces).
class RealEncryptionService implements EncryptionServiceProtocol {
  /// Creates a [RealEncryptionService].
  ///
  /// [secureStorage] defaults to a new [FlutterSecureStorage] instance.
  /// Inject a replacement in integration tests; for pure unit tests use
  /// [SimulationEncryptionService] instead.
  RealEncryptionService({FlutterSecureStorage? secureStorage})
    : _storage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  /// In-memory cache to avoid repeated secure-storage reads within one
  /// app session.
  String? _cachedBase64Key;

  @override
  Future<Uint8List> generateKey() async {
    final rng = Random.secure();
    return Uint8List.fromList(List<int>.generate(32, (_) => rng.nextInt(256)));
  }

  @override
  Future<Uint8List?> getKey() async {
    final stored = await _storage.read(key: kEncryptionKeyStorageId);
    if (stored == null) return null;
    return base64.decode(stored);
  }

  @override
  Future<void> saveKey(Uint8List key) async {
    final encoded = base64.encode(key);
    await _storage.write(key: kEncryptionKeyStorageId, value: encoded);
    _cachedBase64Key = encoded;
  }

  @override
  Future<String> getOrCreateKeyAsBase64() async {
    if (_cachedBase64Key != null) return _cachedBase64Key!;

    final stored = await _storage.read(key: kEncryptionKeyStorageId);
    if (stored != null) {
      _cachedBase64Key = stored;
      return stored;
    }

    // First launch — generate, persist, and cache.
    final newKey = await generateKey();
    final encoded = base64.encode(newKey);
    await _storage.write(key: kEncryptionKeyStorageId, value: encoded);
    _cachedBase64Key = encoded;
    return encoded;
  }

  @override
  Future<DatabaseConnection> openEncryptedDatabase(String path) async {
    final base64Key = await getOrCreateKeyAsBase64();
    final rawKey = base64.decode(base64Key);
    // sqlite3mc expects a binary key via: PRAGMA key = "x'<hex>'";
    final hexKey = rawKey
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    final executor = NativeDatabase.createInBackground(
      File(path),
      setup: (db) => db.execute("PRAGMA key = \"x'$hexKey'\";"),
    );
    return DatabaseConnection(executor);
  }
}
