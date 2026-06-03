/// Unit tests for [HomeChecklistRepository] — the SharedPreferences-backed
/// flag store behind the Safety Setup Checklist (spec 04 §Safety Setup
/// Checklist — Behavior). Exercises the real read/write/round-trip paths
/// (the widget tests use an in-memory fake) plus the no-throw fallbacks.
library;

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:guardianangela/features/home/home_checklist_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeChecklistRepository — defaults', () {
    setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

    test('every flag defaults to false when nothing is persisted', () async {
      final repo = HomeChecklistRepository();
      check(await repo.dismissed()).isFalse();
      check(await repo.simulationDone()).isFalse();
      check(await repo.firstVisitDone()).isFalse();
      check(await repo.allDoneCelebrated()).isFalse();
    });
  });

  group('HomeChecklistRepository — round trip', () {
    setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

    test('setDismissed persists and reads back true', () async {
      final repo = HomeChecklistRepository();
      await repo.setDismissed();
      check(await repo.dismissed()).isTrue();
    });

    test('markSimulationDone persists and reads back true', () async {
      final repo = HomeChecklistRepository();
      await repo.markSimulationDone();
      check(await repo.simulationDone()).isTrue();
    });

    test('markFirstVisitDone persists and reads back true', () async {
      final repo = HomeChecklistRepository();
      await repo.markFirstVisitDone();
      check(await repo.firstVisitDone()).isTrue();
    });

    test('markAllDoneCelebrated persists and reads back true', () async {
      final repo = HomeChecklistRepository();
      await repo.markAllDoneCelebrated();
      check(await repo.allDoneCelebrated()).isTrue();
    });

    test('flags are independent of one another', () async {
      final repo = HomeChecklistRepository();
      await repo.markAllDoneCelebrated();
      check(await repo.allDoneCelebrated()).isTrue();
      check(await repo.dismissed()).isFalse();
      check(await repo.simulationDone()).isFalse();
      check(await repo.firstVisitDone()).isFalse();
    });
  });

  group('HomeChecklistRepository — no-throw on backend failure', () {
    Future<SharedPreferences> boom() async =>
        throw StateError('prefs backend unavailable');

    test('reads fall back to false when the backend throws', () async {
      final repo = HomeChecklistRepository(prefsLoader: boom);
      check(await repo.dismissed()).isFalse();
      check(await repo.simulationDone()).isFalse();
      check(await repo.firstVisitDone()).isFalse();
      check(await repo.allDoneCelebrated()).isFalse();
    });

    test('writes swallow backend errors without throwing', () async {
      final repo = HomeChecklistRepository(prefsLoader: boom);
      // None of these may throw — they are best-effort.
      await repo.setDismissed();
      await repo.markSimulationDone();
      await repo.markFirstVisitDone();
      await repo.markAllDoneCelebrated();
    });
  });
}
