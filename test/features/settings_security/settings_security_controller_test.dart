import 'dart:io';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:test/test.dart';

import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/features/settings_security/settings_security_controller.dart';
import 'package:guardianangela/services/service_providers.dart';

/// In-memory [AppSettingsRepository] that round-trips through [save]/[load]
/// so a controller setter can be proven to persist (not just mutate state).
class _RoundTripRepo extends AppSettingsRepository {
  _RoundTripRepo([AppSettings? initial])
    : _current = initial ?? const AppSettings(),
      super(
        keyProvider: () async =>
            '0102030405060708090a0b0c0d0e0f'
            '101112131415161718191a1b1c1d1e1f20',
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('sec_ctrl_test_'),
      );

  AppSettings _current;

  @override
  Future<AppSettings> load() async => _current;

  @override
  Future<void> save(AppSettings value) async => _current = value;
}

void main() {
  group('SettingsSecurityController — distress-cancel biometric (#9)', () {
    test(
      'build() reflects the persisted distressCancelBiometricEnabled flag',
      () async {
        final repo = _RoundTripRepo(
          const AppSettings(distressCancelBiometricEnabled: true),
        );
        final container = ProviderContainer(
          overrides: <Override>[
            appSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        );
        addTearDown(container.dispose);

        final state = await container.read(
          settingsSecurityControllerProvider.future,
        );
        check(state.distressCancelBiometricEnabled).isTrue();
      },
    );

    test(
      'setDistressCancelBiometric(true) persists to the repository',
      () async {
        final repo = _RoundTripRepo();
        final container = ProviderContainer(
          overrides: <Override>[
            appSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        );
        addTearDown(container.dispose);

        // Materialise the controller first.
        await container.read(settingsSecurityControllerProvider.future);
        await container
            .read(settingsSecurityControllerProvider.notifier)
            .setDistressCancelBiometric(true);

        // Persisted to the encrypted singleton …
        check((await repo.load()).distressCancelBiometricEnabled).isTrue();
        // … and surfaced through a rebuilt state.
        final state = await container.read(
          settingsSecurityControllerProvider.future,
        );
        check(state.distressCancelBiometricEnabled).isTrue();
      },
    );

    test(
      'toggling distress-cancel biometric leaves sibling flags untouched',
      () async {
        final repo = _RoundTripRepo(
          const AppSettings(
            sessionEndPinBiometricEnabled: true,
            appPinBiometricEnabled: true,
          ),
        );
        final container = ProviderContainer(
          overrides: <Override>[
            appSettingsRepositoryProvider.overrideWithValue(repo),
          ],
        );
        addTearDown(container.dispose);

        await container.read(settingsSecurityControllerProvider.future);
        await container
            .read(settingsSecurityControllerProvider.notifier)
            .setDistressCancelBiometric(true);

        final saved = await repo.load();
        check(saved.distressCancelBiometricEnabled).isTrue();
        check(saved.sessionEndPinBiometricEnabled).isTrue();
        check(saved.appPinBiometricEnabled).isTrue();
      },
    );
  });
}
