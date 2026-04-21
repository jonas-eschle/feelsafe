/// Tests for [BatteryAlertController] — singleton hydrate + field
/// setters.
library;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/battery_alert/battery_alert_controller.dart';

import '../../helpers/test_helpers.dart';
import '../fake_repositories.dart';

ProviderContainer _makeContainer({BatteryAlertConfig? seed}) {
  final repo = FakeBatteryAlertRepository(seed);
  return ProviderContainer(
    overrides: [batteryAlertRepositoryProvider.overrideWithValue(repo)],
  );
}

void main() {
  group('BatteryAlertController.build', () {
    test('returns default BatteryAlertConfig when repo empty', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final cfg = await container.read(batteryAlertControllerProvider.future);
      check(cfg.enabled).isTrue();
      check(cfg.thresholdPercent).equals(15);
      check(cfg.chain).isEmpty();
    });

    test('hydrates persisted config', () async {
      final seed = const BatteryAlertConfig(
        enabled: false,
        thresholdPercent: 5,
      );
      final container = _makeContainer(seed: seed);
      addTearDown(container.dispose);
      final cfg = await container.read(batteryAlertControllerProvider.future);
      check(cfg.enabled).isFalse();
      check(cfg.thresholdPercent).equals(5);
    });
  });

  group('BatteryAlertController setters', () {
    test('save overwrites config', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier =
          container.read(batteryAlertControllerProvider.notifier);
      await container.read(batteryAlertControllerProvider.future);
      await notifier.save(const BatteryAlertConfig(thresholdPercent: 20));
      final cfg = container.read(batteryAlertControllerProvider).value!;
      check(cfg.thresholdPercent).equals(20);
    });

    test('enable sets enabled=true', () async {
      final container = _makeContainer(
        seed: const BatteryAlertConfig(enabled: false),
      );
      addTearDown(container.dispose);
      final notifier =
          container.read(batteryAlertControllerProvider.notifier);
      await container.read(batteryAlertControllerProvider.future);
      await notifier.enable();
      final cfg = container.read(batteryAlertControllerProvider).value!;
      check(cfg.enabled).isTrue();
    });

    test('disable sets enabled=false', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier =
          container.read(batteryAlertControllerProvider.notifier);
      await container.read(batteryAlertControllerProvider.future);
      await notifier.disable();
      final cfg = container.read(batteryAlertControllerProvider).value!;
      check(cfg.enabled).isFalse();
    });

    test('setChain replaces chain steps', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier =
          container.read(batteryAlertControllerProvider.notifier);
      await container.read(batteryAlertControllerProvider.future);
      await notifier.setChain([smsStep(order: 0)]);
      final cfg = container.read(batteryAlertControllerProvider).value!;
      check(cfg.chain.length).equals(1);
    });

    test('setThresholdPercent updates threshold', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier =
          container.read(batteryAlertControllerProvider.notifier);
      await container.read(batteryAlertControllerProvider.future);
      await notifier.setThresholdPercent(42);
      final cfg = container.read(batteryAlertControllerProvider).value!;
      check(cfg.thresholdPercent).equals(42);
    });
  });
}
