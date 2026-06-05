/// Tests verifying that SessionController wires EventStrategy.executeReal
/// correctly on engine events (Phase 7 TASK A).
///
/// Covers:
///   - Real dispatch reaches the audio service when a loudAlarm step starts.
///   - Simulation guard: isSimulation=true skips dispatch (Layer-1 guard).
///   - Error isolation: a throwing strategy surfaces lastError without
///     crashing the session.
///   - disguisedReminder is NOT dispatched on stepStarted (deferred to
///     reminderFired which fires after the wait interval).
///   - #17 fakeCall interaction: the fakeCallShowNonce auto-appear signal, and
///     answerFakeCall / hangUpFakeCall / declineFakeCall wiring to audio + engine.
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
import 'package:guardianangela/domain/models/session_context.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/user_profile.dart';
import 'package:guardianangela/features/session/session_controller.dart';
import 'package:guardianangela/services/protocols/audio_service_protocol.dart';
import 'package:guardianangela/services/protocols/notification_service_protocol.dart';
import 'package:guardianangela/services/service_providers.dart';
import 'package:guardianangela/services/session_log_recorder.dart';
import 'package:guardianangela/services/sim/audio_service_sim.dart';
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
            Directory.systemTemp.createTempSync('dispatch_test_'),
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

/// A recording [AudioServiceProtocol] that tracks calls.
final class _RecordingAudioService implements AudioServiceProtocol {
  final List<Map<String, Object?>> calls = [];

  @override
  Future<void> playAlarm({bool alarmDndOverride = true}) async =>
      calls.add({'method': 'playAlarm'});

  @override
  Future<void> playAlarmWithConfig({
    String soundChoice = 'siren',
    String? customSoundPath,
    double volume = 1.0,
    bool isSimulation = false,
    int rampSeconds = kDefaultAlarmRampSeconds,
    bool alarmDndOverride = true,
  }) async => calls.add({'method': 'playAlarmWithConfig'});

  @override
  Future<void> playRingtone(String? assetPath) async =>
      calls.add({'method': 'playRingtone'});

  @override
  Future<void> playSound(String assetPath) async =>
      calls.add({'method': 'playSound'});

  @override
  Future<void> playVoiceRecording(
    String? filePath, {
    bool useSpeaker = false,
    bool isSimulation = false,
  }) async => calls.add({
    'method': 'playVoiceRecording',
    'filePath': filePath,
    'useSpeaker': useSpeaker,
    'isSimulation': isSimulation,
  });

  @override
  Future<void> stop() async => calls.add({'method': 'stop'});
}

/// A throwing [AudioServiceProtocol] for error-isolation tests.
final class _ThrowingAudioService implements AudioServiceProtocol {
  @override
  Future<void> playAlarm({bool alarmDndOverride = true}) async =>
      throw Exception('audio exploded');

  @override
  Future<void> playAlarmWithConfig({
    String soundChoice = 'siren',
    String? customSoundPath,
    double volume = 1.0,
    bool isSimulation = false,
    int rampSeconds = kDefaultAlarmRampSeconds,
    bool alarmDndOverride = true,
  }) async => throw Exception('audio exploded');

  @override
  Future<void> playRingtone(String? assetPath) async {}

  @override
  Future<void> playSound(String assetPath) async {}

  @override
  Future<void> playVoiceRecording(
    String? filePath, {
    bool useSpeaker = false,
    bool isSimulation = false,
  }) async {}

  @override
  Future<void> stop() async {}
}

/// A recording [NotificationServiceProtocol] used for the disguisedReminder
/// test.
final class _RecordingNotificationService
    implements NotificationServiceProtocol {
  final List<Map<String, Object?>> calls = [];

  @override
  Future<void> showDisguisedReminder({
    required int id,
    required String title,
    required String body,
  }) async => calls.add({'method': 'showDisguisedReminder', 'id': id});

  @override
  Future<void> showSmsRetryExhaustedNotification({
    required String contactName,
    required String actionPayload,
  }) async => calls.add({'method': 'showSmsRetryExhaustedNotification'});

  @override
  Future<void> showForegroundServiceNotification({
    required String title,
    required String body,
    bool stealth = false,
  }) async => calls.add({'method': 'showForegroundServiceNotification'});

  @override
  Future<void> showAlarmEscalation({
    required int id,
    required String title,
    required String body,
    String sound = 'critical_alert.wav',
  }) async => calls.add({'method': 'showAlarmEscalation'});

  @override
  Future<void> cancel(int id) async =>
      calls.add({'method': 'cancel', 'id': id});

  @override
  Stream<String> get actionTaps => const Stream.empty();

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<bool> isChannelEnabled(NotificationChannelKey channel) async => true;

  @override
  Future<void> openChannelSettings(NotificationChannelKey channel) async {}
}

// ─── Mode factories ───────────────────────────────────────────────────────────

SessionMode _loudAlarmMode() => SessionMode(
  id: 'mode-la',
  name: 'LoudAlarm Test',
  chainSteps: <ChainStep>[
    ChainStep(
      id: 'step-la-0',
      type: ChainStepType.loudAlarm,
      order: 0,
      waitSeconds: 0,
      durationSeconds: 5,
      gracePeriodSeconds: 1,
      retryCount: 0,
      randomize: false,
    ),
  ],
);

/// disguisedReminder mode with [waitSeconds] = 30, so the timer does not
/// elapse during the immediate-check window of the test. The engine emits
/// [ChainEvent.stepStarted] synchronously inside `engine.start()`, but
/// [ChainEvent.reminderFired] only fires after a 30-second real Timer.
/// This separation lets us assert that nothing reached the service immediately
/// after start (i.e. dispatch was NOT on stepStarted).
SessionMode _disguisedReminderMode() => SessionMode(
  id: 'mode-dr',
  name: 'DisguisedReminder Test',
  chainSteps: <ChainStep>[
    ChainStep(
      id: 'step-dr-0',
      type: ChainStepType.disguisedReminder,
      order: 0,
      waitSeconds: 30,
      durationSeconds: 30,
      gracePeriodSeconds: 5,
      retryCount: 0,
      randomize: false,
    ),
  ],
);

/// Single-step fakeCall mode used by the #17 interaction tests.
SessionMode _fakeCallMode() => SessionMode(
  id: 'mode-fc',
  name: 'FakeCall Test',
  chainSteps: <ChainStep>[
    ChainStep(
      id: 'step-fc-0',
      type: ChainStepType.fakeCall,
      order: 0,
      waitSeconds: 0,
      durationSeconds: 30,
      gracePeriodSeconds: 5,
      retryCount: 1,
      randomize: false,
    ),
  ],
);

// ─── Container builder ────────────────────────────────────────────────────────

ProviderContainer _container(
  GuardianAngelaDatabase db, {
  AudioServiceProtocol? audio,
  NotificationServiceProtocol? notification,
}) {
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
      // Sim service overrides so startSession doesn't touch real hardware.
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
      audioServiceProvider.overrideWithValue(audio ?? SimulationAudioService()),
      notificationServiceProvider.overrideWithValue(
        notification ?? SimulationNotificationService(),
      ),
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

  test(
    'real dispatch reaches audio service: loudAlarm step fires playAlarmWithConfig',
    () async {
      final audio = _RecordingAudioService();
      final container = _container(db, audio: audio);
      await container.read(sessionControllerProvider.future);

      await container
          .read(sessionControllerProvider.notifier)
          .startSession(mode: _loudAlarmMode(), simulate: false);

      // Allow micro-tasks to flush (fire-and-forget via unawaited).
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      check(audio.calls).isNotEmpty();
      check(
        audio.calls.any((c) => c['method'] == 'playAlarmWithConfig'),
      ).isTrue();

      // Cleanup: end session to cancel engine timers.
      await container.read(sessionControllerProvider.notifier).endSession();
    },
  );

  test(
    'simulation guard (isSimulation=true): dispatch is skipped — audio receives no calls',
    () async {
      final audio = _RecordingAudioService();
      final container = _container(db, audio: audio);
      await container.read(sessionControllerProvider.future);

      await container
          .read(sessionControllerProvider.notifier)
          .startSession(mode: _loudAlarmMode(), simulate: true);

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      // Layer-1 sim guard in _dispatchStep returns immediately when
      // isSimulation == true so no strategy runs.
      check(
        audio.calls.where((c) => c['method'] == 'playAlarmWithConfig'),
      ).isEmpty();

      await container.read(sessionControllerProvider.notifier).endSession();
    },
  );

  test(
    'error isolation: throwing audio service surfaces lastError without crashing session',
    () async {
      final audio = _ThrowingAudioService();
      final container = _container(db, audio: audio);
      await container.read(sessionControllerProvider.future);

      await container
          .read(sessionControllerProvider.notifier)
          .startSession(mode: _loudAlarmMode(), simulate: false);

      // Allow enough micro-task rounds for the fire-and-forget to complete and
      // notifyStepExecutionFailed to propagate to the state.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final value = container.read(sessionControllerProvider).value;
      check(value).isNotNull();
      // The session must still be running despite the strategy throw.
      check(
        container.read(sessionControllerProvider.notifier).engine,
      ).isNotNull();
      // The error must be surfaced via lastError (stepExecutionFailed path).
      check(value!.lastError).isNotNull();
      check(value.lastError!).contains('Step execution failed');

      await container.read(sessionControllerProvider.notifier).endSession();
    },
  );

  test(
    'disguisedReminder NOT dispatched on stepStarted: notification receives no calls immediately',
    () async {
      final notification = _RecordingNotificationService();
      final container = _container(db, notification: notification);
      await container.read(sessionControllerProvider.future);

      await container
          .read(sessionControllerProvider.notifier)
          .startSession(mode: _disguisedReminderMode(), simulate: false);

      // Immediately after start (no time advance): the engine emits stepStarted
      // for the disguisedReminder step. The controller must NOT call
      // executeReal here — that fires only on reminderFired (after the
      // wait interval elapses).
      await Future<void>.delayed(Duration.zero);

      final reminderCalls = notification.calls.where(
        (c) => c['method'] == 'showDisguisedReminder',
      );
      check(reminderCalls).isEmpty();

      // Note: with real timers we cannot advance the waitSeconds easily here.
      // The negative assertion proves the stepStarted guard is in place.
      // When reminderFired fires (after wait + duration), showDisguisedReminder
      // WOULD appear — but we rely on the unit-level strategy tests for that.
      await container.read(sessionControllerProvider.notifier).endSession();
    },
  );

  // ─── #17 fakeCall interaction (auto-appear + answer/hang-up/decline) ────────
  group('fakeCall interaction (#17)', () {
    test('fakeCallShowNonce bumps when a fakeCall step starts', () async {
      final container = _container(db);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(mode: _fakeCallMode(), simulate: false);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(sessionControllerProvider).value;
      // Signal that drives the session screen's auto-push of FakeCallScreen.
      check(state!.fakeCallShowNonce).isGreaterThan(0);

      await notifier.endSession();
    });

    test('answerFakeCall stops the ring and plays the voice clip routed to '
        'the requested output', () async {
      final audio = _RecordingAudioService();
      final container = _container(db, audio: audio);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(mode: _fakeCallMode(), simulate: false);
      await Future<void>.delayed(Duration.zero);
      audio.calls.clear(); // drop the ring/escalation from the step firing

      await notifier.answerFakeCall(
        voiceRecordingPath: '/voice/a.aac',
        useSpeaker: true,
      );

      check(audio.calls.any((c) => c['method'] == 'stop')).isTrue();
      final voice = audio.calls.firstWhere(
        (c) => c['method'] == 'playVoiceRecording',
      );
      check(voice['filePath']).equals('/voice/a.aac');
      check(voice['useSpeaker']).equals(true);
      check(voice['isSimulation']).equals(false);

      await notifier.endSession();
    });

    test('hangUpFakeCall stops audio and disarms (reset to step 0)', () async {
      final audio = _RecordingAudioService();
      final container = _container(db, audio: audio);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(mode: _fakeCallMode(), simulate: false);
      await Future<void>.delayed(Duration.zero);
      audio.calls.clear();

      notifier.hangUpFakeCall();
      await Future<void>.delayed(Duration.zero);

      check(audio.calls.any((c) => c['method'] == 'stop')).isTrue();
      final state = container.read(sessionControllerProvider).value;
      check(state!.currentStepIndex).equals(0);

      await notifier.endSession();
    });

    test(
      'declineFakeCall(declineIsSafe: true) stops audio and disarms',
      () async {
        final audio = _RecordingAudioService();
        final container = _container(db, audio: audio);
        await container.read(sessionControllerProvider.future);
        final notifier = container.read(sessionControllerProvider.notifier);
        await notifier.startSession(mode: _fakeCallMode(), simulate: false);
        await Future<void>.delayed(Duration.zero);
        audio.calls.clear();

        notifier.declineFakeCall(declineIsSafe: true);
        await Future<void>.delayed(Duration.zero);

        check(audio.calls.any((c) => c['method'] == 'stop')).isTrue();
        final state = container.read(sessionControllerProvider).value;
        check(state!.currentStepIndex).equals(0);

        await notifier.endSession();
      },
    );

    test('declineFakeCall(declineIsSafe: false) stops audio and re-rings '
        '(session stays active, not disarmed)', () async {
      final audio = _RecordingAudioService();
      final container = _container(db, audio: audio);
      await container.read(sessionControllerProvider.future);
      final notifier = container.read(sessionControllerProvider.notifier);
      await notifier.startSession(mode: _fakeCallMode(), simulate: false);
      await Future<void>.delayed(Duration.zero);
      audio.calls.clear();

      notifier.declineFakeCall(declineIsSafe: false);
      await Future<void>.delayed(Duration.zero);

      check(audio.calls.any((c) => c['method'] == 'stop')).isTrue();
      // restartCurrentStep keeps the engine running (re-rings after grace).
      check(notifier.engine).isNotNull();

      await notifier.endSession();
    });
  });
}
