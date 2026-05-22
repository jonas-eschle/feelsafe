import 'dart:async';
import 'dart:developer';

import 'package:clock/clock.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/sms_contact_selection.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';

/// Default message template used when [SmsContactConfig.messageTemplate]
/// is `null`.
const _kDefaultMessageTemplate =
    'Automated safety alert from Guardian Angela.\n'
    '{name} may need help.\n'
    'Last known location: {location}\n'
    'Time: {time}\n'
    'Physical description: {description}';

/// Strategy for [ChainStepType.smsContact] steps.
///
/// Sends a message to the configured contacts via the single configured
/// channel (Extra-15). Optionally starts an audio recording in parallel
/// before dispatching (spec 02 §6 smsContact).
///
/// Simulation: blocked. Logs `sim_blocked` and returns.
/// Simulation description: `'Would send to N contacts via [channel]'`.
///
/// See spec 02 §6 smsContact.
final class SmsContactStrategy implements EventStrategy {
  /// Creates an [SmsContactStrategy].
  const SmsContactStrategy();

  @override
  Future<void> executeReal(ChainStep step, EventServices services) async {
    if (services.isSimulation) {
      log('smsContact blocked in simulation', name: 'sim_blocked');
      return;
    }

    final config = step.config is SmsContactConfig
        ? step.config! as SmsContactConfig
        : const SmsContactConfig();

    final targets = _resolveContacts(config, services);
    final filtered = targets
        .where((c) => c.channels.contains(config.channel))
        .toList();

    if (filtered.isEmpty) {
      log(
        'smsContact: no contacts with channel ${config.channel.name}',
        name: 'SmsContactStrategy',
      );
      return;
    }

    // Start audio recording in parallel (fire-and-forget) if configured.
    // Recording runs alongside the SMS sends; errors are not propagated.
    if (config.autoRecordAudio) {
      unawaited(
        services.recording.recordForDuration(
          duration: Duration(seconds: config.recordDurationSeconds),
        ),
      );
    }

    final template = config.messageTemplate ?? _kDefaultMessageTemplate;
    final location = config.includeLocation
        ? (services.location.getLastLocationUrl() ??
              services.location.getLastLocationDescription() ??
              'Location unavailable')
        : 'Location unavailable';

    final now = clock.now().toUtc().toIso8601String();
    final userName = services.userName ?? 'the owner of this phone';
    final description = services.userDescription ?? '';

    final sends = filtered.map((contact) {
      var message = template
          .replaceAll('{name}', userName)
          .replaceAll('{location}', location)
          .replaceAll('{time}', now)
          .replaceAll('{description}', description);

      if (config.includeMedicalInfo && services.userMedicalInfo != null) {
        message += '\n\nMedical info: ${services.userMedicalInfo}';
      }

      // Single-channel dispatch (Extra-15): pass a copy restricted to the
      // configured channel so MessagingService never multi-dispatches.
      final singleChannelContact = contact.copyWith(channels: [config.channel]);

      return services.messaging.sendMessage(
        contact: singleChannelContact,
        message: message,
      );
    });

    await Future.wait(sends);
  }

  @override
  String? simulationDescription(ChainStep step, EventServices services) {
    final config = step.config is SmsContactConfig
        ? step.config! as SmsContactConfig
        : const SmsContactConfig();

    final targets = _resolveContacts(config, services);
    final filtered = targets
        .where((c) => c.channels.contains(config.channel))
        .toList();

    if (filtered.isEmpty) {
      return 'No contacts targeted for ${config.channel.name}';
    }

    return 'Would send to ${filtered.length} '
        'contact${filtered.length == 1 ? '' : 's'} '
        'via ${config.channel.name}';
  }

  /// Resolves the target contacts based on [SmsContactConfig.contactSelection].
  ///
  /// Legacy back-compat: when [contactSelection] is [SmsContactSelection.allContacts]
  /// AND [contactIds] is non-null/non-empty, the list is treated as specific IDs.
  List<EmergencyContact> _resolveContacts(
    SmsContactConfig config,
    EventServices services,
  ) {
    final all = services.contacts.all;

    // Legacy back-compat: allContacts + explicit contactIds → specific IDs.
    if (config.contactSelection == SmsContactSelection.allContacts &&
        config.contactIds != null &&
        config.contactIds!.isNotEmpty) {
      return _resolveByIds(config.contactIds!, services);
    }

    switch (config.contactSelection) {
      case SmsContactSelection.allContacts:
        return all;
      case SmsContactSelection.firstContact:
        if (all.isEmpty) {
          return const [];
        }
        final sorted = List<EmergencyContact>.from(all)
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return [sorted.first];
      case SmsContactSelection.specificIds:
        final ids = config.contactIds;
        if (ids == null || ids.isEmpty) {
          return const [];
        }
        return _resolveByIds(ids, services);
    }
  }

  List<EmergencyContact> _resolveByIds(
    List<String> ids,
    EventServices services,
  ) => ids.map(services.contacts.byId).whereType<EmergencyContact>().toList();
}
