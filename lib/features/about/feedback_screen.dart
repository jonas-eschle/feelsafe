/// Placeholder for the user-feedback form.
library;

import 'package:flutter/material.dart';

/// Collects user feedback and diagnostics to send to the maintainer.
class FeedbackScreen extends StatelessWidget {
  /// Creates the feedback-screen placeholder.
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Feedback')),
        body: const Center(
          child: Text('FeedbackScreen — TODO Phase 12'),
        ),
      );
}
