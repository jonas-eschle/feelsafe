/// `PhoneCallContactStrategy` — strategy for
/// `ChainStepType.phoneCallContact`.
///
/// Resolves the target contact from [PhoneCallContactConfig]:
/// `contactId` → lookup by id; null → first contact in
/// `services.context.contacts`. If no contact resolves, the strategy
/// logs and returns — never falls back to a hardcoded phone number
/// (see AUDIT-BUG-3).
///
/// When `config.preSendSms` is true, a pre-call SMS is sent to the
/// same contact before dialing. Every enqueued [MessageWorkId] is
/// passed to `services.registerSmsWorkId` when present.
library;

import 'dart:developer' as developer;

import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';

/// Default pre-SMS body when neither the step config nor a global
/// template provides one.
const String _defaultPreSmsTemplate =
    '{name} is trying to reach you. Please expect a call.';

/// Strategy for phone-call-to-contact steps.
final class PhoneCallContactStrategy extends EventStrategy {
  /// Const constructor.
  const PhoneCallContactStrategy();

  @override
  Future<void> executeReal(ChainStep step, EventServices services) async {
    final config = _resolveConfig(step);
    final contact = _resolveContact(services, config);
    if (contact == null) {
      developer.log(
        'PhoneCallContactStrategy: no contact to call '
        '(contactId=${config.contactId}); skipping.',
        name: 'orchestration.phoneCallContact',
      );
      return;
    }
    final isSim = services.context.isSimulation;
    if (config.preSendSms) {
      final preBody = services.context.resolvePlaceholders(
        config.preSmsMessage ?? _defaultPreSmsTemplate,
      );
      final ids = await services.messaging.sendToAll(
        contacts: [contact],
        message: preBody,
        isSimulation: isSim,
      );
      final register = services.registerSmsWorkId;
      if (register != null) {
        for (final id in ids) {
          register(id);
        }
      }
    }
    await services.phone.call(contact.phoneNumber, isSimulation: isSim);
  }

  @override
  String simulationDescription(ChainStep step, EventServices services) {
    final config = _resolveConfig(step);
    final contact = _resolveContact(services, config);
    if (contact == null) return '[SIM] No contact to call';
    return '[SIM] Would call ${contact.name}';
  }

  /// Resolves the step config, falling back to defaults.
  PhoneCallContactConfig _resolveConfig(ChainStep step) {
    final raw = step.config;
    if (raw is PhoneCallContactConfig) return raw;
    return const PhoneCallContactConfig();
  }

  /// Resolves the target contact: by id when set, else first.
  EmergencyContact? _resolveContact(
    EventServices services,
    PhoneCallContactConfig config,
  ) {
    final all = services.context.contacts;
    if (all.isEmpty) return null;
    final id = config.contactId;
    if (id == null) return all.first;
    for (final c in all) {
      if (c.id == id) return c;
    }
    return null;
  }
}
