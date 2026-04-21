/// Shared setup helpers for DAO tests.
///
/// Provides an in-memory [AppDatabase] factory and the
/// Debian/Ubuntu `libsqlite3.so.0` override used by
/// `test/integration/db_round_trip_test.dart`.
library;

import 'dart:ffi';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:sqlite3/open.dart';

import 'package:guardianangela/data/db/app_database.dart';

/// Creates a fresh in-memory [AppDatabase] for a single test.
AppDatabase makeMemoryDb() => AppDatabase.forTesting(NativeDatabase.memory());

/// Routes `package:sqlite3` to the platform-packaged `so.0` when the
/// test host has no bare `libsqlite3.so`. Needed on Debian/Ubuntu CI.
void overrideSqliteOpen() {
  if (!Platform.isLinux) return;
  const candidates = [
    '/usr/lib/x86_64-linux-gnu/libsqlite3.so.0',
    '/usr/lib/aarch64-linux-gnu/libsqlite3.so.0',
    '/usr/lib/libsqlite3.so.0',
  ];
  for (final path in candidates) {
    if (File(path).existsSync()) {
      open.overrideFor(OperatingSystem.linux, () => DynamicLibrary.open(path));
      return;
    }
  }
}
