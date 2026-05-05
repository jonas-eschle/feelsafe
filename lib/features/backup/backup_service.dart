/// Backup export / import service.
///
/// Produces a self-describing JSON bundle (optionally PIN-encrypted)
/// that captures every persistent entity. Per D-BACKUP-1, the
/// payload is versioned and pre-alpha break-compat: importing a
/// `version` that does not exactly match [kBackupVersion] throws
/// [BackupVersionError]. No migrations — nuke-and-reseed only.
///
/// ## Encryption
///
/// When the caller passes a non-empty `pin`, the payload body is
/// encrypted with a **CTR-like stream cipher** built on top of the
/// pub packages already in `pubspec.yaml` (`crypto` + `crypt`):
///
/// 1. A random 16-byte salt is drawn for the PBKDF2 key-derivation
///    (HMAC-SHA256, 100 000 iterations → 64-byte output).
/// 2. The first 32 bytes seed the **encryption key**; the next 32
///    seed the **MAC key** (independent keys for AEAD hygiene).
/// 3. A random 12-byte nonce is drawn.
/// 4. The keystream is `SHA256(encKey ‖ nonce ‖ counter)` repeated;
///    plaintext is XORed with the stream.
/// 5. The ciphertext is authenticated with `HMAC-SHA256(macKey,
///    salt ‖ nonce ‖ ciphertext)` — encrypt-then-MAC.
///
/// This is **not AES-GCM** — Flutter's stdlib has no AES primitive
/// and we declined to pull `package:encrypt` for one feature in a
/// pre-alpha. The construction above is sound modulo the absence of
/// AES's hardware acceleration: it is a textbook authenticated
/// stream cipher with per-backup keys. v1.1 may promote to AES-GCM
/// via `package:cryptography`; tagged TODO below.
///
/// TODO(Phase 15.1): swap CTR+HMAC for AES-256-GCM via
/// `package:cryptography` once the dep-review process approves it.
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'package:guardianangela/data/repositories/battery_alert_repository.dart';
import 'package:guardianangela/data/repositories/contacts_repository.dart';
import 'package:guardianangela/data/repositories/distress_chains_repository.dart';
import 'package:guardianangela/data/repositories/modes_repository.dart';
import 'package:guardianangela/data/repositories/session_logs_repository.dart';
import 'package:guardianangela/data/repositories/settings_repository.dart';
import 'package:guardianangela/data/repositories/templates_repository.dart';
import 'package:guardianangela/data/repositories/user_profile_repository.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/battery_alert_config.dart';
import 'package:guardianangela/domain/models/distress_chain.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/reminder_template.dart';
import 'package:guardianangela/domain/models/session_log.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/user_profile.dart';

/// Canonical backup-format version. Incompatible changes MUST bump
/// this and break-compat — no migration stubs in pre-alpha.
const int kBackupVersion = 1;

const int _saltLength = 16;
const int _nonceLength = 12;
const int _pbkdf2Iterations = 100000;
const int _pbkdf2DerivedLength = 64; // 32 enc-key + 32 mac-key

/// Thrown when a backup payload's `version` does not match
/// [kBackupVersion].
class BackupVersionError implements Exception {
  /// Creates a version-mismatch error.
  const BackupVersionError(this.found);

  /// The offending `version` read from the payload.
  final Object? found;

  @override
  String toString() =>
      'BackupVersionError: expected version $kBackupVersion, got $found';
}

/// Thrown when a PIN-encrypted bundle fails authentication (wrong
/// PIN or tampered payload).
class BackupAuthenticationError implements Exception {
  /// Creates an auth-failure error.
  const BackupAuthenticationError();

  @override
  String toString() =>
      'BackupAuthenticationError: wrong PIN or payload tampered with.';
}

/// Thrown when a PIN-encrypted bundle is missing required encryption
/// metadata (salt / nonce / tag / ciphertext).
class BackupFormatError implements Exception {
  /// Creates a format error.
  const BackupFormatError(this.reason);

