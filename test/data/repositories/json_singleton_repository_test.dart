// JSON singleton repository tests.
//
// Uses an injected temp directory and a fixed 32-byte AES key so the
// tests are fully deterministic and do not touch
// `getApplicationDocumentsDirectory()`.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:checks/checks.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:guardianangela/data/repositories/json_singleton_repository.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'json_singleton_repo_test_',
    );
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  String fixedHexKey() =>
      '0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20';

  JsonSingletonRepository<Map<String, dynamic>> repo({
    String fileName = 'thing.json',
    Random? random,
    String? keyOverride,
  }) => JsonSingletonRepository<Map<String, dynamic>>(
    fileName: fileName,
    fromJson: (j) => j,
    toJson: (v) => v,
    keyProvider: () async => keyOverride ?? fixedHexKey(),
    resolveDir: () async => tempDir,
    random: random ?? _SeededRandom(42),
  );

  group('JsonSingletonRepository', () {
    test('load returns null when the file does not exist', () async {
      final r = repo();
      check(await r.load()).isNull();
    });

    test('save then load round-trips a POJO', () async {
      // Arrange
      final r = repo();
      final value = {'a': 1, 'b': 'two', 'c': true};
      // Act
      await r.save(value);
      final fetched = await r.load();
      // Assert
      check(fetched).isNotNull().deepEquals(value);
    });

    test('on-disk bytes are NOT the plaintext JSON', () async {
      // Arrange
      final r = repo();
      const secret = 'super_secret_string_marker';
      await r.save({'k': secret});
      // Act
      final file = File(p.join(tempDir.path, 'thing.json'));
      final bytes = await file.readAsBytes();
      final decodedAsString = utf8.decode(bytes);
      // Assert — the envelope is JSON but contains base64 fields only.
      check(decodedAsString.contains(secret)).isFalse();
      final envelope = jsonDecode(decodedAsString) as Map<String, dynamic>;
      check(envelope.keys.toSet()).deepEquals({'v', 'nonce', 'ct'});
      check(envelope['v']).equals(1);
    });

    test('delete removes the file', () async {
      // Arrange
      final r = repo();
      await r.save({'a': 1});
      final file = File(p.join(tempDir.path, 'thing.json'));
      check(file.existsSync()).isTrue();
      // Act
      await r.delete();
      // Assert
      check(file.existsSync()).isFalse();
    });

    test('delete is a no-op when the file does not exist', () async {
      // Act + Assert (no throw).
      await repo().delete();
    });

    test('overwriting save replaces the previous envelope', () async {
      // Arrange — two distinct values.
      final r = repo();
      await r.save({'gen': 1, 'value': 'old'});
      // Act
      await r.save({'gen': 2, 'value': 'new'});
      // Assert
      check(await r.load()).isNotNull().deepEquals({'gen': 2, 'value': 'new'});
    });

    test('rejects keys that do not decode to 32 bytes', () async {
      // Arrange — 16-byte (AES-128) key supplied; we require AES-256.
      final r = repo(keyOverride: '00112233445566778899aabbccddeeff');
      // Act + Assert
      await check(r.save({'a': 1})).throws<ArgumentError>();
    });

    test('rejects file names containing path separators', () {
      check(
        () => JsonSingletonRepository<Map<String, dynamic>>(
          fileName: 'sub/foo.json',
          fromJson: (j) => j,
          toJson: (v) => v,
          keyProvider: () async => fixedHexKey(),
        ),
      ).throws<AssertionError>();
    });

    test(
      'rejects an envelope written with a different version number',
      () async {
        // Arrange — manually write a v=99 envelope.
        final file = File(p.join(tempDir.path, 'thing.json'));
        await file.writeAsString(
          jsonEncode({
            'v': 99,
            'nonce': base64Encode(List<int>.filled(12, 0)),
            'ct': base64Encode(List<int>.filled(16, 0)),
          }),
        );
        // Act + Assert
        await check(repo().load()).throws<FormatException>();
      },
    );

    test('accepts a base64-encoded 32-byte key as well as hex', () async {
      // Arrange — base64 of 32 zero bytes.
      final r = repo(keyOverride: base64Encode(List<int>.filled(32, 7)));
      // Act
      await r.save({'a': 'b'});
      // Assert
      check(await r.load()).isNotNull().deepEquals({'a': 'b'});
    });
  });
}

/// Deterministic `Random` for nonce generation in tests.
final class _SeededRandom implements Random {
  _SeededRandom(int seed) : _r = Random(seed);
  final Random _r;
  @override
  bool nextBool() => _r.nextBool();
  @override
  double nextDouble() => _r.nextDouble();
  @override
  int nextInt(int max) => _r.nextInt(max);
}
