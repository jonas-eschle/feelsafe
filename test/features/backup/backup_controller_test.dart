/// Tests for [BackupController] — export/import happy paths with
/// in-memory fakes plus error propagation from [BackupService].
library;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/domain/models/models.dart';
import 'package:guardianangela/features/backup/backup_controller.dart';
import 'package:guardianangela/features/backup/backup_service.dart';

import '../../helpers/test_helpers.dart';
import '../fake_repositories.dart';

ProviderContainer _makeContainer({
  List<SessionMode> modes = const [],
  List<EmergencyContact> contacts = const [],
  List<DistressChain> chains = const [],
  AppSettings? settings,
}) {
  return ProviderContainer(
    overrides: [
      modesRepositoryProvider
          .overrideWithValue(FakeModesRepository(modes)),
      contactsRepositoryProvider
          .overrideWithValue(FakeContactsRepository(contacts)),
      templatesRepositoryProvider
          .overrideWithValue(FakeTemplatesRepository()),
      distressChainsRepositoryProvider.overrideWithValue(
          FakeDistressChainsRepository(chains)),
      settingsRepositoryProvider
          .overrideWithValue(FakeSettingsRepository(settings)),
      userProfileRepositoryProvider
          .overrideWithValue(FakeUserProfileRepository()),
      batteryAlertRepositoryProvider
          .overrideWithValue(FakeBatteryAlertRepository()),
      sessionLogsRepositoryProvider
          .overrideWithValue(FakeSessionLogsRepository()),
    ],
  );
}

void main() {
  group('BackupController.build', () {
    test('returns null initially', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final v = await container.read(backupControllerProvider.future);
      check(v).isNull();
    });
  });

  group('BackupController.exportAll', () {
    test('exports plaintext payload with version header', () async {
      final container = _makeContainer(
        modes: [makeMode(id: 'mode-1', name: 'M')],
        contacts: [makeContact(id: 'c1', name: 'Alice')],
      );
      addTearDown(container.dispose);
      final notifier = container.read(backupControllerProvider.notifier);
      await container.read(backupControllerProvider.future);
      final payload = await notifier.exportAll();
      check(payload['version']).equals(kBackupVersion);
      check(payload['encrypted']).equals(false);
      check(payload['modes']).isA<List<Object?>>();
    });

    test('export with PIN produces encrypted envelope', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(backupControllerProvider.notifier);
      await container.read(backupControllerProvider.future);
      final payload = await notifier.exportAll(pin: 'secret');
      check(payload['encrypted']).equals(true);
      check(payload.containsKey('ciphertext')).isTrue();
      check(payload.containsKey('salt')).isTrue();
      check(payload.containsKey('nonce')).isTrue();
      check(payload.containsKey('tag')).isTrue();
    });

    test('exportAll pushes data into controller state', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(backupControllerProvider.notifier);
      await container.read(backupControllerProvider.future);
      await notifier.exportAll();
      final s = container.read(backupControllerProvider).value;
      check(s).isNotNull();
    });
  });

  group('BackupController.importAll', () {
    test('round-trip restores modes', () async {
      // Export from one container.
      final exportContainer = _makeContainer(
        modes: [makeMode(id: 'mode-1', name: 'M1')],
      );
      addTearDown(exportContainer.dispose);
      final exportNotifier =
          exportContainer.read(backupControllerProvider.notifier);
      await exportContainer.read(backupControllerProvider.future);
      final payload = await exportNotifier.exportAll();

      // Import into a fresh container.
      final importContainer = _makeContainer();
      addTearDown(importContainer.dispose);
      final importNotifier =
          importContainer.read(backupControllerProvider.notifier);
      await importContainer.read(backupControllerProvider.future);
      await importNotifier.importAll(payload);
      final repo =
          importContainer.read(modesRepositoryProvider);
      final modes = await repo.getAll();
      check(modes.length).equals(1);
      check(modes.single.id).equals('mode-1');
    });

    test('rejects unknown version with BackupVersionError', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(backupControllerProvider.notifier);
      await container.read(backupControllerProvider.future);
      await check(
        notifier.importAll({'version': 999, 'encrypted': false}),
      ).throws<BackupVersionError>();
    });

    test('wrong PIN throws BackupAuthenticationError', () async {
      final exportContainer = _makeContainer();
      addTearDown(exportContainer.dispose);
      final exportNotifier =
          exportContainer.read(backupControllerProvider.notifier);
      await exportContainer.read(backupControllerProvider.future);
      final payload =
          await exportNotifier.exportAll(pin: 'right-pin');

      final importContainer = _makeContainer();
      addTearDown(importContainer.dispose);
      final importNotifier =
          importContainer.read(backupControllerProvider.notifier);
      await importContainer.read(backupControllerProvider.future);
      await check(
        importNotifier.importAll(payload, pin: 'wrong-pin'),
      ).throws<BackupAuthenticationError>();
    });
  });
}