  /// Human-readable reason.
  final String reason;

  @override
  String toString() => 'BackupFormatError: $reason';
}

/// Per-element export selection — a value object passed by the
/// [BackupScreen] toggles to the export pipeline (D5).
///
/// `settings` is intentionally always-true: the export bundle MUST
/// remain self-restorable. The toggle on the screen is rendered
/// disabled to make this contract visible to the user.
class BackupSelection {
  /// Creates a selection. Every flag defaults to true (the
  /// "everything" preset matches the legacy export behavior).
  const BackupSelection({
    this.contacts = true,
    this.modes = true,
    this.distressModes = true,
    this.templates = true,
    this.sessionLogs = true,
    this.recordings = true,
  });

  /// The "include everything" preset (legacy behaviour).
  static const BackupSelection all = BackupSelection();

  /// Whether to include `EmergencyContact`s.
  final bool contacts;

  /// Whether to include user-facing modes (the regular ones — the
  /// ones whose ids are NOT referenced as a distress mode).
  final bool modes;

  /// Whether to include distress-flagged modes.
  final bool distressModes;

  /// Whether to include reminder templates.
  final bool templates;

  /// Whether to include `SessionLog` history.
  final bool sessionLogs;

  /// Whether to include audio-evidence recordings.
  final bool recordings;

  /// Returns a new selection with the given flags replaced.
  BackupSelection copyWith({
    bool? contacts,
    bool? modes,
    bool? distressModes,
    bool? templates,
    bool? sessionLogs,
    bool? recordings,
  }) => BackupSelection(
    contacts: contacts ?? this.contacts,
    modes: modes ?? this.modes,
    distressModes: distressModes ?? this.distressModes,
    templates: templates ?? this.templates,
    sessionLogs: sessionLogs ?? this.sessionLogs,
    recordings: recordings ?? this.recordings,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackupSelection &&
          other.contacts == contacts &&
          other.modes == modes &&
          other.distressModes == distressModes &&
          other.templates == templates &&
          other.sessionLogs == sessionLogs &&
          other.recordings == recordings;

  @override
  int get hashCode => Object.hash(
    contacts,
    modes,
    distressModes,
    templates,
    sessionLogs,
    recordings,
  );

  @override
  String toString() =>
      'BackupSelection(contacts: $contacts, modes: $modes, '
      'distressModes: $distressModes, templates: $templates, '
      'sessionLogs: $sessionLogs, recordings: $recordings)';
}

/// Export / import service for the full app backup bundle.
final class BackupService {
  /// Creates a backup service.
  ///
  /// [random] defaults to `Random.secure()`. Tests pass a seeded
  /// `Random` for deterministic nonce / salt generation.
  BackupService({
    required ModesRepository modesRepository,
    required ContactsRepository contactsRepository,
    required TemplatesRepository templatesRepository,
    required DistressChainsRepository distressChainsRepository,
    required SettingsRepository settingsRepository,
    required UserProfileRepository userProfileRepository,
    required BatteryAlertRepository batteryAlertRepository,
    required SessionLogsRepository sessionLogsRepository,
    Random? random,
  }) : _modes = modesRepository,
       _contacts = contactsRepository,
       _templates = templatesRepository,
       _distressChains = distressChainsRepository,
       _settings = settingsRepository,
       _userProfile = userProfileRepository,
       _batteryAlert = batteryAlertRepository,
       _sessionLogs = sessionLogsRepository,
       _random = random ?? Random.secure();

  final ModesRepository _modes;
  final ContactsRepository _contacts;
  final TemplatesRepository _templates;
  final DistressChainsRepository _distressChains;
  final SettingsRepository _settings;
  final UserProfileRepository _userProfile;
  final BatteryAlertRepository _batteryAlert;
  final SessionLogsRepository _sessionLogs;
  final Random _random;

