/// Shared setup helpers for DAO tests.
///
/// Provides an in-memory [AppDatabase] factory. Library loading on
/// CI is now handled by the `package:sqlite3` build hook (configured
/// in `pubspec.yaml`), so no manual override is required.
library;

import 'package:drift/native.dart';

import 'package:guardianangela/data/db/app_database.dart';

/// Creates a fresh in-memory [AppDatabase] for a single test.
AppDatabase makeMemoryDb() => AppDatabase.forTesting(NativeDatabase.memory());

/// No-op kept for backwards compatibility with existing `setUpAll`
/// calls. The build hook now resolves the cipher-capable sqlite3 for
/// every supported host platform, so tests no longer need a manual
/// library override.
void overrideSqliteOpen() {}
