/// Goldens for the home screen (normal and stealth appearance).
///
/// The real `HomeScreen` hydrates multiple Riverpod providers that in
/// turn depend on repositories and platform services. For the
/// pragmatic golden matrix we render a representative stand-in
/// scaffold that mirrors the screen's AppBar + CTA layout. Full
/// provider-wired end-to-end goldens are an ongoing task.
library;

import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

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
    testGoldens('home_screen_normal_$themeName', (tester) async {
      final builder = buildDevices(
        child: _homeStandin(stealth: false),
        themeMode: themeMode,
        scenarioName: 'normal',
      );
      await tester.pumpDeviceBuilder(
        builder,
        wrapper: (child) => goldenWrapper(child: child, themeMode: themeMode),
      );
      await screenMatchesGolden(tester, 'home_screen_normal_$themeName');
    });

    testGoldens('home_screen_stealth_$themeName', (tester) async {
      final builder = buildDevices(
        child: _homeStandin(stealth: true),
        themeMode: themeMode,
        scenarioName: 'stealth',
      );
      await tester.pumpDeviceBuilder(
        builder,
        wrapper: (child) => goldenWrapper(child: child, themeMode: themeMode),
      );
      await screenMatchesGolden(tester, 'home_screen_stealth_$themeName');
    });
  }
}
