import 'dart:developer';

import 'package:clock/clock.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';

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
  Future<void> executeReal(ChainStep step, EventServices services) async {
    if (services.isSimulation) {
      log('callEmergency blocked in simulation', name: 'sim_blocked');
      return;
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

    if (config.sendLocationSmsFirst) {
      await _sendPreCallSms(number, services);
    }

    await services.phone.callEmergency(number);
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
  /// made. Sends are awaited in parallel via [Future.wait].
  Future<void> _sendPreCallSms(String number, EventServices services) async {
    final smsCandidates = services.contacts.all
        .where((c) => c.channels.contains(MessageChannel.sms))
        .toList();

    if (smsCandidates.isEmpty) {
      return;
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

    await Future.wait(sends);
  }
}
