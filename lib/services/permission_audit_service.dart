import 'dart:async';
import 'dart:developer';

import 'package:permission_handler/permission_handler.dart';

import 'package:guardianangela/domain/configs/step_config.dart';
import 'package:guardianangela/domain/enums/app_permission.dart';
import 'package:guardianangela/domain/enums/chain_step_type.dart';
import 'package:guardianangela/domain/enums/message_channel.dart';
import 'package:guardianangela/domain/models/permission_audit_result.dart';
import 'package:guardianangela/domain/models/permission_revocation.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/domain/triggers/disarm_trigger.dart';
import 'package:guardianangela/services/protocols/permission_audit_service_protocol.dart';

/// Maps [AppPermission] to the corresponding [permission_handler] [Permission].
Permission _toHandlerPermission(AppPermission p) => switch (p) {
  AppPermission.sms => Permission.sms,
  AppPermission.phone => Permission.phone,
  AppPermission.location => Permission.location,
  AppPermission.microphone => Permission.microphone,
  AppPermission.camera => Permission.camera,
  AppPermission.notification => Permission.notification,
};

/// Production [PermissionAuditServiceProtocol] backed by
/// `package:permission_handler`.
///
/// Inspects only the permissions that [mode] actually needs (spec 05
/// §Permission Audit Flow §step 2). The [revocations] stream is backed
/// by a periodic permission poll ([pollInterval], default 5 seconds)
/// on both platforms.
///
/// **Single constructor location rule:** no `RealPermissionAuditService()`
/// call may appear outside `lib/services/service_providers.dart`
/// (CI grep enforces).
class RealPermissionAuditService implements PermissionAuditServiceProtocol {
  /// Creates a [RealPermissionAuditService].
  ///
  /// [pollInterval] defaults to 5 seconds between revocation polls. Tests
  /// inject a shorter interval to avoid long waits. The optional
  /// [permissionChecker] replaces the `permission_handler` call for tests.
  RealPermissionAuditService({
    Duration? pollInterval,
    Future<PermissionStatus> Function(Permission)? permissionChecker,
  }) : _pollInterval = pollInterval ?? const Duration(seconds: 5),
       _checker = permissionChecker ?? _defaultChecker;

  final Duration _pollInterval;
  final Future<PermissionStatus> Function(Permission) _checker;

  // Cached last-known grants for revocation detection.
  final Map<AppPermission, bool> _lastKnown = {};

  // Lazily-created broadcast stream for revocations.
  StreamController<PermissionRevocation>? _revocationController;
  Timer? _pollTimer;

  static Future<PermissionStatus> _defaultChecker(Permission p) => p.status;

  // ---------------------------------------------------------------------------
  // PermissionAuditServiceProtocol implementation
  // ---------------------------------------------------------------------------

  @override
  Future<PermissionAuditResult> auditForMode(
    SessionMode mode, {
    bool isSimulation = false,
  }) async {
    final required = _requiredPermissions(mode);
    final missing = <AppPermission>[];

    for (final perm in required) {
      final status = await _checker(_toHandlerPermission(perm));
      if (!status.isGranted) {
        missing.add(perm);
        log(
          'auditForMode: $perm is NOT granted (status=$status)',
          name: 'PermissionAuditService',
        );
      }
    }

    // Seed the last-known map for revocation detection.
    for (final perm in required) {
      _lastKnown[perm] = !missing.contains(perm);
    }

    log(
      'auditForMode: ${missing.isEmpty ? "all granted" : "missing=$missing"}'
      ' warnOnly=$isSimulation',
      name: 'PermissionAuditService',
    );

    return PermissionAuditResult(missing: missing, warnOnly: isSimulation);
  }

  @override
  Stream<PermissionRevocation> get revocations {
    _revocationController ??= StreamController<PermissionRevocation>.broadcast(
      onListen: _startPolling,
      onCancel: _stopPolling,
    );
    return _revocationController!.stream;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Computes the set of [AppPermission]s that [mode] requires.
  ///
  /// Per spec 05 §Permission Audit Flow §step 2.
  Set<AppPermission> _requiredPermissions(SessionMode mode) {
    final perms = <AppPermission>{};

    // Notifications always required.
    perms.add(AppPermission.notification);

    for (final step in mode.chainSteps) {
      switch (step.type) {
        case ChainStepType.smsContact:
          final config = step.config as SmsContactConfig?;
          final channel = config?.channel ?? MessageChannel.sms;
          // SMS channel on Android requires SEND_SMS permission.
          // WhatsApp / Telegram use URL schemes — no system permission.
          if (channel == MessageChannel.sms) {
            perms.add(AppPermission.sms);
          }
          if (config?.autoRecordAudio == true) {
            perms.add(AppPermission.microphone);
          }

        case ChainStepType.phoneCallContact:
          perms.add(AppPermission.phone);
        // PhoneCallContactConfig has no autoRecordAudio field — no mic check.

        case ChainStepType.callEmergency:
          perms.add(AppPermission.phone);

        case ChainStepType.loudAlarm:
          final config = step.config as LoudAlarmConfig?;
          final flashLight = config?.flashLight ?? true;
          if (flashLight) {
            perms.add(AppPermission.camera);
          }

        case ChainStepType.holdButton:
        case ChainStepType.disguisedReminder:
        case ChainStepType.countdownWarning:
        case ChainStepType.fakeCall:
        case ChainStepType.hardwareButton:
          // No additional permissions required.
          break;
      }
    }

    // Location iff tracking enabled OR any GPS-arrival disarm trigger.
    if (mode.trackingEnabled) {
      perms.add(AppPermission.location);
    }
    for (final trigger in mode.disarmTriggers) {
      if (trigger is GpsArrivalDisarmTrigger) {
        perms.add(AppPermission.location);
        break;
      }
    }

    return perms;
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(_pollInterval, (_) => _pollRevocations());
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _pollRevocations() async {
    final snapshot = Map<AppPermission, bool>.from(_lastKnown);
    for (final entry in snapshot.entries) {
      if (!entry.value) continue; // Was already missing — skip.
      final status = await _checker(_toHandlerPermission(entry.key));
      if (!status.isGranted) {
        log(
          'revocation detected: ${entry.key}',
          name: 'PermissionAuditService',
        );
        _lastKnown[entry.key] = false;
        _revocationController?.add(
          PermissionRevocation(
            permission: entry.key,
            revokedAt: DateTime.now().toUtc(),
          ),
        );
      }
    }
  }

  /// Releases the poll timer and stream controller.
  void dispose() {
    _stopPolling();
    _revocationController?.close();
  }
}
