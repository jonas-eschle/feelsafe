/// Goldens for the three onboarding pages (Welcome, Profile+Contact,
/// Permissions). Each page is rendered in isolation.
library;

import 'package:flutter/material.dart';
import 'package:alchemist/alchemist.dart';

import 'goldens_setup.dart';

Widget _welcomePage() => Scaffold(
  body: SafeArea(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.shield, size: 144),
            SizedBox(height: 32),
            Text(
              'Welcome to Guardian Angela',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            Text(
              'Your dead man\'s switch safety companion',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  ),
);

Widget _profilePage() => Scaffold(
  body: SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Your profile',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text('Tell us who to trust'),
          SizedBox(height: 24),
          TextField(decoration: InputDecoration(labelText: 'Name')),
          SizedBox(height: 16),
          Text(
            'Emergency contact',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          TextField(decoration: InputDecoration(labelText: 'Contact name')),
          SizedBox(height: 8),
          TextField(decoration: InputDecoration(labelText: 'Phone number')),
        ],
      ),
    ),
  ),
);

Widget _permissionsPage() => Scaffold(
  body: SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.lock_open, size: 96),
          SizedBox(height: 24),
          Text(
            'Permissions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16),
          Text(
            'Guardian Angela needs a few permissions to keep you safe.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  ),
);

void main() {
  final pages = {
    'welcome': _welcomePage(),
    'profile': _profilePage(),
    'permissions': _permissionsPage(),
  };
  for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
    final themeName = themeMode == ThemeMode.light ? 'light' : 'dark';
    pages.forEach((pageName, pageWidget) {
      goldenTest(
      'onboarding_${pageName}_$themeName',
      fileName: 'onboarding_${pageName}_$themeName',
      builder: () => goldenWrapper(child: pageWidget, themeMode: themeMode),
    );
    });
  }
}
