/// Goldens for the home screen (normal and stealth appearance).
library;

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';

import 'goldens_setup.dart';

Widget _homeStandin({required bool stealth}) => Scaffold(
  appBar: AppBar(
    title: stealth
        ? const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Calendar'),
              Text('calendar', style: TextStyle(fontSize: 10)),
            ],
          )
        : const Text('Guardian Angela'),
    actions: const [Icon(Icons.settings), SizedBox(width: 8)],
  ),
  body: Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          initialValue: 'walk',
          decoration: const InputDecoration(labelText: 'Select mode'),
          items: const [
            DropdownMenuItem(value: 'walk', child: Text('Walk Mode')),
            DropdownMenuItem(value: 'date', child: Text('Date Mode')),
          ],
          onChanged: (_) {},
        ),
        const SizedBox(height: 24),
        SwitchListTile(
          value: false,
          onChanged: (_) {},
          title: const Text('Simulation'),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start session'),
        ),
      ],
    ),
  ),
);

void main() {
  for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
    final themeName = themeMode == ThemeMode.light ? 'light' : 'dark';
    goldenTest(
      'home_screen normal $themeName',
      fileName: 'home_screen_normal_$themeName',
      builder: () => goldenWrapper(
        child: _homeStandin(stealth: false),
        themeMode: themeMode,
      ),
    );
    goldenTest(
      'home_screen stealth $themeName',
      fileName: 'home_screen_stealth_$themeName',
      builder: () => goldenWrapper(
        child: _homeStandin(stealth: true),
        themeMode: themeMode,
      ),
    );
  }
}
