import 'dart:async';

import 'package:guardianangela/domain/models/permission_audit_result.dart';
import 'package:guardianangela/domain/models/permission_revocation.dart';
import 'package:guardianangela/domain/models/session_mode.dart';
import 'package:guardianangela/services/protocols/permission_audit_service_protocol.dart';

/// Simulation [PermissionAuditServiceProtocol] for tests and simulation
/// sessions.
///
/// Returns constructor-injected results and exposes a [StreamController]
/// for test-driven revocation events. Calling [emitRevocation] pushes an
/// event onto [revocations] so tests can exercise the mid-session
/// revocation path.
class SimulationPermissionAuditService
    implements PermissionAuditServiceProtocol {
  /// Creates a [SimulationPermissionAuditService].
  ///
  /// [fixedResult] defaults to [PermissionAuditResult.allGranted] if not
  /// provided.
  SimulationPermissionAuditService({PermissionAuditResult? fixedResult})
    : _fixedResult = fixedResult ?? const PermissionAuditResult.allGranted();

  final PermissionAuditResult _fixedResult;

  /// All [SessionMode] values passed to [auditForMode] since construction or
  /// last [reset].
  final List<SessionMode> auditedModes = [];

  final StreamController<PermissionRevocation> _revocations =
      StreamController<PermissionRevocation>.broadcast();

  // ---------------------------------------------------------------------------
  // PermissionAuditServiceProtocol implementation
  // ---------------------------------------------------------------------------

  @override
  Future<PermissionAuditResult> auditForMode(
    SessionMode mode, {
    bool isSimulation = false,
  }) async {
    auditedModes.add(mode);
    return _fixedResult;
  }

  @override
  Stream<PermissionRevocation> get revocations => _revocations.stream;

  // ---------------------------------------------------------------------------
  // Test helpers
  // ---------------------------------------------------------------------------

  /// Pushes [event] onto the [revocations] stream to simulate a mid-session
  /// OS revocation.
  void emitRevocation(PermissionRevocation event) => _revocations.add(event);

  /// Resets [auditedModes]. Does NOT close [_revocations].
  void reset() => auditedModes.clear();

  /// Closes the revocation stream. Call in `tearDown` to avoid resource leaks.
  void dispose() => _revocations.close();
}
