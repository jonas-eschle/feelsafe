import 'dart:developer';

import 'package:clock/clock.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';
import 'package:guardianangela/services/protocols/messaging_service_protocol.dart';

/// Unique notification ID for the call-emergency alarm escalation.
///
/// Must not collide with [kForegroundNotificationId] (1), fake-call (50),
/// loud-alarm (51), or disguised-reminder base (100+).
const int _kCallEmergencyNotificationId = 52;

/// Strategy for [ChainStepType.callEmergency] steps.
///
/// Optionally sends a location SMS to all SMS-capable emergency contacts
/// before dialling the emergency number. The confirmation countdown (spec 02
/// §9 callEmergency "Confirmation Countdown") is a UI concern handled by the
/// session controller (Phase 5) BEFORE this strategy is called — the strategy
/// assumes confirmation has already been resolved.
///
/// Emergency number precedence (spec 02 §9 callEmergency):
/// 1. [CallEmergencyConfig.emergencyNumber] (per-step override).
/// 2. [EventServices.emergencyNumberDefault] (app-wide setting).
/// If neither is available, throws [StateError] (fail loud).
///
/// Simulation: blocked. Logs `sim_blocked` and returns.
/// Simulation description: `'Would call [number]'`.
///
/// See spec 02 §9 callEmergency.
final class CallEmergencyStrategy implements EventStrategy {
  /// Creates a [CallEmergencyStrategy].
  const CallEmergencyStrategy();

  @override
  Future<List<MessageWorkId>> executeReal(
    ChainStep step,
    EventServices services,
  ) async {
    if (services.isSimulation) {
      log('callEmergency blocked in simulation', name: 'sim_blocked');
      return const [];
    }

    final config = step.config is CallEmergencyConfig
        ? step.config! as CallEmergencyConfig
        : const CallEmergencyConfig();

    final number = config.emergencyNumber ?? services.emergencyNumberDefault;
    if (number == null || number.isEmpty) {
      throw StateError(
        'CallEmergencyStrategy: no emergencyNumber configured. '
        'Set CallEmergencyConfig.emergencyNumber or '
        'AppSettings.emergencyCallNumber.',
      );
    }

    // The optional pre-call location SMS enqueues WorkManager jobs whose ids
    // the orchestrator must be able to cancel on disarm / clean end (A5).
    final workIds = config.sendLocationSmsFirst
        ? await _sendPreCallSms(number, services)
        : const <MessageWorkId>[];

    // Alarm escalation notification: surfaces the emergency on the lock screen
    // before the call is placed (spec 05:880-886). Critical on iOS.
    await services.notification.showAlarmEscalation(
      id: _kCallEmergencyNotificationId,
      title: 'Emergency call',
      body: 'Calling $number now.',
    );

    await services.phone.callEmergency(number);
    return workIds;
  }

  @override
  String? simulationDescription(ChainStep step, EventServices services) {
    final config = step.config is CallEmergencyConfig
        ? step.config! as CallEmergencyConfig
        : const CallEmergencyConfig();

    final number =
        config.emergencyNumber ??
        services.emergencyNumberDefault ??
        '(no number configured)';
    return 'Would call $number';
  }

  /// Sends a pre-call location SMS to all SMS-capable emergency contacts.
  ///
  /// The message informs contacts that an emergency call is about to be
  /// made. Sends are awaited in parallel via [Future.wait]. Returns the
  /// non-null [MessageWorkId]s of the enqueued SMS jobs so the orchestrator
  /// can cancel them on disarm / clean end (A5).
  Future<List<MessageWorkId>> _sendPreCallSms(
    String number,
    EventServices services,
  ) async {
    final smsCandidates = services.contacts.all
        .where((c) => c.channels.contains(MessageChannel.sms))
        .toList();

    if (smsCandidates.isEmpty) {
      return const [];
    }

    final location =
        services.location.getLastLocationUrl() ??
        services.location.getLastLocationDescription() ??
        'Location unavailable';
    final now = clock.now().toUtc().toIso8601String();

    final message =
        'Emergency call about to be made to $number. '
        'My location: $location '
        'Time: $now';

    final sends = smsCandidates.map((contact) {
      final smsContact = contact.copyWith(channels: [MessageChannel.sms]);
      return services.messaging.sendMessage(
        contact: smsContact,
        message: message,
      );
    });

    final workIds = await Future.wait(sends);
    return workIds.whereType<MessageWorkId>().toList();
  }
}
