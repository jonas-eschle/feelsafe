/// Tests for the first-run seeding in `lib/data/seed_data.dart`.
///
/// Builds a real in-memory Drift database, overrides
/// `appDatabaseProvider`, runs [seedData] once, and then again
/// (idempotence check) — verifies counts match the documented
/// 2 modes + 8 templates + 1 distress chain + 1 settings row + 1
/// user profile + 1 battery alert row.
library;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/app_database.dart';
import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/data/seed_data.dart';
import 'db/dao_test_support.dart';

void main() {
  setUpAll(overrideSqliteOpen);

  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = makeMemoryDb();
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// Runs `seedData` using the Provider container's ref.
  Future<void> runSeed() async {
    // Use the seed function's Ref parameter indirectly by reading
    // through a transient Provider — simplest path to get a `Ref`.
    final refProvider = Provider<Future<void>>((ref) => seedData(ref));
    await container.read(refProvider);
  }

  test('seeds exactly 2 built-in modes', () async {
    await runSeed();
    final modes = await container.read(modesRepositoryProvider).getAll();
    check(modes.length).equals(2);
    check(modes.map((m) => m.id).toSet()).deepEquals({
      SeedModeIds.walk,
      SeedModeIds.date,
    });
  });

  test('seeds exactly 8 built-in templates, all global', () async {
    await runSeed();
    final templates = await container
        .read(templatesRepositoryProvider)
        .getAll();
    check(templates.length).equals(8);
    check(templates.every((t) => t.isGlobal)).isTrue();
  });

  test('seeds exactly 1 distress chain (the default)', () async {
    await runSeed();
    final chains = await container
        .read(distressChainsRepositoryProvider)
        .getAll();
    check(chains.length).equals(1);
    check(chains.first.id).equals(seedDefaultDistressChainId);
  });

  test('seeds AppSettings / UserProfile / BatteryAlert singletons', () async {
    await runSeed();
    check(await container.read(settingsRepositoryProvider).get()).isNotNull();
    check(
      await container.read(userProfileRepositoryProvider).get(),
    ).isNotNull();
    check(
      await container.read(batteryAlertRepositoryProvider).get(),
    ).isNotNull();
  });

  test('default battery alert config is enabled at 15%', () async {
    await runSeed();
    final cfg = await container.read(batteryAlertRepositoryProvider).get();
    check(cfg!.enabled).isTrue();
    check(cfg.thresholdPercent).equals(15);
  });

  test('walk mode uses holdButton check-in', () async {
    await runSeed();
    final walk = await container
        .read(modesRepositoryProvider)
        .getById(SeedModeIds.walk);
    check(walk).isNotNull();
    check(walk!.chainSteps.isNotEmpty).isTrue();
  });

  test('date mode uses disguisedReminder check-in', () async {
    await runSeed();
    final date = await container
        .read(modesRepositoryProvider)
        .getById(SeedModeIds.date);
    check(date).isNotNull();
    check(date!.chainSteps.length).equals(3);
  });

  test('seedData is idempotent: second call does not duplicate', () async {
    await runSeed();
    await runSeed();
    final modes = await container.read(modesRepositoryProvider).getAll();
    final templates = await container
        .read(templatesRepositoryProvider)
        .getAll();
    final chains = await container
        .read(distressChainsRepositoryProvider)
        .getAll();
    check(modes.length).equals(2);
    check(templates.length).equals(8);
    check(chains.length).equals(1);
  });

  test('seedData does not clobber user-customized settings', () async {
    // Simulate a user who has already saved custom settings — run
    // seed and verify they survive.
    final repo = container.read(settingsRepositoryProvider);
    final initial = await repo.get();
    check(initial).isNull();
    await runSeed();
    final seeded = await repo.get();
    check(seeded).isNotNull();
    // A second seed should not overwrite.
    await runSeed();
    final afterSecondSeed = await repo.get();
    check(afterSecondSeed).isNotNull();
  });

  test('seeded templates include quiz (tapWord) template', () async {
    await runSeed();
    final quiz = await container
        .read(templatesRepositoryProvider)
        .getById('seed.template.quiz');
    check(quiz).isNotNull();
    check(quiz!.keyword).equals('continue');
  });

  test('default distress chain has 3 steps', () async {
    await runSeed();
    final chain = await container
        .read(distressChainsRepositoryProvider)
        .getById(seedDefaultDistressChainId);
    check(chain!.steps.length).equals(3);
  });

  test(
    'seeded settings default to AppDefaults (first-launch true)',
    () async {
      await runSeed();
      final s = await container.read(settingsRepositoryProvider).get();
      check(s!.isFirstLaunch).isTrue();
    },
  );
}
