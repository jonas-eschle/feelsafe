/// Integration tests for the 4-layer simulation defense.
///
/// The defense prevents any real telephony / messaging / alarm from
/// firing during a simulated session:
///   * Layer 1 — `SessionOrchestrator` never calls `executeReal` when
///     `isSimulation == true` (only `simulationDescription`).
///   * Layer 2 — real service implementations respect the
///     `isSimulation` kwarg and short-circuit with a SIM-BLOCK log.
///   * Layer 3 — the `SimulationXxxService` impls are structural
///     no-ops that cannot physically reach platform channels.
///   * Layer 4 — structural: simulation service files must not import
///     telephony / url_launcher / MethodChannel.
library;

import 'dart:io';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/chain_event.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/session_context.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';
import 'package:guardianangela/domain/orchestration/event_strategy_registry.dart';
import 'package:guardianangela/domain/orchestration/session_orchestrator.dart';
import 'package:guardianangela/services/fakes/fake_audio_service.dart';
import 'package:guardianangela/services/fakes/fake_messaging_service.dart';
import 'package:guardianangela/services/fakes/fake_notification_service.dart';
import 'package:guardianangela/services/fakes/fake_phone_service.dart';
import 'package:guardianangela/services/fakes/fake_vibration_service.dart';
import 'package:guardianangela/services/implementations/audio_service.dart';
import 'package:guardianangela/services/implementations/phone_service.dart';
import 'package:guardianangela/services/implementations/vibration_service.dart';
import 'package:guardianangela/services/simulation/simulation_audio_service.dart';
import 'package:guardianangela/services/simulation/simulation_messaging_service.dart';
import 'package:guardianangela/services/simulation/simulation_phone_service.dart';
import '../helpers/test_helpers.dart';

ChainEventData _event({
  required ChainEvent event,
  int? stepIndex,
  ChainStepType? stepType,
}) => ChainEventData(
  event: event,
  timestamp: DateTime.utc(2026, 4, 20),
  stepIndex: stepIndex,
  stepType: stepType,
);

/// Orchestrator harness that counts attempted real executions.
({
  SessionOrchestrator orch,
  FakeAudioService audio,
  FakePhoneService phone,
  FakeMessagingService messaging,
  FakeVibrationService vib,
  FakeNotificationService notif,
  List<SimulationDescription> simDescriptions,
})
_buildOrchestrator({
  required bool isSimulation,
  required List<ChainStep> steps,
  List<EmergencyContact> contacts = const [],
}) {
  final audio = FakeAudioService();
  final phone = FakePhoneService();
  final messaging = FakeMessagingService();
  final vib = FakeVibrationService();
  final notif = FakeNotificationService();
  final simDescriptions = <SimulationDescription>[];
  final orch = SessionOrchestrator(
    isSimulation: isSimulation,
    chainStepsResolver: () => steps,
    messagingService: messaging,
    servicesBuilder: (isCancelled, register) => EventServices(
      audio: audio,
      messaging: messaging,
      phone: phone,
      notification: notif,
      vibration: vib,
      context: SessionContext(contacts: contacts, isSimulation: isSimulation),
      isCancelled: isCancelled,
      registerSmsWorkId: register,
    ),
    onSimulationDescription: simDescriptions.add,
  );
  return (
    orch: orch,
    audio: audio,
    phone: phone,
    messaging: messaging,
    vib: vib,
    notif: notif,
    simDescriptions: simDescriptions,
  );
}

