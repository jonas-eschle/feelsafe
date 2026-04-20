/// Placeholder for the first-launch onboarding flow.
///
/// Phase 12 will replace this with the 3-page onboarding flow.
library;

import 'package:flutter/material.dart';

/// First-launch onboarding; Welcome -> Profile+Contact -> Permissions.
class OnboardingScreen extends StatelessWidget {
  /// Creates the onboarding placeholder.
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Welcome')),
        body: const Center(
          child: Text('OnboardingScreen — TODO Phase 12'),
        ),
      );
}
