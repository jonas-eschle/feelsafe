import 'dart:io';

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/repositories/battery_alert_config_repository.dart';
import 'package:guardianangela/data/seed_data.dart';
import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/sms_contact_selection.dart';
import 'package:guardianangela/domain/models/battery_alert_config.dart';
import 'package:guardianangela/domain/models/chain_step.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('battery_alert_repo_test_');
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  BatteryAlertConfigRepository newRepo() => BatteryAlertConfigRepository(
    keyProvider: () async =>
        '0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20',
    resolveDir: () async => tempDir,
  );

  group('BatteryAlertConfigRepository', () {
    test('load returns the seeded default when no file exists', () async {
      check(
        await newRepo().load(),
      ).equals(SeedData.defaultBatteryAlertConfig());
    });

    test('loadOrNull returns null when no file exists', () async {
      check(await newRepo().loadOrNull()).isNull();
    });

    test('round-trips the seeded default', () async {
      // Arrange
      final repo = newRepo();
      final defaults = SeedData.defaultBatteryAlertConfig();
      // Act
      await repo.save(defaults);
      // Assert
      check(await repo.load()).equals(defaults);
    });

    test('round-trips a customised chain (enabled + custom step)', () async {
      // Arrange
      final repo = newRepo();
      final custom = BatteryAlertConfig(
        enabled: true,
        thresholdPercent: 25,
        chain: [
          ChainStep(
            id: 'bat-0',
            type: ChainStepType.smsContact,
            order: 0,
            waitSeconds: 0,
            durationSeconds: 15,
            gracePeriodSeconds: 0,
            retryCount: 0,
            randomize: false,
            config: const SmsContactConfig(
              contactSelection: SmsContactSelection.firstContact,
            ),
          ),
          ChainStep(
            id: 'bat-1',
            type: ChainStepType.callEmergency,
            order: 1,
            waitSeconds: 5,
            durationSeconds: 5,
            gracePeriodSeconds: 0,
            retryCount: 0,
            randomize: false,
          ),
        ],
      );
      // Act
      await repo.save(custom);
      final loaded = await repo.load();
      // Assert
      check(loaded).equals(custom);
      check(loaded.enabled).isTrue();
      check(loaded.thresholdPercent).equals(25);
      check(loaded.chain.length).equals(2);
    });

    test('delete removes the file', () async {
      // Arrange
      final repo = newRepo();
      await repo.save(SeedData.defaultBatteryAlertConfig());
      // Act
      await repo.delete();
      // Assert
      check(await repo.loadOrNull()).isNull();
    });
  });
}
