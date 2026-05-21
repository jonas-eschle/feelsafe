/// Tests for [OnboardingController] — page navigation and completing
/// onboarding (flips [AppSettings.isFirstLaunch]).
library;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import 'package:guardianangela/data/repositories/repository_providers.dart';
import 'package:guardianangela/features/onboarding/onboarding_controller.dart';
import 'package:guardianangela/features/settings/settings_controller.dart';

import '../fake_repositories.dart';

ProviderContainer _makeContainer() {
  final repo = FakeSettingsRepository();
  return ProviderContainer(
    overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
  );
}

void main() {
  group('OnboardingController.build', () {
    test('starts on page 0 and incomplete', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final s = await container.read(onboardingControllerProvider.future);
      check(s.pageIndex).equals(0);
      check(s.isComplete).isFalse();
    });
  });

  group('OnboardingController.goToPage', () {
    test('updates pageIndex', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(onboardingControllerProvider.notifier);
      await container.read(onboardingControllerProvider.future);
      notifier.goToPage(2);
      final s = container.read(onboardingControllerProvider).value!;
      check(s.pageIndex).equals(2);
      check(s.isComplete).isFalse();
    });

    test('goToPage many times', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(onboardingControllerProvider.notifier);
      await container.read(onboardingControllerProvider.future);
      notifier.goToPage(1);
      notifier.goToPage(2);
      notifier.goToPage(0);
      final s = container.read(onboardingControllerProvider).value!;
      check(s.pageIndex).equals(0);
    });
  });

  group('OnboardingController.completeOnboarding', () {
    test('sets isComplete and flips isFirstLaunch', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final notifier = container.read(onboardingControllerProvider.notifier);
      await container.read(onboardingControllerProvider.future);
      await notifier.completeOnboarding();
      final ob = container.read(onboardingControllerProvider).value!;
      check(ob.isComplete).isTrue();
      final s =
          await container.read(settingsControllerProvider.future);
      check(s.isFirstLaunch).isFalse();
    });
  });

  group('OnboardingState', () {
    test('equality and hashCode', () {
      const a = OnboardingState(pageIndex: 1, isComplete: true);
      const b = OnboardingState(pageIndex: 1, isComplete: true);
      const c = OnboardingState(pageIndex: 2, isComplete: true);
      check(a == b).isTrue();
      check(a == c).isFalse();
      check(a.hashCode).equals(b.hashCode);
    });

    test('copyWith replaces only specified fields', () {
      const orig = OnboardingState(pageIndex: 1);
      final copied = orig.copyWith(isComplete: true);
      check(copied.pageIndex).equals(1);
      check(copied.isComplete).isTrue();
    });
  });
}
