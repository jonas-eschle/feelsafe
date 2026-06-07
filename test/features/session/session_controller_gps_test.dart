/// Tests verifying that SessionController wires GPS breadcrumb logging into
/// the session lifecycle (#22).
///
/// Covers (spec 06 §GPS Logging):
///   - A real session with GPS logging enabled starts tracking and requests
///     permission; ending the session stops tracking and clears history.
///   - A mode override with `gpsLogging.enabled == false` skips tracking.
///   - A simulation session never tracks (geolocator is real hardware).
///
/// These drive the REAL SessionController + SessionEngine (host-level proof
/// for pure lifecycle wiring) with a [SimulationLocationService] swapped in so
/// no platform channel is touched.
library;

import 'dart:io';

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/data/repositories/user_profile_repository.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/gps_logging_config.dart';
import 'package:guardianangela/domain/models/location_point.dart';
import 'package:guardianangela/domain/models/mode_overrides.dart';
import 'package:guardianangela/domain/models/session_context.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/user_profile.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/session_log_recorder.dart';
import 'package:guardianangela/services/sim/audio_service_sim.dart';
import 'package:guardianangela/services/sim/call_state_service_sim.dart';
import 'package:guardianangela/services/sim/contact_service_sim.dart';
import 'package:guardianangela/services/sim/flash_service_sim.dart';
import 'package:guardianangela/services/sim/home_widget_service_sim.dart';
import 'package:guardianangela/services/sim/location_service_sim.dart';
import 'package:guardianangela/services/sim/messaging_service_sim.dart';
import 'package:guardianangela/services/sim/notification_service_sim.dart';
import 'package:guardianangela/services/sim/phone_service_sim.dart';
import 'package:guardianangela/services/sim/recording_service_sim.dart';
import 'package:guardianangela/services/sim/screen_flash_service_sim.dart';
import 'package:guardianangela/services/sim/system_ui_service_sim.dart';
import 'package:guardianangela/services/sim/vibration_service_sim.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _FakeAppSettingsRepository extends AppSettingsRepository {
  _FakeAppSettingsRepository()
    : super(
        keyProvider: () async =>
            '0102030405060708090a0b0c0d0e0f'
            '101112131415161718191a1b1c1d1e1f20',
        resolveDir: () async =>
            Directory.systemTemp.createTempSync('gps_test_'),
      );

  @override
  Future<AppSettings> load() async => const AppSettings();
}

class _FakeUserProfileRepository extends UserProfileRepository {
  _FakeUserProfileRepository() : super(keyProvider: _k);

  static Future<String> _k() async => '00' * 32;

  @override
  Future<UserProfile> load() async => const UserProfile();
}

/// Minimal hold-button mode: the engine sits in its wait phase without firing
/// any real action, so GPS-tracking state can be observed in isolation.
/// An optional [gps] override exercises the mode-level GpsLoggingConfig path.
SessionMode _gpsMode({GpsLoggingConfig? gps}) => SessionMode(
  id: 'gps-mode',
  name: 'GPS Test',
  overrides: gps == null ? null : ModeOverrides(gpsLogging: gps),
  chainSteps: <ChainStep>[
    ChainStep(
      id: 'gps-hold-0',
      type: ChainStepType.holdButton,
      order: 0,
      waitSeconds: 30,
      durationSeconds: 30,
      gracePeriodSeconds: 5,
      retryCount: 1,
      randomize: false,
    ),
  ],
);

// ─── Container builder ────────────────────────────────────────────────────────

ProviderContainer _container(
  GuardianAngelaDatabase db,
  SimulationLocationService location,
) {
  final container = ProviderContainer(
    overrides: [
      appSettingsRepositoryProvider.overrideWithValue(
        _FakeAppSettingsRepository(),
      ),
      userProfileRepositoryProvider.overrideWithValue(
        _FakeUserProfileRepository(),
      ),
      databaseProvider.overrideWith((ref) async => db),
      systemUiServiceProvider.overrideWithValue(SimulationSystemUiService()),
      homeWidgetServiceProvider.overrideWithValue(
        SimulationHomeWidgetService(),
      ),
      sessionLogRecorderProvider.overrideWith((ref) async {
        final repo = await ref.watch(sessionLogRepositoryProvider.future);
        return (SessionContext ctx) =>
            SimulationSessionLogRecorder(context: ctx, repo: repo);
      }),
      vibrationServiceProvider.overrideWithValue(SimulationVibrationService()),
      flashServiceProvider.overrideWithValue(SimulationFlashService()),
      screenFlashServiceProvider.overrideWithValue(
        SimulationScreenFlashService(),
      ),
      recordingServiceProvider.overrideWithValue(SimulationRecordingService()),
      locationServiceProvider.overrideWithValue(location),
      phoneServiceProvider.overrideWithValue(SimulationPhoneService()),
      messagingServiceProvider.overrideWithValue(SimulationMessagingService()),
      contactServiceProvider.overrideWith(
        (_) async => SimulationContactService(),
      ),
      audioServiceProvider.overrideWithValue(SimulationAudioService()),
      notificationServiceProvider.overrideWithValue(
        SimulationNotificationService(),
      ),
      callStateServiceProvider.overrideWithValue(SimulationCallStateService()),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late GuardianAngelaDatabase db;

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
  });

  tearDown(() async {
    await db.close();
  });

  test('real session with GPS logging enabled (default) starts tracking and '
      'requests permission', () async {
    final loc = SimulationLocationService();
    final container = _container(db, loc);
    await container.read(sessionControllerProvider.future);

    await container
        .read(sessionControllerProvider.notifier)
        .startSession(mode: _gpsMode(), simulate: false);

    check(loc.isTracking).isTrue();
    check(loc.permissionRequested).isTrue();

    await container.read(sessionControllerProvider.notifier).endSession();
  });

  test(
    'ending the session stops tracking and clears breadcrumb history',
    () async {
      final loc = SimulationLocationService()
        ..injectPoint(
          LocationPoint(
            latitude: 1,
            longitude: 2,
            timestamp: DateTime.utc(2026),
          ),
        );
      final container = _container(db, loc);
      await container.read(sessionControllerProvider.future);

      await container
          .read(sessionControllerProvider.notifier)
          .startSession(mode: _gpsMode(), simulate: false);
      check(loc.isTracking).isTrue();

      await container.read(sessionControllerProvider.notifier).endSession();

      check(loc.isTracking).isFalse();
      check(loc.history).isEmpty();
    },
  );

  test('mode override gpsLogging.enabled=false skips tracking', () async {
    final loc = SimulationLocationService();
    final container = _container(db, loc);
    await container.read(sessionControllerProvider.future);

    await container
        .read(sessionControllerProvider.notifier)
        .startSession(
          mode: _gpsMode(gps: const GpsLoggingConfig(enabled: false)),
          simulate: false,
        );

    check(loc.isTracking).isFalse();
    check(loc.permissionRequested).isFalse();

    await container.read(sessionControllerProvider.notifier).endSession();
  });

  test('simulation session never starts GPS tracking', () async {
    final loc = SimulationLocationService();
    final container = _container(db, loc);
    await container.read(sessionControllerProvider.future);

    await container
        .read(sessionControllerProvider.notifier)
        .startSession(mode: _gpsMode(), simulate: true);

    check(loc.isTracking).isFalse();

    await container.read(sessionControllerProvider.notifier).endSession();
  });
}
