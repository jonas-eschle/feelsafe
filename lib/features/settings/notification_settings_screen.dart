/// Placeholder for the system-notifications config screen.
library;

import 'package:flutter/material.dart';

/// Edits notification channels, priorities, and DND override.
class NotificationSettingsScreen extends StatelessWidget {
  /// Creates the notification-settings placeholder.
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const Center(
          child: Text('NotificationSettingsScreen — TODO Phase 12'),
        ),
      );
}
