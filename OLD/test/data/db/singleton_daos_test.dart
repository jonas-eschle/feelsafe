/// Direct DAO tests for the three singleton-backed DAOs:
/// [SettingsDao], [UserProfileDao], and [BatteryAlertDao]. Each
/// wraps exactly one row keyed by `'singleton'`.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/app_database.dart';
import 'package:guardianangela/data/db/daos/battery_alert_dao.dart';
import 'package:guardianangela/data/db/daos/settings_dao.dart';
import 'package:guardianangela/data/db/daos/user_profile_dao.dart';
import 'package:guardianangela/domain/models/models.dart';
import '../../helpers/test_helpers.dart';
import 'dao_test_support.dart';

void main() {
  setUpAll(overrideSqliteOpen);

  late AppDatabase db;

  setUp(() {
    db = makeMemoryDb();
  });

  tearDown(() async {
    await db.close();
  });

  group('SettingsDao', () {
    test('get on empty db returns null', () async {
      check(await SettingsDao(db).get()).isNull();
    });

    test('save + get round-trips the singleton', () async {
      final dao = SettingsDao(db);
      const s = AppSettings(
        defaults: AppDefaults(),
        emergencyCallNumber: '911',
        pinTimeoutSeconds: 25,
      );
      await dao.save(s);
      final read = await dao.get();
      check(read!.emergencyCallNumber).equals('911');
      check(read.pinTimeoutSeconds).equals(25);
    });

    test('save overwrites rather than inserting a second row', () async {
      final dao = SettingsDao(db);
      await dao.save(const AppSettings(defaults: AppDefaults(), pinTimeoutSeconds: 10));
      await dao.save(const AppSettings(defaults: AppDefaults(), pinTimeoutSeconds: 99));
      check((await dao.get())!.pinTimeoutSeconds).equals(99);
    });

    test('clear deletes the singleton row', () async {
      final dao = SettingsDao(db);
      await dao.save(const AppSettings(defaults: AppDefaults()));
      await dao.clear();
      check(await dao.get()).isNull();
    });

    test('clear on empty db is a no-op', () async {
      await SettingsDao(db).clear();
      check(await SettingsDao(db).get()).isNull();
    });
  });

  group('UserProfileDao', () {
    test('get on empty db returns null', () async {
      check(await UserProfileDao(db).get()).isNull();
    });

    test('save + get round-trips', () async {
      final dao = UserProfileDao(db);
      const profile = UserProfile(
        name: 'Alice',
        allergies: 'peanuts',
        medications: 'insulin',
      );
      await dao.save(profile);
      final read = await dao.get();
      check(read!.name).equals('Alice');
      check(read.allergies).equals('peanuts');
      check(read.medications).equals('insulin');
    });

    test('save overwrites the singleton', () async {
      final dao = UserProfileDao(db);
      await dao.save(const UserProfile(name: 'A'));
      await dao.save(const UserProfile(name: 'B'));
      check((await dao.get())!.name).equals('B');
    });

    test('clear removes the profile', () async {
      final dao = UserProfileDao(db);
      await dao.save(const UserProfile(name: 'X'));
      await dao.clear();
      check(await dao.get()).isNull();
    });
  });

  group('BatteryAlertDao', () {
    test('get on empty db returns null', () async {
      check(await BatteryAlertDao(db).get()).isNull();
    });

    test('save + get round-trips threshold + chain', () async {
      final dao = BatteryAlertDao(db);
      final cfg = BatteryAlertConfig(
        enabled: true,
        thresholdPercent: 20,
        chain: [smsStep(order: 0)],
      );
      await dao.save(cfg);
      final read = await dao.get();
      check(read!.enabled).isTrue();
      check(read.thresholdPercent).equals(20);
      check(read.chain.length).equals(1);
    });

    test('save overwrites the singleton', () async {
      final dao = BatteryAlertDao(db);
      await dao.save(const BatteryAlertConfig(thresholdPercent: 10));
      await dao.save(const BatteryAlertConfig(thresholdPercent: 25));
      check((await dao.get())!.thresholdPercent).equals(25);
    });

    test('clear removes the row', () async {
      final dao = BatteryAlertDao(db);
      await dao.save(const BatteryAlertConfig());
      await dao.clear();
      check(await dao.get()).isNull();
    });
  });
}
