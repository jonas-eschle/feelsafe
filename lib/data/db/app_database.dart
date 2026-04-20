/// Drift database skeleton. Phase 6 wires in the actual schema,
/// `@DriftDatabase` annotation, and code-generation glue; until then
/// this is a placeholder whose every method throws
/// [UnimplementedError].
///
/// We deliberately do NOT add a `drift` import yet — the dependency
/// is added in Phase 6 along with the generator. Once Phase 6
/// arrives, replace the stub class with:
///
/// ```dart
/// @DriftDatabase(tables: [Modes, Contacts, ...])
/// class AppDatabase extends _$AppDatabase { ... }
/// ```
library;

/// Singleton app-database stub. Every call throws
/// [UnimplementedError] until Phase 6 fills it in.
final class AppDatabase {
  AppDatabase._();

  /// Singleton instance. Phase 6 will likely replace this with a
  /// Riverpod-provided instance; for now it is a process-level
  /// singleton so early wiring has a stable reference.
  static final AppDatabase instance = AppDatabase._();

  /// Closes the underlying database. Phase 6 implements this.
  Future<void> close() async =>
      throw UnimplementedError('TODO: Phase 6 fills this in');
}