  /// Exports every persistent entity.
  ///
  /// Returns a top-level JSON-compatible map. When [pin] is non-null
  /// and non-empty, the inner `body` is encrypted via the CTR+HMAC
  /// construction documented at the top of this file; the returned
  /// map then carries `{version, exportedAt, encrypted: true, salt,
  /// nonce, tag, ciphertext}`. Otherwise the map carries `{version,
  /// exportedAt, encrypted: false, ...sections}`.
  ///
  /// [selection] — per-element opt-out (D5). Defaults to
  /// [BackupSelection.all]. `selection.settings` is always honoured:
  /// the bundle must remain self-restorable.
  Future<Map<String, Object?>> exportAll({
    String? pin,
    BackupSelection selection = BackupSelection.all,
  }) async {
    // Per D5 (backup toggles), the user opts out of individual
    // sections via [selection]. `settings` is always exported.
    final allModes = await _modes.getAll();
    final settings = await _settings.get();
    final distressIds = _resolveDistressModeIds(allModes, settings);
    final filteredModes = allModes.where((m) {
      final isDistress = distressIds.contains(m.id);
      return isDistress ? selection.distressModes : selection.modes;
    });

    final sections = <String, Object?>{
      'modes': filteredModes.map((m) => m.toJson()).toList(),
      'contacts': selection.contacts
          ? (await _contacts.getAll()).map((c) => c.toJson()).toList()
          : const <Map<String, Object?>>[],
      'templates': selection.templates
          ? (await _templates.getAll()).map((t) => t.toJson()).toList()
          : const <Map<String, Object?>>[],
      'distressChains': (await _distressChains.getAll())
          .map((d) => d.toJson())
          .toList(),
      'settings': settings?.toJson(),
      'userProfile': (await _userProfile.get())?.toJson(),
      'batteryAlertConfig': (await _batteryAlert.get())?.toJson(),
      'sessionLogs': selection.sessionLogs
          ? (await _sessionLogs.getAll()).map((s) => s.toJson()).toList()
          : const <Map<String, Object?>>[],
      // `recordings` is deferred — once recordings become persisted
      // entities the list goes here. Exposing the empty list keeps
      // the round-trip stable.
      'recordings': const <Map<String, Object?>>[],
      'selection': {
        'contacts': selection.contacts,
        'modes': selection.modes,
        'distressModes': selection.distressModes,
        'templates': selection.templates,
        'sessionLogs': selection.sessionLogs,
        'recordings': selection.recordings,
      },
    };
    final header = <String, Object?>{
      'version': kBackupVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
    };
    if (pin == null || pin.isEmpty) {
      return {...header, 'encrypted': false, ...sections};
    }
    final encrypted = _encryptBody(jsonEncode(sections), pin);
    return {
      ...header,
      'encrypted': true,
      'salt': base64Encode(encrypted.salt),
      'nonce': base64Encode(encrypted.nonce),
      'tag': base64Encode(encrypted.tag),
      'ciphertext': base64Encode(encrypted.ciphertext),
    };
  }

  /// Imports a previously-exported bundle, replacing every persistent
  /// entity.
  ///
  /// Throws [BackupVersionError] on version mismatch,
  /// [BackupAuthenticationError] on wrong PIN, [BackupFormatError] on
  /// missing / malformed encryption fields. On success every
  /// repository is nuked and re-seeded from [payload].
  Future<void> importAll(Map<String, Object?> payload, {String? pin}) async {
    final rawVersion = payload['version'];
    if (rawVersion is! int || rawVersion != kBackupVersion) {
      throw BackupVersionError(rawVersion);
    }
    final sections = payload['encrypted'] == true
        ? _decryptPayload(payload, pin)
        : payload;
    await _restoreFrom(sections);
  }

