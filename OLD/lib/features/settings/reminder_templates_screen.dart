/// Redirects to the shared templates screen.
library;

import 'package:flutter/material.dart';

import 'package:guardianangela/features/templates/templates_screen.dart';

/// Reminder-templates screen (proxies the shared templates screen).
class ReminderTemplatesScreen extends StatelessWidget {
  /// Creates the reminder-templates screen.
  const ReminderTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) => const TemplatesScreen();
}
