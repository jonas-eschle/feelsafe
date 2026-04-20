/// Placeholder for the user-profile screen.
library;

import 'package:flutter/material.dart';

/// User identity + medical information; included in emergency SMS.
class ProfileScreen extends StatelessWidget {
  /// Creates the profile-screen placeholder.
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(
          child: Text('ProfileScreen — TODO Phase 12'),
        ),
      );
}
