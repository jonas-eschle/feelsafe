/// Onboarding-feature controller.
///
/// Tracks the current onboarding page and finalizes the flow by
/// flipping `AppSettings.isFirstLaunch = false` via
/// [settingsControllerProvider].
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardianangela/features/settings/settings_controller.dart';

/// Immutable onboarding-page state.
final class OnboardingState {
  /// Creates an onboarding state.
  ///
  /// [pageIndex] — current zero-based page index; defaults to 0.
  /// [isComplete] — true once the user has finished onboarding;
  /// defaults to false.
  const OnboardingState({this.pageIndex = 0, this.isComplete = false});

  /// Current zero-based page index.
  final int pageIndex;

  /// Whether onboarding is complete.
  final bool isComplete;

  /// Returns a new state with the given fields replaced.
  OnboardingState copyWith({int? pageIndex, bool? isComplete}) =>
      OnboardingState(
        pageIndex: pageIndex ?? this.pageIndex,
        isComplete: isComplete ?? this.isComplete,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingState &&
          other.pageIndex == pageIndex &&
          other.isComplete == isComplete;

  @override
  int get hashCode => Object.hash(pageIndex, isComplete);
}

/// Async controller for the onboarding flow.
class OnboardingController extends AsyncNotifier<OnboardingState> {
  @override
  Future<OnboardingState> build() async => const OnboardingState();

  /// Advances to [pageIndex].
  void goToPage(int pageIndex) {
    final current = state.value ?? const OnboardingState();
    state = AsyncValue.data(current.copyWith(pageIndex: pageIndex));
  }

  /// Marks onboarding complete by flipping
  /// `AppSettings.isFirstLaunch = false` and snapshotting the
  /// `isComplete` flag locally.
  Future<void> completeOnboarding() async {
    await ref.read(settingsControllerProvider.notifier).completeOnboarding();
    final current = state.value ?? const OnboardingState();
    state = AsyncValue.data(current.copyWith(isComplete: true));
  }
}

/// Provider for `OnboardingController`.
final AsyncNotifierProvider<OnboardingController, OnboardingState>
onboardingControllerProvider =
    AsyncNotifierProvider<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );
