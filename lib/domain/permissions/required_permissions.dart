/// Pre-flight permission audit for a [SessionMode].
///
/// Determines which runtime permissions a mode's chain actually
/// needs so the UI can prompt only for what's missing at session
/// start — instead of requesting everything up-front or failing
/// silently mid-escalation.
library;

import 'package:guardianangela/data/models/enums.dart';
import 'package:guardianangela/domain/models/chain_step.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/models/step_config.dart';
import 'package:guardianangela/domain/models/trigger.dart';
import 'package:guardianangela/services/protocols/permission_service_protocol.dart';

/// One of the four runtime permission categories a chain may need.
enum RequiredPermission {
  /// Notification post permission (Android 13+). Needed for
  /// disguised-reminder steps.
  notification,

  /// Foreground location. Needed for any step that includes location
  /// (SMS with `includeLocation=true`), any GPS arrival disarm
  /// trigger, or interval tracking.
  location,

  /// `CALL_PHONE` permission (Android). Needed for direct dial:
  /// `phoneCallContact`, `callEmergency`, and `smsContact` when the
  /// channel is `phoneCall`. iOS does not gate `tel:` URIs.
  callPhone,

  /// `SEND_SMS` permission (Android). Needed for `smsContact` when
  /// the channel is `sms`. iOS uses the system Messages compose sheet
  /// and does not require this permission.
  sendSms,
}

/// Returns the minimal set of [RequiredPermission]s the engine
/// actually needs to run [mode]'s chain to completion.
///
/// Pure function — does not touch the platform. Iterate the chain
/// once, the disarm-trigger list once, and the trackingEnabled flag.
Set<RequiredPermission> requiredPermissionsForMode(SessionMode mode) {
  final perms = <RequiredPermission>{};

  if (mode.trackingEnabled) {
    perms.add(RequiredPermission.location);
  }

  for (final t in mode.disarmTriggers) {
    if (t is GpsArrivalDisarmTrigger) {
      perms.add(RequiredPermission.location);
    }
  }

  for (final step in mode.chainSteps) {
    _accumulateForStep(step, perms);
  }

  return perms;
}

void _accumulateForStep(ChainStep step, Set<RequiredPermission> out) {
  switch (step.type) {
    case ChainStepType.disguisedReminder:
      out.add(RequiredPermission.notification);
    case ChainStepType.smsContact:
      final cfg = step.config;
      final channel = cfg is SmsContactConfig ? cfg.channel : MessageChannel.sms;
      switch (channel) {
        case MessageChannel.sms:
          out.add(RequiredPermission.sendSms);
        case MessageChannel.phoneCall:
          out.add(RequiredPermission.callPhone);
        case MessageChannel.whatsapp:
        case MessageChannel.telegram:
          // Routed via app intent; no system permission.
          break;
      }
      final includesLocation =
          cfg is SmsContactConfig ? cfg.includeLocation : true;
      if (includesLocation) {
        out.add(RequiredPermission.location);
      }
    case ChainStepType.phoneCallContact:
    case ChainStepType.callEmergency:
      out.add(RequiredPermission.callPhone);
    case ChainStepType.holdButton:
    case ChainStepType.countdownWarning:
    case ChainStepType.fakeCall:
    case ChainStepType.loudAlarm:
    case ChainStepType.hardwareButton:
      break;
  }
}

/// Walks the required-permissions set, asks [service] to ensure each
/// one (which surfaces the system dialog when needed), and returns
/// the subset that ended up *denied* after the request flow.
///
/// An empty result means every required permission is granted and
/// the engine can start. A non-empty result means the caller should
/// show a dialog naming the still-missing permissions and offer
/// either to retry or open app settings.
Future<Set<RequiredPermission>> ensureSessionPermissions({
  required PermissionServiceProtocol service,
  required SessionMode mode,
}) async {
  final required = requiredPermissionsForMode(mode);
  final denied = <RequiredPermission>{};
  for (final p in required) {
    final granted = switch (p) {
      RequiredPermission.notification => await service.ensureNotification(),
      RequiredPermission.location => await service.ensureLocation(),
      RequiredPermission.callPhone => await service.ensureCallPhone(),
      RequiredPermission.sendSms => await service.ensureSendSms(),
    };
    if (!granted) denied.add(p);
  }
  return denied;
}
