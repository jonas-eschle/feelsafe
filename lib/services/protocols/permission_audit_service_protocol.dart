import 'package:guardianangela/domain/models/permission_audit_result.dart';
import 'package:guardianangela/domain/models/permission_revocation.dart';
import 'package:guardianangela/domain/models/session_mode.dart';

/// Abstract interface for pre-session and mid-session permission
/// auditing.
///
/// See spec 05 §Permission Audit Flow. The concrete implementation is
/// backed by `permission_handler`.
///
/// Lifecycle:
/// 1. [auditForMode] is called by `SessionController` at session-start
///    to determine which permissions are needed by the given mode and
///    whether they are granted.
/// 2. [revocations] emits mid-session when the OS revokes a permission.
///    The session continues; the controller logs the event.
abstract interface class PermissionAuditServiceProtocol {
  /// Audits the permissions required by [mode] and returns the result.
  ///
  /// Inspects only permissions that [mode] actually needs:
  /// - SMS / Phone iff the chain contains `smsContact`,
  ///   `phoneCallContact`, or `callEmergency` steps.
  /// - Location iff `mode.trackingEnabled` is true or any disarm
  ///   trigger is a GPS-arrival trigger.
  /// - Microphone iff any step opts in to `autoRecordAudio`.
  /// - Camera iff any `loudAlarm` step has `flashLight = true`.
  ///
  /// [isSimulation] controls whether missing permissions are
  /// [PermissionAuditResult.warnOnly] (`true` for simulation,
  /// `false` for real session — real session blocks on missing
  /// permissions, simulation only warns).
  Future<PermissionAuditResult> auditForMode(
    SessionMode mode, {
    bool isSimulation = false,
  });

  /// Broadcast stream of mid-session permission revocations.
  ///
  /// The implementation listens for OS-level permission change
  /// broadcasts. On Android this is a `BroadcastReceiver` for
  /// `PackageManager.ACTION_PACKAGE_FULLY_CHANGED`; on iOS there is
  /// no direct synchronous revocation event so the stream is polled
  /// at a low interval. Session continues regardless of revocations
  /// (spec 05:1176 — non-blocking failure rule).
  Stream<PermissionRevocation> get revocations;
}
