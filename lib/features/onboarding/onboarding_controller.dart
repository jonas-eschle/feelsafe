/// Onboarding-feature controller stub.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stub AsyncNotifier for the onboarding flow.
class OnboardingController extends AsyncNotifier<Object?> {
  @override
  Future<Object?> build() async => null;
}

/// Provider for `OnboardingController`.
final AsyncNotifierProvider<OnboardingController, Object?>
    onboardingControllerProvider =
    AsyncNotifierProvider<OnboardingController, Object?>(
  OnboardingController.new,
);
