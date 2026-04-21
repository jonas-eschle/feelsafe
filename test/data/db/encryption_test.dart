/// Tests for [EncryptionKey] using a fake `FlutterSecureStorage`.
library;

import 'package:checks/checks.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/encryption.dart';

/// Minimal in-memory fake of [FlutterSecureStorage] sufficient for
/// [EncryptionKey] — wraps a Dart `Map` and supports read/write/delete.
class _FakeSecureStorage implements FlutterSecureStorage {
  final Map<String, String> backing = {};

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
      backing.remove(key);
    } else {
      backing[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => backing[key];

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    backing.remove(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('EncryptionKey.load', () {
    test('generates and persists a fresh key on first call', () async {
      final storage = _FakeSecureStorage();
      final key = await EncryptionKey.load(storage: storage);
      check(key).isNotEmpty();
      // Exactly one entry should have been written.
      check(storage.backing.length).equals(1);
      check(storage.backing.values.first).equals(key);
    });

    test('returns the existing key on subsequent calls', () async {
      final storage = _FakeSecureStorage();
      final first = await EncryptionKey.load(storage: storage);
      final second = await EncryptionKey.load(storage: storage);
      check(second).equals(first);
    });

    test(
      'two fresh storages produce different keys (randomness)',
      () async {
        final a = await EncryptionKey.load(storage: _FakeSecureStorage());
        final b = await EncryptionKey.load(storage: _FakeSecureStorage());
        check(a).not((it) => it.equals(b));
      },
    );

    test('generated key is base64 URL-safe of 32 bytes', () async {
      final key = await EncryptionKey.load(storage: _FakeSecureStorage());
      // URL-safe base64 uses `-_` not `+/` and has no padding mandatory.
      check(key.contains('+')).isFalse();
      check(key.contains('/')).isFalse();
      // 32 raw bytes encode to 44 chars (with padding) or ~43 without.
      check(key.length >= 43).isTrue();
    });
  });

  group('EncryptionKey.reset', () {
    test('clears the persisted key', () async {
      final storage = _FakeSecureStorage();
      final original = await EncryptionKey.load(storage: storage);
      check(storage.backing.length).equals(1);
      await EncryptionKey.reset(storage: storage);
      check(storage.backing).isEmpty();
      // A subsequent load generates a new key.
      final regenerated = await EncryptionKey.load(storage: storage);
      check(regenerated).not((it) => it.equals(original));
    });

    test('reset on an empty storage is a no-op', () async {
      final storage = _FakeSecureStorage();
      await EncryptionKey.reset(storage: storage);
      check(storage.backing).isEmpty();
    });
  });
}
