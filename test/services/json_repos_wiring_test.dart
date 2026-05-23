// json_repos_wiring_test.dart
//
// Verifies that the JSON singleton repositories are properly wired to
// the SimulationEncryptionService via the Riverpod provider graph, and
// that the on-disk data is encrypted (never plain-text JSON).

import 'dart:convert';
import 'dart:io';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/services/protocols/encryption_service_protocol.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/sim/encryption_service_sim.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds an [AppSettingsRepository] that writes into [tempDir], keyed
/// by [enc].
AppSettingsRepository _makeRepoWithTempDir(
  Directory tempDir,
  EncryptionServiceProtocol enc,
) => AppSettingsRepository(
  keyProvider: enc.getOrCreateKeyAsBase64,
  resolveDir: () async => tempDir,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late Directory tempDir;
  late ProviderContainer container;
  late SimulationEncryptionService simEnc;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('json_wiring_test_');
    simEnc = SimulationEncryptionService();
    container = ProviderContainer(
      overrides: [encryptionServiceProvider.overrideWithValue(simEnc)],
    );
  });

  tearDown(() async {
    container.dispose();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('JSON repos wiring — provider graph with simulation encryption', () {
    test('appSettingsRepositoryProvider resolves without error through a '
        'simulation ProviderContainer', () {
      // Just verify the provider resolves to the correct type; actual
      // load() requires path_provider which isn't available in unit
      // tests. The round-trip load is tested below using an injected
      // temp-dir repository.
      final repo = container.read(appSettingsRepositoryProvider);
      check(repo.runtimeType.toString()).equals('AppSettingsRepository');
    });

    test('save + reload round-trips AppSettings through the simulation '
        'encryption key', () async {
      final repo = _makeRepoWithTempDir(tempDir, simEnc);
      const original = AppSettings(selectedModeId: 'walk_mode_seed');
      await repo.save(original);
      final loaded = await repo.load();
      check(loaded.selectedModeId).equals('walk_mode_seed');
    });

    test(
      'on-disk file is encrypted — raw bytes are NOT plain-text JSON',
      () async {
        final repo = _makeRepoWithTempDir(tempDir, simEnc);
        const settings = AppSettings(selectedModeId: 'test_id');
        await repo.save(settings);

        // Find the written file.
        final files = tempDir
            .listSync(recursive: true)
            .whereType<File>()
            .toList();
        check(files).isNotEmpty();

        final rawString = utf8.decode(
          files.first.readAsBytesSync(),
          allowMalformed: true,
        );

        // The file must contain the AES-GCM envelope markers, not
        // plain JSON like `{"selectedModeId":"test_id"...}`.
        check(rawString).contains('"v":1');
        check(rawString).contains('"nonce"');
        check(rawString).contains('"ct"');

        // The plain-text secret must NOT appear in the file.
        check(rawString).not((c) => c.contains('"test_id"'));
      },
    );

    test('encrypted file is unreadable with a different key — '
        'loading with wrong key throws', () async {
      // Write with key A.
      final encA = SimulationEncryptionService();
      final repoA = _makeRepoWithTempDir(tempDir, encA);
      await repoA.save(const AppSettings(selectedModeId: 'secret'));

      // Attempt to read with key B (different ephemeral key).
      final encB = SimulationEncryptionService();
      final repoB = _makeRepoWithTempDir(tempDir, encB);

      await check(repoB.loadOrNull()).throws<Object>();
    });
  });
}
