/// `PhoneCallContactStrategy` — strategy for
/// `ChainStepType.phoneCallContact`.
///
/// Spec 02 §7.phoneCallContact Retry Logic & Alternative Contacts:
/// the strategy tries the primary contact up to
/// `ChainStep.retryCount + 1` attempts, then falls through each id in
/// `config.alternativeContactIds` in order. Any `PhoneServiceProtocol`
/// error is caught and treated as "failed"; the next attempt is made.
///
/// NOTE: [PhoneServiceProtocol.call] currently returns `void` without
/// a success/fail channel. Until that signature is extended, every
/// attempt is treated as successful — the retry/fallback loop runs
/// but always exits after the first attempt on the first contact.
/// True retry semantics require the service layer to surface call
/// outcome (TODO: see spec §Phase-4b service extension).
///
/// Resolves the target contact from [PhoneCallContactConfig]:
/// `contactId` → lookup by id; null → first contact in
/// `services.context.contacts`. If no contact resolves, the strategy
/// logs and returns — never falls back to a hardcoded phone number
/// (see AUDIT-BUG-3).
///
/// When `config.preSendSms` is true, a pre-call SMS is sent to the
/// current target contact before dialing. Every enqueued
/// [MessageWorkId] is passed to `services.registerSmsWorkId` when
/// present.
library;

import 'dart:developer' as developer;

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';
import 'package:guardianangela/domain/orchestration/location_resolver.dart';
import 'package:guardianangela/domain/orchestration/log_gps_resolver.dart';

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
    final config = _resolveConfig(step, services);
    final targets = _resolveTargets(services, config);
    if (targets.isEmpty) {
      developer.log(
        'PhoneCallContactStrategy: no contact to call '
        '(contactId=${config.contactId}); skipping.',
        name: 'orchestration.phoneCallContact',
      );
      return;
    }
    final isSim = services.context.isSimulation;
    // Spec 11 §DE-2: resolve the per-step GPS-logging override
    // once per call. Drives the `{location}` placeholder in the
    // pre-call SMS, plus opt-out of any location lookup performed
    // by the platform call layer in the future.
    final logGps = LogGpsResolver.resolve(step, services);
    final locationUrl = LocationResolver.resolve(
      services,
      logGpsEnabled: logGps && config.preSmsIncludeLocation,
    );
    // Spec 02 §7: +1 extra attempts per retryCount on the current
    // contact before moving to the next alternative.
    final attemptsPerContact = step.retryCount + 1;
    for (final contact in targets) {
      var succeeded = false;
      for (var attempt = 0; attempt < attemptsPerContact; attempt++) {
        if (config.preSendSms) {
          final preBody = services.context.resolvePlaceholders(
            config.preSmsMessage ?? _defaultPreSmsTemplate,
            location: locationUrl,
          );
          final id = await services.messaging.sendMessage(
            contact: contact,
            // Pre-SMS uses the contact's first enabled messaging
            // channel (or SMS if none set). Distinct from the call
            // channel per spec.
            channel: contact.channels.isNotEmpty
                ? contact.channels.first
                : MessageChannel.sms,
            message: preBody,
            isSimulation: isSim,
          );
          final register = services.registerSmsWorkId;
          if (register != null) register(id);
        }
        try {
          await services.phone.call(
            contact.phoneNumber,
            isSimulation: isSim,
          );
          // TODO(phase-4b): PhoneServiceProtocol.call currently has
          // no success/fail channel. Treat every completion as
          // success until the service signature is extended.
          succeeded = true;
          break;
        } on Object catch (error) {
          developer.log(
            'PhoneCallContactStrategy: call attempt '
            '${attempt + 1}/$attemptsPerContact failed for '
            '${contact.id}: $error',
            name: 'orchestration.phoneCallContact',
          );
        }
      }
      if (succeeded) return;
    }
  }

  @override
  SimulationDescription simulationDescription(
    ChainStep step,
    EventServices services,
  ) {
    final config = _resolveConfig(step, services);
    final targets = _resolveTargets(services, config);
    if (targets.isEmpty) {
      return const SimulationDescription('simNoContactToCall');
    }
    return SimulationDescription(
      'simPhoneCall',
      {'name': targets.first.name},
    );
  }

  /// Resolves the step config.
  ///
  /// Fix for bugs.json Warn (strategies never fall back to
  /// EventDefaults): prefer step.config, then session eventDefaults,
  /// then the local const fallback.
  PhoneCallContactConfig _resolveConfig(
    ChainStep step,
    EventServices services,
  ) {
    final raw = step.config;
    if (raw is PhoneCallContactConfig) return raw;
    try {
      final fromDefaults = services.context.configFor(step);
      if (fromDefaults is PhoneCallContactConfig) return fromDefaults;
    } on StateError {
      // No eventDefaults — fall through.
    }
    return const PhoneCallContactConfig();
  }

  /// Resolves the ordered list of target contacts: primary first,
  /// then each [PhoneCallContactConfig.alternativeContactIds] in
  /// order. Unknown ids are dropped.
  List<EmergencyContact> _resolveTargets(
    EventServices services,
    PhoneCallContactConfig config,
  ) {
    final all = services.context.contacts;
    if (all.isEmpty) return const [];
    EmergencyContact? byId(String id) {
      for (final c in all) {
        if (c.id == id) return c;
      }
      return null;
    }

    final result = <EmergencyContact>[];
    final primary = config.contactId == null
        ? all.first
        : byId(config.contactId!);
    if (primary != null) result.add(primary);
    for (final id in config.alternativeContactIds) {
      final alt = byId(id);
      if (alt != null && !result.any((c) => c.id == alt.id)) {
        result.add(alt);
      }
    }
    return result;
  }
}
