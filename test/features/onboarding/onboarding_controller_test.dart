/// Unit tests for [OnboardingController]'s state plumbing.
///
/// WID-001 (`test/integration/onboarding_flow_widget_test.dart`) covers the
/// full completion flow against recording repositories (and deliberately
/// fails the database read — see its library doc). These container tests
/// fill the gaps that leaves: the contact-count watcher against a REAL
/// in-memory Drift DB, the profile-draft copyWith preservation semantics
/// the profile page relies on, and the bug-#13 await-half — the
/// keep-alive `firstLaunchProvider` cache must already expose `false`
/// the moment `completeOnboarding()` returns (the route-outcome half is
/// pinned in `test/router/app_router_test.dart`).
///
/// Spec ref: `docs/spec/04-screens-navigation.md §Onboarding` (page 2's
/// "add emergency contact" card flips once a contact exists).
library;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/data/repositories/app_settings_repository.dart';
import 'package:guardianangela/data/repositories/user_profile_repository.dart';
import 'package:guardianangela/domain/models/app_settings.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/domain/models/user_profile.dart';
import 'package:guardianangela/features/onboarding/onboarding_controller.dart';
import 'package:guardianangela/router/app_router.dart';
import 'package:guardianangela/services/service_providers.dart';

/// [AppSettingsRepository] whose [save] round-trips into [load] — the
/// REAL `completeOnboarding` persists `isFirstLaunch = false` and the
/// provider re-load must observe it (mirrors the app_router_test
/// harness; the fixed-value fake would keep loading `true`).
final class _RoundTripSettingsRepository extends AppSettingsRepository {
  _RoundTripSettingsRepository(this.value)
    : super(
        keyProvider: () async => '00' * 33,
        resolveDir: () async => throw UnimplementedError('no disk in tests'),
      );

  AppSettings value;

  @override
  Future<AppSettings> load() async => value;

  @override
  Future<AppSettings?> loadOrNull() async => value;

  @override
  Future<void> save(AppSettings newValue) async => value = newValue;
}

/// [UserProfileRepository] whose [save] round-trips in memory (the real
/// `save` would hit the disk).
final class _RoundTripProfileRepository extends UserProfileRepository {
  _RoundTripProfileRepository(this.value)
    : super(keyProvider: () async => '00' * 32);

  UserProfile value;

  @override
  Future<UserProfile> load() async => value;

  @override
  Future<void> save(UserProfile newValue) async => value = newValue;
}

void main() {
  late GuardianAngelaDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
    container = ProviderContainer(
      overrides: <Override>[databaseProvider.overrideWith((_) async => db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('OnboardingController — contact count watcher', () {
    test('build surfaces the saved contact count from the real db', () async {
      await db.contactsDao.upsert(
        EmergencyContact(
          id: 'c1',
          name: 'Alice',
          phoneNumber: '+15550100',
          sortOrder: 0,
        ),
      );
      await db.contactsDao.upsert(
        EmergencyContact(
          id: 'c2',
          name: 'Bob',
          phoneNumber: '+15550101',
          sortOrder: 1,
        ),
      );

      // First read mounts the Notifier; the count arrives via the
      // build-time microtask once the db future resolves.
      check(
        container.read(onboardingControllerProvider).contactCount,
      ).equals(0);
      await container.read(databaseProvider.future);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      check(
        container.read(onboardingControllerProvider).contactCount,
      ).equals(2);
    });
  });

  group('OnboardingController.updateProfileDraft', () {
    test('stores the typed name + phone in the in-memory draft', () {
      container
          .read(onboardingControllerProvider.notifier)
          .updateProfileDraft(name: 'Sam Carter', phone: '+15557654321');

      final OnboardingState s = container.read(onboardingControllerProvider);
      check(s.draftName).equals('Sam Carter');
      check(s.draftPhone).equals('+15557654321');
    });

    test('an omitted field preserves the previous draft value '
        '(copyWith ?? semantics)', () {
      final notifier = container.read(onboardingControllerProvider.notifier);
      notifier.updateProfileDraft(name: 'Sam', phone: '+15550100');

      notifier.updateProfileDraft(name: 'Max');

      final OnboardingState s = container.read(onboardingControllerProvider);
      check(s.draftName).equals('Max');
      check(s.draftPhone).equals('+15550100');
    });
  });

  group('OnboardingController.completeOnboarding — firstLaunchProvider', () {
    test('the keep-alive cache already exposes false the moment '
        'completeOnboarding returns (bug #13 await-half: invalidate '
        'without the awaited re-read leaves the stale true visible to '
        'the router redirect)', () async {
      final settingsRepo = _RoundTripSettingsRepository(const AppSettings());
      final localDb = GuardianAngelaDatabase.memory(seedCallback: (_) async {});
      final c = ProviderContainer(
        overrides: <Override>[
          databaseProvider.overrideWith((_) async => localDb),
          appSettingsRepositoryProvider.overrideWithValue(settingsRepo),
          userProfileRepositoryProvider.overrideWithValue(
            _RoundTripProfileRepository(const UserProfile()),
          ),
        ],
      );
      addTearDown(() async {
        c.dispose();
        await localDb.close();
      });

      // Prime the keep-alive cache with the value that routed the user
      // to /onboarding — exactly the value that must not go stale.
      check(await c.read(firstLaunchProvider.future)).isTrue();

      await c.read(onboardingControllerProvider.notifier).completeOnboarding();

      // The flag was persisted...
      check(settingsRepo.value.isFirstLaunch).isFalse();
      // ...and the await-half holds: with NO extra pump/microtask the
      // provider is already AsyncData(false) — not loading, not the
      // stale true (onboarding_controller.dart:106-107).
      check(c.read(firstLaunchProvider).value).isNotNull().isFalse();
      check(await c.read(firstLaunchProvider.future)).isFalse();
    });
  });
}
