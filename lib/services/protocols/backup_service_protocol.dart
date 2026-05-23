/// Abstract interface for JSON export/import of app data.
///
/// See spec 05 §BackupService. Phase 5 supplies the concrete
/// implementation. Export is triggered by the UI via `share_plus`;
/// import is driven by a file picker.
abstract interface class BackupServiceProtocol {
  /// Assembles all repositories into a JSON export string.
  ///
  /// The export includes contacts, modes, settings, templates, event
  /// defaults, user profile, and optionally session logs and media.
  ///
  /// [includeSessionLogs] defaults to `true`; set to `false` to
  /// produce a smaller backup without location or session data.
  /// [includeMedia] defaults to `true`; set to `false` to omit audio
  /// recordings and profile photos.
  ///
  /// Returns the JSON string to be written to a file or passed to
  /// `share_plus`.
  Future<String> exportToJson({
    bool includeSessionLogs = true,
    bool includeMedia = true,
  });

  /// Parses and validates [json] then writes all data to the Drift
  /// database and JSON-backed singletons.
  ///
  /// Import is performed inside a single transaction. On success all
  /// existing data is replaced. On failure throws an exception with a
  /// descriptive message and leaves existing data untouched.
  ///
  /// Throws [FormatException] on malformed JSON.
  /// Throws [StateError] if the export's `_schemaVersion` is greater
  /// than the running app's schema version (forward-incompatible).
  Future<void> importFromJson(String json);
}
