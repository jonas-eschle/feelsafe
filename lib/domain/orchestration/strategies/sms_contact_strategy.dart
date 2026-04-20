/// `SmsContactStrategy` — strategy for `ChainStepType.smsContact`.
///
/// Resolves the target contact set from the step's
/// [SmsContactConfig] (allContacts / firstContact / specificIds),
/// resolves placeholders in the message template, and fans the
/// message out via [MessagingServiceProtocol.sendToAll]. Every
/// returned [MessageWorkId] is passed to
/// `services.registerSmsWorkId` (when present) so the orchestrator
/// can cancel pending sends on disarm. When zero contacts match, the
/// strategy logs and returns — no garbage send (see AUDIT-BUG-3).
library;

import 'dart:developer' as developer;

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';

/// Default message body when neither the step config nor any global
/// template provides one.
const String _defaultSmsTemplate =
    '{name} may need help. Location: {location}. Time: {time}.';

/// Strategy for SMS-to-contact steps.
final class SmsContactStrategy extends EventStrategy {
  /// Const constructor.
  const SmsContactStrategy();

  @override
  Future<void> executeReal(ChainStep step, EventServices services) async {
    final config = _resolveConfig(step);
    final channel = config.channel;
    final contacts = _resolveContacts(services, config);
    if (contacts.isEmpty) {
      developer.log(
        'SmsContactStrategy: zero contacts matched '
        '(${config.contactSelection.name}); skipping send.',
        name: 'orchestration.smsContact',
      );
      return;
    }
    final message = services.context.resolvePlaceholders(
      config.messageTemplate ?? _defaultSmsTemplate,
    );
    final ids = await services.messaging.sendToAll(
      contacts: contacts,
      message: message,
      isSimulation: services.context.isSimulation,
    );
    final register = services.registerSmsWorkId;
    if (register != null) {
      for (final id in ids) {
        register(id);
      }
    }
    // Channel is advisory here — `sendToAll` iterates every enabled
    // channel per contact. A future revision may add a per-channel
    // filter. The value is preserved on the config so the real impl
    // and tests can assert on it.
    _touchChannel(channel);
  }

  @override
  String simulationDescription(ChainStep step, EventServices services) {
    final config = _resolveConfig(step);
    final contacts = _resolveContacts(services, config);
    return '[SIM] Would send SMS to ${contacts.length} contacts';
  }

  /// Resolves the step config, falling back to defaults.
  SmsContactConfig _resolveConfig(ChainStep step) {
    final raw = step.config;
    if (raw is SmsContactConfig) return raw;
    return const SmsContactConfig();
  }

  /// Filters `services.context.contacts` by [config.contactSelection].
  List<EmergencyContact> _resolveContacts(
    EventServices services,
    SmsContactConfig config,
  ) {
    final all = services.context.contacts;
    if (all.isEmpty) return const [];
    switch (config.contactSelection) {
      case SmsContactSelection.allContacts:
        return List.unmodifiable(all);
      case SmsContactSelection.firstContact:
        return [all.first];
      case SmsContactSelection.specificIds:
        final ids = config.contactIds;
        if (ids == null || ids.isEmpty) return const [];
        final idSet = ids.toSet();
        return [
          for (final c in all)
            if (idSet.contains(c.id)) c,
        ];
    }
  }

  /// No-op that exists solely to silence dead-code analysis when the
  /// channel field becomes read-only in the strategy. Kept explicit
  /// so future refactors see that the field is intentionally threaded
  /// through but not yet acted on.
  void _touchChannel(MessageChannel channel) {
    // no-op
  }
}
