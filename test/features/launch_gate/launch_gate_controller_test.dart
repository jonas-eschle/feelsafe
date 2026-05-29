/// Unit tests for [LaunchGateController] — the in-memory App-lock state.
///
/// Spec ref: `docs/spec/06-settings.md §App PIN` (cold-start-only gate).
library;

import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/features/launch_gate/launch_gate_controller.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  test('defaults to unlocked', () {
    check(container.read(launchGateProvider)).isFalse();
  });

  test('lockForLaunch locks when an App PIN is set', () {
    container.read(launchGateProvider.notifier).lockForLaunch(appPinSet: true);
    check(container.read(launchGateProvider)).isTrue();
  });

  test('lockForLaunch stays unlocked when no App PIN is set', () {
    container.read(launchGateProvider.notifier).lockForLaunch(appPinSet: false);
    check(container.read(launchGateProvider)).isFalse();
  });

  test('unlock clears a locked gate', () {
    final notifier = container.read(launchGateProvider.notifier)
      ..lockForLaunch(appPinSet: true);
    check(container.read(launchGateProvider)).isTrue();
    notifier.unlock();
    check(container.read(launchGateProvider)).isFalse();
  });
}
