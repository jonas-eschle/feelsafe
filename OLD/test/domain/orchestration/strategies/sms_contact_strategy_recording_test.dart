/// Tests verifying that `SmsContactStrategy.executeReal` calls
/// `services.recording.startAudioRecording(cap: Duration(seconds: N))`
/// when `config.autoRecordAudio=true` AND not in simulation mode.
///
/// Also verifies the three guard conditions under which the call must
/// NOT fire:
///   - `isSimulation=true`
///   - `autoRecordAudio=false`
///   - `services.recording == null`
library;

import 'package:checks/checks.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/session_context.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/strategies/sms_contact_strategy.dart';
import 'package:guardianangela/services/fakes/fake_audio_service.dart';
import 'package:guardianangela/services/fakes/fake_messaging_service.dart';
import 'package:guardianangela/services/fakes/fake_notification_service.dart';
import 'package:guardianangela/services/fakes/fake_phone_service.dart';
import 'package:guardianangela/services/fakes/fake_recording_service.dart';
import 'package:guardianangela/services/fakes/fake_vibration_service.dart';

import '../../../helpers/test_helpers.dart';

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

/// Minimal set of fakes shared across all cases.
final class _Deps {
  _Deps({bool isSimulation = false})
    : audio = FakeAudioService(),
      messaging = FakeMessagingService(),
      phone = FakePhoneService(),
      notification = FakeNotificationService(),
      vibration = FakeVibrationService(),
      recording = FakeRecordingService(),
      _isSimulation = isSimulation;

  final FakeAudioService audio;
  final FakeMessagingService messaging;
  final FakePhoneService phone;
  final FakeNotificationService notification;
  final FakeVibrationService vibration;
  final FakeRecordingService recording;
  final bool _isSimulation;

  EventServices build({
    FakeRecordingService? overrideRecording,
    bool? overrideSimulation,
  }) => EventServices(
    audio: audio,
    messaging: messaging,
    phone: phone,
    notification: notification,
    vibration: vibration,
    context: SessionContext(
      isSimulation: overrideSimulation ?? _isSimulation,
      contacts: [
        makeContact(
          id: 'c1',
          channels: const [MessageChannel.sms],
        ),
      ],
      defaultSmsTemplate: kFallbackSmsTemplate,
      defaultPreSmsTemplate: kFallbackPreSmsTemplate,
    ),
    isCancelled: () => false,
    recording: overrideRecording ?? recording,
  );

  void dispose() {
    audio.dispose();
    messaging.dispose();
    phone.dispose();
    notification.dispose();
    vibration.dispose();
  }
}

const _strategy = SmsContactStrategy();

// ---------------------------------------------------------------------------
// Test cases
// ---------------------------------------------------------------------------

void main() {
  group(
    'SmsContactStrategy — recording.startAudioRecording gating',
    () {
      test(
          'fires startAudioRecording with correct cap when '
          'autoRecordAudio=true AND isSimulation=false', () async {
        final deps = _Deps();
        addTearDown(deps.dispose);

        await _strategy.executeReal(
          step(
            type: ChainStepType.smsContact,
            config: const SmsContactConfig(
              autoRecordAudio: true,
              recordDurationSeconds: 30,
              contactSelection: SmsContactSelection.allContacts,
            ),
          ),
          deps.build(),
        );

        final recordCalls = deps.recording.calls
            .where((c) => c.startsWith('startAudioRecording:'));
        check(recordCalls.length).equals(1);
        check(recordCalls.first).equals('startAudioRecording:cap=30');
      });

      test(
          'cap matches recordDurationSeconds from config', () async {
        final deps = _Deps();
        addTearDown(deps.dispose);

        await _strategy.executeReal(
          step(
            type: ChainStepType.smsContact,
            config: const SmsContactConfig(
              autoRecordAudio: true,
              recordDurationSeconds: 45,
              contactSelection: SmsContactSelection.allContacts,
            ),
          ),
          deps.build(),
        );

        check(deps.recording.calls.first).equals('startAudioRecording:cap=45');
      });

      test('does NOT call startAudioRecording when isSimulation=true', () async {
        // Even if autoRecordAudio=true, simulation mode must never
        // start a real microphone capture.
        final deps = _Deps(isSimulation: true);
        addTearDown(deps.dispose);

        await _strategy.executeReal(
          step(
            type: ChainStepType.smsContact,
            config: const SmsContactConfig(
              autoRecordAudio: true,
              recordDurationSeconds: 30,
              contactSelection: SmsContactSelection.allContacts,
            ),
          ),
          deps.build(),
        );

        final recordCalls = deps.recording.calls
            .where((c) => c.startsWith('startAudioRecording:'));
        check(recordCalls).isEmpty();
      });

      test(
          'does NOT call startAudioRecording when autoRecordAudio=false',
          () async {
        final deps = _Deps();
        addTearDown(deps.dispose);

        await _strategy.executeReal(
          step(
            type: ChainStepType.smsContact,
            config: const SmsContactConfig(
              autoRecordAudio: false,
              contactSelection: SmsContactSelection.allContacts,
            ),
          ),
          deps.build(),
        );

        check(deps.recording.calls).isEmpty();
      });

      test(
          'does NOT call startAudioRecording when services.recording is null',
          () async {
        final deps = _Deps();
        addTearDown(deps.dispose);

        // Build services with recording=null to simulate missing wiring.
        final services = EventServices(
          audio: deps.audio,
          messaging: deps.messaging,
          phone: deps.phone,
          notification: deps.notification,
          vibration: deps.vibration,
          context: SessionContext(
            isSimulation: false,
            contacts: [
              makeContact(
                id: 'c1',
                channels: const [MessageChannel.sms],
              ),
            ],
            defaultSmsTemplate: kFallbackSmsTemplate,
            defaultPreSmsTemplate: kFallbackPreSmsTemplate,
          ),
          isCancelled: () => false,
          // recording intentionally omitted → null
        );

        await _strategy.executeReal(
          step(
            type: ChainStepType.smsContact,
            config: const SmsContactConfig(
              autoRecordAudio: true,
              recordDurationSeconds: 30,
              contactSelection: SmsContactSelection.allContacts,
            ),
          ),
          services,
        );

        // The null-recording path does not crash and does not call our
        // fake's startAudioRecording.
        check(deps.recording.calls).isEmpty();
      });
    },
  );
}
