/// Golden for the settings hub screen.
library;

import 'package:flutter/material.dart';
import 'package:alchemist/alchemist.dart';

import 'goldens_setup.dart';

Widget _settingsStandin() => Scaffold(
  appBar: AppBar(title: const Text('Settings')),
  body: ListView(
    children: [
      _navTile('Profile'),
      _navTile('Contacts'),
      _navTile('Modes'),
      _navTile('Distress chains'),
      const Divider(),
      _navTile('Security'),
      _navTile('Stealth'),
      const Divider(),
      const ListTile(
        title: Text('Defaults'),
        subtitle: Text('None'),
        enabled: false,
      ),
      _navTile('Event defaults'),
      _navTile('GPS logging'),
      _navTile('Reminder templates'),
      _navTile('Battery alert'),
      _navTile('Notifications'),
      _navTile('History retention'),
      const Divider(),
      _navTile('Backup'),
      _navTile('About'),
      _navTile('Feedback'),
    ],
  ),
);

Widget _navTile(String label) => ListTile(
  title: Text(label),
  trailing: const Icon(Icons.chevron_right),
  onTap: () {},
);

void main() {
  for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
    final themeName = themeMode == ThemeMode.light ? 'light' : 'dark';
    goldenTest(
      'settings_screen_$themeName',
      fileName: 'settings_screen_$themeName',
      builder: () => goldenWrapper(child: _settingsStandin(), themeMode: themeMode),
    );
  }
}
