/// Tests for [seedFirstLaunchSettings] (spec 06 §Emergency Number precedence).
///
/// Drives the real bootstrap seeding helper against an in-memory fake
/// [AppSettingsRepository] to prove the three-tier precedence:
/// 1. a returning user's persisted value is returned verbatim and is NEVER
///    overwritten (even when it equals the fallback '112');
/// 2. on a genuine first launch the emergency number is seeded from the device
///    region and persisted;
/// 3. an unmapped / region-less locale seeds the '112' fallback.
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/main.dart';

/// An in-memory [AppSettingsRepository] double.
///
/// [stored] is the on-disk value: `null` models a genuine first launch (no
/// file yet). [save] records the persisted value and the number of writes.
class _FakeSettingsRepo implements AppSettingsRepository {
  _FakeSettingsRepo({AppSettings? stored}) : _stored = stored;

  AppSettings? _stored;
  int saveCount = 0;
  AppSettings? lastSaved;

  @override
  Future<AppSettings> load() async => _stored ?? const AppSettings();

  @override
  Future<AppSettings?> loadOrNull() async => _stored;

  @override
  Future<void> save(AppSettings value) async {
    saveCount++;
    lastSaved = value;
    _stored = value;
  }

  @override
  Future<void> delete() async {
    _stored = null;
  }
}

void main() {
  group('first launch (no settings file yet)', () {
    test(
      'seeds the emergency number from the device region and persists',
      () async {
        final repo = _FakeSettingsRepo();
        final settings = await seedFirstLaunchSettings(
          repo,
          deviceLocale: 'en_US',
        );

        check(settings.emergencyCallNumber).equals('911');
        check(repo.saveCount).equals(1);
        check(repo.lastSaved?.emergencyCallNumber).equals('911');
      },
    );

    test('a different region seeds a different number', () async {
      final repo = _FakeSettingsRepo();
      final settings = await seedFirstLaunchSettings(
        repo,
        deviceLocale: 'de_DE',
      );
      check(settings.emergencyCallNumber).equals('110');
    });

    test('an unmapped / region-less locale seeds the 112 fallback', () async {
      final repoUnmapped = _FakeSettingsRepo();
      check(
        (await seedFirstLaunchSettings(
          repoUnmapped,
          deviceLocale: 'xx_ZZ',
        )).emergencyCallNumber,
      ).equals('112');

      final repoNoRegion = _FakeSettingsRepo();
      check(
        (await seedFirstLaunchSettings(
          repoNoRegion,
          deviceLocale: 'en',
        )).emergencyCallNumber,
      ).equals('112');

      final repoEmpty = _FakeSettingsRepo();
      check(
        (await seedFirstLaunchSettings(
          repoEmpty,
          deviceLocale: '',
        )).emergencyCallNumber,
      ).equals('112');
    });

    test('seeded settings preserve the other model defaults', () async {
      final repo = _FakeSettingsRepo();
      final settings = await seedFirstLaunchSettings(
        repo,
        deviceLocale: 'en_GB',
      );
      // The seed factory pre-wires the distress-mode pointer; assert seeding
      // does not strip it.
      check(settings.defaults.defaultDistressModeId).isNotNull();
      check(settings.isFirstLaunch).isTrue();
    });
  });

  group('returning user (settings file present) — precedence tier 1', () {
    test('persisted value wins and is returned verbatim', () async {
      final repo = _FakeSettingsRepo(
        stored: const AppSettings(emergencyCallNumber: '999'),
      );
      final settings = await seedFirstLaunchSettings(
        repo,
        // Device says US (911), but the user already chose 999 — user wins.
        deviceLocale: 'en_US',
      );
      check(settings.emergencyCallNumber).equals('999');
    });

    test('does NOT overwrite — no save occurs for a returning user', () async {
      final repo = _FakeSettingsRepo(
        stored: const AppSettings(emergencyCallNumber: '999'),
      );
      await seedFirstLaunchSettings(repo, deviceLocale: 'de_DE');
      check(repo.saveCount).equals(0);
    });

    test(
      'a user value of 112 is preserved (not re-seeded to the region)',
      () async {
        // Edge: the stored value equals the fallback. It must still be treated
        // as a deliberate user choice — the file exists, so no re-seed. The
        // explicit '112' is the point of the test (it happens to equal the model
        // default, hence the ignore).
        final repo = _FakeSettingsRepo(
          // ignore: avoid_redundant_argument_values
          stored: const AppSettings(emergencyCallNumber: '112'),
        );
        final settings = await seedFirstLaunchSettings(
          repo,
          deviceLocale: 'en_US', // would seed 911 if this were first launch
        );
        check(settings.emergencyCallNumber).equals('112');
        check(repo.saveCount).equals(0);
      },
    );
  });
}
