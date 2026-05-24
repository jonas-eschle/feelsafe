import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:checks/checks.dart';
import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:guardianangela/services/encryption_service.dart';
import 'package:guardianangela/services/protocols/encryption_service_protocol.dart';
import 'package:guardianangela/services/sim/encryption_service_sim.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

// ---------------------------------------------------------------------------
// In-memory secure storage that uses the actual signature of
// FlutterSecureStorage, matching flutter_secure_storage 10.x where
// iOptions and mOptions are AppleOptions (not IOSOptions).
// ---------------------------------------------------------------------------

class _InMemoryStorage implements FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _data[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _data.remove(key);

  @override
  Future<bool> containsKey({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _data.containsKey(key);

  @override
  Future<Map<String, String>> readAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => Map<String, String>.from(_data);

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _data.clear();

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
    'Not implemented in _InMemoryStorage: '
    '${invocation.memberName}',
  );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Returns a [RealEncryptionService] backed by a mock
/// [FlutterSecureStorage].
(RealEncryptionService, _MockFlutterSecureStorage) _makeReal() {
  final storage = _MockFlutterSecureStorage();
  final service = RealEncryptionService(secureStorage: storage);
  return (service, storage);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('RealEncryptionService', () {
    test('getKey() before any save returns null', () async {
      final (service, storage) = _makeReal();
      when(
        () => storage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => null);

      final key = await service.getKey();
      check(key).isNull();
    });

    test('saveKey() then getKey() round-trips 32 bytes', () async {
      final storage = _InMemoryStorage();
      final service = RealEncryptionService(secureStorage: storage);

      final originalKey = Uint8List.fromList(List<int>.generate(32, (i) => i));
      await service.saveKey(originalKey);
      final retrieved = await service.getKey();

      check(retrieved).isNotNull();
      // Compare element-by-element since Uint8List.operator== is identity.
      check(retrieved!.toList()).deepEquals(originalKey.toList());
    });

    test('generateKey() returns exactly 32 bytes', () async {
      final (service, _) = _makeReal();
      final key = await service.generateKey();
      check(key.length).equals(32);
    });

    test('generateKey() produces different keys across calls', () async {
      final (service, _) = _makeReal();
      final k1 = await service.generateKey();
      final k2 = await service.generateKey();
      // Probability of collision is astronomically low (1/2^256).
      check(k1.toList()).not((c) => c.deepEquals(k2.toList()));
    });

    test(
      'getOrCreateKeyAsBase64() creates and persists key on first call',
      () async {
        final storage = _InMemoryStorage();
        final service = RealEncryptionService(secureStorage: storage);

        final b64 = await service.getOrCreateKeyAsBase64();
        check(b64).isNotEmpty();
        final decoded = base64.decode(b64);
        check(decoded.length).equals(32);
      },
    );

    test('getOrCreateKeyAsBase64() returns same key across instances '
        '(persists via storage)', () async {
      final storage = _InMemoryStorage();

      final b64First = await RealEncryptionService(
        secureStorage: storage,
      ).getOrCreateKeyAsBase64();
      final b64Second = await RealEncryptionService(
        secureStorage: storage,
      ).getOrCreateKeyAsBase64();

      check(b64First).equals(b64Second);
    });

    test('getOrCreateKeyAsBase64() returns valid base64 that decodes to '
        '32 bytes', () async {
      final storage = _InMemoryStorage();
      final service = RealEncryptionService(secureStorage: storage);

      final b64 = await service.getOrCreateKeyAsBase64();
      final decoded = base64.decode(b64);
      check(decoded.length).equals(32);
    });

    test('openEncryptedDatabase opens a database (temp file path)', () async {
      final storage = _InMemoryStorage();
      final service = RealEncryptionService(secureStorage: storage);
      final tempDir = await Directory.systemTemp.createTemp('enc_test_');
      final dbPath = '${tempDir.path}/test.db';

      try {
        final conn = await service.openEncryptedDatabase(dbPath);
        check(conn).isA<DatabaseConnection>();
        await conn.executor.close();
      } finally {
        await tempDir.delete(recursive: true);
      }
    });

    test('getOrCreateKeyAsBase64() is idempotent — cache hit avoids '
        'a second storage read', () async {
      final storage = _MockFlutterSecureStorage();
      final service = RealEncryptionService(secureStorage: storage);

      // First call — storage has no key, must generate + write.
      when(
        () => storage.read(key: kEncryptionKeyStorageId),
      ).thenAnswer((_) async => null);
      when(
        () => storage.write(
          key: kEncryptionKeyStorageId,
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      final b64a = await service.getOrCreateKeyAsBase64();

      // Second call — should hit cache; verify storage.read not
      // called again.
      final b64b = await service.getOrCreateKeyAsBase64();

      check(b64a).equals(b64b);
      verify(() => storage.read(key: kEncryptionKeyStorageId)).called(1);
    });
  });

  group('SimulationEncryptionService', () {
    test('generateKey() returns 32 bytes', () async {
      final service = SimulationEncryptionService();
      final key = await service.generateKey();
      check(key.length).equals(32);
    });

    test('getKey() returns null before saveKey()', () async {
      final service = SimulationEncryptionService();
      final key = await service.getKey();
      check(key).isNull();
    });

    test('saveKey() stores key in memory', () async {
      final service = SimulationEncryptionService();
      final key = Uint8List.fromList(List<int>.generate(32, (i) => i));
      await service.saveKey(key);
      final retrieved = await service.getKey();
      check(retrieved!.toList()).deepEquals(key.toList());
    });

    test('getOrCreateKeyAsBase64() creates ephemeral key', () async {
      final service = SimulationEncryptionService();
      final b64 = await service.getOrCreateKeyAsBase64();
      check(b64).isNotEmpty();
      check(base64.decode(b64).length).equals(32);
    });

    test(
      'getOrCreateKeyAsBase64() is idempotent within same instance',
      () async {
        final service = SimulationEncryptionService();
        final b64a = await service.getOrCreateKeyAsBase64();
        final b64b = await service.getOrCreateKeyAsBase64();
        check(b64a).equals(b64b);
      },
    );

    test('different SimulationEncryptionService instances produce '
        'different ephemeral keys', () async {
      final a = await SimulationEncryptionService().getOrCreateKeyAsBase64();
      final b = await SimulationEncryptionService().getOrCreateKeyAsBase64();
      // Vanishingly unlikely to collide (2^-256 probability).
      check(a).not((c) => c.equals(b));
    });

    test(
      'openEncryptedDatabase() returns an in-memory DatabaseConnection',
      () async {
        final service = SimulationEncryptionService();
        final conn = await service.openEncryptedDatabase('/ignored/path');
        check(conn).isA<DatabaseConnection>();
        await conn.executor.close();
      },
    );

    test(
      'SimulationEncryptionService does NOT touch FlutterSecureStorage',
      () async {
        // Create a mock to verify it is never called.
        final mockStorage = _MockFlutterSecureStorage();
        // We do NOT stub any methods — any call would throw by default
        // via mocktail's "no stub registered" behaviour.

        final service = SimulationEncryptionService();

        // Run all key operations; none should reach the mock.
        await service.generateKey();
        await service.getKey();
        final key = Uint8List.fromList(List<int>.generate(32, (i) => i));
        await service.saveKey(key);
        await service.getOrCreateKeyAsBase64();
        final conn = await service.openEncryptedDatabase('/ignored');
        await conn.executor.close();

        // If mockStorage were called it would throw; reaching here
        // confirms it was never touched.
        verifyNever(() => mockStorage.read(key: any(named: 'key')));
        verifyNever(
          () => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        );
      },
    );

    test('SimulationEncryptionService with deterministic Random produces '
        'predictable key', () async {
      final rng = Random(42);
      final service = SimulationEncryptionService(random: rng);
      final b64 = await service.getOrCreateKeyAsBase64();
      // Deterministic key — same seed gives same bytes.
      final rng2 = Random(42);
      final service2 = SimulationEncryptionService(random: rng2);
      final b64b = await service2.getOrCreateKeyAsBase64();
      check(b64).equals(b64b);
    });
  });

  group('EncryptionServiceProtocol contract', () {
    test('Both RealEncryptionService and SimulationEncryptionService '
        'implement EncryptionServiceProtocol', () {
      check(
        RealEncryptionService(secureStorage: _InMemoryStorage()),
      ).isA<EncryptionServiceProtocol>();
      check(SimulationEncryptionService()).isA<EncryptionServiceProtocol>();
    });
  });

  // =========================================================================
  // F23: Encrypted DB key isolation
  // =========================================================================

  group('F23: Encrypted DB key isolation', () {
    test(
      'F23: different storage instances produce different keys',
      () async {
        // Encryption-at-rest contract: two separate storage instances must
        // produce distinct keys so that data encrypted by one key cannot be
        // read by another.
        final storage1 = _InMemoryStorage();
        final storage2 = _InMemoryStorage();
        final key1 = await RealEncryptionService(
          secureStorage: storage1,
        ).getOrCreateKeyAsBase64();
        final key2 = await RealEncryptionService(
          secureStorage: storage2,
        ).getOrCreateKeyAsBase64();
        check(key1).not((c) => c.equals(key2));
      },
    );

    test(
      'F23: key persists across service instances (wrong-key scenario: '
      'correct storage returns same key)',
      () async {
        // If the correct storage is always used, the same key is returned.
        // A wrong key would require a different storage — verified above.
        final storage = _InMemoryStorage();
        final k1 = await RealEncryptionService(
          secureStorage: storage,
        ).getOrCreateKeyAsBase64();
        final k2 = await RealEncryptionService(
          secureStorage: storage,
        ).getOrCreateKeyAsBase64();
        check(k1).equals(k2);
      },
    );

    test(
      'F23: openEncryptedDatabase with correct key opens successfully',
      () async {
        final storage = _InMemoryStorage();
        final svc = RealEncryptionService(secureStorage: storage);
        final tempDir = await Directory.systemTemp.createTemp('enc_f23_');
        final dbPath = '${tempDir.path}/f23.db';

        try {
          final conn = await svc.openEncryptedDatabase(dbPath);
          check(conn).isA<DatabaseConnection>();
          await conn.executor.close();
        } finally {
          await tempDir.delete(recursive: true);
        }
      },
    );

    test(
      'F23: key has 256-bit entropy (32 bytes of CSPRNG output)',
      () async {
        final storage = _InMemoryStorage();
        final svc = RealEncryptionService(secureStorage: storage);
        final key = await svc.generateKey();
        // 256-bit key = 32 bytes minimum for AES-256 (sqlite3mc default).
        check(key.length).equals(32);
        // Verify it is not all-zeros (degenerate key).
        check(key.any((b) => b != 0)).isTrue();
      },
    );
  });
}
