/// `SmsContactStrategy` — strategy for `ChainStepType.smsContact`.
///
/// Resolves the target contact set from the step's
/// [SmsContactConfig] (allContacts / firstContact / specificIds),
/// resolves placeholders in the message template, and dispatches
/// each contact on `config.channel` via
/// [MessagingServiceProtocol.sendMessage].
///
/// Spec 02 §6.smsContact Single-Channel Dispatch (Extra-15/15b),
/// D-DATA-7: each `smsContact` step uses EXACTLY ONE channel. A
/// contact whose `channels` list does not contain `config.channel`
/// is skipped — add a second `smsContact` step to send via another
/// channel.
///
/// Every returned [MessageWorkId] is passed to
/// `services.registerSmsWorkId` (when present) so the orchestrator
/// can cancel pending sends on disarm. When zero contacts match, the
/// strategy logs and returns — no garbage send (see AUDIT-BUG-3).
library;

import 'dart:developer' as developer;

import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';
import 'package:guardianangela/domain/orchestration/location_resolver.dart';
import 'package:guardianangela/domain/orchestration/log_gps_resolver.dart';

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
    final config = _resolveConfig(step, services);
    final channel = config.channel;
    final candidates = _resolveContacts(services, config);
    if (candidates.isEmpty) {
      developer.log(
        'SmsContactStrategy: zero contacts matched '
        '(${config.contactSelection.name}); skipping send.',
        name: 'orchestration.smsContact',
      );
      return;
    }
    // Spec 02 Extra-15/15b / D-DATA-7: single-channel dispatch.
    // Skip contacts that lack the configured channel. The caller
    // should add a second smsContact step to send via a different
    // channel.
    final contacts = [
      for (final c in candidates)
        if (c.channels.contains(channel)) c,
    ];
    if (contacts.isEmpty) {
      developer.log(
        'SmsContactStrategy: no candidate contacts carry '
        'channel ${channel.name}; skipping.',
        name: 'orchestration.smsContact',
      );
      return;
    }
    // Spec 11 §DE-3 — resolve `{location}` via the layered resolver:
    // prefer the ephemeral tracking buffer (with an age annotation),
    // fall back to a fresh `LocationServiceProtocol.getLastLocationUrl`,
    // and finally to the literal "Location unavailable".
    //
    // Spec 11 §DE-2: gate the lookup on the resolved per-step
    // `logGps` override. When the user has opted out (force-off),
    // the resolver short-circuits to "Location unavailable" without
    // hitting GPS.
    final logGps = LogGpsResolver.resolve(step, services);
    final locationUrl = LocationResolver.resolve(
      services,
      logGpsEnabled: logGps,
    );
    final message = services.context.resolvePlaceholders(
      config.messageTemplate ?? _defaultSmsTemplate,
      location: locationUrl,
    );
    final isSim = services.context.isSimulation;
    final register = services.registerSmsWorkId;
    for (final contact in contacts) {
      final id = await services.messaging.sendMessage(
        contact: contact,
        message: message,
        channel: channel,
        isSimulation: isSim,
      );
      if (register != null) {
        register(id);
      }
    }
  }

  @override
  String simulationDescription(ChainStep step, EventServices services) {
    final config = _resolveConfig(step, services);
    final candidates = _resolveContacts(services, config);
    final channel = config.channel;
    final contacts = [
      for (final c in candidates)
        if (c.channels.contains(channel)) c,
    ];
    return '[SIM] Would send ${channel.name} to '
        '${contacts.length} contacts';
  }

  /// Resolves the step config.
  ///
  /// Fix for bugs.json Warn (strategies never fall back to
  /// EventDefaults): prefer step.config, then session eventDefaults,
  /// then the local const fallback.
  SmsContactConfig _resolveConfig(ChainStep step, EventServices services) {
    final raw = step.config;
    if (raw is SmsContactConfig) return raw;
    try {
      final fromDefaults = services.context.configFor(step);
      if (fromDefaults is SmsContactConfig) return fromDefaults;
    } on StateError {
      // No eventDefaults — fall through.
    }
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
}
