// simulation_swap_test.dart
//
// Verifies that every Real*Service registered in service_providers.dart
// has a simulation override path: when a ProviderContainer is built with
// the relevant provider overridden with a Simulation* impl, reading the
// protocol-typed provider returns the simulation impl.
//
// Phase 5A coverage: EncryptionService + all three JSON repos.
// Stage 5B.1 adds: vibration, wakelock, flash, screenFlash, recording,
//   contact, audio.

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/sim/audio_service_sim.dart';
import 'package:guardianangela/services/sim/contact_service_sim.dart';
import 'package:guardianangela/services/sim/encryption_service_sim.dart';
import 'package:guardianangela/services/sim/flash_service_sim.dart';
import 'package:guardianangela/services/sim/recording_service_sim.dart';
import 'package:guardianangela/services/sim/screen_flash_service_sim.dart';
import 'package:guardianangela/services/sim/vibration_service_sim.dart';
import 'package:guardianangela/services/sim/wakelock_service_sim.dart';

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

  // -----------------------------------------------------------------------
  // Stage 5B.1 — 7 leaf service simulation swaps
  // -----------------------------------------------------------------------

  group('Simulation swap — VibrationService', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          vibrationServiceProvider.overrideWithValue(
            SimulationVibrationService(),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('overridden container returns SimulationVibrationService', () {
      final s = container.read(vibrationServiceProvider);
      check(s).isA<SimulationVibrationService>();
    });

    test('overridden container is NOT RealVibrationService', () {
      final s = container.read(vibrationServiceProvider);
      check(
        s.runtimeType.toString(),
      ).not((c) => c.equals('RealVibrationService'));
    });
  });

  group('Simulation swap — WakelockService', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          wakelockServiceProvider.overrideWithValue(
            SimulationWakelockService(),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('overridden container returns SimulationWakelockService', () {
      final s = container.read(wakelockServiceProvider);
      check(s).isA<SimulationWakelockService>();
    });

    test('simulation wakelock starts disabled', () {
      final s = container.read(wakelockServiceProvider) as SimulationWakelockService;
      check(s.isEnabled).isFalse();
    });
  });

  group('Simulation swap — FlashService', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          flashServiceProvider.overrideWithValue(SimulationFlashService()),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('overridden container returns SimulationFlashService', () {
      final s = container.read(flashServiceProvider);
      check(s).isA<SimulationFlashService>();
    });

    test('simulation flash starts not flashing', () {
      final s =
          container.read(flashServiceProvider) as SimulationFlashService;
      check(s.isFlashing).isFalse();
    });
  });

  group('Simulation swap — ScreenFlashService', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          screenFlashServiceProvider.overrideWithValue(
            SimulationScreenFlashService(),
          ),
        ],
      );
    });

    tearDown(() {
      (container.read(screenFlashServiceProvider)
              as SimulationScreenFlashService)
          .dispose();
      container.dispose();
    });

    test('overridden container returns SimulationScreenFlashService', () {
      final s = container.read(screenFlashServiceProvider);
      check(s).isA<SimulationScreenFlashService>();
    });
  });

  group('Simulation swap — RecordingService', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          recordingServiceProvider.overrideWithValue(
            SimulationRecordingService(),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('overridden container returns SimulationRecordingService', () {
      final s = container.read(recordingServiceProvider);
      check(s).isA<SimulationRecordingService>();
    });

    test('simulation recording starts with empty calls', () {
      final s =
          container.read(recordingServiceProvider) as SimulationRecordingService;
      check(s.calls).isEmpty();
    });
  });

  group('Simulation swap — ContactService', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          contactServiceProvider.overrideWithValue(
            SimulationContactService(),
          ),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('overridden container returns SimulationContactService', () {
      final s = container.read(contactServiceProvider);
      check(s).isA<SimulationContactService>();
    });

    test('simulation contact service starts with empty list', () {
      final s =
          container.read(contactServiceProvider) as SimulationContactService;
      check(s.all).isEmpty();
    });
  });

  group('Simulation swap — AudioService', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          audioServiceProvider.overrideWithValue(SimulationAudioService()),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('overridden container returns SimulationAudioService', () {
      final s = container.read(audioServiceProvider);
      check(s).isA<SimulationAudioService>();
    });

    test('simulation audio starts with empty calls', () {
      final s =
          container.read(audioServiceProvider) as SimulationAudioService;
      check(s.calls).isEmpty();
    });
  });
}
