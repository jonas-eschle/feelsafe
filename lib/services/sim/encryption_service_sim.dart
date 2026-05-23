import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'package:guardianangela/services/protocols/encryption_service_protocol.dart';

/// Simulation [EncryptionServiceProtocol] for tests and simulation
/// isolates.
///
/// Uses an in-memory key generated once per instance — never persisted
/// to `flutter_secure_storage`. [openEncryptedDatabase] returns an
/// in-memory `NativeDatabase` so tests never touch the filesystem.
///
/// Safe to construct in any test; never calls [FlutterSecureStorage].
class SimulationEncryptionService implements EncryptionServiceProtocol {
  /// Creates a [SimulationEncryptionService].
  ///
  /// [random] may be injected for deterministic tests; defaults to
  /// [Random.secure()].
  SimulationEncryptionService({Random? random})
    : _random = random ?? Random.secure();

  final Random _random;

  /// In-memory key created lazily on first [getOrCreateKeyAsBase64]
  /// call and reused for the lifetime of this instance.
  Uint8List? _ephemeralKey;

  @override
  Future<Uint8List> generateKey() async =>
      Uint8List.fromList(List<int>.generate(32, (_) => _random.nextInt(256)));

  @override
  Future<Uint8List?> getKey() async => _ephemeralKey;

  @override
  Future<void> saveKey(Uint8List key) async {
    // Store in memory only — never persists to secure storage.
    _ephemeralKey = key;
  }

  @override
  Future<String> getOrCreateKeyAsBase64() async {
    _ephemeralKey ??= await generateKey();
    return base64.encode(_ephemeralKey!);
  }

  @override
  Future<DatabaseConnection> openEncryptedDatabase(String path) async {
    // Returns an in-memory database; the path is intentionally ignored
    // so tests never write encrypted files to disk.
    return DatabaseConnection(NativeDatabase.memory());
  }
}
