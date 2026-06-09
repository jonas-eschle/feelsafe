// JSON singleton repository tests.
//
// Uses an injected temp directory and a fixed 32-byte AES key so the
// tests are fully deterministic and do not touch
// `getApplicationDocumentsDirectory()`.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:guardianangela/data/repositories/json_singleton_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

    test('load fails when the on-disk envelope was written with a '
        'different key', () async {
      // Arrange — write with key A.
      final writer = repo(
        keyOverride:
            'a0a1a2a3a4a5a6a7a8a9aaabacadaeaf'
            'b0b1b2b3b4b5b6b7b8b9babbbcbdbebf',
      );
      await writer.save({'plain': 'text'});
      // Act — read with key B (same 32-byte length, different bytes).
      final reader = repo(
        keyOverride:
            'c0c1c2c3c4c5c6c7c8c9cacbcccdcecf'
            'd0d1d2d3d4d5d6d7d8d9dadbdcdddedf',
      );
      // Assert — pointycastle raises InvalidCipherTextException ⊂ Exception
      // when the GCM tag check fails. We accept any Object throw so the
      // test is independent of which exact subclass pointycastle uses,
      // but verify the load did NOT silently return plaintext or null.
      await check(reader.load()).throws<Object>();
    });

    test('load fails when the ciphertext bytes are tampered with', () async {
      // Arrange — save a value then corrupt one byte of the ciphertext.
      final r = repo();
      await r.save({'kept': 'safe'});
      final file = File(p.join(tempDir.path, 'thing.json'));
      final envelope =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final ctBytes = base64Decode(envelope['ct'] as String);
      // Flip a single bit in the middle of the ciphertext (avoids the
      // 16-byte GCM tag suffix on the off-chance the flip lands there;
      // either way GCM detects the mismatch).
      ctBytes[ctBytes.length ~/ 2] ^= 0x01;
      envelope['ct'] = base64Encode(ctBytes);
      await file.writeAsString(jsonEncode(envelope));
      // Act + Assert — GCM tag mismatch surfaces as a throw, never as
      // a silently-corrupted decryption.
      await check(r.load()).throws<Object>();
    });
  });

  // -------------------------------------------------------------------------
  // C6b: the DEFAULT resolveDir (path_provider-backed) — the other tests
  // inject resolveDir; here we exercise _defaultResolveDir + the
  // save() dir-creation branch against a mocked path_provider channel.
  // -------------------------------------------------------------------------
  group('JsonSingletonRepository — default resolveDir (path_provider)', () {
    late Directory docsDir;

    setUp(() async {
      docsDir = await Directory.systemTemp.createTemp('ga_docs_');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (call) async => call.method == 'getApplicationDocumentsDirectory'
                ? docsDir.path
                : null,
          );
    });

    tearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            null,
          );
      await docsDir.delete(recursive: true);
    });

    test('save creates the json_store dir under documents and round-trips '
        'via the default resolver', () async {
      final r = JsonSingletonRepository<Map<String, dynamic>>(
        fileName: 'pref.json',
        fromJson: (j) => j,
        toJson: (v) => v,
        keyProvider: () async => fixedHexKey(),
        random: _SeededRandom(7),
        // resolveDir intentionally omitted → _defaultResolveDir runs.
      );
      await r.save({'hello': 'world'});
      // The json_store subdir was created under the mocked documents dir.
      check(
        Directory(p.join(docsDir.path, 'json_store')).existsSync(),
      ).isTrue();
      check(await r.load()).isNotNull().deepEquals({'hello': 'world'});
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
