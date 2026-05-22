import 'dart:developer';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/orchestration/event_services.dart';
import 'package:guardianangela/domain/orchestration/event_strategy.dart';

/// Strategy for [ChainStepType.phoneCallContact] steps.
///
/// Resolves the primary contact (falling back through alternatives) and
/// dials via [PhoneServiceProtocol.call]. The engine drives retries via
/// [ChainStep.retryCount]; this strategy fires once per invocation.
///
/// Pre-call SMS is NOT part of this strategy — calling a personal contact
/// does not warrant an automatic pre-warning SMS. That feature lives only
/// on [CallEmergencyConfig.sendLocationSmsFirst] (spec 02 §7
/// phoneCallContact line 385).
///
/// Simulation: blocked. Logs `sim_blocked` and returns.
/// Simulation description: `'Would call [contact name]'`.
///
/// See spec 02 §7 phoneCallContact.
final class PhoneCallContactStrategy implements EventStrategy {
  /// Creates a [PhoneCallContactStrategy].
  const PhoneCallContactStrategy();

  @override
  Future<void> executeReal(ChainStep step, EventServices services) async {
    if (services.isSimulation) {
      log('phoneCallContact blocked in simulation', name: 'sim_blocked');
      return;
    }

    final config = step.config is PhoneCallContactConfig
        ? step.config! as PhoneCallContactConfig
        : const PhoneCallContactConfig();

    final contact = _resolveContact(config, services);
    if (contact == null) {
      log(
        'phoneCallContact: no contact resolved; skipping call',
        name: 'PhoneCallContactStrategy',
      );
      return;
    }

    await services.phone.call(contact.phoneNumber);
  }

  @override
  String? simulationDescription(ChainStep step, EventServices services) {
    final config = step.config is PhoneCallContactConfig
        ? step.config! as PhoneCallContactConfig
        : const PhoneCallContactConfig();

    final contact = _resolveContact(config, services);
    if (contact == null) {
      return 'Would call (no contact resolved)';
    }
    return 'Would call ${contact.name}';
  }

  /// Resolves the primary contact, falling back through alternatives.
  ///
  /// Priority order:
  /// 1. [PhoneCallContactConfig.contactId] if non-null.
  /// 2. First contact by [EmergencyContact.sortOrder] if primary is null.
  /// 3. Each ID in [PhoneCallContactConfig.alternativeContactIds] in order
  ///    if the primary cannot be resolved.
  EmergencyContact? _resolveContact(
    PhoneCallContactConfig config,
    EventServices services,
  ) {
    // Try primary contact.
    if (config.contactId != null) {
      final primary = services.contacts.byId(config.contactId!);
      if (primary != null) {
        return primary;
      }
    } else {
      // No explicit primary — use first-sorted contact.
      final all = services.contacts.all;
      if (all.isNotEmpty) {
        final sorted = List<EmergencyContact>.from(all)
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return sorted.first;
      }
    }

    // Fall back through alternatives.
    for (final altId in config.alternativeContactIds) {
      final alt = services.contacts.byId(altId);
      if (alt != null) {
        return alt;
      }
    }

    return null;
  }
}
