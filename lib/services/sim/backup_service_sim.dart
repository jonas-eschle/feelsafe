import 'package:guardianangela/services/protocols/backup_service_protocol.dart';

/// Simulation [BackupServiceProtocol] for tests and simulation sessions.
///
/// Records all export and import calls for test assertions. Never writes
/// to disk or any repository.
class SimulationBackupService implements BackupServiceProtocol {
  /// Creates a [SimulationBackupService].
  ///
  /// [fixedExport] is the JSON string returned by [exportToJson].
  /// Defaults to a minimal valid export envelope if not provided.
  SimulationBackupService({String? fixedExport})
    : _fixedExport =
          fixedExport ??
          '{"version":"1.0","_schemaVersion":1,"timestamp":"",'
              '"contacts":[],"modes":[],"settings":{},'
              '"templates":[],"eventDefaults":{},"profile":{}}';

  final String _fixedExport;

  /// All [exportToJson] call records since construction or [reset].
  final List<({bool includeSessionLogs, bool includeMedia})> exportCalls = [];

  /// All [importFromJson] JSON strings passed since construction or [reset].
  final List<String> importCalls = [];

  // ---------------------------------------------------------------------------
  // BackupServiceProtocol implementation
  // ---------------------------------------------------------------------------

  @override
  Future<String> exportToJson({
    bool includeSessionLogs = true,
    bool includeMedia = true,
  }) async {
    exportCalls.add((
      includeSessionLogs: includeSessionLogs,
      includeMedia: includeMedia,
    ));
    return _fixedExport;
  }

  @override
  Future<void> importFromJson(String json) async {
    importCalls.add(json);
  }

  // ---------------------------------------------------------------------------
  // Test helpers
  // ---------------------------------------------------------------------------

  /// Clears [exportCalls] and [importCalls].
  void reset() {
    exportCalls.clear();
    importCalls.clear();
  }
}
