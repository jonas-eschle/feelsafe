import 'package:guardianangela/domain/enums/app_permission.dart';

/// The result of a pre-session permission audit.
///
/// See spec 05 §Permission Audit Flow. [allGranted] must be `true`
/// before a real session can start; [warnOnly] is `true` for
/// simulation sessions (missing permissions warn but do not block).
final class PermissionAuditResult {
  /// Creates an audit result.
  const PermissionAuditResult({required this.missing, required this.warnOnly});

  /// Convenience constructor for a fully-granted audit.
  const PermissionAuditResult.allGranted()
    : missing = const [],
      warnOnly = false;

  /// The list of permissions that are not currently granted for the
  /// audited mode.
  final List<AppPermission> missing;

  /// When `true` the missing permissions are displayed as warnings and
  /// the session can still start (simulation mode).
  ///
  /// When `false` (real session) the session controller blocks start
  /// until all [missing] permissions are granted.
  final bool warnOnly;

  /// `true` iff all required permissions are granted.
  bool get allGranted => missing.isEmpty;
}
