/// Unit tests for [OnboardingController]'s state plumbing.
///
/// WID-001 (`test/integration/onboarding_flow_widget_test.dart`) covers the
/// full completion flow against recording repositories (and deliberately
/// fails the database read — see its library doc). These container tests
/// fill the two gaps that leaves: the contact-count watcher against a REAL
/// in-memory Drift DB, and the profile-draft copyWith preservation
/// semantics the profile page relies on.
///
/// Spec ref: `docs/spec/04-screens-navigation.md §Onboarding` (page 2's
/// "add emergency contact" card flips once a contact exists).
library;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/data/db/database.dart';
import 'package:guardianangela/domain/models/emergency_contact.dart';
import 'package:guardianangela/features/onboarding/onboarding_controller.dart';
import 'package:guardianangela/services/service_providers.dart';

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
}
