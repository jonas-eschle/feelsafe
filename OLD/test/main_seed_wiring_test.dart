/// Verifies that the production `main.dart` seed-on-launch wiring
/// actually seeds Walk Mode and Date Mode through the
/// `appDatabaseProvider`-backed repositories.
///
/// This test mirrors `main.dart`'s `appRunner` block EXACTLY (minus
/// the Sentry/Notification/BatteryMonitor sections, which are out
/// of scope) so a regression in the wiring would surface here.
library;

import 'package:checks/checks.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/app_database.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/data/seed_data.dart';

void main() {
  test(
    'main.dart-style wiring: seedData populates Walk Mode + Date Mode + '
    'default distress mode on first read of a fresh container',
    () async {
      // Mirror main.dart: ProviderContainer with the real Drift
      // schema but an in-memory executor so tests don't touch disk.
      final db = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(db.close);
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      // Mirror exactly what `main.dart` does on launch.
      final seedProvider = Provider<Future<void>>((ref) => seedData(ref));
      await container.read(seedProvider);

      // Assert: both built-ins are seeded as regular SessionModes, the
      // default distress mode is seeded as a SessionMode with
      // `isDistressMode = true`.
      final modes = await container.read(modesRepositoryProvider).getAll();
      final ids = modes.map((m) => m.id).toSet();
      check(ids).contains(SeedModeIds.walk);
      check(ids).contains(SeedModeIds.date);
      check(ids).contains(seedDefaultDistressModeId);

      final walk = modes.firstWhere((m) => m.id == SeedModeIds.walk);
      check(walk.name).equals('Walk Mode');
      check(walk.isDistressMode).isFalse();
      check(walk.chainSteps.length).isGreaterThan(0);

      final date = modes.firstWhere((m) => m.id == SeedModeIds.date);
      check(date.name).equals('Date Mode');
      check(date.isDistressMode).isFalse();
      check(date.chainSteps.length).isGreaterThan(0);
    },
  );

  test(
    'second invocation of seedData is idempotent — no duplicates land '
    'in the modes list',
    () async {
      final db = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(db.close);
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      final seedProvider = Provider<Future<void>>((ref) => seedData(ref));
      await container.read(seedProvider);
      // Second run — should not insert anything new.
      final seedProvider2 = Provider<Future<void>>((ref) => seedData(ref));
      await container.read(seedProvider2);

      final modes = await container.read(modesRepositoryProvider).getAll();
      // 2 regular (walk + date) + 1 distress = 3 total.
      check(modes.length).equals(3);
    },
  );
}
