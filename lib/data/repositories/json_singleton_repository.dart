import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/export.dart' as pc;

/// Signature for resolving the AES-256 key used to encrypt the JSON
/// envelope.
///
/// The Phase 5 wiring resolves this to a [Future<String>] backed by
/// `flutter_secure_storage`. Tests inject a fixed key. The string MUST
/// decode to exactly 32 raw bytes (base64-encoded or hex-encoded).
typedef KeyProvider = Future<String> Function();

/// Signature for resolving the directory under which JSON blobs are
/// written. Defaults to `<app-documents>/json_store`. Tests override
/// this to a temp directory.
typedef DirectoryResolver = Future<Directory> Function();

/// A small encrypted-on-disk JSON blob repository.
///
/// Each instance owns a single file under [resolveDir]; the body is
/// wrapped in an AES-256-GCM envelope keyed by [keyProvider]. The
/// plain-text JSON never touches disk.
///
/// Envelope on-disk JSON shape:
/// ```json
/// {
///   "v": 1,
///   "nonce": "<base64 12-byte nonce>",
///   "ct": "<base64 ciphertext + 16-byte GCM tag>"
/// }
/// ```
///
/// See spec 03 §Storage Architecture / §Encryption & Security.
class JsonSingletonRepository<T> {
  /// Creates a repository that round-trips a single value of type [T].
  ///
  /// [fileName] is the filename under [resolveDir]; it MUST NOT include
  /// directory separators. [fromJson] / [toJson] handle serialisation.
  /// [keyProvider] returns the 32-byte AES key (base64 or hex encoded).
  /// [resolveDir] defaults to `<app-documents>/json_store`; tests
  /// override it to a temp directory. [random] defaults to
  /// `Random.secure()`; tests inject a deterministic implementation.
  JsonSingletonRepository({
    required String fileName,
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(T) toJson,
    required KeyProvider keyProvider,
    DirectoryResolver? resolveDir,
    Random? random,
  }) : assert(
         fileName.isNotEmpty,
         'JsonSingletonRepository.fileName must be non-empty',
       ),
       assert(
         !fileName.contains('/') && !fileName.contains(r'\'),
         'JsonSingletonRepository.fileName must not contain path '
         'separators',
       ),
       _fileName = fileName,
       _fromJson = fromJson,
       _toJson = toJson,
       _keyProvider = keyProvider,
       _resolveDir = resolveDir ?? _defaultResolveDir,
       _random = random ?? Random.secure();

  final String _fileName;
  final T Function(Map<String, dynamic>) _fromJson;
  final Map<String, dynamic> Function(T) _toJson;
  final KeyProvider _keyProvider;
  final DirectoryResolver _resolveDir;
  final Random _random;

  static const int _envelopeVersion = 1;
  static const int _nonceBytes = 12;
  static const int _gcmTagBytes = 16;
  static const int _keyBytes = 32;

  /// Returns the deserialised value, or null if the file does not exist.
  ///
  /// Throws [FormatException] if the envelope or its JSON body is
  /// corrupt, [ArgumentError] if the key length is wrong, and rethrows
  /// any sqlite3mc / pointycastle errors.
  Future<T?> load() async {
    final file = await _file();
    if (!file.existsSync()) {
      return null;
    }
    final envelopeBytes = await file.readAsBytes();
    final envelope =
        jsonDecode(utf8.decode(envelopeBytes)) as Map<String, dynamic>;
    final version = envelope['v'] as int;
    if (version != _envelopeVersion) {
      throw FormatException(
        'JsonSingletonRepository: unknown envelope version $version '
        '(expected $_envelopeVersion).',
      );
    }
    final nonce = base64Decode(envelope['nonce'] as String);
    final ciphertext = base64Decode(envelope['ct'] as String);
    final plaintext = _decrypt(
      key: await _resolveKey(),
      nonce: nonce,
      ciphertext: ciphertext,
    );
    final jsonMap = jsonDecode(utf8.decode(plaintext)) as Map<String, dynamic>;
    return _fromJson(jsonMap);
  }

  /// Encrypts and writes [value] to disk, replacing any prior content.
  ///
  /// Writes are atomic: data is staged to `<file>.tmp` and renamed into
  /// place. Throws [ArgumentError] if the key length is wrong.
  Future<void> save(T value) async {
    final file = await _file();
    final plaintext = utf8.encode(jsonEncode(_toJson(value)));
    final nonce = Uint8List(_nonceBytes);
    for (var i = 0; i < _nonceBytes; i++) {
      nonce[i] = _random.nextInt(256);
    }
    final ciphertext = _encrypt(
      key: await _resolveKey(),
      nonce: nonce,
      plaintext: Uint8List.fromList(plaintext),
    );
    final envelope = <String, dynamic>{
      'v': _envelopeVersion,
      'nonce': base64Encode(nonce),
      'ct': base64Encode(ciphertext),
    };
    final dir = file.parent;
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(jsonEncode(envelope), flush: true);
    await tmp.rename(file.path);
  }

  /// Deletes the file from disk if it exists. No-op otherwise.
  Future<void> delete() async {
    final file = await _file();
    if (file.existsSync()) {
      await file.delete();
    }
  }

  Future<File> _file() async {
    final dir = await _resolveDir();
    return File(p.join(dir.path, _fileName));
  }

  Future<Uint8List> _resolveKey() async {
    final raw = await _keyProvider();
    final bytes = _decodeKey(raw);
    if (bytes.length != _keyBytes) {
      throw ArgumentError.value(
        bytes.length,
        'encryptionKey length',
        'must decode to exactly $_keyBytes bytes for AES-256-GCM '
            '(spec 03 §Encryption & Security).',
      );
    }
    return bytes;
  }

  static Uint8List _decodeKey(String raw) {
    // Accept base64 (44 chars w/ padding) OR hex (64 chars).
    if (raw.length == _keyBytes * 2 &&
        RegExp(r'^[0-9a-fA-F]+$').hasMatch(raw)) {
      final out = Uint8List(_keyBytes);
      for (var i = 0; i < _keyBytes; i++) {
        out[i] = int.parse(raw.substring(i * 2, i * 2 + 2), radix: 16);
      }
      return out;
    }
    return base64Decode(raw);
  }

  Uint8List _encrypt({
    required Uint8List key,
    required Uint8List nonce,
    required Uint8List plaintext,
  }) {
    final cipher = pc.GCMBlockCipher(pc.AESEngine())
      ..init(
        true,
        pc.AEADParameters(
          pc.KeyParameter(key),
          _gcmTagBytes * 8,
          nonce,
          Uint8List(0),
        ),
      );
    return cipher.process(plaintext);
  }

  Uint8List _decrypt({
    required Uint8List key,
    required Uint8List nonce,
    required Uint8List ciphertext,
  }) {
    final cipher = pc.GCMBlockCipher(pc.AESEngine())
      ..init(
        false,
        pc.AEADParameters(
          pc.KeyParameter(key),
          _gcmTagBytes * 8,
          nonce,
          Uint8List(0),
        ),
      );
    return cipher.process(ciphertext);
  }

  static Future<Directory> _defaultResolveDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'json_store'));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }
}
