/// Tests verifying that SessionController wires the engine's background speed
/// clamp (G-013) into the app-lifecycle (#12).
///
/// Covers (spec 01 §setBackgroundClamp):
///   - Backgrounding (AppLifecycleState.paused / hidden) engages the 60× cap;
///     foregrounding (resumed) releases it; inactive / detached do not change
///     it (inactive is a transient, still-visible state).
///   - The observer is actually registered with WidgetsBinding — a real
///     `flutter/lifecycle` platform message engages and releases the clamp,
///     and re-registers correctly for a second session after endSession.
///
/// These drive the REAL SessionController + SessionEngine (host-level proof for
/// pure lifecycle wiring); every platform service is swapped for its simulation
/// double so no platform channel is touched.
library;

import 'dart:io';

import 'package:flutter/services.dart' show StringCodec;
import 'package:flutter/widgets.dart' show AppLifecycleState;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/data/repositories/user_profile_repository.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
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
            Directory.systemTemp.createTempSync('clamp_test_'),
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
/// any real action, so the background-clamp state can be observed in isolation.
SessionMode _clampMode() => SessionMode(
  id: 'clamp-mode',
  name: 'Clamp Test',
  chainSteps: <ChainStep>[
    ChainStep(
      id: 'clamp-hold-0',
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

/// A speed well above the 60× background cap, so the clamp's effect on
/// [SessionEngine.effectiveSpeedMultiplier] is observable.
const double _fastSpeed = 200.0;

ProviderContainer _container(GuardianAngelaDatabase db) {
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
      locationServiceProvider.overrideWithValue(SimulationLocationService()),
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

/// Starts a fast simulation session and returns the live controller.
Future<SessionController> _startSim(ProviderContainer container) async {
  await container.read(sessionControllerProvider.future);
  final controller = container.read(sessionControllerProvider.notifier);
  await controller.startSession(
    mode: _clampMode(),
    simulate: true,
    speedMultiplier: _fastSpeed,
  );
  return controller;
}

/// Delivers a real `flutter/lifecycle` platform message so the change flows
/// through WidgetsBinding to every registered observer — the same path the OS
/// drives at runtime. Proves the controller registered itself as an observer.
Future<void> _sendLifecycle(AppLifecycleState state) async {
  final message = const StringCodec().encodeMessage(state.toString());
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage('flutter/lifecycle', message, (_) {});
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  // SessionController registers a WidgetsBindingObserver in startSession, which
  // needs an initialised binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  late GuardianAngelaDatabase db;

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
  });

  tearDown(() async {
    await db.close();
  });

  group('Background clamp lifecycle (#12, G-013)', () {
    test('paused engages the clamp', () async {
      final container = _container(db);
      final controller = await _startSim(container);
      check(controller.engine!.isBackgroundClamped).isFalse();

      controller.didChangeAppLifecycleState(AppLifecycleState.paused);

      check(controller.engine!.isBackgroundClamped).isTrue();
      await controller.endSession();
    });

    test('hidden engages the clamp', () async {
      final container = _container(db);
      final controller = await _startSim(container);

      controller.didChangeAppLifecycleState(AppLifecycleState.hidden);

      check(controller.engine!.isBackgroundClamped).isTrue();
      await controller.endSession();
    });

    test('resumed releases the clamp', () async {
      final container = _container(db);
      final controller = await _startSim(container);
      controller.didChangeAppLifecycleState(AppLifecycleState.paused);
      check(controller.engine!.isBackgroundClamped).isTrue();

      controller.didChangeAppLifecycleState(AppLifecycleState.resumed);

      check(controller.engine!.isBackgroundClamped).isFalse();
      await controller.endSession();
    });

    test(
      'inactive does not change the clamp (neither engages nor releases)',
      () async {
        final container = _container(db);
        final controller = await _startSim(container);

        // From released: inactive must NOT engage (it is transient + visible).
        controller.didChangeAppLifecycleState(AppLifecycleState.inactive);
        check(controller.engine!.isBackgroundClamped).isFalse();

        // From engaged: inactive must NOT release.
        controller.didChangeAppLifecycleState(AppLifecycleState.paused);
        controller.didChangeAppLifecycleState(AppLifecycleState.inactive);
        check(controller.engine!.isBackgroundClamped).isTrue();

        await controller.endSession();
      },
    );

    test('detached does not change the clamp', () async {
      final container = _container(db);
      final controller = await _startSim(container);
      controller.didChangeAppLifecycleState(AppLifecycleState.paused);

      controller.didChangeAppLifecycleState(AppLifecycleState.detached);

      check(controller.engine!.isBackgroundClamped).isTrue();
      await controller.endSession();
    });

    test(
      'paused caps effectiveSpeedMultiplier to 60x; resumed restores it',
      () async {
        final container = _container(db);
        final controller = await _startSim(container);
        final engine = controller.engine!;
        check(engine.effectiveSpeedMultiplier).isCloseTo(_fastSpeed, 1e-9);

        controller.didChangeAppLifecycleState(AppLifecycleState.paused);
        check(engine.effectiveSpeedMultiplier).isCloseTo(60.0, 1e-9);
        // Stored multiplier is untouched — only the effective value is capped.
        check(engine.speedMultiplier).isCloseTo(_fastSpeed, 1e-9);

        controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
        check(engine.effectiveSpeedMultiplier).isCloseTo(_fastSpeed, 1e-9);

        await controller.endSession();
      },
    );

    test(
      'a lifecycle callback after endSession is a no-op (engine torn down)',
      () async {
        final container = _container(db);
        final controller = await _startSim(container);
        controller.didChangeAppLifecycleState(AppLifecycleState.paused);
        await controller.endSession();

        check(controller.engine).isNull();
        // The observer is removed on teardown; even a stray callback is a no-op.
        check(
          () => controller.didChangeAppLifecycleState(AppLifecycleState.paused),
        ).returnsNormally();
      },
    );

    test('a real flutter/lifecycle message engages then releases the clamp, '
        'and re-registers for a second session', () async {
      final container = _container(db);

      // Session 1: the observer must be registered with WidgetsBinding for
      // the platform message to reach it.
      final controller = await _startSim(container);
      // Normalise to foreground first so the assertion is order-independent
      // (the binding's lifecycle state is shared across tests in the file).
      await _sendLifecycle(AppLifecycleState.resumed);
      check(controller.engine!.isBackgroundClamped).isFalse();

      await _sendLifecycle(AppLifecycleState.paused);
      check(controller.engine!.isBackgroundClamped).isTrue();

      await _sendLifecycle(AppLifecycleState.resumed);
      check(controller.engine!.isBackgroundClamped).isFalse();

      await controller.endSession();

      // Session 2: startSession must re-register the observer (teardown of
      // session 1 removed it). A fresh engine clamps on the next paused
      // message.
      await controller.startSession(
        mode: _clampMode(),
        simulate: true,
        speedMultiplier: _fastSpeed,
      );
      check(controller.engine!.isBackgroundClamped).isFalse();

      await _sendLifecycle(AppLifecycleState.paused);
      check(controller.engine!.isBackgroundClamped).isTrue();

      await _sendLifecycle(AppLifecycleState.resumed);
      await controller.endSession();
    });
  });
}