  Future<void> _restoreFrom(Map<String, Object?> sections) async {
    await _modes.deleteAll();
    await _contacts.deleteAll();
    await _templates.deleteAll();
    await _distressChains.deleteAll();
    await _sessionLogs.deleteAll();

    for (final raw in _listOf(sections['modes']).cast<Map<String, Object?>>()) {
      await _modes.save(SessionMode.fromJson(raw));
    }
    for (final raw in _listOf(
      sections['contacts'],
    ).cast<Map<String, Object?>>()) {
      await _contacts.save(EmergencyContact.fromJson(raw));
    }
    for (final raw in _listOf(
      sections['templates'],
    ).cast<Map<String, Object?>>()) {
      await _templates.save(ReminderTemplate.fromJson(raw));
    }
    for (final raw in _listOf(
      sections['distressChains'],
    ).cast<Map<String, Object?>>()) {
      await _distressChains.save(DistressChain.fromJson(raw));
    }
    for (final raw in _listOf(
      sections['sessionLogs'],
    ).cast<Map<String, Object?>>()) {
      await _sessionLogs.save(SessionLog.fromJson(raw));
    }
    final settings = sections['settings'];
    if (settings is Map<String, Object?>) {
      await _settings.save(AppSettings.fromJson(settings));
    }
    final userProfile = sections['userProfile'];
    if (userProfile is Map<String, Object?>) {
      await _userProfile.save(UserProfile.fromJson(userProfile));
    }
    final batteryAlert = sections['batteryAlertConfig'];
    if (batteryAlert is Map<String, Object?>) {
      await _batteryAlert.save(BatteryAlertConfig.fromJson(batteryAlert));
    }
  }

  List<Object?> _listOf(Object? raw) => raw is List ? raw : const [];

  /// Returns the set of mode-ids that are referenced as a distress
  /// mode by any saved mode's `distressModeId`.
  ///
  /// *Why this heuristic:* a "distress mode" in the current codebase
  /// is structurally a `SessionMode` whose id is referenced from
  /// another mode's `distressModeId` field. Once the Q52 unification
  /// lands and `SessionMode.isDistressMode` exists, this helper can
  /// be replaced with `m.isDistressMode == true`.
  Set<String> _resolveDistressModeIds(
    Iterable<SessionMode> allModes,
    AppSettings? settings,
  ) {
    final ids = <String>{};
    for (final m in allModes) {
      final id = m.distressModeId;
      if (id != null && id.isNotEmpty) ids.add(id);
    }
    return ids;
  }

  _EncryptedBlob _encryptBody(String plaintext, String pin) {
    final salt = _randomBytes(_saltLength);
    final nonce = _randomBytes(_nonceLength);
    final derived = _pbkdf2(pin, salt, _pbkdf2Iterations, _pbkdf2DerivedLength);
    final encKey = derived.sublist(0, 32);
    final macKey = derived.sublist(32, 64);
    final plaintextBytes = utf8.encode(plaintext);
    final ciphertext = _xorKeystream(
      Uint8List.fromList(plaintextBytes),
      encKey,
      nonce,
    );
    final tag = _mac(macKey, salt, nonce, ciphertext);
    return _EncryptedBlob(
      salt: salt,
      nonce: nonce,
      ciphertext: ciphertext,
      tag: tag,
    );
  }

  Map<String, Object?> _decryptPayload(
    Map<String, Object?> payload,
    String? pin,
  ) {
    if (pin == null || pin.isEmpty) {
      throw const BackupFormatError('PIN required for encrypted bundle.');
    }
    final salt = _base64Field(payload, 'salt');
    final nonce = _base64Field(payload, 'nonce');
    final tag = _base64Field(payload, 'tag');
    final ciphertext = _base64Field(payload, 'ciphertext');
    final derived = _pbkdf2(pin, salt, _pbkdf2Iterations, _pbkdf2DerivedLength);
    final encKey = derived.sublist(0, 32);
    final macKey = derived.sublist(32, 64);
    final expected = _mac(macKey, salt, nonce, ciphertext);
    if (!_constantTimeEquals(expected, tag)) {
      throw const BackupAuthenticationError();
    }
    final plaintext = _xorKeystream(ciphertext, encKey, nonce);
    final decoded = jsonDecode(utf8.decode(plaintext)) as Map<String, Object?>;
    return decoded;
  }

