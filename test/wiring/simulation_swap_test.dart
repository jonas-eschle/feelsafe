// simulation_swap_test.dart
//
// Verifies that every Real*Service registered in service_providers.dart
// has a simulation override path: when a ProviderContainer is built with
// encryptionServiceProvider overridden with SimulationEncryptionService,
// reading the protocol-typed providers returns the simulation impl (or a
// service backed by the simulation encryption key — never the real
// FlutterSecureStorage).
//
// Phase 5A coverage: EncryptionService + all three JSON repos.
// Stages 5B/5C extend this test as more Real*Service constructors land.

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/sim/encryption_service_sim.dart';

void main() {
  group('Simulation swap — EncryptionService', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          encryptionServiceProvider.overrideWithValue(
            SimulationEncryptionService(),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('encryptionServiceProvider returns SimulationEncryptionService '
        'when overridden', () {
      final service = container.read(encryptionServiceProvider);
      check(service).isA<SimulationEncryptionService>();
    });

    test('encryptionServiceProvider override is NOT RealEncryptionService', () {
      final service = container.read(encryptionServiceProvider);
      check(
        service.runtimeType.toString(),
      ).not((c) => c.equals('RealEncryptionService'));
    });

    test(
      'keyProviderProvider uses the simulation encryption service '
      '(returns a callable that produces a key without secure storage)',
      () async {
        final keyProvider = container.read(keyProviderProvider);
        // If the provider were backed by RealEncryptionService this
        // would try to read FlutterSecureStorage and fail in a unit
        // test environment.
        final key = await keyProvider();
        check(key).isNotEmpty();
      },
    );

    test('appSettingsRepositoryProvider resolves to an AppSettingsRepository '
        'with the simulation encryption key', () {
      // Just check the provider resolves without error. Actual
      // load() calls require path_provider; that is tested in
      // test/services/json_repos_wiring_test.dart which provides
      // a temp-dir override.
      final repo = container.read(appSettingsRepositoryProvider);
      check(repo.runtimeType.toString()).equals('AppSettingsRepository');
    });

    test(
      'userProfileRepositoryProvider resolves to a UserProfileRepository',
      () {
        final repo = container.read(userProfileRepositoryProvider);
        check(repo.runtimeType.toString()).equals('UserProfileRepository');
      },
    );

    test('batteryAlertConfigRepositoryProvider resolves to a '
        'BatteryAlertConfigRepository', () {
      final repo = container.read(batteryAlertConfigRepositoryProvider);
      check(repo.runtimeType.toString()).equals('BatteryAlertConfigRepository');
    });
  });

  group('Simulation swap — invariant: no Real*Service outside override', () {
    test('Default container (no overrides) uses RealEncryptionService', () {
      // This test verifies the DEFAULT wiring is Real* so that the
      // override swap above is non-trivial (we are actually swapping
      // something, not just reading the same impl).
      //
      // The RealEncryptionService constructor is safe to call here
      // because it only touches FlutterSecureStorage in async
      // operations (getKey / saveKey / getOrCreateKeyAsBase64),
      // not in the constructor itself.
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final service = c.read(encryptionServiceProvider);
      check(service.runtimeType.toString()).equals('RealEncryptionService');
    });
  });
}