void main() {
  // ==================================================================
  // Layer 1 — orchestrator simulation branch does not call executeReal
  // ==================================================================
  group('Layer 1: SessionOrchestrator simulation branch', () {
    test(
      'loudAlarm stepStarted in simulation fires SIM description only',
      () async {
        final h = _buildOrchestrator(
          isSimulation: true,
          steps: [step(type: ChainStepType.loudAlarm)],
        );
        addTearDown(() {
          h.audio.dispose();
          h.messaging.dispose();
          h.phone.dispose();
          h.notif.dispose();
          h.vib.dispose();
        });
        await h.orch.handleEvent(
          _event(event: ChainEvent.stepStarted, stepIndex: 0),
        );
        check(h.audio.calls).isEmpty();
        check(h.simDescriptions).isNotEmpty();
      },
    );

    test(
      'callEmergency stepStarted in simulation does not call phone service',
      () async {
        final h = _buildOrchestrator(
          isSimulation: true,
          steps: [step(type: ChainStepType.callEmergency)],
        );
        addTearDown(() {
          h.audio.dispose();
          h.messaging.dispose();
          h.phone.dispose();
          h.notif.dispose();
          h.vib.dispose();
        });
        await h.orch.handleEvent(
          _event(event: ChainEvent.stepStarted, stepIndex: 0),
        );
        check(h.phone.calls).isEmpty();
      },
    );

    test(
      'smsContact stepStarted in simulation does not call messaging',
      () async {
        final h = _buildOrchestrator(
          isSimulation: true,
          steps: [step(type: ChainStepType.smsContact)],
          contacts: [makeContact(id: 'a')],
        );
        addTearDown(() {
          h.audio.dispose();
          h.messaging.dispose();
          h.phone.dispose();
          h.notif.dispose();
          h.vib.dispose();
        });
        await h.orch.handleEvent(
          _event(event: ChainEvent.stepStarted, stepIndex: 0),
        );
        check(h.messaging.calls).isEmpty();
      },
    );

    test(
      'fakeCall stepStarted in simulation does not call audio service',
      () async {
        final h = _buildOrchestrator(
          isSimulation: true,
          steps: [step(type: ChainStepType.fakeCall)],
        );
        addTearDown(() {
          h.audio.dispose();
          h.messaging.dispose();
          h.phone.dispose();
          h.notif.dispose();
          h.vib.dispose();
        });
        await h.orch.handleEvent(
          _event(event: ChainEvent.stepStarted, stepIndex: 0),
        );
        check(h.audio.calls).isEmpty();
        check(h.vib.calls).isEmpty();
      },
    );

    test('every strategy has a non-empty simulationDescription', () {
      final h = _buildOrchestrator(
        isSimulation: true,
        steps: const [],
        contacts: [makeContact(id: 'a')],
      );
      addTearDown(() {
        h.audio.dispose();
        h.messaging.dispose();
        h.phone.dispose();
        h.notif.dispose();
        h.vib.dispose();
      });
      final ctx = SessionContext(
        contacts: [makeContact(id: 'a')],
        isSimulation: true,
      );
      final services = EventServices(
        audio: h.audio,
        messaging: h.messaging,
        phone: h.phone,
        notification: h.notif,
        vibration: h.vib,
        context: ctx,
        isCancelled: () => false,
      );
      for (final type in ChainStepType.values) {
        final s = step(type: type);
        final strategy = EventStrategyRegistry.forStep(s);
        final desc = strategy.simulationDescription(s, services);
        check(
          desc.templateKey,
          because: 'each type should emit a non-empty template key',
        ).isNotEmpty();
      }
    });
  });

  // ==================================================================
  // Layer 2 — real service impls honor isSimulation: true
  // ==================================================================
  group('Layer 2: real service impls honor isSimulation', () {
    test(
      'real AudioService.playAlarm(isSimulation:true) returns fast',
      () async {
        final audio = AudioService();
        // This should return without crashing and without calling the
        // underlying player. The underlying AudioPlayer is not
        // instantiated because the method short-circuits.
        await audio.playAlarm(isSimulation: true);
      },
    );

    test(
      'real AudioService.playRingtone(isSimulation:true) is a no-op',
      () async {
        final audio = AudioService();
        await audio.playRingtone(isSimulation: true);
      },
    );

    test(
      'real AudioService.playVoiceRecording(isSimulation:true) is a no-op',
      () async {
        final audio = AudioService();
        await audio.playVoiceRecording(
          assetPath: 'foo.mp3',
          isSimulation: true,
        );
      },
    );

    test('real PhoneService.call(isSimulation:true) is a no-op', () async {
      final phone = PhoneService();
      await phone.call('+15551234', isSimulation: true);
    });

    test(
      'real PhoneService.callEmergency(isSimulation:true) is a no-op',
      () async {
        final phone = PhoneService();
        await phone.callEmergency('112', isSimulation: true);
      },
    );

    test(
      'real VibrationService.alarmPattern(isSimulation:true) is a no-op',
      () async {
        final vib = VibrationService();
        await vib.alarmPattern(isSimulation: true);
      },
    );

    test(
      'real VibrationService.warningPattern(isSimulation:true) is a no-op',
      () async {
        final vib = VibrationService();
        await vib.warningPattern(isSimulation: true);
      },
    );
  });

  // ==================================================================
  // Layer 3 — simulation service impls
  // ==================================================================
  group('Layer 3: simulation service impls never reach real paths', () {
    test(
      'SimulationMessagingService.sendToAll returns simulated ids only',
      () async {
        final svc = SimulationMessagingService();
        addTearDown(svc.dispose);
        final ids = await svc.sendToAll(
          contacts: [
            makeContact(id: 'a'),
            makeContact(id: 'b'),
          ],
          message: 'help',
        );
        check(ids.length).equals(2);
        for (final id in ids) {
          check(id.toString()).contains('sim-');
        }
      },
    );

    test('SimulationMessagingService.sendMessage returns sim-* id', () async {
      final svc = SimulationMessagingService();
      addTearDown(svc.dispose);
      final id = await svc.sendMessage(
        contact: makeContact(),
        message: 'help',
        channel: MessageChannel.sms,
      );
      check(id.toString()).contains('sim-');
    });

    test(
      'SimulationAudioService.playAlarm never touches a platform channel',
      () async {
        final svc = SimulationAudioService();
        // Will log but never throw — would throw on MissingPluginException
        // if reaching a real audio player method channel.
        await svc.playAlarm(maxVolume: true);
      },
    );

    test(
      'SimulationPhoneService.callEmergency never touches a platform channel',
      () async {
        final svc = SimulationPhoneService();
        await svc.callEmergency('112');
      },
    );
  });

  // ==================================================================
  // Layer 4 — structural: simulation impl files have no telephony imports
  // ==================================================================
  group('Layer 4: simulation files have no real-side imports', () {
    final simDir = Directory(
      '${Directory.current.path}/lib/services/simulation',
    );

    test('simulation service directory exists', () {
      check(simDir.existsSync()).isTrue();
    });

    test('no simulation file imports url_launcher', () {
      final files = simDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));
      final importRe = RegExp(
        r"^\s*import\s+['"
        "\""
        r"]package:url_launcher",
      );
      for (final file in files) {
        final content = file.readAsStringSync();
        final hasImport = content
            .split('\n')
            .any((line) => importRe.hasMatch(line));
        check(
          hasImport,
          because: '${file.path} must not import url_launcher',
        ).isFalse();
      }
    });

    test('no simulation file declares a MethodChannel', () {
      final files = simDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));
      // Ignore comments by stripping lines starting with // or ///.
      for (final file in files) {
        final content = file.readAsStringSync();
        final strippedLines = content
            .split('\n')
            .where((l) => !l.trimLeft().startsWith('//'))
            .join('\n');
        check(
          strippedLines.contains('MethodChannel('),
          because: '${file.path} must not construct a MethodChannel',
        ).isFalse();
      }
    });

    test(
      'no simulation file imports flutter/services (MethodChannel source)',
      () {
        final files = simDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'));
        final importRe = RegExp(
          r"^\s*import\s+['"
          "\""
          r"]package:flutter/services",
        );
        for (final file in files) {
          final content = file.readAsStringSync();
          final hasImport = content
              .split('\n')
              .any((line) => importRe.hasMatch(line));
          check(
            hasImport,
            because: '${file.path} must not import platform channel types',
          ).isFalse();
        }
      },
    );

    // Fix for historical.json Note / fixer brief item #13: extend the
    // structural check to flag geolocator (real GPS) and
    // flutter_local_notifications (platform-native notifications)
    // imports from simulation files. Both would breach Layer 4.
    test('no simulation file imports geolocator', () {
      final files = simDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));
      final importRe = RegExp(
        r"^\s*import\s+['"
        "\""
        r"]package:geolocator",
      );
      for (final file in files) {
        final content = file.readAsStringSync();
        final hasImport = content
            .split('\n')
            .any((line) => importRe.hasMatch(line));
        check(
          hasImport,
          because: '${file.path} must not import geolocator',
        ).isFalse();
      }
    });

    test('no simulation file imports flutter_local_notifications', () {
      final files = simDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));
      final importRe = RegExp(
        r"^\s*import\s+['"
        "\""
        r"]package:flutter_local_notifications",
      );
      for (final file in files) {
        final content = file.readAsStringSync();
        final hasImport = content
            .split('\n')
            .any((line) => importRe.hasMatch(line));
        check(
          hasImport,
          because: '${file.path} must not import flutter_local_notifications',
        ).isFalse();
      }
    });
  });
}