  Uint8List _base64Field(Map<String, Object?> payload, String key) {
    final raw = payload[key];
    if (raw is! String) {
      throw BackupFormatError('Missing or non-string field "$key".');
    }
    try {
      return base64Decode(raw);
    } on FormatException {
      throw BackupFormatError('Field "$key" is not valid base64.');
    }
  }

  Uint8List _randomBytes(int length) {
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return bytes;
  }

  /// PBKDF2-HMAC-SHA256.
  ///
  /// Implemented locally (RFC 2898) so we do not pull another pub
  /// package. 100k iterations is the PBKDF2 floor recommended by
  /// OWASP 2023 for SHA-256.
  Uint8List _pbkdf2(
    String password,
    Uint8List salt,
    int iterations,
    int outputLength,
  ) {
    final hmac = Hmac(sha256, utf8.encode(password));
    final blocks = (outputLength + 31) ~/ 32;
    final output = Uint8List(outputLength);
    for (var block = 1; block <= blocks; block++) {
      final saltBlock = Uint8List(salt.length + 4)
        ..setRange(0, salt.length, salt)
        ..[salt.length] = (block >> 24) & 0xff
        ..[salt.length + 1] = (block >> 16) & 0xff
        ..[salt.length + 2] = (block >> 8) & 0xff
        ..[salt.length + 3] = block & 0xff;
      var u = Uint8List.fromList(hmac.convert(saltBlock).bytes);
      final t = Uint8List.fromList(u);
      for (var iter = 1; iter < iterations; iter++) {
        u = Uint8List.fromList(hmac.convert(u).bytes);
        for (var i = 0; i < t.length; i++) {
          t[i] ^= u[i];
        }
      }
      final offset = (block - 1) * 32;
      final copyLen = (offset + 32 > outputLength) ? outputLength - offset : 32;
      output.setRange(offset, offset + copyLen, t);
    }
    return output;
  }

  /// Stream cipher: keystream block k = SHA-256(encKey ‖ nonce ‖
  /// counter). XOR into input. Symmetric — same call decrypts.
  Uint8List _xorKeystream(Uint8List input, Uint8List encKey, Uint8List nonce) {
    final output = Uint8List(input.length);
    var counter = 0;
    var offset = 0;
    while (offset < input.length) {
      final counterBytes = Uint8List(4)
        ..[0] = (counter >> 24) & 0xff
        ..[1] = (counter >> 16) & 0xff
        ..[2] = (counter >> 8) & 0xff
        ..[3] = counter & 0xff;
      final block = sha256.convert([
        ...encKey,
        ...nonce,
        ...counterBytes,
      ]).bytes;
      final blockLen = (offset + block.length > input.length)
          ? input.length - offset
          : block.length;
      for (var i = 0; i < blockLen; i++) {
        output[offset + i] = input[offset + i] ^ block[i];
      }
      offset += blockLen;
      counter += 1;
    }
    return output;
  }

  Uint8List _mac(
    Uint8List macKey,
    Uint8List salt,
    Uint8List nonce,
    Uint8List ciphertext,
  ) {
    final hmac = Hmac(sha256, macKey);
    final input = Uint8List(salt.length + nonce.length + ciphertext.length)
      ..setRange(0, salt.length, salt)
      ..setRange(salt.length, salt.length + nonce.length, nonce)
      ..setRange(
        salt.length + nonce.length,
        salt.length + nonce.length + ciphertext.length,
        ciphertext,
      );
    return Uint8List.fromList(hmac.convert(input).bytes);
  }

  bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}

/// Internal container for the four opaque fields of an encrypted
/// payload. Exposed via `base64` on the outer JSON map.
class _EncryptedBlob {
  _EncryptedBlob({
    required this.salt,
    required this.nonce,
    required this.ciphertext,
    required this.tag,
  });

  final Uint8List salt;
  final Uint8List nonce;
  final Uint8List ciphertext;
  final Uint8List tag;
}
