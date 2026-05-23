import 'package:guardianangela/domain/enums/app_permission.dart';

/// Emitted by [PermissionAuditServiceProtocol.revocations] when the OS
/// revokes a permission mid-session.
///
/// See spec 05 §Permission Audit Flow §mid-session revocation. The
/// session controller records this as a `SessionLogEvent` with
/// `eventType: 'permission_revoked'` and continues the session.
final class PermissionRevocation {
  /// Creates a [PermissionRevocation] event.
  const PermissionRevocation({
    required this.permission,
    required this.revokedAt,
  });

  /// The permission that was revoked.
  final AppPermission permission;

  /// Wall-clock time at which the revocation was detected, in UTC.
  final DateTime revokedAt;

  @override
  String toString() =>
      'PermissionRevocation(permission=$permission, revokedAt=$revokedAt)';
}
